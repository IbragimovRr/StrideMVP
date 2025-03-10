//
//  SettingsViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit

protocol SettingsViewDelegate {
    func showProfile()
    func showObjects()
}

class SettingsViewController: UIViewController, SettingsViewDelegate {

    @IBOutlet weak var tbvConstant: NSLayoutConstraint!
    @IBOutlet weak var mail: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    @IBOutlet weak var settingsTableView2: UITableView!

    var presenter = SettingsPresenter()
    var arrayObjects: [Objects] { return presenter.arrayObjects }
    var arrayObjects2: [Objects] { return presenter.arrayObjects2 }
    var user: UserModel { return presenter.user }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        settingsCollectionView.delegate = self
        settingsCollectionView.dataSource = self
        settingsTableView2.dataSource = self
        settingsTableView2.delegate = self
        hiddenBtn()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillApear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeHeightTable()
    }
    
    func showProfile() {
        name.text = "\(user.name) \(user.surname)"
        mail.text = user.email
        if let ava = user.avatarURL {
            avatar.sd_setImage(with: ava)
        }
        self.view.layoutSubviews()
    }
    
    func showObjects() {
        settingsCollectionView.reloadData()
        settingsTableView2.reloadData()
    }

    private func hiddenBtn() {
        if user.role == .user || user.role == .admin  {
            backBtn.isHidden = true
        }else if user.role == .coach {
            backBtn.isHidden = false
        }
    }

    private func changeHeightTable() {
        tbvConstant.constant = settingsCollectionView.contentSize.height
    }
    


    @IBAction func logOut(_ sender: UIButton) {
        UD().clearUD()
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsMain", for: indexPath) as! SettingsCollectionViewCell
        cell.im.image = UIImage(named: arrayObjects[indexPath.row].image)
        cell.name.text = arrayObjects[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch arrayObjects[indexPath.row].name {
        case "Информация о себе":
            performSegue(withIdentifier: "goToInfoAboutMe", sender: self)
        case "Мои курсы":
            performSegue(withIdentifier: "myCourse", sender: self)
        case "Конфиденциальность":
            performSegue(withIdentifier: "conf", sender: self)
        case "Добавить курс":
            performSegue(withIdentifier: "goToAddCourse", sender: self)
        case "Стать тренером":
            UIApplication.shared.open(Constants.formsURL)
        case "Кошелёк":
            performSegue(withIdentifier: "goToWithdraw", sender: self)
        case "Админ панель":
            performSegue(withIdentifier: "admin", sender: self)
        case "Промокоды":
            performSegue(withIdentifier: "promo", sender: self)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthScreen = UIScreen.main.bounds.width - 50
        let widthCell = widthScreen / 2
        return CGSize(width: widthCell, height: 100)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayObjects2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView2.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! SettingsTableViewCell
        cell.im.image = UIImage(named: "\(arrayObjects2[indexPath.row].image)")
        cell.lbl.text = arrayObjects2[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch arrayObjects2[indexPath.row].name {
        case "Политика конфиденциальности":
            performSegue(withIdentifier: "privacy", sender: self)
        case "Нужна помощь? Напиши нам":
            UIApplication.shared.open(Constants.telegramURL)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "myCourse" {
            let vc = segue.destination as! CoursesViewController
            if user.role == .coach {
                vc.typeCourse = .myCreate
            }else if user.role == .user {
                vc.typeCourse = .myBought
            }
        }else if segue.identifier == "goToAddCourse" {
            let vc = segue.destination as! AddInfoAboutCourseVC
            vc.create = true
        }else if segue.identifier == "goToWithdraw" {
            let vc = segue.destination as! WithdrawViewController
            vc.presenter.money = user.coach.money
        }

    }



}
