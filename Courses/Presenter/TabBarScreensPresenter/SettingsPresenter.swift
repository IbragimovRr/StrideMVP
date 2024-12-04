//
//  SettingsPresenter.swift
//  Courses
//
//  Created by Руслан on 05.12.2024.
//

import Foundation

protocol SettingsPresenterDelegate {
    func getMyInfo()
    func getObject()
    func viewWillApear()
}

class SettingsPresenter: SettingsPresenterDelegate {
    
    var view: SettingsViewDelegate?
    var user: UserModel = UserServices.info
    var arrayObjects = [Objects]()
    var arrayObjects2 = [Objects]()
    
    func viewWillApear() {
        getObject()
        getMyInfo()
    }
    
    func getMyInfo() {
        Task {
            user = try await UserServices().getMyInfo()
            DispatchQueue.main.async {
                self.view?.showProfile()
            }
        }
    }
    
    func getObject() {
        print(user.role)
        if user.role == .coach {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), Objects(name: "Добавить курс", image: "confirmAccount", imageForBtn: "next2"), Objects(name: "Кошелёк", image: "wallet", imageForBtn: "next2"), Objects(name: "Промокоды", image: "promoSettings", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }else if user.role == .user {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), /*Objects(name: "Подтвердить аккаунт", image: "confirmAccount", imageForBtn: "next2"),*/ Objects(name: "Стать тренером", image: "becomeCoach", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }else if user.role == .admin {
            arrayObjects = [Objects(name: "Информация о себе", image: "information", imageForBtn: "next2"), Objects(name: "Мои курсы", image: "coursesHistory", imageForBtn: "next2"), Objects(name: "Конфиденциальность", image: "confidentiality", imageForBtn: "next2"), Objects(name: "Админ панель", image: "adminPanel", imageForBtn: "next2")]
            arrayObjects2 = [Objects(name: "Нужна помощь? Напиши нам", image: "helper", imageForBtn: "next2"), Objects(name: "Политика конфиденциальности", image: "political", imageForBtn: "next2")]
        }
    }
    
}
