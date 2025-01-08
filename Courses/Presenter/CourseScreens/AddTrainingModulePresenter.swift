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
    func updateTypeTraining()
}

class AddTrainingModulePresenter: AddTrainingModulePresenterDelegate {
    var view: AddTrainingModuleViewDelegate!
    var module = TrainingModule(module: Modules(name: "", minutes: 0, id: 0))
    var trainingItem = TrainingItem() {
        didSet {
            updateTypeTraining()
        }
    }
    
    func getModule() {
//        var trainingItems = [TrainingItem]()
//        trainingItem.firstItemType = .weight
//        trainingItem.secondItemType = .repeats
//        trainingItems.append(trainingItem)
//        trainingItems.append(trainingItem)
//        module = TrainingModule(module: module.module, mediaURL: nil, description: "Качественное видео снятое в Москве", trainingItems: trainingItems)
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
    
    func updateTypeTraining() {
        guard module.trainingItems.isEmpty == false else { return }
        for x in 0...module.trainingItems.count - 1 {
            module.trainingItems[x].firstItemType = trainingItem.firstItemType
            module.trainingItems[x].secondItemType = trainingItem.secondItemType
        }
    }
}
