//
//  CourseServices.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import UIKit
import Alamofire
import SwiftyJSON

class CourseServices {
    
    private var mananger = CourseMananger()
    private var json = CourseJSON()
    
    // MARK: - Получить дни и модули
    
    func getDaysInCourse(id: Int) async throws -> Course {
        let value = try await mananger.getDaysValue(id: id)
        let course = try await json.daysInCourse(value: value)
        return course
    }
    
    
    
    // MARK: - Получить курсы
    
    func getAllCourses(page: String? = nil) async throws -> [Course] {
        let value = try await mananger.getAllCourses(page: page)
        let courses = json.allCourses(value: value)
        return courses
    }
    
    func getAllCourses(categoryID: Int) async throws -> [Course] {
        let value = try await mananger.getCoursesByCategory(id: categoryID)
        let courses = json.allCourses(value: value)
        return courses
    }
    
    func getCoursesByID(id: Int) async throws -> Course {
        let value = try await mananger.getCoursesByID(id: id)
        let course = json.course(value: value)
        return course
    }
    
    func getCoursesByUserID(id: Int) async throws -> [Course] {
        let value = try await mananger.getCoursesByUserID(id: id)
        let courses = json.allCoursesByUser(value: value)
        return courses
    }
    
    func getCoursesByCelebrity() async throws -> [Course] {
        let value = try await mananger.getCoursesByCelebrity()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }
    
    func getPopularCourses() async throws -> [Course] {
        let value = try await mananger.getPopularCourses()
        let courses = json.allCourses(value: value)
        return courses
    }
    
    func getRecomendedCourses() async throws -> [Course] {
        let value = try await mananger.getRecomendedCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }
    
    
    // MARK: - Получить мои курсы
    
    func getBoughtCourses() async throws -> [Course] {
        let value = try await mananger.getBoughtCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }
    
    func getMyCreateCourses() async throws -> [Course] {
        let value = try await mananger.getMyCreateCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }
    
    // MARK: - Изменить
    
    func changeModuleInfo(info: Modules) async throws {
        let url = Constants.url + "api/v1/module/update/\(info.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.upload(multipartFormData: { multipartFormData in
            if let imageURL = info.imageURL, "\(imageURL)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: imageURL, maxSizeInMB: 0.1) { imageURL in
                    multipartFormData.append(imageURL!, withName: "image")
                }
            }
            multipartFormData.append(Data(info.name.utf8), withName: "title")
            if let description = info.description {
                multipartFormData.append(Data(description.utf8), withName: "desc")
            }
            multipartFormData.append(Data("\(info.minutes)".utf8), withName: "time_to_pass")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            } else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    func changePositionModule(info: Modules) async throws {
        let url = Constants.url + "api/v1/module/update/\(info.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let parameters = [
            "order": info.position
        ]
        let response =  AF.request(url, method: .patch, parameters: parameters, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            } else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    func completedModule(id: Int) async throws {
        let url = Constants.url + "api/v1/courses/\(id)/complete-module/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = try await AF.request(url, method: .post, headers: headers).serializingData().value
    }
    
    // MARK: - Добавить
    
    func saveInfoCourse(info: Course, method: HTTPMethod = .post) async throws -> Int {
        var url = Constants.url + "api/v1/courses/"
        if method == .patch {
            url += "\(info.id)/"
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.upload(multipartFormData: { multipartFormData in
            // Image
            if "\(info.imageURL!)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: info.imageURL!, maxSizeInMB: 0.1) { compressedURL in
                    if let url = compressedURL {
                        multipartFormData.append(url, withName: "image")
                    }
                }
            }
            // Черновик
            if method == .post {
                multipartFormData.append(Data("\(info.isDraft)".utf8), withName: "is_draft")
            }
            multipartFormData.append(Data(info.nameCourse.utf8), withName: "title")
            multipartFormData.append(Data("\(info.price)".utf8), withName: "price")
            multipartFormData.append(Data(info.description.utf8), withName: "desc")
            multipartFormData.append(Data("\(info.category.id)".utf8), withName: "category_id")
        }, to: url, method: method, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 && method == .patch {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        
        if code != 201 && method == .post {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        
        if method == .post {
            let _ = try await addDaysInCourse(courseID: json["id"].intValue)
        }
        
        let idCourse = json["id"].intValue
        return idCourse
    }
    
    func addDaysInCourse(courseID: Int) async throws -> Int {
        let url = Constants.url + "api/v1/day/create/\(courseID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        let id = json["id"].intValue
        return id
    }
    
    func addModulesInCourse(dayID: Int, position: Int) async throws -> Int {
        let url = Constants.url + "api/v1/module/create/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        let id = json["id"].intValue
        return id
    }
    
    func addModulesData(text: NSAttributedString, moduleID: Int) async throws {
        let url = Constants.url + "api/v1/module/update/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let file = FilePath().serializeAttributedStringToFile(text)!
        let tempFileURL = file.deletingPathExtension().appendingPathExtension("data")
        let response = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(tempFileURL, withName: "data")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    // MARK: - Удалить
    
    func deleteModule(moduleID: Int) async throws {
        let url = Constants.url + "api/v1/module/delete/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.request(url, method: .delete, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 204 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    func deleteDay(dayID: Int) async throws {
        let url = Constants.url + "api/v1/day/delete/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.request(url, method: .delete, headers: headers).serializingData()
        let value = try await response.value
    }
    
    // MARK: - Купить курс
    
    func buyCourse(id: Int) async throws  {
        let url = Constants.url + "api/v1/courses/\(id)/buy_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    // MARK: - Поиск
    func searchCourses(text: String, category: CategoryModel?) async throws -> [Course] {
        let value = try await mananger.searchCourses(text: text, category: category)
        let courses = json.allCourses(value: value)
        return courses
    }
    
    // MARK: - Отправить курс на проверку
    func sendCoursesVerification(idCourse: Int) async throws {
        let url = Constants.url + "api/v1/courses/\(idCourse)/send_to_verificate/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
}
