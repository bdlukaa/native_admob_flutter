import Flutter
import GoogleMobileAds

class RewardedAdController: NSObject, GADFullScreenContentDelegate {
    var rewardedAd: GADRewardedAd!

//    var loadRequested: ((MethodChannel.Result) -> Unit)? = null

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
            let ssvInfo: NSDictionary? = params?["ssv"] as? NSDictionary
            let userId: String? = ssvInfo?["userId"] as? String
            let customData: String? = ssvInfo?["customData"] as? String
            let ssv: GADServerSideVerificationOptions = GADServerSideVerificationOptions()
            ssv.userIdentifier = userId
            ssv.customRewardString = customData
            GADRewardedAd.load(withAdUnitID: unitId, request: request) { (ad: GADRewardedAd?, error: Error?) in
                if error != nil {
                    self.rewardedAd = nil
                    self.channel.invokeMethod("onAdFailedToLoad", arguments: [
                        "errorCode": (error! as NSError).code,
                        "message": (error! as NSError).localizedDescription,
                    ])
                    result(false)
                } else {
                    ad?.serverSideVerificationOptions = ssv
                    self.rewardedAd = ad
                    self.rewardedAd.fullScreenContentDelegate = self
                    self.channel.invokeMethod("onAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "show":
            if rewardedAd == nil { return result(false) }
            rewardedAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!) { () in
                self.channel.invokeMethod("onUserEarnedReward", arguments: [
                    "amount": self.rewardedAd.adReward.amount.doubleValue,
                    "type": self.rewardedAd.adReward.type,
                ])
            }

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
