// @dart=2.9
import 'package:lexpro/base/event.dart';
import 'package:lexpro/base/lexer.dart';

import '../senior/MdStyleConfigElementParser.dart';
import 'JamvAttrLib.dart';
import 'JamvAttrOnceLib.dart';

main() {
  LexerMain lexer = LexerMain.load(libraries: [
    // JamvAttrOnceLib(),
    JamvAttrLib(),
  ])
    ..libraryRootState('include-jamv-attr')
    // ..rootState('include-jamv-attr-once')
    ..config = {
      'stateWillListTokens': [Attr, Token.Error],
      'savingRuntimeContext': true,
      'willAutoCompleteErrors': true,
      // 'eventDispatcher': MyEventListener(),
      'debuggable': false,
    }
    ..dependencyAnalyze();
  print('1st:' + lexer.pretty(''' wid'''));
  lexer.configPrint();
  print('1st autocomplete:' +
      lexer.autoCompleting('wid', 'jamv-attr-back').toString());

  // print(lexer.pretty(''' width="10" minHeight'''));
  // lexer.configPrint();
  // print(lexer.autoCompleting('minHeight', 'jamv-attr-back'));

  print('2st' + lexer.pretty(''' width="10" width="100"'''));
  // lexer.configPrint();

  // print(lexer.pretty(''' width="10" minHeight_100 center text-right bottom'''));
  // lexer.configPrint();
  // print(lexer.pretty(''' width="10" minHeight_100 cnter text-right bottom'''));
  // print(lexer.configPrint());
  // print(lexer.pretty(''' dth="10" minHeight_ center build text-right '''));
  // print(lexer.configPrint());
}

_test1() {
  var out = (LexerMain.load(libraries: [
    Lib1(), // rely on lib2
    Lib2(), // rely on lib3
    NamedLib({
      // rely on lib4
      'lib3': [
        JParse(r'not ', DynamicToken('not'), ['lib4'])
      ]
    }),
    NamedLib({
      'lib4': [
        JParse(r'awsome!', DynamicToken('awsome'), [POPROOT])
      ]
    })
  ])
        ..libraryRootState('lib1')
        ..dependencyAnalyze())
      .pretty('''this is not awsome!
  ''');
  print(out);
}

class MyEventListener extends FullEventListener {
  int index = 0;
  @override
  bool onCondition(String eventFlag) {
    print('\nonCondition');
    print('\n\t\teventFlag:$eventFlag');
    print('\n\t\tcounting:${++index}');
    if (index > 1) return true;
    return false;
  }

  bool once = false;
  @override
  bool onConditionInclude(String eventFlag) {
    print('\nonConditionInclude');
    print('\n\t\teventFlag:$eventFlag');
    print('\n\t\tcounting:${++index}');
    if (eventFlag.contains('size')) return true;
    return false;
  }

  @override
  onRuleMatched(String stateName, Context context,
      {String enter, String leave}) {
    print('\nonRuleMatched');
    print('\n\t\tcontex:$context');
    print('\n\t\tstateName:$stateName enter:$enter leave:$leave');
  }

  @override
  onRuleMissed(String ruleMissedFlag) {
    print('\nonRuleMissed');
    print('\n\t\truleMissedFlag:$ruleMissedFlag');
  }

  @override
  onRuleWillStart(String ruleStartFlag) {
    print('\nonRuleWillStart');
    print('\n\t\truleStartFlag:$ruleStartFlag');
  }

  @override
  onStateWillEnd(String stateName) {
    print('\nonStateWillEnd');
    print('\n\t\tstateName:$stateName');
  }

  @override
  onStateWillRestart(String stateName) {
    print('\nonStateWillRestart');
    print('\n\t\tstateName:$stateName');
  }

  @override
  onStateWillStart(String stateName) {
    print('\nonStateWillStart');
    print('\n\t\tstateName:$stateName');
  }
}

class Lib1 extends LibraryLexer {
  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'lib1': [
          JParse(r'(this) ', DynamicToken('this'), ['lib2'])
        ],
        // for override(lib2) and undefined(lib44) test
        'lib2': [
          JParse(r'nothing ', DynamicToken.from(Token.Text), ['lib44'])
        ]
      };
}

class Lib2 extends LibraryLexer {
  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'lib2': [
          JParse(r'(is) ', DynamicToken('is'), ['lib3'])
        ]
      };
}

class NamedLib extends LibraryLexer {
  Map<String, List<JParse>> _commonparses;
  String name;
  NamedLib(this._commonparses, {this.name});
  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      _commonparses;
}
