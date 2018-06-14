//
//  ImageCropper.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/13/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit

class ImageCropper {
    static func cropImage(image: UIImage, rect: CGRect) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        let croppedImage = ciImage.perspectiveCorrection(withrect: rect)
        return UIImage(ciImage: croppedImage)
    }
}
