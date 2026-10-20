import 'expression_exception.dart';

/// Performs checks on user input before the expression parser processes it.
class InputValidator {
  InputValidator._();

  /// Checks for common input problems and keeps expressions to a safe size.
  static void validateExpression(String expression) {
    if (expression.trim().isEmpty) {
      throw const ExpressionException('Enter an expression.');
    }
    if (expression.length > 500) {
      throw const ExpressionException(
        'Expression is too long (maximum 500 characters).',
      );
    }
  }
}
