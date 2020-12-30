part of 'layout_builder.dart';

const String HORIZONTAL = 'horizontal';
const String VERTICAL = 'vertical';

class AdLinearLayout extends AdView {
  final String orientation;
  final List<AdView> children;

  final LayoutGravity gravity;

  AdLinearLayout({
    this.orientation = VERTICAL,
    @required this.children,
    EdgeInsets padding,
    EdgeInsets margin,
    Color backgroundColor,
    double width,
    double height,
    AdBorderRadius borderRadius,
    BorderSide border,
    double elevation,
    Color elevationColor,
    this.gravity,
  })  : assert(orientation != null),
        super(
          id: 'linear_layout',
          viewType: 'linear_layout',
          padding: padding,
          margin: margin,
          backgroundColor: backgroundColor,
          width: width ?? MATCH_PARENT,
          height: height ?? WRAP_CONTENT,
          borderRadius: borderRadius,
          border: border,
        );

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    List<Map<String, dynamic>> childrenData = [];
    for (final child in children) childrenData.add(child.toJson());
    json.addAll({
      'children': childrenData,
      'orientation': orientation ?? 'vertical',
      // 'gravity': _layoutGravityName(gravity ?? LayoutGravity.TOP),
    });
    return json;
  }
}

enum LayoutGravity {

  CENTER, CENTER_HORIZONTAL, CENTER_VERTICAL,
  LEFT, RIGHT, TOP, BOTTOM

}

String _layoutGravityName(LayoutGravity g) {
  return g?.toString()?.replaceAll('LayoutGravity.', '');
}