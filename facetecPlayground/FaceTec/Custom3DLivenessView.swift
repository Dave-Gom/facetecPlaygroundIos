//
//  Custom3DLivenessView.swift
//  facetecPlayground
//
//  Created by Dave Gomez on 2026-02-27.
//

import UIKit
import AVFoundation
import FaceTecSDK

class Custom3DLivenessView: UIView {

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
        // Create and launch the View Controller for a 3D Liveness Check

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCamera()
    }

    private func setupCamera() {

        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }

            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill

            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }

        } catch {
            print("Error initializing camera: \(error)")
        }
    }
    
    private func sendFrameToFacetec(sampleBuffer: CMSampleBuffer) {
        
    }

    deinit {
        session.stopRunning()
    }
}
