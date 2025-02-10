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
    var position = 0
    
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
    
    private func showErrorTypes() {
        customView.color = UIColor.errorRed
        videoView.color = UIColor.errorRed
        trainingView.color = UIColor.errorRed
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
    
    private func initialType() -> Result<ModuleType, ErrorNetwork> {
        var type: ModuleType? = nil
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
        if let type = type {
            return .success(type)
        }else {
            return .failure(ErrorNetwork.notFound)
        }
    }
    
    @IBAction func selectType(_ sender: UIButton) {
        unselectAllView()
        if selectTag == sender.tag {
            unselectView()
            selectTag = nil
        }else {
            selectTag = sender.tag
            selectView()
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        switch initialType() {
        case .success(let type):
            delegate.addModule(type: type, position: position)
            dismiss(animated: false)
        case .failure(_):
            showErrorTypes()
        }
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
    
}
