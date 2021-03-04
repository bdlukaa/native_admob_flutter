import 'package:flutter/material.dart';
import '../utils.dart';

part 'linear.dart';
part 'radial.dart';

class AdGradient {
  /// Linear gradient. Used by [AdLinearGradient]
  static const LINEAR = 'linear';

  /// Radial gradient. Used by [AdRadialGradient]
  static const RADIAL = 'radial';

  // /// Sweep gradient. Used by [AdSweepGradient]
  // static const SWEEP = 'sweep';

  /// The type of the gradient.
  final String type;

  /// The colors of the gradients. There must be at least two colors
  final List<Color>? colors;

  /// The orientation of the gradient. Default to `left to right`
  final AdGradientOrientation? orientation;

  /// The radius used by [AdRadialGradient]
  final double? radialGradientRadius;

  /// The center point of the gadient used by [AdRadialGradient].
  ///
  /// The top-left point is `Alignment(0, 0)` and the
  /// bottom-right point is `Alignment(1, 1)`
  ///
  /// The default center point is `Alignment(0.5, 0.5)`
  final Alignment gradientCenter;

  AdGradient({
    required this.type,
    this.colors,
    this.orientation,
    this.gradientCenter = const Alignment(0.5, 0.5),
    this.radialGradientRadius,
  })  : assert(
          [LINEAR, RADIAL].contains(type),
          'You must specify a valid gradient type. It can be: $LINEAR or $RADIAL',
        ),
        assert(
          colors != null && colors.length >= 2,
          'You must specify at least two colors',
        );

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'colors': colors?.map<String>((e) => e.toHex()).toList(),
      'orientation':
          _adGradientName(orientation ?? AdGradientOrientation.left_right),
      'radialGradientCenterX': gradientCenter.x,
      'radialGradientCenterY': gradientCenter.y,
      'radialGradientRadius': radialGradientRadius ?? 1000.0,
    };
  }
}
