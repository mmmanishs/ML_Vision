//
//  ViewController.swift
//  Vision
//
//  Created by Manish Singh on 6/7/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ImageProcessorResultDelegate {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    var frameExtractor: FrameExtractor!
    let imageProcessorType1 = ImageProcessorType1()
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.imageProcessor = imageProcessorType1
        cameraView.imageProcessor?.resultDelegate = self
        DispatchQueue.main.async {
            self.cameraView.start()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    func imageProcessorResult(imageProcessor: ImageProcessor, result: ImageProcessorResult) {
        DispatchQueue.main.async {
            self.infoLabel.text = result.info
        }
    }
}

