// @dart=2.9
import 'package:lexpro/base/lexer.dart';

const DynamicToken ExecSymbol = DynamicToken('ExecSymbol');
DynamicToken BLANK = DynamicToken.from(Token.Text);

/// For Example:
/// We are trying to build a DSL(Domain Specific Language) to remote invoke Linux Commands.
class RemoteCommandLine extends DTokenedRegexLexer {
  @override
  Map<String, List<JParse>> get parses => {
        'root': [
          JParse.bygroups(r'(clear|ls|whoami)([\t\ ]*)',
              [DynamicToken('CMD.Single'), BLANK], ['props_end', 'exec_orend']),
          JParse.bygroups(
              r'(cd|vim|whereis|rm)([\t\ ]*)',
              [DynamicToken('CMD.Path'), BLANK],
              ['props_end', 'exec_orend', 'path']),
          JParse.bygroups(
              r'(which)([\t\ ]*)',
              [DynamicToken('CMD.CmmdName'), BLANK],
              ['exec_end', 'commondnames']),
          JParse.empty(['exec_end'])
        ],
        'path': [
          JParse(r'\/(\w+\/?)+', DynamicToken('AbsPath'), [POP]),
          JParse(r'\w+(\/(\w+\/?)*)?', DynamicToken('RltvPath'), [POP]),
          JParse.empty(['not_a_legal_path_error'])
        ],
        'exec_orend': [
          // END PART
          JParse.bygroups(r'(\s*)(\n)', [BLANK, ExecSymbol], [POPROOT]),
          // OR PART
          JParse(r'\s+', BLANK, [POP]),
        ],
        'exec_end': [
          JParse.bygroups(r'(\s*)(\n)', [BLANK, ExecSymbol], [POPROOT]),
          JParse.empty(['error_exec_symbol_absent'])
        ],
        'props_end': [
          JParse(r'-(a|h)', DynamicToken('Props'), [POPROOT]),
        ],
        'commondnames': [
          JParse(r'(clear|ls|whoami|cd|vim|whereis|rm|which)',
              DynamicToken('NAME.Commands'), [POP]),
          JParse.empty(['error_not_a_command'])
        ]
      };

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      {
        'error_not_a_legal_path': [],
        'error_exec_symbol_absent': [],
        'error_not_a_command': []
      };

  @override
  RegExpFlags get flags => RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  String get root => 'root';
}

void main() {
  print(RemoteCommandLine().pretty('clear\n'
      'whoami        \n'
      'cd name/is/jack\n'
      'which vim\n'));

  ///CMD.Single(clear)ExecSymbol(\n)
  ///CMD.Single(whoami)        ExecSymbol(\n)
  ///CMD.Path(cd) RltvPath(name/is/jack)ExecSymbol(\n)
  ///CMD.CmmdName(which) NAME.Commands(vim)ExecSymbol(\n)
  ///
}
