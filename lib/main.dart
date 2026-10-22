import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculator/calculation_record.dart';
import 'calculator/expression_evaluator.dart';
import 'calculator/result_formatter.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Scientific Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BD6)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        ),
        home: const CalculatorScreen(),
      );
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _evaluator = ExpressionEvaluator();
  final List<CalculationRecord> _history = [];
  String _display = '0';
  double _lastResult = 0;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insert(String value) {
    setState(() {
      _error = null;
      final text = _controller.text;
      final selection = _controller.selection;
      final start = selection.isValid ? selection.start : text.length;
      final end = selection.isValid ? selection.end : text.length;
      // A lone leading "0" is replaced by the next digit (0 + 5 -> 5), but
      // operators and brackets are appended to it (0 + "+" -> 0+).
      final replaceZero = text == '0' && RegExp(r'^\d+$').hasMatch(value);
      final inserted = replaceZero ? value.replaceFirst(RegExp(r'^0+(?=\d)'), '') : value;
      final prefix = replaceZero ? '' : text.substring(0, start);
      final suffix = replaceZero ? '' : text.substring(end);
      _controller.value = TextEditingValue(
        text: '$prefix$inserted$suffix',
        selection: TextSelection.collapsed(offset: prefix.length + inserted.length),
      );
    });
  }

  void _backspace() {
    final text = _controller.text;
    if (text.isEmpty) return;
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    setState(() {
      _error = null;
      if (start != end) {
        _controller.value = TextEditingValue(text: text.replaceRange(start, end, ''), selection: TextSelection.collapsed(offset: start));
      } else if (start > 0) {
        _controller.value = TextEditingValue(text: text.replaceRange(start - 1, start, ''), selection: TextSelection.collapsed(offset: start - 1));
      }
    });
  }

  void _clear() => setState(() { _controller.clear(); _display = '0'; _error = null; });

  void _calculate() {
    final expression = _controller.text.trim();
    try {
      final result = _evaluator.evaluate(expression);
      setState(() {
        _display = ResultFormatter.format(result);
        _lastResult = result;
        _error = null;
        _history.insert(0, CalculationRecord(expression: expression, result: result));
        if (_history.length > 30) _history.removeLast();
      });
    } on ExpressionException catch (exception) {
      setState(() => _error = exception.message);
    } catch (_) {
      setState(() => _error = 'Unable to calculate this expression.');
    }
  }

  void _useHistory(CalculationRecord record) {
    setState(() {
      _controller.value = TextEditingValue(text: record.expression, selection: TextSelection.collapsed(offset: record.expression.length));
      _display = ResultFormatter.format(record.result);
      _lastResult = record.result;
      _error = null;
    });
  }

  Future<void> _copyResult() async {
    await Clipboard.setData(ClipboardData(text: _display));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scientific Calculator', style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(tooltip: 'Copy result', onPressed: _copyResult, icon: const Icon(Icons.copy_outlined)),
            IconButton(tooltip: 'Clear history', onPressed: _history.isEmpty ? null : () => setState(_history.clear), icon: const Icon(Icons.delete_sweep_outlined)),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final calculator = _buildCalculator();
            if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 3, child: calculator), const VerticalDivider(width: 1), Expanded(flex: 2, child: _buildHistory())]);
            return Column(children: [Expanded(flex: 3, child: calculator), const Divider(height: 1), Expanded(flex: 2, child: _buildHistory())]);
          }),
        ),
      );

  Widget _buildCalculator() {
    final keys = <String>['sin(', 'cos(', 'tan(', 'sqrt(', 'log(', 'ln(', '(', ')', 'pi', 'e', '^', '⌫', '7', '8', '9', '/', '%', 'C', '4', '5', '6', '*', '-', 'abs(', '1', '2', '3', '+', '.', 'exp(', '0', '00', '±', 'Ans', '=', ''];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(elevation: 0, color: Colors.white, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _controller, focusNode: _focusNode, keyboardType: TextInputType.text, textInputAction: TextInputAction.done, onSubmitted: (_) => _calculate(), decoration: const InputDecoration(labelText: 'Expression', hintText: 'Try: sqrt(81) + 2^3', border: InputBorder.none), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const Divider(), const Text('RESULT', style: TextStyle(fontSize: 11, letterSpacing: 1.4, color: Colors.black54)), const SizedBox(height: 5),
          SelectableText(_display, key: const Key('calculator-result'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
          if (_error != null) ...[const SizedBox(height: 8), Text(_error!, key: const Key('calculator-error'), style: const TextStyle(color: Colors.red, fontSize: 13))],
        ]))),
        const SizedBox(height: 12),
        Expanded(child: GridView.builder(physics: const NeverScrollableScrollPhysics(), itemCount: keys.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 1.35), itemBuilder: (context, index) {
          final key = keys[index];
          if (key.isEmpty) return const SizedBox.shrink();
          final isEquals = key == '=';
          final isAction = {'C', '⌫', '='}.contains(key);
          return FilledButton.tonal(
            key: Key('key-$key'),
            style: FilledButton.styleFrom(backgroundColor: isEquals ? Theme.of(context).colorScheme.primary : isAction ? const Color(0xFFE4E5FB) : Colors.white, foregroundColor: isEquals ? Colors.white : const Color(0xFF282844), padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => _onKey(key), child: FittedBox(fit: BoxFit.scaleDown, child: Text(key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          );
        })),
        const Padding(padding: EdgeInsets.only(top: 8), child: Text('Trigonometric functions use radians.', style: TextStyle(color: Colors.black54, fontSize: 11))),
      ]),
    );
  }

  void _onKey(String key) {
    switch (key) {
      case 'C': _clear(); break;
      case '⌫': _backspace(); break;
      case '=': _calculate(); break;
      case '±': _insert('-'); break;
      case 'Ans': _insert(ResultFormatter.toInputString(_lastResult)); break;
      default: _insert(key); break;
    }
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.history, size: 38, color: Colors.black38), SizedBox(height: 8), Text('Your calculations will appear here.')])));
    return ListView.separated(padding: const EdgeInsets.all(12), itemCount: _history.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (context, index) {
      final record = _history[index];
      return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), title: Text(record.expression, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('= ${ResultFormatter.format(record.result)}', style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.north_west, size: 18), onTap: () => _useHistory(record));
    });
  }
}
