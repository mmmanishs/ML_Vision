//
//  VisionObject.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/15/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import Foundation
import Vision

enum VisionObject {
    case virginaFront(Float, [VisionObject]?)
    case virginaBack(Float, [VisionObject]?)
    case texasFront(Float, [VisionObject]?)
    case texasBack(Float, [VisionObject]?)
    case c1VentureCreditFront(Float, [VisionObject]?)
    case c1_360(Float, [VisionObject]?)
    case capitalOneCard(Float, [VisionObject]?)
    case USD(Float, [VisionObject]?)
    case others(Float, [VisionObject]?)
    case failedToClassify
    case coreMLAPIFailure

    init(objectTag: String, probability: Float, lessProbableObjects: [VisionObject]?) {
//        print("objectTag: \(objectTag)(\(probability)")
        switch objectTag {
        case "va_front":
            self = .virginaFront(probability, lessProbableObjects)
        case "va_back":
            self = .virginaBack(probability, lessProbableObjects)
        case "tx_front":
            self = .texasFront(probability, lessProbableObjects)
        case "tx_back":
            self = .texasBack(probability, lessProbableObjects)
        case "C1VentureCCFront":
            self = .c1VentureCreditFront(probability, lessProbableObjects)
        case "c1_360":
            self = .c1_360(probability, lessProbableObjects)
        case "capital_one_card":
            self = .capitalOneCard(probability, lessProbableObjects)
        case "usd":
            self = .USD(probability, lessProbableObjects)
        default:
            self = .others(probability, lessProbableObjects)
        }
    }
}

extension VisionObject {
    func toString() -> String {
        switch self {
        case .virginaFront: return "Virgina License Front"
        case .virginaBack: return "Virgina License Back"
        case .texasFront: return "Texas License Front"
        case .texasBack: return "Texas License Back"
        case .c1VentureCreditFront: return "Capital One Venture Front"
        case .c1_360: return "Capital One 360"
        case .USD: return "Currency"
        case .capitalOneCard: return "Capital One Card"
        case .failedToClassify: return "Failed to classify image"
        case .coreMLAPIFailure: return "Core ML API failure"
        case .others: return "Others"
        }
    }
}

extension VisionObject {
    static func getVisionObjects(from classifications: [VNClassificationObservation]) -> [VisionObject] {
        return classifications.map { classification in
            return VisionObject(objectTag: classification.identifier, probability: classification.confidence, lessProbableObjects: nil)
        }
    }
}
