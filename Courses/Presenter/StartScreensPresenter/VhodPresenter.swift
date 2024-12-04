//
//  VhodPresenter.swift
//  Courses
//
//  Created by Руслан on 05.12.2024.
//

import UIKit

protocol VhodPresenterDelegate {
    func vhod(phoneNumber: String, password: String)
    func googleSign(_ viewController: UIViewController)
}

class VhodPresenter: VhodPresenterDelegate {
    
    var view: VhodViewDelegate?
    
    func googleSign(_ viewController: UIViewController) {
        SignServices().signGoogle(viewController)
    }
    
    func vhod(phoneNumber: String, password: String) {
        view?.showLoading(bool: true)
        Task {
            do {
                let phoneNumberFormat = phoneNumber.format(with: "+XXXXXXXXXXX")
                try await SignServices().vhod(phoneNumber: phoneNumberFormat, password: password)
                DispatchQueue.main.async {
                    self.view?.successVhod()
                    self.view?.showLoading(bool: false)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.showLoading(bool: false)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: nil)
                    self.view?.showLoading(bool: false)
                }
            }
        }
    }
    
}
