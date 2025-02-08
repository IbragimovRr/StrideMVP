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
    func getData(isLoading: Bool)
}

class HomePresenter: HomePresenterProtocol {
    
    var deepLink: Bool { DeepLinksManager.isLink }
    
    var delegate: HomePresenterProtocol?
    weak var view: HomeViewProtocol?
    var userService = UserServices()
    var courseServices = CourseServices()
    var userModel: UserModel = UserServices.info {
        didSet {
            self.view?.showUser(user: userModel)
        }
    }
    
    
    func viewDidLoad() {
        navigateToLoading()
        getBanners()
    }
    
    func viewWillAppear() {
        checkVersion()
        getUser()
        getAllCoachs()
        if deepLink, let courseID = DeepLinksManager.courseID {
            view?.navigateToInfoCourses(idCourses: courseID)
        }
    }
    
    func getData(isLoading: Bool) {
        getBanners()
        Task {
            async let user = try? await userService.getMyInfo()
            async let coachs = try? await self.userService.getAllCoachs()
            async let recomendCourses = try? await CourseServices().getRecomendedCourses()
            async let celebrity = try? await self.userService.getCelebreties()
            
            let userResult = await user
            let coachsResult = await coachs
            let recomendCoursesResult = await recomendCourses
            let celebrityResult = await celebrity
            
            DispatchQueue.main.async {
                if let user = userResult {
                    self.userModel = user
                }
                if let celebrity = celebrityResult {
                    self.view?.showCelebrity(celebrity: celebrity)
                }
                if let recomendCourses = recomendCoursesResult {
                    self.view?.showRecomendedCourses(courses: recomendCourses)
                }
                if let coachs = coachsResult {
                    self.view?.showCoachs(coachs: coachs)
                }
                if isLoading {
                    self.view?.disableLoading()
                }else {
                    self.view?.update()
                }
            }
        }
    }
    
    private func checkVersion() {
        Task {
            let maxVersion = try await AppStoreVersion().getVersion()
            let isLastVersion = AppStoreVersion().isVersion(lessThan: maxVersion)
            if isLastVersion {
                DispatchQueue.main.async {
                    self.view?.disableLoading()
                    self.view?.importantUpdate()
                }
                return
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
            let recomendCourses = try await CourseServices().getRecomendedCourses()
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
