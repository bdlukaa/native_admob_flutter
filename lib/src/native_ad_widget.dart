import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'layout_builder.dart';
import 'utils.dart';
import 'controller.dart';

const _viewType = "native_admob";

class NativeAd extends StatefulWidget {
  /// How the views should be presented to the user.
  ///
  /// Use [adBannerLayoutBuilder] as a default banner layout
  ///
  /// Hot reload does NOT work while building an ad layout
  final AdLayoutBuilder buildLayout;

  final AdRatingBarView ratingBar;
  final AdMediaView media;
  final AdImageView icon;
  final AdTextView headline;
  final AdTextView advertiser;
  final AdTextView body;
  final AdTextView price;
  final AdTextView store;
  final AdTextView attribuition;
  final AdButtonView button;

  /// The ad controller
  final NativeAdController controller;

  /// The widget used in case an error shows up
  final Widget error;

  /// The widget used when the ad is loading.
  final Widget loading;

  /// The height of the ad
  final double height;

  /// The width of the ad
  final double width;

  NativeAd({
    Key key,
    @required this.buildLayout,
    this.advertiser,
    this.attribuition,
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
  })  : assert(buildLayout != null),
        super(key: key);

  @override
  _NativeAdState createState() => _NativeAdState();
}

class _NativeAdState extends State<NativeAd>
    with AutomaticKeepAliveClientMixin {
  NativeAdController controller;

  AdEvent state = AdEvent.loading;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? NativeAdController();
    controller.load();
    controller.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case AdEvent.loading:
        case AdEvent.loaded:
        case AdEvent.loadFailed:
          setState(() => state = event);
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Google Native ads are only supported in Android and iOS
    assert(
      Platform.isAndroid || Platform.isIOS,
      'The current platform does not support native ads. The platform that support it are Android and iOS',
    );

    assert(Platform.isAndroid, 'Android is the only supported platform for now');

    if (state == AdEvent.loading) return widget.loading ?? SizedBox();

    if (state == AdEvent.loadFailed) return widget.error ?? SizedBox();

    final layout = this.layout;
    layout.addAll({'controllerId': controller.id});

    Widget w;

    if (Platform.isAndroid) {
      w = AndroidView(
        viewType: _viewType,
        creationParamsCodec: StandardMessageCodec(),
        creationParams: layout,
      );
    // } else if (Platform.isIOS) {
    //   w = UiKitView(
    //     viewType: _viewType,
    //     creationParamsCodec: StandardMessageCodec(),
    //     creationParams: layout,
    //   );
    } else {
      return SizedBox();
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: w,
    );
  }

  Map<String, dynamic> get layout {
    // default the layout views
    final headline = widget.headline ??
        AdTextView(
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
        );
    final advertiser = widget.advertiser ?? AdTextView(
    );
    BorderRadius.vertical();
    final attribuition = widget.attribuition ?? AdTextView(
      width: WRAP_CONTENT,
      height: WRAP_CONTENT,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      backgroundColor: Colors.yellow,
      text: 'Ad',
      margin: EdgeInsets.only(right: 2),
      maxLines: 1,
      borderRadius: AdBorderRadius.all(10),
    );
    final body = widget.body ?? AdTextView();
    final button = widget.button ?? AdButtonView(
      backgroundColor: Colors.yellow,
      margin: EdgeInsets.all(6),
      borderRadius: AdBorderRadius.vertical(bottom: 10),
    );
    final icon = widget.icon ?? AdImageView(
      margin: EdgeInsets.only(right: 4),
    );
    final media = widget.media ?? AdMediaView();
    final price = widget.price ?? AdTextView();
    final ratingBar = widget.ratingBar ?? AdRatingBarView();
    final store = widget.store ?? AdTextView();

    // define the layout ids
    advertiser.id = 'advertiser';
    attribuition.id = 'attribuition';
    body.id = 'body';
    button.id = 'button';
    headline.id = 'headline';
    icon.id = 'icon';
    media.id = 'media';
    price.id = 'price';
    ratingBar.id = 'ratingBar';
    store.id = 'store';

    // build the layout
    final layout = (widget.buildLayout ?? adBannerLayoutBuilder)
        .call(
          ratingBar,
          media,
          icon,
          headline,
          advertiser,
          body,
          price,
          store,
          attribuition,
          button,
        )
        ?.toJson();
    return layout;
  }

  @override
  bool get wantKeepAlive => true;
}
