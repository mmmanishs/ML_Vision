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

        // need to also get the rect of the face so that it can be marked in the video frame
        videoStreamFrame.image.extractFace() { [weak self] faces in
            self?.shouldProcess = true
            guard let faces = faces,
                faces.count > 0 else {
                    return
            }
            // If faces are found then run ML algo on them
            let face = faces[0]
            
            self?.imageClassifier?.classifyImage(image: face) { mlResult in
                print(mlResult.identifier)
            }
        }
    }
}

