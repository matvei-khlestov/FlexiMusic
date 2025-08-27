//
//  UIApplication+extension.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 27.08.2025.
//

import UIKit

extension UIApplication {
    static var activeKeyWindow: UIWindow? {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: { $0.isKeyWindow })
    }
}


