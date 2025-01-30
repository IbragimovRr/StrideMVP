//
//  PlanCoursesPresenter.swift
//  Courses
//
//  Created by Руслан on 24.01.2025.
//

import Foundation

protocol PlanCoursesPresenterDelegate {
    func getData()
    func savePlan()
}

class PlanCoursesPresenter: PlanCoursesPresenterDelegate {
    var view: PlanCoursesViewDelegate!
    var days = [DayModel]()
    var idCourse = 0
    
    func getData() {
        Task {
            days = try await CourseServices().getDaysInCourse(id: idCourse).courseDays
            DispatchQueue.main.async {
                self.view.setData()
            }
        }
    }
    
    func savePlan() {
        Task {
            do {
                try await CourseServices().addIsVisibleInModule(days: days)
                DispatchQueue.main.async {
                    self.view.savePlan()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.setError(error: error)
                }
            }
        }
    }
    
}
