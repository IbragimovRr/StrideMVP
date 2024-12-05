//
//  RegistrPresenter.swift
//  Courses
//
//  Created by Руслан on 05.12.2024.
//

import Foundation

protocol RegistrPresenterDelegate {
    func signUp(phoneNumber: String,password: String,name: String,lastName: String,mail: String)
}

class RegistrPresenter: RegistrPresenterDelegate {
    
    var view: RegistrViewDelegate?
    
    func signUp(phoneNumber: String, password: String, name: String, lastName: String, mail: String) {
        view?.showLoading(bool: true)
        Task {
            do {
                let phoneNumberFormat = phoneNumber.format(with: "+XXXXXXXXXXX")
                try await SignServices().registr(phoneNumber: phoneNumberFormat, password: password, name: name, lastName: lastName, mail: mail)
                DispatchQueue.main.async {
                    self.view?.showLoading(bool: false)
                    self.view?.successRegistr()
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.showLoading(bool: false)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.showLoading(bool: false)
                    self.view?.showError(error: "Попробуйте позже")
                }
            }
        }
    }
}
