import Flutter
import GoogleMobileAds

class InterstitialAdController: NSObject {
    
    let id: String
    let channel: FlutterMethodChannel
    var interstitial: GADInterstitial!
    
    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()
        
        channel.setMethodCallHandler(handle)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        _ = call.arguments as? [String: Any]
        
        switch call.method {
        case "loadAd":
            channel.invokeMethod("loading", arguments: nil)
        
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            interstitial.load(GADRequest())
            result(true)
        
//            GADInterstitial.load(
//                withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
//                request: GADRequest(),
//                completionHandler: {ad, error in
//                    if let error = error {
//                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                        channel.invokeMethod("onAdFailedToLoad", null)
//                        result(false)
//                        return
//                    }
//                    interstitial = ad
//                })
//
        case "show":            
            if interstitial.isReady {
                interstitial.present(fromRootViewController: UIApplication.shared.keyWindow!.rootViewController!)
                result(true)
              } else {
                print("Ad wasn't ready")
              }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}

class InterstitialAdControllerManager {
    
    static let shared = InterstitialAdControllerManager()
    
    private var controllers: [InterstitialAdController] = []
    
    private init() {}
    
    func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
        if getController(forID: id) == nil {
            let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
            let controller = InterstitialAdController(id: id, channel: methodChannel)
            controllers.append(controller)
        }
    }
    
    func getController(forID id: String) -> InterstitialAdController? {
        return controllers.first(where: { $0.id == id })
    }
    
    func removeController(forID id: String) {
        if let index = controllers.firstIndex(where: { $0.id == id }) {
            controllers.remove(at: index)
        }
    }
}
