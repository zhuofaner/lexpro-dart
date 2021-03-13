import 'package:lexpro/base/lexer.dart';

void main() {
  LexerMain lexer = LexerMain.load(libraries: [NullableLexerTest()])
    ..libraryRootState('root');
  print(lexer.pretty('a2 2 b2 b1 c1 b3'));
  lexer.configPrint();
  print(lexer.autoCompleting('b3', 'root'));
  print(lexer.autoCompleting('b', 'root'));
}

class NullableLexerTest extends LibraryLexer {
  /// Better when depart
  var LETTER_SL = ['a', 'b', 'c', ''];
  var NUMBER_SL = ['1', '2'];

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'root': [
          /// as one combination however cannot enum words from constants
          JParse.constingroups(r'((..))([\t\ ]*)', [
            LETTER_SL,
            NUMBER_SL
          ], [
            DynamicToken.asEnum(Token.Name),
            null,
            null,
            DynamicToken('BLANK')
          ])
        ]
      };
}
