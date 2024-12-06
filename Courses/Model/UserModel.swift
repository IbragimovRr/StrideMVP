//
//  UserModel.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import Foundation

struct UserModel {
    var userName: String
    var role: Role
    var name: String
    var surname: String
    var email: String
    var phone: String
    var height: Double?
    var weight: Double?
    var birthday: String?
    var avatarURL: URL?
    var level: Level?
    var goal: Goal?
    var coach = CoachModel()
    var myCourses = [CourseModel]()
    var id = 0
    var token = ""
    
    init(role: Role = .user, name: String = "", surname: String = "", email: String = "", phone: String = "", id: Int = 0, avatarURL: URL? = nil) {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.id = id
        self.phone = phone
        self.userName = "\(self.name) \(self.surname)"
        self.avatarURL = avatarURL
    }
    
    init(role: Role, name: String, surname: String, email: String, phone: String, height: Double? = nil, weight: Double? = nil, birthday: String? = nil, description: String? = nil, avatarURL: URL? = nil, level: Level? = nil, goal: Goal? = nil, myCourses: [CourseModel] = [CourseModel](), id: Int = 0) {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.height = height
        self.weight = weight
        self.birthday = birthday
        self.avatarURL = avatarURL
        self.level = level
        self.goal = goal
        self.myCourses = myCourses
        self.userName = "\(self.name) \(self.surname)"
    }
}

struct CoachModel {
    var description: String?
    var countCourses: Int = 0
    var rating: Float = 0.0
    var myCourses = [CourseModel]()
    var money: Int = 0
}

struct InfoMeModel: Encodable {
    var level: String?
    var goal: String?
    var height: Double?
    var weight: Double?
    var date_of_birth: String?
}
