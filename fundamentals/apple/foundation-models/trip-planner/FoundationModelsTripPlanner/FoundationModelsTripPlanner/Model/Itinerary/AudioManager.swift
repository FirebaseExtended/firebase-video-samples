import Foundation
import AVFoundation

actor AudioManager {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    
    private let inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!
    private let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 24000, channels: 1, interleaved: false)!
    
    private var microphoneDataQueue: AsyncStream<(Data, Float)>.Continuation?
    
    public var isPlayingAudio: Bool {
        return playerNode.isPlaying
    }
    
    init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
    }
    
    func listenToMic() async throws -> AsyncStream<(Data, Float)> {
        try configureAudioSession()
        
        let inputNode = engine.inputNode
        let hwInputFormat = inputNode.outputFormat(forBus: 0)
        
        guard let converter = try setupAudioConverter(from: hwInputFormat) else {
            throw ApplicationError("Failed to create audio converter")
        }
        
        let (stream, continuation) = AsyncStream<(Data, Float)>.makeStream()
        microphoneDataQueue = continuation
        
        installMicrophoneTap(on: inputNode, format: hwInputFormat, converter: converter, continuation: continuation)
        
        engine.prepare()
        try engine.start()
        playerNode.play()
        
        return stream
    }
    
    // MARK: - Helpers
    
    private func configureAudioSession() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetoothHFP, .allowBluetoothA2DP]
        )
        try session.setActive(true)
        #endif
        
        let inputNode = engine.inputNode
        do {
            if !inputNode.isVoiceProcessingEnabled {
                try inputNode.setVoiceProcessingEnabled(true)
            }
        } catch {
            print("Could not enable voice processing: \(error)")
        }
    }
    
    private func setupAudioConverter(from hwInputFormat: AVAudioFormat) throws -> AVAudioConverter? {
        return AVAudioConverter(from: hwInputFormat, to: inputFormat)
    }
    
    private func installMicrophoneTap(on inputNode: AVAudioInputNode, format hwInputFormat: AVAudioFormat, converter: AVAudioConverter, continuation: AsyncStream<(Data, Float)>.Continuation) {
        let targetFormat = self.inputFormat
        
        inputNode.installTap(onBus: 0, bufferSize: 16384, format: hwInputFormat) { buffer, time in
            // Calculate RMS from original float buffer before converting to Int16
            var rms: Float = 0
            if let channelData = buffer.floatChannelData?[0] {
                let frameLength = Int(buffer.frameLength)
                for i in 0..<frameLength {
                    rms += channelData[i] * channelData[i]
                }
                rms = sqrt(rms / Float(frameLength))
            }
            
            let capacity = AVAudioFrameCount(Double(buffer.frameLength) * 16000.0 / buffer.format.sampleRate)
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }
            
            var error: NSError?
            var allDone = false
            converter.convert(to: convertedBuffer, error: &error) { packetCount, outStatus in
                if allDone {
                    outStatus.pointee = .noDataNow
                    return nil
                }
                allDone = true
                outStatus.pointee = .haveData
                return buffer
            }
            
            if error == nil, let channelData = convertedBuffer.int16ChannelData {
                let data = Data(bytes: channelData[0], count: Int(convertedBuffer.frameLength) * 2)
                continuation.yield((data, rms))
            }
        }
    }
    
    func stop() {
        microphoneDataQueue?.finish()
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        playerNode.stop()
        
        do {
            if engine.inputNode.isVoiceProcessingEnabled {
                try engine.inputNode.setVoiceProcessingEnabled(false)
            }
        } catch {
            print("Failed to disable voice processing: \(error.localizedDescription)")
        }
    }
    
    func playAudio(audio data: Data) {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(data.count / 2)) else { return }
        buffer.frameLength = buffer.frameCapacity
        
        data.withUnsafeBytes { rawBuffer in
            if let baseAddress = rawBuffer.bindMemory(to: Int16.self).baseAddress,
               let channelData = buffer.int16ChannelData {
                channelData[0].update(from: baseAddress, count: Int(buffer.frameLength))
            }
        }
        
        playerNode.scheduleBuffer(buffer)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
    
    func interrupt() {
        playerNode.stop()
        playerNode.play()
    }
}
