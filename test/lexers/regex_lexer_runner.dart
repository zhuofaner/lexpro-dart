import 'package:lexpro/base/lexer.dart';
import 'package:test/test.dart';

abstract class RegexLexerRunner {
  RegexLexer get lexer;
  Map<String, Iterable<UnprocessedToken>> get specs;

  void _log(Iterable<UnprocessedToken> tokens) {
    for (final token in tokens) print('$token,');
  }

  void run() {
    for (final spec in specs.entries) {
      final code = spec.key;
      final tokens = spec.value;
      if (tokens == null) {
        _log(lexer.getTokensUnprocessed(code));
      } else {
        _check(code, tokens);
      }
    }
  }

  void _check(String code, Iterable<UnprocessedToken> tokens) {
    test(code, () {
      expect(lexer.getTokensUnprocessed(code), equals(tokens));
    });
  }
}
