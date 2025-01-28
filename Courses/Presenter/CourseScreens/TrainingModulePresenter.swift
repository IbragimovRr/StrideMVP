//
//  TrainingModulePresenter.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import Foundation

protocol TrainingModulePresenterDelegate {
    func getData()
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
