//
//  VhodViewController.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import UIKit
import Lottie

protocol VhodViewDelegate {
    func showLoading(bool: Bool)
    func showError(error: String?)
    func clearError()
    func successVhod()
}

class VhodViewController: UIViewController, VhodViewDelegate {

    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var passwordBorder: Border!
    @IBOutlet weak var phoneBorder: Border!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!

    
    var presenter = VhodPresenter()
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    

    override func viewDidLoad() {
        super.viewDidLoad()
        phone.delegate = self
        presenter.view = self
        view.addSubview(errorView)
        errorView.isHidden = true
    }
    
    func showLoading(bool: Bool) {
        if bool {
            loadingStart()
        }else {
            loadingStop()
        }
    }
    
    func showError(error: String?) {
        if let error = error {
            errorView.isHidden = false
            errorView.configure(title: "Ошибка", description: error)
        }else {
            errorView.isHidden = false
            errorView.configure(title: "Ошибка", description: "Попробуйте позже")
        }
    }
    
    func successVhod() {
        performSegue(withIdentifier: "success", sender: self)
    }

    func clearError() {
        passwordBorder.color = .lightBlackMain
        phoneBorder.color = .lightBlackMain
        errorView.isHidden = true
    }

    
    private func loadingStart() {
        loading.play()
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        nextBtn.isHidden = true
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        nextBtn.isHidden = false
    }

    func checkInfo() -> Bool {
        var result = true
        guard phone.text!.count > 2 else {
            phoneBorder.color = .errorRed
            result = false
            return result }
        guard password.text!.isEmpty == false else {
            passwordBorder.color = .errorRed
            result = false
            return result }
        return result
    }

    @IBAction func vhod(_ sender: UIButton) {
        clearError()
        if checkInfo() {
            presenter.vhod(phoneNumber: phone.text!, password: password.text!)
        }
    }


    @IBAction func apple(_ sender: UIButton) {

    }

    @IBAction func google(_ sender: UIButton) {
        presenter.googleSign(self)
    }

    @IBAction func passwordHidden(_ sender: UIButton) {
        if sender.tag == 0 {
            password.isSecureTextEntry = false
            sender.tag = 1
        }else {
            password.isSecureTextEntry = true
            sender.tag = 0
        }
    }

    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender)
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        password.resignFirstResponder()
        phone.resignFirstResponder()
    }
}

extension VhodViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
    }


}
