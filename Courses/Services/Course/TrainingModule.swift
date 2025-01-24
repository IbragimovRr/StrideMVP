//
//  CourseService Ex Module.swift
//  Courses
//
//  Created by Руслан on 12.01.2025.
//

import Foundation
import Alamofire
import SwiftyJSON

extension CourseServices {
    
    func addTrainingModule(dayID: Int, position: Int) async throws -> Int {
        let url = Constants.url + "api/v1/training-module/create/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        let parameters = ["training_description":"a"]
        let response = AF.request(url, method: .post, parameters: parameters, headers: headers).serializingData()
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
    
    func deleteTrainingModule(moduleID: Int) async throws {
        let url = Constants.url + "api/v1/training-module/delete/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
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
}
