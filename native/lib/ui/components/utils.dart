import 'package:flutter/widgets.dart';

bool isPhone(BuildContext context) => MediaQuery.of(context).size.width < 600;
bool isTablet(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= 600 && w < 900;
}
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;
double sidebarWidth(BuildContext context) => isDesktop(context) ? 288.0 : 256.0;
double contentMaxWidth() => 680.0;
EdgeInsets screenPadding(BuildContext context) =>
    isPhone(context) ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.symmetric(horizontal: 32);
