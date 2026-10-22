/// Formats calculation results for display and for re-use inside expressions.
class ResultFormatter {
  ResultFormatter._();

  /// Values smaller than this are shown as zero (hides floating-point noise
  /// such as `sin(pi)` = 1.22e-16).
  static const double _zeroThreshold = 1e-12;

  /// Human-friendly text for the result panel and the history list.
  static String format(double value) {
    if (value.abs() < _zeroThreshold) return '0';
    final magnitude = value.abs();
    if (value == value.roundToDouble() && magnitude < 1e15) {
      return value.toInt().toString();
    }
    if (magnitude >= 1e10 || magnitude < 1e-6) {
      final parts = value.toStringAsExponential(9).split('e');
      return '${_trimZeros(parts[0])}e${parts[1]}';
    }
    return _trimZeros(value.toStringAsPrecision(10));
  }

  /// Full-precision text that can safely be inserted into an expression
  /// (used by the `Ans` key). Negative values are wrapped in parentheses so
  /// that `-3^2` style surprises cannot happen.
  static String toInputString(double value) {
    final text = value == value.roundToDouble() && value.abs() < 1e15
        ? value.toInt().toString()
        : value.toString();
    return value < 0 ? '($text)' : text;
  }

  static String _trimZeros(String text) {
    if (!text.contains('.')) return text;
    return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
