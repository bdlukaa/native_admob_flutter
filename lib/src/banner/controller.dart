import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

enum BannerAdEvent {
  impression,
  clicked,
  loadFailed,
  loaded,
  loading,
  undefined,
}

class BannerSize {
  final Size size;

  const BannerSize(this.size);

  // static const BannerSize ADAPTIVE = BannerSize(Size(-1, -1));
  static const BannerSize SMART_BANNER = BannerSize(Size(-1, -2));
  static const BannerSize BANNER = BannerSize(Size(320, 50));
  static const BannerSize LARGE_BANNER = BannerSize(Size(320, 100));
  static const BannerSize MEDIUM_RECTANGLE = BannerSize(Size(320, 250));
  static const BannerSize FULL_BANNER = BannerSize(Size(468, 60));
  static const BannerSize LEADERBOARD = BannerSize(Size(728, 90));

  factory BannerSize.fromWH(double width, double height) {
    return BannerSize(Size(width, height));
  }

  @override
  String toString() => '${size.width}x${size.height}';
}

class BannerAdController {
  final _key = UniqueKey();

  /// The unique id of the controller
  String get id => _key.toString();

  final _onEvent = StreamController<Map<BannerAdEvent, dynamic>>.broadcast();

  /// Listen to the events the controller throws
  ///
  /// Usage:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case BannerAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case BannerAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case BannerAdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case BannerAdEvent.impression:
  ///       print('ad rendered');
  ///       break;
  ///     case BannerAdEvent.clicked;
  ///       print('clicked');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<Map<BannerAdEvent, dynamic>> get onEvent => _onEvent.stream;

  /// Channel to communicate with plugin
  final _pluginChannel = const MethodChannel("native_admob_flutter");

  /// Channel to communicate with controller
  MethodChannel _channel;

  bool _attached = false;

  /// Creates a new native ad controller
  BannerAdController() {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    // Let the plugin know there is a new controller
    _init();
  }

  /// Initialize the controller. This can be called only by the controller
  void _init() {
    _pluginChannel.invokeMethod("initBannerAdController", {"id": id});
  }

  void attach() {
    assert(
      !_attached,
      'This controller has already been attached to a native ad. You need one controller for each native ad.',
    );
    if (_attached) return;
    _attached = true;
  }

  /// Dispose the controller. Once disposed, the controller can not be used anymore
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   super.dispose();
  ///   controller?.dispose();
  /// }
  /// ```
  void dispose() {
    _pluginChannel.invokeMethod("disposeBannerAdController", {"id": id});
    _onEvent.close();
    _attached = false;
  }

  Future<dynamic> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "loading":
        _onEvent.add({BannerAdEvent.loading: null});
        break;
      case "onAdFailedToLoad":
        _onEvent.add({BannerAdEvent.loadFailed: call.arguments['errorCode']});
        break;
      case "onAdLoaded":
        _onEvent.add({BannerAdEvent.loaded: call.arguments});
        break;
      case "onAdClicked":
        _onEvent.add({BannerAdEvent.clicked: null});
        break;
      case "onAdImpression":
        _onEvent.add({BannerAdEvent.impression: null});
        break;
      case 'undefined':
      default:
        _onEvent.add({BannerAdEvent.undefined: null});
        break;
    }
  }

  /// Load the ad.
  ///
  /// If [unitId] is not specified, uses [NativeAds.nativeAdUnitId]
  void load() {
    // assert(
    //   NativeAds.isInitialized,
    //   'You MUST initialize the ADMOB before requesting any ads',
    // );
    _channel.invokeMethod('loadAd', null);
  }
}
