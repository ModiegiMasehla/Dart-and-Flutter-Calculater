# Flutter Advanced Scientific Calculator

An advanced, responsive scientific calculator built with **Dart** and **Flutter**. It provides a Material 3 interface, an expression parser, scientific functions, calculation history, helpful errors, and automated tests.

## Features

- Arithmetic: addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`) and remainder (`%`).
- Powers (`^`), parentheses, negative values and standard operator precedence.
- Constants: `pi` and `e`.
- Functions: `sqrt`, `abs`, `sin`, `cos`, `tan`, `log` (base 10), `ln` and `exp`.
- Trigonometric functions use radians.
- Calculation history for the current session; tap an entry to reuse its expression.
- Clear and backspace controls, result reuse (`Ans`), responsive layout and error messages.
- A hand-written recursive-descent parser; it does not evaluate user input as executable code.

## Requirements

- Flutter SDK (Flutter 3.19 or newer recommended)
- Dart SDK compatible with the Flutter version
- Android Studio, VS Code, or another editor with Flutter support

Check your installation:

```bash
flutter --version
flutter doctor
```

## Run the app

From this project directory:

```bash
flutter pub get
flutter run
```

Choose a connected device or running emulator when prompted. To run on a desktop platform, enable that platform in your Flutter installation and use `flutter run -d linux`, `flutter run -d windows`, or `flutter run -d macos` as appropriate.

## Run tests and static analysis

```bash
flutter test
flutter analyze
```

Build an Android APK:

```bash
flutter build apk
```

The APK is normally written to `build/app/outputs/flutter-apk/app-release.apk` for a release build.

## Example expressions

| Expression | Result |
|---|---:|
| `2 + 3 * 4` | `14` |
| `(2 + 3) * 4` | `20` |
| `2^3^2` | `512` |
| `sqrt(81) + 2^3` | `17` |
| `sin(pi / 2)` | approximately `1` |
| `log(1000)` | `3` |

Enter function calls with parentheses, for example `sqrt(25)` or `sin(pi / 2)`. Function names and constants are case-insensitive. Multiplication must be explicit (`2*pi`, not `2pi`).

## Project structure

```text
flutter_advanced_calculator/
├── lib/
│   ├── calculator/
│   │   ├── calculation_record.dart
│   │   └── expression_evaluator.dart
│   └── main.dart
├── test/
│   ├── expression_evaluator_test.dart
│   └── widget_test.dart
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Design notes for learners

- `ExpressionEvaluator` tokenizes and parses an expression using separate grammar levels. That makes operator precedence explicit and avoids unsafe dynamic evaluation.
- `ExpressionException` represents understandable user-input errors, such as division by zero.
- `CalculationRecord` keeps an expression together with its numeric result.
- `CalculatorScreen` is a stateful widget because the expression, displayed result, error and history change during use.
- The tests cover arithmetic, precedence, scientific functions, invalid inputs and basic widget behaviour.

## Current limitations

- History is held in memory and resets when the app restarts.
- Trigonometric functions use radians only.
- There is no implicit multiplication, variables, equation solving, or persistent history storage.
- `%` means remainder, not a percentage suffix.

## Suggested Git workflow

See `PUSH_STAGES.md` for an ordered commit plan and suggested messages.
