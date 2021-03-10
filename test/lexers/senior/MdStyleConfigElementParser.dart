// @dart=2.9
// const DynamicToken ExecSymbol = DynamicToken('ExecSymbol');
import 'package:lexpro/base/lexer.dart';

/// dtokens
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

/// states
const NodeRootState = 'root_node';
const RootTagConstants = 'root_tag_constants';

/// constants & enums
const BlockQuote = 'blockquote';
const HeadLine = 'headline';
const Paragraph = 'p';
const Common = 'common';
const Head1 = 'h1';
const Head2 = 'h2';
const Head3 = 'h3';
const Head4 = 'h4';
const Head5 = 'h5';
const Head6 = 'h6';
const Builder = 'builder';
const Wrapper = 'wrapper';
const Divider = 'divder';

class MdStyleConfigElementParser extends DTokenedRegexLexer {
  @override
  Map<String, List<JParse>> get parses => {
        'root': [
          JParse(r'[\t\ \n]*', BLANK),
          // JParse(r'<\/', Tend, [RootTagConstants]),
          JParse(r'<', Tstart, [RootTagConstants]),
        ],
        RootTagConstants: [
          JParse.constants(
              [
                [BlockQuote]
              ],
              TAG,
              [POP, 'blockquote_attrs_or_end']),
          JParse.constants(
              [
                [HeadLine]
              ],
              TAG,
              [POP, 'headline_attrs_or_end']),
          JParse.constants(
              [
                [Paragraph]
              ],
              TAG,
              [POP, 'attr_or_end'])
        ],
        'blockquote_attrs': [],
        'tag_constants': [
          JParse.constants(
              [
                [
                  'blockquote',
                  'p',
                  'headline',
                  'wrapper',
                  'builder',
                  'h1',
                  'h2',
                  'h3',
                  'h4',
                  'h5',
                  'h6',
                  'common'
                ]
              ],
              TAG,
              [POP, 'attr_or_end'])
        ],

        /// align: center, left, right, align="left", align="right", align="center"
        /// textAlign: text-center, text-left, text-center, text-align="center", text-align="left", text-align="right"
        /// width: width_100, width="100"
        /// paddingLeft: paddingleft_45
        /// src: src="http://wwwlf.sfdw.png"
        /// centerSlice: 9patch_1_2_3_4,
        /// padding: padding_1_2_3_4,
        /// bgColor: bgcolor:#af9988, bgcolor:[colorvalues],
        /// color: [colorvalues[|shades]], color:[colorvalues[|shades]]
        /// colorvalues#def: [white],[black],red,blue,green,cyan,amber,yellow,brown,grey,indigo,lime,orange,pink,purple,teal'
        /// shades#def: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900
        /// white#def: r'white(10|12|24|30|38|54|60|70)?'
        /// black#def: r'black(12|26|38|45|54|87)?'
        'blockquote_attrs_or_end': [
          JParse.bygroups(
              r'(\/>)([\t\ \n]*)', [closeT, BLANK], [RootTagConstants]),
          JParse.bygroups(r'(>)([\t\ \n]*)', [endT, BLANK],
              ['blockquote_child_tags_or_end']),
        ],
        'blockquote_child_tags_or_end': [
          JParse.constingroups(r'(<)(..)', [
            [Paragraph]
          ], [
            Tstart
          ], [
            'attr_or_end'
          ]),
          JParse.constingroups(r'(<\/)(..)([[\t\ ]*)(>)', [
            [BlockQuote]
          ], [
            DynamicToken.fromEnum(['</'], named: endT),
            TAG,
            BLANK,
            DynamicToken.fromEnum(['>'], named: Tend)
          ], [
            POP
          ])
        ],
        'headline_child_tags_or_end': [
          JParse.constingroups(r'(<)(..)()([[\t\ ]*)(>)([[\t\ \n]*)', [
            [Wrapper, Builder]
          ], [
            Tstart,
            TAG,
            BLANK,
            endT,
            BLANK
          ], [
            'any_tag_lexer'
          ]),
          JParse.constingroups(r'(<)(..)', [
            [Head1, Head2, Head3, Head4, Head5, Head6, Common]
          ], [
            Tstart,
            TAG
          ], [
            'attr_or_end'
          ]),
          JParse.constingroups(r'(<\/)(..)([[\t\ ]*)(>)', [
            [HeadLine]
          ], [
            DynamicToken.fromEnum(['</'], named: endT.name),
            TAG,
            BLANK,
            DynamicToken.fromEnum(['>'], named: Tend.name)
          ], [
            POP
          ])
        ],

        /// inside properties like <build></build> <wrapper></wrapper>
        'any_tag_lexer': [JParse.lexer(MdElementAnyParser())],
        'attr_or_end': [
          JParse.include('include_attr'),
          JParse(r'[\t\ ]+', BLANK),
          JParse.bygroups(
              r'(\/>)([\t\ \n]*)', [closeT, BLANK], ['node_single']),
          JParse.bygroups(r'(>)([\t\ \n]*)', [endT, BLANK], ['node_single']),
          JParse.empty(['error_no_tag_closing'])
        ],
        'blockquote_attrs'
            // 支持简写的属性
            'include_attr': [
          JParse.bygroups(r'([\t\ ]+)([^\/>\t\ \n]+)(=")',
              [BLANK, Attr, Vstart], ['value_str']),
          JParse.bygroups(r'([\t\ ]+)([^\/>\t\ \n]+)', [BLANK, Attr])
        ],
      };

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        /// Common part for including lexers(JParse.lexer) and self usage.
        'attr_or_end': [
          JParse.include('include_attr'),
          JParse(r'[\t\ ]+', BLANK),
          JParse.bygroups(r'(\/>)([\t\ \n]*)', [closeT, BLANK], [POPROOT]),
          JParse.bygroups(r'(>)([\t\ \n]*)', [endT, BLANK], [POPROOT]),
          JParse.empty(['error_no_tag_closing'])
        ],
        // 支持简写的属性
        'include_attr': [
          JParse.bygroups(r'([\t\ ]+)([^\/>\t\ \n]+)(=")',
              [BLANK, Attr, Vstart], ['value_str']),
          JParse.bygroups(r'([\t\ ]+)([^\/>\t\ \n]+)', [BLANK, Attr])
        ],
        'value_str': [
          JParse(r'\\"', ValuePart),
          JParse(r'[^\n"]+', ValuePart),
          JParse(r'"', Vend, [POP]),
          // JParse.bygroups(r'(")([\t\ ]*)', [Vend, BLANK], [POP]),
          JParse.empty(['error_value_should_close_by_quot'])
        ],

        /// pure error part
        'error_no_tag_closing': [],
        'error_value_should_close_by_quot': []
      };

  @override
  RegExpFlags get flags => RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  String get root => 'root';
}

/// should avoid to use wrapper or builder as any tag's name,they are special for returning back.
class MdElementAnyParser extends DTokenedRegexLexer {
  @override
  Map<String, List<JParse>> get parses => {
        'node_any': [
          /// exit to outsider lexar(normally named 'root') or else (no outsider lexer) stay inside this root.
          JParse.bygroups(
              r'(<\/)(wrapper|builder)([\t\ ]*)(>)',
              [Tend, TAG, BLANK, endT],
              [ONPOP('root', DO: BREAK, ELSE: POPROOT)]),
          JParse.bygroups(r'(<\/)([^/>]+)([\t\ ]*)(>)([\t\ \n]*)',
              [Tend, TAG, BLANK, endT]),
          JParse.bygroups(r'(<)([^\/>\ ]+)', [Tstart, TAG], ['attr_or_end']),
        ],
      };

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      currentCommon;

  @override
  RegExpFlags get flags => RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  String get root => 'node_any';
}

class LibraryCertainAttrs extends LibraryLexer {
  @override
  Map<String, List<JParse>> commonparses(
      Map<String, List<JParse>> currentCommon) {
    // TODO: implement commonparses
    throw UnimplementedError();
  }
}
