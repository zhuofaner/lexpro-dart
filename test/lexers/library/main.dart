// @dart=2.9
import 'package:lexpro/base/lexer.dart';

main() {
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
        ..rootState('lib1')
        ..dependencyAnalyze())
      .pretty('''this is not awsome!
  ''');
  print(out);
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
