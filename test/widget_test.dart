import 'package:flutter/material.dart';
import 'package:flutter_advanced_calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gives the test a large, desktop-like screen so every key is visible.
void useLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pressKeys(WidgetTester tester, List<String> keys) async {
  for (final key in keys) {
    await tester.tap(find.byKey(Key('key-$key')));
  }
  await tester.pumpAndSettle();
}

String resultText(WidgetTester tester) =>
    tester.widget<SelectableText>(find.byKey(const Key('calculator-result'))).data!;

String expressionText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('shows calculator, expression field, result and empty history', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('Scientific Calculator'), findsOneWidget);
    expect(find.text('Expression'), findsOneWidget);
    expect(find.text('RESULT'), findsOneWidget);
    expect(find.text('Your calculations will appear here.'), findsOneWidget);
    expect(resultText(tester), '0');
  });

  testWidgets('calculates a button-entered expression and adds history', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(const CalculatorApp());
    await pressKeys(tester, ['2', '+', '3', '=']);
    expect(resultText(tester), '5');
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('2+3')),
      findsOneWidget,
    );
    expect(find.text('= 5'), findsOneWidget);
  });

  testWidgets('shows an error for invalid expressions and clear resets input', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(const CalculatorApp());
    await pressKeys(tester, ['4', '/', '0', '=']);
    expect(find.byKey(const Key('calculator-error')), findsOneWidget);
    expect(find.text('Cannot divide by zero.'), findsOneWidget);
    await pressKeys(tester, ['C']);
    expect(find.byKey(const Key('calculator-error')), findsNothing);
    expect(expressionText(tester), isEmpty);
    expect(resultText(tester), '0');
  });

  testWidgets('backspace removes the last character', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(const CalculatorApp());
    await pressKeys(tester, ['1', '2', '⌫']);
    expect(expressionText(tester), '1');
  });

  testWidgets('a leading zero is replaced by a digit but kept before an operator', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(const CalculatorApp());
    await pressKeys(tester, ['0', '5']);
    expect(expressionText(tester), '5');
    await pressKeys(tester, ['C', '0', '+', '5']);
    expect(expressionText(tester), '0+5');
  });

  testWidgets('Ans re-uses the previous result', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(const CalculatorApp());
    await pressKeys(tester, ['2', '+', '3', '=', 'C', 'Ans', '*', '2', '=']);
    expect(resultText(tester), '10');
  });
}
