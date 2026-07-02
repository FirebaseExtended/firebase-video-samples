import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
typealias UIImage = NSImage
#endif
@preconcurrency import AVFoundation

@Observable
@MainActor
final class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    var status: Status = .unconfigured
    nonisolated(unsafe) let session = AVCaptureSession()
    var capturedImage: UIImage?
    
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated(unsafe) private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.friendlymeals.camera")
    
    @ObservationIgnored
    nonisolated(unsafe) private var isExtractingFrames = false
    @ObservationIgnored
    nonisolated(unsafe) private var lastExtractedFrame: UIImage?
    
    func checkPermissions() async {
        guard status == .unconfigured else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            self.status = granted ? .unconfigured : .unauthorized
        case .restricted, .denied:
            self.status = .unauthorized
        case .authorized:
            self.status = .unconfigured
        @unknown default:
            self.status = .unauthorized
        }
    }
    
    func configureSession() {
        guard status == .unconfigured else { return }
        
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .vga640x480
            
            if !self.setupVideoInput() {
                self.session.commitConfiguration()
                Task { @MainActor in
                    self.setStatus(.failed)
                }
                return
            }
            
            self.setupPhotoOutput()
            self.setupVideoDataOutput()
            
            self.session.commitConfiguration()
            Task { @MainActor in
                self.setStatus(.configured)
            }
        }
    }
    
    // MARK: - Setup Helpers
    
    nonisolated private func setupVideoInput() -> Bool {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              self.session.canAddInput(videoInput) else {
            return false
        }
        self.session.addInput(videoInput)
        return true
    }
    
    nonisolated private func setupPhotoOutput() {
        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
        }
    }
    
    nonisolated private func setupVideoDataOutput() {
        if self.session.canAddOutput(self.videoOutput) {
            self.session.addOutput(self.videoOutput)
        }
    }
    
    private func setStatus(_ newStatus: Status) {
        self.status = newStatus
    }
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Video Frame Extraction for Live API
    
    func startVideoDataOutput() {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            self.isExtractingFrames = true
        }
    }
    
    func stopVideoDataOutput() {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
            self.isExtractingFrames = false
        }
    }
    
    func getLatestVideoFrame() async -> UIImage? {
        return lastExtractedFrame
    }
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let image = extractImage(from: sampleBuffer) {
            Task { @MainActor in
                self.lastExtractedFrame = image
            }
        }
    }
    
    // MARK: - Image Conversion Helpers
    
    private nonisolated func extractImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: NSZeroSize)
        #else
        return UIImage(cgImage: cgImage)
        #endif
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        Task { @MainActor in
            self.capturedImage = image
        }
    }
}
