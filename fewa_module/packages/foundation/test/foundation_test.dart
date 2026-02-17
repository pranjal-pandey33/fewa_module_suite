import 'package:foundation/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('foundation', () {
    test('foundationHello returns expected message', () {
      expect(foundationHello(), equals('foundation: wired'));
    });
  });
}
