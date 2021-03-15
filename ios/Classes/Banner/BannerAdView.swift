import Flutter
import GoogleMobileAds

class BannerAdView : NSObject,FlutterPlatformView {
    
    var data:Dictionary<String, Any>?
    var controller: BannerAdController
    private let messenger: FlutterBinaryMessenger
    var result : FlutterResult?=nil
    private var adSize: GADAdSize = kGADAdSizeBanner
    
    private func getAdSize(width: Float)-> GADAdSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(CGFloat(width))
    }
    
    init(data: Dictionary<String, Any>?, messenger: FlutterBinaryMessenger) {
        self.data=data
        self.controller = BannerAdControllerManager.shared.getController(forID: data?["controllerId"] as? String)!
        self.result=controller.result
        self.messenger = messenger
        super.init()
        if let width = data?["size_width"] as! Float?, width != -1{
            self.adSize=getAdSize(width: width)
        }
        self.controller.loadRequested=load
        generateAdView(data:data)
        load()
    }
    
    private func load() {
        let request = GADRequest()
        if #available(iOS 13.0, *) {
            request.scene = UIApplication.shared.keyWindow?.windowScene
        }
        controller.bannerView.load(request)
    }
    
    private func generateAdView(data:Dictionary<String, Any>?) {
        controller.bannerView = GADBannerView()
        if let width = Int(data?["size_width"] as! Float) as Int?,
           let height = Int(data?["size_height"] as! Float) as Int?, height != -1, width != -1{
            self.controller.bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: width, height: height))
        }
        else{
            self.controller.bannerView.adSize = adSize
        }
        controller.bannerView.rootViewController=UIApplication.shared.keyWindow?.rootViewController
        controller.bannerView.adUnitID = (data?["unitId"] as! String)
        controller.bannerView.delegate=self
    }
    
    func view() -> UIView {
        return controller.bannerView
    }
    
}

extension BannerAdView : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        controller.channel.invokeMethod("onAdLoaded", arguments: controller.bannerView.adSize.size.height)
        result?(true)
    }
    
    private func bannerView(bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
        controller.channel.invokeMethod("onAdFailedToLoad", arguments: [
            "errorCode": error.code,
            "message": error.localizedDescription
        ])
        result?(false)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView){
        controller.channel.invokeMethod("onAdImpression", arguments: nil)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        controller.channel.invokeMethod("onAdClicked", arguments: nil)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        controller.channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
