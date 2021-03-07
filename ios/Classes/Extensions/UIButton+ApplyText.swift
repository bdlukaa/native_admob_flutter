import Foundation

extension UIButton{
    func applyText(data: Dictionary<String, Any>) -> Void{
        let view = self
        if let textSize = data["textSize"] as? Double{
            view.titleLabel?.font=view.titleLabel?.font.withSize(CGFloat(textSize))
        }
        
        if let textColor = data["textColor"] as? String{
            view.setTitleColor(UIColor(hexString:textColor), for: .normal)
        }
        
        if let letterSpacing = data["letterSpacing"] as? String{
            let attributedString = NSMutableAttributedString(string: view.titleLabel?.attributedText!.string ?? "")
            attributedString.addAttribute(NSAttributedString.Key.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedString.length - 1))
            view.setAttributedTitle(attributedString, for: .normal)
        }
        
        if let maxLines = data["maxLines"] as? Int{
            view.titleLabel?.numberOfLines = maxLines
        }
        
        if let bold = data["bold"] as? Bool{
            if(bold){
                view.titleLabel?.font=UIFont.systemFont(ofSize: view.titleLabel?.font.pointSize ?? 0, weight: .bold)
            }
            else{
                view.titleLabel?.font=UIFont.systemFont(ofSize: view.titleLabel?.font.pointSize ?? 0, weight: .regular)
            }
        }
        
        if let text = data["text"] as? String{
            view.setTitle(text, for: .normal)
        }
        
        view.titleLabel?.lineBreakMode = .byTruncatingTail
        
        
        
        return
    }
}
