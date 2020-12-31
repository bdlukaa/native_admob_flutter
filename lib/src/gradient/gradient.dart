import 'package:flutter/material.dart';
import '../utils.dart';

part 'linear.dart';
part 'radial.dart';

class AdGradient {
  /// Linear gradient
  static const LINEAR = 'linear';

  /// Radial gradient
  static const RADIAL = 'radial';
  // static const SWEEP = 'sweep';

  final String type;

  /// The colors of the gradients. There must be at least two colors
  final List<Color> colors;

  /// The orientation of the gradient. Default to `left to right`
  final AdGradientOrientation orientation;

  /// The radius used by [AdRadialGradient]
  final double radialGradientRadius;

  /// The center point of the gadient used by [AdRadialGradient].
  /// 
  /// The top-left point is `Alignment(0, 0)` and the
  /// bottom-right point is `Alignment(1, 1)`
  /// 
  /// The default center point is `Alignment(0.5, 0.5)`
  final Alignment gradientCenter;

  const AdGradient({
    @required this.type,
    this.colors,
    this.orientation,
    this.gradientCenter = const Alignment(0.5, 0.5),
    this.radialGradientRadius,
  })  : assert(type != null),
        assert(colors != null),
        assert(colors.length >= 2);

  Map<String, dynamic> toJson() {
    return {
      'type': type ?? LINEAR,
      'colors': colors?.map<String>((e) => e?.toHex())?.toList(),
      'orientation':
          _adGradientName(orientation ?? AdGradientOrientation.left_right),
      'radialGradientCenterX': gradientCenter?.x ?? 0.0,
      'radialGradientCenterY': gradientCenter?.y ?? 0.0,
      'radialGradientRadius': radialGradientRadius ?? 1000.0,
    };
  }
}
