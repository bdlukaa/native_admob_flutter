import Flutter
import UIKit

public class SwiftNativeAdmobFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_admob_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeAdmobFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(UIDevice.current.systemVersion)
  }
}
