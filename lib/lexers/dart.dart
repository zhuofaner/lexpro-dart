import 'package:lexpro/base/lexer.dart';

class DartLexer extends RegexLexer {
  final name = 'Dart';
  final aliases = ['dart'];
  final filenames = ['*.dart'];
  final mimetypes = ['text/x-dart'];

  final RegExpFlags flags = RegExpFlags(
    dotAll: true,
    multiline: true,
  );
  Map<String, List<Parse>> get parses => {
        'root': [
          Parse.include('string_literal'),
          Parse(r'#!(.*?)$', Token.CommentPreproc),
          Parse(r'\b(import|export)\b', Token.Keyword, ['import_decl']),
          Parse(r'\b(library|source|part of|part)\b', Token.Keyword),
          Parse(r'[^\S\n]+', Token.Text),
          Parse(r'//.*?\n', Token.CommentSingle),
          Parse(r'/\*.*?\*/', Token.CommentMultiline),
          Parse.bygroups(r'\b(class)\b(\s+)',
              [Token.KeywordDeclaration, Token.Text], ['class']),
          Parse(
              r'\b(assert|break|case|catch|continue|default|do|else|finally|for|'
              r'if|in|is|new|return|super|switch|this|throw|try|while)\b',
              Token.Keyword),
          Parse(
              r'\b(abstract|async|await|const|extends|factory|final|get|'
              r'implements|native|operator|set|static|sync|typedef|var|with|'
              r'yield)\b',
              Token.KeywordDeclaration),
          Parse(r'\b(bool|double|dynamic|int|num|Object|String|void)\b',
              Token.KeywordType),
          Parse(r'\b(false|null|true)\b', Token.KeywordConstant),
          Parse(r'[~!%^&*+=|?:<>/-]|as\b', Token.Operator),
          Parse(r'[a-zA-Z_$]\w*:', Token.NameLabel),
          Parse(r'[a-zA-Z_$]\w*', Token.Name),
          Parse(r'[(){}\[\],.;]', Token.Punctuation),
          Parse(r'0[xX][0-9a-fA-F]+', Token.NumberHex),
          Parse(r'\d+(\.\d*)?([eE][+-]?\d+)?', Token.Number),
          Parse(r'\.\d+([eE][+-]?\d+)?', Token.Number),
          Parse(r'\n', Token.Text)
        ],
        'class': [
          Parse(r'[a-zA-Z_$]\w*', Token.NameClass, [POP])
        ],
        'import_decl': [
          Parse.include('string_literal'),
          Parse(r'\s+', Token.Text),
          Parse(r'\b(as|show|hide)\b', Token.Keyword),
          Parse(r'[a-zA-Z_$]\w*', Token.Name),
          Parse(r'\,', Token.Punctuation),
          Parse(r'\;', Token.Punctuation, [POP])
        ],
        'string_literal': [
          // Raw strings.
          Parse(r'r"""([\w\W]*?)"""', Token.StringDouble),
          Parse(r"r'''([\w\W]*?)'''", Token.StringSingle),
          Parse(r'r"(.*?)"', Token.StringDouble),
          Parse(r"r'(.*?)'", Token.StringSingle),
          // Normal Strings.
          Parse(r'"""', Token.StringDouble, ['string_double_multiline']),
          Parse(r"'''", Token.StringSingle, ['string_single_multiline']),
          Parse(r'"', Token.StringDouble, ['string_double']),
          Parse(r"'", Token.StringSingle, ['string_single'])
        ],
        'string_common': [
          Parse(
              r"\\(x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}|u\{[0-9A-Fa-f]*\}|[a-z'"
              r'"$\\])',
              Token.StringEscape),
          Parse.bygroups(
              r'(\$)([a-zA-Z_]\w*)', [Token.StringInterpol, Token.Name]),
          Parse.bygroups(r'(\$\{)(.*?)(\})', [
            Token.StringInterpol,
            Token.RecurseSameLexer,
            Token.StringInterpol,
          ])
        ],
        'string_double': [
          Parse(r'"', Token.StringDouble, [POP]),
          Parse(r'[^"$\\\n]+', Token.StringDouble),
          Parse.include('string_common'),
          Parse(r'\$+', Token.StringDouble)
        ],
        'string_double_multiline': [
          Parse(r'"""', Token.StringDouble, [POP]),
          Parse(r'[^"$\\]+', Token.StringDouble),
          Parse.include('string_common'),
          Parse(r'(\$|\")+', Token.StringDouble)
        ],
        'string_single': [
          Parse(r"'", Token.StringSingle, [POP]),
          Parse(r"[^'$\\\n]+", Token.StringSingle),
          Parse.include('string_common'),
          Parse(r'\$+', Token.StringSingle)
        ],
        'string_single_multiline': [
          Parse(r"'''", Token.StringSingle, [POP]),
          Parse(r"[^'$\\]+", Token.StringSingle),
          Parse.include('string_common'),
          Parse(r"(\$|\')+", Token.StringSingle)
        ]
      };

  @override
  String get root => 'root';

  @override
  Map<String, List<Parse>> commonparses(
          Map<String, List<Parse>> currentCommon) =>
      null;
}
