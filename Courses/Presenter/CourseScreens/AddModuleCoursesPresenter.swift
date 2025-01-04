//
//  AddModuleCoursesPresenter.swift
//  Courses
//
//  Created by Руслан on 25.12.2024.
//

import UIKit


protocol AddModuleCoursesPresenterDelegate {
    func addCourseInfo()
    func addDay()
    func addModule(dayID: Int, position: Int) 
    func deleteDay(dayID: Int)
    func changePositionModule(module: Modules)
}

class AddModuleCoursesPresenter: AddModuleCoursesPresenterDelegate {
    var view: AddModuleCoursesViewDelegate?
    var course = CourseModel()
    var selectDay: Int = 0
    var selectModule: ModuleProtocol?
    var idCourse = 0
    
    func addCourseInfo() {
        Task {
            do {
                course = try await CourseServices().getDaysInCourse(id: idCourse)
                DispatchQueue.main.async {
                    self.view?.loading(bool: false)
                    self.view?.showCourseInfo()
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.loading(bool: false)
                }
            }
        }
    }
    
    func addDay() {
        Task {
            do {
                let id = try await CourseServices().addDaysInCourse(courseID: idCourse)
                course.courseDays.append(CourseDays(dayID: id, type: .noneSee))
                DispatchQueue.main.async {
                    self.view?.showDay()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                }
            }
        }
    }
    
    func addModule(dayID: Int, position: Int) {
        Task {
            do {
                let id = try await CourseServices().addModulesInCourse(dayID: dayID, position: position)
                course.courseDays[selectDay].modules.append(selectModule!)
                DispatchQueue.main.async {
                    self.view?.showModule(position: position)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                }
            }
        }
    }
    
    func deleteDay(dayID: Int) {
        Task {
            do {
                try await CourseServices().deleteDay(dayID: dayID)
                DispatchQueue.main.async {
                    self.view?.deleteDay(dayID: dayID)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                }
            }
        }
    }

    
    func changePositionModule(module: Modules) {
        Task {
            try await CourseServices().changePositionModule(info: module)
        }
    }
}
