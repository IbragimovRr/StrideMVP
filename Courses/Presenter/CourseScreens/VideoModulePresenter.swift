//
//  VideoModulePresenter.swift
//  Courses
//
//  Created by Руслан on 23.12.2024.
//

import UIKit

protocol VideoModulePresenterDelegate {
    func getModule()
    func nextModule()
}

class VideoModulePresenter: VideoModulePresenterDelegate {
    
    var view: VideoModuleViewDelegate?
    var module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getModule() {
        view?.showData()
    }
    
    func nextModule() {
        print(22)
    }
}
