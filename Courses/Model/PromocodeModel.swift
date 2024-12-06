//
//  PromocodeModel.swift
//  Courses
//
//  Created by Руслан on 06.12.2024.
//

import Foundation

class PromocodeModel {
    var name: String
    var procent: Int
    var dateStart: String?
    var dateEnd: String?
    var buyers: Int
    var countCourses: Int
    var id: Int
    
    init(name: String, procent: Int, dateStart: String?, dateEnd: String?, buyers: Int, countCourses: Int, id: Int) {
        self.name = name
        self.procent = procent
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.buyers = buyers
        self.countCourses = countCourses
        self.id = id
    }
    
    init() {
        self.name = ""
        self.procent = 0
        self.dateStart = nil
        self.dateEnd = nil
        self.buyers = 0
        self.countCourses = 0
        self.id = 0
    }
    
}
