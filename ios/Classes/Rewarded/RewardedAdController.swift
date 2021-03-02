import Flutter
import GoogleMobileAds

class RewardedAdController: NSObject,GADFullScreenContentDelegate {

    var rewardedAd: GADRewardedAd!

//    var loadRequested: ((MethodChannel.Result) -> Unit)? = null

    let id: String
    let channel: FlutterMethodChannel
    var result : FlutterResult?=nil

    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result=result
        let params = call.arguments as? [String: Any]
        
        switch call.method {
        case "loadAd":
            channel.invokeMethod("loading", arguments: nil)
            let unitId: String = params?["unitId"] as! String
            GADRewardedAd.load(withAdUnitID: unitId, request: GADRequest()) { (ad : GADRewardedAd?, error:Error?) in
                if error != nil {
                    self.rewardedAd = nil
                    self.channel.invokeMethod("onAdFailedToLoad", arguments: error.debugDescription)
                    result(false)
                }
                else{
                    self.rewardedAd = ad
                    self.rewardedAd.fullScreenContentDelegate=self
                    self.channel.invokeMethod("onAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "show" :
            if (self.rewardedAd == nil){ return result(false)}
            self.rewardedAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!){ () in
                self.channel.invokeMethod("onUserEarnedReward", arguments: [
                    "amount":self.rewardedAd.adReward.amount,
                    "type":self.rewardedAd.adReward.type
                ])
            }
            
        default: 
            result(FlutterMethodNotImplemented)
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.channel.invokeMethod("onAdFailedToShowFullScreenContent", arguments: error.localizedDescription)
        result!(false)
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.channel.invokeMethod("onAdShowedFullScreenContent", arguments: nil)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.channel.invokeMethod("onAdDismissedFullScreenContent", arguments: nil)
        result!(true)
    }

}
