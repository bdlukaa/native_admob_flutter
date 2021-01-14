import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../native_admob_flutter.dart';
import 'options.dart';
import 'media_content.dart';

export 'options.dart';
export 'media_content.dart';

enum NativeAdEvent {
  impression,
  clicked,
  loadFailed,
  loaded,
  loading,
  muted,
  undefined,
}

enum AdVideoEvent { start, play, pause, end, mute }

class NativeAdController {
  final _key = UniqueKey();

  /// The unique id of the controller
  String get id => _key.toString();

  MediaContent _mediaContent;

  /// Provides media content information.
  ///
  /// This will be null until load is complete
  MediaContent get mediaContent => _mediaContent;

  List<String> _muteThisAdReasons = [];
  List<String> get muteThisAdReasons => _muteThisAdReasons;

  bool _customMuteThisAdEnabled = false;
  bool get isCustomMuteThisAdEnabled => _customMuteThisAdEnabled;

  final _onEvent = StreamController<Map<NativeAdEvent, dynamic>>.broadcast();
  /// Listen to the events the controller throws
  ///
  /// Usage:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case NativeAdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case NativeAdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case NativeAdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case NativeAdEvent.impression:
  ///       print('add rendered');
  ///       break;
  ///     case NativeAdEvent.clicked;
  ///       print('clicked');
  ///       break;
  ///     case NativeAdEvent.muted:
  ///       showDialog(
  ///         ...,
  ///         builder: (_) => AlertDialog(title: Text('Ad muted')),
  ///       );
  ///       break
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<Map<NativeAdEvent, dynamic>> get onEvent => _onEvent.stream;

  final _onVideoEvent =
      StreamController<Map<AdVideoEvent, dynamic>>.broadcast();
  Stream<Map<AdVideoEvent, dynamic>> get onVideoEvent => _onVideoEvent.stream;

  /// Channel to communicate with plugin
  final _pluginChannel = const MethodChannel("native_admob_flutter");

  /// Channel to communicate with controller
  MethodChannel _channel;

  bool _attached = false;

  /// Creates a new native ad controller
  NativeAdController() {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    // Let the plugin know there is a new controller
    _init();
  }

  /// Initialize the controller. This can be called only by the controller
  void _init() {
    _pluginChannel.invokeMethod("initNativeAdController", {"id": id});
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
    _pluginChannel.invokeMethod("disposeNativeAdController", {"id": id});
    _onEvent.close();
    _onVideoEvent.close();
    _attached = false;
  }

  /// Handle the messages the channel sends
  Future<void> _handleMessages(MethodCall call) async {
    if (call.method.startsWith('onVideo')) {
      switch (call.method) {
        case 'onVideoStart':
          _onVideoEvent.add({AdVideoEvent.start: null});
          break;
        case 'onVideoPlay':
          _onVideoEvent.add({AdVideoEvent.play: null});
          break;
        case 'onVideoPause':
          _onVideoEvent.add({AdVideoEvent.pause: null});
          break;
        case 'onVideoMute':
          _onVideoEvent.add({AdVideoEvent.mute: null});
          break;
        case 'onVideoEnd':
          _onVideoEvent.add({AdVideoEvent.end: null});
          break;
        default:
          break;
      }
      return;
    }
    switch (call.method) {
      case "loading":
        _onEvent.add({NativeAdEvent.loading: null});
        break;
      case "onAdFailedToLoad":
        _onEvent.add({NativeAdEvent.loadFailed: call.arguments['errorCode']});
        break;
      case "onAdLoaded":
        _onEvent.add({NativeAdEvent.loaded: null});
        break;
      case "onAdClicked":
        _onEvent.add({NativeAdEvent.clicked: null});
        break;
      case "onAdImpression":
        _onEvent.add({NativeAdEvent.impression: null});
        break;
      case "onAdMuted":
        _onEvent.add({NativeAdEvent.muted: null});
        break;
      case 'undefined':
      default:
        _onEvent.add({NativeAdEvent.undefined: null});
        break;
    }

    if (call.arguments != null && call.arguments is Map) {
      (call.arguments as Map).forEach((key, value) {
        switch (key) {
          case 'muteThisAdInfo':
            final Map args = (value ?? {}) as Map;
            _muteThisAdReasons = args?.get('muteThisAdReasons') ?? [];
            _customMuteThisAdEnabled =
                args?.get('isCustomMuteThisAdEnabled') ?? false;
            break;
          case 'mediaContent':
            _mediaContent = MediaContent.fromJson(value);
            break;
          default:
            break;
        }
      });
    }
  }

  /// Load the ad.
  ///
  /// If [unitId] is not specified, uses [NativeAds.nativeAdUnitId]
  void load({String unitId, NativeAdOptions options}) {
    // assert(
    //   NativeAds.isInitialized,
    //   'You MUST initialize the ADMOB before requesting any ads',
    // );
    final id = unitId ?? MobileAds.nativeAdUnitId;
    assert(id != null, 'The ad unit id can NOT be null');
    _channel.invokeMethod('loadAd', {
      'unitId': id ?? MobileAds.nativeAdUnitId,
      'options': (options ?? NativeAdOptions()).toJson(),
    });
  }

  /// Request the UI to update when changes happen
  void requestAdUIUpdate(Map<String, dynamic> layout) {
    print('requested ui update');
    _channel.invokeMethod('updateUI', {'layout': layout ?? {}});
  }

  /// Mutes This Ad programmatically.
  ///
  /// Use null to Mute This Ad with default reason.
  void muteThisAd([int reason]) {
    // assert(reason != null);
    // assert(
    //   muteThisAdReasons.length > reason,
    //   'The specified reason has not been found',
    // );
    _channel.invokeMethod('muteAd', {'reason': reason});
  }
}

extension map<K, V> on Map<K, V> {
  V get(K key) {
    if (containsKey(key)) return this[key];
    return null;
  }
}
