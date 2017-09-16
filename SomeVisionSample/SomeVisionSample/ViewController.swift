//
//  ViewController.swift
//  SomeVisionSample
//
//  Created by htomcat on 2017/09/11.
//  Copyright © 2017年 htomcat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var faceDetection: UIButton!
    @IBOutlet weak var imageAnalysis: UIButton!
    @IBOutlet weak var textDetection: UIButton!
    @IBOutlet weak var objectTracking: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageAnalysis.addTarget(self,
                                action: #selector(touchedImageAnalysis(_:)),
                                for: .touchUpInside)
        faceDetection.addTarget(self,
                                action: #selector(touchedFaceDetection(_:)),
                                for: .touchUpInside)
        textDetection.addTarget(self,
                                action: #selector(touchedTextDetection(_:)),
                                for: .touchUpInside)
        objectTracking.addTarget(self,
                                 action: #selector(touchedObjectTracking(_:)),
                                 for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc
    private func touchedImageAnalysis(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "ImageAnalysisViewController", bundle: nil).instantiateInitialViewController() else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
    @objc
    private func touchedFaceDetection(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "FaceDetectionViewController", bundle: nil).instantiateInitialViewController() else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc
    private func touchedTextDetection(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "TextDetectionViewController", bundle: nil).instantiateInitialViewController() else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc
    private func touchedObjectTracking(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "ObjectTrackingViewController", bundle: nil).instantiateInitialViewController() else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
}
