import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowCaseView extends StatelessWidget {
  const ShowCaseView(
      {Key? key,
      required this.globalKey,
      required this.title,
      required this.child,
      required this.description,
      required this.shapeBorder})
      : super(key: key);
  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final ShapeBorder shapeBorder;
  @override
  Widget build(BuildContext context) {
    return Showcase(key: globalKey,title: title, description: description, child: child,targetShapeBorder: shapeBorder,);
  }
}


/*


CircleBorder: Creates a perfect circle border.
RoundedRectangleBorder: Creates a rectangle with rounded corners, customizable with BorderRadius.
BeveledRectangleBorder: Creates a rectangle with beveled corners.
StadiumBorder: Creates a pill-shaped border, resembling a stadium.
ContinuousRectangleBorder: Creates a rectangle with smoothly continuous rounded corners.
OutlineInputBorder: Typically used for InputDecoration like text fields; it creates a standard rectangle with a configurable border radius.
UnderlineInputBorder: Another variant for InputDecoration that underlines the text field.
Border: The simplest form of border, which can be applied uniformly or only to specific sides of a rectangle.
InputBorder: A base class for borders that are used to outline InputDecorator widgets, like text fields.
 */