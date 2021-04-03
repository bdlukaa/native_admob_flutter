import Flutter
import GoogleMobileAds

class NativeAdController: NSObject, GADNativeAdLoaderDelegate {
    var nativeAdChanged: ((GADNativeAd?) -> Void)?
    var nativeAdUpdateRequested: (([String: Any]?, GADNativeAd?) -> Void)?
    var nativeAd: GADNativeAd?
    var adLoader: GADAdLoader!

    let id: String
    let channel: FlutterMethodChannel

    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()

        nativeAdChanged = { (ad: GADNativeAd?) -> Void in
            self.nativeAd = ad
        }

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any]

        switch call.method {
        case "loadAd":
            let unitId: String = params?["unitId"] as! String
            let nonPersonalizedAds: Bool = params?["nonPersonalizedAds"] as! Bool
            let options: [String: Any] = params?["options"] as! [String: Any]
            loadAd(unitId: unitId, nonPersonalizedAds: nonPersonalizedAds, options: options, result: result)

        case "updateUI":
            if params?["layout"] == nil || nativeAdUpdateRequested == nil { return }
            let layout: [String: Any] = params?["layout"] as! [String: Any]
            nativeAdUpdateRequested!(layout, nativeAd)
            result(nil)

        case "muteAd":
            // yep it's always success :)
            if nativeAd == nil { return result(nil) }
            if (nativeAd?.isCustomMuteThisAdAvailable) != nil {
                nativeAd?.muteThisAd(with: nativeAd?.muteThisAdReasons![params?["reason"] as! Int])
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func loadAd(unitId: String, nonPersonalizedAds: Bool, options: [String: Any], result _: FlutterResult) {
        channel.invokeMethod("loading", arguments: nil)
        // ad options
        let adImageAdLoaderOptions = GADNativeAdImageAdLoaderOptions()
        adImageAdLoaderOptions.shouldRequestMultipleImages = options["requestMultipleImages"] as! Bool
        let adViewAdOptions = GADNativeAdViewAdOptions()
        adViewAdOptions.preferredAdChoicesPosition = adChoiceMapper(index: options["adChoicesPlacement"] as! Int)
        let adVideoOptions = GADVideoOptions()
        adVideoOptions.startMuted = (options["videoOptions"] as! [String: Any])["startMuted"] as! Bool
        let adMediaAdLoaderOptions = GADNativeAdMediaAdLoaderOptions()
        adMediaAdLoaderOptions.mediaAspectRatio = GADMediaAspectRatio(rawValue: options["mediaAspectRatio"] as! Int)!
        let adMuteThisAdLoaderOptions = GADNativeMuteThisAdLoaderOptions()
        adMuteThisAdLoaderOptions.customMuteThisAdRequested = options["requestCustomMuteThisAd"] as! Bool

        adLoader = GADAdLoader(adUnitID: unitId, rootViewController: nil, adTypes: [GADAdLoaderAdType.native], options: [adImageAdLoaderOptions, adViewAdOptions, adVideoOptions, adMediaAdLoaderOptions, adMuteThisAdLoaderOptions])
        adLoader.delegate = self
        let request: GADRequest = RequestFactory.createAdRequest(nonPersonalizedAds: nonPersonalizedAds)
        adLoader.load(request)
    }

    func adLoader(_: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if nativeAdChanged != nil { nativeAdChanged!(nativeAd) }
        let mediaContent = nativeAd.mediaContent

        channel.invokeMethod("onAdLoaded", arguments: [
            "muteThisAdInfo": [
                "muteThisAdReasons": nativeAd.muteThisAdReasons?.map {
                    $0.description
                } ?? [""],
                "isCustomMuteThisAdEnabled": nativeAd.isCustomMuteThisAdAvailable,
            ],
            "mediaContent": [
                "duration": Double(mediaContent.duration),
                "aspectRatio": Double(mediaContent.aspectRatio),
                "hasVideoContent": mediaContent.hasVideoContent,
            ],
        ])
    }

    func adLoader(_: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        channel.invokeMethod("onAdFailedToLoad", arguments: error.localizedDescription)
    }

    func adChoiceMapper(index: Int) -> GADAdChoicesPosition {
        switch index {
        case 0:
            return GADAdChoicesPosition.topLeftCorner
        case 1:
            return GADAdChoicesPosition.topRightCorner
        case 2:
            return GADAdChoicesPosition.bottomRightCorner
        case 3:
            return GADAdChoicesPosition.bottomLeftCorner
        default:
            return GADAdChoicesPosition.topLeftCorner
        }
    }
}
