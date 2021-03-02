import Flutter
import GoogleMobileAds

class InterstitialAdController: NSObject,GADFullScreenContentDelegate {
    
    var interstitialAd: GADInterstitialAd!
    
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
            GADInterstitialAd.load(withAdUnitID: unitId, request: GADRequest()) { (ad : GADInterstitialAd?, error:Error?) in
                if error != nil {
                    self.interstitialAd = nil
                    self.channel.invokeMethod("onAdFailedToLoad", arguments: error.debugDescription)
                    result(false)
                }
                else{
                    self.interstitialAd = ad
                    self.interstitialAd.fullScreenContentDelegate=self
                    self.channel.invokeMethod("onAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "show" :
            if (self.interstitialAd == nil){ return result(false)}
            self.interstitialAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
            
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

