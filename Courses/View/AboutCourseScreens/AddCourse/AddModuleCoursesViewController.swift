//
//  AddModuleCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit
import Lottie

protocol AddModuleCoursesViewDelegate {
    func loading(bool: Bool)
    func showCourseInfo()
    func showDay()
    func showModule(position: Int)
    func deleteDay(dayID: Int)
    func showError(error: String)
}

class AddModuleCoursesViewController: UIViewController, AddModuleCoursesViewDelegate {
    

    @IBOutlet weak var successBtn: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourses: UILabel!
    @IBOutlet weak var heightViewDays: NSLayoutConstraint!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet weak var modulesCollectionView: UICollectionView!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()

    private let layout = PageModuleLayout()
    private var scaleView = false
    var presenter = AddModuleCoursesPresenter()
    var role: InfoCourses = .send

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionSettings()
        startPosition = errorView.center
        presenter.view = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingSettings()
        presenter.addCourseInfo()
    }

    
    private func checkRole() {
        guard role != .adminVerification else { successBtn.isHidden = false; return }
        
        switch presenter.course.verification {
        case .proccessVerificate:
            role = .send
            successBtn.isHidden = true
        case .noneVerificate:
            role = .nothing
            successBtn.isHidden = false
        case .proccess:
            role = .nothing
            successBtn.isHidden = false
        case .verificate:
            role = .send
            successBtn.isHidden = true
        }
    }


    private func collectionSettings() {
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        modulesCollectionView.delegate = self
        modulesCollectionView.dataSource = self
        addGestureRecognizeByCollectionView()

        layout.pageWidth = 350
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset.left = 5
        layout.sectionInset.right = 5
        layout.scrollDirection = .horizontal
        daysCollectionView.collectionViewLayout = layout
        daysCollectionView.decelerationRate = .fast
    }
    
    private func addGestureRecognizeByCollectionView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        modulesCollectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = modulesCollectionView else { return }
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.play()
        loading.isHidden = false
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        checkRole()
    }
    
    private func selectBack(deleteIndex: Int) {
        if presenter.selectDay == presenter.course.courseDays.count - 1 {
            presenter.selectDay -= 1
        }
    }

    
    func loading(bool: Bool) {
        if bool {
            loading.play()
        }else {
            loadingStop()
        }
    }
    
    func showCourseInfo() {
        nameCourses.text = presenter.course.nameCourse
        daysCollectionView.reloadData()
        modulesCollectionView.reloadData()
    }
    
    func showDay() {
        daysCollectionView.insertItems(at: [IndexPath(item: presenter.course.courseDays.count - 1, section: 0)])
    }
    
    func showModule(position: Int) {
        modulesCollectionView.insertItems(at: [IndexPath(item: position, section: 0)])
    }
    
    func deleteDay(dayID: Int) {
        for x in 0...presenter.course.courseDays.count - 1 {
            if presenter.course.courseDays[x].dayID == dayID {
                selectBack(deleteIndex: x)
                presenter.course.courseDays.remove(at: x)
                daysCollectionView.reloadData()
                modulesCollectionView.reloadData()
                break
            }
        }
    }
    
    func showError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
        view.addSubview(errorView)
    }
    

    
    @IBAction func success(_ sender: UIButton) {
        performSegue(withIdentifier: "preview", sender: self)
    }
    
    @IBAction func longClickInView(_ sender: UILongPressGestureRecognizer) {
        if scaleView == false {
            if sender.state == .began {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if sender.state == .ended {
                UIView.animate(withDuration: 0.5) {
                    self.layout.scrollDirection = .vertical
                    self.daysCollectionView.collectionViewLayout = self.layout
                    self.view.layoutIfNeeded()
                    var size = self.daysCollectionView.contentSize.height + 25
                    if size < 65 {size = 65}
                    self.heightViewDays.constant = size
                }
                scaleView = true
            }
        }else {
            if sender.state == .began {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if sender.state == .ended {
                UIView.animate(withDuration: 0.5) {
                    self.heightViewDays.constant = 65
                }
                self.layout.scrollDirection = .horizontal
                self.daysCollectionView.collectionViewLayout = self.layout
                self.view.layoutIfNeeded()
                scaleView = false
            }
        }

    }

    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension AddModuleCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == daysCollectionView {
            return presenter.course.courseDays.count + 1
        }else {
            if presenter.course.courseDays.isEmpty == false {
                return presenter.course.courseDays[presenter.selectDay].modules.count + 1
            }else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Day
        if collectionView == daysCollectionView {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCourseCollectionViewCell
            // Add +
            if indexPath.row == presenter.course.courseDays.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addDayCell", for: indexPath) as! DaysCourseCollectionViewCell
                return cell
            }else {
                cell.lbl.text = "\(indexPath.row + 1)"
                cell.delete.isHidden = false
                cell.delete.tag = presenter.course.courseDays[indexPath.row].dayID
                cell.delete.addTarget(self, action: #selector(deleteDayBtn), for: .touchUpInside)
                if presenter.selectDay == indexPath.row {
                    cell.current()
                    cell.delete.isHidden = true
                }else {
                    cell.before()
                }
            }
            return cell
        }else {
            // Modules
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell

            guard presenter.course.courseDays.isEmpty == false else { return cell }

            // Add +
            if indexPath.row == presenter.course.courseDays[presenter.selectDay].modules.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moduleAdd", for: indexPath) as! ModuleCourseCollectionViewCell
                return cell
            }

            if let image = presenter.course.courseDays[presenter.selectDay].modules[indexPath.row].module.imageURL {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.im.sd_setImage(with: image)
                cell.settingsBtn.tag = indexPath.row
                cell.settingsBtn.addTarget(self, action: #selector(settings), for: .touchUpInside)
            }else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module2", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.settingsBtn2.tag = indexPath.row
                cell.settingsBtn2.addTarget(self, action: #selector(settings), for: .touchUpInside)
            }
            cell.name.text = presenter.course.courseDays[presenter.selectDay].modules[indexPath.row].module.name
            if presenter.course.courseDays[presenter.selectDay].modules[indexPath.row].module.minutes == 0 {
                cell.time.isHidden = true
            }else {
                cell.time.isHidden = false
                cell.time.text = "\(presenter.course.courseDays[presenter.selectDay].modules[indexPath.row].module.minutes) минут(ы/а)"
            }
            cell.descrLbl.text = presenter.course.courseDays[presenter.selectDay].modules[indexPath.row].module.description
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == daysCollectionView {

            if indexPath.row == presenter.course.courseDays.count {
                presenter.addDay()
            }else{
                presenter.selectDay = indexPath.row
            }
            modulesCollectionView.reloadData()
            daysCollectionView.reloadData()
        }else {

            if indexPath.row == presenter.course.courseDays[presenter.selectDay].modules.count {
                
//                presenter.addModule(dayID: presenter.course.courseDays[presenter.selectDay].dayID, position: indexPath.row)
                performSegue(withIdentifier: "addModule", sender: self)
            }else {
                presenter.selectModule = presenter.course.courseDays[presenter.selectDay].modules[indexPath.row]
                switch presenter.selectModule?.type {
                case .custom:
                    performSegue(withIdentifier: "goToAddCourse2", sender: self)
                case .video:
                    performSegue(withIdentifier: "goToAddVideoModule", sender: self)
                case .training:
                    performSegue(withIdentifier: "goToAddTrainingModule", sender: self)
                case .none:
                    break
                }
            }

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goToAddCourse2" {
            let vc = segue.destination as! AddCourseViewController
            vc.presenter.module = presenter.selectModule as! CustomModule
        }else if segue.identifier == "goToAddVideoModule" {
            let vc = segue.destination as! AddVideoModuleViewController
            vc.presenter.module = presenter.selectModule as! VideoModule
        }else if segue.identifier == "goToModuleSettings" {
            let vc = segue.destination as! AddInfoAboutModuleViewController
            vc.module = presenter.selectModule!.module
            vc.delegate = self
        }else if segue.identifier == "preview" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.presenter.course.id = presenter.course.id
            vc.interface = role
        }else if segue.identifier == "addModule" {
            let vc = segue.destination as! TypeModuleViewController
            vc.delegate = self
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        if collectionView == daysCollectionView {
            let result = 40
            return CGSize(width: result, height: result)
        }else {
            return CGSize(width: width, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == presenter.course.courseDays[presenter.selectDay].modules.count {
            return false
        }else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row != presenter.course.courseDays[presenter.selectDay].modules.count else {
            collectionView.moveItem(at: destinationIndexPath, to: sourceIndexPath)
            return
        }
        
        var module = presenter.course.courseDays[presenter.selectDay].modules[sourceIndexPath.row].module
        module.position = destinationIndexPath.row + 1
        presenter.changePositionModule(module: module)
        let movedModule = presenter.course.courseDays[presenter.selectDay].modules.remove(at: sourceIndexPath.row)
        presenter.course.courseDays[presenter.selectDay].modules.insert(movedModule, at: destinationIndexPath.row)
        modulesCollectionView.reloadData()
        
    }

    @objc func deleteDayBtn(sender: UIButton) {
        let alert = UIAlertController(title: "Удалить данные?", message: "Вы уверены, что хотите удалить этот день? Это действие невозможно отменить.", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.presenter.deleteDay(dayID: sender.tag)
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            self.dismiss(animated: true)
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)

    }

    @objc func settings(sender: UIButton) {
        presenter.selectModule = presenter.course.courseDays[presenter.selectDay].modules[sender.tag]
        performSegue(withIdentifier: "goToModuleSettings", sender: self)
    }

}
extension AddModuleCoursesViewController: ChangeInfoModule, TypeModuleDelegate {
    
    func addModule(type: ModuleType) {
        var module: ModuleProtocol!
        switch type {
        case .custom:
            module = CustomModule(module: Modules(name: "", minutes: 0, id: 0))
        case .video:
            module = VideoModule(module: Modules(name: "", minutes: 0, id: 0))
        case .training:
            module = TrainingModule(module: Modules(name: "", minutes: 0, id: 0))
        }
        presenter.course.courseDays[presenter.selectDay].modules.append(module)
        modulesCollectionView.reloadData()
    }
    

    func changeInfoModuleDismiss(module: Modules, moduleID: Int) {
        for x in 0...presenter.course.courseDays[presenter.selectDay].modules.count - 1 {
            if presenter.course.courseDays[presenter.selectDay].modules[x].module.id == moduleID {
                presenter.course.courseDays[presenter.selectDay].modules[x].module = module
                modulesCollectionView.reloadData()
            }
        }
    }

    func deleteModuleDismiss(moduleID: Int) {
        for x in 0...presenter.course.courseDays[presenter.selectDay].modules.count - 1 {
            if presenter.course.courseDays[presenter.selectDay].modules[x].module.id == moduleID {
                presenter.course.courseDays[presenter.selectDay].modules.remove(at: x)
                modulesCollectionView.reloadData()
                break
            }
        }
    }

}
