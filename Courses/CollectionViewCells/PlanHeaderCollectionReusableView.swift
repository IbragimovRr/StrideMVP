//
//  PlanHeaderCollectionReusableView.swift
//  Courses
//
//  Created by Руслан on 24.01.2025.
//

import UIKit

class PlanHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var name: UILabel!
    
    func ishiddenTopView(index: Int) {
        if index == 0 {
            topView.isHidden = true
        }else {
            topView.isHidden = false
        }
    }
}
