//
//  DayModel.swift
//  Courses
//
//  Created by Руслан on 14.01.2025.
//

import Foundation

struct DayModel {
    var dayID: Int
    var type: TypeDays = .noneSee
    var modules = [ModuleProtocol]()
    var completed: Bool = false
    var isVerified: Bool = false
}
