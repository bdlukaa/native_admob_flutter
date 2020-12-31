part of 'layout_builder.dart';

class AdTextView extends AdView {
  /// The style applied to the text view.
  ///
  /// Accepted values:
  /// - color
  /// - fontSize
  /// - fontWeight (only FontWeight.bold)
  /// - letterSpacing
  final TextStyle style;
  final String text;

  final int minLines;
  final int maxLines;

  AdTextView({
    String viewType = 'text_view',
    EdgeInsets padding,
    EdgeInsets margin,
    Color backgroundColor,
    double width,
    double height,
    AdBorderRadius borderRadius,
    BorderSide border,
    AdGradient gradient,
    // text
    this.style,
    this.minLines,
    this.maxLines,
    this.text,
  })  : assert(
          ['text_view', 'button_view'].contains(viewType),
          'This view must be a text view or a button view',
        ),
        super(
          viewType: viewType ?? 'text_view',
          padding: padding,
          margin: margin,
          backgroundColor: backgroundColor,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          borderRadius: borderRadius,
          border: border,
          gradient: gradient,
        );

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    final style = this.style ?? TextStyle(fontSize: 14, color: Colors.black);
    json.addAll({
      'textColor': style.color?.toHex(),
      'textSize': style.fontSize,
      'text': text,
      'letterSpacing': style.letterSpacing,
      'minLines': minLines,
      'maxLines': maxLines,
      'bold': style.fontWeight == FontWeight.bold,
    });
    return json;
  }
}

class AdButtonView extends AdView {
  final Color pressColor;

  AdButtonView({
    EdgeInsets padding,
    EdgeInsets margin,
    double width,
    double height,
    AdBorderRadius borderRadius,
    Color backgroundColor,
    BorderSide border,
    this.pressColor,
    AdGradient gradient,
    // text
    int minLines,
    int maxLines,
    TextStyle textStyle,
    String text,
  }) : super(
          viewType: 'button_view',
          padding: padding,
          margin: margin,
          backgroundColor: backgroundColor,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          borderRadius: borderRadius,
          border: border,
          gradient: gradient,
        );

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'pressColor': pressColor?.toHex()});
    return json;
  }
}
