//
//  CloudServices.swift
//  Courses
//
//  Created by Руслан on 03.01.2025.
//

import Foundation
import AWSS3
import AWSCore

class CloudServices {
    
    private let accessKey = "YCAJEU1x2VW_nZJRAhvUoVR1O"
    private let secretKey = "YCNHv4ti2jzm3lLJlcVnql_c6r_eegc3mprWoWLF"
    private let bucketName = "stride"
    private let region = "ru-central1"
    private let endpoint = "https://storage.yandexcloud.net"
    
    func configureAWS() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        
        let endpoint = AWSEndpoint(
            region: .EUCentral1,
            service: .S3,
            url: URL(string: "https://storage.yandexcloud.net")!
        )
        
        let config = AWSServiceConfiguration(
            region: .EUCentral1,
            endpoint: endpoint,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = config
    }
    
    func uploadFileToS3(fileURL: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            
            configureAWS()
            
            let key = "images_editor/" + UUID().uuidString
            var finished = false
            
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = {(task, progress) in
                if progress.isFinished {
                    if finished {
                        let publicURL = self.generatePublicURL(key: key)
                        continuation.resume(returning: publicURL)
                    }
                    finished = true
                }
            }
            
            let contentType = checkContentTypeFile(fileURL: fileURL)
            
            
            let uploadTask = AWSS3TransferUtility.default().uploadFile(
                fileURL,
                bucket: bucketName,
                key: key,
                contentType: contentType,
                expression: expression
            )
        }
    }

    
    private func generatePublicURL(key: String) -> String {
        let urlString = "\(endpoint)/\(bucketName)/\(key)"
        return urlString
    }
    
    private func checkContentTypeFile(fileURL: URL) -> String {
        var contentType = "application/octet-stream"
        let fileExtension = fileURL.pathExtension.lowercased()
        switch fileExtension {
        case "jpg", "jpeg":
            contentType = "image/jpeg"
        case "png":
            contentType = "image/png"
        case "gif":
            contentType = "image/gif"
        case "webp":
            contentType = "image/webp"
        case "mp4":
            contentType = "video/mp4"
        case "webm":
            contentType = "video/webm"
        case "mov", "quicktime":
            contentType = "video/quicktime"
        case "mpeg":
            contentType = "video/mpeg"
        default:
            contentType = "application/octet-stream"
        }
        return contentType
    }

}
