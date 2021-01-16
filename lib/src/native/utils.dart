import 'package:flutter/material.dart';
import 'layout_builder/layout_builder.dart';

/// Default banner ad layout
///
/// ![adBannerLayoutBuilder screenshot](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/default_banner_screenshot.png)
///
/// For more info, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-a-native-ad#creating-a-layout-builder)
AdLayoutBuilder get adBannerLayoutBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribution, button) {
      return AdLinearLayout(
        decoration: AdDecoration(backgroundColor: Colors.white),
        width: MATCH_PARENT,
        height: MATCH_PARENT,
        orientation: HORIZONTAL,
        gravity: LayoutGravity.center_vertical,
        children: [
          icon,
          AdExpanded(
            flex: 2,
            child: AdLinearLayout(
              width: WRAP_CONTENT,
              margin: EdgeInsets.symmetric(horizontal: 4),
              children: [
                headline,
                AdLinearLayout(
                  orientation: HORIZONTAL,
                  children: [attribution, advertiser],
                ),
              ],
            ),
          ),
          AdExpanded(flex: 3, child: button),
        ],
      );
    };

extension colorExtension on Color {
  String toHex([bool hashtag = true]) {
    if (this == Colors.transparent) return '#00ff0000';
    String hex = '';
    if (hashtag) hex = '#$hex';
    hex = '$hex${value.toRadixString(16)}';
    return hex;
  }
}

class AdBorderRadius {
  /// The top-right radius
  final double topRight;

  /// The top-left radius
  final double topLeft;

  /// The bottom-right radius
  final double bottomRight;

  /// The bottom-left radius
  final double bottomLeft;

  AdBorderRadius({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  /// Creates a border radius where all `radius` are `value`.
  static AdBorderRadius all(double value) => AdBorderRadius(
        topLeft: value,
        topRight: value,
        bottomLeft: value,
        bottomRight: value,
      );

  /// Creates a vertically symmetric border radius where the top
  /// and bottom sides of the rectangle have the same value.
  static AdBorderRadius vertical({
    double top,
    double bottom,
  }) =>
      AdBorderRadius(
        topLeft: top,
        topRight: top,
        bottomLeft: bottom,
        bottomRight: bottom,
      );

  /// Creates a horizontally symmetrical border radius where the left
  ///  and right sides of the rectangle have the same value.
  static AdBorderRadius horizontal({
    double left,
    double right,
  }) =>
      AdBorderRadius(
        topLeft: left,
        bottomLeft: left,
        topRight: right,
        bottomRight: right,
      );
}
