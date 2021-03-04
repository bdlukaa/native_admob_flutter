import 'package:flutter/material.dart';

import '../gradient/gradient.dart';
import '../utils.dart';

part 'text.dart';
part 'linear_layout.dart';
part 'container.dart';

/// The layout builder. It must return an `AdLinearLayout` and can't return null
typedef AdLayoutBuilder = AdLinearLayout Function(
  AdRatingBarView ratingBar,
  AdMediaView media,
  AdImageView icon,
  AdTextView headline,
  AdTextView advertiser,
  AdTextView body,
  AdTextView price,
  AdTextView store,
  AdTextView attribution,
  AdButtonView button,
  // AdButtonView muteThisAd,
);

/// Expands the view to fit the parent size. Same as `double.infinity`
const double MATCH_PARENT = -1;

/// Wrap the content to fit its own size
const double WRAP_CONTENT = -2;

class AdView {
  /// The Decoration of the AdView.
  final AdDecoration? decoration;

  /// The padding applied to the view. Default to none
  final EdgeInsets? padding;

  /// The margin applied to the view. Default to none
  final EdgeInsets? margin;

  /// The width of the view
  final double? width;

  /// The height of the view
  final double? height;

  /// The elevation of the view. It may not work in some views
  ///
  /// On android, it only has effect on version >= 21
  final double? elevation;

  /// The color of the elevation. It may not work in some views
  ///
  /// On android, it only has effect on version >= 21
  final Color? elevationColor;

  /// The type of the view. Do not change this manually
  final String viewType;

  /// The id of the view. Used to recognize it
  String? id;

  AdView({
    required this.viewType,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.id,
    this.decoration,
    this.elevation,
    this.elevationColor,
  });

  /// Copy [this] with a new [AdView]
  AdView copyWith(AdView view) {
    return AdView(
      viewType: view.viewType,
      decoration: view.decoration ?? decoration,
      height: view.height ?? height,
      width: view.width ?? width,
      id: view.id ?? id,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevationColor,
    );
  }

  Map<String, dynamic> toJson() {
    double? width = this.width;
    if (width == double.infinity) width = MATCH_PARENT;

    double? height = this.height;
    if (height == double.infinity) height = MATCH_PARENT;

    final json = <String, dynamic>{
      // meta
      'id': id,
      'viewType': viewType,
      // padding
      'paddingRight': padding?.right,
      'paddingLeft': padding?.left,
      'paddingTop': padding?.top,
      'paddingBottom': padding?.bottom,
      // margin
      'marginRight': margin?.right,
      'marginLeft': margin?.left,
      'marginTop': margin?.top,
      'marginBottom': margin?.bottom,
      // screen bounds
      'width': width,
      'height': height,
      // others
      'elevation': elevation,
      'elevationColor': elevationColor?.toHex()
    };
    if (decoration != null) json.addAll(decoration!.toJson());
    return json;
  }
}

class AdImageView extends AdView {
  AdImageView({
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? size,
    AdDecoration? decoration,
    double? elevation,
    Color? elevationColor,
  }) : super(
          viewType: 'image_view',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: size ?? 50,
          height: size ?? 50,
          elevation: elevation,
          elevationColor: elevationColor,
        );

  /// Copy [this] with a new [AdView]
  AdImageView copyWith(AdView? view) {
    if (view == null) return this;
    assert(view is AdImageView);
    return AdImageView(
      decoration: view.decoration ?? decoration,
      size: view.height ?? view.width ?? height ?? width,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevation as Color?,
    );
  }
}

class AdMediaView extends AdView {
  AdMediaView({
    EdgeInsets? padding,
    EdgeInsets? margin,
    AdDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? elevationColor,
  }) : super(
          viewType: 'media_view',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          elevation: elevation,
          elevationColor: elevationColor,
        );

  /// Copy [this] with a new [AdView]
  AdMediaView copyWith(AdView? view) {
    if (view == null) return this;
    return AdMediaView(
      decoration: view.decoration ?? decoration,
      height: view.height ?? height,
      width: view.width ?? width,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevationColor,
    );
  }
}

class AdRatingBarView extends AdView {
  final double? stepSize;

  AdRatingBarView({
    EdgeInsets? padding,
    EdgeInsets? margin,
    AdDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? elevationColor,
    // rating
    this.stepSize,
  }) : super(
          viewType: 'rating_bar',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? WRAP_CONTENT,
          height: height ?? WRAP_CONTENT,
          elevation: elevation,
          elevationColor: elevationColor,
        );

  /// Copy [this] with a new [AdRatingBarView]
  AdRatingBarView copyWith(AdView? view) {
    if (view == null) return this;
    assert(view is AdRatingBarView);
    return AdRatingBarView(
      decoration: view.decoration ?? decoration,
      height: view.height ?? height,
      width: view.width ?? width,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevationColor,
      stepSize: (view as AdRatingBarView).stepSize,
    );
  }

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'stepSize': stepSize});
    return json;
  }
}
