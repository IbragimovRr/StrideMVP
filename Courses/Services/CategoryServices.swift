//
//  CategoryServices.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class CategoryServices {
    
    static func getCategories() async throws -> [CategoryModel] {
        let url = Constants.url + "api/v1/categories/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var categories = [CategoryModel]()

        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}

        for x in 0...results.count - 1 {
            let title = json["results"][x]["title"].stringValue
            let image = json["results"][x]["image"].stringValue
            let id = json["results"][x]["id"].intValue
            categories.append(CategoryModel(nameCategory: title, imageURL: URL(string: image)!, id: id))
        }
        return categories
    }
    
}
