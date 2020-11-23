//
//  CameraManager.swift
//  Benji
//
//  Created by Benji Dodgson on 10/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import AVFoundation
import Vision
import ReactiveSwift

class FaceDetectionViewController: UIViewController {
    var sequenceHandler = VNSequenceRequestHandler()

    @IBOutlet var faceView: FaceView!

    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var capturePhotoOutput: AVCapturePhotoOutput!

    let dataOutputQueue = DispatchQueue(label: "video data queue",
                                        qos: .userInitiated,
                                        attributes: [],
                                        autoreleaseFrequency: .workItem)
    private var videoOutput: AVCaptureVideoDataOutput?

    var hasDetectedFace = MutableProperty<Bool>(false)

    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0

    var didCapturePhoto: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.maxX = view.bounds.maxX
        self.midY = view.bounds.midY
        self.maxY = view.bounds.maxY
    }

    func begin() {
        self.configureCaptureSession()
        self.session.startRunning()
    }

    func stop() {
        self.session.stopRunning()
        if let output = self.videoOutput {
            self.session.removeOutput(output)
        }
        if let output = self.capturePhotoOutput {
            self.session.removeOutput(output)
        }
    }

    private func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
                                                    fatalError("No front video camera available")
        }

        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if self.session.inputs.isEmpty {
                self.session.addInput(cameraInput)
            }
        } catch {
            fatalError(error.localizedDescription)
        }

        // Create the video data output
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput!.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
        self.videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        // Add the video output to the capture session
        self.session.addOutput(self.videoOutput!)

        let videoConnection = self.videoOutput?.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        // Get an instance of ACCapturePhotoOutput class
        self.capturePhotoOutput = AVCapturePhotoOutput()
        self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        // Set the output on the capture session
        self.session.addOutput(self.capturePhotoOutput)

        // Configure the preview layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.view.bounds
    }

    func capturePhoto() {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}
