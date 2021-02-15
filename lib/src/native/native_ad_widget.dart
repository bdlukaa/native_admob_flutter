import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../utils.dart';
import '../../native_admob_flutter.dart';

import 'layout_builder/layout_builder.dart';
import 'utils.dart';
import 'controller/controller.dart';

const _viewType = 'native_admob';

class NativeAd extends StatefulWidget {
  /// How the views should be presented to the user.
  ///
  /// Use [adBannerLayoutBuilder] as a default banner layout\
  /// ![adBannerLayoutBuilder screenshot](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/native/banner_size_ad.png?raw=true)
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-native-ad#creating-a-layout-builder)
  final AdLayoutBuilder buildLayout;

  /// The rating bar. This isn't always inclued in the request
  final AdRatingBarView ratingBar;

  /// The full media view. This is always included in the request
  final AdMediaView media;

  /// The icon view. This isn't always inclued in the request
  final AdImageView icon;

  /// The ad headline. This is always inclued in the request
  final AdTextView headline;

  /// The ad advertiser. This isn't always inclued in the request
  final AdTextView advertiser;

  /// The ad body. This isn't always inclued in the request
  final AdTextView body;

  /// The app price. This isn't always inclued in the request
  final AdTextView price;

  /// The store. This isn't always inclued in the request
  final AdTextView store;

  /// The ad attribution. This is always inclued in the request
  final AdTextView attribution;

  /// The ad button. This isn't always inclued in the request
  final AdButtonView button;

  /// The ad controller. If not specified, uses a default controller.
  /// This can not be changed dynamically
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Using-the-controller-and-listening-to-native-events)
  final NativeAdController controller;

  /// The widget used in case of an error shows up
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Native-Ad-builder-and-placeholders#loading-and-error-placeholders)
  final Widget error;

  /// The widget used while the ad is loading.
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Native-Ad-builder-and-placeholders#loading-and-error-placeholders)
  final Widget loading;

  /// The height of the ad. If this is null, the widget will expand
  ///
  /// 🔴IMPORTANT❗🔴:
  /// Ad views that have a width or height smaller than 32 will be
  /// demonetized in the future.
  /// Please make sure the ad view has sufficiently large area.
  ///
  /// Usage inside of a `Column` requires an `Expanded` or a defined height.
  /// Usage inside of a `ListView` requires a defined height.
  final double height;

  /// The width of the ad. If this is null, the widget will expand
  ///
  /// 🔴IMPORTANT❗🔴:
  /// Ad views that have a width or height smaller than 32 will be
  /// demonetized in the future.
  /// Please make sure the ad view has sufficiently large area.
  ///
  /// Usage inside of a Row requires an Expanded or a defined width.
  /// Usage inside of a ListView requires a defined width.
  final double width;

  /// Used to configure native ad requests.
  ///
  /// If this is changed, the ad will be reloaded. To disable it, set
  /// `reloadWhenOptionsChange` to false
  final NativeAdOptions options;

  /// If true, the ad will be reloaded whenever `options` changes
  final bool reloadWhenOptionsChange;

  /// Build the ad background. Basic usage:
  /// ```dart
  /// NativeAd(
  ///   builder: (context, child) {
  ///     return Container(
  ///       // Applies a blue color to the background.
  ///       // You can use anything here to build the ad.
  ///       // The ad won't be reloaded
  ///       color: Colors.blue,
  ///       child: child,
  ///     );
  ///   }
  /// )
  /// ```
  ///
  /// For more info, read the [changelog](https://github.com/bdlukaa/native_admob_flutter/wiki/Native-Ad-builder-and-placeholders#adbuilder)
  final AdBuilder builder;

  /// Create a `NativeAd`.
  /// Uses `NativeAdView` on android and `GADNativeAd` on iOS
  ///
  /// Useful links:
  ///   - https://developers.google.com/admob/ios/native/start
  ///   - https://developers.google.com/admob/android/native/start
  ///   - https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-native-ad
  ///
  /// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-native-ad)
  const NativeAd({
    Key key,
    @required this.buildLayout,
    this.advertiser,
    this.attribution,
    this.body,
    this.button,
    this.headline,
    this.icon,
    this.media,
    this.price,
    this.ratingBar,
    this.store,
    this.controller,
    this.error,
    this.loading,
    this.height,
    this.width,
    this.options,
    this.reloadWhenOptionsChange = true,
    this.builder,
  })  : assert(buildLayout != null),
        assert(reloadWhenOptionsChange != null),
        super(key: key);

  @override
  _NativeAdState createState() => _NativeAdState();
}

class _NativeAdState extends State<NativeAd>
    with AutomaticKeepAliveClientMixin<NativeAd> {
  NativeAdController controller;
  NativeAdEvent state = NativeAdEvent.loading;

  @override
  void didUpdateWidget(NativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    // reload if options changed
    if (widget.reloadWhenOptionsChange &&
        oldWidget.options?.toJson()?.toString() !=
            widget.options?.toJson()?.toString())
      controller.load(options: widget.options);
    if (layout(oldWidget).toString() != layout(widget).toString()) {
      _requestAdUIUpdate(layout(widget));
    }
  }

  void _requestAdUIUpdate(Map<String, dynamic> layout) {
    controller.channel.invokeMethod('updateUI', {'layout': layout ?? {}});
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? NativeAdController();
    controller.attach();
    controller.load(options: widget.options);
    controller.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case NativeAdEvent.loading:
        case NativeAdEvent.loaded:
        case NativeAdEvent.loadFailed:
          setState(() => state = event);
          break;
        case NativeAdEvent.undefined:
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    // dispose the controller only if the controller was
    // created by the ad.
    if (widget.controller == null)
      controller?.dispose();
    else
      controller?.attach(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assertPlatformIsSupported();
    assertVersionIsSupported();

    if (state == NativeAdEvent.loading) return widget.loading ?? SizedBox();
    if (state == NativeAdEvent.loadFailed) return widget.error ?? SizedBox();

    Widget w;

    final params = layout(widget);
    params.addAll({'controllerId': controller.id});

    return LayoutBuilder(builder: (context, consts) {
      final size = consts.biggest;
      final height = widget.height ?? size.height;
      final width = widget.width ?? size.width;
      // assert(!height.isInfinite, 'A height must be provided');
      // assert(!width.isInfinite, 'A width must be provided');
      assert(
        height > 32 && width > 32,
        'Native ad views that have a width or height smaller than '
        '32 will be demonetized in the future. '
        'Please make sure the ad view has sufficiently large area.',
      );

      if (Platform.isAndroid) {
        w = buildAndroidPlatformView(
          params,
          _viewType,
          MobileAds.useHybridComposition,
        );
      } else if (Platform.isIOS) {
        w = UiKitView(
          viewType: _viewType,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: params,
        );
      } else {
        return SizedBox();
      }

      w = SizedBox(
        height: height,
        width: width,
        child: w,
      );
      return widget.builder?.call(context, w) ?? w;
    });
  }

  Map<String, dynamic> layout(NativeAd widget) {
    // default the layout views
    final headline = AdTextView(
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
    ).copyWith(widget.headline);
    final advertiser = AdTextView().copyWith(widget.advertiser);
    final attribution = AdTextView(
      width: WRAP_CONTENT,
      height: WRAP_CONTENT,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      style: TextStyle(color: Colors.black),
      text: 'Ad',
      margin: EdgeInsets.only(right: 2),
      maxLines: 1,
      decoration: AdDecoration(
        borderRadius: AdBorderRadius.all(10),
        backgroundColor: Colors.yellow,
      ),
    ).copyWith(widget.attribution);
    final body = AdTextView().copyWith(widget.body);
    final button = AdButtonView(
      pressColor: Colors.red,
      decoration: AdDecoration(backgroundColor: Colors.yellow),
      margin: EdgeInsets.only(top: 6),
    ).copyWith(widget.button);
    final icon = AdImageView().copyWith(widget.icon);
    final media = AdMediaView().copyWith(widget.media);
    final price = AdTextView().copyWith(widget.price);
    final ratingBar = AdRatingBarView().copyWith(widget.ratingBar);
    final store = AdTextView().copyWith(widget.store);

    // define the layout ids
    advertiser.id = 'advertiser';
    attribution.id = 'attribution';
    body.id = 'body';
    button.id = 'button';
    headline.id = 'headline';
    icon.id = 'icon';
    media.id = 'media';
    price.id = 'price';
    ratingBar.id = 'ratingBar';
    store.id = 'store';

    // build the layout
    final layout = (widget.buildLayout ?? adBannerLayoutBuilder)(
      ratingBar,
      media,
      icon,
      headline,
      advertiser,
      body,
      price,
      store,
      attribution,
      button,
    )?.toJson();
    assert(layout != null, 'The layout must not return null');

    return layout;
  }

  @override
  bool get wantKeepAlive => true;
}
