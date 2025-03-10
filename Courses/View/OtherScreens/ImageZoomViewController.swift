//
//  ImageZoomViewController.swift
//  Courses
//
//  Created by Руслан on 13.02.2025.
//

import UIKit

class ImageZoomViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var image: UIImageView!
    var imageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.sd_setImage(with: URL(string: imageURL))
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .black
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        scrollView.addSubview(image)
        
        image.frame = scrollView.bounds
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return image
    }
    
}
