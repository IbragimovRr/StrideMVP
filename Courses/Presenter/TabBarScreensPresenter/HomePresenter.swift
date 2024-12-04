//
//  HomePresenter.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import UIKit

protocol HomePresenterProtocol {
    var deepLink: Bool { get }
    var userModel: UserModel { get set }
    func viewDidLoad()
    func viewWillAppear()
    func getUser()
    func getCelebrity()
    func getRecomendCourses()
    func getBanners()
    func getAllCoachs()
    func navigateToLoading()
    func getData()
}

class HomePresenter: HomePresenterProtocol {
    
    var deepLink: Bool { DeepLinksManager.isLink }
    
    var delegate: HomePresenterProtocol?
    weak var view: HomeViewProtocol?
    var userService = UserServices()
    var courseServices = CourseServices()
    var userModel: UserModel = User.info {
        didSet {
            self.view?.showUser(user: userModel)
        }
    }
    
    
    func viewDidLoad() {
        navigateToLoading()
        getBanners()
    }
    
    func viewWillAppear() {
        getUser()
        getAllCoachs()
    }
    
    func getData() {
        getBanners()
        Task {
            let user = try await userService.getMyInfo()
            let coachs = try await self.userService.getAllCoachs()
            let recomendCourses = try await Course().getRecomendedCourses()
            let celebrity = try await self.userService.getCelebreties()
            
            DispatchQueue.main.async {
                self.userModel = user
                self.view?.showCelebrity(celebrity: celebrity)
                self.view?.showRecomendedCourses(courses: recomendCourses)
                self.view?.showCoachs(coachs: coachs)
                self.view?.disableLoading()
            }
        }
    }
    
    func navigateToLoading() {
        if !deepLink {
            view?.navigateToLoading()
        }else {
            getCelebrity()
            getRecomendCourses()
        }
    }
    
    func getUser() {
        Task {
            let user = try await userService.getMyInfo()
            DispatchQueue.main.async {
                self.userModel = user
            }
        }
    }
    
    func getCelebrity() {
        Task {
            let celebrity = try await self.userService.getCelebreties()
            DispatchQueue.main.async {
                self.view?.showCelebrity(celebrity: celebrity)
            }
        }
    }
    
    func getRecomendCourses() {
        Task {
            let recomendCourses = try await Course().getRecomendedCourses()
            DispatchQueue.main.async {
                self.view?.showRecomendedCourses(courses: recomendCourses)
            }
        }
    }
    
    func getBanners() {
        var banners = [String]()
        banners.append("first")
        banners.append("second")
        banners.append("third")
        banners.append("fourth")
        view?.showBanners(banners: banners)
    }
    
    func getAllCoachs() {
        Task {
            let coachs = try await self.userService.getAllCoachs()
            DispatchQueue.main.async {
                self.view?.showCoachs(coachs: coachs)
            }
        }
    }
    
}
