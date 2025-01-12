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
    func resizeImage(image: UIImage, url: URL)
}

class AddCoursePresenter: AddCoursePresenterDelegate {
    var view: AddCoursePresenterViewDelegate!
    var module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func deleteAlamofireFiles() {
        FilePath().deleteAlamofireFiles()
    }
    
    func getData() {
        Task {
            
            let initialHTML = """
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Заголовки и абзацы</title>
                    <meta charset="utf-8">
                </head>
                <body>
                    <h1>Заголовок<br>первого уровня</h1>
                    <h2>Заголовок второго уровня</h2>
                    <h3>Заголовок третьего уровня</h3>
                    <h4>Заголовок четвертого уровня</h4>
                    <h5>Заголовок пятого уровня</h5>
                    <h6>Заголовок шестого уровня</h6>
                    <hr>
                    <p>Тест абзаца</p>
                </body>
                </html>
                """
            view.setData(html: initialHTML)
            
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
    
    func resizeImage(image: UIImage, url: URL) {
        let targetWidth = UIScreen.main.bounds.width - 30
        let aspectRatio = image.size.height / image.size.width
        let targetSize = CGSize(width: targetWidth, height: targetWidth * aspectRatio)
        view.setImage(targetSize, url: url)
    }
    
}
