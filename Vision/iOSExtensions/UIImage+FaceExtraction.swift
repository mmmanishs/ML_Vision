//
//  FaceCropper.swift
//  ExtractFaces
//
//  Created by Manish Singh on 9/13/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import Foundation
import Vision
import UIKit

extension UIImage {
    func extractFace(completion: @escaping ([UIImage]?) -> ()) {
        guard let cgImage = cgImage else {
            completion(nil)
            return
        }
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest() { request, error in
            guard let observations = request.results as? [VNFaceObservation] else {
                fatalError("unexpected result type!")
            }
            var faceImages = [UIImage]()
            for face in observations {
                let normalizedBox = self.normalizeRect(rect: face.boundingBox)
                if let faceImage = self.crop(rect: normalizedBox) {
                    faceImages.append(faceImage)
                }
            }
            completion(faceImages)
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(.downMirrored), options: [:])
        try? requestHandler.perform([faceLandmarksRequest])
    }
}

extension UIImage {
    func normalizeRect(rect: CGRect) -> CGRect {
        var toRect = CGRect()
        toRect.size.width = rect.size.width * size.width
        toRect.size.height = rect.size.height * size.height
        toRect.origin.y =  (size.height) - (size.height * rect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  rect.origin.x * size.width
        return toRect
    }
    
    func crop(rect: CGRect) -> UIImage? {
        let ciimage = CIImage(image: self)
        guard let croppedImage = ciimage?.cropped(to: rect) else {
            return nil
        }
        let context = CIContext.init(options: nil)
        let cgImage = context.createCGImage(croppedImage, from: croppedImage.extent)!
        let image = UIImage.init(cgImage: cgImage)
        return image
    }
}
