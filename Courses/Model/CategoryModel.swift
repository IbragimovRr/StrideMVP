//
//  CategoryModel.swift
//  Courses
//
//  Created by Руслан on 03.12.2024.
//

import Foundation

class CategoryModel {
    
    var nameCategory: String
    var imageURL: URL?
    var id: Int
    
    init(nameCategory: String = "", imageURL: URL? = nil, id: Int = 0) {
        self.nameCategory = nameCategory
        self.imageURL = imageURL
        self.id = id
    }
    
}
