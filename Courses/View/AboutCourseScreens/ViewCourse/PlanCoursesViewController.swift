//
//  PlanCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 24.01.2025.
//

import UIKit

protocol PlanCoursesViewDelegate {
    func setData()
    func setError(error: String)
    func savePlan()
}

extension PlanCoursesViewDelegate {
    func setError(error: String) {}
    func savePlan() {}
}

class PlanCoursesViewController: UIViewController, PlanCoursesViewDelegate {

    @IBOutlet weak var modulesCollectionView: UICollectionView!
    
    var presenter = PlanCoursesPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modulesCollectionView.delegate = self
        modulesCollectionView.dataSource = self
        presenter.view = self
        presenter.getData()
    }
    
    func setData() {
        modulesCollectionView.reloadData()
    }
    

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension PlanCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PlanHeaderCollectionReusableView
        cell.name.text = "Этап \(indexPath.section + 1)"
        cell.ishiddenTopView(index: indexPath.section)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.days[section].modules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
        guard presenter.days.isEmpty == false else { return cell }

        if let image = presenter.days[indexPath.section].modules[indexPath.row].module.imageURL {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageModule", for: indexPath) as! ModuleCourseCollectionViewCell
            cell.im.sd_setImage(with: image)
        }
        
        cell.cropBottomConstantinPlan(count: presenter.days[indexPath.section].modules.count - 1, index: indexPath.row)
        
        cell.blurEffect(isBlur: presenter.days[indexPath.section].modules[indexPath.row].module.isVisible)
        
        cell.typeModule(presenter.days[indexPath.section].modules[indexPath.row].type)
        
        cell.name.text = presenter.days[indexPath.section].modules[indexPath.row].module.name
        if presenter.days[indexPath.section].modules[indexPath.row].module.minutes == 0 {
            cell.time.isHidden = true
        }else {
            cell.time.isHidden = false
            cell.time.text = "\(presenter.days[indexPath.section].modules[indexPath.row].module.minutes) минут(ы/а)"
        }
        cell.descrLbl.text = presenter.days[indexPath.section].modules[indexPath.row].module.description
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if presenter.days[indexPath.section].modules.count - 1 == indexPath.row {
            return CGSize(width: collectionView.bounds.width, height: 120)
        }else {
            return CGSize(width: collectionView.bounds.width, height: 135)
        }
    }
}
