part of 'gradient.dart';

class AdRadialGradient extends AdGradient {
  const AdRadialGradient({
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
