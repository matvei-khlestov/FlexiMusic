//
//  UIStackView+extension.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 16.08.2025.
//

import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { self.addArrangedSubview($0) }
    }
}
