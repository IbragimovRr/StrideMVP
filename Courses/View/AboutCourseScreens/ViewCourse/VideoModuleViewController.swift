//
//  VideoModuleViewController.swift
//  Courses
//
//  Created by Руслан on 22.12.2024.
//

import UIKit
import AVKit

class VideoModuleViewController: UIViewController {
    
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playImageControl: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var nameModule: UILabel!
    @IBOutlet weak var descriptionVideo: UITextView!
    
    var module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoPlayerView.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
    }

    
    func showData() {
        authorName.text = module.author
        time.text = "\(module.timeVideo) минут"
        nameModule.text = module.module.name
        descriptionVideo.text = module.videoDescription
        if let videoURL = module.videoURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func settingsPlayer(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 5
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        player = AVPlayer(playerItem: playerItem)
        playerViewController.player = player
        audioInitial()
        setupView()
    }
    
    func audioInitial() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Ошибка аудиосессии: \(error.localizedDescription)")
        }
    }
    
    func setupView() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(playerLayer)
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
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
