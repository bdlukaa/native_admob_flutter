import Flutter
import GoogleMobileAds

class BannerAdView : NSObject,FlutterPlatformView {
    
    var data: Dictionary<String, Any>?
    var controller: BannerAdController

    private let channel: FlutterMethodChannel
    private let messenger: FlutterBinaryMessenger

    private func getAdSize(width: Double)-> GADAdSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(CGFloat(width))
    }
    
    init(data: Dictionary<String, Any>?, messenger: FlutterBinaryMessenger) {
        self.data=data
        self.controller = BannerAdControllerManager.shared.getController(forID: data?["controllerId"] as? String)!
        self.messenger = messenger
        channel = FlutterMethodChannel(name: "banner_admob", binaryMessenger: messenger)
        super.init()
        generateAdView(data: data)
        load()
    }
    
    private func load() {
        controller.bannerView.delegate = self
        controller.bannerView.load(GADRequest())
    }
    
    private func generateAdView(data: Dictionary<String, Any>?) {
        controller.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        controller.bannerView.adUnitID = (data?["unitId"] as! String)
    }

    func view() -> UIView {
        return controller.bannerView
    }
    
}

extension BannerAdView : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        channel.invokeMethod("onAdLoaded", arguments: controller.bannerView.adSize.size.height)
    }
    
    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
        channel.invokeMethod("onAdFailedToLoad", arguments: [
            "errorCode": error.code,
            "error": error.localizedDescription
        ])
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    private func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("onAdClicked", arguments: nil)
    }
    
    // TODO: not sure this exists on iOS.
    // channel.invokeMethod("impression", null)
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }
    
    internal func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("closed", arguments: nil)
    }
}
