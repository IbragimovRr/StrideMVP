//
//  ViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage
import Lottie

protocol CatalogViewDelegate: AnyObject {
    func showCourses()
    func showCategories()
    func showLoadingMain(bool: Bool)
    func showLoadingPage(bool: Bool)
    func showNextPage()
    func showEmptyView(bool: Bool)
    func searchCourses()
    func updateCollection()
}

class CatalogViewController: UIViewController, CatalogViewDelegate {

    @IBOutlet weak var instagrampostFilterSegment: UIButton!
    @IBOutlet weak var groupPostFilterSegment: UIButton!
    @IBOutlet weak var loadingMain: LottieAnimationView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingPage: LottieAnimationView!
    @IBOutlet weak var catalogHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyBox: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var presenter = CatalogPresenter()
    private var postFilterSegment: PostSegmented!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        presenter.view = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
        search.delegate = self
        postFilterSegment = PostSegmented(firstBtn: groupPostFilterSegment, secondBtn: instagrampostFilterSegment)
        design()
        presenter.viewDidLoad()
    }
    
    
    private func changeHeightCollection() {
        catalogHeight.constant = catalogCollectionView.contentSize.height
    }
    
    private func design() {
        emptySettings()
        loadingPage.play()
        loadingPage.loopMode = .loop
        loadingMain.play()
        loadingMain.loopMode = .loop
    }
    
    func showCourses() {
        emptyCheck()
        catalogCollectionView.reloadData()
        catalogCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    func showCategories() {
        categoryCollectionView.reloadData()
    }
    
    func showLoadingMain(bool: Bool) {
        if bool {
            loadingMain.isHidden = false
            loadingMain.play()
        }else {
            loadingMain.isHidden = true
            loadingMain.stop()
        }
    }
    
    func showLoadingPage(bool: Bool) {
        if bool {
            loadingPage.isHidden = false
            loadingPage.play()
        }else {
            loadingPage.isHidden = true
            loadingPage.stop()
        }
    }
    
    func showNextPage() {
        catalogCollectionView.reloadData()
        catalogCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    func showEmptyView(bool: Bool) {
        if presenter.courses.isEmpty == false {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }
    
    func searchCourses() {
        emptyCheck()
        catalogCollectionView.reloadData()
        catalogCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    func updateCollection() {
        catalogCollectionView.reloadData()
        categoryCollectionView.reloadData()
    }

    
    private func emptyCheck() {
        if presenter.courses.isEmpty == false {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }
    
    private func emptySettings() {
        emptyBox.contentMode = .scaleToFill
        emptyBox.play()
    }
    
    
    
    @IBAction func filterPost(_ sender: UIButton) {
        if sender == groupPostFilterSegment {
            postFilterSegment.onFirst()
        }else {
            postFilterSegment.onSecond()
        }
        catalogCollectionView.reloadData()
        catalogCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        search.resignFirstResponder()
    }

}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return presenter.categories.count
        }else {
            return presenter.courses.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoriesCollectionViewCell
            cell.image.sd_setImage(with: presenter.categories[indexPath.row].imageURL)
            cell.nameCategory.text = presenter.categories[indexPath.row].nameCategory
            cell.selectCategory(selectCategoryID: presenter.selectCategory?.id, categoryID: presenter.categories[indexPath.row].id)
            return cell
        }else {
            let cell = catalogCollectionView.dequeueReusableCell(withReuseIdentifier: postFilterSegment.collectionIdentifier, for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: presenter.courses[indexPath.row].imageURL)
            cell.nameAuthor.text = presenter.courses[indexPath.row].author.userName
            cell.nameCourse.text = presenter.courses[indexPath.row].nameCourse
            cell.price.text = "\(presenter.courses[indexPath.row].price)₽"
            cell.rating.text = "\(presenter.courses[indexPath.row].rating)"
            let days = presenter.courses[indexPath.row].daysCount
            cell.daysCount.text = "\(days) \(days.declinedWord())"
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == catalogCollectionView {
            presenter.selectCourse = presenter.courses[indexPath.row]
            performSegue(withIdentifier: "info", sender: self)
        }else if collectionView == categoryCollectionView {
            presenter.getSelectCategory(indexPath: indexPath, search: search.text!)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == catalogCollectionView {
            if postFilterSegment.selectFirst {
                let width = UIScreen.main.bounds.width / 2 - 30
                return CGSize(width: width, height: 180)
            }else {
                let width = catalogCollectionView.bounds.width
                return CGSize(width: width, height: 180)
            }
        }else {
            return CGSize(width: 100, height: 128)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let contentHeight = catalogCollectionView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            let scrollOffset = scrollView.contentOffset.y
            
            guard presenter.courses.isEmpty == false else { return }
            let nextURL = presenter.courses[presenter.courses.count - 1].nextPage
            
            if scrollOffset >= contentHeight - scrollViewHeight && presenter.loadingMoreData == false && nextURL != "" {
                loadingPage.isHidden = false
                loadingPage.play()
                presenter.loadingMoreData = true
                presenter.getNextPage(page: nextURL)
            }
            
            checkLastPage(nextURL: nextURL)
        }
    }
    
    private func checkLastPage(nextURL:String?) {
        if nextURL == "" {
            loadingPage.stop()
            loadingPage.isHidden = true
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "info" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.presenter.course = presenter.selectCourse
        }

    }


}
extension CatalogViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.searchCourse(text: textField.text!)
    }

    
}
