import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_advanced_calculator/main.dart';

void main() {
  testWidgets('shows calculator, expression field, result and empty history', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('Scientific Calculator'), findsOneWidget);
    expect(find.text('Expression'), findsOneWidget);
    expect(find.text('RESULT'), findsOneWidget);
    expect(find.text('Your calculations will appear here.'), findsOneWidget);
  });

  testWidgets('calculates a button-entered expression and adds history', (tester) async {
    await tester.view.setPhysicalSize(const Size(900, 1000));
    await tester.view.setDevicePixelRatio(1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CalculatorApp());
    await tester.tap(find.byKey(const Key('key-2')).first);
    await tester.tap(find.byKey(const Key('key-+')).first);
    await tester.tap(find.byKey(const Key('key-3')).first);
    await tester.tap(find.byKey(const Key('key-=')).first);
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2+3'), findsOneWidget);
  });

  testWidgets('shows an error for invalid expressions and clear resets input', (tester) async {
    await tester.view.setPhysicalSize(const Size(900, 1000));
    await tester.view.setDevicePixelRatio(1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CalculatorApp());
    await tester.tap(find.byKey(const Key('key-4')).first);
    await tester.tap(find.byKey(const Key('key-/')).first);
    await tester.tap(find.byKey(const Key('key-0')).first);
    await tester.tap(find.byKey(const Key('key-=')).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculator-error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('key-C')).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculator-error')), findsNothing);
  });
}
