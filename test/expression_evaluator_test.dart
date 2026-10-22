import 'package:flutter_advanced_calculator/calculator/expression_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExpressionEvaluator evaluator;
  setUp(() => evaluator = ExpressionEvaluator());

  group('arithmetic and precedence', () {
    test('handles each basic arithmetic operator', () {
      expect(evaluator.evaluate('18 + 7'), 25);
      expect(evaluator.evaluate('18 - 7'), 11);
      expect(evaluator.evaluate('8 * 6'), 48);
      expect(evaluator.evaluate('45 / 9'), 5);
      expect(evaluator.evaluate('17 % 5'), 2);
    });
    test('uses parentheses and normal precedence', () {
      expect(evaluator.evaluate('4 + 3 * 2'), 10);
      expect(evaluator.evaluate('(4 + 3) * 2'), 14);
    });
    test('supports right-associative powers and negative values', () {
      expect(evaluator.evaluate('3^2^2'), 81);
      expect(evaluator.evaluate('-3 + 8'), 5);
      expect(evaluator.evaluate('2^-3'), closeTo(0.125, 1e-12));
    });
  });

  group('extra syntax', () {
    test('supports unary operators and precedence of unary minus', () {
      expect(evaluator.evaluate('2*-3'), -6);
      expect(evaluator.evaluate('-2^2'), -4);
      expect(evaluator.evaluate('+5'), 5);
    });
    test('supports scientific notation and decimals', () {
      expect(evaluator.evaluate('1e3'), 1000);
      expect(evaluator.evaluate('1.5E-3'), closeTo(0.0015, 1e-15));
      expect(evaluator.evaluate('0.1 + 0.2'), closeTo(0.3, 1e-12));
      expect(evaluator.evaluate('1.5 + .5'), 2);
    });
    test('function and constant names are case-insensitive', () {
      expect(evaluator.evaluate('SQRT(16)'), 4);
      expect(evaluator.evaluate('PI'), closeTo(3.141592653589793, 1e-12));
    });
    test('rejects implicit multiplication, empty brackets and fractional roots of negatives', () {
      for (final expression in ['2(3)', '()', 'sqrt', '(-8)^(1/3)', '1e']) {
        expect(() => evaluator.evaluate(expression), throwsA(isA<ExpressionException>()), reason: expression);
      }
    });
  });

  group('scientific functions and constants', () {
    test('resolves pi and e', () {
      expect(evaluator.evaluate('pi'), closeTo(3.141592653589793, 1e-12));
      expect(evaluator.evaluate('e'), closeTo(2.718281828459045, 1e-12));
    });
    test('calculates supported functions', () {
      expect(evaluator.evaluate('sqrt(144)'), 12);
      expect(evaluator.evaluate('abs(-9)'), 9);
      expect(evaluator.evaluate('sin(0)'), 0);
      expect(evaluator.evaluate('cos(0)'), 1);
      expect(evaluator.evaluate('tan(0)'), 0);
      expect(evaluator.evaluate('log(1000)'), closeTo(3, 1e-12));
      expect(evaluator.evaluate('ln(e)'), closeTo(1, 1e-12));
      expect(evaluator.evaluate('exp(1)'), closeTo(2.718281828459045, 1e-12));
    });
  });

  group('input validation and error handling', () {
    test('rejects blank or oversized input', () {
      expect(() => evaluator.evaluate('  '), throwsA(isA<ExpressionException>()));
      expect(() => evaluator.evaluate('1' * 501), throwsA(isA<ExpressionException>()));
    });
    test('rejects malformed expressions and unsupported characters', () {
      for (final expression in ['7 +', '(2 * 3', '2 & 3', '.', '2 3']) {
        expect(() => evaluator.evaluate(expression), throwsA(isA<ExpressionException>()), reason: expression);
      }
    });
    test('rejects invalid arithmetic and function domains', () {
      for (final expression in ['8 / 0', '8 % 0', 'sqrt(-4)', 'log(0)', 'ln(-1)', 'mystery(3)', '10^10000']) {
        expect(() => evaluator.evaluate(expression), throwsA(isA<ExpressionException>()), reason: expression);
      }
    });
  });
}
