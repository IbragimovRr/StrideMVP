//
//  VideoModulePresenter.swift
//  Courses
//
//  Created by Руслан on 23.12.2024.
//

import UIKit

protocol AddVideoModuleDelegate {
    func checkUpload()
    func saveModule()
    func uploadVideo(videoURL: URL)
}

class AddVideoModulePresenter: AddVideoModuleDelegate {
    
    var view: AddVideoViewDelegate?
    var module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func checkUpload() {
        view?.showData()
        if module.videoURL != nil {
            view?.showVideo()
        }else {
            view?.showUploadVideo()
        }
    }
    
    func uploadVideo(videoURL: URL) {
        module.videoURL = videoURL
        view?.showVideo()
    }
    
    func saveModule() {
        Task {
            do {
                try await CourseServices().addVideoModulesData(module: module)
                DispatchQueue.main.async {
                    self.view?.saveData()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                print(error)
            }
        }
    }
    
    
}
