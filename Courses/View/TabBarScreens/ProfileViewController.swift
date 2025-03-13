//
//  ProfileViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit
import SDWebImage
import SkeletonView
import TipKit

protocol ProfileViewDelegate: AnyObject {
    func showUser()
    func showMyCourses()
    func showSceletonAnimated(bool: Bool)
}

class ProfileViewController: UIViewController, ProfileViewDelegate {

    @IBOutlet weak var verifyImage: UIImageView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var characteristic: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingBottom: UILabel!
    @IBOutlet weak var coursesCount: UILabel!
    @IBOutlet weak var coursesCountBottom: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var coursesCollectionView: UICollectionView!

    var presenter = ProfilePresenter()
    var verifyInfo: TipVerificate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        coursesCollectionView.delegate = self
        coursesCollectionView.dataSource = self
        tipCreate()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillApear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tipSettings()
    }

    private func tipCreate() {
        verifyInfo = TipVerificate(frame: CGRect(x: 0, y: 0, width: 220, height: 120))
        verifyInfo.isHidden = true
        view.addSubview(verifyInfo)
    }
    
    private func tipSettings() {
        let buttonFrameInRootView = verifyBtn.convert(verifyBtn.bounds, to: self.view)

        let x = buttonFrameInRootView.maxX - 207
        let y = buttonFrameInRootView.maxY + 5
        
        verifyInfo.frame =  CGRect(x: x, y: y, width: 220, height: 120)
    }
    
    private func sceletonAnimatedStart() {
        coursesCollectionView.isSkeletonable = true
        coursesCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        avatar.isSkeletonable = true
        avatar.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        characteristic.isSkeletonable = true
        characteristic.linesCornerRadius = 5
        characteristic.skeletonTextNumberOfLines = 3
        characteristic.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        rating.isSkeletonable = true
        rating.linesCornerRadius = 5
        rating.skeletonTextNumberOfLines = 2
        rating.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        coursesCount.isSkeletonable = true
        coursesCount.linesCornerRadius = 5
        coursesCount.skeletonTextNumberOfLines = 2
        coursesCount.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        name.isSkeletonable = true
        name.linesCornerRadius = 5
        name.skeletonTextNumberOfLines = 0
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        verifyImage.isHidden = true
        ratingBottom.isHidden = true
        coursesCountBottom.isHidden = true
        name.isHidden = true
        
    }

    private func sceletonAnimatedStop() {
        coursesCollectionView.hideSkeleton(transition: .none)
        avatar.hideSkeleton(transition: .none)
        characteristic.hideSkeleton(transition: .none)
        rating.hideSkeleton(transition: .none)
        coursesCount.hideSkeleton(transition: .none)
        name.hideSkeleton(transition: .none)
        ratingBottom.isHidden = false
        coursesCountBottom.isHidden = false
        name.isHidden = false
        verifyImage.isHidden = false
    }
    
    func showUser() {
        characteristic.text = presenter.user.coach.description
        name.text = "\(presenter.user.surname) \(presenter.user.name)"
        avatar.sd_setImage(with: presenter.user.avatarURL)
    }
    
    func showMyCourses() {
        coursesCount.text = "\(presenter.courses.count)"
        rating.text = "\(presenter.averageRating())"
        coursesCollectionView.reloadData()
    }
    
    func showSceletonAnimated(bool: Bool) {
        if bool {
            sceletonAnimatedStart()
        }else {
            sceletonAnimatedStop()
        }
    }

    func showTip(bool: Bool) {
        if bool {
            verifyInfo.isHidden = false
        }else {
            verifyInfo.isHidden = true
        }
    }

    
    // MARK: - IBAction
    
    
    @IBAction func verifyInfo(_ sender: UIButton) {
        showTip(bool: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        showTip(bool: false)
    }
    
}

extension ProfileViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "course"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.courses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        descriptionCell(cell: cell, indexPath: indexPath)
        cell.image.sd_setImage(with: presenter.courses[indexPath.row].imageURL)
        return cell
    }
    
    private func descriptionCell(cell: CoursesCollectionViewCell, indexPath: IndexPath) {
        if presenter.courses[indexPath.row].isDraft {
            cell.isDraftView.isHidden = false
            switch presenter.courses[indexPath.row].verification {
            case .proccess:
                cell.descriptionDraft.text = "Черновик"
            case .noneVerificate:
                cell.descriptionDraft.text = "Отменено"
            case .proccessVerificate:
                cell.descriptionDraft.text = "Проверка"
            case .verificate:
                cell.isDraftView.isHidden = true
            }
        }else {
            cell.isDraftView.isHidden = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectCourse = presenter.courses[indexPath.row]
        performSegue(withIdentifier: "changeCourse", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "changeCourse" {
            let vc = segue.destination as! AddInfoAboutCourseVC
            vc.create = false
            vc.idCourse = presenter.selectCourse.id
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 3 - 2
        return CGSize(width: size, height: size)
    }

}
