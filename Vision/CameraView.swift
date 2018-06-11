//
//  CameraView.swift
//  Vision
//
//  Created by Manish Singh on 6/8/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView, FrameExtractorDelegate {
    var frameExtractor: FrameExtractor!
    var imageProcessor: ImageProcessor?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
    func start() {
        self.frameExtractor = FrameExtractor()
        self.frameExtractor.delegate = self
        if let previewLayer = previewLayer {
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.session = frameExtractor.captureSession
        }
    }
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func captured(image: UIImage) {
        imageProcessor?.feedLinker(image: image)
    }
}
