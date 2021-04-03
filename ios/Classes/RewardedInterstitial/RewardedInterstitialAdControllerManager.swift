import Flutter
import GoogleMobileAds

class RewardedIntersititalAdControllerManager {
    static let shared = RewardedIntersititalAdControllerManager()

    private var controllers: [RewardedIntersititalAdController] = []

    private init() {}

    func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
        if getController(forID: id) == nil {
            let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
            let controller = RewardedIntersititalAdController(id: id, channel: methodChannel)
            controllers.append(controller)
        }
    }

    func getController(forID id: String) -> RewardedIntersititalAdController? {
        return controllers.first(where: { $0.id == id })
    }

    func removeController(forID id: String) {
        if let index = controllers.firstIndex(where: { $0.id == id }) {
            controllers.remove(at: index)
        }
    }
}
