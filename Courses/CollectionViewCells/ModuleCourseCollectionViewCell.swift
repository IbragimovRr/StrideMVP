//
//  ModuleCourseCollectionViewCell.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit

class ModuleCourseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var typeModuleImage: UIImageView!
    @IBOutlet weak var typeModuleView: UIView!
    @IBOutlet weak var settingsBtn2: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var descrLbl: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    
    
    func typeModule(_ type: ModuleType) {
        if type == .video {
            typeModuleView.isHidden = false
            typeModuleImage.image = UIImage.videoModule
        }else if type == .training {
            typeModuleView.isHidden = false
            typeModuleImage.image = UIImage.trainingModule
        }else {
            typeModuleView.isHidden = true
        }
    }
    
    func cropBottomConstantinPlan(count: Int, index: Int) {
        if count == index {
            bottomConstant.constant = 0
        }else {
            bottomConstant.constant = 15
        }
    }
    
    func blurEffect(isBlur: Bool) {
        blurView.removeBlurEffect()
        if !isBlur {
            blurView.isHidden = false
            blurView.applyBlurEffect()
        }else {
            blurView.isHidden = true
        }
    }
    
}
