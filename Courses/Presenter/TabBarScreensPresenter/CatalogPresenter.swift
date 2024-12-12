//
//  CatalogPresenter.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import Foundation

protocol CatalogPresenterProtocol {
    func getCourses()
    func getNextPage(page: String)
    func getCategories()
    func getCoursesByCategory(id: Int) 
    func searchCourse(text: String)
    func viewDidLoad()
    func getSelectCategory(indexPath: IndexPath, search: String)
}


class CatalogPresenter: CatalogPresenterProtocol {
    
    weak var view: CatalogViewDelegate?
    
    var categories = [CategoryModel]()
    var courses = [CourseModel]()
    var selectCourse = CourseModel()
    var selectCategory: CategoryModel?
    var loadingMoreData = false
    
    func getCourses() {
        view?.showLoadingMain(bool: true)
        Task {
            courses = try await CourseServices().getAllCourses()
            loadingMoreData = false
            DispatchQueue.main.async {
                self.view?.showCourses()
                self.view?.showLoadingMain(bool: false)
            }
        }
    }
    
    func getNextPage(page: String) {
        view?.showLoadingPage(bool: true)
        Task {
            let result = try await CourseServices().getAllCourses(page: page)
            courses += result
            loadingMoreData = false
            DispatchQueue.main.async {
                self.view?.showNextPage()
                self.view?.showLoadingPage(bool: false)
            }
        }
    }
    
    func getCategories() {
        Task {
            categories = try await CategoryServices.getCategories()
            DispatchQueue.main.async {
                self.view?.showCategories()
            }
        }
    }
    
    func getCoursesByCategory(id: Int) {
        courses.removeAll()
        view?.showLoadingMain(bool: true)
        Task {
            let results = try await CourseServices().getAllCourses(categoryID: id)
            courses = results
            loadingMoreData = false
            DispatchQueue.main.async {
                self.view?.showLoadingMain(bool: false)
                self.view?.showCourses()
            }
        }
    }
    
    func searchCourse(text: String) {
        Task {
            courses = try await CourseServices().searchCourses(text: text, category: selectCategory)
            DispatchQueue.main.async {
                self.view?.searchCourses()
            }
        }
    }

    func viewDidLoad() {
        getCourses()
        getCategories()
    }
    
    func getSelectCategory(indexPath: IndexPath, search: String) {
        if selectCategory?.id == categories[indexPath.row].id {
            loadCourses(text: search)
        }else {
            loadCategory(indexPath: indexPath, search: search)
        }
    }
    
    private func loadCategory(indexPath: IndexPath, search: String) {
        selectCategory = categories[indexPath.row]
        
        if search == "" {
            getCoursesByCategory(id: categories[indexPath.row].id)
        }else {
            searchCourse(text: search)
        }
        view?.updateCollection()
    }
    
    private func loadCourses(text: String) {
        selectCategory = nil
        courses.removeAll()
        view?.updateCollection()
        if text == "" {
            getCourses()
        } else {
            searchCourse(text: text)
        }
    }
    
    
}
