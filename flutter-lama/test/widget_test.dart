import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_pos/main.dart';

void main() {
  testWidgets('PIN Login with 3 Tabs (Cabang 1, Cabang 2, Owner) smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KasirPinApp());
    expect(find.text('Sarjana Degan POS'), findsOneWidget);
    expect(find.text('Cabang 1'), findsOneWidget);
    expect(find.text('Cabang 2'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
  });
}
