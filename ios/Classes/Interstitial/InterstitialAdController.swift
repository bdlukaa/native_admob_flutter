import Flutter
import GoogleMobileAds

class InterstitialAdController: GADFullScreenContentDelegate {

    var interstitialView: GADInterstitialAd?

//    var loadRequested: ((MethodChannel.Result) -> Unit)? = null

    let id: String
    let channel: FlutterMethodChannel

    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any]

        switch call.method {
            case "loadAd":
                channel.invokeMethod("loading", arguments: nil)
                let unitId = params?["unitId"]
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID: unitId,
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
                        interstitialView = ad
                        interstitial?.fullScreenContentDelegate = self
                        channel.invokeMethod("onAdLoaded", arguments: nil)
                        result(false)
                      }
                }
            case "show":
                if interstitialView == nil {
                    result(false)
                }
                interstitial.present(fromRootViewController: UIApplication.shared.keyWindow!.rootViewController!)
            default:
                result(FlutterMethodNotImplemented)
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

