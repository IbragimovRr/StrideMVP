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
import SwiftyMarkdown
import InfomaniakRichHTMLEditor


class AddCourseViewController: UIViewController {
    
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
    var editor = RichHTMLEditorView()
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private var isChangedText = false
    private var isSave = true
    
    var module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
    var nameCourse = ""
    
    private var colorSelect = UIColor.white {
        didSet {
            colorView.backgroundColor = colorSelect
            editor.setForegroundColor(colorSelect)
        }
    }
    private var fontSelect = UIFont.systemFont(ofSize: 16) {
        didSet {
            fontTitle.text = fontSelect.fontName
            editor.setFontName(fontSelect.fontName)
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
            editor.setFontSize(intSize)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRichEditorView()
        loadInitialHTML()
//        markdownTextView.delegate = self
        self.overrideUserInterfaceStyle = .dark
        getData()
        design()
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
        FilePath().deleteAlamofireFiles()
    }
    
    func setupRichEditorView() {
        editor.isScrollEnabled = true
        editor.translatesAutoresizingMaskIntoConstraints = false
        editorBackView.addSubview(editor)
        
        NSLayoutConstraint.activate([
            editor.topAnchor.constraint(equalTo: editorBackView.topAnchor),
            editor.bottomAnchor.constraint(equalTo: editorBackView.bottomAnchor),
            editor.trailingAnchor.constraint(equalTo: editorBackView.trailingAnchor),
            editor.leadingAnchor.constraint(equalTo: editorBackView.leadingAnchor)
        ])
    }

    func loadInitialHTML() {
        let initialHTML = "<p>This is some initial <b>rich</b> text.</p>"
        editor.html = initialHTML
    }

    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        
        loading.play()
        loading.isHidden = false
    }
    
    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
    }
    
    
    func getData() {
        Task {
            
            let markdownText = """
        *italics* or _italics_
        """
            
        }
    }
    
    private func design() {
        nameCourseLBL.text = module.module.name
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
            editor.justify(.full)
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
    
    
    private func addCourse(text: NSAttributedString) async throws {
        do {
            loadingSettings()
            try await CourseServices().addModulesData(text: text, moduleID: module.module.id)
            loadingStop()
            isSave = true
        }catch ErrorNetwork.runtimeError(let error) {
            errorView.isHidden = false
            errorView.configure(title: "Ошибка", description: error)
            view.addSubview(errorView)
            loadingStop()
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
//        editor.isEditable = true
//        editor.becomeFirstResponder()
        isChangedText = false
        checkUndoRedo()
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
//        textView.resignFirstResponder()
//        Task {
//            try await addCourse(text: textView.attributedText)
//        }
        editor.html = editor.html
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
//        editor.isSelectable = true
//        editor.isEditable = false
//        editor.becomeFirstResponder()
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

// MARK: - TextView
extension AddCourseViewController: RichHTMLEditorViewDelegate {
    
//    func textViewDidChange(_ textView: UITextView) {
//        if let text = textView.text {
//            self.markdownText = text
//            updateMarkdown()
//        }
//    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        
//        checkUndoRedo()
//        isSave = false
//    }
    
}
// MARK: - Image
extension AddCourseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
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
