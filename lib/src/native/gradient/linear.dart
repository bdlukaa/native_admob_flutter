part of 'gradient.dart';

class AdLinearGradient extends AdGradient {
  /// Creates a LinearGradient.
  ///
  /// Uses [GradientDrawable](https://developer.android.com/reference/android/graphics/drawable/GradientDrawable)
  /// on Android
  ///
  /// - You must specify at least two colors.
  /// - The default orientation is `left_right` (left to right)
  AdLinearGradient({
    AdGradientOrientation orientation,
    @required List<Color> colors,
  }) : super(
          type: AdGradient.LINEAR,
          colors: colors,
          orientation: orientation,
        );
}

/// The orientation or the gradient
enum AdGradientOrientation {
  /// draw the gradient from the top to the bottom
  top_bottom,

  /// draw the gradient from the top-right to the bottom-left
  tr_bl,

  /// draw the gradient from the right to the left
  right_left,

  /// draw the gradient from the bottom-right to the top-left
  br_tl,

  /// draw the gradient from the bottom to the top
  bottom_top,

  /// draw the gradient from the bottom-left to the top-right
  bl_tr,

  /// draw the gradient from the left to the right
  left_right,

  /// draw the gradient from the top-left to the bottom-right
  tl_br,
}

/// Gets the name of the gradient that will be used by the platform
String _adGradientName(AdGradientOrientation o) {
  return o?.toString()?.replaceAll('AdGradientOrientation.', '');
}
