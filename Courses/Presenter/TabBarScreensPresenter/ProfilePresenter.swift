//
//  ProfilePresenter.swift
//  Courses
//
//  Created by Руслан on 04.12.2024.
//

import Foundation

protocol ProfilePresenterDelegate {
    var user: UserModel { get set }
    func getMyInfo()
    func getMyCourses()
    func viewWillApear()
}

class ProfilePresenter: ProfilePresenterDelegate {
    
    weak var view: ProfileViewDelegate?
    var courses = [Course]()
    var selectCourseID = 0
    
    var user: UserModel = User.info {
        didSet {
            view?.showSceletonAnimated(bool: false)
            view?.showUser()
        }
    }
    
    func viewWillApear() {
        view?.showSceletonAnimated(bool: true)
        getMyInfo()
        getMyCourses()
    }
    
    func getMyInfo() {
        Task {
            let result = try await User().getMyInfo()
            await MainActor.run { [weak self] in
                self?.user = result
                self?.view?.showUser()
            }
        }
    }
    
    func getMyCourses() {
        Task {
            courses = try await Course().getMyCreateCourses()
            await MainActor.run { [weak self] in
                self?.view?.showMyCourses()
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
