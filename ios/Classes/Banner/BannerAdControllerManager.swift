import Flutter
import GoogleMobileAds

class BannerAdControllerManager {
    static let shared = BannerAdControllerManager()

    private var controllers: [BannerAdController] = []

    private init() {}

    func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
        if getController(forID: id) == nil {
            let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
            let controller = BannerAdController(id: id, channel: methodChannel)
            controllers.append(controller)
        }
    }

    func getController(forID id: String?) -> BannerAdController? {
        return controllers.first(where: { $0.id == id })
    }

    func removeController(forID id: String) {
        if let index = controllers.firstIndex(where: { $0.id == id }) {
            controllers.remove(at: index)
        }
    }
}
