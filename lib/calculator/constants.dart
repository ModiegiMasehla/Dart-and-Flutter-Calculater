import 'dart:math' as math;

/// Named mathematical constants supported by the calculator.
///
/// Keeping constants in one place makes it easy to add more later.
class CalculatorConstants {
  CalculatorConstants._();

  static const Map<String, double> values = {
    'pi': math.pi,
    'e': math.e,
  };

  /// Returns the value for [name], or null when it is not a known constant.
  static double? resolve(String name) => values[name.toLowerCase()];
}
