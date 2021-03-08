// @dart=2.9
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/dart.dart';
import 'package:test/test.dart';

import 'regex_lexer_runner.dart';

class DartLexerRunner extends RegexLexerRunner {
  final lexer = DartLexer();
  final specs = {
    'final s = 1;': [
      UnprocessedToken(0, Token.KeywordDeclaration, 'final'),
      UnprocessedToken(5, Token.Text, ' '),
      UnprocessedToken(6, Token.Name, 's'),
      UnprocessedToken(7, Token.Text, ' '),
      UnprocessedToken(8, Token.Operator, '='),
      UnprocessedToken(9, Token.Text, ' '),
      UnprocessedToken(10, Token.Number, '1'),
      UnprocessedToken(11, Token.Punctuation, ';'),
    ],
    // Recursing same lexer to lex string interpolation
    "final s = '1 + 2 = \${(1 + 2 > 3) ? 3 : 1 + 2}';": [
      UnprocessedToken(0, Token.KeywordDeclaration, 'final'),
      UnprocessedToken(5, Token.Text, ' '),
      UnprocessedToken(6, Token.Name, 's'),
      UnprocessedToken(7, Token.Text, ' '),
      UnprocessedToken(8, Token.Operator, '='),
      UnprocessedToken(9, Token.Text, ' '),
      UnprocessedToken(10, Token.StringSingle, '\''),
      UnprocessedToken(11, Token.StringSingle, '1 + 2 = '),
      UnprocessedToken(19, Token.StringInterpol, '\${'),
      UnprocessedToken(0, Token.Punctuation, '('),
      UnprocessedToken(1, Token.Number, '1'),
      UnprocessedToken(2, Token.Text, ' '),
      UnprocessedToken(3, Token.Operator, '+'),
      UnprocessedToken(4, Token.Text, ' '),
      UnprocessedToken(5, Token.Number, '2'),
      UnprocessedToken(6, Token.Text, ' '),
      UnprocessedToken(7, Token.Operator, '>'),
      UnprocessedToken(8, Token.Text, ' '),
      UnprocessedToken(9, Token.Number, '3'),
      UnprocessedToken(10, Token.Punctuation, ')'),
      UnprocessedToken(11, Token.Text, ' '),
      UnprocessedToken(12, Token.Operator, '?'),
      UnprocessedToken(13, Token.Text, ' '),
      UnprocessedToken(14, Token.Number, '3'),
      UnprocessedToken(15, Token.Text, ' '),
      UnprocessedToken(16, Token.Operator, ':'),
      UnprocessedToken(17, Token.Text, ' '),
      UnprocessedToken(18, Token.Number, '1'),
      UnprocessedToken(19, Token.Text, ' '),
      UnprocessedToken(20, Token.Operator, '+'),
      UnprocessedToken(21, Token.Text, ' '),
      UnprocessedToken(22, Token.Number, '2'),
      UnprocessedToken(44, Token.StringInterpol, '}'),
      UnprocessedToken(45, Token.StringSingle, '\''),
      UnprocessedToken(46, Token.Punctuation, ';'),
    ],
    'void foo(int a, String s = \'\') {'
        '  for (int i = 0; i < a; i++) {'
        '    s += i.toString();'
        '  }'
        '  return s;'
        '}': [
      UnprocessedToken(0, Token.KeywordType, 'void'),
      UnprocessedToken(4, Token.Text, ' '),
      UnprocessedToken(5, Token.Name, 'foo'),
      UnprocessedToken(8, Token.Punctuation, '('),
      UnprocessedToken(9, Token.KeywordType, 'int'),
      UnprocessedToken(12, Token.Text, ' '),
      UnprocessedToken(13, Token.Name, 'a'),
      UnprocessedToken(14, Token.Punctuation, ','),
      UnprocessedToken(15, Token.Text, ' '),
      UnprocessedToken(16, Token.KeywordType, 'String'),
      UnprocessedToken(22, Token.Text, ' '),
      UnprocessedToken(23, Token.Name, 's'),
      UnprocessedToken(24, Token.Text, ' '),
      UnprocessedToken(25, Token.Operator, '='),
      UnprocessedToken(26, Token.Text, ' '),
      UnprocessedToken(27, Token.StringSingle, '\''),
      UnprocessedToken(28, Token.StringSingle, '\''),
      UnprocessedToken(29, Token.Punctuation, ')'),
      UnprocessedToken(30, Token.Text, ' '),
      UnprocessedToken(31, Token.Punctuation, '{'),
      UnprocessedToken(32, Token.Text, '  '),
      UnprocessedToken(34, Token.Keyword, 'for'),
      UnprocessedToken(37, Token.Text, ' '),
      UnprocessedToken(38, Token.Punctuation, '('),
      UnprocessedToken(39, Token.KeywordType, 'int'),
      UnprocessedToken(42, Token.Text, ' '),
      UnprocessedToken(43, Token.Name, 'i'),
      UnprocessedToken(44, Token.Text, ' '),
      UnprocessedToken(45, Token.Operator, '='),
      UnprocessedToken(46, Token.Text, ' '),
      UnprocessedToken(47, Token.Number, '0'),
      UnprocessedToken(48, Token.Punctuation, ';'),
      UnprocessedToken(49, Token.Text, ' '),
      UnprocessedToken(50, Token.Name, 'i'),
      UnprocessedToken(51, Token.Text, ' '),
      UnprocessedToken(52, Token.Operator, '<'),
      UnprocessedToken(53, Token.Text, ' '),
      UnprocessedToken(54, Token.Name, 'a'),
      UnprocessedToken(55, Token.Punctuation, ';'),
      UnprocessedToken(56, Token.Text, ' '),
      UnprocessedToken(57, Token.Name, 'i'),
      UnprocessedToken(58, Token.Operator, '+'),
      UnprocessedToken(59, Token.Operator, '+'),
      UnprocessedToken(60, Token.Punctuation, ')'),
      UnprocessedToken(61, Token.Text, ' '),
      UnprocessedToken(62, Token.Punctuation, '{'),
      UnprocessedToken(63, Token.Text, '    '),
      UnprocessedToken(67, Token.Name, 's'),
      UnprocessedToken(68, Token.Text, ' '),
      UnprocessedToken(69, Token.Operator, '+'),
      UnprocessedToken(70, Token.Operator, '='),
      UnprocessedToken(71, Token.Text, ' '),
      UnprocessedToken(72, Token.Name, 'i'),
      UnprocessedToken(73, Token.Punctuation, '.'),
      UnprocessedToken(74, Token.Name, 'toString'),
      UnprocessedToken(82, Token.Punctuation, '('),
      UnprocessedToken(83, Token.Punctuation, ')'),
      UnprocessedToken(84, Token.Punctuation, ';'),
      UnprocessedToken(85, Token.Text, '  '),
      UnprocessedToken(87, Token.Punctuation, '}'),
      UnprocessedToken(88, Token.Text, '  '),
      UnprocessedToken(90, Token.Keyword, 'return'),
      UnprocessedToken(96, Token.Text, ' '),
      UnprocessedToken(97, Token.Name, 's'),
      UnprocessedToken(98, Token.Punctuation, ';'),
      UnprocessedToken(99, Token.Punctuation, '}'),
    ],
  };
}

void main() {
  group('Lexer: Dart', () {
    DartLexerRunner().run();
  });
}
