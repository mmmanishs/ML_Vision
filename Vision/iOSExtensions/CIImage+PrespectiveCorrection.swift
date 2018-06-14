//
//  CIImage+PrespectiveCorrection.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/13/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit

extension CIImage {
    func perspectiveCorrection(withrect rect: CGRect) -> CIImage {
        let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y)
        let topRight = CGPoint(x: rect.origin.x, y: (rect.origin.x + rect.size.width))
        let bottomLeft = CGPoint(x: rect.origin.x, y: (rect.origin.y + rect.size.height))
        let bottomRight = CGPoint(x: (rect.origin.x + rect.size.width), y: (rect.origin.y + rect.size.height))
        return applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft":    CIVector(cgPoint: topLeft),
            "inputTopRight":   CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight":CIVector(cgPoint: bottomRight)])
    }
}
