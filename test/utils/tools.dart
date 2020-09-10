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
}
