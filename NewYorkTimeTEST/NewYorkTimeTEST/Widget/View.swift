import UIKit

class View: UIView {

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderIBColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var isCircle: Bool = false
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var gradientColor1: UIColor!
    @IBInspectable var gradientColor2: UIColor!
    
    var gLayer: CAGradientLayer!
    
    @IBInspectable var isInnerShadow: Bool = false
    @IBInspectable var isVerticalGradient: Bool = false
    @IBInspectable var isCardView: Bool = false
    
    var innerShadow: CALayer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        if cornerRadius > 0.0 {
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
        
        if gradientColor1 != nil && gradientColor2 != nil {
            gLayer = CAGradientLayer()
            
            gLayer.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
            gLayer.locations = [0.0, 1.0]
            
            if isVerticalGradient {
                gLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            } else {
                gLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            }
            
            self.layer.insertSublayer(gLayer, at: 0)
            self.clipsToBounds = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isCircle {
            let width = self.frame.width
            self.layer.cornerRadius = width / 2
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
        
        if isInnerShadow {
            addInnerShadow()
        }
        
        if isCardView {
            addCardShadow()
        }
        
        //  Update gradient
        if gradientColor1 != nil && gradientColor2 != nil {
            gLayer.frame = self.bounds
        }
    }
    
    private func addInnerShadow() {
        if innerShadow == nil {
            innerShadow = CALayer()
            innerShadow.frame = bounds
            
            // Shadow path (1pt ring around bounds)
            let radius = self.frame.size.height / 2
            let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -1, dy:-1), cornerRadius:radius)
            let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
            
            path.append(cutout)
            innerShadow.shadowPath = path.cgPath
            innerShadow.masksToBounds = true
            // Shadow properties
            innerShadow.shadowColor = UIColor.black.cgColor
            innerShadow.shadowOffset = CGSize(width: 0, height: 3)
            innerShadow.shadowOpacity = 0.5
            innerShadow.shadowRadius = (isCircle ? self.frame.size.height / 2 : cornerRadius)
            innerShadow.cornerRadius = (isCircle ? self.frame.size.height / 2 : cornerRadius)
            layer.addSublayer(innerShadow)
        }
    }
    
    private func addCardShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
    }

}

