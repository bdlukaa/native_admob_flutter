part of 'layout_builder.dart';

class AdSizedView extends AdSingleChildView {
  /// If non-null, requires the child to have exactly this height.
  final double? height;

  /// If non-null, requires the child to have exactly this width.
  final double? width;

  AdSizedView({
    required AdView child,
    this.height,
    this.width,
  }) : super(child: child);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    double? width = this.width;
    if (width == double.infinity) width = MATCH_PARENT;

    double? height = this.height;
    if (height == double.infinity) height = MATCH_PARENT;
    json.addAll({
      // screen bounds
      'width': width,
      'height': height,
    });

    return json;
  }
}

class AdPadding extends AdSingleChildView {
  /// The amount of space by which to inset the child.
  final EdgeInsets padding;

  AdPadding({
    required AdView child,
    required this.padding,
  })  : assert(padding.isNonNegative),
        super(child: child);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'paddingRight': padding.right,
      'paddingLeft': padding.left,
      'paddingTop': padding.top,
      'paddingBottom': padding.bottom,
    });
    return json;
  }
}

class AdDecoratedView extends AdSingleChildView {
  /// What decoration to paint.
  AdDecoration decoration;

  AdDecoratedView({
    required this.decoration,
    required AdView child,
  }) : super(child: child);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(decoration.toJson());
    return json;
  }
}

class AdDecoration {
  /// The radius of the view
  final AdBorderRadius? borderRadius;

  /// The background color applied to the view.
  final Color? backgroundColor;

  /// The border of the view
  final BorderSide? border;

  /// The gradient of the view.
  ///
  /// If `backgroundColor` is specified, the gradient won't be rendered
  final AdGradient? gradient;

  AdDecoration({
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.gradient,
  });

  Map<String, dynamic> toJson() {
    return {
      // radius
      'topRightRadius': borderRadius?.topRight,
      'topLeftRadius': borderRadius?.topLeft,
      'bottomRightRadius': borderRadius?.bottomRight,
      'bottomLeftRadius': borderRadius?.bottomLeft,
      // border
      'borderWidth': border?.width ?? 0,
      'borderColor': border?.color.toHex(),
      // other
      'backgroundColor': backgroundColor?.toHex(),
      'gradient': gradient?.toJson(),
    };
  }
}
