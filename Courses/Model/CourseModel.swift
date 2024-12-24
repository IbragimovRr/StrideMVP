//
//  CourseModel.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import Foundation

class CourseModel {
    var daysCount: Int
    var nameCourse: String
    var author: UserModel = UserModel()
    var price: Int
    var category: CategoryModel = CategoryModel()
    var imageURL: URL?
    var rating: Float
    var myRating: Int
    var progressInDays: Int = 0
    var id: Int
    var description: String
    var dataCreated: String
    var countBuyer: Int = 0
    var isBought: Bool = false
    var courseDays = [CourseDays]()
    var isDraft: Bool
    var next: String = ""
    var verification: Verification = .proccess
    
    init(daysCount: Int = 0, nameCourse: String = "", price: Int = 0, category: CategoryModel = CategoryModel(), imageURL: URL? = nil, rating: Float = 0.0, myRating:Int = 0, id: Int = 0, description: String = "", dataCreated: String = "", progressInDays: Int = 0, countBuyer: Int = 0, isBought: Bool = false, isDraft: Bool = true, next: String = "", verification: Verification = .proccess, author: UserModel = UserModel()) {
        self.daysCount = daysCount
        self.nameCourse = nameCourse
        self.price = price
        self.author = author
        self.category = category
        self.imageURL = imageURL
        self.rating = CommentsServices().roundRating(rating: rating)
        self.myRating = myRating
        self.id = id
        self.description = description
        self.dataCreated = dataCreated
        self.progressInDays = progressInDays
        self.countBuyer = countBuyer
        self.isBought = isBought
        self.isDraft = isDraft
        self.next = next
        self.verification = verification
    }
    
}

struct Modules {
    var text: URL?
    var videoURL: URL?
    var name: String
    var minutes: Int
    var imageURL: URL?
    var description: String?
    var id: Int
    var isCompleted: Bool = false
    var position: Int = 0
    var views: Int = 0
    var timeVideo: Int = 0
    var author: String?
    var videoDescription: String?
    var type : ModuleType = .text
}

enum ModuleType {
    case text
    case video
}



struct CourseDays {
    var dayID: Int
    var type: TypeDays = .noneSee
    var modules = [Modules]()
    var completed: Bool = false
    
    init(dayID: Int, type: TypeDays, modules: [Modules] = [Modules](), completed: Bool = false) {
        self.dayID = dayID
        self.type = type
        self.modules = modules.sorted(by: { $0.position < $1.position })
        self.completed = completed
    }
}
