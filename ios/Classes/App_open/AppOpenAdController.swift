 import Flutter
 import GoogleMobileAds

 class AppOpenAdController: NSObject,GADFullScreenContentDelegate {

     var appOpenAd: GADAppOpenAd!

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
            let orientation: Int = params?["orientation"] as! Int
            GADAppOpenAd.load(withAdUnitID: unitId, request: GADRequest(), orientation: UIInterfaceOrientation(rawValue: orientation)!) { (ad : GADAppOpenAd?, error:Error?) in
                if error != nil {
                    self.appOpenAd = nil
                    self.channel.invokeMethod("onAppOpenAdFailedToLoad", arguments: error.debugDescription)
                    result(false)
                }
                else{
                    self.appOpenAd = ad
                    self.appOpenAd.fullScreenContentDelegate=self
                    self.channel.invokeMethod("onAppOpenAdLoaded", arguments: nil)
                    result(true)
                }
            }
        case "showAd" :
            if (self.appOpenAd == nil){ return result(false)}
            self.appOpenAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
            
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
