import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/typescript.dart';
import 'package:test/test.dart';

import 'regex_lexer_runner.dart';

class TypeScriptLexerRunner extends RegexLexerRunner {
  final lexer = TypeScriptLexer();

  final specs = {
    // isolated byGroups case
    'canRead(p: string)': [
      UnprocessedToken(0, Token.NameOther, 'canRead'),
      UnprocessedToken(7, Token.Punctuation, '('),
      UnprocessedToken(8, Token.NameOther, 'p'),
      UnprocessedToken(9, Token.Text, ': '),
      UnprocessedToken(11, Token.KeywordType, 'string'),
      UnprocessedToken(17, Token.Punctuation, ')'),
    ],
    // longer example including byGroups
    'export async function canRead(p: string): Promise<boolean> {'
        '  try {'
        '    await access(p, fs.constants.R_OK)'
        '    return true'
        '  } catch (err) {'
        '    return false'
        '  }'
        '}': [
      UnprocessedToken(0, Token.KeywordReserved, 'export'),
      UnprocessedToken(6, Token.Text, ' '),
      UnprocessedToken(7, Token.KeywordReserved, 'async'),
      UnprocessedToken(12, Token.Text, ' '),
      UnprocessedToken(13, Token.KeywordDeclaration, 'function'),
      UnprocessedToken(21, Token.Text, ' '),
      UnprocessedToken(22, Token.NameOther, 'canRead'),
      UnprocessedToken(29, Token.Punctuation, '('),
      UnprocessedToken(30, Token.NameOther, 'p'),
      UnprocessedToken(31, Token.Text, ': '),
      UnprocessedToken(33, Token.KeywordType, 'string'),
      UnprocessedToken(39, Token.Punctuation, ')'),
      UnprocessedToken(40, Token.Operator, ':'),
      UnprocessedToken(41, Token.Text, ' '),
      UnprocessedToken(42, Token.NameOther, 'Promise'),
      UnprocessedToken(49, Token.Operator, '<'),
      UnprocessedToken(50, Token.KeywordReserved, 'boolean'),
      UnprocessedToken(57, Token.Operator, '>'),
      UnprocessedToken(58, Token.Text, ' '),
      UnprocessedToken(59, Token.Punctuation, '{'),
      UnprocessedToken(60, Token.Text, '  '),
      UnprocessedToken(62, Token.Keyword, 'try'),
      UnprocessedToken(65, Token.Text, ' '),
      UnprocessedToken(66, Token.Punctuation, '{'),
      UnprocessedToken(67, Token.Text, '    '),
      UnprocessedToken(71, Token.KeywordReserved, 'await'),
      UnprocessedToken(76, Token.Text, ' '),
      UnprocessedToken(77, Token.NameOther, 'access'),
      UnprocessedToken(83, Token.Punctuation, '('),
      UnprocessedToken(84, Token.NameOther, 'p'),
      UnprocessedToken(85, Token.Punctuation, ','),
      UnprocessedToken(86, Token.Text, ' '),
      UnprocessedToken(87, Token.NameOther, 'fs'),
      UnprocessedToken(89, Token.Punctuation, '.'),
      UnprocessedToken(90, Token.NameOther, 'constants'),
      UnprocessedToken(99, Token.Punctuation, '.'),
      UnprocessedToken(100, Token.NameOther, 'R_OK'),
      UnprocessedToken(104, Token.Punctuation, ')'),
      UnprocessedToken(105, Token.Text, '    '),
      UnprocessedToken(109, Token.Keyword, 'return'),
      UnprocessedToken(115, Token.Text, ' '),
      UnprocessedToken(116, Token.KeywordConstant, 'true'),
      UnprocessedToken(120, Token.Text, '  '),
      UnprocessedToken(122, Token.Punctuation, '}'),
      UnprocessedToken(123, Token.Text, ' '),
      UnprocessedToken(124, Token.Keyword, 'catch'),
      UnprocessedToken(129, Token.Text, ' '),
      UnprocessedToken(130, Token.Punctuation, '('),
      UnprocessedToken(131, Token.NameOther, 'err'),
      UnprocessedToken(134, Token.Punctuation, ')'),
      UnprocessedToken(135, Token.Text, ' '),
      UnprocessedToken(136, Token.Punctuation, '{'),
      UnprocessedToken(137, Token.Text, '    '),
      UnprocessedToken(141, Token.Keyword, 'return'),
      UnprocessedToken(147, Token.Text, ' '),
      UnprocessedToken(148, Token.KeywordConstant, 'false'),
      UnprocessedToken(153, Token.Text, '  '),
      UnprocessedToken(155, Token.Punctuation, '}'),
      UnprocessedToken(156, Token.Punctuation, '}'),
    ],
  };
}

void main() {
  group('Lexer: TypeScript', () {
    TypeScriptLexerRunner().run();
  });
}
