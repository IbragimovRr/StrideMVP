//
//  AddVideoModuleViewController.swift
//  Courses
//
//  Created by Руслан on 27.12.2024.
//

import UIKit
import AVKit
import Lottie

protocol AddVideoViewDelegate {
    func showData()
    func showVideo()
    func showUploadVideo()
    func saveData()
    func showLoading(isLoading: Bool)
    func showError(error: String)
}

class AddVideoModuleViewController: UIViewController, AddVideoViewDelegate {
    
    @IBOutlet weak var reloadView: UIView!
    @IBOutlet weak var changeVideo: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var descriptionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var countCharacters: UILabel!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var authorText: UILabel!
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
    private var playerLayer = AVPlayerLayer()
    private var isLoaded = false
    let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        descriptionText.delegate = self
        view.layer.makeHiddenOnCapture()
        view.addSubview(errorView)
        loadingSettings()
        presenter.checkUpload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoPlayerView.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(controll: .pause)
    }
    
    // MARK: - Protocol
    
    func showData() {
        let module = presenter.module
        authorText.text = module.author
        if module.timeVideo != 0 {
            timeCount.text = "\(module.timeVideo) \(module.timeVideo.declinedWord(one: "минута", few: "минуты", many: "минут"))"
        }else {
            timeCount.text = "< 1 минуты"
        }
        nameModule.text = module.module.name
        descriptionText.text = module.videoDescription
        updateCharCountLabel(count: descriptionText.text.count)
    }
    
    func showVideo() {
        videoView.isHidden = false
        changeVideo.isHidden = false
        uploadView.isHidden = true
        if let videoURL = presenter.module.videoURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showUploadVideo() {
        changeVideo.isHidden = true
        videoView.isHidden = true
        uploadView.isHidden = false
    }
    
    
    func saveData() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showLoading(isLoading: Bool) {
        if isLoading {
            loading.play()
            loading.isHidden = false
            saveBtn.isHidden = true
            isLoaded = true
        }else {
            loading.stop()
            loading.isHidden = true
            saveBtn.isHidden = false
            isLoaded = false
        }
    }
    
    func showError(error: String) {
        errorView.configure(title: "Ошибка", description: error)
        errorView.isHidden = false
    }
    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = true
    }
    
    // MARK: - Player
    
    func settingsPlayer(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 5
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        player = AVPlayer(playerItem: playerItem)
        playerViewController.player = player
        player.automaticallyWaitsToMinimizeStalling = false
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        audioInitial()
        setupView()
    }
    
    func setupView() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(playerLayer)
    }
    
    func audioInitial() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    @objc func videoDidFinish() {
        toggleControlVideo(controll: .reload)
    }
    
    private func getTimeInVideo() -> Int {
        if let currentItem = player.currentItem {
            let duration = currentItem.duration
            let durationInSeconds = CMTimeGetSeconds(duration)
            if durationInSeconds.isFinite {
                let durationInMinutes = durationInSeconds / 60
                return Int(durationInMinutes)
            } else {
                return 0
            }
        }
        return 0
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
    
    
    
    private func initialModule() -> Result<Void, ErrorNetwork> {
        guard let _ = presenter.module.videoURL else { return .failure(ErrorNetwork.runtimeError("Добавьте видео файл")) }
        guard descriptionText.text != "" else { return .failure(ErrorNetwork.runtimeError("Добавьте описание тренировки")) }
        
        presenter.module.videoDescription = descriptionText.text
        let me = UD().getMyInfo()
        presenter.module.author = "\(me.name) \(me.surname)"
        presenter.module.timeVideo = getTimeInVideo()
        return .success(())
    }
    
    @IBAction func save(_ sender: UIButton) {
        switch initialModule() {
        case .success():
            presenter.saveModule()
        case .failure(ErrorNetwork.runtimeError(let error)):
            showError(error: error)
        case .failure(.tryAgainLater):
            break
        case .failure(.notFound):
            break
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
        if isLoaded {
            errorView.warningSave(self, title: "Загрузка еще не завершена")
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender)
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
        
        if newText.count <= 1000 {
            updateCharCountLabel(count: newText.count)
            return true
        }
        
        return false
    }
    
    func updateCharCountLabel(count: Int){
        countCharacters.text = "\(count)/\(1000)"
    }
    
}
