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
        view.isEnabledBtn(false)
        Task {
            do {
                try await CourseServices().addIsVisibleInModule(days: days)
                DispatchQueue.main.async {
                    self.view.savePlan()
                    self.view.isEnabledBtn(true)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view.setError(error: error)
                    self.view.isEnabledBtn(true)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view.setError(error: "Попробуйте позже")
                    self.view.isEnabledBtn(true)
                }
            }
        }
    }
    
}
