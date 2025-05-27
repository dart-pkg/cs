import 'package:test/test.dart';
import 'package:debug_output/debug_output.dart';
import 'package:cs/cs.dart';

void main() {
  group('Calculator', () {
    test('addOne', () {
      var calc = Calculator();
      var result = calc.addOne(123);
      dump(result, title: 'result');
      expect(result == 124, isTrue);
    });
  });
}
