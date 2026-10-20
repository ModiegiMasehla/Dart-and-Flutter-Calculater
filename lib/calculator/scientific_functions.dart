import 'dart:math' as math;

import 'expression_exception.dart';

/// Scientific functions available to expressions, using radians for angles.
class ScientificFunctions {
  ScientificFunctions._();

  /// Applies a one-argument scientific [functionName] to [value].
  static double apply(String functionName, double value) {
    late final double result;

    switch (functionName.toLowerCase()) {
      case 'sqrt':
        if (value < 0) {
          throw const ExpressionException(
            'Square root needs a non-negative number.',
          );
        }
        result = math.sqrt(value);
        break;
      case 'abs':
        result = value.abs();
        break;
      case 'sin':
        result = math.sin(value);
        break;
      case 'cos':
        result = math.cos(value);
        break;
      case 'tan':
        result = math.tan(value);
        break;
      case 'log':
        if (value <= 0) {
          throw const ExpressionException(
            'log requires a number greater than zero.',
          );
        }
        result = math.log(value) / math.ln10;
        break;
      case 'ln':
        if (value <= 0) {
          throw const ExpressionException(
            'ln requires a number greater than zero.',
          );
        }
        result = math.log(value);
        break;
      case 'exp':
        result = math.exp(value);
        break;
      default:
        throw ExpressionException('Unknown function: $functionName.');
    }

    if (!result.isFinite) {
      throw const ExpressionException('The result is not a finite number.');
    }
    return result;
  }
}
