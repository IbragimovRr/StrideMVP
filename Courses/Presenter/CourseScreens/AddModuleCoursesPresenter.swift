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
    func addModule(position: Int, type: ModuleType) 
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
                course.courseDays.append(DayModel(dayID: id, type: .noneSee))
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
    
    func addModule(position: Int, type: ModuleType) {
        let dayID = course.courseDays[selectDay].dayID
        Task {
            do {
                var id = 0
                
                switch type {
                case .custom:
                    id = try await CourseServices().addModulesInCourse(dayID: dayID, position: position)
                    selectModule = CustomModule(module: Modules(name: "", minutes: 0, id: id))
                case .video:
                    id = try await CourseServices().addVideoModule(dayID: dayID, position: position)
                    selectModule = VideoModule(module: Modules(name: "", minutes: 0, id: id))
                case .training:
                    id = try await CourseServices().addTrainingModule(dayID: dayID, position: position)
                    selectModule = TrainingModule(module: Modules(name: "", minutes: 0, id: id))
                }
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
