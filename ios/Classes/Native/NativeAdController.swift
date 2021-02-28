import Flutter
import GoogleMobileAds

class NativeAdController: NSObject {

    var nativeView: GADNativeAdView!

    let id: String
    let channel: FlutterMethodChannel

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
            default:
                result(FlutterMethodNotImplemented)
        }
    }

}
