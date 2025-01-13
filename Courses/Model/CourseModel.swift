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
    var mySendRating: Int
    var progressInDays: Int = 0
    var id: Int
    var description: String
    var dataCreated: String
    var countBuyer: Int = 0
    var isBought: Bool = false
    var courseDays = [DayModel]()
    var isDraft: Bool
    var nextPage: String = ""
    var verification: Verification = .proccess
    
    init(daysCount: Int = 0, nameCourse: String = "", price: Int = 0, category: CategoryModel = CategoryModel(), imageURL: URL? = nil, rating: Float = 0.0, mySendRating: Int = 0, id: Int = 0, description: String = "", dataCreated: String = "", progressInDays: Int = 0, countBuyer: Int = 0, isBought: Bool = false, isDraft: Bool = true, nextPage: String = "", verification: Verification = .proccess, author: UserModel = UserModel()) {
        self.daysCount = daysCount
        self.nameCourse = nameCourse
        self.price = price
        self.author = author
        self.category = category
        self.imageURL = imageURL
        self.rating = CommentsServices().roundRating(rating: rating)
        self.mySendRating = mySendRating
        self.id = id
        self.description = description
        self.dataCreated = dataCreated
        self.progressInDays = progressInDays
        self.countBuyer = countBuyer
        self.isBought = isBought
        self.isDraft = isDraft
        self.nextPage = nextPage
        self.verification = verification
    }
    
}

