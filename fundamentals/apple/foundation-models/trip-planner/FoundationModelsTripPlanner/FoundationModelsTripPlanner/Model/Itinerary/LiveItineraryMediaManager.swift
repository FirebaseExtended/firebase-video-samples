import Foundation
import FirebaseAILogic
import AVFoundation
import UIKit

@MainActor
final class LiveItineraryMediaManager {
    private var audioManager: AudioManager?
    private var microphoneTask = Task<Void, Never> {}
    private var videoFrameTimer: Timer?
    private var isSendingVideo = false
    
    // MARK: - Audio
    
    func startRecording(to session: LiveSession, isMuted: Bool, isPaused: Bool, currentSpeaker: SpeakerState, onSpeakerUpdate: @escaping @MainActor (Bool) -> Void) async throws {
        audioManager = AudioManager()
        guard let audioManager else { return }
        
        let stream = try await audioManager.listenToMic()
        microphoneTask = Task {
            for await (pcmData, rms) in stream {
                await processAudioBuffer(pcmData: pcmData, rms: rms, session: session, isMuted: isMuted, isPaused: isPaused, currentSpeaker: currentSpeaker, onSpeakerUpdate: onSpeakerUpdate)
            }
        }
    }
    
    private func processAudioBuffer(pcmData: Data, rms: Float, session: LiveSession, isMuted: Bool, isPaused: Bool, currentSpeaker: SpeakerState, onSpeakerUpdate: @escaping @MainActor (Bool) -> Void) async {
        let shouldSendAudio = !isMuted && !isPaused
        guard shouldSendAudio else { return }
        
        let isAISpeaking = currentSpeaker == .ai
        let noiseGateThreshold: Float = isAISpeaking ? 0.08 : 0.02
        let isUserSpeaking = rms > noiseGateThreshold
        
        if isUserSpeaking {
            await session.sendAudioRealtime(pcmData)
        } else {
            let silence = Data(count: pcmData.count)
            await session.sendAudioRealtime(silence)
        }
        
        onSpeakerUpdate(isUserSpeaking)
    }
    
    func playAudio(_ data: Data) async {
        await audioManager?.playAudio(audio: data)
    }
    
    // MARK: - Video
    
    func startVideoStreaming(from cameraManager: CameraManager, session: LiveSession, isPaused: Bool) {
        isSendingVideo = true
        cameraManager.startVideoDataOutput()
        
        videoFrameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                guard self.isSendingVideo, !isPaused else { return }
                
                if let image = await cameraManager.getLatestVideoFrame(),
                   let jpegData = image.jpegData(compressionQuality: 0.8) {
                    await session.sendVideoRealtime(jpegData, mimeType: "image/jpeg")
                }
            }
        }
    }
    
    func stopVideoStreaming(from cameraManager: CameraManager) {
        isSendingVideo = false
        videoFrameTimer?.invalidate()
        videoFrameTimer = nil
        cameraManager.stopVideoDataOutput()
    }
    
    // MARK: - Cleanup
    
    func stop() async {
        videoFrameTimer?.invalidate()
        videoFrameTimer = nil
        isSendingVideo = false
        
        await audioManager?.stop()
        microphoneTask.cancel()
        audioManager = nil
    }
}
