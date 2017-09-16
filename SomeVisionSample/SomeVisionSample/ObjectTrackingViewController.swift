//
//  ObjectTrackingViewController.swift
//  SomeVisionSample
//
//  Created by htomcat on 2017/09/12.
//  Copyright © 2017年 htomcat. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ObjectTrackingViewController: UIViewController {
    @IBOutlet private weak var cameraView: UIView?
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()
    private var lastObservation: VNDetectedObjectObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        // make the camera appear on the screen
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func userTapped(_ sender: UITapGestureRecognizer) {
        // get the center of the tap
        let size = CGSize(width: 100, height: 100)
        let center = sender.location(in: self.view)
        let division: CGFloat = 2
        let xPos = center.x - size.width / division
        let yPos = center.y - size.height / division
        let originalRect = CGRect(x: xPos, y: yPos, width: size.width, height: size.height)
        var convertedRect = self.cameraLayer.metadataOutputRectConverted(fromLayerRect: originalRect)
        convertedRect.origin.y = 1 - convertedRect.origin.y
        
        // set the observation
        let newObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
        self.lastObservation = newObservation
    }
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
        DispatchQueue.main.async {
            // make sure we have an actual result
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation else { return }
            
            // prepare for next loop
            self.lastObservation = newObservation
            
            // check the confidence level before updating the UI
            guard newObservation.confidence >= 0.3 else {
                // hide the rectangle when we lose accuracy so the user knows something is wrong
                return
            }
            
            // calculate view rect
            var transformedRect = newObservation.boundingBox
            transformedRect.origin.y = 1 - transformedRect.origin.y
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
            self.cameraView?.layer.sublayers?.removeSubrange(1...)
            let outline = CALayer()
            outline.frame = convertedRect
            outline.borderWidth = 2.0
            outline.borderColor = UIColor.red.cgColor
            self.cameraView?.layer.addSublayer(outline)
        }
    }
}
extension ObjectTrackingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // create the request for detect image
        if let lastObservation = self.lastObservation {
            // create the request
            let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: self.handleVisionRequestUpdate)
            request.trackingLevel = .accurate
            
            // perform the request
            do {
                try self.visionSequenceHandler.perform([request], on: pixelBuffer)
            } catch {
                print("Throws: \(error)")
            }
        }
    }
}

