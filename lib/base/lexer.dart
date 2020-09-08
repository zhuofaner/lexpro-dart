import 'dart:developer';

import 'package:lexpro/base/token.dart';
import 'package:lexpro/base/types.dart';
import 'package:lexpro/base/unprocessed_token.dart';
import 'package:lexpro/utils/poprouter.dart';

export 'package:lexpro/base/token.dart';
export 'package:lexpro/base/types.dart';
export 'package:lexpro/base/unprocessed_token.dart';
export 'package:lexpro/utils/poprouter.dart';

abstract class Lexer {
  Lexer({
    this.stripnl = true,
    this.stripall = false,
    this.ensurenl = true,
    this.tabsize = 0,
    this.encoding = 'guess',
    this.debuggable = false,
  });
  final bool stripnl;
  final bool stripall;
  final bool ensurenl;
  final int tabsize;
  final String encoding;
  final bool debuggable;

  // TODO: left out filter related things
  // final List<String> filters;
  String get root;
  String get name => null;
  List<String> get aliases => [];
  List<String> get filenames => [];
  List<String> get aliasFilenames => [];
  List<String> get mimetypes => [];
  int get priority => 0;

  // Has to return a float between ``0`` and ``1`` that indicates if a lexer wants to highlight this text. Used by ``guess_lexer``.
  // If this method returns ``0`` it won't highlight it in any case, if
  // it returns ``1`` highlighting with this lexer is guaranteed.
  //
  // The `LexerMeta` metaclass automatically wraps this function so
  // that it works like a static method (no ``self`` or ``cls``
  // parameter) and the return value is automatically converted to
  // `float`. If the return value is an object that is boolean `False`
  // it's the same as if the return values was ``0.0``.
  double analyseText(String text) {
    throw new UnimplementedError(
        'Either inheritor or regex lexer needs to implement this');
  }

  // Return an iterable of (index, tokentype, value) pairs where "index"
  // is the starting position of the token within the input text.
  //
  // In subclasses, implement this method as a generator to
  // maximize effectiveness.

  Iterable<UnprocessedToken> getTokensUnprocessed(String text);

  // Return an iterable of (tokentype, value) pairs generated from
  // `text`. If `unfiltered` is set to `True`, the filtering mechanism
  // is bypassed even if filters are defined.
  //
  // Also preprocess the text, i.e. expand tabs and strip it if
  // wanted and applies registered filters.
  List<Parse> getTokens(String text, {bool unfiltered = false}) {
    // text now *is* a unicode string (TODO: conversion once needed)
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (stripall) text = text.trim();
    // TODO: how to trim \n in dart; else if (stripnl) text = text.trim('\n');

    if (tabsize > 0) text.replaceAll('\t', ''.padLeft(tabsize));
    if (ensurenl && !text.endsWith('\n')) text += '\n';

    return null;
  }

  String processedString(
      {Iterable<UnprocessedToken> unprocessedTokens, String text}) {
    if (unprocessedTokens == null) {
      unprocessedTokens = getTokensUnprocessed(text);
    }
    var out = "";
    Token currentToken;
    for (UnprocessedToken token in unprocessedTokens) {
      if (token.token == Token.Text) {
        if (currentToken != null) {
          out += ')';
          currentToken = null;
        }
        out += token.match;
      } else {
        if (token.token != currentToken) {
          if (currentToken != null) {
            out += ')';
          }
          out += token.token.toString().replaceAll("Token.", "") + '(';
          currentToken = token.token;
        }
        out += token.match;
      }
    }
    return out;
  }
}

class Position {
  int from;
  Position(this.from);
}

typedef RegExpMatch RexMatch(String text, int pos);

// http://pygments.org/docs/lexerdevelopment
//
// The lexer base class used by almost all of Pygments’ lexers is the
// RegexLexer.
// This class allows you to define lexing rules in terms of regular
// expressions for different states.
//
// States are groups of regular expressions that are matched against the
// input string at the current position.
// If one of these expressions matches, a corresponding action is performed
// (such as yielding a token with a specific type, or changing state),
// the current position is set to where the last match ended and
// the matching process continues with the first regex of the current state.
//
// Lexer states are kept on a stack: each time a new state is entered,
// the new state is pushed onto the stack.
// The most basic lexers (like the DiffLexer) just need one state.
//
// Each state is defined as a list of tuples in the form
// (regex, action, new_state) where the last item is optional.
// In the most basic form, action is a token type (like Name.Builtin).
// That means: When regex matches, emit a token with the match text and type
// tokentype and push new_state on the state stack.

// If the new state is '#pop', the topmost state is popped from the stack
// instead. To pop more than one state, use '#pop:2' and so on.
// '#push' is a synonym for pushing the current state on the stack.
abstract class RegexLexer extends Lexer {
  RegexLexer({
    stripnl = true,
    stripall = false,
    ensurenl = true,
    tabsize = 0,
    encoding = 'guess',
    debuggable = false,
  }) : super(
            stripnl: stripnl,
            stripall: stripall,
            ensurenl: ensurenl,
            tabsize: tabsize,
            encoding: encoding,
            debuggable: debuggable);
  RegExpFlags get flags;
  Map<String, List<Parse>> get parses;
  Map<String, List<Parse>> commonparses(Map<String, List<Parse>> currentCommon);
  String pretty(String text,
      [List<String> stack, Position pos, Map<String, List<Parse>> commondefs]) {
    return processedString(
        unprocessedTokens: getTokensUnprocessed(text, stack, pos, commondefs));
  }

  // Split ``text`` into (token type, text) pairs.
  //
  // ``stack`` is the initial stack (default: ``[root]``)
  //
  // The get_tokens_unprocessed() method must return an iterator or iterable
  // containing tuples in the form (index, token, value).
  // Stream<Tuple2<index, token, value>>
  Iterable<UnprocessedToken> getTokensUnprocessed(String text,
      [List<String> stack, Position pos, Map<String, List<Parse>> commondefs]) {
    var ret = <UnprocessedToken>[];
    pos = pos ?? Position(0);

    /// merge common
    commondefs = _merge(commondefs, commonparses(commondefs));
    Map<String, Iterable<Parse>> parsedefs =

        /// merge all
        _expand(_merge(commondefs, parses));
    final List<String> statestack = stack ?? List.from([root]);
    List<Parse> statetokens = parsedefs[statestack.last];
    while (true && pos.from < text.length) {
      bool matched = false;
      for (final parse in statetokens) {
        final pattern = parse.pattern;
        final token = parse.token;
        final newStates = parse.newStates;
        if (token == Token.IncludeOtherLexer) {
          RegexLexer lexer = (parse as LexerParse).lexer;
          statestack.add(lexer.root);
          var pos_before = pos.from;
          Iterable<UnprocessedToken> res =
              lexer.getTokensUnprocessed(text, statestack, pos, commondefs);
          ret.addAll(res);
          if (pos.from > pos_before) {
            matched = true;
            break;
          } else {
            continue;
          }
        }

        final regex = RegExp(
          pattern,
          dotAll: flags.dotAll,
          unicode: flags.unicode,
          multiLine: flags.multiline,
          caseSensitive: flags.caseSensitive,
        );

        final m = regex.matchAsPrefix(text, pos.from);

        if (m != null) {
          if (token != null && m.group(0).isNotEmpty) {
            if (token == Token.ParseByGroups) {
              ret.addAll(this._bygroup(m, parse.groupTokens,
                  statestack.isEmpty ? root : statestack.last));
            } else {
              ret.add(UnprocessedToken(pos.from, token, m.group(0),
                  statestack.isEmpty ? root : statestack.last, debuggable));
            }
          }
          pos.from = m.end;
          if (newStates != null) {
            for (final state in newStates) {
              if (_doStackActionsNeedBreak(statestack, state) == true) {
                return ret;
              }
            }
            statetokens = statestack.isEmpty
                ? parsedefs[root]
                : parsedefs[statestack.last];
            // if (statetokens == null) debugger();
          }
          matched = true;
          break;
        }
      }

      if (!matched) {
        // We are here only if all state tokens have been considered
        // and there was not a match on any of them.
        try {
          if (text[pos.from] == '\n') {
            _popTo(statestack, root);
            statetokens = parsedefs[root];
            ret.add(UnprocessedToken(pos.from, Token.Text, '\n',
                statestack.isEmpty ? root : statestack.last, debuggable));
            pos.from++;
            continue;
          }
          // print(
          //     'Error starts from "${text.substring(pos.from)}" in statestack: $statestack \n');
          ret.add(UnprocessedToken(pos.from, Token.Error, text[pos.from],
              statestack.isEmpty ? root : statestack.last, debuggable));
          pos.from++;
        } on Exception catch (err) {
          print(err);
          break;
        }
      }
    }
    return ret;
  }

  Iterable<UnprocessedToken> _getTokensUnprocessed(String text,
      [List<String> stack,
      Position pos,
      Map<String, List<Parse>> commondefs]) sync* {
    pos = pos ?? Position(0);
    // print(
    //     'getTokensUnprocessed\npos:${pos.from}\nstack:${stack}\ncommondefs:${commondefs}');

    /// merge common
    commondefs = _merge(commondefs, commonparses(commondefs));
    Map<String, Iterable<Parse>> parsedefs =

        /// merge all
        _expand(_merge(commondefs, parses));
    final List<String> statestack = stack ?? List.from([root]);
    List<Parse> statetokens = parsedefs[statestack.last];
    while (true && pos.from < text.length) {
      bool matched = false;
      for (final parse in statetokens) {
        final pattern = parse.pattern;
        final token = parse.token;
        final newStates = parse.newStates;
        if (token == Token.IncludeOtherLexer) {
          RegexLexer lexer = (parse as LexerParse).lexer;
          statestack.add(lexer.root);
          var pos_before = pos.from;
          yield* lexer._getTokensUnprocessed(text, statestack, pos, commondefs);
          if (pos.from > pos_before) {
            matched = true;
            break;
          } else {
            continue;
          }
        }

        final regex = RegExp(
          pattern,
          dotAll: flags.dotAll,
          unicode: flags.unicode,
          multiLine: flags.multiline,
          caseSensitive: flags.caseSensitive,
        );

        final m = regex.matchAsPrefix(text, pos.from);

        if (m != null) {
          if (token != null && m.group(0).isNotEmpty) {
            if (token == Token.ParseByGroups) {
              yield* this._bygroup(m, parse.groupTokens,
                  statestack.isEmpty ? root : statestack.last);
            } else {
              yield UnprocessedToken(pos.from, token, m.group(0),
                  statestack.isEmpty ? root : statestack.last, debuggable);
            }
          }
          pos.from = m.end;
          if (newStates != null) {
            for (final state in newStates) {
              _doStackActionsNeedBreak(statestack, state);
            }
            statetokens = statestack.isEmpty
                ? parsedefs[root]
                : parsedefs[statestack.last];
          }
          matched = true;
          break;
        }
      }

      if (!matched) {
        // We are here only if all state tokens have been considered
        // and there was not a match on any of them.
        try {
          if (text[pos.from] == '\n') {
            _popTo(statestack, root);
            statetokens = parsedefs[root];
            yield UnprocessedToken(pos.from, Token.Text, '\n',
                statestack.isEmpty ? root : statestack.last, debuggable);
            pos.from++;
            continue;
          }
          // print(
          //     'Error starts from "${text.substring(pos.from)}" in statestack: $statestack \n');
          yield UnprocessedToken(pos.from, Token.Error, text[pos.from],
              statestack.isEmpty ? root : statestack.last, debuggable);
          pos.from++;
        } on Exception catch (err) {
          print(err);
          break;
        }
      }
    }
  }

  bool _doStackActionsNeedBreak(List<String> statestack, String stateOrAction) {
    if (stateOrAction == CLEAR)
      statestack.clear();
    else if (stateOrAction == BREAK) {
      // debugger();
      return true;
    } else if (stateOrAction == POP)
      this._pop(statestack, 1);
    else if (stateOrAction == POP2)
      this._pop(statestack, 2);
    else if (stateOrAction == POPROOT)
      this._popTo(statestack, root);
    else if (stateOrAction == PUSH)
      statestack.add(statestack.last);

    /// add more dynamic way to control state stack.
    else if (stateOrAction.startsWith("#pop:")) {
      final popingState = stateOrAction.replaceFirst("#pop:", "");
      if (int.tryParse(popingState) != null) {
        this._pop(statestack, int.parse(popingState));
      } else
        this._popTo(statestack, popingState);

      /// end add by jackyanjiaqi.
    } else if (stateOrAction.startsWith("#on:")) {
      List<List<dynamic>> rules = [
        [
          r'#on:(.*)#pop:(.*)#do:\{(.*)\}#else:\{(.*)\}',
          [1, 2, 3, 4]
        ],
        [
          r'#on:(.*)#pop:(.*)#do:\{(.*)\}',
          [1, 2, 3, null]
        ],
        [
          r'#on:(.*)#pop:(.*)#else:\{(.*)\}',
          [1, 2, null, 3]
        ],
        [
          r'#on:(.*)#pop:(.*)',
          [1, 2, null, null]
        ],
        [
          r'#on:(.*)#do:\{(.*)\}#else:\{(.*)\}',
          [1, null, 2, 3]
        ],
        [
          r'#on:(.*)#do:\{(.*)\}',
          [1, null, 2, null]
        ],
        [
          r'#on:(.*)#else:\{(.*)\}',
          [1, null, null, 2]
        ],
      ];
      for (List singleRule in rules) {
        RegExpMatch rem = RegExp(singleRule[0]).matchAsPrefix(stateOrAction);
        if (rem != null) {
          groupValue(v) => v != null ? rem.group(v) : null;
          return this._onPopDoElse(
              statestack,
              groupValue(singleRule[1][0]),
              groupValue(singleRule[1][1]),
              groupValue(singleRule[1][2]),
              groupValue(singleRule[1][3]));
        }
      }
    } else {
      statestack.add(stateOrAction);
      if (debuggable == true) print(statestack);
    }
    return false;

    /// end add by jackyanjiaqi.
  }

  // Callback that yields multiple actions for each group in the match.
  Iterable<UnprocessedToken> _bygroup(Match m, Iterable<Token> tokens,
      [String stateName]) sync* {
    int groupIdx = 1;
    int pos = m.start;
    for (final token in tokens) {
      final s = m.group(groupIdx);
      if (token == Token.RecurseSameLexer) {
        yield* this.getTokensUnprocessed(s);
      } else {
        yield UnprocessedToken(pos, token, s, stateName, debuggable);
      }

      pos += s.length;
      groupIdx++;
    }
  }

  void _pop(List<String> statestack, int times) {
    while (statestack.isNotEmpty && times > 0) {
      statestack.removeLast();
      times--;
    }
    if (debuggable == true) print(statestack);
  }

  void _popTo(List<String> statestack, String target) {
    while (statestack.isNotEmpty && statestack.last != target) {
      statestack.removeLast();
    }
  }

  bool _onPopDoElse(List<String> statestack, String onstate, String popto,
      String doAction, String elseAction) {
    if (statestack.contains(onstate)) {
      if (popto != null) _popTo(statestack, popto);
      if (doAction != null)
        return _doStackActionsNeedBreak(statestack, doAction);
    } else if (elseAction != null) {
      return _doStackActionsNeedBreak(statestack, elseAction);
    }
  }

  Map<String, List<Parse>> _merge(
      Map<String, List<Parse>> merge1, Map<String, List<Parse>> merge2) {
    final merged = Map<String, List<Parse>>();
    if (merge1 != null && merge1.isNotEmpty) {
      for (final entry in merge1.entries) {
        merged[entry.key] = entry.value;
      }
    }
    if (merge2 != null && merge2.isNotEmpty) {
      for (final entry in merge2.entries) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  Map<String, List<Parse>> _expand(Map<String, List<Parse>> parsesMap) {
    final expanded = Map<String, List<Parse>>();
    Iterable<Parse> expandList(List<Parse> parses) sync* {
      for (final p in parses) {
        if (p.token == Token.IncludeOtherParse) {
          yield* expandList(parsesMap[p.pattern]);
        } else {
          yield p;
        }
      }
    }

    for (final entry in parsesMap.entries) {
      expanded[entry.key] = expandList(entry.value).toList();
    }
    return expanded;
  }
}
