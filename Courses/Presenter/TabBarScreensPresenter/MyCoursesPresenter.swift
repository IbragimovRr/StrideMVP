//
//  MyCoursesPresenter.swift
//  Courses
//
//  Created by Руслан on 04.12.2024.
//

import Foundation

protocol MyCoursesPresenterDelegate {
    func getMyBoughtCourses()
    func viewWillApear()
}

class MyCoursesPresenter: MyCoursesPresenterDelegate {
    
    var view: MyCoursesViewDelegate?
    var course = [CourseModel]()
    var filteredCourse = [CourseModel]()
    var selectIDCourse = 0
    
    func getMyBoughtCourses() {
        view?.showLoading(bool: true)
        Task {
            course = try await CourseServices().getBoughtCourses()
            filteredCourse = course
            DispatchQueue.main.async {
                self.view?.showLoading(bool: false)
                self.view?.showMyBoughtCourses()
            }
        }
    }
    
    func viewWillApear() {
        getMyBoughtCourses()
    }
    
    func procent(indexPath: IndexPath) -> Double {
        let completed = filteredCourse[indexPath.row].progressInDays
        let countAll = filteredCourse[indexPath.row].daysCount
        guard countAll > 0 else { return 100.0 }
        let progress = Double(completed) / Double(countAll)
        return progress * 100
    }
}
