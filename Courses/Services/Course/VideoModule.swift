//
//  VideoModule.swift
//  Courses
//
//  Created by Руслан on 12.01.2025.
//

import Foundation
import Alamofire
import SwiftyJSON

extension CourseServices {
    
    func addVideoModule(dayID: Int, position: Int) async throws -> Int {
        let url = Constants.url + "api/v1/video-module/create/\(dayID)/"
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
    
    func addVideoModulesData(module: VideoModule) async throws {
        let url = Constants.url + "api/v1/video-module/update/\(module.module.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        let response =  AF.upload(multipartFormData: { multipartFormData in
            if let videoURL = module.videoURL, "\(videoURL)".starts(with: "file") {
                multipartFormData.append(videoURL, withName: "data")
            }
            if let description = module.videoDescription {
                multipartFormData.append(Data(description.utf8), withName: "video_desc")
            }
            if let author = module.author {
                multipartFormData.append(Data(author.utf8), withName: "author")
            }
            multipartFormData.append(Data("\(module.timeVideo)".utf8), withName: "time")
        }, to: url, method: .patch, headers: headers).serializingData()
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
    
    func deleteVideoModule(moduleID: Int) async throws {
        let url = Constants.url + "api/v1/video-module/delete/\(moduleID)/"
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
