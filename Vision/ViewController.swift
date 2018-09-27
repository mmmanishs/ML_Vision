//
//  ViewController.swift
//  Vision
//
//  Created by Manish Singh on 6/7/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation
import FaceCropper

class ViewController: UIViewController, CameraDelegate {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var outputImageView: UIImageView!
    var imageClassifier: ImageClassifier?
    var frameExtractor: FrameExtractor!
    var frameCount = 0
    var shouldProcess = true
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoFeedDelegate = self
        DispatchQueue.main.async {
            self.cameraView.start(decoration: .rectView)
        }
        self.imageClassifier = ImageClassifier()
        //            self.classifierRunning()
    }
    
//    func classifierRunning() {
//        if let image = UIImage(named: "VA"){
//            imageClassifier?.classifyImage(image: image) {visionObject in
////                print(visionObject.toString())
//            }
//        }
//    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    func videoFrameFeed(videoStreamFrame: VideoStreamFrame, guideRect: CGRect, cameraView: CameraView) {
        frameCount += 1
        guard shouldProcess == true,
            frameCount % 15 == 0,
            let previewLayer = cameraView.previewLayer else {
                return
        }
        shouldProcess = false
        guard let croppedImage = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer) else {
            return
        }
        DispatchQueue.main.async {
            self.outputImageView.image = nil
            self.outputImageView.image = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer)
        }
        
        // Check for the presense of a face\
        
        croppedImage.extractFace() { faces in
            var modelToUse: MLModelIdentifier!
            var imageToRunMLOn: UIImage!
            if let faces = faces,
                faces.count > 0 {
                // The classify using the trained model
                modelToUse = .dl2
                imageToRunMLOn = croppedImage
            } else {
                // If we do not find any face then classify using a different ML model
                modelToUse = .resnet50
                imageToRunMLOn = videoStreamFrame.image
            }

            self.imageClassifier?.classifyImage(image: imageToRunMLOn, withModel: modelToUse) { visionObject, objectTag in
                DispatchQueue.main.async {
                    self.infoLabel.text = objectTag
                    switch visionObject {
                    case .virginaFront(let p, let _):
                        if p > 0.85 {
                            cameraView.update(forState: .detectedVirginia)
                        } else {
                            cameraView.update(forState: .scanning)
                        }
                    default:
                        cameraView.update(forState: .scanning)
                        self.confidenceLabel.text = "---"
                    }
                    self.shouldProcess = true
                }
            }
        }
    }
}

