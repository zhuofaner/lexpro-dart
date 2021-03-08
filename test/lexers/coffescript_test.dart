// @dart=2.9

import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/coffeescript.dart';
import 'package:test/test.dart';

import 'regex_lexer_runner.dart';

class CoffeeScriptLexerRunner extends RegexLexerRunner {
  final lexer = CoffeeScriptLexer();
  final specs = {
    ''
        'math ='
        '  root:   Math.sqrt'
        '  square: square'
        '  cube:   (x) -> x * square x': [
      UnprocessedToken(0, Token.NameBuiltin, 'math'),
      UnprocessedToken(4, Token.Text, ' '),
      UnprocessedToken(5, Token.Operator, '='),
      UnprocessedToken(6, Token.Text, '  '),
      UnprocessedToken(8, Token.NameVariable, 'root: '),
      UnprocessedToken(14, Token.Text, '  '),
      UnprocessedToken(16, Token.NameBuiltin, 'Math'),
      UnprocessedToken(20, Token.Punctuation, '.'),
      UnprocessedToken(21, Token.NameOther, 'sqrt'),
      UnprocessedToken(25, Token.Text, '  '),
      UnprocessedToken(27, Token.NameVariable, 'square: '),
      UnprocessedToken(35, Token.NameOther, 'square'),
      UnprocessedToken(41, Token.Text, '  '),
      UnprocessedToken(43, Token.NameVariable, 'cube: '),
      UnprocessedToken(49, Token.Text, '  '),
      UnprocessedToken(51, Token.NameFunction, '(x) ->'),
      UnprocessedToken(57, Token.Text, ' '),
      UnprocessedToken(58, Token.NameOther, 'x'),
      UnprocessedToken(59, Token.Text, ' '),
      UnprocessedToken(60, Token.Operator, '*'),
      UnprocessedToken(61, Token.Text, ' '),
      UnprocessedToken(62, Token.NameOther, 'square'),
      UnprocessedToken(68, Token.Text, ' '),
      UnprocessedToken(69, Token.NameOther, 'x'),
    ]
  };
}

void main() {
  group('Lexer: Dart', () {
    CoffeeScriptLexerRunner().run();
  });
}
