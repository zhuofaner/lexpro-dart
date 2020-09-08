import 'package:equatable/equatable.dart';
import 'package:lexpro/base/token.dart';

class UnprocessedToken extends Equatable {
  UnprocessedToken(this.pos, this.token, this.match,
      [this.stateName, this.debuggable])
      : super([pos, token, match]);
  final int pos;
  final Token token;
  final String match;
  final String stateName;
  final bool debuggable;

  String toString() {
    if (debuggable == true) {
      return 'UnprocessedToken($pos, $token, \'${_stringifyMatch(match)}\', \'$stateName\')';
    } else
      return 'UnprocessedToken($pos, $token, \'${_stringifyMatch(match)}\')';
  }

  String pretty() {
    return '$token(\'${_stringifyMatch(match)}\')';
  }

  String _stringifyMatch(String match) {
    if (match == '\n') return '\\n';
    if (match == "'") return "\\'";
    return match;
  }
}
