import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'mobile_ads.dart';

/// Assert the running platform is supported.
/// The supported platforms are: Android
void assertPlatformIsSupported() {
  // Google Native ads are only supported in Android and iOS
  assert(
    Platform.isAndroid || Platform.isIOS,
    'The current platform does not support native ads. The platforms that support it are Android and iOS',
  );

  // TODO: Support iOS
  assert(Platform.isAndroid, 'Android is the only supported platform for now');
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

/// Assert the Native or Banner Ad controller is attached and
/// isn't disposed.
void assertControllerIsAttached(bool attached) {
  assert(attached, 'You can NOT use a disposed controller');
}

void assertControllerIsNotAttached(bool attached) {
  assert(
    !attached,
    'This controller has already been attached to a native or banner ad. You need one controller for each',
  );
}

void debugCheckIsTestId(String id, List<String> testIds) {
  assert(id != null);
  assert(testIds != null);
  if (!testIds.contains(id) && kDebugMode)
    print(
      'It is highly recommended to use test ads in for testing instead of production ads'
      'Failure to do so can lead in to the suspension of your account',
    );
}

/// Assert the current version is supported.
/// The min versions are:
///  - iOS: 9
///  - Android: 16 (19 for Native and Banner Ads)
void assertVersionIsSupported() {
  if (Platform.isAndroid)
    assert(
      MobileAds.osVersion >= 19,
      'Native and Banner Ads are not supported in versions before 19 because'
      ' flutter only support platform views on Android 19 or greater.',
    );
  else
    assert(
      MobileAds.osVersion >= 9,
      'The required version to use the AdMOB SDk is 9 or higher',
    );
}

typedef AdBuilder = Widget Function(BuildContext context, Widget child);

/// Build the android platform view
Widget buildAndroidPlatformView(
  Map<String, dynamic> params,
  String viewType, [
  bool useHybridComposition = false,
]) {
  assert(useHybridComposition != null);
  final gestures = <Factory<OneSequenceGestureRecognizer>>[
    // Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
    // Factory<OneSequenceGestureRecognizer>(() => TapGestureRecognizer()),
    // Factory<OneSequenceGestureRecognizer>(() => LongPressGestureRecognizer()),
  ].toSet();
  if (!useHybridComposition)
    // virtual display
    return AndroidView(
      viewType: viewType,
      creationParamsCodec: StandardMessageCodec(),
      creationParams: params,
      gestureRecognizers: gestures,
    );
  else
    // hybrid composition
    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller,
          gestureRecognizers: gestures,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams p) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: p.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: params,
          creationParamsCodec: StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(p.onPlatformViewCreated)
          // ..setSize(Size(width, height))
          ..create();
      },
    );
}

class AdError {
  /// Gets the error code. Possible error codes:
  /// - App Id Missing (The ad request was not made due to a missing app ID): 8
  /// - Invalid request (The ad request was invalid; for instance, the ad unit ID was incorrect): 1
  /// - Network error (The ad request was unsuccessful due to network connectivity): 2
  /// - No fill (The ad request was successful, but no ad was returned due to lack of ad inventory): 3
  ///
  /// See [this](https://developers.google.com/android/reference/com/google/android/gms/ads/AdRequest#constant-summary) for more info
  ///
  /// If this comes from [OpenAds], the possible error codes are:
  /// - Ad Reused (You're reusing an ad. This will rarely happen because this error is handled by the plugin): 1
  /// - Ad not ready (The ad is not ready to be shown): 2
  /// - App Not In Foreground (The app must be in foreground so the ad can be shown): 3
  ///
  /// See [this](https://developers.google.com/android/reference/com/google/android/gms/ads/FullScreenContentCallback#constants) for more info
  ///
  /// Global error codes:
  /// - Internal error (Something happened internally; for instance, an invalid response was received from the ad server): 0
  final int code;

  /// Gets an error message. For example "Account not approved yet".
  /// See [this](https://support.google.com/admob/answer/9905175) for explanations of
  /// common errors
  final String message;

  /// Gets the domain from which the error came.
  final String domain;

  /// Gets the cause of the error, if available.
  final AdError cause;

  /// Creates a new AdError
  const AdError({
    @required this.code,
    @required this.message,
    @required this.domain,
    this.cause,
  });

  /// Retrieve this from a json
  factory AdError.fromJson(Map<String, dynamic> json) {
    return AdError(
      code: json['code'],
      message: json['message'],
      domain: json['domain'],
      cause: AdError.fromJson(json['cause']),
    );
  }

  @override
  String toString() => '#$code from $domain. $message. Cause: $cause';
}

mixin UniqueKeyMixin {
  final _key = UniqueKey();

  /// The unique key of the class
  String get id => _key.toString();
}

abstract class LoadShowAd<T> with UniqueKeyMixin {
  @protected
  final onEventController = StreamController<Map<T, dynamic>>.broadcast();
  Stream get onEvent => onEventController.stream;

  /// Channel to communicate with controller
  // @protected
  MethodChannel channel;

  bool _disposed = false;
  /// Check if the ad is loaded
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
