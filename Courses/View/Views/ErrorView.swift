//
//  ErrorView.swift
//  Courses
//
//  Created by Руслан on 22.08.2024.
//

import Foundation
import UIKit

class ErrorView: UIView {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 3
            return stackView
        }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProRounded-Semibold", size: 14)!
        label.textColor = .white
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "SFProRounded-Regular", size: 10)!
        label.textColor = .white
        return label
    }()
    
    var startPosition = CGPoint()
    
    override init(frame: CGRect = CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70)) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func designView() {
        self.backgroundColor = UIColor.errorRed
        self.layer.cornerRadius = 10
        self.isHidden = true
    }

    private func setupView() {
        addSubview(imageView)
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        designView()
        startPosition = self.center

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalToConstant: 25),

            contentStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            centerYAnchor.constraint(equalTo: contentStackView.centerYAnchor, constant: 0),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15),
        ])
    }
    
    func configure(image: UIImage = UIImage.error, title: String, description: String) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
        self.backgroundColor = UIColor.errorRed
    }
    
    func configureSuccess(image: UIImage = UIImage.success, title: String, description: String) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
        self.backgroundColor = UIColor.success
    }
    
    func configureUnavailable(image: UIImage = UIImage.errorLight, title: String, description: String) {
        imageView.image = image
        titleLabel.text = title
        titleLabel.textColor = .label
        descriptionLabel.textColor = .label
        descriptionLabel.text = description
        self.backgroundColor = UIColor.lightBlackMain
    }
    
    func swipe(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        switch sender.state {
        case .changed:
            self.center = CGPoint(x: self.center.x, y: self.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        case .ended:
            UIView.animate(withDuration: 0.5, animations: {
                if self.center.y < self.startPosition.y {
                    self.alpha = 0.0
                    self.center = CGPoint(x: self.center.x, y: self.center.y - 50)
                } else {
                    self.center = self.startPosition
                }
            }, completion: { _ in
                if self.alpha == 0.0 {
                    self.alpha = 1.0
                    self.isHidden = true
                    self.center = self.startPosition
                }
            })
            
        default:
            break
        }
    }

}
