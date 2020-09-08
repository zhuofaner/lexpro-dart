import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/lexers/senior/dart_head_import.dart';

/// about name && names moveto commonparses;
/// about names like [as RENAME(;/ hide/ show)] or [hide HIDDEN1, HIDDEN2, HIDDEN3;] or else
const IMPORT_NAME_AND = 'import_name_and';
const IMPORT_NAME_END = 'import_name_end';
const IMPORT_NAMES_AND = 'import_names_and';
const INCLUDE_IMPORT_NAMES_AND = 'include_import_names_and';
const IMPORT_NAMES_AND_OREND = 'import_names_and_orend';

const REQUIRED_NAME_END = 'required_name_end';

class DartHeadLexer extends RegexLexer {
  DartHeadLexer([bool debuggable = false]) : super(debuggable: debuggable);
  @override
  final RegExpFlags flags = RegExpFlags(
    dotAll: true,
    multiline: true,
  );

  @override
  Map<String, List<Parse>> get parses => {
        "library": [
          /// library appears in front of all
          Parse.bygroups(r'\b(library)\b(\s+)', [Token.Keyword, Token.Text],
              [POP, REQUIRED_NAME_END]),
          Parse.empty([POP, "root"])
        ],
        "root": [
          /// 换行、语句结束符和空白段是合法的
          Parse.include('linebreaker'),
          Parse.include('blankend'),
          Parse(r'\s+', Token.Text),

          /// 把复核规则放在最后
          Parse.lexer(DartHeadImportLexer(debuggable)),
          // Parse.empty([BREAK])
        ],
        "blankend": [
          Parse.bygroups(r'(\s*)(\;)', [Token.Text, Token.Punctuation]),
        ],
        "linebreaker": [
          Parse(r'\s*\n', Token.Text),
        ]
      };

  @override
  String get root => 'root';

  @override
  Map<String, List<Parse>> commonparses(
      Map<String, List<Parse>> currentCommon) {
    return {
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
        Parse(r'"', Token.StringDouble, [POP2]),
        Parse(r'[^"$\\\n]+', Token.StringDouble),
        Parse.include('string_common'),
        Parse(r'\$+', Token.StringDouble)
      ],
      'string_double_multiline': [
        Parse(r'"""', Token.StringDouble, [POP2]),
        Parse(r'[^"$\\]+', Token.StringDouble),
        Parse.include('string_common'),
        Parse(r'(\$|\")+', Token.StringDouble)
      ],
      'string_single': [
        Parse(r"'", Token.StringSingle, [POP2]),
        Parse(r"[^'$\\\n]+", Token.StringSingle),
        Parse.include('string_common'),
        Parse(r'\$+', Token.StringSingle)
      ],
      'string_single_multiline': [
        Parse(r"'''", Token.StringSingle, [POP2]),
        Parse(r"[^'$\\]+", Token.StringSingle),
        Parse.include('string_common'),
        Parse(r"(\$|\')+", Token.StringSingle)
      ],
      INCLUDE_IMPORT_NAMES_AND: [
        Parse(r'[a-zA-Z_$]\w*', Token.Name),
        Parse.bygroups(
            r'(\s*)(\,)(\s*)', [Token.Text, Token.Punctuation, Token.Text]),
        Parse(r'\s+', Token.Text, [POP]),
      ],
      IMPORT_NAMES_AND: [
        Parse.include(INCLUDE_IMPORT_NAMES_AND),
        Parse.empty([POP])
      ],
      IMPORT_NAMES_AND_OREND: [
        Parse.include(INCLUDE_IMPORT_NAMES_AND),
        Parse.include(IMPORT_NAME_END),
      ],
      IMPORT_NAME_AND: [
        Parse(r'[a-zA-Z_$]\w*', Token.Name),
        Parse(r'\s+', Token.Text, [POP]),
        Parse.empty([POP])
      ],
      IMPORT_NAME_END: [
        Parse.bygroups(r'([a-zA-Z_$]\w*)' r'(\s*)(\;)',
            [Token.Name, Token.Text, Token.Punctuation],

            /// 此处需要修改退栈逻辑(根据情况退栈) 解决共用结束规则的问题
            [ONPOP('pop->root', ELSE: POPROOT)]),
        Parse.empty([POP])
      ],
      REQUIRED_NAME_END: [
        Parse.bygroups(r'([a-zA-Z_$]\w*)' r'(\s*)(\;)',
            [Token.Name, Token.Text, Token.Punctuation], [POP])
      ],
    };
  }
}
