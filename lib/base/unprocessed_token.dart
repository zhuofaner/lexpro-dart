// @dart=2.9
import 'package:equatable/equatable.dart';
import 'package:lexpro/base/token.dart';

class UnprocessedToken extends Equatable {
  const UnprocessedToken(
    this.pos,
    this.token,
    this.match, [
    this.stateName,
    this.debuggable,
  ]);
  final int pos;

  ///
  /// Token or DynamicToken
  final Object token;
  // final DynamicToken dtoken;
  final String match;
  final String stateName;
  final bool debuggable;

  String get tokenName {
    return isDynamic
        ? (token as DynamicToken).name
        : token.toString().substring(6);
  }

  bool get isDynamic {
    return token is DynamicToken;
  }

  String toString() {
    if (debuggable == true) {
      return 'UnprocessedToken($pos, $tokenName, \'${_stringifyMatch(match)}\', \'$stateName\')';
    } else {
      return 'UnprocessedToken($pos, $tokenName, \'${_stringifyMatch(match)}\')';
    }
  }

  String get prettyMatch {
    if (match.contains('\n')) {
      return match.replaceAll('\n', r"\n");
    }
    return match;
  }

  String pretty() {
    return '$tokenName(\'${_stringifyMatch(match)}\')';
  }

  String _stringifyMatch(String match) {
    if (match == '\n') return '\\n';
    if (match == "'") return "\\'";
    return match;
  }

  @override
  List<Object> get props => [pos, token, match];
}
