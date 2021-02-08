part of 'gradient.dart';

class AdRadialGradient extends AdGradient {
  /// Creates a RadialGradient
  ///
  /// Uses a [GradientDrawable](https://developer.android.com/reference/android/graphics/drawable/GradientDrawable)
  /// on Android
  ///
  /// - You must specify at least two [colors].
  /// - The default value for [radius] is 1000
  /// - The default value for [center] is `Alignment(0.5, 0.5)`
  AdRadialGradient({
    @required List<Color> colors,
    double radius,
    Alignment center,
  }) : super(
          type: AdGradient.RADIAL,
          colors: colors,
          radialGradientRadius: radius,
          gradientCenter: center ?? const Alignment(0.5, 0.5),
        );
}
