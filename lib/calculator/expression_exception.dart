/// Thrown when an expression is malformed or cannot be evaluated.
class ExpressionException implements Exception {
  const ExpressionException(this.message);

  final String message;

  @override
  String toString() => message;
}
