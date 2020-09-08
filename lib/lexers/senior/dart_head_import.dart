import 'package:lexpro/base/lexer.dart';
import './dart_head.dart';
import 'package:lexpro/utils/poprouter.dart';

/// part of dart but add grammer rules by adding states.
class DartHeadImportLexer extends RegexLexer {
  DartHeadImportLexer([bool debuggable = false])
      : super(debuggable: debuggable);
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
          /// BREAK always use inside a insider Lexer which is passed to Parse.lexer function,
          /// In order to breakback to outsider Lexer.
          Parse.empty([ONPOP('root', DO: BREAK, ELSE: POPROOT)]
              // [POPTO('root'), BREAK]
              )
        ],
        'import_literal': [
          Parse.include('string_literal'),
          Parse.empty([POP])
        ],
        'import_literal_and_orend': [
          ///此处的string_literal需要移到上一层的nextState中 来满足import 之后衔接的必要条件。
          // Parse.include('string_literal'),
          Parse.bygroups(r'(\s*)(\;)', [Token.Text, Token.Punctuation], [POP]),
          Parse(r'\s+', Token.Text, ['import_sub']),
          // Parse.empty([POP]) //不留这句，可以报错到当前位置解决 import 'name1' import 'name2'的问题
        ],

        /// 没有内容的为错误提示池
        'error_only_support_keyword:as,hide,show': [
          Parse(r'\;', Token.Punctuation, [POP]), //语句结束符可以跳出出错语句
          Parse(r'\n', Token.Punctuation, [POP]) //换行符可以跳出出错语句
        ],

        /// Because of POP passing to the 'nextState' property, 'import_sub' no longer exist in the statestack.
        /// Here just a onetime state example show you how to parse 'import_as_start_part', 'import_show_start_part', 'import_hide_start_part' in order and only parse once.
        'import_sub': [
          Parse.empty([
            POP, // 与Parse.empty配合，不能缺少否则会空转。
            // 'pop->root',
            'error_only_support_keyword:as,hide,show',
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
      };

  @override
  String get root => 'import';

  @override
  Map<String, List<Parse>> commonparses(
      Map<String, List<Parse>> currentCommon) {
    /// to see what is current visible common parse rules
    print('commondefs:${currentCommon.keys}');
    return null;
  }
}
