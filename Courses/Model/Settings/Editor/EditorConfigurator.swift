//
//  EditorConfigurator.swift
//  Courses
//
//  Created by Руслан on 11.01.2025.
//

import UIKit
import WebKit

class StyleChangedHandler: NSObject, WKScriptMessageHandler {
    weak var viewController: AddCourseViewController?

    init(viewController: AddCourseViewController) {
        self.viewController = viewController
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let styleInfo = message.body as? [String: Any],
              let font = styleInfo["font"] as? String,
              let fontSize = styleInfo["fontSize"] as? CGFloat,
              let color = styleInfo["color"] as? String,
              let textAlign = styleInfo["textAlign"] as? String else {
            print("Invalid message format")
            return
        }
        
        viewController?.updateStyles(font: font, fontSize: fontSize, color: color, textAlign: textAlign)
    }
}
