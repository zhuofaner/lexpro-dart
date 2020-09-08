import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/senior/dart_head.dart';
import 'package:test/test.dart';

void main() {
  final lexer = DartHeadLexer();
  group('Lexer/Senior: DartImport with HeadLexer', () {
    String prefixImport = "import 'package:lex/base/lexer.dart' ";
    String FULL(String name) => prefixImport + name;
    group('import single', () {
      final String simpleRight = "import 'package:lex/base/lexer.dart';";
      final String simpleWrong = "import ;";
      test(simpleRight, () {
        expect(
            lexer.getTokensUnprocessed(simpleRight),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ''),
              UnprocessedToken(36, Token.Punctuation, ';')
            ]));
      });
      test(simpleWrong, () {
        expect(
            lexer.getTokensUnprocessed(simpleWrong),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.Text, ''),
              UnprocessedToken(7, Token.Punctuation, ';', 'import_decl')
            ]));
      });
    });
    group("import as start", () {
      String testAsRight = "as LEX;";
      String testAsWrong1 = "as good, name, dream;";
      String testAsWrong2 = "as hide lex;";
      String testAsWrong3 = "as name as name;";
      test(testAsRight, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testAsRight)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'as'),
              UnprocessedToken(39, Token.Text, ' '),
              UnprocessedToken(40, Token.Name, 'LEX'),
              UnprocessedToken(43, Token.Text, ''),
              UnprocessedToken(43, Token.Punctuation, ';')
            ]));
      });
      test(testAsWrong1, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testAsWrong1)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'as'),
              UnprocessedToken(39, Token.Text, ' '),
              UnprocessedToken(40, Token.Name, 'good'),
              UnprocessedToken(44, Token.Error, ','),
              UnprocessedToken(45, Token.Error, ' '),
              UnprocessedToken(46, Token.Error, 'n'),
              UnprocessedToken(47, Token.Error, 'a'),
              UnprocessedToken(48, Token.Error, 'm'),
              UnprocessedToken(49, Token.Error, 'e'),
              UnprocessedToken(50, Token.Error, ','),
              UnprocessedToken(51, Token.Error, ' '),
              UnprocessedToken(52, Token.Error, 'd'),
              UnprocessedToken(53, Token.Error, 'r'),
              UnprocessedToken(54, Token.Error, 'e'),
              UnprocessedToken(55, Token.Error, 'a'),
              UnprocessedToken(56, Token.Error, 'm'),
              UnprocessedToken(57, Token.Punctuation, ';')
            ]));
      });
      test(testAsWrong2, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testAsWrong2)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'as'),
              UnprocessedToken(39, Token.Text, ' '),
              UnprocessedToken(40, Token.Name, 'hide'),
              UnprocessedToken(44, Token.Text, ' '),
              UnprocessedToken(45, Token.Error, 'l'),
              UnprocessedToken(46, Token.Error, 'e'),
              UnprocessedToken(47, Token.Error, 'x'),
              UnprocessedToken(48, Token.Punctuation, ';')
            ]));
      });
      test(testAsWrong3, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testAsWrong3)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'as'),
              UnprocessedToken(39, Token.Text, ' '),
              UnprocessedToken(40, Token.Name, 'name'),
              UnprocessedToken(44, Token.Text, ' '),
              UnprocessedToken(45, Token.Error, 'a'),
              UnprocessedToken(46, Token.Error, 's'),
              UnprocessedToken(47, Token.Error, ' '),
              UnprocessedToken(48, Token.Error, 'n'),
              UnprocessedToken(49, Token.Error, 'a'),
              UnprocessedToken(50, Token.Error, 'm'),
              UnprocessedToken(51, Token.Error, 'e'),
              UnprocessedToken(52, Token.Punctuation, ';')
            ]));
      });
    });
    group("import hide start", () {
      String testHideRight1 = "hide Lexer;";
      String testHideRight2 = "hide Lexer, RegexLexer;";
      String testHideRight3 = "hide Lexer as Done";
      String testHideRight4 = "hide Lexer, RegexLexer as Done";
      String testHideRight5 = "hide RegexLexer as Done show Lexer, RexMatch ;";
      test(testHideRight1, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testHideRight1)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'hide'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ';')
            ]));
      });
      test(testHideRight2, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testHideRight2)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'hide'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ','),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.Name, 'RegexLexer'),
              UnprocessedToken(59, Token.Text, ''),
              UnprocessedToken(59, Token.Punctuation, ';')
            ]));
      });
      test(testHideRight3, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testHideRight3)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'hide'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ' '),
              UnprocessedToken(48, Token.Keyword, 'as'),
              UnprocessedToken(50, Token.Text, ' '),
              UnprocessedToken(51, Token.Name, 'Done')
            ]));
      });
      test(testHideRight4, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testHideRight4)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'hide'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ','),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.Name, 'RegexLexer'),
              UnprocessedToken(59, Token.Text, ' '),
              UnprocessedToken(60, Token.Keyword, 'as'),
              UnprocessedToken(62, Token.Text, ' '),
              UnprocessedToken(63, Token.Name, 'Done')
            ]));
      });
      test(testHideRight5, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testHideRight5)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'hide'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'RegexLexer'),
              UnprocessedToken(52, Token.Text, ' '),
              UnprocessedToken(53, Token.Keyword, 'as'),
              UnprocessedToken(55, Token.Text, ' '),
              UnprocessedToken(56, Token.Name, 'Done'),
              UnprocessedToken(60, Token.Text, ' '),
              UnprocessedToken(61, Token.Keyword, 'show'),
              UnprocessedToken(65, Token.Text, ' '),
              UnprocessedToken(66, Token.Name, 'Lexer'),
              UnprocessedToken(71, Token.Text, ''),
              UnprocessedToken(71, Token.Punctuation, ','),
              UnprocessedToken(72, Token.Text, ' '),
              UnprocessedToken(73, Token.Name, 'RexMatch'),
              UnprocessedToken(81, Token.Text, ' '),
              UnprocessedToken(82, Token.Text, ''),
              UnprocessedToken(82, Token.Punctuation, ';')
            ]));
      });
    });
    group("import show start", () {
      String testShowRight1 = "show Lexer;";
      String testShowRight2 = "show Lexer, RegexLexer;";
      String testShowRight3 = "show Lexer as Done";
      String testShowRight4 = "show Lexer, RegexLexer as Done";
      String testShowRight5 = "show RegexLexer as Done hide Lexer, RexMatch ;";
      test(testShowRight1, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testShowRight1)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'show'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ';')
            ]));
      });
      test(testShowRight2, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testShowRight2)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'show'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ','),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.Name, 'RegexLexer'),
              UnprocessedToken(59, Token.Text, ''),
              UnprocessedToken(59, Token.Punctuation, ';')
            ]));
      });
      test(testShowRight3, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testShowRight3)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'show'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ' '),
              UnprocessedToken(48, Token.Keyword, 'as'),
              UnprocessedToken(50, Token.Text, ' '),
              UnprocessedToken(51, Token.Name, 'Done')
            ]));
      });
      test(testShowRight4, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testShowRight4)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'show'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'Lexer'),
              UnprocessedToken(47, Token.Text, ''),
              UnprocessedToken(47, Token.Punctuation, ','),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.Name, 'RegexLexer'),
              UnprocessedToken(59, Token.Text, ' '),
              UnprocessedToken(60, Token.Keyword, 'as'),
              UnprocessedToken(62, Token.Text, ' '),
              UnprocessedToken(63, Token.Name, 'Done')
            ]));
      });
      test(testShowRight5, () {
        expect(
            lexer.getTokensUnprocessed(FULL(testShowRight5)),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(
                  8, Token.StringSingle, 'package:lex/base/lexer.dart'),
              UnprocessedToken(35, Token.StringSingle, '\''),
              UnprocessedToken(36, Token.Text, ' '),
              UnprocessedToken(37, Token.Keyword, 'show'),
              UnprocessedToken(41, Token.Text, ' '),
              UnprocessedToken(42, Token.Name, 'RegexLexer'),
              UnprocessedToken(52, Token.Text, ' '),
              UnprocessedToken(53, Token.Keyword, 'as'),
              UnprocessedToken(55, Token.Text, ' '),
              UnprocessedToken(56, Token.Name, 'Done'),
              UnprocessedToken(60, Token.Text, ' '),
              UnprocessedToken(61, Token.Keyword, 'hide'),
              UnprocessedToken(65, Token.Text, ' '),
              UnprocessedToken(66, Token.Name, 'Lexer'),
              UnprocessedToken(71, Token.Text, ''),
              UnprocessedToken(71, Token.Punctuation, ','),
              UnprocessedToken(72, Token.Text, ' '),
              UnprocessedToken(73, Token.Name, 'RexMatch'),
              UnprocessedToken(81, Token.Text, ' '),
              UnprocessedToken(82, Token.Text, ''),
              UnprocessedToken(82, Token.Punctuation, ';')
            ]));
      });
    });
  });
}
