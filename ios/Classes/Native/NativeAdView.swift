import Flutter
import GoogleMobileAds

class NativeAdView: NSObject, FlutterPlatformView {
    var data: [String: Any]?
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

    private var controller: NativeAdController?

    init(data: [String: Any]?, messenger: FlutterBinaryMessenger) {
        self.data = data
        channel = FlutterMethodChannel(name: "native_admob", binaryMessenger: messenger)
        adView = GADNativeAdView()
        super.init()
        adView.backgroundColor = UIColor(white: 1, alpha: 0)
        let builtView = buildView(data: data!)
        adView.addSubview(builtView)
        builtView.topAnchor.constraint(equalTo: adView.topAnchor).isActive = true
        builtView.bottomAnchor.constraint(equalTo: adView.bottomAnchor).isActive = true
        builtView.leftAnchor.constraint(equalTo: adView.leftAnchor).isActive = true
        builtView.rightAnchor.constraint(equalTo: adView.rightAnchor).isActive = true
        define()
        if let controllerId = data?["controllerId"] as? String,
           let controller = NativeAdControllerManager.shared.getController(forID: controllerId)
        {
            self.controller = controller
            controller.nativeAdChanged = setNativeAd
            controller.nativeAdUpdateRequested = { (layout: [String: Any]?, ad: GADNativeAd?) -> Void in
                self.adView = GADNativeAdView()
                self.adView.addSubview(self.buildView(data: layout!))
                self.define()
                self.setNativeAd(nativeAd: ad)
            }
        }

        if let nativeAd = controller?.nativeAd {
            setNativeAd(nativeAd: nativeAd)
        }
    }

    private func buildView(data: [String: Any]) -> UIView {
        let viewType: String? = data["viewType"] as? String
        let view: UIView = UICustomView(data: data)
        view.translatesAutoresizingMaskIntoConstraints = false
        var subView = UIView()

        if viewType != nil {
            switch viewType {
            case "linear_layout":
                subView = UIStackView()
                subView.translatesAutoresizingMaskIntoConstraints = false
                if data["orientation"] as! String == "vertical" {
                    (subView as! UIStackView).axis = NSLayoutConstraint.Axis.vertical
                } else {
                    (subView as! UIStackView).axis = NSLayoutConstraint.Axis.horizontal
                }
                switch data["gravity"] as? String {
                case "center":
                    (subView as! UIStackView).alignment = .center
                case "center_horizontal":
                    (subView as! UIStackView).alignment = .center
                case "center_vertical":
                    (subView as! UIStackView).alignment = .center
                case "left":
                    (subView as! UIStackView).alignment = .leading
                case "right":
                    (subView as! UIStackView).alignment = .trailing
                case "top":
                    (subView as! UIStackView).alignment = .top
                case "bottom":
                    (subView as! UIStackView).alignment = .bottom
                default:
                    (subView as! UIStackView).alignment = .top
                }
                if data["children"] != nil {
                    let lastId: String = (data["children"] as! [[String: Any]]).last!["id"] as! String
                    let firstId: String = (data["children"] as! [[String: Any]]).first!["id"] as! String
                    for child in data["children"] as! [[String: Any]] {
                        let builtView = buildView(data: child)
                        (subView as! UIStackView).addArrangedSubview(builtView)
                        if let height = child["height"] as! Float?, height == -1 {
                            if lastId == child["id"] as! String {
                                builtView.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
                            }
                            if firstId == child["id"] as! String {
                                builtView.topAnchor.constraint(equalTo: subView.topAnchor).isActive = true
                            }
                        }
                        if let width = child["width"] as! Float?, width == -1 {
                            if lastId == child["id"] as! String {
                                builtView.trailingAnchor.constraint(equalTo: subView.trailingAnchor).isActive = true
                            }
                            if firstId == child["id"] as! String {
                                builtView.leadingAnchor.constraint(equalTo: subView.leadingAnchor).isActive = true
                            }
                        }
                    }
                }
            case "text_view":
                subView = CustomUILabel(data: data)
            case "image_view":
                subView = PaddedImageView(data: data)
                subView.contentMode = .scaleAspectFit
            case "media_view":
                subView = GADMediaView()
                (subView as! GADMediaView).contentMode = .scaleAspectFit
            case "rating_bar":
                subView = PaddedImageView(data: data)
            case "button_view":
                subView = UIButton()
                subView.isUserInteractionEnabled = false
                (subView as! UIButton).applyText(data: data)
                (subView as! UIButton).contentMode = .scaleAspectFit
            case .none:
                print("none")
            case .some:
                print("some")
            }
        }

        // bounds
        let paddingRight = data["paddingRight"] as? Double ?? 0
        let paddingLeft = data["paddingLeft"] as? Double ?? 0
        let paddingTop = data["paddingTop"] as? Double ?? 0
        let paddingBottom = data["paddingBottom"] as? Double ?? 0
        if #available(iOS 11.0, *) {
            if viewType == "linear_layout" { (subView as! UIStackView).isLayoutMarginsRelativeArrangement = true }
            subView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: CGFloat(paddingTop), leading: CGFloat(paddingLeft), bottom: CGFloat(paddingBottom), trailing: CGFloat(paddingRight))
        } else {
            subView.layoutMargins = UIEdgeInsets(top: CGFloat(paddingTop), left: CGFloat(paddingLeft), bottom: CGFloat(paddingBottom), right: CGFloat(paddingRight))
        }

        if let height = data["height"] as! Float?, height > 0 {
            subView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        }
        if let width = data["width"] as! Float?, width > 0 {
            subView.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        }

        switch data["id"] as! String {
        case "advertiser": adAdvertiser = subView as? UILabel
        case "attribution": adAttribution = subView as? UILabel
        case "body": adBody = subView as? UILabel
        case "button": callToAction = subView as? UIButton
        case "headline": adHeadline = subView as? UILabel
        case "icon": adIcon = subView as? UIImageView
        case "media": adMedia = subView as? GADMediaView
        case "price": adPrice = subView as? UILabel
        case "ratingBar": ratingBar = subView as? UIImageView
        case "store": adStore = subView as? UILabel
        default:
            print("")
        }

        (view as! UIStackView).addArrangedSubview(subView)

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
        adView.mediaView = adMedia
        adView.headlineView = adHeadline
        adView.bodyView = adBody
        adView.callToActionView = callToAction
        adView.iconView = adIcon
        adView.priceView = adPrice
        adView.starRatingView = ratingBar
        adView.storeView = adStore
        adView.advertiserView = adAdvertiser
    }

    private func setNativeAd(nativeAd: GADNativeAd?) {
        if nativeAd == nil { return }

        adMedia?.mediaContent = nativeAd?.mediaContent

        (adHeadline)?.text = nativeAd?.headline

        (adBody)?.text = nativeAd?.body
        adBody?.isHidden = nativeAd?.body == nil

        (callToAction)?.setTitle(nativeAd?.callToAction, for: .normal)
        callToAction?.isHidden = nativeAd?.callToAction == nil

        (adIcon)?.image = nativeAd?.icon?.image
        adIcon?.isHidden = nativeAd?.icon == nil

        (ratingBar)?.image = imageOfStars(from: nativeAd?.starRating)
        ratingBar?.isHidden = nativeAd?.starRating == nil

        (adStore)?.text = nativeAd?.store
        adStore?.isHidden = nativeAd?.store == nil

        (adPrice)?.text = nativeAd?.price
        adPrice?.isHidden = nativeAd?.price == nil

        (adAdvertiser)?.text = nativeAd?.advertiser
        adAdvertiser?.isHidden = nativeAd?.advertiser == nil

        callToAction?.isUserInteractionEnabled = false

        adView.nativeAd = nativeAd
    }
}
