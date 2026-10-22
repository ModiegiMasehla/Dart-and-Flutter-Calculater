import 'package:flutter_advanced_calculator/calculator/result_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResultFormatter.format', () {
    test('shows whole numbers without a decimal point', () {
      expect(ResultFormatter.format(5), '5');
      expect(ResultFormatter.format(-42), '-42');
      expect(ResultFormatter.format(-0.0), '0');
    });
    test('trims trailing zeros and floating-point noise', () {
      expect(ResultFormatter.format(0.1 + 0.2), '0.3');
      expect(ResultFormatter.format(2.5), '2.5');
      expect(ResultFormatter.format(1 / 3), '0.3333333333');
    });
    test('treats tiny values as zero', () {
      expect(ResultFormatter.format(1.2246467991473532e-16), '0');
    });
    test('uses exponent notation for very large and very small numbers', () {
      expect(ResultFormatter.format(1e20), '1e+20');
      expect(ResultFormatter.format(1.5e-7), '1.5e-7');
    });
  });

  group('ResultFormatter.toInputString', () {
    test('keeps full precision and wraps negatives in brackets', () {
      expect(ResultFormatter.toInputString(5), '5');
      expect(ResultFormatter.toInputString(0.5), '0.5');
      expect(ResultFormatter.toInputString(-3), '(-3)');
    });
  });
}
