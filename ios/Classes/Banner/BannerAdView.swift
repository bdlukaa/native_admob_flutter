import Flutter
import GoogleMobileAds

class BannerAdView: NSObject, FlutterPlatformView {
    var data: [String: Any]?
    var controller: BannerAdController
    private let messenger: FlutterBinaryMessenger
    var result: FlutterResult?
    private var adSize: GADAdSize = kGADAdSizeBanner

    private func getAdSize(width: Float) -> GADAdSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(CGFloat(width))
    }

    init(data: [String: Any]?, messenger: FlutterBinaryMessenger) {
        self.data = data
        controller = BannerAdControllerManager.shared.getController(forID: data?["controllerId"] as? String)!
        result = controller.result
        self.messenger = messenger
        super.init()
        if let width = data?["size_width"] as! Float?, width != -1 {
            adSize = getAdSize(width: width)
        }
        controller.loadRequested = load
        generateAdView(data: data)
        load()
    }

    private func load() {
        let nonPersonalizedAds: Bool = data?["nonPersonalizedAds"] as! Bool
        let keywords: [String] = data?["keywords"] as! [String]
        let request: GADRequest = RequestFactory.createAdRequest(nonPersonalizedAds: nonPersonalizedAds, keywords: keywords)
        controller.bannerView.load(request)
    }

    private func generateAdView(data: [String: Any]?) {
        controller.bannerView = GADBannerView()
        if let width = Int(data?["size_width"] as! Float) as Int?,
           let height = Int(data?["size_height"] as! Float) as Int?, height != -1, width != -1
        {
            controller.bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: width, height: height))
        } else {
            controller.bannerView.adSize = adSize
        }
        controller.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        controller.bannerView.adUnitID = (data?["unitId"] as! String)
        controller.bannerView.delegate = self
    }

    func view() -> UIView {
        return controller.bannerView
    }
}

extension BannerAdView: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_: GADBannerView) {
        controller.channel.invokeMethod("onAdLoaded", arguments: controller.bannerView.adSize.size.height)
        result?(true)
    }

    private func bannerView(bannerView _: GADBannerView, didFailToReceiveAdWithError error: NSError) {
        controller.channel.invokeMethod("onAdFailedToLoad", arguments: [
            "errorCode": error.code,
            "message": error.localizedDescription,
        ])
        result?(false)
    }

    func bannerViewDidRecordImpression(_: GADBannerView) {
        controller.channel.invokeMethod("onAdImpression", arguments: nil)
    }

    func bannerViewWillPresentScreen(_: GADBannerView) {
        controller.channel.invokeMethod("onAdClicked", arguments: nil)
    }

    func adViewWillLeaveApplication(_: GADBannerView) {
        controller.channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
