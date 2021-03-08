// @dart=2.9

import 'package:lexpro/base/lexer.dart';

DynamicToken BLANK = DynamicToken.from(Token.Text);

/// For Example:
/// We are trying to build a DSL(Domain Specific Language) to remote invoke Linux Commands.
class RemoteCommandLine extends DTokenedRegexLexer {
  /// Tokens
  static const TkExecSymbol = DynamicToken('ExecSymbol');
  static const TkCMDSingle = DynamicToken('CMD.Single');
  static const TkCMDPath = DynamicToken('CMD.Path');
  static const TkCMDCmmdName = DynamicToken('CMD.CmmdName');
  static const TkAbsPath = DynamicToken('AbsPath');
  static const TkRltvPath = DynamicToken('RltvPath');
  static const TkProps = DynamicToken('Props');
  static const TkNAMECommands = DynamicToken('NAME.Commands');

  /// Error states
  static const StErrNotLegalPath = 'ERROR: Not a legal path!';
  static const StErrExecSymbolAbsent = "ERROR: Exec Symbol '\\n' absent";
  static const StErrNotCommand = 'ERROR: Not a command!';
  @override
  Map<String, List<JParse>> get parses => {
        'root': [
          JParse(
              r'(clear|ls|whoami)', TkCMDSingle, ['props_end', 'exec_orend']),
          JParse.bygroups(r'(cd|vim|whereis|rm)([\t\ ]*)', [TkCMDPath, BLANK],
              ['props_end', 'exec_orend', 'path']),
          JParse.bygroups(r'(which)([\t\ ]*)', [TkCMDCmmdName, BLANK],
              ['exec_end', 'commondnames']),
          JParse.empty(['exec_end'])
        ],
        'path': [
          JParse(r'\/(\w+\/?)+', TkAbsPath, [POP]),
          JParse(r'\w+(\/(\w+\/?)*)?', TkRltvPath, [POP]),
          JParse.empty([StErrNotLegalPath])
        ],
        'exec_orend': [
          // END PART
          JParse.bygroups(r'(\s*)(\n)', [BLANK, TkExecSymbol], [POPROOT]),
          // OR PART
          JParse(r'\s+', BLANK, [POP]),
        ],
        'exec_end': [
          JParse.bygroups(r'(\s*)(\n)', [BLANK, TkExecSymbol], [POPROOT]),
          JParse.empty([StErrExecSymbolAbsent])
        ],
        'props_end': [
          JParse(r'-(a|h)', TkProps, [POPROOT]),
        ],
        'commondnames': [
          JParse(r'(clear|ls|whoami|cd|vim|whereis|rm|which)', TkNAMECommands,
              [POP]),
          JParse.empty([StErrNotCommand])
        ]
      };

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {StErrNotLegalPath: [], StErrExecSymbolAbsent: [], StErrNotCommand: []};

  @override
  RegExpFlags get flags => RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  String get root => 'root';
}
