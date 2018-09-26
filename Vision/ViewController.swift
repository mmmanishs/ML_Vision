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
        guard shouldProcess,
            let previewLayer = cameraView.previewLayer else {
                return
        }

        frameCount += 1
        shouldProcess = false
        
        videoStreamFrame.image.extractFace() { faces in
            self.shouldProcess = true
            guard let faces = faces,
                faces.count > 0 else {
                    return
            }
            let face = faces[0]
            DispatchQueue.main.async {
                self.outputImageView.image = nil
                self.outputImageView.image = face
                print("face detected...")
            }


//            DispatchQueue.main.async {
//                let face = faces[0]
//                self.imageClassifier?.classifyImage(image: face) { visionObject in
//                    DispatchQueue.main.async {
//                        self.shouldProcess = true
//                    }
//                }
//
//            }
        }
    }
}

