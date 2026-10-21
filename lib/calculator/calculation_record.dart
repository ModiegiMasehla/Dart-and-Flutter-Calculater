/// A single successful calculation shown in the history panel.
class CalculationRecord {
  const CalculationRecord({required this.expression, required this.result});

  final String expression;
  final double result;
}
