//
//  Player.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import Foundation
import AVKit

class Player {
    var player = AVPlayer()
    let playerViewController = AVPlayerViewController()
    var videoPlayerView = UIView()
    var playView = UIView()
    var fullScreenBtn = UIButton()
    var vc = UIViewController()
    
    init(videoPlayerView: UIView, playView: UIView, fullScreenBtn: UIButton, vc: UIViewController) {
        self.videoPlayerView = videoPlayerView
        self.playView = playView
        self.fullScreenBtn = fullScreenBtn
        self.vc = vc
        set
    }
    
    private func setupView() {
        let layer = AVPlayerLayer(player: player)
        layer.frame = videoPlayerView.bounds
        layer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(layer)
    }
    
    func showVideo(url: URL) {
        Task {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerViewController.player = player
        }
    }
    
    func toggleControlVideo(isPlay: Bool) {
        if isPlay {
            player.play()
            playView.isHidden = true
            fullScreenBtn.isHidden = false
        }else {
            player.pause()
            fullScreenBtn.isHidden = true
            playView.isHidden = false
        }
    }
    
    func fullScreen() {
        vc.present(playerViewController, animated: true) {
            self.player.play()
        }
    }
    
}
