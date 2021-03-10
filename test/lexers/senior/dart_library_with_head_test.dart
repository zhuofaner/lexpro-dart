// @dart=2.9
import 'package:lexpro/base/parser.dart';
import 'package:lexpro/base/unprocessed_token.dart';
import 'package:lexpro/lexers/senior/dart_head.dart';
import 'package:test/test.dart';

void main() {
  final lexer = DartHeadLexer(false);
  group('Lexer/Senior: DartLibrary with HeadLexer', () {
    test('librarySingle', () {
      final librarySingleRight1 = """
library jack;
  """;
      final librarySingleRight2 = "library name;";
      final librarySingleWrong1 = "library 'name';";
      final librarySingleWrong2 = "library ;";
      expect(
          lexer.getTokensUnprocessed(librarySingleRight1, ['root', 'library']),
          equals([
            UnprocessedToken(0, Token.Keyword, 'library'),
            UnprocessedToken(7, Token.Text, ' '),
            UnprocessedToken(8, Token.Name, 'jack'),
            UnprocessedToken(12, Token.Text, ''),
            UnprocessedToken(12, Token.Punctuation, ';'),
            UnprocessedToken(13, Token.Text, '\n'),
            UnprocessedToken(14, Token.Text, '  '),
          ]));
      expect(
          lexer.getTokensUnprocessed(librarySingleRight2, ['root', 'library']),
          equals([
            UnprocessedToken(0, Token.Keyword, 'library'),
            UnprocessedToken(7, Token.Text, ' '),
            UnprocessedToken(8, Token.Name, 'name'),
            UnprocessedToken(12, Token.Text, ''),
            UnprocessedToken(12, Token.Punctuation, ';')
          ]));
      expect(
          lexer.getTokensUnprocessed(librarySingleWrong1, ['root', 'library']),
          equals([
            UnprocessedToken(0, Token.Keyword, 'library'),
            UnprocessedToken(7, Token.Text, ' '),
            UnprocessedToken(8, Token.Error, '\''),
            UnprocessedToken(9, Token.Error, 'n'),
            UnprocessedToken(10, Token.Error, 'a'),
            UnprocessedToken(11, Token.Error, 'm'),
            UnprocessedToken(12, Token.Error, 'e'),
            UnprocessedToken(13, Token.Error, '\''),
            UnprocessedToken(14, Token.Error, ';')
          ]));
      expect(
          lexer.getTokensUnprocessed(librarySingleWrong2, ['root', 'library']),
          equals([
            UnprocessedToken(0, Token.Keyword, 'library'),
            UnprocessedToken(7, Token.Text, ' '),
            UnprocessedToken(8, Token.Error, ';')
          ]));
    });
    group('library && import', () {
      final libraryImportRight1 = """
library jack;
import 'dart:html' as HTML;
  """;
      final libraryImportRight2 = """
library name;
import 'dart:html' as HTML;
export 'dart:html' hide parse;
""";
      final libraryImportWrong1 = """
import 'dart:html' as HTML;
library name;
export 'dart:html' hide parse;
""";
      final libraryImportWrong2 =
          "library OOK;import 'dart:math' export 'dart:html';";
      test('right1', () {
        expect(
            lexer
                .getTokensUnprocessed(libraryImportRight1, ['root', 'library']),
            equals([
              UnprocessedToken(0, Token.Keyword, 'library', 'library'),
              UnprocessedToken(7, Token.Text, ' ', 'library'),
              UnprocessedToken(8, Token.Name, 'jack', 'required_name_end'),
              UnprocessedToken(12, Token.Text, '', 'required_name_end'),
              UnprocessedToken(12, Token.Punctuation, ';', 'required_name_end'),
              UnprocessedToken(13, Token.Text, '\n'),
              UnprocessedToken(14, Token.Keyword, 'import'),
              UnprocessedToken(20, Token.Text, ' '),
              UnprocessedToken(21, Token.StringSingle, '\''),
              UnprocessedToken(22, Token.StringSingle, 'dart:html'),
              UnprocessedToken(31, Token.StringSingle, '\''),
              UnprocessedToken(32, Token.Text, ' '),
              UnprocessedToken(33, Token.Keyword, 'as'),
              UnprocessedToken(35, Token.Text, ' '),
              UnprocessedToken(36, Token.Name, 'HTML'),
              UnprocessedToken(40, Token.Text, ''),
              UnprocessedToken(40, Token.Punctuation, ';'),
              UnprocessedToken(41, Token.Text, '\n'),
              UnprocessedToken(42, Token.Text, '  '),
            ]));
      });
      test('right2', () {
        expect(
            lexer
                .getTokensUnprocessed(libraryImportRight2, ['root', 'library']),
            equals([
              UnprocessedToken(0, Token.Keyword, 'library'),
              UnprocessedToken(7, Token.Text, ' '),
              UnprocessedToken(8, Token.Name, 'name'),
              UnprocessedToken(12, Token.Text, ''),
              UnprocessedToken(12, Token.Punctuation, ';'),
              UnprocessedToken(13, Token.Text, '\n'),
              UnprocessedToken(14, Token.Keyword, 'import'),
              UnprocessedToken(20, Token.Text, ' '),
              UnprocessedToken(21, Token.StringSingle, '\''),
              UnprocessedToken(22, Token.StringSingle, 'dart:html'),
              UnprocessedToken(31, Token.StringSingle, '\''),
              UnprocessedToken(32, Token.Text, ' '),
              UnprocessedToken(33, Token.Keyword, 'as'),
              UnprocessedToken(35, Token.Text, ' '),
              UnprocessedToken(36, Token.Name, 'HTML'),
              UnprocessedToken(40, Token.Text, ''),
              UnprocessedToken(40, Token.Punctuation, ';'),
              UnprocessedToken(41, Token.Text, '\n'),
              UnprocessedToken(42, Token.Keyword, 'export'),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.StringSingle, '\''),
              UnprocessedToken(50, Token.StringSingle, 'dart:html'),
              UnprocessedToken(59, Token.StringSingle, '\''),
              UnprocessedToken(60, Token.Text, ' '),
              UnprocessedToken(61, Token.Keyword, 'hide'),
              UnprocessedToken(65, Token.Text, ' '),
              UnprocessedToken(66, Token.Name, 'parse'),
              UnprocessedToken(71, Token.Text, ''),
              UnprocessedToken(71, Token.Punctuation, ';'),
              UnprocessedToken(72, Token.Text, '\n')
            ]));
      });
      test('wrong1', () {
        expect(
            lexer
                .getTokensUnprocessed(libraryImportWrong1, ['root', 'library']),
            equals([
              UnprocessedToken(0, Token.Keyword, 'import'),
              UnprocessedToken(6, Token.Text, ' '),
              UnprocessedToken(7, Token.StringSingle, '\''),
              UnprocessedToken(8, Token.StringSingle, 'dart:html'),
              UnprocessedToken(17, Token.StringSingle, '\''),
              UnprocessedToken(18, Token.Text, ' '),
              UnprocessedToken(19, Token.Keyword, 'as'),
              UnprocessedToken(21, Token.Text, ' '),
              UnprocessedToken(22, Token.Name, 'HTML'),
              UnprocessedToken(26, Token.Text, ''),
              UnprocessedToken(26, Token.Punctuation, ';'),
              UnprocessedToken(27, Token.Text, '\n'),
              UnprocessedToken(28, Token.Error, 'l'),
              UnprocessedToken(29, Token.Error, 'i'),
              UnprocessedToken(30, Token.Error, 'b'),
              UnprocessedToken(31, Token.Error, 'r'),
              UnprocessedToken(32, Token.Error, 'a'),
              UnprocessedToken(33, Token.Error, 'r'),
              UnprocessedToken(34, Token.Error, 'y'),
              UnprocessedToken(35, Token.Error, ' '),
              UnprocessedToken(36, Token.Error, 'n'),
              UnprocessedToken(37, Token.Error, 'a'),
              UnprocessedToken(38, Token.Error, 'm'),
              UnprocessedToken(39, Token.Error, 'e'),
              UnprocessedToken(40, Token.Punctuation, ';'),
              UnprocessedToken(41, Token.Text, '\n'),
              UnprocessedToken(42, Token.Keyword, 'export'),
              UnprocessedToken(48, Token.Text, ' '),
              UnprocessedToken(49, Token.StringSingle, '\''),
              UnprocessedToken(50, Token.StringSingle, 'dart:html'),
              UnprocessedToken(59, Token.StringSingle, '\''),
              UnprocessedToken(60, Token.Text, ' '),
              UnprocessedToken(61, Token.Keyword, 'hide'),
              UnprocessedToken(65, Token.Text, ' '),
              UnprocessedToken(66, Token.Name, 'parse'),
              UnprocessedToken(71, Token.Text, ''),
              UnprocessedToken(71, Token.Punctuation, ';'),
              UnprocessedToken(72, Token.Text, '\n')
            ]));
      });
      test('wrong2', () {
        expect(
            lexer
                .getTokensUnprocessed(libraryImportWrong2, ['root', 'library']),
            equals([
              UnprocessedToken(0, Token.Keyword, 'library'),
              UnprocessedToken(7, Token.Text, ' '),
              UnprocessedToken(8, Token.Name, 'OOK'),
              UnprocessedToken(11, Token.Text, ''),
              UnprocessedToken(11, Token.Punctuation, ';'),
              UnprocessedToken(12, Token.Keyword, 'import'),
              UnprocessedToken(18, Token.Text, ' '),
              UnprocessedToken(19, Token.StringSingle, '\''),
              UnprocessedToken(20, Token.StringSingle, 'dart:math'),
              UnprocessedToken(29, Token.StringSingle, '\''),
              UnprocessedToken(30, Token.Text, ' '),
              UnprocessedToken(31, Token.Error, 'e'),
              UnprocessedToken(32, Token.Error, 'x'),
              UnprocessedToken(33, Token.Error, 'p'),
              UnprocessedToken(34, Token.Error, 'o'),
              UnprocessedToken(35, Token.Error, 'r'),
              UnprocessedToken(36, Token.Error, 't'),
              UnprocessedToken(37, Token.Error, ' '),
              UnprocessedToken(38, Token.Error, '\''),
              UnprocessedToken(39, Token.Error, 'd'),
              UnprocessedToken(40, Token.Error, 'a'),
              UnprocessedToken(41, Token.Error, 'r'),
              UnprocessedToken(42, Token.Error, 't'),
              UnprocessedToken(43, Token.Error, ':'),
              UnprocessedToken(44, Token.Error, 'h'),
              UnprocessedToken(45, Token.Error, 't'),
              UnprocessedToken(46, Token.Error, 'm'),
              UnprocessedToken(47, Token.Error, 'l'),
              UnprocessedToken(48, Token.Error, '\''),
              UnprocessedToken(49, Token.Punctuation, ';')
            ]));
      });
    });
  });
  test('Lexer/Base: processedString', () {
    var test = """
import 'dart:html' as HTML;
library name;
export 'dart:html' hide parse;
""";
    expect(
        lexer.processedString(
            unprocessedTokens:
                lexer.getTokensUnprocessed(test, ['root', 'library'])),
        equals(
            """Keyword(import) StringSingle(\'dart:html\') Keyword(as) Name(HTML)Punctuation(;)
Error(library name)Punctuation(;)
Keyword(export) StringSingle(\'dart:html\') Keyword(hide) Name(parse)Punctuation(;)
"""));
  });
}
