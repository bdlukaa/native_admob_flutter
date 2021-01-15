import 'package:flutter/material.dart';
import 'layout_builder/layout_builder.dart';

/// Default ad layout
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
  final double topRight, topLeft, bottomRight, bottomLeft;

  AdBorderRadius({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  static AdBorderRadius all(double value) => AdBorderRadius(
        topLeft: value,
        topRight: value,
        bottomLeft: value,
        bottomRight: value,
      );

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
