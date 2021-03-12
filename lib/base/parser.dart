// @dart=2.9
import 'package:lexpro/base/token.dart';
export 'package:lexpro/base/token.dart';
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/utils/tools.dart';
// static DynamicToken Dynamic(Token enumToken){
//   return DynamicToken(enumToken.toString().substring(6));
// }

// Token Enum(DynamicToken dynamicToken){

// }
const POP = '#pop';
const POP2 = '#pop:2';
const PUSH = '#push';

/// pop the current lexer root not always 'root';
const POPROOT = '#poproot';

/// for breaking lexer parse
const BREAK = '#break';

/// clear the statestack to empty
const CLEAR = '#clear';

/// for system use, user don't use
const INSIDE_MARK_ADDED = '#inside-mark-added';

class Parse {
  const Parse(
    this.pattern,
    this.token, [
    this.newStates = null,
  ]);
  factory Parse.include(String s) => Parse(s, Token.IncludeOtherParse);
  factory Parse.bygroups(
    String pattern,
    List<Token> tokens, [
    List<String> nextState,
  ]) =>
      GroupParse(pattern, tokens, nextState);

  factory Parse.empty(List<String> nextState) =>
      Parse('', Token.Text, nextState);
  factory Parse.lexer(Lexer lexer) => LexerParse(lexer);

  final String pattern;
  final Token token;
  final List<String> newStates;

  Parse get parent => null;
  List<Token> get groupTokens => null;

  String toString() {
    return '''Parse {
      pattern: $pattern
      token: $token
      newStates: $newStates
    }''';
  }

  copy({List<String> newStates}) =>
      Parse(pattern, token, newStates ?? this.newStates);

  List<String> split() {
    List<String> buf = [];
    Parse node = this;
    while (node != null) {
      buf.add(node.toString());
      node = node.parent;
    }
    return buf.reversed;
  }
}

class JParse extends Parse {
  JParse(String pattern, this.dtoken, [newStates = null, this.constants = null])
      : super(pattern, dtoken.token, newStates);

  final DynamicToken dtoken;
  List<List<String>> constants;
  bool get isConst => constants != null;
  Token get token => dtoken.token;
  factory JParse.eventOnStateWillStart() =>
      EventEmmitor(null, DynamicToken.from(Token.EventOnStateWillStart));
  factory JParse.eventOnStateWillRestart() =>
      EventEmmitor(null, DynamicToken.from(Token.EventOnStateWillRestart));
  factory JParse.eventOnStateWillEnd() =>
      EventEmmitor(null, DynamicToken.from(Token.EventOnStateWillEnd));
  factory JParse.eventOnRuleWillStart(String ruleStartFlag) => EventEmmitor(
      ruleStartFlag, DynamicToken.from(Token.EventOnRuleWillStart));
  factory JParse.eventOnRuleMissed(String ruleMissedFlag) =>
      EventEmmitor(ruleMissedFlag, DynamicToken.from(Token.EventOnRuleMissed));
  factory JParse.eventOnCondition(
          String conditionFlag, List<String> returnTrueCallBack) =>
      EventEmmitor(conditionFlag, DynamicToken.from(Token.EventOnCondition),
          returnTrueCallBack);
  factory JParse.eventOnConditionInclude(
          String conditionFlag, Iterable<JParse> skippingRules) =>
      JParsePackage(conditionFlag,
          DynamicToken.from(Token.EventOnConditionInclude), skippingRules);
  @override
  copy({List<String> newStates}) =>
      JParse(pattern, dtoken, newStates ?? this.newStates);

  /// replaceAllNewStates: 批量替换所有newStates 包括 Include
  factory JParse.include(String s,
          {List<String> replaceAllNewStates, List<String> addedNewStates}) =>
      JParse(
          s,
          DynamicToken.from(Token.IncludeOtherParse),
          replaceAllNewStates ??
              (addedNewStates != null
                  ? [INSIDE_MARK_ADDED, ...addedNewStates]
                  : null));

  factory JParse.constants(
    List<List<String>> constants,
    DynamicToken dtoken, [
    newStates = null,
  ]) =>
      JParse(const2Pattern(constants), dtoken, newStates, constants);

  factory JParse.constingroups(String pattern, List<List<String>> constants,
          List<DynamicToken> tokens, [List<String> nextState]) =>
      GroupJParse(pattern.replaceFirst('(..)', const2Pattern(constants)),
          tokens, nextState, constants);

  factory JParse.bygroups(
    String pattern,
    List<DynamicToken> tokens, [
    List<String> nextState,
  ]) =>
      GroupJParse(pattern, tokens, nextState);

  factory JParse.empty(List<String> nextState) =>
      JParse('', DynamicToken.from(Token.Text), nextState);
  factory JParse.lexer(Lexer lexer, {List<String> doActionsWithoutState}) =>
      LexerJParse(lexer, doActionsWithoutState);
}

// Yields multiple actions for each group in the match.
class GroupParse extends Parse {
  GroupParse(
    String pattern,
    this.groupTokens, [
    List<String> newStates = null,
  ]) : super(pattern, Token.ParseByGroups, newStates);

  final List<Token> groupTokens;
  @override
  copy({List<String> newStates}) =>
      GroupParse(pattern, groupTokens, newStates ?? this.newStates);
}

class GroupJParse extends JParse {
  GroupJParse(String pattern, this.groupDTokens,
      [List<String> newStates = null, List<List<String>> constants = null])
      : super(pattern, DynamicToken.from(Token.ParseByGroups), newStates,
            constants);

  final List<DynamicToken> groupDTokens;
  @override
  copy({List<String> newStates}) =>
      GroupJParse(pattern, groupDTokens, newStates ?? this.newStates);
}

class LexerParse extends Parse {
  final RegexLexer lexer;
  const LexerParse(
    this.lexer, [
    List<String> newStates = null,
  ]) : super(null, Token.IncludeOtherLexer, newStates);
  @override
  copy({List<String> newStates}) =>
      LexerParse(lexer, newStates ?? this.newStates);
}

class LexerJParse extends JParse {
  final RegexLexer lexer;
  LexerJParse(
    this.lexer, [
    List<String> newStates = null,
  ]) : super(null, DynamicToken.from(Token.IncludeOtherLexer), newStates);
  @override
  copy({List<String> newStates}) =>
      LexerJParse(lexer, newStates ?? this.newStates);
}

class EventEmmitor extends JParse {
  EventEmmitor(String eventFlag, DynamicToken eventToken,
      [List<String> newStates = null])
      : super(eventFlag, eventToken ?? DynamicToken.from(Token.EventUnknown),
            newStates);
  @override
  copy({List<String> newStates}) =>
      EventEmmitor(pattern, dtoken, newStates ?? this.newStates);
}

class JParsePackage extends EventEmmitor {
  List<JParse> package;
  JParsePackage(String eventFlag, DynamicToken eventToken, this.package)
      : super(eventFlag, eventToken);
  @override
  copy({List<String> newStates}) => JParsePackage(pattern, dtoken, package);
}
