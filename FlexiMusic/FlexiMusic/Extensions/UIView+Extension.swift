//
//  UIView+Extension.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 03.08.2025.
//

import UIKit

extension UIView {
    
    func addSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addSubview(subview)
        }
    }
}
