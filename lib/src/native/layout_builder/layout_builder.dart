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
  final AdDecoration decoration;

  /// The padding applied to the view. Default to none
  final EdgeInsets padding;

  /// The margin applied to the view. Default to none
  final EdgeInsets margin;

  /// The width of the view
  final double width;

  /// The height of the view
  final double height;

  /// The type of the view. Do not change this manually
  final String viewType;

  final String tooltipText;

  /// The id of the view. Used to recognize it
  String id;

  AdView(
      {@required this.viewType,
      this.padding = EdgeInsets.zero,
      this.margin = EdgeInsets.zero,
      this.width,
      this.height,
      this.id,
      this.tooltipText,
      this.decoration});

  Map<String, dynamic> toJson() {
    double width = this.width;
    if (width == double.infinity) width = MATCH_PARENT;

    double height = this.height;
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
      // other
      'tooltipText': tooltipText,
    };
    if (decoration != null) json.addAll(decoration.toJson());
    return json;
  }
}

class AdImageView extends AdView {
  AdImageView(
      {EdgeInsets padding,
      EdgeInsets margin,
      double size,
      String tooltipText,
      AdDecoration decoration})
      : super(
          viewType: 'image_view',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: size ?? 40,
          height: size ?? 40,
          tooltipText: tooltipText,
        );
}

class AdMediaView extends AdView {
  AdMediaView({
    EdgeInsets padding,
    EdgeInsets margin,
    AdDecoration decoration,
    double width,
    double height,
    String tooltipText,
  }) : super(
          viewType: 'media_view',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          tooltipText: tooltipText,
        );
}

class AdRatingBarView extends AdView {
  final double stepSize;

  AdRatingBarView({
    EdgeInsets padding,
    EdgeInsets margin,
    AdDecoration decoration,
    double width,
    double height,
    String tooltipText,
    // rating
    this.stepSize,
  }) : super(
          viewType: 'rating_bar',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? WRAP_CONTENT,
          height: height ?? WRAP_CONTENT,
          tooltipText: tooltipText,
        );

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'stepSize': stepSize});
    return json;
  }
}
