//
//  AddCoursePresenter.swift
//  Courses
//
//  Created by Руслан on 11.01.2025.
//

import UIKit

protocol AddCoursePresenterDelegate {
    func deleteAlamofireFiles()
    func viewDidLoad()
    func saveCourse(html: String)
    func saveImageInCloud(filePath: URL)
}

class AddCoursePresenter: AddCoursePresenterDelegate {
    
    var view: AddCoursePresenterViewDelegate!
    var module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func deleteAlamofireFiles() {
        FilePath().deleteAlamofireFiles()
    }
    
    func viewDidLoad() {
        getData()
    }
    
    private func getData() {
        guard let urlHtml = module.text else { return }
        Task {
            do {
                let html = try await FilePath().downloadHtmlFileWithURL(url: urlHtml)
                DispatchQueue.main.async {
                    if let html = html {
                        self.view.setData(html: html)
                    }
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.setError(error)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view.setError("Неизвестная ошибка. Попробуйте позже")
                }
            }
        }
    }
    

    
    func saveImageInCloud(filePath: URL)  {
        view.isLoading(true)
        Task {
            let url = try await CloudServices().uploadFileToS3(fileURL: filePath)
            DispatchQueue.main.async {
                self.view.setImage(url: url)
                self.view.isLoading(false)
            }
        }
    }
    
    func saveCourse(html: String) {
        view.isLoading(true)
        Task {
            do {
                try await CourseServices().addModulesData(text: html, moduleID: module.module.id)
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
