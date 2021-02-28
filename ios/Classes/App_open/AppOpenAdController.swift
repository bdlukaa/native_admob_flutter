 import Flutter
 import GoogleMobileAds

 class AppOpenAdController: NSObject, GADFullScreenContentDelegate {

     var appOpenAd: GADAppOpenAd!

     let id: String
     let channel: FlutterMethodChannel

     init(id: String, channel: FlutterMethodChannel) {
         self.id = id
         self.channel = channel
         super.init()

         channel.setMethodCallHandler(handle)
     }
    
    private func isAdAvailable()-> Bool {
        return (appOpenAd != nil);
    }

    private var isShowingAd = false

    private func showAdIfAvailable() {
        if (!isShowingAd && isAdAvailable()) {
            appOpenAd.present(
                fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!
            )
        }
    }

     private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any]

        switch call.method {
            case "loadAd":
                channel.invokeMethod("loading", arguments: nil)
                let unitId: String = params?["unitId"] as! String
                let orientation: Int = params?["orientation"] as! Int
                GADAppOpenAd.load(
                    withAdUnitID: unitId, 
                    request: GADRequest(), 
                    orientation: UIInterfaceOrientation(rawValue: orientation)!
                ) { (ad, error) in
                    if error != nil {
                        channel.invokeMethod("onAdFailedToLoad", arguments: [
                            "errorCode": error.code,
                            "error": error.localizedDescription
                        ])
                        result(false)
                        return
                    }
                    self.appOpenAd = ad
                    self.appOpenAd.fullScreenContentDelegate = self
                    result(true)
                }
            case "showAd":
               showAdIfAvailable()
            default:
                return
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
