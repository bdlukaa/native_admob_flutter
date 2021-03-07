import Foundation

class CustomUILabel :  UILabel{
    var UIEI = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // as desired
    var maxLines:Int = 0

    init(data: Dictionary<String, Any>) {
        super.init(frame: .zero)

        let view = self
        if let textSize = data["textSize"] as? Double{
            view.font=view.font.withSize(CGFloat(textSize))
        }
        
        if let textColor = data["textColor"] as? String{
            view.textColor = UIColor(hexString:textColor)
        }
        
        if let letterSpacing = data["letterSpacing"] as? String{
            let attributedString = NSMutableAttributedString(string: attributedText!.string)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
        
        if let maxLines = data["maxLines"] as? Int{
            view.numberOfLines = maxLines
            self.maxLines = maxLines
        }
        
        if let bold = data["bold"] as? Bool{
            if(bold){
                view.font=UIFont.systemFont(ofSize: view.font.pointSize, weight: .bold)
            }
            else{
                view.font=UIFont.systemFont(ofSize: view.font.pointSize, weight: .regular)
                
            }
        }
        
        if let text = data["text"] as? String{
            view.text=text
        }
        
        let paddingRight = CGFloat(data["paddingRight"] as? Float ?? 0)
        let paddingLeft = CGFloat(data["paddingLeft"] as? Float ?? 0)
        let paddingTop = CGFloat(data["paddingTop"] as? Float ?? 0)
        let paddingBottom = CGFloat(data["paddingBottom"] as? Float ?? 0)
        
        UIEI = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)

        view.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize:CGSize {
        var s = super.intrinsicContentSize
        s.height = s.height + UIEI.top + UIEI.bottom
        s.width = s.width + UIEI.left + UIEI.right
        return s
    }

    override func drawText(in rect:CGRect) {
        let r = rect.inset(by: UIEI)
        super.drawText(in: r)
    }

    override func textRect(forBounds bounds:CGRect,
                               limitedToNumberOfLines n:Int) -> CGRect {
        let b = bounds
        let tr = b.inset(by: UIEI)
        let ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: maxLines)
        // that line of code MUST be LAST in this function, NOT first
        return ctr
    }
}
