//
//  ThemeModel.swift
//  Courses
//
//  Created by Руслан on 09.12.2024.
//

import UIKit

enum AppTheme: String {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

extension UIUserInterfaceStyle {
    
    var rawValue: String {
        switch self {
        case .unspecified:
            return "default"
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "default"
        }
    }
    
    func themeInsert(_ result: String) -> Self {
        switch result {
        case "light":
            return .light
        case "dark":
            return .dark
        case "default":
            return .unspecified
        default:
            return .unspecified
        }
    }
}
