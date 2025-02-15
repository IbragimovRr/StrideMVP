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
        view.showLoading(isLoading: true)
        Task {
            do {
                print(44)
                try await CourseServices().changeTrainingModule(module: module)
                print(55)
                DispatchQueue.main.async {
                    self.view.showLoading(isLoading: false)
                    self.view.saveData()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.showError(error: error)
                    self.view.showLoading(isLoading: false)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view.showError(error: "Неизвестная ошибка. Попробуйте позже")
                    self.view.showLoading(isLoading: false)
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
