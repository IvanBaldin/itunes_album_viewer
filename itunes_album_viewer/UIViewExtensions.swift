//
//  UIViewExtensions.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 08.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

@IBDesignable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            self.layer.cornerRadius
        }
    }
}
