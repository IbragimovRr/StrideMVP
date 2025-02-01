//
//  AddVideoModuleViewController.swift
//  Courses
//
//  Created by Руслан on 27.12.2024.
//

import UIKit
import AVKit

protocol AddVideoViewDelegate {
    func showData()
    func showVideo()
    func showUploadVideo()
    func saveData()
}

class AddVideoModuleViewController: UIViewController, AddVideoViewDelegate {
    
    @IBOutlet weak var descriptionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var countCharacters: UILabel!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var authorText: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var timeCount: UILabel!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descriptionView: Border!
    @IBOutlet weak var nameModule: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoView: UIView!
    
    var presenter = AddVideoModulePresenter()
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        descriptionText.delegate = self
        presenter.checkUpload()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
    }
    
    func showData() {
        let module = presenter.module
        authorText.text = module.author
        timeCount.text = "\(module.timeVideo) минут"
        nameModule.text = module.module.name
        descriptionText.text = module.videoDescription
        updateCharCountLabel(count: descriptionText.text.count)
    }
    
    func showVideo() {
        videoView.isHidden = false
        uploadView.isHidden = true
        if let videoURL = presenter.module.videoURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showUploadVideo() {
        videoView.isHidden = true
        uploadView.isHidden = false
    }
    
    
    func saveData() {
        self.navigationController?.popViewController(animated: true)
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
    
    private func disabledTextWrite() {
        descriptionView.color = UIColor.clear
        let size = descriptionText.contentSize
        descriptionHeight.constant = size.height + 15
        descriptionText.isScrollEnabled = false
        descriptionText.resignFirstResponder()
        descriptionViewTopConstraint.constant = -20
        descriptionViewRightConstraint.constant = 10
        descriptionViewLeftConstraint.constant = 10
        applyBtn.isHidden = true
        countCharacters.isHidden = true
    }
    
    private func enabledTextWrite() {
        descriptionView.color = UIColor.extraLightBlackMain
        descriptionHeight.constant = 175
        descriptionText.isScrollEnabled = true
        descriptionViewTopConstraint.constant = 5
        descriptionViewRightConstraint.constant = 30
        descriptionViewLeftConstraint.constant = 30
        applyBtn.isHidden = false
        countCharacters.isHidden = false
    }
    
    private func initialModule() {
        presenter.module.videoDescription = descriptionText.text
    }
    
    @IBAction func save(_ sender: UIButton) {
        initialModule()
        presenter.saveModule()
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            toggleControlVideo(isPlay: true)
        }else {
            toggleControlVideo(isPlay: false)
        }
    }
    
    @IBAction func uploadVideo(_ sender: UIButton) {
        let privacy = Privacy().checkPhotoLibraryAuthorization()
        if privacy {
            let imagePickerController = UIImagePickerController()
            imagePickerController.mediaTypes = ["public.movie"]
            imagePickerController.delegate = self
            present(imagePickerController, animated: true)
        }
    }
    
    @IBAction func applyText(_ sender: UIButton) {
        if descriptionText.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            disabledTextWrite()
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
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        descriptionText.resignFirstResponder()
    }
    
}
extension AddVideoModuleViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            presenter.uploadVideo(videoURL: videoURL)
            dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
extension AddVideoModuleViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        enabledTextWrite()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else {
            return true
        }
        
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 400 {
            updateCharCountLabel(count: newText.count)
            return true
        }
        
        return false
    }
    
    func updateCharCountLabel(count: Int){
        countCharacters.text = "\(count)/\(400)"
    }
    
}
