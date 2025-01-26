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
        initTrainingItem()
        view?.showData()
        if let mediaURL = module.mediaURL {
            checkType(media: mediaURL)
        }else {
            view?.showUploadMedia()
        }
    }
    
    private func checkType(media: URL) {
        let type = MediaTypeManager().determineFileType(from: media)
        switch type {
        case .image:
            view.showImage()
        case .video:
            view.showVideo()
        case .none:
            view?.showUploadMedia()
        }
    }
    
    private func initTrainingItem() {
        guard module.trainingItems.isEmpty == false else {return}
        trainingItem = module.trainingItems[0]
        trainingItem.firstItemData = nil
        trainingItem.secondItemData = nil
    }
    
    func saveModule() {
        Task {
            do {
                try await CourseServices().changeTrainingModule(module: module)
                DispatchQueue.main.async {
                    self.view.saveData()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.showError(error: error)
                }
            }
        }
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
