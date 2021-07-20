part of 'layout_builder.dart';

enum AdTextSizeUnit {
  px,
  dip,
  sp,
  pt,
  ich,
  mm
}

class AdTextView extends AdView {
  /// The style applied to the text view.
  ///
  /// Accepted values:
  /// - color
  /// - fontSize
  /// - fontWeight (only FontWeight.bold)
  /// - letterSpacing
  final TextStyle? style;
  final AdTextSizeUnit? textSizeUnit;
  final String? text;

  final int? minLines;
  final int? maxLines;

  AdTextView({
    String viewType = 'text_view',
    EdgeInsets? padding,
    EdgeInsets? margin,
    AdDecoration? decoration,
    double? width,
    double? height,
    double? elevation,
    Color? elevationColor,
    // text
    this.textSizeUnit,
    this.style,
    this.minLines,
    this.maxLines,
    this.text,
  })  : assert(
          ['text_view', 'button_view'].contains(viewType),
          'This view must be a text view or a button view',
        ),
        super(
          viewType: viewType,
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          elevation: elevation,
          elevationColor: elevationColor,
        );

  AdTextView copyWith(AdView? view) {
    if (view == null) return this;
    assert(view is AdTextView);
    return AdTextView(
      decoration: view.decoration ?? decoration,
      height: view.height ?? height,
      width: view.width ?? width,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevationColor,
      maxLines: (view as AdTextView).maxLines ?? maxLines,
      minLines: view.minLines ?? minLines,
      style: _copyStylesWithin(this.style, view.style),
      text: view.text ?? text,
      textSizeUnit: view.textSizeUnit ?? textSizeUnit
    );
  }

  TextStyle? _copyStylesWithin(TextStyle? a, TextStyle? b) {
    if (a == null && b == null)
      return TextStyle(fontSize: 14, color: Colors.white);
    if (a == null) return b;
    if (b == null) return a;
    return a.copyWith(
      color: b.color,
      fontSize: b.fontSize,
      letterSpacing: b.letterSpacing,
      fontWeight: b.fontWeight,
    );
  }

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    final defaultColor = () {
      final b = WidgetsBinding.instance!.window.platformBrightness;
      switch (b) {
        case Brightness.dark:
          return Colors.white;
        default:
          return Colors.black;
      }
    }();
    final style = _copyStylesWithin(
      TextStyle(fontSize: 14, color: defaultColor),
      this.style,
    )!;
    json.addAll({
      'textColor': style.color?.toHex(),
      'textSize': style.fontSize,
      'text': text,
      'letterSpacing': style.letterSpacing,
      'minLines': minLines ?? 1,
      'maxLines': maxLines,
      'bold': style.fontWeight == FontWeight.bold,
      'textSizeUnit': textSizeUnit?.index,
    });
    return json;
  }
}

class AdButtonView extends AdTextView {
  final Color? pressColor;

  AdButtonView({
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    AdDecoration? decoration,
    double? elevation,
    Color? elevationColor,
    this.pressColor,
    // text
    AdTextSizeUnit? textSizeUnit,
    int? minLines,
    int? maxLines,
    TextStyle? textStyle,
    String? text,
  }) : super(
          viewType: 'button_view',
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          elevation: elevation,
          elevationColor: elevationColor,
          // text
          textSizeUnit: textSizeUnit,
          maxLines: maxLines,
          minLines: minLines,
          style: textStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.black,
                // fontWeight: FontWeight.bold,
              ),
          text: text,
        );

  AdButtonView copyWith(AdView? view) {
    if (view == null) return this;
    assert(view is AdButtonView);
    return AdButtonView(
      decoration: view.decoration ?? decoration,
      height: view.height ?? height,
      width: view.width ?? width,
      margin: view.margin ?? margin,
      padding: view.padding ?? padding,
      elevation: view.elevation ?? elevation,
      elevationColor: view.elevationColor ?? elevationColor,
      maxLines: (view as AdButtonView).maxLines ?? maxLines,
      minLines: view.minLines ?? minLines,
      textStyle: view.style ?? style,
      text: view.text ?? text,
      pressColor: view.pressColor ?? pressColor,
      textSizeUnit: view.textSizeUnit ?? textSizeUnit,
    );
  }

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'pressColor': pressColor?.toHex()});
    return json;
  }
}
