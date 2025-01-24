//
//  ModuleModel.swift
//  Courses
//
//  Created by Руслан on 14.01.2025.
//

import Foundation

protocol ModuleProtocol {
    var module: Modules { get set }
    var type: ModuleType { get set }
    var position: Int { get }
}

struct CustomModule: ModuleProtocol {
    var module: Modules
    var type: ModuleType = .custom
    var text: URL?
    
    var position: Int {
        module.position
    }
}

struct VideoModule: ModuleProtocol {
    var module: Modules
    var type: ModuleType = .video
    var videoURL: URL?
    var views: Int = 0
    var timeVideo: Int = 0
    var author: String?
    var videoDescription: String?
    
    var position: Int {
        module.position
    }
}

struct TrainingModule: ModuleProtocol {
    var module: Modules
    var type: ModuleType = .training
    var mediaURL: URL?
    var description: String = ""
    var trainingItems = [TrainingItem]()
    
    var position: Int {
        module.position
    }
}

/// Дефолтные значение которые есть у всех модулей
struct Modules {
    var name: String
    var minutes: Int
    var imageURL: URL?
    var description: String?
    var id: Int
    var isCompleted: Bool = false
    var position: Int = 0
    var isVisible: Bool = false
}

enum FormatTraining: String {
    case weight = "WEIGHT"
    case repeats = "REPEATS"
    case timer = "TIMER"
    case distance = "DISTANCE"
    
    var initialDefaultName: String {
        switch self {
        case .weight:
            return "Вес"
        case .repeats:
            return "Повторения"
        case .timer:
            return "Таймер"
        case .distance:
            return "Дистанция"
        }
    }
    
    func initialFormatTraining(_ format: String) -> FormatTraining {
        switch format {
        case "Вес":
            return .weight
        case "Повторения":
            return .repeats
        case "Таймер":
            return .timer
        case "Дистанция":
            return .distance
        default:
            return .weight
        }
    }
}

/// Подходы в тренировочном модуле
struct TrainingItem {
    var firstItemType: FormatTraining?
    var firstItemData: String?
    var secondItemType: FormatTraining?
    var secondItemData: String?
}

enum ModuleType {
    case custom
    case video
    case training
}
