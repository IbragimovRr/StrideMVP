//
//  HomePresenter.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import UIKit

protocol HomePresenterProtocol {
    var deepLink: Bool { get }
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
    var userModel = UserModel()
    
    
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
            userModel = try await userService.getMyInfo()
            let coachs = try await self.userService.getAllCoachs()
            let recomendCourses = try await Course().getRecomendedCourses()
            let celebrity = try await self.userService.getCelebreties()
            
            await MainActor.run { [weak self] in
                self?.view?.showCelebrity(celebrity: celebrity)
            }
            await MainActor.run { [weak self] in
                self?.view?.showUser(user: userModel)
            }
            await MainActor.run { [weak self] in
                self?.view?.showRecomendedCourses(courses: recomendCourses)
            }
            await MainActor.run { [weak self] in
                self?.view?.showCoachs(coachs: coachs)
            }
            await MainActor.run { [weak self] in
                self?.view?.disableLoading()
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
            userModel = try await userService.getMyInfo()
            await MainActor.run { [weak self] in
                self?.view?.showUser(user: userModel)
            }
        }
    }
    
    func getCelebrity() {
        Task {
            let celebrity = try await self.userService.getCelebreties()
            await MainActor.run { [weak self] in
                self?.view?.showCelebrity(celebrity: celebrity)
            }
        }
    }
    
    func getRecomendCourses() {
        Task {
            let recomendCourses = try await Course().getRecomendedCourses()
            await MainActor.run { [weak self] in
                self?.view?.showRecomendedCourses(courses: recomendCourses)
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
            await MainActor.run { [weak self] in
                self?.view?.showCoachs(coachs: coachs)
            }
        }
    }
    
}
