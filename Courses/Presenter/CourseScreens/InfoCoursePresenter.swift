//
//  InfoCoursePresenter.swift
//  Courses
//
//  Created by Руслан on 07.12.2024.
//

import UIKit

protocol InfoCoursePresenterDelegate {
    func viewDidLoad()
    func getCourses()
    func getComments()
    func getSimillarCourses()
    func buyCourse(_ vc: UIViewController, price: Int, promocode: PromocodeModel?)
    func sendCoursesVerification()
    func successVerification()
    func cancelVerfication()
    func usedPromocode(promo: String)
}

class InfoCoursePresenter: InfoCoursePresenterDelegate {

    var view: InfoCoursesViewDelegate?
    var course = CourseModel()
    var similarCourse = [CourseModel]()
    var reviews = [Reviews]()
    
    func viewDidLoad() {
        getCourses()
        getComments()
    }
    
    func getCourses() {
        view?.showSceletonLoading(bool: true)
        Task {
            course = try await CourseServices().getCoursesByID(id: course.id)
            DispatchQueue.main.async {
                self.view?.showSceletonLoading(bool: false)
                self.view?.showCourses()
            }
            getSimillarCourses()
        }
    }
    
    func getComments() {
        Task {
            reviews = try await CommentsServices().getComments(courseID: course.id)
            DispatchQueue.main.async {
                self.view?.showComments()
            }
        }
    }
    
    func getSimillarCourses() {
        Task {
            similarCourse = try await CourseServices().getAllCourses(categoryID: course.category.id)
            DispatchQueue.main.async {
                self.view?.showSimilarCourses()
            }
        }
    }
    
    func buyCourse(_ vc: UIViewController, price: Int, promocode: PromocodeModel?) {
        Task {
            let email = try await getEmail()
            PaymentServices().configure(vc, email: email, price: price) { result in
                switch result {
                case .succeeded(_):
                    self.buyCourseSuccesed(promocode: promocode)
                case .failed(_):
                    break
                case .cancelled(_):
                    break
                }
            }
        }
    }
    
    private func buyCourseSuccesed(promocode: PromocodeModel?) {
        Task {
            do {
                try await CourseServices().buyCourse(id: course.id, promocode: promocode)
                DispatchQueue.main.async {
                    self.view?.buyCoursesSuccessed()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                }
            }
        }
    }
    
    private func getEmail() async throws -> String {
        let email = try await UserServices().getMyInfo().email
        return email
    }
    
    func sendCoursesVerification() {
        Task {
            do {
                try await CourseServices().sendCoursesVerification(idCourse: course.id)
                DispatchQueue.main.async {
                    self.view?.showVerification()
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                }
            }
        }
    }
    
    func successVerification() {
        Task {
            do {
                try await Admin().successCourses(idCourses: course.id)
                DispatchQueue.main.async {
                    self.view?.verificationCourse(bool: true)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                }
            }
        }
    }
    
    func cancelVerfication() {
        Task {
            do {
                try await Admin().cancelCourses(idCourses: course.id)
                DispatchQueue.main.async {
                    self.view?.verificationCourse(bool: false)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                }
            }
        }
    }
    
    func usedPromocode(promo: String) {
        Task {
            do {
                let promo = try await PromocodesServices().usedPromocode(promo, courseID: course.id)
                DispatchQueue.main.async {
                    self.view?.promoSuccess(promo: promo)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.promoCancel()
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                    self.view?.promoCancel()
                }
            }
        }
    }
   
}
