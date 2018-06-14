//
//  UIImage+Cropping.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/13/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    func crop(rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            let croppedUIImage = UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: imageOrientation)
            return croppedUIImage
        }
        return nil
    }
}
