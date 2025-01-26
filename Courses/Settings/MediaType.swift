//
//  MediaType.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import Foundation

enum MediaType {
    case image
    case video
    case none
}

class MediaTypeManager {
    func determineFileType(from url: URL) -> MediaType {
        let pathExtension = url.pathExtension.lowercased()

        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "flv", "wmv"]

        if imageExtensions.contains(pathExtension) {
            return .image
        } else if videoExtensions.contains(pathExtension) {
            return .video
        } else {
            return .none
        }
    }
}
