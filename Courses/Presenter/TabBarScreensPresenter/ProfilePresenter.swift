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
    var selectCourseID = 0
    
    var user: UserModel = UserServices.info
    
    func viewWillApear() {
        getMyData()
    }
    
    func getMyData() {
        view?.showSceletonAnimated(bool: true)
        Task {
            user = try await UserServices().getMyInfo()
            courses = try await CourseServices().getMyCreateCourses()
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
