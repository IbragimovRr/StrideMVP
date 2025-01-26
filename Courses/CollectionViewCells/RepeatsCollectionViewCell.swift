//
//  RepeatsCollectionViewCell.swift
//  Courses
//
//  Created by Руслан on 03.01.2025.
//

import UIKit

class RepeatsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var secondItemType: UILabel!
    @IBOutlet weak var secondItemTF: UITextField!
    @IBOutlet weak var firstItemType: UILabel!
    @IBOutlet weak var firstItemTF: UITextField!
    @IBOutlet weak var numbers: UILabel!
    
    var onTextChangedFirst: ((String) -> Void)?
    var onTextChangedSecond: ((String) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guard firstItemTF != nil && secondItemTF != nil else { return }
        firstItemTF.addTarget(self, action: #selector(textFieldDidChangeFirst), for: .editingChanged)
        secondItemTF.addTarget(self, action: #selector(textFieldDidChangeSecond), for: .editingChanged)
    }

    
    @objc func textFieldDidChangeFirst(_ sender: UITextField) {
        maxFourCharacters(sender: sender)
        onTextChangedFirst?(firstItemTF.text ?? "")
    }
    
    @objc func textFieldDidChangeSecond(_ sender: UITextField) {
        maxFourCharacters(sender: sender)
        onTextChangedSecond?(secondItemTF.text ?? "")
    }
    
    private func maxFourCharacters(sender: UITextField) {
        if let text = sender.text, text.count > 4 {
            sender.text = String(text.prefix(4))
        }
    }
    
}

