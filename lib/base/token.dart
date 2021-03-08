// @dart=2.9
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/utils/tools.dart';

enum Token {
  Text,
  Whitespace,
  Escape,
  Error,
  Other,

  Keyword,
  KeywordConstant,
  KeywordDeclaration,
  KeywordNamespace,
  KeywordPseudo,
  KeywordReserved,
  KeywordType,

  Name,
  NameAttribute,

  NameBuiltin,
  NameBuiltinPseudo,

  NameClass,
  NameConstant,
  NameDecorator,
  NameEntity,
  NameException,

  NameFunction,
  NameFunctionMagic,

  NameProperty,
  NameLabel,
  NameNamespace,
  NameOther,
  NameTag,

  NameVariable,
  NameVariableClass,
  NameVariableGlobal,
  NameVariableInstance,
  NameVariableMagic,

  Literal,
  LiteralDate,

  String,
  StringAffix,
  StringBacktick,
  StringChar,
  StringDelimiter,
  StringDoc,
  StringDouble,
  StringEscape,
  StringHeredoc,
  StringInterpol,
  StringOther,
  StringRegex,
  StringSingle,
  StringSymbol,

  Number,
  NumberBin,
  NumberFloat,
  NumberHex,

  NumberInteger,
  NumberIntegerLong,

  NumberOct,

  Operator,
  OperatorWord,

  Punctuation,

  Comment,
  CommentHashbang,
  CommentMultiline,
  CommentPreproc,
  CommentPreprocFile,
  CommentSingle,
  CommentSpecial,

  Generic,
  GenericDeleted,
  GenericEmph,
  GenericError,
  GenericHeading,
  GenericInserted,
  GenericOutput,
  GenericPrompt,
  GenericStrong,
  GenericSubheading,
  GenericTraceback,

  //add for enum
  Enum,
  // Special
  IncludeOtherParse,
  ParseByGroups,
  RecurseSameLexer,
  // added in lexpro
  IncludeOtherLexer,
  // for DynamicToken transfer
  Dynamic
}

/// easy for users to define their own Tokens
class DynamicToken {
  final String name;
  // Given constant right examples belongs to this token.
  // These values are list for literal-error-correcting.
  final List<String> enums;
  bool get isEnum => enums != null;
  const DynamicToken(this.name, [this.enums = null]);
  factory DynamicToken.fromEnum(List<String> options, {String enumName}) =>
      DynamicToken(enumName ?? Token.Enum.toString().substring(6), options);
  factory DynamicToken.asEnum([String name]) =>
      DynamicToken(name ?? Token.Enum.toString().substring(6), []);
  factory DynamicToken.from(Token enumToken) =>
      DynamicToken(enumToken.toString().substring(6));
  Token get token {
    for (var tk in Token.values) {
      if (tk.toString() == toString()) return tk;
    }
    return Token.Dynamic;
  }

  @override
  bool operator ==(Object other) => other.toString() == toString();

  @override
  String toString() {
    if (isEnum && enums.isNotEmpty) {
      return 'Token.$name(${(enums..sort()).join('|')})';
    }
    return 'Token.$name';
  }
}

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

  factory JParse.include(String s) =>
      JParse(s, DynamicToken.from(Token.IncludeOtherParse));

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
  factory JParse.lexer(Lexer lexer, [List<String> nextState]) =>
      LexerJParse(lexer, nextState);
}

// Yields multiple actions for each group in the match.
class GroupParse extends Parse {
  GroupParse(
    String pattern,
    this.groupTokens, [
    List<String> newStates = null,
  ]) : super(pattern, Token.ParseByGroups, newStates);

  final List<Token> groupTokens;
}

class GroupJParse extends JParse {
  GroupJParse(String pattern, this.groupDTokens,
      [List<String> newStates = null, List<List<String>> constants = null])
      : super(pattern, DynamicToken.from(Token.ParseByGroups), newStates,
            constants);

  final List<DynamicToken> groupDTokens;
}

class LexerParse extends Parse {
  final RegexLexer lexer;
  const LexerParse(
    this.lexer, [
    List<String> newStates = null,
  ]) : super(null, Token.IncludeOtherLexer, newStates);
}

class LexerJParse extends JParse {
  final RegexLexer lexer;
  LexerJParse(
    this.lexer, [
    List<String> newStates = null,
  ]) : super(null, DynamicToken.from(Token.IncludeOtherLexer), newStates);
}
