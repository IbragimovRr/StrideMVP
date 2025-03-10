//
//  VideoModuleViewController.swift
//  Courses
//
//  Created by Руслан on 22.12.2024.
//

import UIKit
import AVKit

class VideoModuleViewController: UIViewController {
    
    @IBOutlet weak var reloadView: UIView!
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
        toggleControlVideo(controll: .pause)
    }

    
    func showData() {
        authorName.text = module.author
        if module.timeVideo != 0 {
            time.text = "\(module.timeVideo) \(module.timeVideo.declinedWord(one: "минута", few: "минуты", many: "минут"))"
        }else {
            time.text = "< 1 минуты"
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
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
    
    @objc func videoDidFinish() {
        toggleControlVideo(controll: .reload)
    }
    
    func toggleControlVideo(controll: VideoControl) {
        if controll == .play {
            player.play()
            playView.isHidden = true
            fullScreenBtn.isHidden = false
            reloadView.isHidden = true
        }else if controll == .pause {
            player.pause()
            fullScreenBtn.isHidden = true
            playView.isHidden = false
            reloadView.isHidden = true
        }else {
            playView.isHidden = true
            fullScreenBtn.isHidden = true
            reloadView.isHidden = false
        }
    }
    
    
    @IBAction func playVideo(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            toggleControlVideo(controll: .play)
        }else {
            toggleControlVideo(controll: .pause)
        }
    }
    
    @IBAction func reloadVideo(_ sender: UIButton) {
        player.seek(to: .zero)
        toggleControlVideo(controll: .play)
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
