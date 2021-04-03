import Flutter
import GoogleMobileAds

class NativeAdControllerManager {
    static let shared = NativeAdControllerManager()

    private var controllers: [NativeAdController] = []

    private init() {}

    func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
        if getController(forID: id) == nil {
            let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
            let controller = NativeAdController(id: id, channel: methodChannel)
            controllers.append(controller)
        }
    }

    func getController(forID id: String) -> NativeAdController? {
        return controllers.first(where: { $0.id == id })
    }

    func removeController(forID id: String) {
        if let index = controllers.firstIndex(where: { $0.id == id }) {
            controllers.remove(at: index)
        }
    }
}
