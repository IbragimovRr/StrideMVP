//
//  VideoModulePresenter.swift
//  Courses
//
//  Created by Руслан on 23.12.2024.
//

import UIKit

protocol AddVideoModuleDelegate {
    func getModule()
    func saveModule()
    func uploadVideo(videoURL: URL)
}

class AddVideoModulePresenter: AddVideoModuleDelegate {
    
    var view: AddVideoViewDelegate?
    var module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getModule() {
        module = VideoModule(module: Modules(name: "Видео модуль", minutes: 55, id: 0, isCompleted: false, position: 0), videoURL: nil, views: 550, timeVideo: 50, author: "Руслан Ибрагимов", videoDescription: "Качественное видео снятое в Москве")
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
        print(55)
    }
}
