// @dart=2.9
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
  Dynamic,
  // for event system
  EventUnknown,
  EventOnStateWillStart,
  EventOnStateWillRestart,
  EventOnStateWillEnd,
  EventOnRuleWillStart,
  EventOnRuleMissed,
  EventOnRuleMatchedEnterLeave,
  EventOnCondition,
  EventOnConditionInclude
}

/// Templates must be Enum(isEnum == true)
class TemplateVars {
  final List<Pattern> patterns;
  final List<DynamicToken> enumvars;
  final List<String> enumnone;
  const TemplateVars({this.patterns, this.enumvars, this.enumnone});
}

class Templates extends DynamicToken {
  final List<String> templates;
  final TemplateVars vars;
  Templates(this.templates, DynamicToken token, {this.vars})
      : super(token?.name, token?.enums ?? const []);
}

/// easy for users to define their own Tokens
class DynamicToken {
  final String name;
  // Given constant right examples belongs to this token.
  // These values are list for literal-error-correcting.
  final List<String> enums;
  bool get isEnum => enums != null;
  bool enumsEqual(Object token) {
    if (token is! DynamicToken) return false;
    DynamicToken other = token as DynamicToken;
    // 名称相同
    if (other.isEnum && isEnum && name == other.name) {
      // 枚举值相同
      if (enums.isNotEmpty && other.enums.isNotEmpty) {
        return (enums..sort()).toString() == (other.enums..sort()).toString();
      } else if (enums.isEmpty && other.enums.isEmpty) return true;
    }
    // 否则不同
    return false;
  }

  const DynamicToken(this.name, [this.enums = null]);
  factory DynamicToken.fromEnum(List<String> options, {Object named}) =>
      DynamicToken(enumTokenName(named), options);
  factory DynamicToken.asEnum([Object name]) =>
      DynamicToken.fromEnum([], named: name);
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
    // if (isEnum && enums.isNotEmpty) {
    //   return 'Token.$name(${(enums..sort()).join('|')})';
    // }
    return 'Token.$name';
  }
}
