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
        view?.showLoading(isLoading: true)
        Task {
            do {
                try await CourseServices().addVideoModulesData(module: module) { progress in
                    self.view?.showProgress(progress: "\(progress)")
                }
                DispatchQueue.main.async {
                    self.view?.saveData()
                    self.view?.showLoading(isLoading: false)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.showLoading(isLoading: false)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Повторите попытку позже.")
                    self.view?.showLoading(isLoading: false)
                }
            }
        }
    }
    
    
}
