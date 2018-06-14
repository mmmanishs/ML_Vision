//
//  ImageProcessor.swift
//  Vision
//
//  Created by Manish Singh on 6/8/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit
import CoreML
import ImageIO
import Vision

protocol ImageProcessor: class {
    var resultDelegate: ImageProcessorResultDelegate?{get set}
    func feedLinker(image: UIImage)
}

protocol ImageProcessorResultDelegate: class {
    func imageProcessorResult(imageProcessor: ImageProcessor, result: ImageProcessorResult)
}

class ImageProcessorType1: ImageProcessor {
    weak var resultDelegate: ImageProcessorResultDelegate?
    var stillProcessing = false
    
    func feedLinker(image: UIImage) {
        // Here detect that the feed is stable
        // if stable then process model
        // Report result the with the detected stuff
        guard !stillProcessing else {
            return
        }
        stillProcessing = true
        updateClassifications(for: image)
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: DL2().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
                let result = ImageProcessorResult(info: "Engine flameout. Restart app.")
                self.resultDelegate?.imageProcessorResult(imageProcessor: self, result: result)
            }
        }
    }

    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.global().async {
            guard let results = request.results else {
                let result = ImageProcessorResult(info: "Failed to classify")
                self.resultDelegate?.imageProcessorResult(imageProcessor: self, result: result)
                self.stillProcessing = false
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                let result = ImageProcessorResult(info: "Nothing recognized")
                self.resultDelegate?.imageProcessorResult(imageProcessor: self, result: result)
            } else {
                let probableClassification = classifications.max(by: {(a, b) -> Bool in
                    return a.confidence < b.confidence
                })
                if let resultClassification = probableClassification {
                    let result = ImageProcessorResult(info: "\(resultClassification.identifier) (\(resultClassification.confidence))")
                    self.resultDelegate?.imageProcessorResult(imageProcessor: self, result: result)
                } else {
                    let result = ImageProcessorResult(info: "Cannot classify")
                    self.resultDelegate?.imageProcessorResult(imageProcessor: self, result: result)
                }

            }
            self.stillProcessing = false
        }
    }    
}

struct ImageProcessorResult {
    let info: String
}
