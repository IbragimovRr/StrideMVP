//
//  TrainingModulePresenter.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import Foundation

protocol TrainingModulePresenterDelegate {
    func getData()
    func saveTraining()
    func getTraining()
}

class TrainingModulePresenter: TrainingModulePresenterDelegate {
    var view: TrainingModuleViewDelegate!
    var module = TrainingModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getData() {
        view?.showData()
        if let mediaURL = module.mediaURL {
            checkType(media: mediaURL)
        }
    }
    
    func saveTraining() {
        LocalCloudServices().saveTrainingProgress(moduleId: module.module.id, items: module.trainingItems)
        getTraining()
    }
    
    func getTraining() {
        let trainingItems = LocalCloudServices().loadTrainingProgress(moduleId: module.module.id)
        view.showSavedTraining(trainingItems: trainingItems)
    }
    
    private func checkType(media: URL) {
        let type = MediaTypeManager().determineFileType(from: media)
        switch type {
        case .image:
            view.showImage()
        case .video:
            view.showVideo()
        case .none:
            break
        }
    }
    
    
}
