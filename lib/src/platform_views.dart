import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'mobile_ads.dart';

const kDefaultAndroidViewDelay = Duration(milliseconds: 250);

class AndroidPlatformView extends StatefulWidget {
  AndroidPlatformView({
    Key? key,
    required this.params,
    required this.viewType,
    bool? useHybridComposition,
    this.onCreated,
    this.delayToShow,
  })  : this.useHybridComposition =
            useHybridComposition ?? MobileAds.useHybridComposition,
        super(key: key);

  final PlatformViewCreatedCallback? onCreated;
  final String viewType;
  final bool useHybridComposition;
  final Map<String, dynamic> params;

  final Duration? delayToShow;

  @override
  _AndroidPlatformViewState createState() => _AndroidPlatformViewState();
}

class _AndroidPlatformViewState extends State<AndroidPlatformView> {
  late bool visible;

  @override
  void initState() {
    super.initState();
    visible = widget.useHybridComposition;
  }

  @override
  Widget build(BuildContext context) {
    Widget view;

    final gestures = <Factory<OneSequenceGestureRecognizer>>[
      // Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      // Factory<OneSequenceGestureRecognizer>(() => TapGestureRecognizer()),
      // Factory<OneSequenceGestureRecognizer>(() => LongPressGestureRecognizer()),
    ].toSet();
    if (!widget.useHybridComposition)
      // virtual display
      view = AndroidView(
        viewType: widget.viewType,
        creationParamsCodec: StandardMessageCodec(),
        creationParams: widget.params,
        gestureRecognizers: gestures,
        onPlatformViewCreated: (i) async {
          widget.onCreated?.call(i);
          if (visible) return;
          // This is the current fix for this issue:
          // https://github.com/bdlukaa/native_admob_flutter/issues/11
          await Future.delayed(widget.delayToShow ?? kDefaultAndroidViewDelay);
          // Issues to track:
          // - https://github.com/flutter/flutter/issues/26771
          if (mounted) setState(() => visible = true);
        },
      );
    else
      // hybrid composition
      view = PlatformViewLink(
        viewType: widget.viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: gestures,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams p) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: p.id,
            viewType: widget.viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: widget.params,
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(p.onPlatformViewCreated)
            ..create();
        },
      );
    return Opacity(
      opacity: visible ? 1 : 0,
      child: view,
    );
  }
}
