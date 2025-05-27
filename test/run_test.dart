// ignore_for_file: prefer_single_quotes
import 'package:test/test.dart';
import 'package:debug_output/debug_output.dart';
import 'package:cs/cs.dart';

main() {
  group('Run', () {
    test('run1', () {
      var calc = Calculator();
      var result = calc.addOne(123);
      dump(result, title: 'result');
    });
  });
}
