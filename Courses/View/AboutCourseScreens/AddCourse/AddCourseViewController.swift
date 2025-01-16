//
//  AddCourseViewController.swift
//  Courses
//
//  Created by Руслан on 25.06.2024.
//

import UIKit
import SwiftyJSON
import Alamofire
import Lottie
import WebKit

protocol AddCoursePresenterViewDelegate {
    func isLoading(_ bool: Bool)
    func setData(html: String)
    func saveCourse()
    func setError(_ error: String)
    func setImage(_ size: CGSize, url: URL)
}

class AddCourseViewController: UIViewController, AddCoursePresenterViewDelegate {
    
    
    @IBOutlet weak var fontCollectionView: UICollectionView!
    @IBOutlet weak var editorBackView: UIView!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourseLBL: UILabel!
    @IBOutlet weak var mainEditorView: UIView!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var bottomConsoleView: NSLayoutConstraint!
    
    // Text editor Format
    @IBOutlet weak var alingment: UIButton!
    @IBOutlet weak var isUnderline: UIButton!
    @IBOutlet weak var isStrikeThrough: UIButton!
    @IBOutlet weak var isItalic: UIButton!
    @IBOutlet weak var isBold: UIButton!
    @IBOutlet weak var redo: UIButton!
    @IBOutlet weak var undo: UIButton!
    
    
    var editor = EditorView()
    var presenter = AddCoursePresenter()
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    var fonts = [
            "Arial",
            "Helvetica",
            "Times New Roman",
            "Courier New",
            "Verdana",
            "Georgia",
            "Impact",
            "Comic Sans MS",
            "Trebuchet MS"
        ]
    var selectedFontIndex = 2 {
        didSet {
            editor.font(fonts[selectedFontIndex])
        }
    }
    private var isChangedText = false
    private var isSave = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .dark
        fontCollectionView.delegate = self
        fontCollectionView.dataSource = self
        fontCollectionView.collectionViewLayout = CarouselLayout()
        presenter.view = self
//        getData()
        design()
        setupRichEditorView()
        loadingSettings()
        startPosition = errorView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCenterCell()
    }
    
    @objc func keyboardWillAppear(notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomConsoleView.constant = keyboardHeight - 30
        }
    }
    
    @objc func keyboardWillDisappear() {
        bottomConsoleView.constant = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        presenter.deleteAlamofireFiles()
    }
    
    func setupRichEditorView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "format")
        webConfiguration.userContentController = contentController
        editor = EditorView(frame: .zero, configuration: webConfiguration)
        editor.delegate = self
        editor.scrollView.showsVerticalScrollIndicator = false
        editor.scrollView.showsHorizontalScrollIndicator = false
        editor.translatesAutoresizingMaskIntoConstraints = false
        editor.isOpaque = false
        editorBackView.addSubview(editor)
        
        
        NSLayoutConstraint.activate([
            editor.topAnchor.constraint(equalTo: editorBackView.topAnchor),
            editor.bottomAnchor.constraint(equalTo: editorBackView.bottomAnchor),
            editor.trailingAnchor.constraint(equalTo: editorBackView.trailingAnchor),
            editor.leadingAnchor.constraint(equalTo: editorBackView.leadingAnchor)
        ])
    }

    
    func isLoading(_ bool: Bool) {
        if bool {
            loading.play()
            loading.isHidden = false
        }else {
            loading.stop()
            loading.isHidden = true
        }
    }
    
    func setData(html: String) {
        editor.html = html
    }
    
    func saveCourse() {
        isSave = true
    }
    
    func setError(_ error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
        view.addSubview(errorView)
        isLoading(false)
    }
    
    func setImage(_ size: CGSize, url: URL) {
        let widthInt = Int(size.width)
        let heightInt = Int(size.height)
        editor.insertImage(url: url.absoluteString, alt: "image", width: widthInt, height: heightInt)
    }
    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
    }
    
    private func design() {
        nameCourseLBL.text = presenter.module.module.name
    }
    
    private func toggleFontView(isShow: Bool) {
        if isShow {
            fontView.isHidden = false
            mainEditorView.isHidden = true
        }else {
            fontView.isHidden = true
            mainEditorView.isHidden = false
        }
    }
    
    private func changedAlignment(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            alingment.setImage(UIImage.leftTextFull, for: .normal)
            alingment.tag = 1
            editor.justify(.left)
        case .center:
            alingment.setImage(UIImage.centerTextFull, for: .normal)
            alingment.tag = 2
            editor.justify(.center)
        case .right:
            alingment.setImage(UIImage.rightTextFull, for: .normal)
            alingment.tag = 3
            editor.justify(.right)
        case .justified:
            alingment.setImage(UIImage.defaultTextFull, for: .normal)
            alingment.tag = 0
            editor.justify(.justified)
        default:
            break
        }
    }
    
    private func checkUndoRedo() {
        if editor.undoManager?.canUndo == true {
            undo.setImage(UIImage.undoFill, for: .normal)
        }else {
            undo.setImage(UIImage.undo, for: .normal)
        }
        
        if editor.undoManager?.canRedo == true {
            redo.setImage(UIImage.rendoFill, for: .normal)
        }else {
            redo.setImage(UIImage.rendo, for: .normal)
        }
    }
    
    private func toggleFontName(_ sender: UIButton) {
        if fontCollectionView.isHidden {
            fontCollectionView.isHidden = false
            sender.backgroundColor = .extraLightBlackMain
            editor.focus()
        }else {
            fontCollectionView.isHidden = true
            sender.backgroundColor = .clear
        }
    }
    
    func scrollToCenterCell() {
        let indexPath = IndexPath(row: selectedFontIndex, section: 0)
        
        fontCollectionView.layoutIfNeeded()
        if let attributes = fontCollectionView.layoutAttributesForItem(at: indexPath) {
            let center = CGPoint(x: attributes.center.x - fontCollectionView.bounds.width / 2, y: 0)
            fontCollectionView.setContentOffset(center, animated: false)
            fontCollectionView.reloadData()
        }
    }

    
    private func warningSave() {
        let alert = UIAlertController(title: "Вы не сохранили изменения", message: "Вы точно хотите выйти?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Выйти", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }


    
    // MARK: - UIButton
    
    @IBAction func closeFontView(_ sender: Any) {
        toggleFontView(isShow: false)
        checkUndoRedo()
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
        editor.resignFirstResponder()
        editor.getHtml(handler: { res in
            print(res)
        })
//        presenter.saveCourse(html: nil)
    }
    
    
    @IBAction func attributesFontBtn(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            toggleFontName(sender)
        case 1: // FontSize
            break
        case 2:
            editor.bold()
        case 3:
            editor.italic()
        case 4:
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        case 5:
            editor.strikeThrough()
        case 6:
            editor.underline()
        case 7:
            editor.blockquote()
        default:
            break
        }
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let privacy = Privacy().checkPhotoLibraryAuthorization()
        if privacy {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            present(imagePickerController, animated: true)
        }
    }
    
    @IBAction func changedText(_ sender: UIButton) {
        toggleFontView(isShow: true)
        isChangedText = true
    }
    
    
    @IBAction func undo(_ sender: UIButton) {
        if sender.tag == 0 {
            editor.undo()
        }else {
            editor.redo()
        }
        checkUndoRedo()
    }
    
    @IBAction func alignment(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            changedAlignment(.left)
            sender.tag = 1
        case 1:
            changedAlignment(.center)
            sender.tag = 2
        case 2:
            changedAlignment(.right)
            sender.tag = 3
        case 3:
            changedAlignment(.justified)
            sender.tag = 0
        default:
            break
        }
    }
    
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    @IBAction func back(_ sender: UIButton) {
        if isSave == false {
            warningSave()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
extension AddCourseViewController: WKScriptMessageHandler, EditorViewDelegate {
    
    func format(isBold: Bool, isItalic: Bool, isUnderline: Bool, isStrikethrough: Bool, isBlockquote: Bool, aligment: NSTextAlignment) {
        changedAlignment(aligment)
        if isBold { self.isBold.backgroundColor = .extraLightBlackMain}
        else { self.isBold.backgroundColor = .clear }
        if isItalic { self.isItalic.backgroundColor = .extraLightBlackMain}
        else { self.isItalic.backgroundColor = .clear }
        if isUnderline { self.isUnderline.backgroundColor = .extraLightBlackMain}
        else { self.isUnderline.backgroundColor = .clear }
        if isStrikethrough { self.isStrikeThrough.backgroundColor = .extraLightBlackMain}
        else { self.isStrikeThrough.backgroundColor = .clear }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "format" {
            editor.initialFormat(message: message)
        }
    }
    
}

// MARK: - Image
extension AddCourseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            presenter.resizeImage(image: image, url: url)
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    
}
// MARK: - Font
extension AddCourseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "font", for: indexPath) as! FontCollectionViewCell
        
        var isHighlighted = false
        if selectedFontIndex == indexPath.row {
            isHighlighted = true
        }
        
        cell.configure(with: fonts[indexPath.row], isHighlighted: isHighlighted)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = fontCollectionView.collectionViewLayout as! CarouselLayout
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        
        var minDistance = CGFloat.infinity
        var closestIndex = 0
        
        for i in 0..<fonts.count {
            if let attributes = layout.layoutAttributesForItem(at: IndexPath(item: i, section: 0)) {
                let distance = abs(attributes.center.x - centerX)
                if distance < minDistance {
                    minDistance = distance
                    closestIndex = i
                }
            }
        }
        
        if closestIndex != selectedFontIndex {
            selectedFontIndex = closestIndex
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            fontCollectionView.reloadData()
        }
    }

}
extension AddCourseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "font", for: indexPath) as! FontCollectionViewCell
        
        var isHighlighted = false
        if selectedFontIndex == indexPath.row {
            isHighlighted = true
        }
        
        cell.configure(with: fonts[indexPath.row], isHighlighted: isHighlighted)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = fontCollectionView.collectionViewLayout as! CarouselLayout
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        
        var minDistance = CGFloat.infinity
        var closestIndex = 0
        
        for i in 0..<fonts.count {
            if let attributes = layout.layoutAttributesForItem(at: IndexPath(item: i, section: 0)) {
                let distance = abs(attributes.center.x - centerX)
                if distance < minDistance {
                    minDistance = distance
                    closestIndex = i
                }
            }
        }
        
        if closestIndex != selectedFontIndex {
            selectedFontIndex = closestIndex
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            fontCollectionView.reloadData()
        }
    }

}
// MARK: - Color
extension AddCourseViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        editor.textColor(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        editor.textColor(viewController.selectedColor)
    }
    
}
