import UIKit

class TipVerificate: UIView {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBInspectable
    var color: UIColor = UIColor.lightBlackMain {
        didSet {
            mainView.backgroundColor = color
            updateArrowColor()
        }
    }
    
    private let arrowView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        if let view = UINib(nibName: "TipVerificate", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.frame = bounds
            addSubview(view)
        }
        
        createArrow()
    }
    
    private func createArrow() {
        arrowView.frame = CGRect(x: 187, y: 0, width: 16, height: 8)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 16, y: 8))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        arrowView.layer.addSublayer(shapeLayer)
        
        addSubview(arrowView)
    }
    
    private func updateArrowColor() {
        if let shapeLayer = arrowView.layer.sublayers?.first as? CAShapeLayer {
            shapeLayer.fillColor = color.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrowView.frame = CGRect(x: 187, y: 0, width: 16, height: 8)
    }
}
