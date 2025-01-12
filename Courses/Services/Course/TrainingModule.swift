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
    
    func changeTrainingModuleInfo(info: Modules) async throws {
        let url = Constants.url + "api/v1/training-module/update/\(info.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        let response =  AF.upload(multipartFormData: { multipartFormData in
            if let imageURL = info.imageURL, "\(imageURL)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: imageURL, maxSizeInMB: 0.1) { imageURL in
                    multipartFormData.append(imageURL!, withName: "image")
                }
            }
            multipartFormData.append(Data(info.name.utf8), withName: "title")
            if let description = info.description {
                multipartFormData.append(Data(description.utf8), withName: "desc")
            }
            multipartFormData.append(Data("\(info.minutes)".utf8), withName: "time_to_pass")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            } else {
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
