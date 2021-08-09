
import UIKit
import Foundation


@IBDesignable
class CurrentExpenseVSBudget: UIView {

    var proportion: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    
    
    private let proportionLayer = CALayer()
    private let backgroundMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        layer.addSublayer(proportionLayer)
    }
    
    
    
  
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask

        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * proportion, height: rect.height))

        proportionLayer.frame = progressRect
        proportionLayer.backgroundColor = UIColor.orange.cgColor
        
        
    }


}
