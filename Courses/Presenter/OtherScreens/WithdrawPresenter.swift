//
//  WithdrawPresenter.swift
//  Courses
//
//  Created by Руслан on 06.12.2024.
//

import Foundation

protocol WithdrawPresenterDelegate {
    func getBanks()
    func fluentSBP(money: Int, selectMoney: Int, number: String, bank: String)
    func fluent(money: Int, selectMoney: Int, cardFormat: String)
}

class WithdrawPresenter: WithdrawPresenterDelegate {
    
    var view: WithdrawViewDelegate?
    var money = 0
    var arrayBanks = [Banks]()
    
    func getBanks() {
        arrayBanks = [Banks(name: "Сбербанк", image: ""), Banks(name: "Т-Банк", image: ""), Banks(name: "АльфаБанк", image: ""), Banks(name: "ГазПромБанк", image: "")]
        view?.showBank()
    }
    
    func fluentSBP(money: Int, selectMoney: Int, number: String, bank: String) {
        view?.showEnableFinish(bool: false)
        Task {
            do {
                let sbp: PaymentMethod = .sbp(phoneNumber: number, amount: selectMoney, bank: bank)
                try await PaymentServices().fetchFunds(payment: sbp)
                DispatchQueue.main.async {
                    self.view?.showEnableFinish(bool: true)
                    let result = money - selectMoney
                    self.money = result
                    self.view?.showSuccess(money: result)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.showEnableFinish(bool: true)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                    self.view?.showEnableFinish(bool: true)
                }
            }
        }
    }
    
    func fluent(money: Int, selectMoney: Int, cardFormat: String) {
        view?.showEnableFinish(bool: false)
        Task {
            do {
                let card: PaymentMethod = .card(cardNumber: cardFormat, amount: selectMoney)
                try await PaymentServices().fetchFunds(payment: card)
                DispatchQueue.main.async {
                    self.view?.showEnableFinish(bool: true)
                    let result = money - selectMoney
                    self.money = result
                    self.view?.showSuccess(money: result)
                }
            }catch ErrorNetwork.runtimeError(let error) {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                    self.view?.showEnableFinish(bool: true)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: "Попробуйте позже")
                    self.view?.showEnableFinish(bool: true)
                }
            }
        }
    }
    
    
}
