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
        let response = AF.request(url, method: .post, headers: headers).serializingData()
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
    
    func changeTrainingModule(module: TrainingModule, progressHandler: @escaping (Int) -> Void) async throws  {
        try await changeTrainingItems(module: module)
        try await changeOtherOptions(module: module, progressHandler: progressHandler)
    }
    
    private func changeOtherOptions(module: TrainingModule, progressHandler: @escaping (Int) -> Void) async throws {
        let url = Constants.url + "api/v1/training-module/update/\(module.module.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        
        let update = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(module.description.utf8), withName: "training_description")
            if let mediaURL = module.mediaURL, "\(mediaURL)".starts(with: "file") {
                multipartFormData.append(mediaURL, withName: "data")
            }
        }, to: url, method: .patch, headers: headers)
        
        update.uploadProgress { progress in
            let percentComplete = Int(progress.fractionCompleted * 100)
            progressHandler(percentComplete)
        }
        let response = update.serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
    private func changeTrainingItems(module: TrainingModule) async throws {
        let url = Constants.url + "api/v1/training-module/update/\(module.module.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        let parameters = [
            "training_items": module.trainingItems.map { $0.toDictionary }
        ]
        
        let response = AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
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
