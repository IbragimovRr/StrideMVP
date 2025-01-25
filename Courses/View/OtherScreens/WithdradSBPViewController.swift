//
//  WithdradSBPViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 16.09.2024.
//

import UIKit

protocol WithdrawViewDelegate {
    func showError(error: String)
    func showSuccess(money: Int)
    func showBank()
    func showEnableFinish(bool: Bool)
}

class WithdrawSBPViewController: UIViewController, WithdrawViewDelegate {
    
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var withdrawTextField: UITextField!
    @IBOutlet weak var withdrawBorder: Border!
    @IBOutlet weak var bankBorder: Border!
    @IBOutlet weak var numberBorder: Border!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var banksTableView: UITableView!
    @IBOutlet weak var numberTextField: UITextField!
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    var presenter = WithdrawPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearError()
        design()
        presenter.getBanks()
        textFieldDesign()
        numberTextField.delegate = self
        presenter.view = self
        banksTableView.delegate = self
        banksTableView.dataSource = self
        view.addSubview(errorView)
        errorView.isHidden = true
    }
    
    private func textFieldDesign() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        withdrawTextField.attributedPlaceholder = NSAttributedString(string: "от 100₽ до 50000₽", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
    }
    
    private func design() {
        banksTableView.isHidden = true
        moneyCount.text = "\(presenter.money)"
    }
    
    func showError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
    }
    
    func showSuccess(money: Int) {
        moneyCount.text = "\(money)"
        errorView.isHidden = false
        errorView.configureSuccess(title: "Успешно", description: "Средства будут выведены в течении 48 часов")
    }
    
    func showBank() {
        banksTableView.reloadData()
    }
    
    func showEnableFinish(bool: Bool) {
        finishBtn.isEnabled = bool
    }
    
    
    func clearError() {
        withdrawBorder.color = .lightBlackMain
        numberBorder.color = .lightBlackMain
        bankBorder.color = .lightBlackMain
        errorView.isHidden = true
    }
    
    
    private func checkInfo() -> Bool {
        var result = true
        guard numberTextField.text!.isEmpty == false else {
            numberBorder.color = .errorRed
            result = false
            return result }
        guard numberTextField.text!.count == 17 else {
            numberBorder.color = .errorRed
            showError(error: "Неправильный номер")
            result = false
            return result }
        if bankLabel.text == "Выберите ваш банк" {
            bankBorder.color = .errorRed
            showError(error: "Выберите банк")
            result = false
            return result }
        guard withdrawTextField.text!.isEmpty == false else {
            withdrawBorder.color = .errorRed
            result = false
            return result }
        guard Int(withdrawTextField.text!)! >= 100 && Int(withdrawTextField.text!)! <= 50000 else {
            withdrawBorder.color = .errorRed
            showError(error: "Вывод средств от 100₽ до 50000₽")
            result = false
            return result }
        return result
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        numberTextField.resignFirstResponder()
        withdrawTextField.resignFirstResponder()
    }
    
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender)
    }
    
    @IBAction func fluent(_ sender: UIButton) {
        clearError()
        if checkInfo() {
            let moneyCountRes = Int(moneyCount.text!)!
            let selectMoney = Int(withdrawTextField.text!)!
            presenter.fluentSBP(money: moneyCountRes, selectMoney: selectMoney, number: numberTextField.text!, bank: bankLabel.text!)
        }
    }
    
    @IBAction func banksTV(_ sender: UIButton) {
        banksTableView.isHidden.toggle()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}




extension WithdrawSBPViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.arrayBanks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = banksTableView.dequeueReusableCell(withIdentifier: "bankTF", for: indexPath) as! BanksTableViewCell
        cell.name.text = presenter.arrayBanks[indexPath.row].name
        cell.im.image = UIImage(named: "\(presenter.arrayBanks[indexPath.row].image)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bankLabel.text = presenter.arrayBanks[indexPath.row].name
        banksTableView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return ValidateTF().phone(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
}
