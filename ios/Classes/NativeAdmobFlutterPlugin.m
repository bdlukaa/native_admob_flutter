#import "NativeAdmobFlutterPlugin.h"
#if __has_include(<native_admob_flutter/native_admob_flutter-Swift.h>)
#import <native_admob_flutter/native_admob_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_admob_flutter-Swift.h"
#endif

@implementation NativeAdmobFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeAdmobFlutterPlugin registerWithRegistrar:registrar];
}
@end
