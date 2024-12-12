//
//  ProfilePresenter.swift
//  Courses
//
//  Created by Руслан on 04.12.2024.
//

import Foundation

protocol ProfilePresenterDelegate {
    func getMyData()
    func viewWillApear()
}

class ProfilePresenter: ProfilePresenterDelegate {
    
    weak var view: ProfileViewDelegate?
    var courses = [CourseModel]()
    var selectCourse = CourseModel()
    var isMyProfile = true
    var user: UserModel = UserServices.info
    var isLoadData = false
    
    func viewWillApear() {
        getMyData()
    }
    
    func getMyData() {
        Task {
            if isMyProfile {
                DispatchQueue.main.async {
                    if self.isLoadData == false {
                        self.view?.showSceletonAnimated(bool: true)
                    }
                }
                user = try await UserServices().getMyInfo()
                courses = try await CourseServices().getMyCreateCourses()
                isLoadData = true
            }else {
                DispatchQueue.main.async {
                    self.view?.showSceletonAnimated(bool: true)
                }
                user = try await UserServices().getUserByID(id: user.id)
                courses = try await CourseServices().getCoursesByUserID(id: user.id)
            }
            DispatchQueue.main.async {
                self.view?.showSceletonAnimated(bool: false)
                self.view?.showUser()
                self.view?.showMyCourses()
            }
        }
    }
    
    func averageRating() -> Float {
        var ratingSumm: Float = 0.0
        var count = 0
        for course in courses {
            if course.rating != 0.0 {
                ratingSumm += course.rating
                count += 1
            }
        }
    
        let average = Float(ratingSumm) / Float(count)
        if average.isNaN {
            return 0.0
        }else {
            return CommentsServices().roundRating(rating: average)
        }
    }
    
}
