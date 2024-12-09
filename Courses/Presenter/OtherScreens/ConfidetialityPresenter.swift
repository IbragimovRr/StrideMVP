//
//  ConfidetialityPresenter.swift
//  Courses
//
//  Created by Руслан on 09.12.2024.
//

import UIKit

protocol ConfidetialityPresenterDelegate {
    var theme: UIUserInterfaceStyle { get set }
    func getTheme()
}

class ConfidetialityPresenter: ConfidetialityPresenterDelegate {
    
    var view: ConfidetialityViewDelegate?
    var theme: UIUserInterfaceStyle = .unspecified {
        didSet {
            saveTheme()
        }
    }
    
    func saveTheme() {
        UD().saveTheme(theme.rawValue)
        changeTheme()
        view?.showTheme()
    }
    
    func getTheme() {
        let themeRes = UD().getTheme()
        theme = theme.themeInsert(themeRes)
        changeTheme()
        view?.showTheme()
    }
    
    func changeTheme() {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = theme
        }
    }
}
