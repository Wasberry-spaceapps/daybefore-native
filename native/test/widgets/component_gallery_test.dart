import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/ui/components/component_gallery.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('component gallery renders', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const ComponentGallery(), size: size));
    expect(find.text('Component Gallery'), findsOneWidget);
  });
}
