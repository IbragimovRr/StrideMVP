//
//  DateHeaderCollectionReusableView.swift
//  Courses
//
//  Created by Руслан on 03.02.2025.
//

import UIKit

class DateHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var lastText: UILabel!
    
    func isFirstSection(index: Int) {
        if index == 0 {
            lastText.isHidden = false
        }else {
            lastText.isHidden = true
        }
    }
}
