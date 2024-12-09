//
//  СonfidentialityViewController.swift
//  Courses
//
//  Created by Руслан on 30.10.2024.
//

import UIKit

protocol ConfidetialityViewDelegate {
    func showTheme()
}

class ConfidentialityViewController: UIViewController, ConfidetialityViewDelegate {
    
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var successThird: UIImageView!
    @IBOutlet weak var successSecond: UIImageView!
    @IBOutlet weak var successFirst: UIImageView!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var oldPassword: UITextField!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    var presenter = ConfidetialityPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPosition = errorView.center
        errorView.isHidden = true
        presenter.view = self
        presenter.getTheme()
        view.addSubview(errorView)
    }
    
    @IBAction func viewPassword(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            oldPassword.isSecureTextEntry = false
            sender.tag = 2
        case 1:
            newPassword.isSecureTextEntry = false
            sender.tag = 3
        case 2:
            oldPassword.isSecureTextEntry = true
            sender.tag = 0
        case 3:
            newPassword.isSecureTextEntry = true
            sender.tag = 1
        default:
            break
        }
    }
    
    func showTheme() {
        clearSegmented()
        switch presenter.theme {
        case .unspecified:
            thirdView.layer.borderColor = UIColor.blueMain.cgColor
            thirdView.layer.borderWidth = 1
            successThird.isHidden = false
        case .light:
            firstView.layer.borderColor = UIColor.blueMain.cgColor
            firstView.layer.borderWidth = 1
            successFirst.isHidden = false
        case .dark:
            secondView.layer.borderColor = UIColor.blueMain.cgColor
            secondView.layer.borderWidth = 1
            successSecond.isHidden = false
        @unknown default:
            thirdView.layer.borderColor = UIColor.blueMain.cgColor
            thirdView.layer.borderWidth = 1
            successThird.isHidden = false
        }
        
    }
    
    
    private func deleteAccount() {
        Task {
            do {
                try await UserServices().deleteAccount()
                UD().clearUD()
                self.navigationController?.popToRootViewController(animated: true)
            }catch {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
            }
        }
    }
    
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Внимание",
                                      message: "Вы действительно хотите удалить свой аккаунт?",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Да", style: .default) { _ in
            self.deleteAccount()
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    
        present(alert, animated: true)
    }
    
    private func clearSegmented() {
        firstView.layer.borderColor = UIColor.clear.cgColor
        firstView.layer.borderWidth = 0
        secondView.layer.borderColor = UIColor.clear.cgColor
        secondView.layer.borderWidth = 0
        thirdView.layer.borderColor = UIColor.clear.cgColor
        thirdView.layer.borderWidth = 0
        successFirst.isHidden = true
        successSecond.isHidden = true
        successThird.isHidden = true
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        errorView.isHidden = false
        errorView.configureUnavailable(title: "Cкоро", description: "В данный момент недоступно")
    }
    
    
    @IBAction func theme(_ sender: UIButton) {
        clearSegmented()
        
        switch sender.tag {
        case 0:
            presenter.theme = .light
        case 1:
            presenter.theme = .dark
        case 2:
            presenter.theme = .unspecified
        default:
            presenter.theme = .unspecified
        }
    }
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        showAccessDeniedAlert()
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
}
