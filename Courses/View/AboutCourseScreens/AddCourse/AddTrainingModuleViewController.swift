//
//  AddTrainingModuleViewController.swift
//  Courses
//
//  Created by Руслан on 03.01.2025.
//

import UIKit
import AVKit

protocol AddTrainingModuleViewDelegate {
    func showData()
    func showVideo()
    func showImage()
    func showUploadMedia()
    func showError(error: String)
    func saveData()
}

class AddTrainingModuleViewController: UIViewController, AddTrainingModuleViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heigthCollection: NSLayoutConstraint!
    @IBOutlet weak var distanceView: Border!
    @IBOutlet weak var timerView: Border!
    @IBOutlet weak var repeatsView: Border!
    @IBOutlet weak var weightView: Border!
    @IBOutlet weak var imView: UIView!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var distanceImage: UIImageView!
    @IBOutlet weak var distanceBox: UIImageView!
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var timerBox: UIImageView!
    @IBOutlet weak var weightBox: UIImageView!
    @IBOutlet weak var weightImage: UIImageView!
    @IBOutlet weak var repeatsBox: UIImageView!
    @IBOutlet weak var repeatsImage: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var repeatsLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var descriptionView: Border!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var countDescription: UILabel!
    @IBOutlet weak var nameModule: UILabel!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTop: NSLayoutConstraint!
    @IBOutlet weak var descriptionRight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLeft: NSLayoutConstraint!
    @IBOutlet weak var changeMediaBtn: UIButton!
    @IBOutlet weak var countType: UILabel!
    @IBOutlet weak var trainingCollectionView: UICollectionView!
    @IBOutlet weak var applyBtn: UIButton!
    
    private let playerViewController = AVPlayerViewController()
    private var player = AVPlayer()
    let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    let presenter = AddTrainingModulePresenter()
    
    var selectTF = UITextField()
    var mediaURL: URL?
    var trainingItem: TrainingItem {
        get {
            return presenter.trainingItem
        }set {
            presenter.trainingItem = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainingCollectionView.delegate = self
        trainingCollectionView.dataSource = self
        descriptionText.delegate = self
        presenter.view = self
        view.addSubview(errorView)
        presenter.getModule()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        toggleControlVideo(isPlay: false)
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
        selectTF.scrollBottomText(scrollView: scrollView, notification: notification)
    }

    @objc func keyboardWillDisappear() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: true)
    }
    
    private func changeHeightCollection() {
        heigthCollection.constant = trainingCollectionView.contentSize.height
    }
    
    // MARK: - Protocol function
    
    func showData() {
        let module = presenter.module
        nameModule.text = module.module.name
        descriptionText.text = module.description
        updateCharCountLabel(count: descriptionText.text.count)
        updateFormatUI()
        trainingCollectionView.reloadData()
        trainingCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    func showVideo() {
        videoView.isHidden = false
        imView.isHidden = true
        changeMediaBtn.isHidden = false
        uploadView.isHidden = true
        if let videoURL = presenter.module.mediaURL {
            settingsPlayer(videoURL: videoURL)
        }
    }
    
    func showUploadMedia() {
        videoView.isHidden = true
        imView.isHidden = true
        changeMediaBtn.isHidden = true
        uploadView.isHidden = false
    }
    
    func showImage() {
        imView.isHidden = false
        videoView.isHidden = true
        changeMediaBtn.isHidden = false
        uploadView.isHidden = true
        im.sd_setImage(with: presenter.module.mediaURL)
    }
    
    func saveData() {
        navigationController?.popViewController(animated: true)
    }
    
    func showError(error: String) {
        errorView.configure(title: "Ошибка", description: error)
        errorView.isHidden = false
    }
    
    // MARK: - Private function
    
    private func hiddenTrainingItems() {
        if countType.text == "2/2" {
            trainingCollectionView.isHidden = false
            countType.isHidden = true
            trainingCollectionView.reloadData()
            isNotEnabledType()
        }else {
            trainingCollectionView.isHidden = true
            countType.isHidden = false
            isEnabledType()
        }
    }
    
    private func countTypeChange(){
        var count = 0
        if trainingItem.firstItemType != nil {
            count += 1
        }
        if trainingItem.secondItemType != nil {
            count += 1
        }
        countType.text = "\(count)/2"
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
    
    private func disabledTextWrite() {
        descriptionView.color = UIColor.clear
        let size = descriptionText.contentSize
        descriptionHeight.constant = size.height + 15
        descriptionText.isScrollEnabled = false
        descriptionText.resignFirstResponder()
        descriptionTop.constant = -20
        descriptionRight.constant = 10
        descriptionLeft.constant = 10
        applyBtn.isHidden = true
        countDescription.isHidden = true
    }
    
    private func enabledTextWrite() {
        descriptionView.color = UIColor.extraLightBlackMain
        descriptionHeight.constant = 175
        descriptionText.isScrollEnabled = true
        descriptionTop.constant = 5
        descriptionRight.constant = 30
        descriptionLeft.constant = 30
        applyBtn.isHidden = false
        countDescription.isHidden = false
    }
    
    private func formatAdd(type: FormatTraining) {
        if trainingItem.firstItemType != nil && trainingItem.secondItemType != nil {
            return
        }
        if trainingItem.firstItemType == nil {
            trainingItem.firstItemType = type
        }else if trainingItem.secondItemType == nil {
            trainingItem.secondItemType = type
        }
    }
    
    private func formatDelete(type: FormatTraining) {
        if trainingItem.firstItemType == type {
            trainingItem.firstItemType = nil
        }else if trainingItem.secondItemType == type {
            trainingItem.secondItemType = nil
        }
    }
    
    private func isEnabledType() {
        if trainingItem.firstItemType != .weight && trainingItem.secondItemType != .weight {
            weightLbl.textColor = UIColor.grayMain
            weightImage.image = UIImage.weight
        }
        if trainingItem.firstItemType != .repeats && trainingItem.secondItemType != .repeats {
            repeatsLbl.textColor = UIColor.grayMain
            repeatsImage.image = UIImage.repeats
        }
        if trainingItem.firstItemType != .timer && trainingItem.secondItemType != .timer {
            timerLbl.textColor = UIColor.grayMain
            timerImage.image = UIImage.timer
        }
        if trainingItem.firstItemType != .distance && trainingItem.secondItemType != .distance {
            distanceLbl.textColor = UIColor.grayMain
            distanceImage.image = UIImage.distance
        }
    }
    
    private func isNotEnabledType() {
        if trainingItem.firstItemType != .weight && trainingItem.secondItemType != .weight {
            weightLbl.textColor = UIColor.extraLightBlackMain
            weightImage.image = UIImage.weightUnselect
        }
        if trainingItem.firstItemType != .repeats && trainingItem.secondItemType != .repeats {
            repeatsLbl.textColor = UIColor.extraLightBlackMain
            repeatsImage.image = UIImage.repeatsUnselect
        }
        if trainingItem.firstItemType != .timer && trainingItem.secondItemType != .timer {
            timerLbl.textColor = UIColor.extraLightBlackMain
            timerImage.image = UIImage.timerUnselect
        }
        if trainingItem.firstItemType != .distance && trainingItem.secondItemType != .distance {
            distanceLbl.textColor = UIColor.extraLightBlackMain
            distanceImage.image = UIImage.distanceUnselect
        }
    }
    
    private func updateFormatUI() {
        unselectAllType()
        countTypeChange()
        hiddenTrainingItems()
        if trainingItem.firstItemType == .weight || trainingItem.secondItemType == .weight {
            selectType(type: .weight)
        }
        if trainingItem.firstItemType == .repeats || trainingItem.secondItemType == .repeats {
            selectType(type: .repeats)
        }
        if trainingItem.firstItemType == .timer || trainingItem.secondItemType == .timer {
            selectType(type: .timer)
        }
        if trainingItem.firstItemType == .distance || trainingItem.secondItemType == .distance {
            selectType(type: .distance)
        }
    }
    
    private func selectType(type: FormatTraining) {
        switch type {
        case .weight:
            weightBox.image = UIImage.boxSelect
            weightLbl.textColor = UIColor.blueMain
            weightImage.image = UIImage.weightSelect
            weightView.color = UIColor.blueMain
            weightView.backgroundColor = UIColor.extraLightBlueMain
        case .repeats:
            repeatsBox.image = UIImage.boxSelect
            repeatsLbl.textColor = UIColor.blueMain
            repeatsImage.image = UIImage.repeatsSelect
            repeatsView.color = UIColor.blueMain
            repeatsView.backgroundColor = UIColor.extraLightBlueMain
        case .timer:
            timerBox.image = UIImage.boxSelect
            timerLbl.textColor = UIColor.blueMain
            timerImage.image = UIImage.timerSelect
            timerView.color = UIColor.blueMain
            timerView.backgroundColor = UIColor.extraLightBlueMain
        case .distance:
            distanceBox.image = UIImage.boxSelect
            distanceLbl.textColor = UIColor.blueMain
            distanceImage.image = UIImage.distanceSelect
            distanceView.color = UIColor.blueMain
            distanceView.backgroundColor = UIColor.extraLightBlueMain
        }
    }
    
    private func unselectAllType() {
        weightBox.image = UIImage.box
        weightLbl.textColor = UIColor.grayMain
        weightImage.image = UIImage.weight
        weightView.color = UIColor.extraLightBlackMain
        weightView.backgroundColor = UIColor.clear
        repeatsBox.image = UIImage.box
        repeatsLbl.textColor = UIColor.grayMain
        repeatsImage.image = UIImage.repeats
        repeatsView.color = UIColor.extraLightBlackMain
        repeatsView.backgroundColor = UIColor.clear
        timerBox.image = UIImage.box
        timerLbl.textColor = UIColor.grayMain
        timerImage.image = UIImage.timer
        timerView.color = UIColor.extraLightBlackMain
        timerView.backgroundColor = UIColor.clear
        distanceBox.image = UIImage.box
        distanceLbl.textColor = UIColor.grayMain
        distanceImage.image = UIImage.distance
        distanceView.color = UIColor.extraLightBlackMain
        distanceView.backgroundColor = UIColor.clear
    }
    
    private func toggleFormatSelection(type: FormatTraining) {
        if trainingItem.firstItemType == type || trainingItem.secondItemType == type {
            formatDelete(type: type)
        } else {
            formatAdd(type: type)
        }
    }
    
    private func initialTrainingModule() -> Result<Void, ErrorNetwork> {
        guard let mediaURL = presenter.module.mediaURL else { return .failure(ErrorNetwork.runtimeError("Добавьте медиа файл")) }
        guard descriptionText.text != "" else { return .failure(ErrorNetwork.runtimeError("Добавьте описание тренировки")) }
        guard presenter.module.trainingItems.isEmpty == false else { return .failure(ErrorNetwork.runtimeError("Добавьте подходы для тренировки")) }
        guard trainingItem.firstItemType != nil && trainingItem.secondItemType != nil else {
            return .failure(ErrorNetwork.runtimeError("Выберите формат тренировки"))
        }
        presenter.module.mediaURL = mediaURL
        presenter.module.description = descriptionText.text
        return .success(())
    }
    
    // MARK: - @IBAction
    
    @IBAction func save(_ sender: UIButton) {
        switch initialTrainingModule() {
        case .failure(ErrorNetwork.runtimeError(let error)):
            showError(error: error)
        case .success():
            presenter.saveModule()
        case .failure(.tryAgainLater):
            break
        case .failure(.notFound):
            break
        }
    }
    
    @IBAction func uploadMediaFile(_ sender: UIButton) {
        let privacy = Privacy().checkPhotoLibraryAuthorization()
        if privacy {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.image", "public.movie"]
            present(imagePickerController, animated: true)
        }
    }
    
    @IBAction func selectFormatType(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            toggleFormatSelection(type: .weight)
        case 1:
            toggleFormatSelection(type: .repeats)
        case 2:
            toggleFormatSelection(type: .timer)
        case 3:
            toggleFormatSelection(type: .distance)
        default:
            break
        }
        updateFormatUI()
    }
    
    @IBAction func applyDescription(_ sender: UIButton) {
        if descriptionText.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            disabledTextWrite()
        }
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
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender)
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        present(playerViewController, animated: true) {
            self.player.play()
        }
    }
    
}
extension AddTrainingModuleViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            mediaURL = videoURL
            presenter.uploadMedia(media: videoURL, isVideo: true)
            dismiss(animated: true)
        }
        
        if let image = info[.imageURL] as? URL {
            mediaURL = image
            presenter.uploadMedia(media: image, isVideo: false)
            dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
extension AddTrainingModuleViewController: UITextViewDelegate, UITextFieldDelegate {
    
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
        countDescription.text = "\(count)/\(400)"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectTF = textField
    }
    
}
extension AddTrainingModuleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Создание ячеек
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.module.trainingItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddRepeats", for: indexPath) as! RepeatsCollectionViewCell
        
        if indexPath.row == presenter.module.trainingItems.count {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddRepeats", for: indexPath) as! RepeatsCollectionViewCell
            
        }else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "repeats", for: indexPath) as! RepeatsCollectionViewCell
            let module = presenter.module
            cell.firstItemType.text = module.trainingItems[indexPath.row].firstItemType?.initialDefaultName
            cell.secondItemType.text = module.trainingItems[indexPath.row].secondItemType?.initialDefaultName
            cell.firstItemTF.text = module.trainingItems[indexPath.row].firstItemData
            cell.secondItemTF.text = module.trainingItems[indexPath.row].secondItemData
            cell.firstItemTF.delegate = self
            cell.secondItemTF.delegate = self
            cell.numbers.text = "\(indexPath.row + 1)"
            cell.onTextChangedFirst = { [weak self] text in
                self?.presenter.module.trainingItems[indexPath.row].firstItemData = text
            }
            cell.onTextChangedSecond = { [weak self] text in
                self?.presenter.module.trainingItems[indexPath.row].secondItemData = text
            }
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPath.row != presenter.module.trainingItems.count else {return nil}
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteItem(at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
        
        return configuration
    }
    
    // MARK: - Удаление элемента
    
    func deleteItem(at indexPath: IndexPath) {
        presenter.module.trainingItems.remove(at: indexPath.row)
        trainingCollectionView.reloadData()
    }

    // MARK: - Добавление элемента
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == presenter.module.trainingItems.count {
            guard limitItems() else { return }
            presenter.module.trainingItems.append(trainingItem)
            trainingCollectionView.reloadData()
            trainingCollectionView.layoutIfNeeded()
            changeHeightCollection()
        }
    }
    
    private func limitItems() -> Bool {
        if presenter.module.trainingItems.count >= 15 {
            showError(error: "Вы достигли максимального количества повторений для текущего упражнения.")
            return false
        }else {
            return true
        }
    }
    
}
