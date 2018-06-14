//
//  CameraGuideView.swift
//  ML_Vision
//
//  Created by Manish Singh on 6/13/18.
//  Copyright © 2018 Manish Singh. All rights reserved.
//

import UIKit

class CameraGuideView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 13
        layer.borderWidth = 5
        layer.borderColor = UIColor.orange.cgColor
        backgroundColor = UIColor.clear
    }
}
