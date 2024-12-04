//
//  MyCoursesPresenter.swift
//  Courses
//
//  Created by Руслан on 04.12.2024.
//

import Alamofire
import SwiftyJSON

protocol MyCoursesPresenterDelegate {
    func getMyBoughtCourses()
    func viewWillApear()
}

class MyCoursesPresenter: MyCoursesPresenterDelegate {
    
    var view: MyCoursesViewDelegate?
    var course = [Course]()
    var filteredCourse = [Course]()
    var selectIDCourse = 0
    
    func getMyBoughtCourses() {
        view?.showLoading(bool: true)
        Task {
            course = try await Course().getBoughtCourses()
            filteredCourse = course
            await MainActor.run { [weak self] in
                self?.view?.showLoading(bool: false)
                self?.view?.showMyBoughtCourses()
            }
        }
    }
    
    func viewWillApear() {
        getMyBoughtCourses()
    }
    
}
