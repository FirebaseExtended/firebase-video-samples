import SwiftUI
import AVFoundation

struct LiveItineraryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let landmark: Landmark
    let itinerary: Itinerary.PartiallyGenerated
    let onModifyItinerary: (Int, String, Int?, String?, String?, String?) -> Void
    
    @State private var liveService: LiveItineraryService
    @State private var cameraManager = CameraManager()
    @State private var isCameraOn = false
    
    init(landmark: Landmark, itinerary: Itinerary.PartiallyGenerated, onModifyItinerary: @escaping (Int, String, Int?, String?, String?, String?) -> Void) {
        self.landmark = landmark
        self.itinerary = itinerary
        self.onModifyItinerary = onModifyItinerary
        _liveService = State(initialValue: LiveItineraryService(
            landmark: landmark,
            itinerary: itinerary,
            onModifyItinerary: onModifyItinerary
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Base Dark Background
            Color.black.ignoresSafeArea()
            
            // Foggy, Misty, Glowing Background (Always visible, behind camera)
            ZStack {
                Circle()
                    .fill(color1)
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -60, y: -150)
                
                Circle()
                    .fill(color2)
                    .frame(width: 250, height: 250)
                    .blur(radius: 90)
                    .offset(x: 100, y: 100)
                    
                Circle()
                    .fill(color3)
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: 0, y: 250)
            }
            .ignoresSafeArea()
            .scaleEffect(backgroundScale)
            .animation(backgroundAnimation, value: liveService.currentSpeaker)
            
            // Camera Feed
            if isCameraOn && cameraManager.status == .configured {
                CameraPreviewView(session: cameraManager.session)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .padding(16)
                    .padding(.top, 60)
                    .padding(.bottom, 140)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if isCameraOn && cameraManager.status == .failed {
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash.fill")
                        .font(.largeTitle)
                    Text("Camera Unavailable")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding(32)
            } else if isCameraOn && cameraManager.status == .unauthorized {
                Text("Camera access denied. Please enable in Settings.")
                    .foregroundStyle(.red)
            }
            
            // Scrolling Subtitles Overlay
            if !liveService.messages.isEmpty {
                LiveItineraryTranscriptView(messages: liveService.messages)
            }
            
            // Bottom Control Bar
            LiveItineraryControlsBar {
                LiveItineraryCameraButton(isCameraOn: $isCameraOn) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isCameraOn.toggle()
                        if isCameraOn {
                            cameraManager.start()
                            liveService.startVideoStreaming(from: cameraManager)
                        } else {
                            cameraManager.stop()
                            liveService.stopVideoStreaming(from: cameraManager)
                        }
                    }
                }
                
                LiveItineraryPlayButton(isPaused: liveService.isPaused) {
                    withAnimation { liveService.togglePause() }
                }
                
                LiveItineraryMicButton(isMicrophoneMuted: liveService.isMicrophoneMuted) {
                    withAnimation { liveService.toggleMicrophone() }
                }
            }
            
            // Top Header Overlay (Status & Close Button)
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding()
                    }
                    
                    Spacer()
                    
                    if liveService.state == .connecting {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    } else if case .error(let errorMsg) = liveService.state {
                        Text("Error: \(errorMsg)")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                    } else if liveService.state == .connected {
                        HStack(spacing: 6) {
                            Image(systemName: liveService.isPaused ? "pause.circle.fill" : "sparkles")
                                .font(.subheadline)
                            Text(liveService.isPaused ? "Paused" : "Live")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.white)
                        .padding()
                    }
                    Spacer()
                    // Dummy space to center the status
                    Spacer().frame(width: 60)
                }
                Spacer()
            }
        }
        .onAppear {
            Task {
                await cameraManager.checkPermissions()
                if cameraManager.status == .unconfigured {
                    cameraManager.configureSession()
                }
                await liveService.connect()
            }
        }
        .onDisappear {
            isCameraOn = false
            cameraManager.stop()
            liveService.stopVideoStreaming(from: cameraManager)
            Task {
                await liveService.disconnect()
            }
        }
    }
    
    // MARK: - Animation Properties
    
    private var color1: Color {
        switch liveService.currentSpeaker {
        case .ai: return .blue.opacity(0.4)
        case .user: return .orange.opacity(0.4)
        case .idle: return .gray.opacity(0.2)
        }
    }
    
    private var color2: Color {
        switch liveService.currentSpeaker {
        case .ai: return .cyan.opacity(0.3)
        case .user: return .yellow.opacity(0.3)
        case .idle: return .gray.opacity(0.15)
        }
    }
    
    private var color3: Color {
        switch liveService.currentSpeaker {
        case .ai: return .purple.opacity(0.3)
        case .user: return .red.opacity(0.3)
        case .idle: return .black.opacity(0.5)
        }
    }

    private var backgroundScale: CGFloat {
        switch liveService.currentSpeaker {
        case .ai: return 1.15
        case .user: return 1.1
        case .idle: return 1.0
        }
    }
    
    private var backgroundAnimation: Animation {
        switch liveService.currentSpeaker {
        case .ai: return .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        case .user: return .easeInOut(duration: 0.3).repeatForever(autoreverses: true)
        case .idle: return .easeInOut(duration: 2.0)
        }
    }
}

// MARK: - Components

struct LiveItineraryCameraButton: View {
    @Binding var isCameraOn: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isCameraOn ? "video.fill" : "video.slash.fill")
                .font(.title2)
                .foregroundStyle(isCameraOn ? .black : .white)
                .frame(width: 64, height: 64)
                .background(Circle().fill(isCameraOn ? .white : Color(white: 0.25)))
        }
    }
}

struct LiveItineraryPlayButton: View {
    let isPaused: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.blue))
        }
    }
}

struct LiveItineraryMicButton: View {
    let isMicrophoneMuted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isMicrophoneMuted ? "mic.slash.fill" : "mic.fill")
                .font(.title2)
                .foregroundStyle(isMicrophoneMuted ? .white : .black)
                .frame(width: 64, height: 64)
                .background(Circle().fill(isMicrophoneMuted ? Color(white: 0.25) : .white))
        }
    }
}

struct LiveItineraryControlsBar<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 40) {
            content
        }
        .padding(.bottom, 32)
    }
}

struct LiveItineraryTranscriptView: View {
    let messages: [TranscriptMessage]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { msg in
                        HStack(alignment: .top, spacing: 4) {
                            if msg.isUser {
                                Text("You: ")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                            Text(msg.text)
                                .font(.body)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(msg.id)
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxHeight: 180)
            .mask(
                LinearGradient(
                    colors: [.clear, .black, .black, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.bottom, 120)
            .transition(.opacity)
            .onChange(of: messages) { oldValue, newValue in
                if let last = newValue.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }
}
