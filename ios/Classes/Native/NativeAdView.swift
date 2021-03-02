import Flutter
import GoogleMobileAds

class NativeAdView : NSObject,FlutterPlatformView {
    
    var data:Dictionary<String, Any>?
    private let channel: FlutterMethodChannel
    
    private var adView: GADNativeAdView
    
    private var ratingBar: UIImageView? = UIImageView()
    private var adMedia: GADMediaView? = GADMediaView()
    private var adIcon: UIImageView? = UIImageView()
    private var adHeadline: UILabel? = UILabel()
    private var adAdvertiser: UILabel? = UILabel()
    private var adBody: UILabel? = UILabel()
    private var adPrice: UILabel? = UILabel()
    private var adStore: UILabel? = UILabel()
    private var adAttribution: UILabel? = UILabel()
    private var callToAction: UIButton? = UIButton()
    
    private var controller: NativeAdController? = nil
    
    
    init(data: Dictionary<String, Any>?, messenger: FlutterBinaryMessenger) {
        self.data=data
        channel = FlutterMethodChannel(name: "native_admob", binaryMessenger: messenger)
        self.adView=GADNativeAdView()
        super.init()
        adView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        let builtView = buildView(data: data!)
        builtView.frame=adView.bounds
        self.adView.addSubview(builtView)
        define()
        if let controllerId = data?["controllerId"] as? String,
           let controller = NativeAdControllerManager.shared.getController(forID: controllerId) {
            self.controller = controller
            controller.nativeAdChanged = setNativeAd
            controller.nativeAdUpdateRequested = { (layout: Dictionary<String, Any>?, ad: GADNativeAd?) -> Void in
                self.adView=GADNativeAdView()
                self.adView.addSubview(self.buildView(data: layout!))
                self.define()
                self.setNativeAd(nativeAd: ad)
            }
        }
        
        if let nativeAd = controller?.nativeAd {
            setNativeAd(nativeAd: nativeAd)
        }
        
    }
    
    private func buildView(data: Dictionary<String, Any>)-> UIView {
        let viewType: String? = data["viewType"] as? String
        var view :UIView = UIView()
        
        if (viewType != nil){
            switch (viewType) {
            case "linear_layout" :
                view=UIStackView()
//                (view as! UIStackView).translatesAutoresizingMaskIntoConstraints=false
                (view as! UIStackView).distribution = .fillProportionally
                
                if data["orientation"] as! String == "vertical"{
                    (view as! UIStackView).axis = NSLayoutConstraint.Axis.vertical
                } else {
                    (view as! UIStackView).axis = NSLayoutConstraint.Axis.horizontal
                }
                switch data["gravity"] as? String {
                case "center":
                    (view as! UIStackView).alignment = .center
                case "center_horizontal":
                    (view as! UIStackView).alignment = .center
                case "center_vertical":
                    (view as! UIStackView).alignment = .center
                case "left":
                    (view as! UIStackView).alignment = .leading
                case "right":
                    (view as! UIStackView).alignment = .trailing
                case "top":
                    (view as! UIStackView).alignment = .top
                case "bottom":
                    (view as! UIStackView).alignment = .bottom
                default:
                    (view as! UIStackView).alignment = .top
                }
                if (data["children"] != nil){
                    for child in data["children"] as! Array<Any>{
                        (view as! UIStackView).addArrangedSubview(buildView(data: child as! Dictionary<String, Any>))
                    }
                }
            case "text_view" :
                view = UILabel()
                (view as! UILabel).applyText(data: data)
            case "image_view" :
                view = UIImageView()
            case "media_view" :
                view = GADMediaView()
            case "rating_bar" :
                view = UIImageView()
            case "button_view" :
                view = UIButton()
            case .none:
                print("none")
            case .some(_):
                print("some")
            }
            
        }

        
        let shape = CAGradientLayer()
        let gradient: Dictionary<String,Any>? = data["gradient"] as? Dictionary<String,Any>
        
        if(gradient != nil){
            print("\n")
            print(view.subviews)
            print("\n")
            switch gradient?["orientation"] as! String{
            case "top_bottom" :
                shape.startPoint = CGPoint(x: 0.5, y: 0.0);
                shape.endPoint = CGPoint(x: 0.5, y: 1.0);
            case "tr_bl" :
                shape.startPoint = CGPoint(x: 1.0, y: 0.0);
                shape.endPoint = CGPoint(x: 0.0, y: 1.0);
            case "right_left" :
                shape.startPoint = CGPoint(x: 1.0, y: 0.5);
                shape.endPoint = CGPoint(x: 0.0, y: 0.5);
            case "br_tl" :
                shape.startPoint = CGPoint(x: 1.0, y: 1.0);
                shape.endPoint = CGPoint(x: 0.0, y: 0.0);
            case "bottom_top" :
                shape.startPoint = CGPoint(x: 0.5, y: 1.0);
                shape.endPoint = CGPoint(x: 0.5, y: 0.0);
            case "bl_tr" :
                shape.startPoint = CGPoint(x: 0.0, y: 1.0);
                shape.endPoint = CGPoint(x: 1.0, y: 0.0);
            case "left_right" :
                shape.startPoint = CGPoint(x: 0.0, y: 0.5);
                shape.endPoint = CGPoint(x: 1.0, y: 0.5);
            case "tl_br" :
                shape.startPoint = CGPoint(x: 0.0, y: 0.0);
                shape.endPoint = CGPoint(x: 1.0, y: 1.0);
            default:
                shape.startPoint = CGPoint(x: 0.0, y: 0.5);
                shape.endPoint = CGPoint(x: 1.0, y: 0.5);
            }
            
            let colors: Array<CGColor> = (data["colors"] as? Array<String> ?? ["#ffffff","#ffffff"]).map { UIColor(hexString: $0).cgColor };
            shape.colors=colors
            
            switch gradient?["type"] as! String{
            case "linear" :
                shape.type=CAGradientLayerType.axial
            case "radial" :
                shape.type=CAGradientLayerType.radial
            default:
                shape.type=CAGradientLayerType.axial
            }
        }
     
        // radius
        shape.cornerRadius=CGFloat(data["topRightRadius"] as? Double ?? 00)
        
        shape.borderWidth=CGFloat(data["borderWidth"] as? Double ?? 0);
        shape.borderColor=UIColor(hexString: data["borderColor"] as? String ?? "#ffffff").cgColor
        
        shape.backgroundColor=UIColor(hexString: (data["backgroundColor"] as? String ?? "#ffffff")).cgColor
        
        view.layer.insertSublayer(shape, at: 0)
        
        // bounds
        let paddingRight = (data["paddingRight"] as? Double)
        let paddingLeft=(data["paddingLeft"] as? Double)
        let paddingTop=(data["paddingTop"] as? Double)
        let paddingBottom=(data["paddingBottom"] as? Double)
        view.layoutMargins=UIEdgeInsets(top: CGFloat(paddingTop ?? 0), left: CGFloat(paddingLeft ?? 0), bottom: CGFloat(paddingBottom ?? 0), right: CGFloat(paddingRight ?? 0))
        
        if let height =  data["height"], let width = data["width"] {
            let dpHeight = Int(height as! Float).dp()
            let dpWidth = Int(width as! Float).dp()
            view.frame.size.width=CGFloat(dpWidth)
            view.frame.size.height=CGFloat(dpHeight)
            view.sizeThatFits(CGSize(width: CGFloat(dpWidth), height: CGFloat(dpHeight)))
        }

        
        
        switch data["id"] as! String{
        case "advertiser" : adAdvertiser = view as? UILabel
        case "attribution" : adAttribution = view as? UILabel
        case "body" : adBody = view as? UILabel
        case "button" : callToAction = view as? UIButton
        case "headline" : adHeadline = view as? UILabel
        case "icon" : adIcon = view as? UIImageView
        case "media" : adMedia = view as? GADMediaView
        case "price" : adPrice = view as? UILabel
        case "ratingBar" : ratingBar = view as? UIImageView
        case "store" : adStore = view as? UILabel
        default:
            print("")
        }

        return view
    }
    
    func view() -> UIView {
        return adView
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    private func define() {
        self.adView.mediaView = adMedia
        self.adView.headlineView = adHeadline
        self.adView.bodyView = adBody
        self.adView.callToActionView = callToAction
        self.adView.iconView = adIcon
        self.adView.priceView = adPrice
        self.adView.starRatingView = ratingBar
        self.adView.storeView = adStore
        self.adView.advertiserView = adAdvertiser
    }
    
    private func setNativeAd(nativeAd: GADNativeAd?) {
        if (nativeAd == nil){ return}
        
        adMedia?.mediaContent = nativeAd?.mediaContent
        
        (adHeadline)?.text = nativeAd?.headline
        
        (adBody)?.text = nativeAd?.body
        adBody?.isHidden = nativeAd?.body == nil
        
        (callToAction)?.setTitle(nativeAd?.callToAction, for: .normal)
        callToAction?.isHidden = nativeAd?.callToAction == nil
        
        (adIcon)?.image = nativeAd?.icon?.image
        adIcon?.isHidden = nativeAd?.icon == nil
        
        (ratingBar)?.image = imageOfStars(from:nativeAd?.starRating)
        ratingBar?.isHidden = nativeAd?.starRating == nil
        
        (adStore)?.text = nativeAd?.store
        adStore?.isHidden = nativeAd?.store == nil
        
        (adPrice)?.text = nativeAd?.price
        adPrice?.isHidden = nativeAd?.price == nil
        
        (adAdvertiser)?.text = nativeAd?.advertiser
        adAdvertiser?.isHidden = nativeAd?.advertiser == nil
        
        callToAction?.isUserInteractionEnabled = false
        
        adView.nativeAd=nativeAd
    }
    
}
