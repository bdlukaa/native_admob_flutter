import Flutter
import GoogleMobileAds

class AppOpenAdController: NSObject, GADFullScreenContentDelegate {
    var appOpenAd: GADAppOpenAd!

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
            let orientation: Int = params?["orientation"] as! Int
            let nonPersonalizedAds: Bool = params?["nonPersonalizedAds"] as! Bool
            let request: GADRequest = RequestFactory.createAdRequest(nonPersonalizedAds: nonPersonalizedAds)
            GADAppOpenAd.load(withAdUnitID: unitId, request: request, orientation: UIInterfaceOrientation(rawValue: orientation)!) { (ad: GADAppOpenAd?, error: Error?) in
                if error != nil {
                    self.appOpenAd = nil
                    self.channel.invokeMethod("onAppOpenAdFailedToLoad", arguments: [
                        "errorCode": (error! as NSError).code,
                        "message": (error! as NSError).localizedDescription,
                    ])
                    result(false)
                } else {
                    self.appOpenAd = ad
                    self.appOpenAd.fullScreenContentDelegate = self
                    self.channel.invokeMethod("onAppOpenAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "showAd":
            if appOpenAd == nil { return result(false) }
            appOpenAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)

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
