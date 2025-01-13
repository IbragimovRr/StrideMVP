//
//  CourseResponse.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import SwiftyJSON

class CourseResponse {
    
    // MARK: - Days JSON
    func daysInCourse(value: Data) async throws -> CourseModel {
        let json = JSON(value)
        let course = CourseModel()
        var modules = [ModuleProtocol]()
        /// Информация курса
        course.nameCourse = json["title"].stringValue
        course.id = json["id"].intValue
        course.isDraft = json["is_draft"].boolValue
        course.verification = Verification(rawValue: json["verification"].stringValue) ?? .proccess
        let daysCount = json["days"].arrayValue.count
        guard daysCount > 0 else {throw ErrorNetwork.runtimeError("Пустой массив")}

        for x in 0...daysCount - 1 {
            /// Информация модулей
            let idDay = json["days"][x]["id"].intValue
            let modulesArray = json["days"][x]["modules"].arrayValue.count
            let trainingModulesArray = json["days"][x]["training_modules"].arrayValue.count
            let videoModulesArray = json["days"][x]["video_modules"].arrayValue.count
            let completed = json["days"][x]["day_completed"].boolValue
            modules += initialCustomModule(x: x, modulesCount: modulesArray, json: json)
            modules += initialVideoModule(x: x, modulesCount: videoModulesArray, json: json)
            modules += initialTrainingModule(x: x, modulesCount: trainingModulesArray, json: json)
            course.courseDays.append(DayModel(dayID: idDay, type: .noneSee, modules: modules, completed: completed))
            modules.removeAll()
        }
        return course
    }
    
    /// Достаются все Кастомные модули
    private func initialCustomModule(x: Int, modulesCount: Int, json: JSON) -> [ModuleProtocol] {
        guard modulesCount != 0 else { return [] }
        var modules = [ModuleProtocol]()
        for y in 0...modulesCount - 1 {
            let id = json["days"][x]["modules"][y]["id"].intValue
            let text = json["days"][x]["modules"][y]["data"].stringValue
            let min = json["days"][x]["modules"][y]["time_to_pass"].intValue
            let title = json["days"][x]["modules"][y]["title"].stringValue
            let image = json["days"][x]["modules"][y]["image"].stringValue
            let desc = json["days"][x]["modules"][y]["desc"].stringValue
            let index = json["days"][x]["modules"][y]["order"].intValue
            let completed = json["days"][x]["modules"][y]["module_complete"].boolValue
            modules.append(CustomModule(module: Modules( name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id, isCompleted: completed, position: index), text: URL(string: text)))
        }
        return modules
    }
    
    /// Достаются все Тренировочные модули
    private func initialTrainingModule(x: Int, modulesCount: Int, json: JSON) -> [ModuleProtocol] {
        guard modulesCount != 0 else { return [] }
        var modules = [ModuleProtocol]()
        for y in 0...modulesCount - 1 {
            let id = json["days"][x]["training_modules"][y]["id"].intValue
            let min = json["days"][x]["training_modules"][y]["time_to_pass"].intValue
            let title = json["days"][x]["training_modules"][y]["title"].stringValue
            let image = json["days"][x]["training_modules"][y]["image"].stringValue
            let desc = json["days"][x]["training_modules"][y]["desc"].stringValue
            let index = json["days"][x]["training_modules"][y]["order"].intValue
            let completed = json["days"][x]["training_modules"][y]["module_complete"].boolValue
            let mediaURL = json["days"][x]["training_modules"][y]["data"].stringValue
            let description = json["days"][x]["training_modules"][y]["training_description"].stringValue
            let trainingItemsCount = json["days"][x]["training_modules"][y]["training_items"].arrayValue.count
            
            let trainingItmes = initialTrainingItem(x: x, y: y, count: trainingItemsCount, json: json)
            
            var defaultModels = Modules( name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id, isCompleted: completed, position: index)
            
            modules.append(TrainingModule(module: defaultModels, mediaURL: URL(string: mediaURL), description: description, trainingItems: trainingItmes))
        }
        return modules
    }
    
    ///Достаются все тренировочные подходы
    private func initialTrainingItem(x: Int, y: Int, count: Int, json: JSON) -> [TrainingItem] {
        guard count != 0 else { return [] }
        var items = [TrainingItem]()
        for z in 0...count - 1 {
            let firstType = json["days"][x]["training_modules"][y]["training_items"][z]["first_item"].stringValue
            let firstData = json["days"][x]["training_modules"][y]["training_items"][z]["first_data"].stringValue
            let secondType = json["days"][x]["training_modules"][y]["training_items"][z]["second_item"].stringValue
            let secondData = json["days"][x]["training_modules"][y]["training_items"][z]["second_data"].stringValue
            items.append(TrainingItem(firstItemType: FormatTraining(rawValue: firstType), firstItemData: firstData, secondItemType: FormatTraining(rawValue: secondType), secondItemData: secondData))
        }
        return items
    }
    
    /// Достается все видео модули
    private func initialVideoModule(x: Int, modulesCount: Int, json: JSON) -> [ModuleProtocol] {
        guard modulesCount != 0 else { return [] }
        var modules = [ModuleProtocol]()
        for y in 0...modulesCount - 1 {
            let id = json["days"][x]["video_modules"][y]["id"].intValue
            let min = json["days"][x]["video_modules"][y]["time_to_pass"].intValue
            let title = json["days"][x]["video_modules"][y]["title"].stringValue
            let image = json["days"][x]["video_modules"][y]["image"].stringValue
            let desc = json["days"][x]["video_modules"][y]["desc"].stringValue
            let index = json["days"][x]["video_modules"][y]["order"].intValue
            let completed = json["days"][x]["video_modules"][y]["module_complete"].boolValue
            
            let video = json["days"][x]["video_modules"][y]["data"].stringValue
            let videoDesc = json["days"][x]["video_modules"][y]["video_desc"].stringValue
            
            
            var defaultModule = Modules( name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id, isCompleted: completed, position: index)
            
            modules.append(VideoModule(module: defaultModule, videoURL: URL(string: video), views: 0, timeVideo: 0, author: "Кто-то", videoDescription: videoDesc))
        }
        return modules
    }
    
    
    // MARK: - All Courses JSON
    func allCourses(value: Data) -> [CourseModel] {
        let json = JSON(value)
        var courses = [CourseModel]()

        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}

        for x in 0...results.count - 1 {
            let daysCount = json["results"][x]["count_days"].intValue
            let title = json["results"][x]["title"].stringValue
            let price = json["results"][x]["price"].intValue
            let id = json["results"][x]["id"].intValue
            let image = json["results"][x]["image"].stringValue
            let description = json["results"][x]["desc"].stringValue
            let dataCreated = json["results"][x]["created_at"].stringValue
            let authorName = json["results"][x]["author"]["first_name"].stringValue
            let authorSurname = json["results"][x]["author"]["last_name"].stringValue
            let authorID = json["results"][x]["author"]["id"].intValue
            let authorAvatar = json["results"][x]["author"]["image"].stringValue
            let author = UserModel(name:authorName, surname: authorSurname, id: authorID, avatarURL: URL(string: authorAvatar))
            let countBuyer = json["results"][x]["bought_count"].intValue
            let rating = json["results"][x]["rating"].floatValue
            let isBought = json["results"][x]["bought"].boolValue
            let next = json["next"].stringValue
            let progressInDays = json["results"][x]["completed_days_count"].intValue
            courses.append(CourseModel(daysCount: daysCount, nameCourse: title, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, progressInDays: progressInDays, countBuyer: countBuyer, isBought: isBought, nextPage: next, author: UserModel(name:authorName, surname: authorSurname, id: authorID)))
        }
        return courses
    }
    
    // MARK: - All Courses By another user
    func allCoursesByUser(value: Data) -> [CourseModel] {
        let json = JSON(value)
        var courses = [CourseModel]()

        let results = json.arrayValue
        guard results.isEmpty == false else {return []}

        for x in 0...results.count - 1 {
            let daysCount = json[x]["count_days"].intValue
            let title = json[x]["title"].stringValue
            let price = json[x]["price"].intValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            let description = json[x]["desc"].stringValue
            let dataCreated = json[x]["created_at"].stringValue
            let authorName = json[x]["author"]["first_name"].stringValue
            let authorSurname = json[x]["author"]["last_name"].stringValue
            let authorID = json[x]["author"]["id"].intValue
            let authorAvatar = json[x]["author"]["image"].stringValue
            let author = UserModel(name:authorName, surname: authorSurname, id: authorID, avatarURL: URL(string: authorAvatar))
            let countBuyer = json[x]["bought_count"].intValue
            let rating = json[x]["rating"].floatValue
            let isBought = json[x]["bought"].boolValue
            let isDraft = json[x]["is_draft"].boolValue
            let verification = Verification(rawValue: json[x]["verification"].stringValue) ?? .proccess
            let progressInDays = json[x]["completed_days_count"].intValue
            courses.append(CourseModel(daysCount: daysCount, nameCourse: title, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, progressInDays: progressInDays, countBuyer: countBuyer, isBought: isBought, isDraft: isDraft, verification: verification, author: author))
        }
        return courses
    }
    
    // MARK: - One Course
    func course(value: Data) -> CourseModel {
        let json = JSON(value)
        let daysCount = json["count_days"].intValue
        let title = json["title"].stringValue
        let price = json["price"].intValue
        let id = json["id"].intValue
        let image = json["image"].stringValue
        let description = json["desc"].stringValue
        let dataCreated = json["created_at"].stringValue
        let authorName = json["author"]["first_name"].stringValue
        let authorSurname = json["author"]["last_name"].stringValue
        let authorID = json["author"]["id"].intValue
        let authorAvatar = json["author"]["image"].stringValue
        let author = UserModel(name:authorName, surname: authorSurname, id: authorID, avatarURL: URL(string: authorAvatar))
        let rating = json["rating"].floatValue
        let myRating = json["my_rating"]["rating"].intValue
        let categoryID = json["category"]["id"].intValue
        let categoryTitle = json["category"]["title"].stringValue
        let categoryImage = json["category"]["image"].stringValue
        let category = CategoryModel(nameCategory: categoryTitle, imageURL: URL(string: categoryImage), id: categoryID)
        let boughtCount = json["bought_count"].intValue
        let isBought = json["bought"].boolValue
        let isDraft = json["is_draft"].boolValue
        let verification = Verification(rawValue: json["verification"].stringValue) ?? .proccess
        let course = CourseModel(daysCount: daysCount, nameCourse: title, price: price, category: category, imageURL: URL(string: image),rating: rating, mySendRating: myRating, id: id, description: description, dataCreated: dataCreated, countBuyer: boughtCount, isBought: isBought, isDraft: isDraft, verification: verification, author: author)
        return course
    }
}
