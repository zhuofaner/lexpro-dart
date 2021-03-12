import 'package:lexpro/base/lexer.dart';
import '../senior/MdStyleConfigElementParser.dart';

class JamvAttrLib extends LibraryLexer {
  /// align: center, left, right, align="left", align="right", align="center"
  /// textAlign: text-center, text-left, text-center, text-align="center", text-align="left", text-align="right"
  /// pos: middle, top, bottom, pos="middle", pos="top", pos="bottom"
  /// [min|max]?width: width_100, width="100"
  /// [min|max]?height:
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
  final AlignSV = 'align';
  final AlignValuesSL = ['left', 'right', 'center'];
  final PositionSV = 'pos';
  final PositionValuesSL = ['middle', 'top', 'bottom'];
  final TextAlignSV = 'text-align';
  final TextAlignValuesSL = ['text-left', 'text-right', 'text-center'];
  final SizeSL = [
    'width',
    'height',
    'minWidth',
    'minHeight',
    'maxWidth',
    'maxHeight'
  ];
  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'include-jamv-attr': [
          JParse(r'[\t\ ]+', BLANK, [MATCHED(), 'jamv-attr-back'])
        ],
        'jamv-attr-back': [
          JParse.include('include-pure-jamv-attr'),
        ],
        'include-pure-jamv-attr': [
          JParse.eventOnStateWillStart(),
          JParse.eventOnStateWillRestart(),
          JParse.include('jamv-attr-align'),
          JParse.include('jamv-attr-text-align'),
          JParse.eventOnRuleMissed('not align'),
          JParse.include('jamv-attr-pos'),
          JParse.eventOnCondition(
              'only accept one size', [MATCHED(LEAVE: 'pop'), POP]),
          JParse.include('jamv-attr-size',
              replaceAllNewStates: [MATCHED(), POP]),
          JParse.eventOnStateWillEnd()
        ],
        'jamv-attr-align': [
          JParse.constingroups(r'(' + AlignSV + r')(=")(..)(")', [
            AlignValuesSL
          ], [
            DynamicToken.fromEnum([AlignSV], named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.fromEnum(AlignValuesSL, named: ValuePart),
            DynamicToken.asEnum(Vend),
          ], [
            POP
          ]),
          JParse.constants([AlignValuesSL], Attr, [POP])
        ],
        'jamv-attr-text-align': [
          JParse.constingroups(r'(' + TextAlignSV + r')(=")(..)(")', [
            AlignValuesSL
          ], [
            DynamicToken.fromEnum([TextAlignSV], named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.fromEnum(TextAlignValuesSL, named: ValuePart),
            DynamicToken.asEnum(Vend)
          ], [
            POP
          ]),
          JParse.constants([TextAlignValuesSL], Attr, [POP])
        ],
        'jamv-attr-pos': [
          JParse.constingroups(r'(' + PositionSV + r')(=")(..)(")', [
            PositionValuesSL
          ], [
            DynamicToken.fromEnum([PositionSV], named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.fromEnum(PositionValuesSL, named: ValuePart),
            DynamicToken.asEnum(Vend)
          ], [
            POP
          ]),
          JParse.constants([PositionValuesSL], Attr, [POP])
        ],
        'jamv-attr-size': [
          JParse.constingroups(r'(..)(=")(\d+)(")', [
            SizeSL
          ], [
            DynamicToken.fromEnum(SizeSL, named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.asEnum(ValuePart),
            DynamicToken.asEnum(Vend)
          ], [
            POP
          ]),
          JParse.constingroups(r'(..)(_)(\d+)', [
            SizeSL
          ], [
            DynamicToken.fromEnum(SizeSL, named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.asEnum(ValuePart),
          ], [
            POP
          ])
        ]
      };
}
