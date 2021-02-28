import Flutter
import GoogleMobileAds

class RewardedAdController: NSObject, GADFullScreenContentDelegate {

    var rewardedView: GADRewardedAd?

    let id: String
    let channel: FlutterMethodChannel

    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        params = call.arguments as? [String: Any]

        switch call.method {
            case "loadAd":
                channel.invokeMethod("loading", arguments: nil)
                let request = GADRequest()
                GADRewardedAd.load(
                    withAdUnitID: unitId,
                    request: request,
                    completionHandler: { [self] ad, error in
                        if let error = error {
                            interstitialView = nil
                            channel.invokeMethod("onAdFailedToLoad", arguments: [
                                "errorCode": error.code,
                                "error": error.localizedDescription
                            ])
                            result(true)
                            return
                        }
                        rewardedView = ad
                        rewardedView?.fullScreenContentDelegate = self
                        channel.invokeMethod("onAdLoaded", arguments: nil)
                        result(false)
                    }
                }
            case "show":
                if (rewardedView == nil) {
                    result(false)
                    return
                }
                rewardedView.present(
                    fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!
                    userDidEarnRewardHandler: { [self] in
                        let reward = rewardedAd.adReward
                        channel.invokeMethod("onUserEarnedReward", arguments: [
                            "amount": reward.amount,
                            "type": reward.type
                        ])
                    }
                )
                result(true)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      // TODO: this should return an error in arguments
      channel.invokeMethod("onAdFailedToShowFullScreenContent", arguments: null)
      // TODO: this should result(false)
    }

    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      channel.invokeMethod("onAdShowedFullScreenContent", arguments: null)
      // TODO: this should result(true)
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      channel.invokeMethod("onAdDismissedFullScreenContent", arguments: null)
      // TODO: this should result(true)
    }

}
