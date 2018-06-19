//
//  ViewController.swift
//  Vision
//
//  Created by Manish Singh on 6/7/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, CameraDelegate {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var outputImageView: UIImageView!
    var imageClassifier: ImageClassifier?
    var frameExtractor: FrameExtractor!
    var frameCount = 0
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
                print(visionObject.toString())
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
        guard let previewLayer = cameraView.previewLayer else {
            return
        }
        frameCount += 1
        guard let croppedImage = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer) else {
            return
        }
        DispatchQueue.main.async {
            self.outputImageView.image = videoStreamFrame.image.crop(rect: guideRect, previewLayer: previewLayer)
        }
        if true {
            if imageClassifier?.isProcessing == true {
                //skip this
            } else {
                imageClassifier?.classifyImage(image: croppedImage) { visionObject in
                    DispatchQueue.main.async {
                        self.infoLabel.text = visionObject.toString()
                        
                        switch visionObject {
                        case .virginaFront(let p, let _),
                             .virginaBack(let p, let _):
                            self.confidenceLabel.text = "\(p * 100)%"
                            if p > 0.97 {
                                cameraView.update(forState: .detectedVirginia)
                            } else {
                                cameraView.update(forState: .scanning)
                            }
                        case .BofaDebitCardFront(let p, let _),
                             .BofaDebitCardBack(let p, let _):
                            self.confidenceLabel.text = "\(p * 100)%"
                            if p > 0.97 {
                                cameraView.update(forState: .detectedBofaDebitCard)
                            } else {
                                cameraView.update(forState: .scanning)
                            }
                        default:
                            cameraView.update(forState: .scanning)
                            self.confidenceLabel.text = "---"
                        }
                    }
                }
            }
        }
    }
}

