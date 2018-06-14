//
//  CameraView.swift
//  Vision
//
//  Created by Manish Singh on 6/8/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraDelegate: class {
    func outputImage(image: UIImage, guideRect: CGRect)
}

class CameraView: UIView, FrameExtractorDelegate {
    var frameExtractor: FrameExtractor!
    var imageProcessor: ImageProcessor?
    weak var delegate: CameraDelegate?
    
    var guideRect: CGRect {
        let aspectRatio: CGFloat = 1.5859
        let height = UIScreen.main.bounds.height * 0.65
        let width = height * aspectRatio
        let x = UIScreen.main.bounds.width / 2 - width / 2
        let y = UIScreen.main.bounds.height / 2 - 25 - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
    
    func start() {
        self.frameExtractor = FrameExtractor()
        self.frameExtractor.delegate = self
        if let previewLayer = previewLayer {
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.session = frameExtractor.captureSession
        }
        DispatchQueue.main.async {
            self.addGuideView()
        }
    }
    
    func addGuideView() {
        let guideView = CameraGuideView()
        guideView.frame = guideRect
        addSubview(guideView)
        bringSubviewToFront(guideView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        // Resize the debug layer if it exists
        guard let previewLayer = previewLayer, previewLayer.connection != nil else { return }
        // Make sure that the capture layer's orientation matches the phone's
        if layer is AVCaptureVideoPreviewLayer {
            previewLayer.connection?.videoOrientation = .landscapeRight
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func captured(image: UIImage) {
        imageProcessor?.feedLinker(image: image)
        delegate?.outputImage(image: image, guideRect: guideRect)
    }
}
