// @dart=2.9
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/base/parser.dart';
import 'package:lexpro/base/types.dart';
import 'package:lexpro/base/unprocessed_token.dart';
import 'package:test/test.dart';

// Tests adapted from: pygments tests/test_regexlexer.py

class TestTransitionLexer extends RegexLexer {
  final Map<String, List<Parse>> parses = {
    'root': [
      Parse('a', Token.Comment, ['rag']),
      Parse('e', Token.Comment),
      Parse('#', Token.Comment, [POP]),
      Parse('@', Token.Comment, [POP, POP]),
      Parse.empty(['beer', 'beer']),
    ],
    'beer': [
      Parse('d', Token.Escape, [POP, POP]),
    ],
    'rag': [
      Parse('b', Token.StringEscape, [PUSH]),
      Parse('c', Token.StringEscape, [POP, 'beer']),
    ],
  };

  @override
  double analyseText(String text) {
    return null;
  }

  @override
  RegExpFlags get flags => RegExpFlags();

  @override
  String get root => 'root';

  @override
  Map<String, List<Parse>> commonparses(
          Map<String, List<Parse>> currentCommon) =>
      null;
}

final _lexer = TestTransitionLexer();
void main() {
  group('regex lexer', () {
    test('Transitions including pop', () {
      expect(
        _lexer.getTokensUnprocessed('abcde'),
        equals([
          UnprocessedToken(0, Token.Comment, 'a'),
          UnprocessedToken(1, Token.StringEscape, 'b'),
          UnprocessedToken(2, Token.StringEscape, 'c'),
          UnprocessedToken(3, Token.Escape, 'd'),
          UnprocessedToken(4, Token.Comment, 'e'),
        ]),
      );
    });
    test('Multiline', () {
      expect(
        _lexer.getTokensUnprocessed('a\ne'),
        equals([
          UnprocessedToken(0, Token.Comment, 'a'),
          UnprocessedToken(1, Token.Text, '\n'),
          UnprocessedToken(2, Token.Comment, 'e'),
        ]),
      );
    });

    test('Default', () {
      expect(
        _lexer.getTokensUnprocessed('d'),
        equals([
          UnprocessedToken(0, Token.Escape, 'd'),
        ]),
      );
    });

    test('Regular', () {
      expect(
        _lexer.getTokensUnprocessed('#e'),
        equals([
          UnprocessedToken(0, Token.Comment, '#'),
          UnprocessedToken(1, Token.Comment, 'e'),
        ]),
      );
    });

    test('Tuple', () {
      expect(
        _lexer.getTokensUnprocessed('@e'),
        equals([
          UnprocessedToken(0, Token.Comment, '@'),
          UnprocessedToken(1, Token.Comment, 'e'),
        ]),
      );
    });
  });
}
