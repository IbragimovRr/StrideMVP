//
//  CourseTextViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit
import Lottie
import WebKit

class CourseTextViewController: UIViewController {

    @IBOutlet weak var editorBackView: UIView!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourse: UILabel!

    var module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
    var editor = EditorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FilePath().deleteAlamofireFiles()
    }
    
    
    private func design() {
        self.overrideUserInterfaceStyle = .dark
        setupRichEditorView()
        loadingSettings()
        nameCourse.text = module.module.name
    }
    
    func setupRichEditorView() {
        let webConfiguration = WKWebViewConfiguration()
        editor = EditorView(frame: .zero, configuration: webConfiguration)
        editor.navigationDelegate = self
        editor.layer.makeHiddenOnCapture()
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

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
    }

    func getData() {
        Task {
            guard let moduleText = module.text else { return }
            loading.play()
            let html = try await FilePath().downloadHtmlFileWithURL(url: moduleText)
            if let html = html {
                editor.html = html
            }
            loading.stop()
            loading.isHidden = true
        }
    }
    

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension CourseTextViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getData()
        editor.disableEditing()
    }
}
