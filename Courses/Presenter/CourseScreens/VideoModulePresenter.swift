//
//  VideoModulePresenter.swift
//  Courses
//
//  Created by Руслан on 23.12.2024.
//

import UIKit

protocol VideoModulePresenterDelegate {
    func getModule()
    func nextModule()
}

class VideoModulePresenter: VideoModulePresenterDelegate {
    
    var view: VideoModuleViewDelegate?
    var module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
    
    func getModule() {
        module = VideoModule(module: Modules(name: "Видео модуль", minutes: 55, id: 0, isCompleted: false, position: 0), videoURL: URL(string: "https://media-hosting.imagekit.io//4c008dd182064001/38085aa0-25d9-4449-b4ec-3bc80fd4b468.MP4?Expires=1735404633&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=x7Tz9obrnQK6PxX0xHSFnxS8uZ~FCe5OPiz6M126GQR4GVRQVL~R0FHXPSopj1VHCcBP3lcgo0fcRxZedHA3aCD38C-s3ZdqjhWYJvXUcDd5BHNrY~MLQJT6Prq7zNxJI-DeZ03idM36~nxun3qXN0KC3EmTkhwuEtRxzTGosgk5-5aiJELevq0iKdpJmoZ0dfLQ5QvwSjRK1ojOLtKuS~bSkNZr8T2~gnR070wK1A5K5IRBQ1DzpIu7z9KHlXHdoc8TwSwhBhL53GlbtM3NKsNJwHvSrSPYbU8xWse4rdZZi14TK65dLKY2ePvffnsHc30XlyWGDDONfV4mqv~Ayw__"), views: 550, timeVideo: 50, author: "Руслан Ибрагимов", videoDescription: "Качественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в МосквеКачественное видео снятое в Москве")
        view?.showData()
    }
    
    func nextModule() {
        print(22)
    }
}
