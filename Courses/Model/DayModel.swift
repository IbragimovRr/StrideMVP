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
    
    init(dayID: Int, type: TypeDays, modules: [ModuleProtocol] = [ModuleProtocol](), completed: Bool = false) {
        self.dayID = dayID
        self.type = type
        self.modules = modules.sorted(by: { $0.position < $1.position })
        self.completed = completed
    }
}
