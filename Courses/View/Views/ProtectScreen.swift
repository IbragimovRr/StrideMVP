//
//  ProtectScreen.swift
//  Courses
//
//  Created by Руслан on 20.11.2024.
//

import Foundation
import UIKit

public extension CALayer {
    func makeHiddenOnCapture() {
        let uiKitTextField = UITextField()
        let captureSecuredView: UIView? = uiKitTextField.subviews
                .first(where: { NSStringFromClass(type(of: $0)).contains("LayoutCanvasView") })
        
        let originalLayer = captureSecuredView?.layer
        captureSecuredView?.setValue(self, forKey: "layer")
        uiKitTextField.isSecureTextEntry = false
        uiKitTextField.isSecureTextEntry = true
        captureSecuredView?.setValue(originalLayer, forKey: "layer")
    }
}
