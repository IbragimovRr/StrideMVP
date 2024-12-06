//
//  CreatePromoPresenter.swift
//  Courses
//
//  Created by Руслан on 06.12.2024.
//

import Foundation

protocol CreatePromoPresenterDelegate {
    func createPromocode(promocode: PromocodeModel)
    func getProcents()
    func changePromocode()
    func deletePromocode()
}

class CreatePromoPresenter: CreatePromoPresenterDelegate {
    
    var view: CreatePromoViewDelegate?
    var procents = [Int]()
    var selectProcent: Int? = nil
    var promoCode: PromocodeModel? = nil
    
    
    func getProcents() {
        procents += [5,10,15,20,25,30]
    }
    
    func changePromocode() {
        selectProcent = getProcentByArray(procent: promoCode!.procent)
        self.view?.dateStart = promoCode!.dateStart
        self.view?.dateEnd = promoCode!.dateEnd
    }
    
    private func getProcentByArray(procent: Int) -> Int? {
        for x in 0...procents.count - 1 {
            if procents[x] == procent {
                return x
            }
        }
        return nil
    }
    
    func createPromocode(promocode: PromocodeModel) {
        Task {
            do {
                if promoCode == nil {
                    let promocode = try await PromocodesServices().createPromocode(promocode)
                    DispatchQueue.main.async {
                        self.view?.create(promoCode: promocode)
                    }
                }else {
                    let promocode = try await PromocodesServices().changePromocode(promocode)
                    DispatchQueue.main.async {
                        self.view?.change(promoCode: promocode)
                    }
                }
            }catch ErrorNetwork.runtimeError(var error) {
                DispatchQueue.main.async {
                    self.view?.showErrors(error: error)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showErrors(error: "Попробуйте позже")
                }
            }
        }
    }
    
    func deletePromocode() {
        Task {
            do {
                guard let promoCode = promoCode else { return }
                try await PromocodesServices().deletePromocode(promoCode)
                DispatchQueue.main.async {
                    self.view?.delete(promoCode: promoCode)
                }
            }catch ErrorNetwork.runtimeError(var error) {
                DispatchQueue.main.async {
                    self.view?.showErrors(error: error)
                }
            }catch {
                DispatchQueue.main.async {
                    self.view?.showErrors(error: "Попробуйте позже")
                }
            }
        }
    }
}
