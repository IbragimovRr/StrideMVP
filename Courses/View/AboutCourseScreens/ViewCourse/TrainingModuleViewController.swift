//
//  TrainingModuleViewController.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import UIKit
import AVKit

protocol TrainingModuleViewDelegate {
    var selectRepeats: Int { get set }
    var repeats: [TrainingItem] { get set }
    var content: ContentTrainingModule { get set }
    
    func showData()
    func showVideo()
    func showImage()
    func showTimer()
    func showError(error: String)
    func showSavedTraining(trainingItems: [TrainingSession])
    func endRepeats()
}

class TrainingModuleViewController: UIViewController, TrainingModuleViewDelegate {
    
    @IBOutlet weak var reloadView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var controlTimerBtn: UIButton!
    @IBOutlet weak var timerCount: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var allHistoryBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var savedTrainingCollectionView: UICollectionView!
    @IBOutlet weak var trainingBtn: UIButton!
    @IBOutlet weak var startTrainingBtn: UIButton!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var stackViewTF: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var descriptionModule: UITextView!
    @IBOutlet weak var trainingHeightCollection: NSLayoutConstraint!
    @IBOutlet weak var heightCollection: NSLayoutConstraint!
    @IBOutlet weak var trainingCollectionView: UICollectionView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imView: UIView!
    @IBOutlet weak var im: UIImageView!
    
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    private var timer = TimerTraining()
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var repeats = [TrainingItem]()
    private var trainingItems = [TrainingSession]()
    //Нажат ли просмотр всей истории тренировок
    private var moreTraining = false
    private var modeTimer: TimerMode = .timer
    
    var selectRepeats: Int = 0 {
        didSet {
            showSelectRepeat()
        }
    }

    var content: ContentTrainingModule = .next {
        didSet {
            switch content {
            case .timer:
                trainingBtn.setImage(UIImage.timerTrainingModule, for: .normal)
            case .next:
                trainingBtn.setImage(UIImage.nextRepeats, for: .normal)
            case .save:
                trainingBtn.setImage(UIImage.successTrainingModule, for: .normal)
            }
        }
    }
    
    var presenter = TrainingModulePresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        savedTrainingCollectionView.delegate = self
        savedTrainingCollectionView.dataSource = self
        trainingCollectionView.delegate = self
        trainingCollectionView.dataSource = self
        firstTF.delegate = self
        secondTF.delegate = self
        view.layer.makeHiddenOnCapture()
        presenter.view = self
        timer.delegate = self
        presenter.getData()
        presenter.getTraining()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoPlayerView.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(controll: .pause)
    }
    
    // Работа с клавиатурой
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillAppear(notification: Notification) {
        //Скролл до низа nextField c клавиатурой
        firstTF.scrollBottomText(scrollView: scrollView, notification: notification)
    }

    @objc func keyboardWillDisappear() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: true)
    }
    
    private func changeHeightCollection() {
        trainingCollectionView.layoutIfNeeded()
        savedTrainingCollectionView.layoutIfNeeded()
        heightCollection.constant = trainingCollectionView.contentSize.height
        trainingHeightCollection.constant = savedTrainingCollectionView.contentSize.height
    }
    
    // MARK: - Protocol func
    
    func showData() {
        let module = presenter.module
        name.text = module.module.name
        descriptionModule.text = module.description
        let size = descriptionModule.contentSize
        descriptionHeight.constant = size.height + 15
        addViewByCountRepeats()
        trainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    func showVideo() {
        videoView.isHidden = false
        imView.isHidden = true
        timerView.isHidden = true
        backBtn.backgroundColor = .lightBlackMain
        if let videoURL = presenter.module.mediaURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showImage() {
        imView.isHidden = false
        videoView.isHidden = true
        timerView.isHidden = true
        backBtn.backgroundColor = .lightBlackMain
        im.sd_setImage(with: presenter.module.mediaURL)
    }
    
    func showTimer() {
        timerView.isHidden = false
        imView.isHidden = true
        videoView.isHidden = true
        backBtn.backgroundColor = .clear
        initialTimer()
    }
    
    func showSelectRepeat() {
        let views = stackView.arrangedSubviews
        guard views.isEmpty == false else { return }
        
        for x in 0...views.count - 1 {
            if selectRepeats >= x {
                views[x].backgroundColor = .blueMain
            }else {
                views[x].backgroundColor = .extraLightBlackMain
            }
        }
        labelCount()
        initialTextField()
        initialTrainingBtn()
        trainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    func endRepeats() {
        content = .save
    }
    
    func showError(error: String) {
        errorView.configure(title: "Ошибка", description: error)
        errorView.isHidden = false
    }
    
    func showSavedTraining(trainingItems: [TrainingSession]) {
        if trainingItems.isEmpty {
            allHistoryBtn.isHidden = true
        }else {
            allHistoryBtn.isHidden = false
        }
        self.trainingItems = trainingItems
        savedTrainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    // MARK: - Private function
    private func initialTimer() {
        let item = presenter.module.trainingItems[selectRepeats]
        if item.firstItemType == .timer {
            timer.configure(seconds: Int(item.firstItemData ?? "0") ?? 0, mode: modeTimer)
        }else if item.secondItemType == .timer {
            timer.configure(seconds: Int(item.secondItemData ?? "0") ?? 0, mode: modeTimer)
        }
    }
    
    private func chechkEndRepeats() {
        if presenter.module.trainingItems.count - 1 == selectRepeats {
            content = .save
        }else {
            content = .next
        }
    }
    
    private func initialTrainingBtn() {
        guard let firstItem = presenter.module.trainingItems.first else { return }
        
        if firstItem.firstItemType == .timer || firstItem.secondItemType == .timer {
            content = .timer
        }else {
            chechkEndRepeats()
        }
    }
    
    
    private func labelCount() {
        let select = selectRepeats + 1
        let count = presenter.module.trainingItems.count
        countLbl.text = "\(select) из \(count)"
    }

    
    private func initialTextField() {
        let item = presenter.module.trainingItems[selectRepeats]
        
        firstTF.resignFirstResponder()
        secondTF.resignFirstResponder()
        
        if let firstData = item.firstItemData {
            firstTF.text = "\(firstData) \(item.firstItemType?.trainingName ?? "повторов")"
        }
        if let secondData = item.secondItemData {
            secondTF.text = "\(secondData) \(item.secondItemType?.trainingName ?? "повторов")"
        }
    }
    
    private func addViewByCountRepeats() {
        guard presenter.module.trainingItems.isEmpty == false else { return }
        for _ in 0...presenter.module.trainingItems.count - 1 {
            let view = createView()
            stackView.addArrangedSubview(view)
        }
    }
    
    private func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = .extraLightBlackMain
        view.layer.cornerRadius = 3
        return view
    }
    
    func settingsPlayer(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 5
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
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
    
    private func toggleTraining(isTraining: Bool) {
        if isTraining {
            stackView.isHidden = false
            stackViewTF.isHidden = false
            countLbl.isHidden = false
            startTrainingBtn.isHidden = true
        }else {
            stackView.isHidden = true
            stackViewTF.isHidden = true
            countLbl.isHidden = true
            startTrainingBtn.isHidden = false
            presenter.restartTraining()
        }
    }
    
    private func saveTraining() {
        toggleTraining(isTraining: false)
        presenter.saveTraining()
        repeats.removeAll()
        trainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    
    // MARK: - @IBAction
    
    @IBAction func complete(_ sender: UIButton) {
        switch content {
        case .timer:
            showTimer()
        case .next:
            presenter.nextRepeat()
        case .save:
            saveTraining()
        }
    }
    
    @IBAction func toggleTimerMode(_ sender: UIButton) {
        if modeTimer == .timer {
            modeTimer = .stopwatch
            sender.setImage(UIImage.timer2, for: .normal)
        }else {
            modeTimer = .timer
            sender.setImage(UIImage.secundomer, for: .normal)
        }
        initialTimer()
    }
    
    @IBAction func startTraining(_ sender: UIButton) {
        toggleTraining(isTraining: true)
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
    
    @IBAction func allHistoryTraining(_ sender: UIButton) {
        moreTraining = true
        sender.isHidden = true
        savedTrainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    @IBAction func successTimer(_ sender: UIButton) {
        // Убирает таймер и добавляет картинку или видео
        if let mediaURL = presenter.module.mediaURL {
            presenter.checkType(media: mediaURL)
        }
        chechkEndRepeats()
        timer.stop()
    }
    
    @IBAction func reloadTimer(_ sender: Any) {
        timer.reload()
    }
    
    @IBAction func playTimer(_ sender: UIButton) {
        if timer.control == .pause {
            timer.start()
        }else if timer.control == .process {
            timer.stop()
        }
    }
    
    // MARK: - Other Action
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        firstTF.resignFirstResponder()
        secondTF.resignFirstResponder()
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        present(playerViewController, animated: true) {
            self.player.play()
        }
    }
}
extension TrainingModuleViewController: TimerDelegate {
    
    func timerDidStart() {
        controlTimerBtn.setImage(UIImage.pauseTimer, for: .normal)
    }
    
    func timerDidControlState(state: TimerState) {
        switch state {
        case .pause:
            controlTimerBtn.setImage(UIImage.playTimer, for: .normal)
        case .process:
            controlTimerBtn.setImage(UIImage.pauseTimer, for: .normal)
        case .end:
            controlTimerBtn.setImage(UIImage.playTimer, for: .normal)
        case .reload:
            break
        case .next:
            break
        }
    }
    
    func timerDidUpdate(resultData: String) {
        timerCount.text = resultData
    }
}
extension TrainingModuleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if savedTrainingCollectionView == collectionView {
            if !moreTraining && !trainingItems.isEmpty { return 1 }
            return trainingItems.count
        }else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dateHeader", for: indexPath) as! DateHeaderCollectionReusableView
        cell.date.text = trainingItems[indexPath.section].date.formattedDayMonth()
        cell.isFirstSection(index: indexPath.section)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == savedTrainingCollectionView {
            return trainingItems[section].items.count
        }else {
            return repeats.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "repeats", for: indexPath) as! RepeatsCollectionViewCell
        
        
        if collectionView == savedTrainingCollectionView {
            let item = trainingItems[indexPath.section].items[indexPath.row]
            cell.firstItemType.text = FormatTraining(rawValue: item.firstItemType ?? "REPEATS")?.initialDefaultName
            cell.secondItemType.text = FormatTraining(rawValue: item.secondItemType ?? "REPEATS")?.initialDefaultName
            cell.firstItemTF.text = item.firstItemData
            cell.secondItemTF.text = item.secondItemData
        }else {
            let item = repeats[indexPath.row]
            cell.firstItemType.text = item.firstItemType?.initialDefaultName
            cell.secondItemType.text = item.secondItemType?.initialDefaultName
            cell.firstItemTF.text = item.firstItemData
            cell.secondItemTF.text = item.secondItemData
        }
        cell.numbers.text = "\(indexPath.row + 1)"
        cell.firstItemTF.isUserInteractionEnabled = false
        cell.secondItemTF.isUserInteractionEnabled = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == trainingCollectionView else { return }
        selectRepeats = indexPath.row
    }
    
    
}
extension TrainingModuleViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == firstTF {
            textField.text = presenter.module.trainingItems[selectRepeats].firstItemData
        }else {
            textField.text = presenter.module.trainingItems[selectRepeats].secondItemData
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        if textField == firstTF {
            presenter.module.trainingItems[selectRepeats].firstItemData = updatedText
        } else {
            presenter.module.trainingItems[selectRepeats].secondItemData = updatedText
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        initialTextField()
    }
}
