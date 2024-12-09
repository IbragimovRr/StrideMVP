//
//  ProtectScreen.swift
//  Courses
//
//  Created by Руслан on 20.11.2024.
//

import Foundation
import UIKit
import ScreenProtectorKit

//class ProtectScreen {
//    
//    static var currentVc: UIViewController = StartViewController()
//    static var isRecording = UIScreen.main.isCaptured
//    static var window: UIWindow?
//    private lazy var screenProtectorKit = { return ScreenProtectorKit(window: ProtectScreen.window) }()
//    
//    func enabled() {
//        if ProtectScreen.isRecording {
//            self.screenProtectorKit.enabledBlurScreen()
//        }
//    }
//    
//    func disabled() {
//        self.screenProtectorKit.disableBlurScreen()
//    }
//    
//    func protectOn() {
//        screenProtectorKit.configurePreventionScreenshot()
//        screenProtectorKit.screenshotObserver {
//            self.screenProtectorKit.enabledBlurScreen()
//        }
//        screenProtectorKit.screenRecordObserver { isRecording in
//            ProtectScreen.isRecording = isRecording
//            if isRecording && (ProtectScreen.currentVc is ModulesCourseViewController || ProtectScreen.currentVc is CourseTextViewController) {
//                self.screenProtectorKit.enabledBlurScreen()
//            }else {
//                self.screenProtectorKit.disableBlurScreen()
//            }
//        }
//    }
//    
//    func protectOff() {
//        screenProtectorKit.removeAllObserver()
//    }
//
//}

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
