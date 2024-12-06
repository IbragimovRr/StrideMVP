//
//  Segment.swift
//  Courses
//
//  Created by Руслан on 19.11.2024.
//

import Foundation
import UIKit

class PostSegmented {
    
    var firstBtn: UIButton
    var secondBtn: UIButton
    var selectFirst = true {
        didSet {
            if selectFirst {
                collectionIdentifier = "course"
            }else {
                collectionIdentifier = "instagramPost"
            }
        }
    }
    var collectionIdentifier = "course"
    
    init(firstBtn: UIButton, secondBtn: UIButton) {
        self.firstBtn = firstBtn
        self.secondBtn = secondBtn
    }
    
    func onFirst() {
        firstBtn.setImage(UIImage.groupPostFull, for: .normal)
        secondBtn.setImage(UIImage.instagramPost, for: .normal)
        selectFirst = true
    }
    
    func onSecond() {
        firstBtn.setImage(UIImage.groupPost, for: .normal)
        secondBtn.setImage(UIImage.instagramPostFull, for: .normal)
        selectFirst = false
    }
    
    
}
