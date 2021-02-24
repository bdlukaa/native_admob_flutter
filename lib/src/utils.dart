import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'mobile_ads.dart';

/// Make sure the running platform is supported.
/// The currently supported platforms are:
///   - Android
void assertPlatformIsSupported() {
  // Google's AdMOB supports only Android and iOS
  assert(
    Platform.isAndroid || Platform.isIOS,
    'The current platform does not support native ads. '
    'The platforms that support it are Android and iOS',
  );

  // TODO: Support iOS
  // assert(Platform.isAndroid, 'Android is the only supported platform for now');
}

/// Assert the Mobile Ads SDK is initialized.
/// It must be initialized before any ads can be loaded and must be initialized once.
///
/// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize)
void assertMobileAdsIsInitialized() {
  assert(
    MobileAds.isInitialized,
    'The Mobile Ads SDK must be initialized before any ads can be loaded',
  );
}

/// Assert the current version is supported.
/// The min versions are:
///  - iOS: 9
///  - Android: 16 (19 for Native and Banner Ads)
void assertVersionIsSupported([bool usePlatformView = true]) {
  if (Platform.isAndroid) {
    /// The min required version for Android is 16
    assert(
      MobileAds.osVersion >= 16,
      'The required version to use the AdMOB SDK is 16 or higher',
    );

    /// The required version by flutter to use PlatformViews is
    ///   - Hybrid composition: 19
    ///   - Virtual display: 20
    if (usePlatformView)
      assert(
        MobileAds.osVersion >= 19,
        'Native and Banner Ads are not supported in versions before 19 because'
        ' flutter only support platform views on Android 19 or greater.',
      );
  } else {
    /// The min required version for iOS is 9
    assert(
      MobileAds.osVersion >= 9,
      'The required version to use the AdMOB SDK is 9 or higher',
    );
  }
}

bool debugCheckAdWillReload(bool isLoaded, bool force) {
  isLoaded ??= false;
  force ??= false;
  if (isLoaded && !force) {
    print('An ad is already avaiable, no need to load another');
    return false;
  }
  return true;
}

/// The Ad Builder
///
/// Useful links:
///   - https://github.com/bdlukaa/native_admob_flutter/wiki/Native-Ad-builder-and-placeholders#adbuilder
///   - https://github.com/bdlukaa/native_admob_flutter/wiki/Banner-Ad-builder-and-placeholders#adbuilder
typedef AdBuilder = Widget Function(BuildContext context, Widget child);

class AdError {
  /// Gets the error code. Possible error codes:
  /// - App Id Missing (The ad request was not made due to a missing app ID): 8
  /// - Invalid request (The ad request was invalid; for instance, the ad unit ID was incorrect): 1
  /// - Network error (The ad request was unsuccessful due to network connectivity): 2
  /// - No fill (The ad request was successful, but no ad was returned due to lack of ad inventory): 3
  ///
  /// See [this](https://developers.google.com/android/reference/com/google/android/gms/ads/AdRequest#constant-summary) for more info
  ///
  /// If this comes from Full-screen ads, the possible error codes are:
  /// - Ad Reused (You're reusing an ad. This will rarely happen because this error is handled by the plugin): 1
  /// - Ad not ready (The ad is not ready to be shown): 2
  /// - App Not In Foreground (The app must be in foreground so the ad can be shown): 3
  ///
  /// See [this](https://developers.google.com/android/reference/com/google/android/gms/ads/FullScreenContentCallback#constants) for more info
  ///
  /// Global error codes:
  /// - Internal error (Something happened internally; for instance, an invalid response was received from the ad server): 0
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Ad-error-codes)
  final int code;

  /// Gets an error message. For example "Account not approved yet".
  /// See [this](https://support.google.com/admob/answer/9905175) for explanations of
  /// common errors
  final String message;

  /// Creates a new AdError instance
  const AdError({
    @required this.code,
    @required this.message,
  });

  /// Retrieve an [AdError] from a json
  static AdError fromJson(/* Map<String, dynamic> */ json) {
    return AdError(
      code: json['errorCode'],
      message: json['message'],
    );
  }

  @override
  String toString() => '#$code: $message';
}

mixin UniqueKeyMixin {
  final _key = UniqueKey();

  /// The unique key of [this] class
  String get id => _key.toString();
}

mixin AttachableMixin {
  bool _attached = false;

  /// Check if the controller is attached to an Ad
  bool get isAttached => _attached;

  /// Attach the controller to an Ad
  /// Throws an `AssertionException` if the controller is already attached.
  ///
  /// You should not call this function
  @mustCallSuper
  void attach([bool attach = true]) {
    assert(attach != null);
    if (attach) _assertControllerIsNotAttached();
    _attached = attach;
  }

  /// Ensure the controller is not attached
  void _assertControllerIsNotAttached() {
    assert(
      !isAttached,
      'This controller has already been attached to an ad. '
      'You need one controller for each',
    );
  }
}

abstract class LoadShowAd<T> with UniqueKeyMixin {
  @protected
  final onEventController = StreamController<Map<T, dynamic>>.broadcast();

  /// The events this ad throws. Listen to it using:
  ///
  /// ```dart
  /// ad.onEvent.listen((event) {
  ///   print(event);
  /// });
  /// ```
  Stream get onEvent => onEventController.stream;

  /// Channel to communicate with controller
  // @protected
  MethodChannel channel;

  bool _disposed = false;

  /// Check if the ad is disposed. You can dispose the ad by calling
  /// `ad.dispose()`
  bool get isDisposed => _disposed;

  @mustCallSuper
  LoadShowAd() {
    channel = MethodChannel(id);
    init();
  }

  @protected
  void init();
  Future<bool> load();
  Future<bool> show() {
    throw UnimplementedError('This was not implemented for this ad');
  }

  @mustCallSuper
  void dispose() {
    ensureAdNotDisposed();
    _disposed = true;
    onEventController.close();
  }

  @protected
  void ensureAdNotDisposed() {
    assert(!_disposed, 'You can NOT use a disposed ad');
  }
}
