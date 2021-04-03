import Flutter
import GoogleMobileAds

class BannerAdController: NSObject {
    var bannerView: GADBannerView!
    var loadRequested: (() -> Void)?
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
        _ = call.arguments as? [String: Any]

        switch call.method {
        case "loadAd":
            channel.invokeMethod("loading", arguments: nil)
            if loadRequested != nil { loadRequested!() }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
