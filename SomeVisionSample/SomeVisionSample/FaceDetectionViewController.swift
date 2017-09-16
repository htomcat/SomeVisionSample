//
//  FaceDetectionViewController.swift
//  SomeVisionSample
//
//  Created by htomcat on 2017/09/12.
//  Copyright © 2017年 htomcat. All rights reserved.
//

import UIKit
import Vision

class FaceDetectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    var inputImage: CIImage!
    lazy var rectanglesRequest: VNDetectFaceLandmarksRequest = {
        return VNDetectFaceLandmarksRequest(completionHandler: self.handleRectangles)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        selectImageButton.addTarget(self,
                                    action: #selector(touchedSelectImage(_:)),
                                    for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc
    private func touchedSelectImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(uiImage.imageOrientation.rawValue)) else {
            return
        }
        inputImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))

        // Show the image in the UI.
        imageView.image = uiImage
        
        // Run the rectangle detector, which upon completion runs the ML classifier.
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.rectanglesRequest])
            } catch {
                print(error)
            }
        }
    }
    func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation]
            else { fatalError("unexpected result type from VNDetectRectanglesRequest") }
        for faceObservation in observations {
            let boundingBox = faceObservation.boundingBox
            let size = CGSize(width: boundingBox.width * imageView.bounds.width,
                              height: boundingBox.height * imageView.bounds.height)
            let origin = CGPoint(x: boundingBox.minX * imageView.bounds.width,
                                 y: (1 - faceObservation.boundingBox.minY) * imageView.bounds.height - size.height)
            let outline = CALayer()
            outline.frame = CGRect(origin: origin, size: size)
            outline.borderWidth = 2.0
            outline.borderColor = UIColor.red.cgColor
            DispatchQueue.main.async {
                self.imageView.layer.addSublayer(outline)
            }
        }

    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
