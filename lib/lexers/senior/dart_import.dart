// @dart=2.9

import 'package:lexpro/base/lexer.dart';
// import 'package:lexpro/utils/poprouter.dart';

/// about names like [as RENAME(;/ hide/ show)] or [hide HIDDEN1, HIDDEN2, HIDDEN3;] or else
const IMPORT_NAME_AND = 'import_name_and';
const IMPORT_NAME_END = 'import_name_end';
const IMPORT_NAMES_AND = 'import_names_and';
const INCLUDE_IMPORT_NAMES_AND = 'include_import_names_and';
const IMPORT_NAMES_AND_OREND = 'import_names_and_orend';

/// part of dart but add grammer rules by adding states.
class DartImportLexer extends RegexLexer {
  @override
  final RegExpFlags flags = RegExpFlags(
    dotAll: true,
    multiline: true,
  );

  @override
  Map<String, List<Parse>> get parses => {
        'import': [
          Parse.bygroups(
              r'\b(import|export)\b(\s+)',
              [Token.Keyword, Token.Text],
              ['import_literal_and_orend', 'import_literal']),
          Parse(r'\;', Token.Punctuation, ['pop->root'])
        ],

        /// Avoid unecessary backtrack to 'root',passing to 'nextState' property when constructing Parsing class.
        /// Comparing to POPTO('root'),it can stay in the statestack while the POPTO is taking an immediate action.
        /// Any POP、POP2、POPTO(number|statename) order is taking an action immediately in nextState, and will no longer stay in the statestack as they originally arranged in order.

        'pop->root': [
          Parse.empty([POPROOT])
        ],
        'import_literal': [
          Parse.include('string_literal'),
          Parse.empty([POP])
        ],
        'import_literal_and_orend': [
          ///此处的string_literal需要移到上一层的nextState中 来满足import 之后衔接的必要条件。
          // Parse.include('string_literal'),
          Parse.bygroups(r'(\s*)(\;)', [Token.Text, Token.Punctuation], [POP]),
          Parse(r'\s+', Token.Text, [POP, 'import_sub']),
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
          Parse(r'[a-zA-Z_$]\w*', Token.Name),
          Parse.bygroups(
              r'(\s*)(\;)', [Token.Text, Token.Punctuation], [POPROOT]),
          Parse.empty([POP])
        ],

        /// Because of POP passing to the 'nextState' property, 'import_sub' no longer exist in the statestack.
        /// Here just a onetime state example show you how to parse 'import_as_start_part', 'import_show_start_part', 'import_hide_start_part' in order and only parse once.
        'import_sub': [
          Parse.empty([
            POP,
            'import_hide_start_part',
            'import_show_start_part',
            'import_as_start_part'
          ]),
        ],
        'import_as_start_part': [
          Parse.bygroups(r'\b(as)\b(\s+)', [
            Token.Keyword,
            Token.Text
          ], [
            'pop->root',
            'import_as_depart_part',
            IMPORT_NAME_AND,
            IMPORT_NAME_END
          ]),
          Parse.empty([POP])
        ],
        'include_import_as_end_part': [
          Parse.bygroups(
              r'\b(as)\b(\s+)', [Token.Keyword, Token.Text], [IMPORT_NAME_END])
        ],
        'import_as_end_part': [
          Parse.include('include_import_as_end_part'),
          Parse.empty([POP])
        ],
        'import_as_depart_part': [
          // Parse.include('include_import_hide_end_part'),
          // Parse.include('include_import_show_end_part'),
          Parse.bygroups(r'\b(show)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_hide_end_part', IMPORT_NAMES_AND_OREND]),
          Parse.bygroups(r'\b(hide)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_show_end_part', IMPORT_NAMES_AND_OREND]),
          Parse.empty([POP])
        ],
        'import_hide_start_part': [
          Parse.bygroups(r'\b(hide)\b(\s+)', [Token.Keyword, Token.Text],
              ['pop->root', 'import_hide_depart_part', IMPORT_NAMES_AND_OREND]),
          Parse.empty([POP])
        ],
        'include_import_hide_end_part': [
          Parse.bygroups(r'\b(hide)\b(\s+)', [Token.Keyword, Token.Text],
              [IMPORT_NAMES_AND_OREND]),
        ],
        'import_hide_end_part': [
          Parse.include('include_import_hide_end_part'),
          Parse.empty([POP])
        ],
        'import_hide_depart_part': [
          // Parse.include('include_import_as_end_part'),
          // Parse.include('import_show_end_part'),
          Parse.bygroups(r'\b(as)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_show_end_part', IMPORT_NAME_AND, IMPORT_NAME_END]),
          Parse.bygroups(r'\b(show)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_as_end_part', IMPORT_NAMES_AND_OREND]),
          Parse.empty([POP])
        ],
        'import_show_start_part': [
          Parse.bygroups(r'\b(show)\b(\s+)', [Token.Keyword, Token.Text],
              ['pop->root', 'import_show_depart_part', IMPORT_NAMES_AND_OREND]),
          Parse.empty([POP])
        ],
        'include_import_show_end_part': [
          Parse.bygroups(r'\b(show)\b(\s+)', [Token.Keyword, Token.Text],
              [IMPORT_NAMES_AND_OREND]),
        ],
        'import_show_end_part': [
          Parse.include('include_import_show_end_part'),
          Parse.empty([POP])
        ],
        'import_show_depart_part': [
          // Parse.include('include_import_as_end_part'),
          // Parse.include('import_hide_end_part'),
          Parse.bygroups(r'\b(as)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_show_end_part', IMPORT_NAME_AND, IMPORT_NAME_END]),
          Parse.bygroups(r'\b(hide)\b(\s+)', [Token.Keyword, Token.Text],
              ['import_as_end_part', IMPORT_NAMES_AND_OREND]),
          Parse.empty([POP])
        ],

        /// below is directly copied from DartLexer class.
        /// POP -> POP2 to skip string_literal for enabling use in nextState
        /// there's no grammer like 'something''anotherthing'
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
        ]
      };

  @override
  String get root => 'import';

  @override
  Map<String, List<Parse>> commonparses(
      Map<String, List<Parse>> currentCommon) {
    /// to see what is current visible common parse rules
    return null;
  }
}
