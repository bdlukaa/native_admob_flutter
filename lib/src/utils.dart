import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Assert the running platform is supported.
void assertPlatformIsSupported() {
  // Google Native ads are only supported in Android and iOS
  assert(
    Platform.isAndroid || Platform.isIOS,
    'The current platform does not support native ads. The platforms that support it are Android and iOS',
  );

  // TODO: Support iOS
  assert(Platform.isAndroid, 'Android is the only supported platform for now');
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

  final int code;
  final String message;
  final String domain;
  final AdError cause;

  const AdError({
    @required this.code,
    @required this.message,
    @required this.domain,
    this.cause,
  });

  factory AdError.fromJson(Map<String, dynamic> json) {
    return AdError(
      code: json['code'],
      message: json['message'],
      domain: json['domain'],
      cause: AdError.fromJson(json['cause'])
    );
  }

}