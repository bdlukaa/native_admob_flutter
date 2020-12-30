import 'package:flutter/material.dart';
import 'layout_builder/layout_builder.dart';

AdLayoutBuilder adBannerLayoutBuilder = (ratingBar, media, icon, headline,
    advertiser, body, price, store, attribuition, button) {
  return AdLinearLayout(
    margin: EdgeInsets.all(10),
    borderRadius: AdBorderRadius.all(10),
    // The first linear layout width needs to be extended to the
    // parents height, otherwise the children won't fit good
    width: MATCH_PARENT,
    children: [
      AdLinearLayout(
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribuition, advertiser],
                orientation: HORIZONTAL,
                width: WRAP_CONTENT,
              ),
            ],
          ),
        ],
        width: MATCH_PARENT,
        orientation: HORIZONTAL,
        margin: EdgeInsets.all(6),
      ),
      button,
    ],
    backgroundColor: Colors.blue,
  );
};

extension colorExtension on Color {
  String toHex([bool hashtag = true]) {
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
