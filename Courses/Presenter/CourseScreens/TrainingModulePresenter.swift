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
    func nextRepeat()
    func restartTraining()
}

class TrainingModulePresenter: TrainingModulePresenterDelegate {
    var view: TrainingModuleViewDelegate!
    var module = TrainingModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getData() {
        view?.showData()
        view.selectRepeats = 0
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
    
    func nextRepeat() {
        guard view.selectRepeats != module.trainingItems.count else { return }
        
        if view.repeats.count - 1 >= view.selectRepeats {
            view.repeats[view.selectRepeats] = module.trainingItems[view.selectRepeats]
        }else {
            view.repeats.append(module.trainingItems[view.selectRepeats])
        }
        
        if module.trainingItems.count - 2 == view.selectRepeats {
            view.endRepeats()
        }
    
        if module.trainingItems.count - 1 != view.selectRepeats {
            view.selectRepeats += 1
        }
    }
    
    func restartTraining() {
        view.selectRepeats = 0
    }
    
    func checkType(media: URL) {
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
