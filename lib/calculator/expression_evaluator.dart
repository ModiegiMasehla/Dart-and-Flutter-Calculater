import 'constants.dart';
import 'expression_exception.dart';
import 'input_validator.dart';
import 'mathematical_operations.dart';
import 'scientific_functions.dart';

/// Evaluates mathematical expressions without using unsafe code evaluation.
///
/// Supported operators: +, -, *, /, %, ^ and parentheses.
/// Supported constants: pi, e.
/// Supported functions: sqrt, abs, sin, cos, tan, log (base 10), ln, exp.
/// Trigonometric functions use radians.
class ExpressionEvaluator {
  double evaluate(String expression) {
    InputValidator.validateExpression(expression);

    final parser = _Parser(expression);
    final result = parser.parseExpression();
    if (!parser.isAtEnd) {
      throw const ExpressionException('Unexpected input in expression.');
    }
    if (!result.isFinite) {
      throw const ExpressionException('The result is not a finite number.');
    }
    return result;
  }
}

class _Parser {
  _Parser(String source) : _tokens = _tokenize(source);

  final List<_Token> _tokens;
  int _position = 0;

  bool get isAtEnd => _peek.type == _TokenType.end;
  _Token get _peek => _tokens[_position];

  double parseExpression() => _parseAdditive();

  double _parseAdditive() {
    var value = _parseMultiplicative();
    while (_matchOperator('+') || _matchOperator('-')) {
      final operator = _previous.text;
      final right = _parseMultiplicative();
      value = MathematicalOperations.apply(operator, value, right);
    }
    return value;
  }

  double _parseMultiplicative() {
    var value = _parseUnary();
    while (_matchOperator('*') || _matchOperator('/') || _matchOperator('%')) {
      final operator = _previous.text;
      final right = _parseUnary();
      value = MathematicalOperations.apply(operator, value, right);
    }
    return value;
  }

  double _parseUnary() {
    if (_matchOperator('+')) return _parseUnary();
    if (_matchOperator('-')) return -_parseUnary();
    return _parsePower();
  }

  double _parsePower() {
    final base = _parsePrimary();
    if (_matchOperator('^')) {
      // Parsing the right side recursively makes exponentiation right-associative.
      return MathematicalOperations.apply('^', base, _parseUnary());
    }
    return base;
  }

  double _parsePrimary() {
    if (_match(_TokenType.number)) return double.parse(_previous.text);

    if (_match(_TokenType.identifier)) {
      final name = _previous.text.toLowerCase();
      final constantValue = CalculatorConstants.resolve(name);
      if (constantValue != null) return constantValue;

      _consume(_TokenType.leftParen, 'Expected "(" after function name.');
      final argument = _parseAdditive();
      _consume(_TokenType.rightParen, 'Expected ")" after function argument.');
      return _applyFunction(name, argument);
    }

    if (_match(_TokenType.leftParen)) {
      final value = _parseAdditive();
      _consume(_TokenType.rightParen, 'Expected ")" after expression.');
      return value;
    }

    throw const ExpressionException('Expected a number, constant, or expression.');
  }

  double _applyFunction(String name, double value) =>
      ScientificFunctions.apply(name, value);

  bool _matchOperator(String operator) =>
      _peek.type == _TokenType.operator && _peek.text == operator && _advance();

  bool _match(_TokenType type) {
    if (_peek.type != type) return false;
    _advance();
    return true;
  }

  bool _advance() {
    _position++;
    return true;
  }

  _Token get _previous => _tokens[_position - 1];

  void _consume(_TokenType type, String message) {
    if (!_match(type)) throw ExpressionException(message);
  }

  static List<_Token> _tokenize(String source) {
    final tokens = <_Token>[];
    var index = 0;
    while (index < source.length) {
      final char = source[index];
      if (char.trim().isEmpty) {
        index++;
        continue;
      }

      if (_isDigit(char) || char == '.') {
        final start = index;
        var decimalSeen = false;
        if (char == '.') decimalSeen = true;
        index++;
        while (index < source.length) {
          final next = source[index];
          if (_isDigit(next)) {
            index++;
          } else if (next == '.' && !decimalSeen) {
            decimalSeen = true;
            index++;
          } else {
            break;
          }
        }
        final numberText = source.substring(start, index);
        if (numberText == '.') throw const ExpressionException('A decimal point needs digits.');
        tokens.add(_Token(_TokenType.number, numberText));
        continue;
      }

      if (_isLetter(char)) {
        final start = index;
        index++;
        while (index < source.length && _isLetter(source[index])) {
          index++;
        }
        tokens.add(_Token(_TokenType.identifier, source.substring(start, index)));
        continue;
      }

      if ('+-*/%^'.contains(char)) {
        tokens.add(_Token(_TokenType.operator, char));
        index++;
        continue;
      }
      if (char == '(') {
        tokens.add(_Token(_TokenType.leftParen, char));
        index++;
        continue;
      }
      if (char == ')') {
        tokens.add(_Token(_TokenType.rightParen, char));
        index++;
        continue;
      }
      throw ExpressionException('Unsupported character: $char.');
    }
    tokens.add(const _Token(_TokenType.end, ''));
    return tokens;
  }

  static bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  static bool _isLetter(String char) =>
      (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) ||
      (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122);
}

enum _TokenType { number, identifier, operator, leftParen, rightParen, end }

class _Token {
  const _Token(this.type, this.text);
  final _TokenType type;
  final String text;
}
