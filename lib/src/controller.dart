import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../native_admob_flutter.dart';

enum AdEvent {
  impression, clicked, loadFailed, loaded, loading, undefined
}

class NativeAdController {
  final _key = UniqueKey();

  /// The unique id of the controller
  String get id => _key.toString();

  final _onEvent = StreamController<Map<AdEvent, dynamic>>.broadcast();

  /// Listen to the events the controller throws
  /// 
  /// Usage:
  /// ```dart
  /// controller.onEvent.listen((e) {
  ///   final event = e.keys.first;
  ///   switch (event) {
  ///     case AdEvent.loading:
  ///       print('loading');
  ///       break;
  ///     case AdEvent.loaded:
  ///       print('loaded');
  ///       break;
  ///     case AdEvent.loadFailed:
  ///       final errorCode = e.values.first;
  ///       print('loadFailed $errorCode');
  ///       break;
  ///     case AdEvent.impression:
  ///       print('add rendered');
  ///       break;
  ///     case AdEvent.clicked;
  ///       print('clicked');
  ///       break
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<Map<AdEvent, dynamic>> get onEvent => _onEvent.stream;

  /// Channel to communicate with plugin
  final _pluginChannel = const MethodChannel("native_admob_flutter");

  /// Channel to communicate with controller
  MethodChannel _channel;
  String _adUnitID;

  /// Creates a new native ad controller
  NativeAdController() {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);

    // Let the plugin know there is a new controller
    _init();
  }

  /// Initialize the controller. This can be called only by the controller
  void _init() {
    _pluginChannel.invokeMethod("initController", {"id": id});
  }

  /// Dispose the controller. Once disposed, the controller can not be used anymore
  /// 
  /// Usage:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   super.dispose();
  ///   controller.dispose();
  /// }
  /// ```
  void dispose() {
    _pluginChannel.invokeMethod("disposeController", {"id": id});
    _onEvent.close();
  }

  /// Handle the messages the channel sends
  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "loading":
        _onEvent.add({AdEvent.loading: null});
        break;
      case "onAdFailedToLoad":
        _onEvent.add({AdEvent.loadFailed: call.arguments['errorCode']});
        break;
      case "onAdLoaded":
        _onEvent.add({AdEvent.loaded: null});
        break;
      case "onAdClicked":
        _onEvent.add({AdEvent.clicked: null});
        break;
      case "onAdImpression":
        _onEvent.add({AdEvent.impression: null});
        break;
      default:
        _onEvent.add({AdEvent.undefined: null});
        break;
    }
  }

  /// Load the ad
  void load([String unitId]) {
    _channel.invokeMethod("loadAd", {
      "unitId": unitId ?? NativeAds.nativeAdUnitId,
      // "numberAds": numberAds,
    });
  }

}
