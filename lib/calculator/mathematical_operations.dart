import 'dart:math' as math;

import 'expression_exception.dart';

/// Centralises the calculator's basic binary arithmetic operations.
class MathematicalOperations {
  MathematicalOperations._();

  /// Applies [operator] to two operands and validates the result.
  static double apply(String operator, double left, double right) {
    late final double result;

    switch (operator) {
      case '+':
        result = left + right;
        break;
      case '-':
        result = left - right;
        break;
      case '*':
        result = left * right;
        break;
      case '/':
        if (right == 0) {
          throw const ExpressionException('Cannot divide by zero.');
        }
        result = left / right;
        break;
      case '%':
        if (right == 0) {
          throw const ExpressionException(
            'Cannot take a remainder by zero.',
          );
        }
        result = left % right;
        break;
      case '^':
        result = _power(left, right);
        break;
      default:
        throw ExpressionException('Unsupported operator: $operator.');
    }

    if (!result.isFinite) {
      throw const ExpressionException('The result is not a finite number.');
    }
    return result;
  }

  static double _power(double base, double exponent) {
    // A fractional power of a negative number is not a real number.
    if (base < 0 && exponent.isFinite && exponent != exponent.roundToDouble()) {
      throw const ExpressionException(
        'A negative number cannot have a fractional real-number exponent.',
      );
    }
    final result = math.pow(base, exponent).toDouble();
    if (!result.isFinite) {
      throw const ExpressionException('The result is not a finite number.');
    }
    return result;
  }

}

