import Flutter
import GoogleMobileAds

class InterstitialAdController: NSObject, GADFullScreenContentDelegate {
    var interstitialAd: GADInterstitialAd!

    let id: String
    let channel: FlutterMethodChannel
    var result: FlutterResult?

    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        let params = call.arguments as? [String: Any]

        switch call.method {
        case "loadAd":
            channel.invokeMethod("loading", arguments: nil)
            let unitId: String = params?["unitId"] as! String
            let nonPersonalizedAds: Bool = params?["nonPersonalizedAds"] as! Bool
            let keywords: [String] = params?["keywords"] as! [String]
            let request: GADRequest = RequestFactory.createAdRequest(nonPersonalizedAds: nonPersonalizedAds, keywords: keywords)
            GADInterstitialAd.load(withAdUnitID: unitId, request: request) { (ad: GADInterstitialAd?, error: Error?) in
                if error != nil {
                    self.interstitialAd = nil
                    self.channel.invokeMethod("onAdFailedToLoad", arguments: [
                        "errorCode": (error! as NSError).code,
                        "message": (error! as NSError).localizedDescription,
                    ])
                    result(false)
                } else {
                    self.interstitialAd = ad
                    self.interstitialAd.fullScreenContentDelegate = self
                    self.channel.invokeMethod("onAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "show":
            if interstitialAd == nil { return result(false) }
            interstitialAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func ad(_: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        channel.invokeMethod("onAdFailedToShowFullScreenContent", arguments: error.localizedDescription)
        result!(false)
    }

    func adDidPresentFullScreenContent(_: GADFullScreenPresentingAd) {
        channel.invokeMethod("onAdShowedFullScreenContent", arguments: nil)
    }

    func adDidDismissFullScreenContent(_: GADFullScreenPresentingAd) {
        channel.invokeMethod("onAdDismissedFullScreenContent", arguments: nil)
        result!(true)
    }
}
