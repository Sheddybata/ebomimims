import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ims_mobile/app.dart';

void main() {
  testWidgets('Login screen shows EBOMIM IMS header', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ImsMobileApp()),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('EBOMIM IMS'), findsOneWidget);
  });
}
