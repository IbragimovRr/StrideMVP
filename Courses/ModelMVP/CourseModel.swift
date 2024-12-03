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
    var author: UserStruct = UserStruct()
    var price: Int
    var category: Category = Category()
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
    
    init(daysCount: Int = 0, nameCourse: String = "", price: Int = 0, category: Category = Category(), imageURL: URL? = nil, rating: Float = 0.0, myRating:Int = 0, id: Int = 0, description: String = "", dataCreated: String = "", progressInDays: Int = 0, countBuyer: Int = 0, isBought: Bool = false, isDraft: Bool = true, next: String = "", verification: Verification = .proccess, author: UserStruct = UserStruct()) {
        self.daysCount = daysCount
        self.nameCourse = nameCourse
        self.price = price
        self.author = author
        self.category = category
        self.imageURL = imageURL
        self.rating = Comments().roundRating(rating: rating)
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
