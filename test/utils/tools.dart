// @dart=2.9
import 'dart:math';

import 'package:lexpro/utils/tools.dart';
import 'package:test/test.dart';

cmlexec(
    [String path,
    String version,
    String all,
    String needHelp,
    String verbosePrint]) {
  var out = 'cmlexec:\n';

  out = path != null ? '$out -p $path' : out;
  out = version != null ? '$out -v $version' : out;
  out = all == 'yes' ? '$out -a' : out;
  out = needHelp == 'yes' ? '$out --help' : out;
  out = verbosePrint == 'yes' ? '$out --verbose' : out;
  return out;
}

var rules = [
  [
    r'exec( _path:\"([^\"]*)\"| _vers:\"([^\"]*)\"| _all:\"([^\"]*)\"| _help:\"([^\"]*)\"| _verb:\"([^\"]*)\")+?',
    [2, 3, 4, 5, 6],

    /// 以下是pureOrLink配置,表示第1个括号下的分组是第2、3、4、5、6个括号
    {
      1: [2, 3, 4, 5, 6]
    }
  ],
  [
    r'execTempAll\(( _vers:\"([^\"]*)\"| _help:\"([^\"]*)\"| _verb:\"([^\"]*)\")+?\)',
    ['temp/exec', 2, 'yes', 3, 4],

    /// 以下是pureOrLink配置
    {
      1: [2, 3, 4]
    }
  ],
  [
    r'execTempOnLatestVersion\;',
    ['temp/exec', 'latest', 'no', 'no', 'no']
  ]
];
void main() {
  group('Utils.preWork', () {
    test('groupPureOrLinkCapture', () {
      expect(
          groupPureOrLinkCapture('exec b c -name d f',
              r'exec(((( a)|( b)|( c))+?)| -name((( d)|( e)|( f))+?))+', {
            3: [4, 5, 6],
            8: [9, 10, 11]
          }),
          equals([
            'exec b c -name d',
            ' -name d',
            null,
            null,
            null,
            ' b',
            ' c',
            ' d',
            ' d',
            ' d',
            null,
            ' f'
          ]));
      expect(
          groupPureOrLinkCapture(
              'exec _path:"root/mine" _all:"yes"',
              r'exec( _path:\"([^\"]*)\"| _vers:\"([^\"]*)\"| _all:\"([^\"]*)\"| _help:\"([^\"]*)\"| _verb:\"([^\"]*)\")+?',
              {
                1: [2, 3, 4, 5, 6]
              }),
          equals([
            'exec _path:"root/mine"',
            ' _path:"root/mine"',
            'root/mine',
            null,
            'yes',
            null,
            null
          ]));
    });
  });

  group('Utils.RegstrInvoke', () {
    test('command line exec', () {
      expect(
          RegstrInvoke('exec _path:"root/mine" _all:"yes"', rules,
              invoker: cmlexec),
          equals('cmlexec:\n'
              ' -p root/mine -a'));
      expect(
          RegstrInvoke(
              'execTempAll( _vers:"1.0.5+3" _help:"yes" _verb:"yes")', rules,
              invoker: cmlexec),
          equals('cmlexec:\n'
              ' -p temp/exec -v 1.0.5+3 -a --help --verbose'));
      expect(
          RegstrInvoke('execTempOnLatestVersion\;', rules, invoker: cmlexec),
          equals('cmlexec:\n'
              ' -p temp/exec -v latest'));
    });
  });
  List<List<String>> constants = [
    ['bgcolor', 'color', 'strokecolor'],
    ['="', '_', ''],
    ['red', 'green', 'blue', 'yellow']
  ];
  group('Utils.enumAllConstants', () {
    test('0', () {
      expect(constantEscape('(a+b)?.c+d'), equals(r'\(a\+b\)\?\.c\+d'));
    });
    test('1', () {
      expect(
          enumAllConstants(constants),
          equals([
            'bgcolor="red',
            'bgcolor="green',
            'bgcolor="blue',
            'bgcolor="yellow',
            'bgcolor_red',
            'bgcolor_green',
            'bgcolor_blue',
            'bgcolor_yellow',
            'bgcolorred',
            'bgcolorgreen',
            'bgcolorblue',
            'bgcoloryellow',
            'color="red',
            'color="green',
            'color="blue',
            'color="yellow',
            'color_red',
            'color_green',
            'color_blue',
            'color_yellow',
            'colorred',
            'colorgreen',
            'colorblue',
            'coloryellow',
            'strokecolor="red',
            'strokecolor="green',
            'strokecolor="blue',
            'strokecolor="yellow',
            'strokecolor_red',
            'strokecolor_green',
            'strokecolor_blue',
            'strokecolor_yellow',
            'strokecolorred',
            'strokecolorgreen',
            'strokecolorblue',
            'strokecoloryellow',
          ]));
    });
    test('2', () {
      expect(
          enumAllConstants([
            ['1', '2', '3', '4'],
            [],
            [],
            []
          ]),
          equals(['1', '2', '3', '4']));
    });
    test('3', () {
      expect(
          enumAllConstants([
            [],
            ['1', '2', '3', '4'],
            [],
            ['sad', 'on'],
            []
          ]),
          equals(['1sad', '1on', '2sad', '2on', '3sad', '3on', '4sad', '4on']));
    });
  });

  group('Utils.enumAllTemplates', () {
    test('1', () {
      expect(
          enumAllTemplates([
            ['9patch'],
            [],
            [],
            [],
            []
          ], [
            ['9patch']
          ]),
          equals(['9patch']));
    });
    test('2', () {
      expect(
          enumAllTemplates([
            ['a', 'b', ''],
            ['1', '2'],
            [],
            [],
          ], [
            ['a1_0_0', 'b2_0_0'],
            ['1_1_1', '2_2_2'],
            ['_3_3', '_4_4']
          ]),
          equals([
            'a1_0_0',
            'b2_0_0',
            'a1_1_1',
            'a2_2_2',
            'b1_1_1',
            'b2_2_2',
            '1_1_1',
            '2_2_2',
            'a1_3_3',
            'a1_4_4',
            'a2_3_3',
            'a2_4_4',
            'b1_3_3',
            'b1_4_4',
            'b2_3_3',
            'b2_4_4',
            '1_3_3',
            '1_4_4',
            '2_3_3',
            '2_4_4'
          ]));
    });
  });
  group('Utils.const2Pattern', () {
    test('1', () {
      expect(const2Pattern(constants),
          equals('(bgcolor|color|strokecolor)(="|_)?(red|green|blue|yellow)'));
      expect(
          const2Pattern([
            ['(name+bad)', ''],
            ['?', r'3\4']
          ]),
          equals(r'(\(name\+bad\))?(\?|3\\4)'));
    });
  });
  group('Utils.enumSplitMatches', () {
    test('multiply1', () {
      expect(
          multiply([
            'a1',
            'a2',
            'm0',
            'm4'
          ], [
            '_0_0_0_admin',
            '-0-did-admin-0'
          ], [
            ['0', 'admin'],
            ['0', 'did', 'admin']
          ]),
          equals([
            [
              'a1_0_0_0_admin',
              ['0', 'admin']
            ],
            [
              'a2_0_0_0_admin',
              ['0', 'admin']
            ],
            [
              'm0_0_0_0_admin',
              ['0', 'admin']
            ],
            [
              'm4_0_0_0_admin',
              ['0', 'admin']
            ],
            [
              'a1-0-did-admin-0',
              ['0', 'did', 'admin']
            ],
            [
              'a2-0-did-admin-0',
              ['0', 'did', 'admin']
            ],
            [
              'm0-0-did-admin-0',
              ['0', 'did', 'admin']
            ],
            [
              'm4-0-did-admin-0',
              ['0', 'did', 'admin']
            ]
          ]));
      ;
    });
    test('multiply2', () {
      expect(
          multiply([], ['_0_0_0_admin', '-0-did-admin-0'], [[], []]),
          equals([
            ['_0_0_0_admin', []],
            ['-0-did-admin-0', []]
          ]));
    });
    test('enumSplitTemplates', () {
      expect(
          enumSplitTemplates([
            ['width', 'height'],
            ['_', '='],
            [r'$', ''],
            ['100', '200']
          ], [
            null,
            [],
            [r'$400', r'$0'],
            ['300']
          ], [
            [],
            null,
            [
              [r'$', '4', '0'],
              [r'$', '0']
            ],
            null
          ]),
          equals([
            [
              r'width_$400',
              [r'$', '4', '0']
            ],
            [
              r'width=$400',
              [r'$', '4', '0']
            ],
            [
              r'height_$400',
              [r'$', '4', '0']
            ],
            [
              r'height=$400',
              [r'$', '4', '0']
            ],
            [
              r'width_$0',
              [r'$', '0']
            ],
            [
              r'width=$0',
              [r'$', '0']
            ],
            [
              r'height_$0',
              [r'$', '0']
            ],
            [
              r'height=$0',
              [r'$', '0']
            ],
            [r'width_$300', []],
            [r'width_300', []],
            [r'width=$300', []],
            [r'width=300', []],
            [r'height_$300', []],
            [r'height_300', []],
            [r'height=$300', []],
            ['height=300', []]
          ]));
    });
    test('enumSplitMatches', () {
      expect(
          wrapPrintRegExpLL(enumSplitMatches(
              ['w', 'd', '3'],
              [
                ['width', 'height'],
                ['_', '='],
                [r'$', ''],
                ['100', '200']
              ],
              matchMode: 2,
              templates: [
                null,
                [],
                [r'$400', r'$0'],
                ['300']
              ],
              matchedFromTemplate: [
                [],
                null,
                [
                  [r'$', '4', '0'],
                  [r'$', '0']
                ],
                null
              ])),
          isNotEmpty);
    });
  });
}
