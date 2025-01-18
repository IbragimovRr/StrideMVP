//
//  AddCoursePresenter.swift
//  Courses
//
//  Created by Руслан on 11.01.2025.
//

import UIKit

protocol AddCoursePresenterDelegate {
    func deleteAlamofireFiles()
    func getData()
    func saveCourse(html: NSAttributedString?)
}

class AddCoursePresenter: AddCoursePresenterDelegate {
    var view: AddCoursePresenterViewDelegate!
    var module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func deleteAlamofireFiles() {
        FilePath().deleteAlamofireFiles()
    }
    
    func getData() {
            Task {
//                let attributedString = try await FilePath().downloadFileWithURL(url: module.text!)
//                DispatchQueue.main.async {
//                    self.view.setData(html: attributedString.htmlString()!)
//                    self.view.setData(attr: attributedString)
//                }
                
            }
        }
    
    func saveCourse(html: NSAttributedString?) {
        view.isLoading(true)
        Task {
            do {
                try await CourseServices().addModulesData(text: html!, moduleID: module.module.id)
                DispatchQueue.main.async {
                    self.view.isLoading(false)
                    self.view.saveCourse()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.setError(error)
                }
            }
        }
    }
    
}
