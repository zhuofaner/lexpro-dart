import 'package:lexpro/base/lexer.dart';

import '../senior/MdStyleConfigElementParser.dart';

class JamvAttrOnceLib extends LibraryLexer {
  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'include-jamv-attr-once': [
          JParse(r'[\t\ ]+', BLANK, ['jamv-attr-back-once'])
        ],
        'jamv-attr-back-once': [
          JParse.include('include-pure-jamv-attr-once'),
        ],
        'include-pure-jamv-attr-once': [
          JParse.eventOnConditionInclude(
              'align-once', [JParse.include('jamv-attr-align')]),
          JParse.eventOnConditionInclude(
              'text-align-once', [JParse.include('jamv-attr-text-align')]),
          JParse.eventOnConditionInclude(
              'pos-once', [JParse.include('jamv-attr-pos')]),
          JParse.eventOnConditionInclude(
              'size-once', [JParse.include('jamv-attr-size')]),
        ]
      };
}
