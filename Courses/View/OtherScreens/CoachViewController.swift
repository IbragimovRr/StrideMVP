//
//  CoachViewController.swift
//  Courses
//
//  Created by Руслан on 04.08.2024.
//
import UIKit
import SDWebImage
import SkeletonView

class CoachViewController: UIViewController, ProfileViewDelegate {
    
    @IBOutlet weak var characteristic: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingBottom: UILabel!
    @IBOutlet weak var coursesCount: UILabel!
    @IBOutlet weak var coursesCountBottom: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var coursesCollectionView: UICollectionView!

    var presenter = ProfilePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.isMyProfile = false
        coursesCollectionView.delegate = self
        coursesCollectionView.dataSource = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillApear()
    }


    private func sceletonAnimatedStart() {
        coursesCollectionView.isSkeletonable = true
        coursesCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        avatar.isSkeletonable = true
        avatar.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        characteristic.isSkeletonable = true
        characteristic.linesCornerRadius = 5
        characteristic.skeletonTextNumberOfLines = 0
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
        name.skeletonTextNumberOfLines = 3
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        ratingBottom.isHidden = true
        coursesCountBottom.isHidden = true
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

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension CoachViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "course"
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.courses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: presenter.courses[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectCourse = presenter.courses[indexPath.row]
        performSegue(withIdentifier: "info", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "info" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = presenter.selectCourse
        }
        
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 3 - 2
        return CGSize(width: size, height: size)
    }

}
