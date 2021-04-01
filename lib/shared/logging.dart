// Package imports:
import 'package:logger/logger.dart';

final logger = (Type type) => Logger(printer: CustomerPrinter(type.toString()));

class CustomerPrinter extends LogPrinter {
  final String className;

  CustomerPrinter(this.className);
  @override
  List<String> log(LogEvent event) {
    final emoji = PrettyPrinter.levelEmojis[event.level];
    final colour = PrettyPrinter.levelColors[event.level];
    final message = event.message;

    return [colour('$emoji $className: $message')];
  }
}
