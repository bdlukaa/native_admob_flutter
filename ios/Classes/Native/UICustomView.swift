import Foundation

class UICustomView: UIStackView {
    
    private let gradientLayer : CAGradientLayer = CAGradientLayer()
    private let shapeMask : CAShapeLayer = CAShapeLayer()
    private let borderLayer : CAShapeLayer = CAShapeLayer()
    private var path :UIBezierPath = UIBezierPath()
    private var gradientBackgroundColor: UIColor = UIColor(white: 1, alpha: 0)
    private var borderColor: UIColor = UIColor(white: 1, alpha: 0)
    private var gradientStartColor: UIColor = UIColor(white: 1, alpha: 0)
    private var gradientEndColor: UIColor = UIColor(white: 1, alpha: 0)
    private var startPoint: CGPoint = CGPoint.zero
    private var endPoint: CGPoint = CGPoint.zero
    private var topRight : Float = 0.0
    private var topLeft :Float = 0.0
    private var bottomRight :Float = 0.0
    private var bottomLeft : Float = 0.0
    private var topRightRadius :CGFloat = 0.0
    private var topLeftRadius :CGFloat = 0.0
    private var bottomRightRadius :CGFloat = 0.0
    private var bottomLeftRadius:CGFloat = 0.0
    private var marginRight :CGFloat = 0.0
    private var marginLeft :CGFloat = 0.0
    private var marginTop :CGFloat = 0.0
    private var marginBottom:CGFloat = 0.0
    private var borderWidth :CGFloat = 0.0
        
    init(data : [String:Any]) {
        if let  gradient = data["gradient"] as? [String:Any], let colors = gradient["colors"] as? Array<String>, let orientation = gradient["orientation"] as? String, let type = gradient["type"] as? String,
           let radialGradientCenterX = gradient["radialGradientCenterX"] as? Float,let radialGradientCenterY = gradient["radialGradientCenterY"] as? Float
           ,let radialGradientRadius = gradient["radialGradientRadius"] as? Int
        {
            self.gradientStartColor = UIColor(hexString: colors[1])
            self.gradientEndColor = UIColor(hexString: colors[0])
            switch orientation{
            case "top_bottom" :
                self.startPoint = CGPoint(x: 0.5, y: 0.0);
                self.endPoint = CGPoint(x: 0.5, y: 1.0);
            case "tr_bl" :
                self.startPoint = CGPoint(x: 1.0, y: 0.0);
                self.endPoint = CGPoint(x: 0.0, y: 1.0);
            case "right_left" :
                self.startPoint = CGPoint(x: 1.0, y: 0.5);
                self.endPoint = CGPoint(x: 0.0, y: 0.5);
            case "br_tl" :
                self.startPoint = CGPoint(x: 1.0, y: 1.0);
                self.endPoint = CGPoint(x: 0.0, y: 0.0);
            case "bottom_top" :
                self.startPoint = CGPoint(x: 0.5, y: 1.0);
                self.endPoint = CGPoint(x: 0.5, y: 0.0);
            case "bl_tr" :
                self.startPoint = CGPoint(x: 0.0, y: 1.0);
                self.endPoint = CGPoint(x: 1.0, y: 0.0);
            case "left_right" :
                self.startPoint = CGPoint(x: 0.0, y: 0.5);
                self.endPoint = CGPoint(x: 1.0, y: 0.5);
            case "tl_br" :
                self.startPoint = CGPoint(x: 0.0, y: 0.0);
                self.endPoint = CGPoint(x: 1.0, y: 1.0);
            default:
                self.startPoint = CGPoint(x: 0.0, y: 0.5);
                self.endPoint = CGPoint(x: 1.0, y: 0.5);
            }
            
            switch type{
            case "linear" :
                gradientLayer.type = .axial
            case "radial" :
                gradientLayer.type = .radial
                var location : Float = Float(radialGradientRadius.dpReverse())/200
                let gradientLocation = colors.map({ (hex) -> NSNumber in
                    if(colors.firstIndex(of: hex) == 0){return 0.0}
                    let res = NSNumber(value: location)
                    location *= 2
                    return res
                })
                gradientLayer.locations = gradientLocation
                self.startPoint=CGPoint(x: CGFloat(radialGradientCenterX), y: CGFloat(radialGradientCenterY))
                self.endPoint=CGPoint(x: 1, y: 1)
                
            default:
                gradientLayer.type=CAGradientLayerType.axial
            }
        }
        super.init(frame: .zero)
        
        marginRight = CGFloat((data["marginRight"] as? Int ?? 0))
        marginLeft=CGFloat((data["marginLeft"] as? Int ?? 0))
        marginTop=CGFloat((data["marginTop"] as? Int ?? 0))
        marginBottom=CGFloat((data["marginBottom"] as? Int ?? 0))
        if #available(iOS 11.0, *) {
            isLayoutMarginsRelativeArrangement = true
            directionalLayoutMargins=NSDirectionalEdgeInsets(top: CGFloat(marginTop), leading: CGFloat(marginLeft), bottom: CGFloat(marginBottom), trailing: CGFloat(marginRight))
        } else {
            layoutMargins=UIEdgeInsets(top: CGFloat(marginTop), left: CGFloat(marginLeft), bottom: CGFloat(marginBottom), right: CGFloat(marginRight))
        }
        
        
        if let borderWidth = data["borderWidth"] as? Int, let borderColor = data["borderColor"] as? String{
            self.borderColor = UIColor(hexString: borderColor)
            self.borderWidth = CGFloat(borderWidth.dp())
        }
        
        if let backgroundColor = data["backgroundColor"] as? String{
            gradientBackgroundColor=UIColor(hexString: backgroundColor)
        }
        
        topRightRadius = CGFloat((data["topRightRadius"] as? Int ?? 0).dpReverse())
        topLeftRadius = CGFloat((data["topLeftRadius"] as? Int ?? 0).dpReverse())
        bottomRightRadius = CGFloat((data["bottomRightRadius"] as? Int ?? 0).dpReverse())
        bottomLeftRadius = CGFloat((data["bottomLeftRadius"] as? Int ?? 0).dpReverse())
        path = UIBezierPath(shouldRoundRect: getFrameWithMargin(), topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)

        
    }
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = bounds
    }
    
    override public func draw(_ rect: CGRect) {
        gradientLayer.frame = bounds
        gradientLayer.colors = [gradientEndColor.cgColor, gradientStartColor.cgColor]
        gradientLayer.backgroundColor = gradientBackgroundColor.cgColor
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderWidth
        shapeMask.frame=bounds
        path = UIBezierPath(shouldRoundRect: getFrameWithMargin(), topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        shapeMask.path = path.cgPath
        gradientLayer.mask = shapeMask
        borderLayer.path = path.cgPath
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        if borderLayer.superlayer == nil {
            gradientLayer.insertSublayer(borderLayer, at: 0)
        }
        super.draw(rect)
    }
    
    func getFrameWithMargin() -> CGRect {
        let x :CGFloat = self.bounds.minX + marginLeft
        let y :CGFloat = self.bounds.minY  + marginTop
        let width :CGFloat = self.bounds.maxX  - marginRight
        let height :CGFloat = self.bounds.maxY - marginBottom
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
