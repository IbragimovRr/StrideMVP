//
//  AddTrainingModulePresenter.swift
//  Courses
//
//  Created by Руслан on 03.01.2025.
//

import Foundation

protocol AddTrainingModulePresenterDelegate {
    func getModule()
    func saveModule()
    func uploadMedia(media: URL, isVideo: Bool)
}

class AddTrainingModulePresenter: AddTrainingModulePresenterDelegate {
    var view: AddTrainingModuleViewDelegate!
    var module = TrainingModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getModule() {
        var trainingItems = [TrainingItem]()
        module = TrainingModule(module: module.module, mediaURL: nil, description: "Качественное видео снятое в Москве", trainingItems: trainingItems)
        view?.showData()
        if module.mediaURL != nil {
            view?.showVideo()
        }else {
            view?.showUploadMedia()
        }
    }
    
    func saveModule() {
        print(55)
    }
    
    func uploadMedia(media: URL, isVideo: Bool) {
        module.mediaURL = media
        if isVideo {
            view?.showVideo()
        }else {
            view.showImage()
        }
    }
}
