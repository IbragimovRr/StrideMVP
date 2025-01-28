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
    func showError(error: String)
}

class TrainingModuleViewController: UIViewController, TrainingModuleViewDelegate {
    
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
    @IBOutlet weak var heightCollection: NSLayoutConstraint!
    @IBOutlet weak var trainingCollectionView: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imView: UIView!
    @IBOutlet weak var im: UIImageView!
    
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var trainingItems = [TrainingItem]()
    
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
        trainingCollectionView.delegate = self
        trainingCollectionView.dataSource = self
        firstTF.delegate = self
        secondTF.delegate = self
        presenter.view = self
        presenter.getData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
    }
    
    private func changeHeightCollection() {
        heightCollection.constant = trainingCollectionView.contentSize.height
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
        trainingCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    func showVideo() {
        videoView.isHidden = false
        imView.isHidden = true
        if let videoURL = presenter.module.mediaURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showImage() {
        imView.isHidden = false
        videoView.isHidden = true
        im.sd_setImage(with: presenter.module.mediaURL)
    }
    
    func showError(error: String) {
        errorView.configure(title: "Ошибка", description: error)
        errorView.isHidden = false
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
            trainingBtn.setImage(UIImage.successTrainingModule, for: .normal)
            trainingBtn.tag = 1
        }else {
            trainingBtn.tag = 0
            trainingBtn.setImage(UIImage.nextRepeats, for: .normal)
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
        layer.frame = videoView.bounds
        layer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(layer)
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
        }
    }
    
    
    // MARK: - @IBAction
    
    @IBAction func complete(_ sender: UIButton) {
        guard selectRepeats != presenter.module.trainingItems.count else { return }
        if trainingItems.count - 1 >= selectRepeats {
            trainingItems[selectRepeats] = presenter.module.trainingItems[selectRepeats]
        }else {
            trainingItems.append(presenter.module.trainingItems[selectRepeats])
        }
        
        if sender.tag == 1 {
            toggleTraining(isTraining: false)
        }else {
            selectRepeats += 1
        }
        
        trainingCollectionView.reloadData()
        trainingCollectionView.layoutIfNeeded()
        changeHeightCollection()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "repeats", for: indexPath) as! RepeatsCollectionViewCell
        let module = presenter.module
        cell.firstItemType.text = trainingItems[indexPath.row].firstItemType?.initialDefaultName
        cell.secondItemType.text = trainingItems[indexPath.row].secondItemType?.initialDefaultName
        cell.firstItemTF.text = trainingItems[indexPath.row].firstItemData
        cell.secondItemTF.text = trainingItems[indexPath.row].secondItemData
        cell.numbers.text = "\(indexPath.row + 1)"
        cell.firstItemTF.isUserInteractionEnabled = false
        cell.secondItemTF.isUserInteractionEnabled = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
