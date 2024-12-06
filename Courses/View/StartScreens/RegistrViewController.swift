//
//  RegistrViewController.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import UIKit
import Lottie

protocol RegistrViewDelegate: AnyObject {
    func showError(error: String)
    func showLoading(bool: Bool)
    func successRegistr()
}

class RegistrViewController: UIViewController, RegistrViewDelegate {

    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var phoneBorder: Border!
    @IBOutlet weak var passwordAgoBorder: Border!
    @IBOutlet weak var passwordBorder: Border!
    @IBOutlet weak var mailBorder: Border!
    @IBOutlet weak var surnameBorder: Border!
    @IBOutlet weak var nameBorder: Border!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var passwordAgo: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var mail: UITextField!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var startPosition = CGPoint()
    var presenter = RegistrPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        name.delegate = self
        lastName.delegate = self
        presenter.view = self
        name.autocapitalizationType = .words
        lastName.autocapitalizationType = .words
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
    }

    func clearError() {
        nameBorder.color = UIColor.lightBlackMain
        surnameBorder.color = UIColor.lightBlackMain
        mailBorder.color = UIColor.lightBlackMain
        passwordBorder.color = UIColor.lightBlackMain
        passwordAgoBorder.color = UIColor.lightBlackMain
        phoneBorder.color = UIColor.lightBlackMain
        errorView.isHidden = true
    }
    
    private func loadingStart() {
        loading.play()
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        registerBtn.isHidden = true
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        registerBtn.isHidden = false
    }

    func checkInfo() -> Bool {
        var results = true
        guard password.text == passwordAgo.text else {
            passwordBorder.color = .errorRed
            passwordAgoBorder.color = .errorRed
            errorView.configure(title: "Неверный пароль", description: "Пароли не совпадают")
            errorView.isHidden = false
            results = false
            return results }
        guard name.text!.isEmpty == false else {
            nameBorder.color = .errorRed
            results = false
            return results }
        guard lastName.text!.isEmpty == false else {
            surnameBorder.color = .errorRed
            results = false
            return results }
        guard mail.text!.isEmpty == false else {
            mailBorder.color = .errorRed
            results = false
            return results }
        guard password.text!.isEmpty == false else {
            passwordBorder.color = .errorRed
            results = false
            return results }
        return results
    }
    
    func showError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
    }
    
    func showLoading(bool: Bool) {
        if bool {
            loadingStart()
        }else {
            loadingStop()
        }
    }
    
    func successRegistr() {
        performSegue(withIdentifier: "success", sender: self)
    }

    @IBAction func registr(_ sender: UIButton) {
        clearError()
        if checkInfo() {
            presenter.signUp(phoneNumber: phoneNumber.text!, password: password.text!, name: name.text!, lastName: lastName.text!, mail: mail.text!)
        }
    }


    @IBAction func passwordHidden(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            password.isSecureTextEntry = false
            sender.tag = 2
        case 1:
            passwordAgo.isSecureTextEntry = false
            sender.tag = 3
        case 2:
            password.isSecureTextEntry = true
            sender.tag = 0
        case 3:
            passwordAgo.isSecureTextEntry = true
            sender.tag = 1
        default:
            break
        }
    }


    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        phoneNumber.resignFirstResponder()
        password.resignFirstResponder()
        passwordAgo.resignFirstResponder()
        lastName.resignFirstResponder()
        name.resignFirstResponder()
        mail.resignFirstResponder()
    }

}
extension RegistrViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
        }else {
            return ValidateTF().nameAndSurname(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
    }

}
