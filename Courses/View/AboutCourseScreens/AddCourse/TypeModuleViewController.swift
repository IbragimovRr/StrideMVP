//
//  TypeModuleViewController.swift
//  Courses
//
//  Created by Руслан on 26.12.2024.
//

import UIKit

class TypeModuleViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var trainingImage: UIImageView!
    @IBOutlet weak var customView: Border!
    @IBOutlet weak var videoView: Border!
    @IBOutlet weak var trainingView: Border!
    
    private var selectTag: Int? = nil
    private var startPosition = CGPoint()
    var delegate: TypeModuleDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startPosition = mainView.frame.origin
    }
    
    private func selectView() {
        switch selectTag {
        case 0:
            customView.color = UIColor.blueMain
            customImage.image = UIImage.selectCustomModule
        case 1:
            videoView.color = UIColor.blueMain
            videoImage.image = UIImage.selectVideoModule
        case 2:
            trainingView.color = UIColor.blueMain
            trainingImage.image = UIImage.selectTrainingModule
        default:
            break
        }
    }
    
    private func unselectView() {
        switch selectTag {
        case 0:
            customView.color = UIColor.lightBlackMain
            customImage.image = UIImage.customModule
        case 1:
            videoView.color = UIColor.lightBlackMain
            videoImage.image = UIImage.videoModule2
        case 2:
            trainingView.color = UIColor.lightBlackMain
            trainingImage.image = UIImage.trainingModule2
        default:
            break
        }
    }
    
    private func unselectAllView() {
        customView.color = UIColor.lightBlackMain
        customImage.image = UIImage.customModule
        videoView.color = UIColor.lightBlackMain
        videoImage.image = UIImage.videoModule2
        trainingView.color = UIColor.lightBlackMain
        trainingImage.image = UIImage.trainingModule2
    }
    
    @IBAction func selectType(_ sender: UIButton) {
        unselectView()
        if selectTag == sender.tag {
            unselectView()
            selectTag = nil
        }else {
            selectTag = sender.tag
            selectView()
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        var type: ModuleType = .custom
        switch selectTag {
        case 0:
            type = .custom
        case 1:
            type = .video
        case 2:
            type = .training
        case .none:
            break
        case .some(_):
            break
        }
        delegate.addModule(type: type)
        dismiss(animated: false)
    }
    
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: mainView)
        switch sender.state {
        case .changed:
            guard translation.y > 0 else { return }
            mainView.center = CGPoint(x: mainView.center.x, y: mainView.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: mainView)
        case .ended:
            if sender.velocity(in: mainView).y > 500 {
                dismiss(animated: false)
            }else {
                UIView.animate(withDuration: 0.5) {
                    self.mainView.frame.origin = self.startPosition
                }
            }
        default:
            break
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}
