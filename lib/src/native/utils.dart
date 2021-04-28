import 'package:flutter/material.dart';
import 'layout_builder/layout_builder.dart';

/// Default banner ad layout
///
/// ![Banner Layout Builder Preview](https://github.com/bdlukaa/native_admob_flutter/blob/master/screenshots/native/banner_size_ad.png?raw=true)
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
          AdExpanded(flex: 4, child: button),
        ],
      );
    };

/// The small template is ideal for ListView, or any time
/// you need a long rectangular ad view. For instance you
/// could use it for in-feed ads.
///
/// The default height for this template is 115
///
/// ![Small Template Preview](https://developers.google.com/admob/images/android_small_template.png)
AdLayoutBuilder get smallAdTemplateLayoutBuilder {
  return (ratingBar, media, icon, headline, advertiser, body, price, store,
      attribution, button) {
    return AdLinearLayout(
      decoration: AdDecoration(backgroundColor: Colors.white),
      width: MATCH_PARENT,
      height: MATCH_PARENT,
      gravity: LayoutGravity.center_vertical,
      padding: EdgeInsets.all(8.0),
      children: [
        attribution,
        AdLinearLayout(
          margin: EdgeInsets.only(top: 6.0),
          orientation: HORIZONTAL,
          children: [
            icon,
            AdExpanded(
              flex: 2,
              child: AdLinearLayout(
                width: WRAP_CONTENT,
                margin: EdgeInsets.symmetric(horizontal: 4),
                children: [headline, body, advertiser],
              ),
            ),
            AdExpanded(flex: 3, child: button),
          ],
        ),
      ],
    );
  };
}

/// The medium template is meant to be a one-half to three-quarter
/// page view but can also be used in feeds. It is good for landing
/// pages or splash pages.
///
/// Feel free to experiment with placement. Of course, you can also
/// change the source code to suit your requirements.
///
/// The default height for this template is 320
///
/// ![Medium Template Preview](https://developers.google.com/admob/images/android_medium_template.png)
AdLayoutBuilder get mediumAdTemplateLayoutBuilder {
  return (ratingBar, media, icon, headline, advertiser, body, price, store,
      attribution, button) {
    return AdLinearLayout(
      decoration: AdDecoration(backgroundColor: Colors.white),
      width: MATCH_PARENT,
      height: MATCH_PARENT,
      gravity: LayoutGravity.center_vertical,
      padding: EdgeInsets.all(8.0),
      children: [
        attribution,
        AdLinearLayout(
          padding: EdgeInsets.only(top: 6.0),
          height: WRAP_CONTENT,
          orientation: HORIZONTAL,
          children: [
            icon,
            AdExpanded(
              flex: 2,
              child: AdLinearLayout(
                width: WRAP_CONTENT,
                margin: EdgeInsets.symmetric(horizontal: 4),
                children: [headline, body, advertiser],
              ),
            ),
          ],
        ),
        media,
        button
      ],
    );
  };
}

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
  final double? topRight;

  /// The top-left radius
  final double? topLeft;

  /// The bottom-right radius
  final double? bottomRight;

  /// The bottom-left radius
  final double? bottomLeft;

  const AdBorderRadius({
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
  static AdBorderRadius vertical({double? top, double? bottom}) =>
      AdBorderRadius(
        topLeft: top,
        topRight: top,
        bottomLeft: bottom,
        bottomRight: bottom,
      );

  /// Creates a horizontally symmetrical border radius where the left
  /// and right sides of the rectangle have the same value.
  static AdBorderRadius horizontal({double? left, double? right}) =>
      AdBorderRadius(
        topLeft: left,
        bottomLeft: left,
        topRight: right,
        bottomRight: right,
      );
}
