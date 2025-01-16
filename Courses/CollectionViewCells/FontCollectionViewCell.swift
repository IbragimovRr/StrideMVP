//
//  FontCollectionViewCell.swift
//  Courses
//
//  Created by Руслан on 16.01.2025.
//

import UIKit

class FontCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: Border!
    @IBOutlet weak var fontName: UILabel!
    
    func configure(with fontName: String, isHighlighted: Bool) {
        self.fontName.text = fontName
        self.fontName.font = UIFont(name: fontName, size: 8)
        
        if isHighlighted {
            self.fontName.font = UIFont(name: fontName, size: 8)
            mainView.layer.borderColor = UIColor.grayMain.cgColor
        } else {
            mainView.layer.borderColor = UIColor.extraLightBlackMain.cgColor
        }
        
    }

    
}
