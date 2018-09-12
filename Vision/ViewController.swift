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
    
    func classifierRunning() {
        if let image = UIImage(named: "VA"){
            imageClassifier?.classifyImage(image: image) {visionObject in
//                print(visionObject.toString())
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    func videoFrameFeed(videoStreamFrame: VideoStreamFrame, guideRect: CGRect, cameraView: CameraView) {
        guard shouldProcess == true,
            let previewLayer = cameraView.previewLayer else {
                return
        }
        frameCount += 1
        shouldProcess = false
        guard let croppedImage = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer) else {
            return
        }
        DispatchQueue.main.async {
            self.outputImageView.image = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer)
        }
        imageClassifier?.classifyImage(image: croppedImage) { visionObject in
            DispatchQueue.main.async {
                self.infoLabel.text = "Scanning"
                switch visionObject {
                case .virginaFront(let p, let _):
                    let image = croppedImage
                    image.face.crop { result in
                        switch result {
                        case .success(let faces):
                            if p > 0.85 {
                                cameraView.update(forState: .detectedVirginia)
                            } else {
                                cameraView.update(forState: .scanning)
                            }
                        self.infoLabel.text = visionObject.toString()
                        case .notFound: break
                        // When the image doesn't contain any face, `result` will be `.notFound`.
                        case .failure(let error): break
                            // When the any error occured, `result` will be `failure`.
                        }
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

