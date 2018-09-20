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
import ARKit

enum MLModelIdentifier {
    case dl2
    case resnet50
}
class ImageClassifier {
    typealias VisionMLCompletionHandler = (VisionObject) -> ()
    var isProcessing = false
    var dl2Request: VNCoreMLRequest?
//    var resnet50: VNCoreMLRequest?
    
    var completionHandler: VisionMLCompletionHandler?
    init() {
        do {
            let model = try VNCoreMLModel(for: Face().model)
            dl2Request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                if error == nil {
                    self?.processClassifications(for: request, for: .dl2)
                }
            })
            dl2Request?.imageCropAndScaleOption = .centerCrop
        } catch {
        }
//
//        do {
//            let model = try VNCoreMLModel(for: MobileNet().model)
//            resnet50 = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
//                if error == nil {
//                    self?.processClassifications(for: request, for: .resnet50)
//                }
//            })
//            resnet50?.imageCropAndScaleOption = .centerCrop
//        } catch {
//        }
    }
    
    func processClassifications(for request: VNRequest, for modelIdentifier: MLModelIdentifier) {
        defer {
            isProcessing = false
        }
        guard let results = request.results else {
            imageClassified(tag: nil, probablity: 0.0, modelIdentifier: modelIdentifier)
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        guard let classifications = results as? [VNClassificationObservation] else {
            imageClassified(tag: nil, probablity: 0.0, modelIdentifier: modelIdentifier)
            return
        }
        if classifications.isEmpty {
            imageClassified(tag: nil, probablity: 0.0, modelIdentifier: modelIdentifier)
        } else {
            let probableClassification = classifications.max(by: {(a, b) -> Bool in
                return a.confidence < b.confidence
            })
            if let resultClassification = probableClassification {
                imageClassified(tag: resultClassification.identifier, probablity: resultClassification.confidence, modelIdentifier: modelIdentifier)
            } else {
                imageClassified(tag: nil, probablity: 0.0, modelIdentifier: modelIdentifier)
            }
        }
    }
    
    func classifyImage(image: UIImage, completionHandler: VisionMLCompletionHandler?) {
        guard let dl2Request = dl2Request else {
                return
        }
        isProcessing = true
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        self.completionHandler = completionHandler
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            //                try handler.perform([dl2Request, resnet50])
            try handler.perform([dl2Request])
        } catch {
            /*
             This handler catches general image processing errors. The `classificationRequest`'s
             completion handler `processClassifications(_:error:)` catches errors specific
             to processing that request.
             */
            self.imageClassified(tag: nil, probablity: 0.0, modelIdentifier: .dl2)
        }
    }
    
}

extension ImageClassifier {
    func imageClassified(tag: String?, probablity: Float, modelIdentifier: MLModelIdentifier) {
        guard let tag = tag else {
            completionHandler?(VisionObject.failedToClassify)
            return
        }
        switch modelIdentifier {
        case .dl2:
            print("dl2: \(tag)")
        case .resnet50:
            print("resnet50: \(tag)")
        }
        completionHandler?(VisionObject(objectTag: tag, probability: probablity, lessProbableObjects: nil))
    }
}
