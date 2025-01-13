//
//  InfoCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import UIKit
import SkeletonView
import SDWebImage

protocol InfoCoursesViewDelegate {
    func promoSuccess(promo: PromocodeModel)
    func promoCancel()
    func showCourses()
    func showSimilarCourses()
    func showComments()
    func showSceletonLoading(bool: Bool)
    func buyCoursesSuccessed()
    func verificationCourse(bool: Bool)
    func showError(error: String)
    func showSuccess()
    func showVerification()
}

class InfoCoursesViewController: UIViewController, InfoCoursesViewDelegate {

    @IBOutlet weak var promoMainText: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var promoMainBtn: UIButton!
    @IBOutlet weak var promoSuccessInfo: UILabel!
    @IBOutlet weak var promoSucces: UIImageView!
    @IBOutlet weak var promoInfoView: UIView!
    @IBOutlet weak var promoTextField: UITextField!
    @IBOutlet weak var similarCourseLbl: UILabel!
    @IBOutlet weak var similarCoursesCollectionView: UICollectionView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var stackInfo: UIStackView!
    @IBOutlet weak var countDays: UILabel!
    @IBOutlet weak var topScrollConstant: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnAdmin: UIButton!
    @IBOutlet weak var stackBtn: UIStackView!
    @IBOutlet weak var reviewsLbl: UILabel!
    @IBOutlet weak var reviewsConstant: NSLayoutConstraint!
    @IBOutlet weak var similarConstant: NSLayoutConstraint!
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var coachName: UILabel!
    @IBOutlet weak var reviewsCollectionView: UICollectionView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countBuyer: UILabel!
    @IBOutlet weak var dateCreate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var btnView: UIButton!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    var presenter = InfoCoursePresenter()
    
    var interface: InfoCourses = .nothing
    var promocode: PromocodeModel? = nil {
        didSet {
            if let promocode = promocode {
                promoSuccessDesign(promo: promocode)
            }
        }
    }
    var price: Int = 0 {
        didSet {
            priceLbl.text = "₽\(price)"
        }
    }
    var sale: Int? = nil {
        didSet {
            if sale != nil {
                oldPrice.attributedText = "₽\(price)".strikeText()
                price = price - sale!
                oldPrice.isHidden = false
            }else {
                oldPrice.isHidden = true
                if let oldValue = oldValue {
                    price = price + oldValue
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        reviewsCollectionView.delegate = self
        reviewsCollectionView.dataSource = self
        similarCoursesCollectionView.delegate = self
        similarCoursesCollectionView.dataSource = self
        promoTextField.delegate = self
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeCollectionViewHeight()
    }
    
    func showError(error: String) {
        errorView.isHidden = false
        errorView.configure(title: "Ошибка", description: error)
    }
    
    func showSuccess() {
        errorView.configureSuccess(title: "Успешно", description: "Проверим в течение 48 часов")
        errorView.isHidden = false
    }
    
    func promoSuccess(promo: PromocodeModel) {
        promocode = promo
        promoMainBtn.tag = 1
    }
    
    func promoCancel() {
        promoMainBtn.tag = 0
    }
    
    func showCourses() {
        design()
    }
    
    func showVerification() {
        interfaceCheck()
    }
    
    func showSimilarCourses() {
        deleteSelectCoursesInSimilar()
        designSimilarCourse()
        similarCoursesCollectionView.reloadData()
        changeCollectionViewHeight()
        similarCoursesCollectionView.invalidateIntrinsicContentSize()
        self.view.layoutIfNeeded()
    }
    
    func showComments() {
        reviewsCollectionView.reloadData()
        changeCollectionViewHeight()
        checkReviewsCount()
        reviewsCollectionView.invalidateIntrinsicContentSize()
        self.view.layoutIfNeeded()
    }
    
    func showSceletonLoading(bool: Bool) {
        if bool {
            sceletonAnimatedStart()
        }else {
            sceletonAnimatedStop()
        }
    }
    
    func buyCoursesSuccessed() {
        performSegue(withIdentifier: "goCourse", sender: self)
    }
    
    func verificationCourse(bool: Bool) {
        if bool {
            let adminMainVC = navigationController!.viewControllers[navigationController!.viewControllers.count - 4]
            navigationController?.popToViewController(adminMainVC, animated: true)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func designSimilarCourse() {
        if presenter.similarCourse.isEmpty {
            similarCourseLbl.isHidden = true
        }
    }
    
    private func deleteSelectCoursesInSimilar() {
        guard presenter.similarCourse.isEmpty == false else { return }
        for x in 0...presenter.similarCourse.count - 1 {
            if presenter.course.id == presenter.similarCourse[x].id {
                presenter.similarCourse.remove(at: x)
                return
            }
        }
    }

    private func checkReviewsCount() {
        if presenter.reviews.isEmpty {
            reviewsLbl.text = "Нет отзывов"
        }else {
            reviewsLbl.text = "Отзывы"
        }
    }


    private func design() {
        sceletonAnimatedStop()
        price = presenter.course.price
        descriptionText.text = presenter.course.description
        dateCreate.text = presenter.course.dataCreated
        rating.text = "\(presenter.course.rating)"
        countDays.text = "\(presenter.course.daysCount)"
        name.text = presenter.course.nameCourse
        coachName.text = presenter.course.author.userName
        im.sd_setImage(with: presenter.course.imageURL)
        countBuyer.text = "\(presenter.course.countBuyer)"
        categoryLbl.text = presenter.course.category.nameCategory
        userAvatar.sd_setImage(with: presenter.course.author.avatarURL)
        interfaceCheck()
        interfaceDesign()
    }
    
    private func sceletonAnimatedStart() {
        reviewsCollectionView.isSkeletonable = true
        reviewsCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        name.isSkeletonable = true
        name.linesCornerRadius = 5
        name.skeletonTextNumberOfLines = 2
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        descriptionView.isSkeletonable = true
        descriptionView.skeletonCornerRadius = 15
        descriptionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        stackInfo.isSkeletonable = true
        stackInfo.skeletonCornerRadius = 15
        stackInfo.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        stackBtn.isHidden = true
        dateCreate.isHidden = true
        categoryLbl.isHidden = true
    }
    
    private func sceletonAnimatedStop() {
        reviewsCollectionView.hideSkeleton(transition: .none)
        im.hideSkeleton(transition: .none)
        name.hideSkeleton(transition: .none)
        descriptionView.hideSkeleton(transition: .none)
        stackInfo.hideSkeleton(transition: .none)
        stackBtn.isHidden = false
        dateCreate.isHidden = false
        categoryLbl.isHidden = false
    }

    private func interfaceCheck() {
        guard interface != .adminVerification else { return }
        
        if myCourse() == true {
            switch presenter.course.verification {
            case .proccessVerificate:
                interface = .nothing
            case .noneVerificate:
                interface = .send
            case .proccess:
                interface = .send
            case .verificate:
                interface = .nothing
            }
            return
        }

        if presenter.course.isBought == true {
            if presenter.course.mySendRating == 0 {
                interface = .review
                return
            }else {
                interface = .nothing
                return
            }
        }else {
            interface = .bought
            return
        }
    }
    
    private func interfaceDesign() {
        switch interface {
        case .bought:
            buyView.isHidden = false
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .review:
            btnView.setTitle("Оставить отзыв", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .send:
            btnView.setTitle("Отправить на проверку", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .nothing:
            btnView.isHidden = true
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .adminVerification:
            btnView.setTitle("Подтвердить", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = false
            buyView.isHidden = true
            stackBtn.distribution = .fillEqually
        }
    }
    
    private func myCourse() -> Bool {
        if UserServices.info.id == presenter.course.author.id {
            btnView.isHidden = true
            return true
        }else {
            return false
        }
    }

    private func changeCollectionViewHeight() {
        let heightConstant = -self.view.safeAreaInsets.top
        topScrollConstant.constant = heightConstant
        reviewsConstant.constant = reviewsCollectionView.contentSize.height
        similarConstant.constant = similarCoursesCollectionView.contentSize.height
        self.view.layoutIfNeeded()
    }
    
    private func promoSuccessDesign(promo: PromocodeModel) {
        promoSucces.isHidden = false
        promoSuccessInfo.isHidden = false
        promoMainText.isHidden = false
        promoTextField.isHidden = true
        promoTextField.resignFirstResponder()
        promoMainText.text = promo.name
        let saleAfterPromo = Double(price) / 100.00 * Double(promo.procent)
        promoSuccessInfo.text = "\(promo.procent)% cкидка (-₽\(Int(saleAfterPromo)).00)"
        sale = Int(saleAfterPromo)
        promoMainBtn.setTitle("", for: .normal)
        promoMainBtn.setImage(UIImage.closeGray, for: .normal)
    }
    
    private func promoClose() {
        promoSucces.isHidden = true
        promoSuccessInfo.isHidden = true
        promoMainText.isHidden = true
        promoTextField.isHidden = false
        sale = nil
        promocode = nil
        promoMainBtn.setTitle("Подтвердить", for: .normal)
        promoMainBtn.setImage(nil, for: .normal)
    }

    @IBAction func coach(_ sender: UIButton) {
        performSegue(withIdentifier: "coach", sender: self)
    }
    
    @IBAction func promoSelect(_ sender: UIButton) {
        if sender.tag == 0 {
            presenter.usedPromocode(promo: promoTextField.text!)
            sender.tag = 1
        }else {
            promoClose()
            sender.tag = 0
        }
    }
    
    @IBAction func buy(_ sender: UIButton) {
        if interface == .review {
            performSegue(withIdentifier: "goToAddReview", sender: self)
        }else if interface == .bought {
            presenter.buyCourse(self, price: price, promocode: promocode)
        }else if interface == .send {
            presenter.sendCoursesVerification()
        }else if interface == .adminVerification {
            if sender.tag == 0 {
                presenter.successVerification()
            }else {
                presenter.cancelVerfication()
            }
        }
    }
    
    
    

    @IBAction func share(_ sender: UIButton) {
        let link = DeepLinksManager.getLinkAboutCourse(idCourse: presenter.course.id)
        DeepLinksManager.openShareViewController(url: link, self)
    }
    
    
    @IBAction func infoAboutPromo(_ sender: UIButton) {
        if sender.tag == 0 {
            promoInfoView.isHidden = false
        }else {
            promoInfoView.isHidden = true
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "coach" {
            let vc = segue.destination as! CoachViewController
            vc.presenter.user = presenter.course.author
        }else if segue.identifier == "goCourse" {
            let vc = segue.destination as! ModulesCourseViewController
            vc.idCourse = presenter.course.id
        }else if segue.identifier == "goToAddReview" {
            let vc = segue.destination as! AddReviewViewController
            vc.idCourse = presenter.course.id
        }
    }

    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        promoTextField.resignFirstResponder()
    }
    
}
extension InfoCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == reviewsCollectionView {
            return presenter.reviews.count
        }else {
            return presenter.similarCourse.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == reviewsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviews", for: indexPath) as! ReviewsCollectionViewCell
            cell.avatar.sd_setImage(with: presenter.reviews[indexPath.row].authorAvatar)
            cell.descriptionText.text = presenter.reviews[indexPath.row].text
            cell.data.text = presenter.reviews[indexPath.row].date
            cell.name.text = presenter.reviews[indexPath.row].author
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: presenter.similarCourse[indexPath.row].imageURL)
            cell.nameAuthor.text = presenter.similarCourse[indexPath.row].author.userName
            cell.nameCourse.text = presenter.similarCourse[indexPath.row].nameCourse
            cell.price.text = "\(presenter.similarCourse[indexPath.row].price)₽"
            cell.rating.text = "\(presenter.similarCourse[indexPath.row].rating)"
            cell.daysCount.text = "\(presenter.similarCourse[indexPath.row].daysCount) этапов"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarCoursesCollectionView {
            openCourse(courseID: presenter.similarCourse[indexPath.row].id)
        }
    }
    
    private func openCourse(courseID: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "InfoCoursesViewController") as? InfoCoursesViewController else { return }
        
        vc.presenter.course.id = courseID
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == reviewsCollectionView {
            let textView = UITextView()
            textView.font = UIFont(name: "Commissioner-Medium", size: 12)!
            textView.text = presenter.reviews[indexPath.row].text
            let textSize = textView.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: collectionView.bounds.width, height: textSize.height + 55)
        }else {
            let width = UIScreen.main.bounds.width / 2 - 30
            return CGSize(width: width, height: 180)
        }
    }


}
extension InfoCoursesViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        promoMainBtn.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            promoMainBtn.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let characterSet = CharacterSet(charactersIn: string.uppercased())
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.uppercased()
    }
    
}
