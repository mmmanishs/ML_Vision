//
//  ImageClassifier.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/15/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ImageClassifier {
    typealias VisionMLCompletionHandler = (VisionObject) -> ()
    var isProcessing = false
    var request1: VNCoreMLRequest?
    var completionHandler: VisionMLCompletionHandler?
    init() {
        do {
            let model = try VNCoreMLModel(for: DL2().model)
            request1 = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                if error == nil {
                    self?.processClassifications(for: request)
                }
            })
            request1?.imageCropAndScaleOption = .centerCrop
        } catch {
        }
    }
    
    func processClassifications(for request: VNRequest) {
        defer {
            isProcessing = false
        }
        guard let results = request.results else {
            completionHandler?(.failedToClassify)
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        guard let classifications = results as? [VNClassificationObservation] else {
            completionHandler?(.coreMLAPIFailure)
            return
        }
        if classifications.isEmpty {
            completionHandler?(.failedToClassify)
        } else {
            let probableClassification = classifications.max(by: {(a, b) -> Bool in
                return a.confidence < b.confidence
            })
            if let resultClassification = probableClassification {
                completionHandler?(VisionObject(objectTag: resultClassification.identifier, probability: resultClassification.confidence, lessProbableObjects: VisionObject.getVisionObjects(from: classifications)))
            } else {
                completionHandler?(VisionObject.failedToClassify)
            }
        }
    }
    
    func classifyImage(image: UIImage, completionHandler: VisionMLCompletionHandler?) {
        guard let request1 = request1 else {
            return
        }
        isProcessing = true
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.completionHandler = completionHandler
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([request1])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                completionHandler?(VisionObject.coreMLAPIFailure)
            }
        }
    }
}
