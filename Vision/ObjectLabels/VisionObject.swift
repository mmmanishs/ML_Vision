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
    case c1VentureCreditBack(Float, [VisionObject]?)
    case BofaDebitCardFront(Float, [VisionObject]?)
    case BofaDebitCardBack(Float, [VisionObject]?)
    case others(Float, [VisionObject]?)
    case failedToClassify
    case coreMLAPIFailure

    init(objectTag: String, probability: Float, lessProbableObjects: [VisionObject]?) {
        switch objectTag {
        case "VA_Front":
            self = .virginaFront(probability, lessProbableObjects)
        case "VA_Back":
            self = .virginaBack(probability, lessProbableObjects)
        case "TX_Front":
            self = .texasFront(probability, lessProbableObjects)
        case "TX_Back":
            self = .texasBack(probability, lessProbableObjects)
        case "C1VentureCCFront":
            self = .c1VentureCreditFront(probability, lessProbableObjects)
        case "C1VentureCCBack":
            self = .c1VentureCreditBack(probability, lessProbableObjects)
        case "BofaDebitCardFront":
            self = .BofaDebitCardFront(probability, lessProbableObjects)
        case "BofaDebitCardBack":
            self = .BofaDebitCardBack(probability, lessProbableObjects)
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
        case .c1VentureCreditBack: return "Capital One Venture Back"
        case .BofaDebitCardFront: return "BofA Debit Card Front"
        case .BofaDebitCardBack: return "BofA Debit Card Back"
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
