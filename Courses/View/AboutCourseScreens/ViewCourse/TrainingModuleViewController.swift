//
//  TrainingModuleViewController.swift
//  Courses
//
//  Created by Руслан on 27.01.2025.
//

import UIKit
import AVKit

protocol TrainingModuleViewDelegate {
    func showData()
    func showVideo()
    func showImage()
    func showTimer()
    func showError(error: String)
    func showSavedTraining(trainingItems: [TrainingSession])
}

class TrainingModuleViewController: UIViewController, TrainingModuleViewDelegate {
    
    @IBOutlet weak var timerCount: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var allHistoryBtn: UIButton!
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
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var repeats = [TrainingItem]()
    private var trainingItems = [TrainingSession]()
    private var moreTraining = false
    private var isTimer = false
    
    private var selectRepeats = 0 {
        didSet {
            if presenter.module.trainingItems.count == selectRepeats {
                selectRepeats = oldValue
            }else {
                reloadDataRepeats()
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
        presenter.view = self
        presenter.getData()
        presenter.getTraining()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
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
        trainingBtn.setImage(getTrainingImage(), for: .normal) 
        addViewByCountRepeats()
        trainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    func showVideo() {
        videoView.isHidden = false
        imView.isHidden = true
        timerView.isHidden = true
        if let videoURL = presenter.module.mediaURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showImage() {
        imView.isHidden = false
        videoView.isHidden = true
        timerView.isHidden = true
        im.sd_setImage(with: presenter.module.mediaURL)
    }
    
    func showTimer() {
        timerView.isHidden = false
        imView.isHidden = true
        videoView.isHidden = true
        if presenter.module.trainingItems[selectRepeats].firstItemType == .timer {
            timerCount.text = presenter.module.trainingItems[selectRepeats].firstItemData
        }else if presenter.module.trainingItems[selectRepeats].secondItemType == .timer {
            timerCount.text = presenter.module.trainingItems[selectRepeats].secondItemData
        }
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
    
    private func reloadDataRepeats() {
        let views = stackView.arrangedSubviews
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
    }
    
    private func initialTrainingBtn() {
        if presenter.module.trainingItems.count - 1 == selectRepeats {
            if isTimer == false {
                trainingBtn.setImage(UIImage.successTrainingModule, for: .normal)
            }
            trainingBtn.tag = 1
        }else {
            trainingBtn.tag = 0
            trainingBtn.setImage(getTrainingImage(), for: .normal)
        }
    }
    
    private func getTrainingImage() -> UIImage {
        guard let firstItem = presenter.module.trainingItems.first else {
            return UIImage.nextRepeats
        }
        
        let hasTimer = firstItem.firstItemType == .timer || firstItem.secondItemType == .timer
        isTimer = hasTimer
        return hasTimer ? UIImage.timerTrainingModule : UIImage.nextRepeats
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
        for _ in 0...presenter.module.trainingItems.count - 1 {
            let view = createView()
            stackView.addArrangedSubview(view)
        }
        reloadDataRepeats()
    }
    
    private func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = .extraLightBlackMain
        view.layer.cornerRadius = 3
        return view
    }
    
    private func settingsPlayer(videoURL: URL) {
        Task {
            let asset = AVAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerViewController.player = player
            setupView()
        }
    }
    
    private func setupView() {
        let layer = AVPlayerLayer(player: player)
        layer.frame = videoPlayerView.bounds
        layer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(layer)
    }
    
    private func toggleControlVideo(isPlay: Bool) {
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
            selectRepeats = 0
        }
    }
    
    private func endRepeat() {
        toggleTraining(isTraining: false)
        presenter.saveTraining()
        repeats.removeAll()
    }
    
    private func nextRepeats() {
        guard selectRepeats != presenter.module.trainingItems.count else { return }
        if repeats.count - 1 >= selectRepeats {
            repeats[selectRepeats] = presenter.module.trainingItems[selectRepeats]
        }else {
            repeats.append(presenter.module.trainingItems[selectRepeats])
        }
        
        if trainingBtn.tag == 1 {
            endRepeat()
        }else {
            selectRepeats += 1
        }
        
        trainingCollectionView.reloadData()
        changeHeightCollection()
    }

    
    
    // MARK: - @IBAction
    
    @IBAction func complete(_ sender: UIButton) {
        if isTimer {
            showTimer()
        }else {
            nextRepeats()
        }
    }
    
    @IBAction func startTraining(_ sender: UIButton) {
        toggleTraining(isTraining: true)
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            toggleControlVideo(isPlay: true)
        }else {
            toggleControlVideo(isPlay: false)
        }
    }
    
    @IBAction func allHistoryTraining(_ sender: UIButton) {
        moreTraining = true
        sender.isHidden = true
        savedTrainingCollectionView.reloadData()
        changeHeightCollection()
    }
    
    @IBAction func successTimer(_ sender: UIButton) {
        nextRepeats()
    }
    
    @IBAction func reloadTimer(_ sender: Any) {
    }
    
    @IBAction func playTimer(_ sender: UIButton) {
    }
    
    // MARK: - Other Action
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        present(playerViewController, animated: true) {
            self.player.play()
        }
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
