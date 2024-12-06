//
//  ChangeInformationPresenter.swift
//  Courses
//
//  Created by Руслан on 06.12.2024.
//

import Foundation

protocol ChangeInformationPresenterDelegate {
    func getUser()
    func save()
}

class ChangeInformationPresenter: ChangeInformationPresenterDelegate {
    
    var view: ChangeInformationViewDelegate?
    var user: UserModel = UserServices.info
    
    func getUser() {
        Task {
            user = try await UserServices().getMyInfo()
            DispatchQueue.main.async {
                if self.user.role == .user {
                    self.view?.showUser()
                }else {
                    self.view?.showCoach()
                }
            }
        }
    }
    
    func save() {
        view?.showEnabledSaveBtn(bool: false)
        Task{
            do {
                try await UserServices().changeInfoUser(user: user)
                DispatchQueue.main.async {
                    self.view?.showLoading(bool: false)
                    self.view?.create()
                    self.view?.showEnabledSaveBtn(bool: true)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showLoading(bool: false)
                    self.view?.showError(error: error)
                    self.view?.showEnabledSaveBtn(bool: true)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showLoading(bool: false)
                    self.view?.showError(error: "Попробуйте позже")
                    self.view?.showEnabledSaveBtn(bool: true)
                }
            }
        }
    }
    
}
