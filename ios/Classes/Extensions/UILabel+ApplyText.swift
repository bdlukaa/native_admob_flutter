import Foundation

extension UILabel{
    func applyText(data: Dictionary<String, Any>) -> Void{
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
        
        view.lineBreakMode = .byTruncatingTail
        
        return
    }
}
