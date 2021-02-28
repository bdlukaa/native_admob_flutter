 import Flutter
 import GoogleMobileAds

 class AppOpenAdController: NSObject,GADFullScreenContentDelegate {

     var appOpenAd: GADAppOpenAd!

 //    var loadRequested: ((MethodChannel.Result) -> Unit)? = null

     let id: String
     let channel: FlutterMethodChannel

     init(id: String, channel: FlutterMethodChannel) {
         self.id = id
         self.channel = channel
         super.init()

         channel.setMethodCallHandler(handle)
     }
    
    private func fetchAd(unitId: String, orientation: Int) {
            // if (isAdAvailable()) return
        GADAppOpenAd.load(withAdUnitID: unitId, request: GADRequest(), orientation: UIInterfaceOrientation(rawValue: orientation)!){ (ad, error) in
            if error != nil { return }
               self.appOpenAd = ad
               self.appOpenAd.fullScreenContentDelegate = self
            }
        }


        private func isAdAvailable()-> Bool {
            return (appOpenAd != nil);
        }

        private var isShowingAd = false

    private func showAdIfAvailable() {
            if (!isShowingAd && isAdAvailable()) {
                appOpenAd.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
            }
        }

     private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any]

         switch call.method {
             case "loadAd":
                channel.invokeMethod("loading", arguments: nil)
                let unitId: String = params?["unitId"] as! String
                let orientation: Int = params?["orientation"] as! Int
                fetchAd(unitId: unitId, orientation: orientation)
            case "showAd":
               showAdIfAvailable()
            default:
                return
         }
        
     }
    

 }
