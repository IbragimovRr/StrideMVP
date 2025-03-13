//
//  TipVerificate.swift
//  Courses
//
//  Created by Руслан on 12.03.2025.
//

import UIKit

class TipVerificate: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let view = UINib(nibName: "TipVerificate", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
}
