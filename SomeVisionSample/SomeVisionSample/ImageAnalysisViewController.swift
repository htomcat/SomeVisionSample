//
//  ImageAnalysisViewController.swift
//  SomeVisionSample
//
//  Created by htomcat on 2017/09/11.
//  Copyright © 2017年 htomcat. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML
import ImageIO

class ImageAnalysisViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation] else { return }
        guard let observation = observations.first else { return }
        DispatchQueue.main.async {
            self.label1.text = "Identifier: \(observation.identifier)"
            self.label2.text = "confidence: \(observation.confidence)"
        }
    }
}

extension ImageAnalysisViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            return
        }
        let request = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}
