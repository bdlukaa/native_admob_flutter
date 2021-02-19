// class NativeAdmobController: NSObject {

//     let id: String
//     let channel: FlutterMethodChannel

//     init(id: String, channel: FlutterMethodChannel) {
//         self.id = id
//         self.channel = channel
//         super.init()
        
//         channel.setMethodCallHandler(handle)
//     }
// }

// class NativeAdmobControllerManager {
    
//     static let shared = NativeAdmobControllerManager()
    
//     private var controllers: [NativeAdmobController] = []
    
//     private init() {}
    
//     func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
//         if getController(forID: id) == nil {
//             let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
//             let controller = NativeAdmobController(id: id, channel: methodChannel)
//             controllers.append(controller)
//         }
//     }
    
//     func getController(forID id: String) -> NativeAdmobController? {
//         return controllers.first(where: { $0.id == id })
//     }
    
//     func removeController(forID id: String) {
//         if let index = controllers.firstIndex(where: { $0.id == id }) {
//             controllers.remove(at: index)
//         }
//     }
// }