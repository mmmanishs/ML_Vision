//
//  ViewController.swift
//  Vision
//
//  Created by Manish Singh on 6/7/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ImageProcessorResultDelegate, CameraDelegate {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var outputImageView: UIImageView!
    var frameExtractor: FrameExtractor!
    let imageProcessorType1 = ImageProcessorType1()
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.imageProcessor = imageProcessorType1
        cameraView.imageProcessor?.resultDelegate = self
        cameraView.delegate = self
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
    
    func outputImage(image: UIImage, guideRect: CGRect) {
        outputImageView.image = cropToPreviewLayer(originalImage: image, rect: guideRect)

    }

    func cropToPreviewLayer(originalImage: UIImage, rect: CGRect) -> UIImage {
        let outputRect = cameraView.previewLayer!.metadataOutputRectConverted(fromLayerRect: rect)
        var cgImage = originalImage.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
}

