//
//  VideoModuleViewController.swift
//  Courses
//
//  Created by Руслан on 22.12.2024.
//

import UIKit
import AVKit

protocol VideoModuleViewDelegate {
    func showData()
}

class VideoModuleViewController: UIViewController, VideoModuleViewDelegate {
    
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playImageControl: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var nameModule: UILabel!
    @IBOutlet weak var descriptionVideo: UITextView!
    
    var presenter = VideoModulePresenter()
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.getModule()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
    }

    
    func showData() {
        let module = presenter.module
        authorName.text = module.author
        views.text = "\(module.views) просмотров"
        time.text = "\(module.timeVideo) минут"
        nameModule.text = module.name
        descriptionVideo.text = module.videoDescription
        if let videoURL = module.videoURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func settingsPlayer(videoURL: URL) {
        Task {
            let asset = AVAsset(url: videoURL)

            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerViewController.player = player
            setupView()
        }
    }
    
    func setupView() {
        let layer = AVPlayerLayer(player: player)
        layer.frame = videoPlayerView.bounds
        layer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(layer)
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
    
    
    @IBAction func playVideo(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            toggleControlVideo(isPlay: true)
        }else {
            toggleControlVideo(isPlay: false)
        }
    }
    
    
    @IBAction func fullScreen(_ sender: UIButton) {
        present(playerViewController, animated: true) {
            self.player.play()
        }
    }
    
}
