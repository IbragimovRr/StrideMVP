//
//  MyCoursesViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit
import SDWebImage
import Lottie


protocol MyCoursesViewDelegate {
    func showLoading(bool: Bool)
    func showMyBoughtCourses()
}

class MyCoursesViewController: UIViewController, MyCoursesViewDelegate {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyBox: LottieAnimationView!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var myCoursesCollectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForSearch: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var search: UITextField!

    var presenter = MyCoursesPresenter()
    var refreshControl = RefreshControll()

    override func viewDidLoad() {
        super.viewDidLoad()
        myCoursesCollectionView.delegate = self
        myCoursesCollectionView.dataSource = self
        presenter.view = self
        search.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
        presenter.viewWillApear()
    }

    func design() {
        loadingSettings()
        addRefreshControll()
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        search.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayMain, NSAttributedString.Key.font: font!])
    }
    
    private func addRefreshControll() {
        refreshControl.refreshSettings(collectionView: myCoursesCollectionView)
        refreshControl.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl ) {
        presenter.getMyBoughtCourses()
    }


    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        loading.play()
        emptyBox.contentMode = .scaleToFill
        emptyBox.play()
    }

    private func emptyCheck() {
        if presenter.filteredCourse.isEmpty == false {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }
    
    func showLoading(bool: Bool) {
        if bool {
            loading.play()
            loading.isHidden = false
        }else {
            loading.stop()
            loading.isHidden = true
        }
    }
    
    func showMyBoughtCourses() {
        emptyCheck()
        myCoursesCollectionView.reloadData()
        refreshControl.refreshControl.endRefreshing()
    }

    @IBAction func search(_ sender: UIButton) {
        topConstraint.constant = 95
        viewForSearch.isHidden = false
        searchBtn.isHidden = true
        cancelBtn.isHidden = false
        search.becomeFirstResponder()
    }

    @IBAction func cancel(_ sender: UIButton) {
        search.text = ""
        presenter.filteredCourse = presenter.course
        myCoursesCollectionView.reloadData()
        topConstraint.constant = 30
        viewForSearch.isHidden = true
        searchBtn.isHidden = false
        cancelBtn.isHidden = true
        search.resignFirstResponder()
        emptyCheck()
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        search.resignFirstResponder()
    }

}

extension MyCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.filteredCourse.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCoursesCollectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: presenter.filteredCourse[indexPath.row].imageURL)
        cell.nameAuthor.text = "Тренер: \(presenter.filteredCourse[indexPath.row].author.userName)"
        cell.nameCourse.text = presenter.filteredCourse[indexPath.row].nameCourse
        cell.rating.text = "\(presenter.filteredCourse[indexPath.row].rating)"
        cell.progressInDays.text = "\(presenter.filteredCourse[indexPath.row].progressInDays)/\(presenter.filteredCourse[indexPath.row].daysCount)"
        let procent = presenter.procent(indexPath: indexPath)
        cell.progressInPercents.text = "\(Int(procent))%"
        cell.progressVIew.setProgress(Float(procent / 100), animated: false)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectIDCourse = presenter.filteredCourse[indexPath.row].id
        performSegue(withIdentifier: "course", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 50, height: 120)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "course" {
            let vc = segue.destination as! ModulesCourseViewController
            vc.idCourse = presenter.selectIDCourse
        }

    }
}
extension MyCoursesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        presenter.filteredCourse = updatedText.isEmpty ? presenter.course : presenter.course.filter { courseItem in
            return courseItem.nameCourse.lowercased().contains(updatedText.lowercased())
        }
        emptyCheck()
        myCoursesCollectionView.reloadData()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
