//
//  Privacy.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import UIKit
import Photos
import Alamofire
import SwiftyJSON

class Privacy {
    
    func checkPhotoLibraryAuthorization() -> Bool {
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    let _ = self.checkPhotoLibraryAuthorization()
                }
            }
        case .denied, .restricted:
            showAccessDeniedAlert()
        default:
            break
        }
        return false
    }
    
    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к фотогалерее запрещен",
                                      message: "Пожалуйста, разрешите приложению доступ к фотогалерее в настройках.",
                                      preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        rootViewController.present(alert, animated: true, completion: nil)
    }
}

class AppStoreVersion {
    static let shared = AppStoreVersion()
    
    var isUpdate = false
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    func isVersion(lessThan otherVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let otherComponents = otherVersion.split(separator: ".").compactMap { Int($0) }
        
        for (v1, v2) in zip(currentComponents, otherComponents) {
            if v1 < v2 { return true }
            if v1 > v2 { return false }
        }
        let result = currentComponents.count < otherComponents.count
        return result
    }
    
    func getVersion() async throws -> String {
        let url = Constants.url + "api/v1/users/version/get/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserServices.info.token)"]
        let value = try await AF.request(
            url,method: .get,
            headers: headers
        ).serializingData().value
        let json = JSON(value)
        let version = json["version"].stringValue
        return version
    }
    
}
