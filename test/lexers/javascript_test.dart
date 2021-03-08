// @dart=2.9
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/javascript.dart';
import 'package:test/test.dart';

void main() {
  final lexer = JavaScriptLexer();
  group('Lexer: JavaScript', () {
    test('const s = 1', () {
      expect(
        lexer.getTokensUnprocessed('const s = 1'),
        equals([
          UnprocessedToken(0, Token.KeywordReserved, 'const'),
          UnprocessedToken(5, Token.Text, ' '),
          UnprocessedToken(6, Token.NameOther, 's'),
          UnprocessedToken(7, Token.Text, ' '),
          UnprocessedToken(8, Token.Operator, '='),
          UnprocessedToken(9, Token.Text, ' '),
          UnprocessedToken(10, Token.NumberInteger, '1'),
        ]),
      );
    });

    test('var name = \'hello\'', () {
      expect(
        lexer.getTokensUnprocessed('var name = \'hello\''),
        equals([
          UnprocessedToken(0, Token.KeywordDeclaration, 'var'),
          UnprocessedToken(3, Token.Text, ' '),
          UnprocessedToken(4, Token.NameOther, 'name'),
          UnprocessedToken(8, Token.Text, ' '),
          UnprocessedToken(9, Token.Operator, '='),
          UnprocessedToken(10, Token.Text, ' '),
          UnprocessedToken(11, Token.StringSingle, '\'hello\''),
        ]),
      );
    });
  });
}
