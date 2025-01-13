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
    
    @IBOutlet weak var editorBackView: UIView!
    @IBOutlet weak var redo: UIButton!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourseLBL: UILabel!
    @IBOutlet weak var sizeFont: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var fontTitle: UILabel!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var bottomConsoleView: NSLayoutConstraint!
    @IBOutlet weak var alingment: UIButton!
    
    var editor = EditorView()
    var presenter = AddCoursePresenter()
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private var isChangedText = false
    private var isSave = true
    
    private var colorSelect = UIColor.white {
        didSet {
            colorView.backgroundColor = colorSelect
            editor.textColor(colorSelect)
        }
    }
    private var fontSelect = UIFont.systemFont(ofSize: 16) {
        didSet {
            fontTitle.text = fontSelect.fontName
            editor.font(fontSelect.fontName)
        }
    }
    private var alignment = NSMutableParagraphStyle().alignment {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment
            changedAlignment(alignment)
        }
    }
    private var sizeFontSelect = 16.0 {
        didSet {
            fontSelect = UIFont(descriptor: fontSelect.fontDescriptor, size: sizeFontSelect)
            let roundedSize = round(sizeFontSelect * 10) / 10
            sizeFontSelect = roundedSize
            sizeFont.text = "\(sizeFontSelect) пт"
            let intSize = Int(sizeFontSelect)
//            editor.heading(intSize)
            editor.blockquote()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .dark
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
        editor = EditorView(frame: .zero, configuration: webConfiguration)
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
    
    func updateStyles(font: String, fontSize: CGFloat, color: String, textAlign: String) {
//        fontSelect = font
//        sizeFontSelect = fontSize
//        colorSelect = UIColor(named: color) ?? .black
//        alignment = NSTextAlignment(rawValue: textAlign)!
        print(font, fontSize, color, textAlign)
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
            alingment.setImage(UIImage.defaulTextFull, for: .normal)
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
    
    @IBAction func okFont(_ sender: Any) {
        fontView.isHidden = true
        isChangedText = false
        checkUndoRedo()
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
        editor.resignFirstResponder()
        presenter.saveCourse(html: nil)
    }
    
    @IBAction func color(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = colorView.backgroundColor!
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
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
        fontView.isHidden = false
        isChangedText = true
    }
    
    @IBAction func fontBtn(_ sender: UIButton) {
        let config = UIFontPickerViewController.Configuration()
        config.includeFaces = false
        let vc = UIFontPickerViewController()
        vc.delegate = self
        present(vc, animated: true)
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
            alignment = .left
            sender.tag = 1
        case 1:
            alignment = .center
            sender.tag = 2
        case 2:
            alignment = .right
            sender.tag = 3
        case 3:
            alignment = .justified
            sender.tag = 0
        default:
            break
        }
    }
    
    @IBAction func stepper(_ sender: UIButton) {
        if sender.tag == 0 {
            sizeFontSelect -= 1
        }else {
            sizeFontSelect += 1
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
extension AddCourseViewController: UIFontPickerViewControllerDelegate {
    
    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let descriptor = viewController.selectedFontDescriptor else {return}
        fontSelect = UIFont(descriptor: descriptor, size: sizeFontSelect)
        viewController.dismiss(animated: true)
    }
}
// MARK: - Color
extension AddCourseViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorSelect = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorSelect = viewController.selectedColor
    }
    
}
