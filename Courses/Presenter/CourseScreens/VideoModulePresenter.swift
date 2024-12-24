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
    var module = Modules(name: "", minutes: 0, id: 0)
    
    func getModule() {
        module = Modules(videoURL: URL(string: "https://media-hosting.imagekit.io//dd6c1e7a10d344ac/38085aa0-25d9-4449-b4ec-3bc80fd4b468.MP4?Expires=1735217163&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=s0h71RvaTP1JiC4OAWgag-YxaEZXMnTAVmxjDy6dRZMx8yASaPIcVzVuJ0sUox-teVS8-KhBgQVNOs3rFnAumEnotixomqg5ISlLnDbGjLNN9hxGVS3UiuYwhauQlUoi041OhZ8zdnhFHOTYkuN-Mf2QlHbF3yGW-nW0KC1s8ao67Il9v~HVOEn0UPCRL4xIVu-gTiJRdTQrOAzzW~iOx64UjHkmO0D-IYow55wqDWLHi6V5U17caGv~3VGErGwSUKewnDPiw3R-mVkRGbR5vY6XRBbavrYTvE4OYe0TnzK3-GXtiJRvIQ6BCjkjQo24lgWY1bJ9zGAjU~F-SdXhow__"), name: "Видео модуль", minutes: 55, description: "leo messi", id: 10, isCompleted: true, position: 10, views: 550, timeVideo: 55, author: "Руслан Ибрагимов", videoDescription: "Качественное видео снятое в Москве", type: .video)
        view?.showData()
    }
    
    func nextModule() {
        print(22)
    }
}
