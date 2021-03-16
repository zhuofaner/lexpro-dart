// @dart=2.9
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/utils/tools.dart';
import '../test/lexers/library/JamvAttrLib.dart';

const DynamicToken TAG = DynamicToken('TAG');
const DynamicToken Tstart = DynamicToken('T.start');
const DynamicToken Tend = DynamicToken('T.end');
const DynamicToken endT = DynamicToken('end.T');
const DynamicToken closeT = DynamicToken('close.T');
const DynamicToken Attr = DynamicToken('Attr');
const DynamicToken Vstart = DynamicToken('V.start');
const DynamicToken Vend = DynamicToken('V.end');
const DynamicToken ValuePart = DynamicToken('Value.part');

DynamicToken BLANK = DynamicToken.from(Token.Text);

class XMLlikeLexer extends DTokenedRegexLexer {
  @override
  Map<String, List<JParse>> get parses => {
        'root': [
          JParse.bygroups(r'(<\/)([^/>]+)([\t\ ]*)(>)([\t\ \n]*)',
              [Tend, TAG, BLANK, endT]),
          JParse.bygroups(
              r'(<)([^\/>\ ]+)', [Tstart, TAG], ['end_or_attrorend']),
        ],
        'include-end': [
          JParse.bygroups(r'(\/>)([\t\ \n]*)', [
            DynamicToken.fromEnum(['/>'], named: closeT),
            BLANK
          ], [
            POPROOT
          ]),
          JParse.bygroups(r'(>)([\t\ \n]*)', [
            DynamicToken.fromEnum(['>'], named: endT),
            BLANK
          ], [
            POPROOT
          ])
        ],
        'end-error': [
          JParse.include('include-end'),
          JParse.empty(['error_no_tag_closing'])
        ],
        // here in this state all parse rules can be enumed when autocompleting.
        'end_or_attrorend': [
          //blank + attr or end symbol
          JParse(r'[\t\ ]+', DynamicToken.fromEnum([' '], named: BLANK),
              ['attr_or_end']),
          //only end symbol
          JParse.include('include-end')
          //with no JParse.empty for need to cycle here
        ],
        'attr_or_end': [
          // include from lib which have all enums and constants for autocompleting.
          // because from lib pure include they need a replaced jump state.
          // Prefix 'pure-' means no state jump
          // Prefix 'include-' means no JParse.empty
          JParse.include('include-pure-jamv-attr', replaceAllNewStates: [POP]),
          // for all typed words as enums
          JParse.include('include-attr', addedNewStates: [POP]),
          JParse.include('include-end'),
          // here if you want to use autoComplete don't put error message here
        ],
        // suppor short attributes with no value part(="") must start with a letter or _
        'include-attr': [
          JParse.bygroups(r'([a-zA-Z_][^\/>\t\ \n]*)(=")', [
            DynamicToken.asEnum(Attr),
            DynamicToken.fromEnum(['="'], named: Vstart)
          ], [
            'value_str'
          ]),
          JParse(r'([a-zA-Z_][^\/>\t\ \n]*)', Attr)
        ],
        'value_str': [
          JParse(r'\\"', ValuePart),
          JParse(r'[^\n"]+', ValuePart),
          // need to jump outof both 'value_str' and 'attr_or_end'
          JParse(r'"', Vend, [POP2]),
          // JParse.bygroups(r'(")([\t\ ]*)', [Vend, BLANK], [POP]),
          JParse.empty(['error_value_should_close_by_quot'])
        ]
      };

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {'error_no_tag_closing': [], 'error_value_should_close_by_quot': []};

  @override
  RegExpFlags get flags => RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  String get root => 'root';

  /// How to use LexerMain in 2.0.0
  LexerMain configLexerMain() {
    return LexerMain.load(libraries: [JamvAttrLib()], root: this)
      ..config = {
        // only list key tokens in configPrint, both DynamicToken,Token and String is allowed.
        'stateWillListTokens': [TAG, 'Attr', Token.Error],

        // needed for autocompleting
        'savingRuntimeContext': true,

        // Event System to build AST
        // 'eventDispatcher': MyEventListener(),

        // If there is error, trigger this to true to see more information.
        'debuggable': false
      }

      //TODO: IF root lexer not given, then test libraries from this state entrance.
      // ..libraryRootState('include-jamv-attr')

      /// To make sure libraries each and root Lexer have no conflicts.
      /// If there is a 'null' error take care of undefined states listed.
      ..dependencyAnalyze();

    // Loading order:
    // =============================
    // JamvAttrLib(1049837909) >> XMLlikeLexer(520416528) >> root
    // =============================

    // Unused states:
    // =============================
    // JamvAttrLib(1049837909):include-jamv-attr
    // XMLlikeLexer(520416528):root
    // XMLlikeLexer(520416528):end-error

    // =============================
    //                      total: 3
  }
}

void main() {
  const forTest = '''
<correct width="10" green bgcolor:grey paddingLeft_10 >
	<p black87 text-right/>
</correct>
<error 10 center>
  <wrapper>
  </wrapper>
	<divider hide/>
</error>
''';
  LexerMain lexer = XMLlikeLexer().configLexerMain();

  print(lexer.pretty(forTest));

//  T.start(<)TAG(correct) Attr(width)V.start(_)Value.part(10) Attr(green) Attr(bgcolor:grey) Attr(paddingLeft_10) end.T(>)
// 	T.start(<)TAG(p) Attr(black87) Attr(text-right)close.T(/>)
// T.end(</)TAG(correct)end.T(>)T.start(<)TAG(error) Error(10 )Attr(center)end.T(>)
//   T.start(<)TAG(wrapper)end.T(>)
//   T.end(</)TAG(wrapper)end.T(>)T.start(<)TAG(divider) Attr(hide)close.T(/>)
// T.end(</)TAG(error)end.T(>)

  // to see error text range and what state are they in
  lexer.configPrint();
// Settings:
// +============================
// |  eventDispatcher : null
// |  savingRuntimeContext : true
// |  stateWillListTokens : [Token.TAG, Attr, Token.Error]
// |  useCache : true
// |  enumStrict : false
// +============================

// Tokens by state:
// =============================

//    TAG:
//     =========================

//    root:
//     correct

//    root:
//     p

//    root:
//     correct

//    root:
//     error

//    root:
//     wrapper

//    root:
//     wrapper

//    root:
//     divider

//    root:
//     error

//     =========================
//                      total: 8

// Attr:
//     =========================

//    attr_or_end:
//     width

//    attr_or_end:
//     green

//    attr_or_end:
//     bgcolor:grey

//    attr_or_end:
//     paddingLeft_10

//    attr_or_end:
//     black87

//    attr_or_end:
//     text-right

//    attr_or_end:
//     center

//    attr_or_end:
//     hide

//     =========================
//                      total: 8

//    Error:
//     =========================

//    attr_or_end:
//     1

//    attr_or_end:
//     0

//    attr_or_end:

//     =========================
//                      total: 3

// =============================
//                     total: 19

  print(lexer.autoCompleting('10', 'attr_or_end'));
// [width="10, width="10", height="10, height="10", maxWidth="10, minWidth="10, maxWidth="10", minWidth="10", maxHeight="10, minHeight="10, maxHeight="10", minHeight="10"]
  print(lexer.splitAutoCompleting(['a', 'l', 'c', 't', 'r'], 'attr_or_end'));
  // [text-align="center", align="center"]
}
