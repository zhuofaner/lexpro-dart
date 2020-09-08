// ignore_for_file: non_constant_identifier_names
import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/unistring.dart';

final JS_IDENT_START = (r'(?:[$_' +
    uni.combine(['Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl']) +
    ']|\\\\u[a-fA-F0-9]{4})');
final JS_IDENT_PART = (r'(?:[$' +
    uni.combine([
      'Lu',
      'Ll',
      'Lt',
      'Lm',
      'Lo',
      'Nl',
      'Mn',
      'Mc',
      'Nd',
      'Pc'
    ]) + /*u*/ '\u200c\u200d]|\\\\u[a-fA-F0-9]{4})');
final JS_IDENT = JS_IDENT_START + '(?:' + JS_IDENT_PART + ')*';

class JavaScriptLexer extends RegexLexer {
  final name = 'JavaScript';
  final aliases = ['js', 'javascript'];
  final filenames = ['*.js', '*.jsm'];
  final mimetypes = [
    'application/javascript',
    'application/x-javascript',
    'text/x-javascript',
    'text/javascript'
  ];

  final RegExpFlags flags = RegExpFlags(
    dotAll: true,
    unicode: true,
    multiline: true,
  );

  final Map<String, List<Parse>> parses = {
    'commentsandwhitespace': [
      Parse(r'\s+', Token.Text),
      Parse(r'<!--', Token.Comment),
      Parse(r'//.*?\n', Token.CommentSingle),
      Parse(r'/\*.*?\*/', Token.CommentMultiline),
    ],
    'slashstartsregex': [
      Parse.include('commentsandwhitespace'),
      /* TODO: disabled Lone quantifier brackets
      https://stackoverflow.com/questions/40939209/invalid-regular-expressionlone-quantifier-brackets
      Parse(
          r'/(\\.|[^[/\\\n]|\[(\\.|[^\]\\\n])*])+/'
          r'([gimuy]+\b|\B)',
          Token.StringRegex,
          [POP]),
       */
      Parse(r'(?=/)', Token.Text, [POP, 'badregex']),
      Parse.empty([POP])
    ],
    'badregex': [
      Parse(r'\n', Token.Text, [POP]),
    ],
    'root': [
      Parse(r'^#! ?/.*?\n', Token.CommentHashbang), // recognized by node.js
      Parse(r'^(?=\s|/|<!--)', Token.Text, ['slashstartsregex']),
      Parse.include('commentsandwhitespace'),
      Parse(r'(\.\d+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)?', Token.NumberFloat),
      Parse(r'0[bB][01]+', Token.NumberBin),
      Parse(r'0[oO][0-7]+', Token.NumberOct),
      Parse(r'0[xX][0-9a-fA-F]+', Token.NumberHex),
      Parse(r'[0-9]+', Token.NumberInteger),
      Parse(r'\.\.\.|=>', Token.Punctuation),
      Parse(
          r'\+\+|--|~|&&|\?|:|\|\||\\(?=\n)|'
          r'(<<|>>>?|==?|!=?|[-<>+*%&|^/])=?',
          Token.Operator,
          ['slashstartsregex']),
      Parse(r'[{(\[;,]', Token.Punctuation, ['slashstartsregex']),
      Parse(r'[})\].]', Token.Punctuation),
      Parse(
          r'(for|in|while|do|break|return|continue|switch|case|default|if|else|'
          r'throw|try|catch|finally|new|delete|typeof|instanceof|void|yield|'
          r'this|of)\b',
          Token.Keyword,
          ['slashstartsregex']),
      Parse(r'(var|let|with|function)\b', Token.KeywordDeclaration,
          ['slashstartsregex']),
      Parse(
          r'(abstract|boolean|byte|char|class|const|debugger|double|enum|export|'
          r'extends|final|float|goto|implements|import|int|interface|long|native|'
          r'package|private|protected|public|short|static|super|synchronized|throws|'
          r'transient|volatile)\b',
          Token.KeywordReserved),
      Parse(
          r'(true|false|null|NaN|Infinity|undefined)\b', Token.KeywordConstant),
      Parse(
          r'(Array|Boolean|Date|Error|Function|Math|netscape|'
          r'Number|Object|Packages|RegExp|String|Promise|Proxy|sun|decodeURI|'
          r'decodeURIComponent|encodeURI|encodeURIComponent|'
          r'Error|eval|isFinite|isNaN|isSafeInteger|parseFloat|parseInt|'
          r'document|this|window)\b',
          Token.NameBuiltin),
      // TODO: should be the below if we want to support unicode
      // Parse(JS_IDENT, Token.NameOther),
      Parse(r'[a-zA-Z\d_$]+', Token.NameOther),
      Parse(r'"(\\\\|\\"|[^"])*"', Token.StringDouble),
      Parse(r"'(\\\\|\\'|[^'])*'", Token.StringSingle),
      Parse(r'`', Token.StringBacktick, ['interp']),
    ],
    'interp': [
      Parse(r'`', Token.StringBacktick, [POP]),
      Parse(r'\\\\', Token.StringBacktick),
      Parse(r'\\`', Token.StringBacktick),
      Parse(r'\$\{', Token.StringInterpol, ['interp-inside']),
      Parse(r'\$', Token.StringBacktick),
      Parse(r'[^`\\$]+', Token.StringBacktick),
    ],
    'interp-inside': [
      Parse(r'\}', Token.StringInterpol, [POP]),
      Parse.include('root'),
    ],
    // # (\\\\|\\`|[^`])*`', String.Backtick),
  };

  @override
  String get root => 'root';

  @override
  Map<String, List<Parse>> commonparses(
          Map<String, List<Parse>> currentCommon) =>
      null;
}
