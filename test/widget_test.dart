import 'package:flutter_test/flutter_test.dart';
import 'package:rusk_media_player/core/init/app_widget.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AppWidget());
    await tester.pump();
  });
}
