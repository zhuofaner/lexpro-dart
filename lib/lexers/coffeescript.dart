import 'package:lexpro/base/lexer.dart';

// For `CoffeeScript`_ source code. http://coffeescript.org
class CoffeeScriptLexer extends RegexLexer {
  final name = 'CoffeeScript';
  final aliases = ['coffee-script', 'coffeescript', 'coffee'];
  final filenames = ['*.coffee'];
  final mimetypes = ['text/coffeescript'];

  final _operator_re =
      (r'\+\+|~|&&|\band\b|\bor\b|\bis\b|\bisnt\b|\bnot\b|\?|:|'
          r'\|\||\\(?=\n)|'
          r'(<<|>>>?|==?(?!>)|!=?|=(?!>)|-(?!>)|[<>+*`%&\|\^/])=?');

  final RegExpFlags flags = RegExpFlags(
    dotAll: true,
  );
  Map<String, List<Parse>> get parses => {
        'commentsandwhitespace': [
          Parse(r'\s+', Token.Text),
          Parse(r'###[^#].*?###', Token.CommentMultiline),
          Parse(r'#(?!##[^#]).*?\n', Token.CommentSingle),
        ],
        'multilineregex': [
          Parse(r'[^/#]+', Token.StringRegex),
          Parse(r'///([gim]+\b|\B)', Token.StringRegex, [POP]),
          Parse(r'#\{', Token.StringInterpol, ['interpoling_string']),
          Parse(r'[/#]', Token.StringRegex),
        ],
        'slashstartsregex': [
          Parse.include('commentsandwhitespace'),
          Parse(r'///', Token.StringRegex, ([POP, 'multilineregex'])),
          Parse(
              r'/(?! )(\\.|[^[/\\\n]|\[(\\.|[^\]\\\n])*])+/'
              r'([gim]+\b|\B)',
              Token.StringRegex,
              [POP]),
          // This isn't really guarding against mis-highlighting well-formed
          // code, just the ability to infinite-loop between root and
          // slashstartsregex.
          Parse(r'/', Token.Operator),
          Parse.empty([POP]),
        ],
        'root': [
          Parse.include('commentsandwhitespace'),
          Parse(r'^(?=\s|/)', Token.Text, ['slashstartsregex']),
          Parse(_operator_re, Token.Operator, ['slashstartsregex']),
          Parse(r'(?:\([^()]*\))?\s*[=-]>', Token.NameFunction,
              ['slashstartsregex']),
          Parse(r'[{(\[;,]', Token.Punctuation, ['slashstartsregex']),
          Parse(r'[})\].]', Token.Punctuation),
          Parse(
              r'(?<![.$])(for|own|in|of|while|until|'
              r'loop|break|return|continue|'
              r'switch|when|then|if|unless|else|'
              r'throw|try|catch|finally|new|delete|typeof|instanceof|super|'
              r'extends|this|class|by)\b',
              Token.Keyword,
              ['slashstartsregex']),
          Parse(
              r'(?<![.$])(true|false|yes|no|on|off|null|'
              r'NaN|Infinity|undefined)\b',
              Token.KeywordConstant),
          Parse(
              r'(Array|Boolean|Date|Error|Function|Math|netscape|'
              r'Number|Object|Packages|RegExp|String|sun|decodeURI|'
              r'decodeURIComponent|encodeURI|encodeURIComponent|'
              r'eval|isFinite|isNaN|parseFloat|parseInt|document|window)\b',
              Token.NameBuiltin),
          Parse(r'[$a-zA-Z_][\w.:$]*\s*[:=]\s', Token.NameVariable,
              ['slashstartsregex']),
          Parse(r'@[$a-zA-Z_][\w.:$]*\s*[:=]\s', Token.NameVariableInstance,
              ['slashstartsregex']),
          Parse(r'@', Token.NameOther, ['slashstartsregex']),
          Parse(r'@?[$a-zA-Z_][\w$]*', Token.NameOther),
          Parse(r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?', Token.NumberFloat),
          Parse(r'0x[0-9a-fA-F]+', Token.NumberHex),
          Parse(r'[0-9]+', Token.NumberInteger),
          Parse('"""', Token.String, ['tdqs']),
          Parse("'''", Token.String, ['tsqs']),
          Parse('"', Token.String, ['dqs']),
          Parse("'", Token.String, ['sqs']),
        ],
        'strings': [
          Parse(r"[^#\\'" r'"]+', Token.String),
          // note that all coffee script strings are multi-line.
          // hash marks, quotes and backslashes must be parsed one at a time
        ],
        'interpoling_string': [
          Parse(r'\}', Token.StringInterpol, [POP]),
          Parse.include('root')
        ],
        'dqs': [
          Parse(r'"', Token.String, [POP]),
          Parse(r"\\.|'",
              Token.String), // double-quoted string don't need ' escapes
          Parse(r'#\{', Token.StringInterpol, ['interpoling_string']),
          Parse(r'#', Token.String),
          Parse.include('strings')
        ],
        'sqs': [
          Parse(r"'", Token.String, [POP]),
          Parse(r'#|\\.|"',
              Token.String), // single quoted strings don't need " escapses
          Parse.include('strings')
        ],
        'tdqs': [
          Parse(r'"""', Token.String, [POP]),
          Parse(r"\\.|'|" r'"',
              Token.String), // no need to escape quotes in triple-string
          Parse(r'#\{', Token.StringInterpol, ['interpoling_string']),
          Parse(r'#', Token.String),
          Parse.include('strings'),
        ],
        'tsqs': [
          Parse(r"'''", Token.String, [POP]),
          Parse(r"#|\\.|'|" r'"',
              Token.String), // no need to escape quotes in triple-strings
          Parse.include('strings')
        ],
      };

  @override
  String get root => 'root';

  @override
  Map<String, List<Parse>> commonparses(
          Map<String, List<Parse>> currentCommon) =>
      null;
}
