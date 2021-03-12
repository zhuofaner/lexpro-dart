// @dart=2.9
import 'dart:developer';

import 'package:lexpro/base/event.dart';
import 'package:lexpro/base/parser.dart';
import 'package:lexpro/base/types.dart';
import 'package:lexpro/base/unprocessed_token.dart';
import 'package:lexpro/utils/tools.dart';

export 'package:lexpro/base/parser.dart';
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
    String currentTokenName;
    bool newlineNeeded = false;
    for (UnprocessedToken token in unprocessedTokens) {
      if (token.token == Token.Text) {
        if (currentTokenName != null) {
          out += ')';
          currentTokenName = null;
        }
        out += token.match;
      } else {
        if (token.tokenName != currentTokenName) {
          if (currentTokenName != null) {
            out += ')';
            if (newlineNeeded == true) {
              out += '\n';
              newlineNeeded = false;
            }
          }
          out += token.tokenName + '(';
          currentTokenName = token.tokenName;
          if (token.match.contains('\n')) {
            newlineNeeded = true;
          }
        }
        out += token.prettyMatch;
      }
    }
    if (currentTokenName != null) {
      out += ')';
      if (newlineNeeded == true) {
        out += '\n';
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
const CONFIG_EVENT_DISPATCHER = 'eventDispatcher';
const CONFIG_USECACHE = 'useCache';
const CONFIG_SAVING_RUNTIME_CONTEXT = 'savingRuntimeContext';
const CONFIG_STATE_WILL_LIST_TOKENS = 'stateWillListTokens';
const CONFIG_DEBUGGABLE = 'debuggable';
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
abstract class RegexLexer<T extends Parse> extends Lexer {
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
  Map<String, List<T>> get parses;
  Map<String, dynamic> config;

  /// runtimeContext is the deepest context the parser can go.
  /// each parser has two part of parsing rules. Single parses and Common parses.
  /// if you nested lexer with another lexer use [JParse.lexer], the context go deeper.
  /// Each parser's single parses is isolated but common parses will merge.
  /// So the deeper goes the common parse becomes larger.That's what we want when searching
  /// a certain state.
  /// However the single part belongs to each parser. and the state name maybe conflict.
  /// but that doesn't matter, Because when a parser is running,it automaticlly ignored other parsers' own defination.
  /// When you start parsing from a LexerMain there's only one root Lexer and many LibrayLexers ,don't worry you'll lose any context.
  Map<String, List<T>> _runtimeContext;

  /// a cacheContext is only for those case expanding the same parse package.
  /// the context stays inside of this parser and this will not cause conflict.
  /// different parser has its own cacheContext, they should not be merged anytime for the risk of naming conflict.
  Map<String, List<T>> _cacheContext = {};
  bool get supportEventDispatching =>
      config?.containsKey(CONFIG_EVENT_DISPATCHER) ?? false;
  RawEventDispatcher get configEventDispatcher =>
      supportEventDispatching ? config[CONFIG_EVENT_DISPATCHER] : null;
  bool get useCache => config?.containsKey(CONFIG_USECACHE) ?? false
      ? (config[CONFIG_USECACHE] as bool)
      : true;
  bool get configSaveRuntimeContext =>
      config?.containsKey(CONFIG_SAVING_RUNTIME_CONTEXT) ?? false;
  List<Object> get configListTokenStateNames =>
      config?.containsKey(CONFIG_STATE_WILL_LIST_TOKENS) ?? false
          ? config[CONFIG_STATE_WILL_LIST_TOKENS] as List
          : null;
  bool get configDebuggable => config?.containsKey(CONFIG_DEBUGGABLE) ?? false
      ? config[CONFIG_DEBUGGABLE]
      : debuggable;

  /// You don't have to merge like this
  /// return { ...currentCommon, [your Def]: bla bla bla}
  /// just give your own lib common parse rules
  /// => { [your Def]: bla bla bla }
  /// currentCommon is for you to check what have been loaded if Needed.
  Map<String, List<T>> commonparses(Map<String, List<T>> currentCommon);

  List<String> _enumAllGiven(DynamicToken enumToken, String stateName) {
    assert(enumToken.isEnum == true);
    if (enumToken.enums.isNotEmpty)
      return enumToken.enums;
    else {
      return _tokensUnprocessed
          .where((element) =>
              enumToken.enumsEqual(element.token) &&
              element.stateName == stateName)
          .map<String>((e) => e.match)
          .toList();
    }
  }

  List<String> autoCompleting(String errorText, String stateName) {
    assert(_runtimeContext != null);
    List<RegExpMatch> matches = [];

    /// step1: find matches;
    _runtimeContext[stateName]?.whereType<JParse>()?.forEach((element) {
      if (element.isConst && element is! GroupJParse) {
        matches.addAll(enumAllMatches(errorText, element.constants));
      } else if (element is GroupJParse &&
          element.groupDTokens.any((dtoken) => dtoken.isEnum)) {
        // print(element.pattern);
        var constantRules = element.groupDTokens
            .map<List<String>>((dtoken) => _enumAllGiven(dtoken, stateName))
            .toList(growable: false);
        matches.addAll(enumAllMatches(errorText, constantRules));
      }
    });

    /// step2: sort
    /// 从左到右 -> 优先
    /// start 小 ->
    /// input.length 小 ->
    matches
      ..sort((left, right) {
        if (left.start < right.start) {
          return -1;
        } else if (left.input.length < right.input.length) {
          return -1;
        }
        return 1;
      });

    /// step3: 用 Set 去重
    return (Set<String>()..addAll(matches.map<String>((m) => m.input)))
        .toList();
  }

  // Deprecated.
  List<String> __correcting({String tText, String stateName}) {
    List<String> recommands = [];
    _addFromParses(parses) {
      parses[stateName]?.whereType<JParse>()?.forEach((element) {
        // part1: from parsing rules -> JParse.constants;
        if (element.isConst)
          recommands.addAll(enumAllConstants(element.constants));
        // part2: from Token.Enum Given Values
        if (element is GroupJParse) {
          element.groupDTokens.forEach((dTk) {
            if (dTk.isEnum && dTk.enums.isNotEmpty) {
              recommands.addAll(dTk.enums);
            }
          });
        } else if (element is JParse) {
          var dTk = element.dtoken;
          if (dTk.isEnum && dTk.enums.isNotEmpty) {
            recommands.addAll(dTk.enums);
          }
        }
      });
    }

    _addFromParses(_runtimeContext);
    // part3: from all unproccessedTokens with Enum matched value
    // who has a named or nonenamed Enum Type which == Token.Enum
    DynamicToken dTk;
    _tokensUnprocessed.forEach((uTk) {
      if (uTk.isDynamic &&
          (dTk = uTk.token as DynamicToken).isEnum &&
          dTk.enums.isEmpty) {
        recommands.add(uTk.match);
      }
    });
    if (tText != null) {
      return recommands
        ..retainWhere((element) => RegExp(tText).hasMatch(element));
    } else
      return recommands;
  }

  String pretty(String text,
      [List<String> stack, Position pos, Map<String, List<Parse>> commondefs]) {
    return processedString(
        unprocessedTokens: getTokensUnprocessed(text, stack, pos, commondefs));
  }

  void configPrint() {
    print('''Settings:
+============================
|  $CONFIG_EVENT_DISPATCHER : ${configEventDispatcher}
|  $CONFIG_SAVING_RUNTIME_CONTEXT : ${configSaveRuntimeContext}
|  $CONFIG_STATE_WILL_LIST_TOKENS : ${configListTokenStateNames}
|  $CONFIG_USECACHE : ${useCache}
+============================
''');
    if (configListTokenStateNames == null || _tokensUnprocessed == null) return;
    print('''

Tokens by state:
=============================
''');
    int total = 0;
    configListTokenStateNames.forEach((tokenObj) {
      int byToken = 0;
      print('''   ${tokenName(tokenObj)}:
    =========================
''');
      _tokensUnprocessed.forEach((UnprocessedToken ut) {
        if (tokenObj == ut.token ||
            ut.token.toString() == 'Token.' + tokenName(tokenObj)) {
          byToken++;
          print('''   ${ut.stateName}:
    ${ut.match}
''');
        }
        // else {
        //   print('\n');
        //   print(ut.token.toString());
        //   print(tokenName(tokenObj));
        //   print('\n');
        // }
      });
      String byTokenPadding = 'total: $byToken'.padLeft(25);
      total += byToken;
      print('''
    =========================
    $byTokenPadding
''');
    });
    String totalPadding = 'total: $total'.padLeft(29);
    print('''
=============================
$totalPadding
''');
  }

  /// TODO: 自动补全通过缓存配置获得 暂时不需要静态获得了
  /// 静态分析获得所有state的parsing tree
  statesStaticAllExpand(String stateName, [Map<String, List<T>> commondefs]) {
    /// merge common
    // commondefs = _merge(commondefs, commonparses(commondefs));
    // Map<String, Iterable<T>> parsedefs =
    // /// merge all
    // _expand(_merge(commondefs, parses));
    // parsedefs.keys.contains
  }
  // Split ``text`` into (token type, text) pairs.
  //
  // ``stack`` is the initial stack (default: ``[root]``)
  //
  // The get_tokens_unprocessed() method must return an iterator or iterable
  // containing tuples in the form (index, token, value).
  // Stream<Tuple2<index, token, value>>
  List<UnprocessedToken> _tokensUnprocessed;
  Iterable<UnprocessedToken> getTokensUnprocessed(String text,
      [List<String> stack, Position pos, Map<String, List<T>> commondefs]) {
    // init 变量
    var ret = <UnprocessedToken>[];
    pos = pos ?? Position(0);

    /// merge common
    commondefs = _merge(commondefs, commonparses(commondefs));
    Map<String, Iterable<T>> parsedefs =

        /// merge all
        _expand(_merge(commondefs, parses));
    _runtimeContext = configSaveRuntimeContext ? parsedefs : null;
    final List<String> statestack = stack ?? List.from([root]);
    List<T> statetokens = parsedefs[statestack.last];
    if (configDebuggable) {
      print('\n==================================');
      print('\n$this invoke getTokenUnprocessed');
      print('\nstatestack: $statestack');
      print('\nparsedefs: ${parsedefs.keys}');
      print('\n==================================');
    }

    bool stateStartTrigger = false;
    bool stateRestartTrigger = false;
    bool stateEndTrigger = false;
    String _willRestartFlag;
    // init 函数
    _markStateAboutEventEmmitor(_) {
      stateStartTrigger = false;
      stateRestartTrigger = false;
      stateEndTrigger = false;
      _.forEach((T item) {
        if (item is EventEmmitor) {
          if (item.dtoken == Token.EventOnStateWillStart)
            stateStartTrigger = true;
          else if (item.dtoken == Token.EventOnStateWillRestart)
            stateRestartTrigger = true;
          else if (item.dtoken == Token.EventOnStateWillEnd)
            stateEndTrigger = true;
        }
      });
    }

    String currentStateName() {
      return statestack.isEmpty ? root : statestack.last;
    }

    int _tempL = ret.length;
    Context _buildContext() {
      int lastL = _tempL;
      _tempL = ret.length;
      return TokenContext(parsedefs, ret, lastL);
    }

    bool _finishJumpState(newStates) {
      for (final state in newStates) {
        if (_doStackActionsNeedBreak(statestack, state,
                context: _buildContext()) ==
            true) {
          return true;
        }
      }
      statetokens = parsedefs[currentStateName()];
      // statestack.isEmpty ? parsedefs[root] : parsedefs[statestack.last];
      // _markStateAboutEventEmmitor(statetokens);
      // if (statetokens == null) debugger();
      return false;
    }

    while (true && pos.from < text.length) {
      bool matched = false;
      String solidEventStateName = currentStateName();
      _markStateAboutEventEmmitor(statetokens);
      if (supportEventDispatching) {
        if (stateRestartTrigger && _willRestartFlag == currentStateName()) {
          configEventDispatcher.dispatchEvent(
              Token.EventOnStateWillRestart,
              Token.EventOnStateWillRestart.toString().substring(6),
              solidEventStateName,
              _buildContext());
        } else if (stateStartTrigger) {
          configEventDispatcher.dispatchEvent(
              Token.EventOnStateWillStart,
              Token.EventOnStateWillStart.toString().substring(6),
              solidEventStateName,
              _buildContext());
          _willRestartFlag = currentStateName();
        }
      }
      var _growableIterating = []..addAll(statetokens);
      while (_growableIterating.isNotEmpty) {
        final parse = _growableIterating.removeAt(0);
        // }
        // for (final parse in statetokens) {
        final pattern = parse.pattern;
        final token = parse is JParse ? parse.dtoken : parse.token;
        final newStates = parse.newStates;
        Token _temp;
        if (token == (_temp = Token.EventOnCondition) ||
            token == (_temp = Token.EventOnConditionInclude) ||
            token == (_temp = Token.EventOnRuleMissed) ||
            token == (_temp = Token.EventOnRuleWillStart)) {
          if (supportEventDispatching) {
            // Token.EventOnCondition 具有跳转的功能
            if (configEventDispatcher.dispatchEvent(
                    _temp, pattern, solidEventStateName, _buildContext()) ==
                true) {
              if (_temp == Token.EventOnCondition) {
                if (newStates != null && _finishJumpState(newStates)) {
                  return ret;
                }
              } else if (_temp == Token.EventOnConditionInclude) {
                _growableIterating.insertAll(
                    0,
                    expandList(
                        (parse as JParsePackage).package.cast<T>(), parsedefs));
              }
            }
          }
        } else if (token == Token.EventOnStateWillEnd ||
            token == Token.EventOnStateWillRestart ||
            token == Token.EventOnStateWillStart) {
          continue;
        } else if (token == Token.IncludeOtherLexer) {
          RegexLexer lexer =
              parse is LexerJParse ? parse.lexer : (parse as LexerParse).lexer;
          lexer.config = config;
          if (newStates != null) {
            for (final state in newStates) {
              _doStackActionsNeedBreak(statestack, state,
                  context: _buildContext(), onlyActions: true);
            }
          }
          statestack.add(lexer.root);
          var pos_before = pos.from;
          Iterable<UnprocessedToken> res =
              lexer.getTokensUnprocessed(text, statestack, pos, commondefs);
          _runtimeContext = lexer._runtimeContext;
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
              ret.addAll(this._bygroup(
                  m,
                  parse.groupTokens ?? (parse as GroupJParse).groupDTokens,
                  currentStateName()));
            } else {
              ret.add(UnprocessedToken(
                  pos.from, token, m.group(0), currentStateName(), debuggable));
            }
          }
          pos.from = m.end;
          if (newStates != null && _finishJumpState(newStates)) {
            return ret;
          }
          matched = true;
          break;
        }
      }
      if (supportEventDispatching && stateEndTrigger) {
        configEventDispatcher.dispatchEvent(
            Token.EventOnStateWillEnd,
            Token.EventOnStateWillEnd.toString().substring(6),
            solidEventStateName,
            _buildContext());
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
              currentStateName(), debuggable));
          pos.from++;
        } on Exception catch (err) {
          print(err);
          break;
        }
      }
    }
    return _tokensUnprocessed = ret;
  }

  /// Deprecated.
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

  bool _doStackActionsNeedBreak(List<String> statestack, String stateOrAction,
      {Context context, bool onlyActions = false}) {
    if (stateOrAction == CLEAR)
      statestack.clear();
    else if (stateOrAction == BREAK) {
      return true;
    } else if (stateOrAction == POP)
      this._pop(statestack, 1);
    else if (stateOrAction == POP2)
      this._pop(statestack, 2);
    else if (stateOrAction == POPROOT)
      this._popTo(statestack, root);
    else if (stateOrAction == PUSH)
      statestack.add(statestack.isNotEmpty ? statestack.last : root);
    else if (stateOrAction.startsWith("#event-match")) {
      if (supportEventDispatching) {
        configEventDispatcher.dispatchEvent(
            Token.EventOnRuleMatchedEnterLeave,
            stateOrAction,
            statestack.isNotEmpty ? statestack.last : root,
            context);
      }
    }

    /// add more dynamic way to control state stack.
    else if (stateOrAction.startsWith("#pop:")) {
      final popingState = stateOrAction.replaceFirst("#pop:", "");
      if (int.tryParse(popingState) != null) {
        this._pop(statestack, int.parse(popingState));
      } else
        this._popTo(statestack, popingState);

      /// end add by jackyanjiaqi.
    } else if (stateOrAction.startsWith("#on:")) {
      List<List<dynamic>> rules1 = [
        [
          r'#on:(.*)#pop:(.*)#do:\{(.*)\}#else:\{(.*)\}',
          [statestack, 1, 2, 3, 4]
        ],
        [
          r'#on:(.*)#pop:(.*)#do:\{(.*)\}',
          [statestack, 1, 2, 3, null]
        ],
        [
          r'#on:(.*)#pop:(.*)#else:\{(.*)\}',
          [statestack, 1, 2, null, 3]
        ],
        [
          r'#on:(.*)#pop:(.*)',
          [statestack, 1, 2, null, null]
        ],
        [
          r'#on:(.*)#do:\{(.*)\}#else:\{(.*)\}',
          [statestack, 1, null, 2, 3]
        ],
        [
          r'#on:(.*)#do:\{(.*)\}',
          [statestack, 1, null, 2, null]
        ],
        [
          r'#on:(.*)#else:\{(.*)\}',
          [statestack, 1, null, null, 2]
        ],
      ];

      /// Simple Rules But Need More Test
      // List<List<dynamic>> rules2 = [
      //   [
      //     r'#on:(.*)(#pop:(.*)|#do:\{(.*)\}|#else:\{(.*)\})+?',
      //     [statestack, 1, 3, 4, 5],
      //     {
      //       2: [3, 4, 5]
      //     }
      //   ]
      // ];
      return RegstrInvoke(stateOrAction, rules1, invoker: _onPopDoElse);

      /// skipping states when onlyAction == true;
    } else if (onlyActions == false) {
      statestack.add(stateOrAction);
      if (configDebuggable) print(statestack);
    }

    return false;

    /// end add by jackyanjiaqi.
  }

  // Callback that yields multiple actions for each group in the match.
  Iterable<UnprocessedToken> _bygroup(Match m, Iterable<Object> tokens,
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
    if (configDebuggable == true) print(statestack);
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

  Map<String, List<T>> _merge(
      Map<String, List<T>> merge1, Map<String, List<T>> merge2) {
    final merged = Map<String, List<T>>();
    if (merge1?.isNotEmpty ?? false) {
      for (final entry in merge1.entries) {
        merged[entry.key] = entry.value;
      }
    }
    if (merge2?.isNotEmpty ?? false) {
      for (final entry in merge2.entries) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  Iterable<T> expandList(List<T> parses, Map<String, List<T>> parsesMap,
      {List<String> replaceNewState}) sync* {
    for (final p in parses) {
      if (p.token == Token.IncludeOtherParse) {
        yield* expandList(parsesMap[p.pattern], parsesMap,
            replaceNewState: replaceNewState ?? p.newStates);
      } else if (replaceNewState != null) {
        /// Parse.include 批量替换 newState 避免污染原 Parse
        yield p.copy(newStates: replaceNewState);
      } else
        yield p;
    }
  }

  Map<String, List<T>> _expand(Map<String, List<T>> parsesMap) {
    final expanded = Map<String, List<T>>();
    for (final entry in parsesMap.entries) {
      if (useCache) {
        _cacheContext ??= {};
        if (_cacheContext.containsKey(entry.key)) {
          expanded[entry.key] = _cacheContext[entry.key];
        } else {
          expanded[entry.key] = expandList(entry.value, parsesMap).toList();
          _cacheContext[entry.key] = expanded[entry.key];
        }
      } else
        expanded[entry.key] = expandList(entry.value, parsesMap).toList();
    }
    return expanded;
  }
}

class LexerMain extends RegexLexer<JParse> {
  final ERROR_NO_ROOTLEXER_OR_LIBRARY_ROOTSTATE_SET =
      'ERROR :NO_ROOTLEXER_OR_LIBRARY_ROOTSTATE_SET!!!';
  static LexerMain _instance = LexerMain._();
  LexerMain._() : super(debuggable: true);
  List<LibraryLexer> _libraries;
  String _rootState;
  RegexLexer _root;

  static LexerMain load({List<LibraryLexer> libraries, RegexLexer root}) {
    return _instance
      ..loadLirbraries(libraries)
      ..rootLexer(root);
  }

  loadLirbraries(List<LibraryLexer> libraries) {
    _libraries = libraries ?? _libraries;
  }

  rootLexer(RegexLexer root) {
    _root = root ?? _root;
  }

  rootState(String rstate) {
    _rootState = rstate ?? _rootState;
  }

  @override
  Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) =>
      currentCommon;

  @override
  RegExpFlags get flags => _root?.flags;

  @override
  Map<String, List<JParse>> get parses {
    assert(_root != null || _rootState != null);
    if (_libraries?.isNotEmpty ?? false) {
      _libraries[0]
        ..loadNext(_root)
        ..loadRoot(_rootState);
      LibraryLexer main =
          _libraries.reduce((value, element) => element..loadNext(value));
      return {
        'main': [
          JParse.lexer(main, doActionsWithoutState: [CLEAR])
        ]
      };
    } else if (_root != null) {
      return {
        'main': [
          JParse.lexer(_root, doActionsWithoutState: [CLEAR])
        ]
      };
    } else
      return {
        'main': [
          JParse.empty([ERROR_NO_ROOTLEXER_OR_LIBRARY_ROOTSTATE_SET])
        ],
        ERROR_NO_ROOTLEXER_OR_LIBRARY_ROOTSTATE_SET: []
      };
  }

  @override
  String get root => 'main';

  dependencyAnalyze() {
    Map<String, Object> defined = {};
    Map<String, List> undefined = {};
    _oSymbol(Object o) => '${o.runtimeType}(${o.hashCode})';
    if (_libraries != null && _libraries.isNotEmpty) {
      _libraries.reversed.forEach((element) {
        Map<String, List> d =
            defined[_oSymbol(element)] = {'override': [], 'unused': []};
        var it = element.commonparses(null);
        it.keys.forEach((state) {
          if (defined.keys.contains(state)) {
            var oldElement = defined[state];
            print(
                'WARNING:${_oSymbol(element)} defined a override state $state already defined in $oldElement\n');
            (defined[oldElement] as Map<String, List>)['override'].add(state);
            (defined[oldElement] as Map<String, List>)['unused'].remove(state);
            defined[state] = _oSymbol(element);
            (defined[_oSymbol(element)] as Map<String, List>)['unused']
                .add(state);
          } else {
            defined[state] = _oSymbol(element);
            (defined[_oSymbol(element)] as Map<String, List>)['unused']
                .add(state);
          }
        });
      });
      _libraries.reversed.forEach((element) {
        undefined[_oSymbol(element)] = [];
        var it = element.commonparses(null);
        it.values.forEach((e) {
          List<JParse> _growableEValues = []..addAll(e);
          while (_growableEValues.isNotEmpty) {
            var parser = _growableEValues.removeAt(0);
            // }
            // e.forEach((parser) {
            // 解包压平
            if (parser is JParsePackage) {
              _growableEValues..insertAll(0, parser.package);
              break;
            }
            // 检查包含关系
            if (parser.token == Token.IncludeOtherParse) {
              // 包含未定义
              if (defined[parser.pattern] == null) {
                undefined[_oSymbol(element)].add(parser.pattern);
              } else {
                // 包含已定义
                var usedElement = defined[parser.pattern];
                (defined[usedElement] as Map<String, List>)['unused']
                    .remove(parser.pattern);
              }
            }
            // 检查跳转关系
            if (parser.newStates?.isNotEmpty ?? false) {
              parser.newStates.forEach((jump) {
                // 排除跳转动作
                if (RegExp(r'#(on|pop|push|clear|break|event)')
                        .matchAsPrefix(jump) !=
                    null) return;
                // 跳转未定义
                if (defined[jump] == null) {
                  undefined[_oSymbol(element)].add(jump);
                  // 跳转已定义
                } else {
                  var usedElement = defined[jump];
                  (defined[usedElement] as Map<String, List>)['unused']
                      .remove(jump);
                }
              });
            }
          }
          // );
        });
      });
      String out = "";
      undefined.keys.forEach((key) => out += '$key >> ');
      out += 'root';
      print('''
Loading order:
=============================
$out
=============================
''');
      // undefined;
      out = "";
      int total = 0;
      undefined.forEach((key, value) {
        if (value.isNotEmpty) {
          value.forEach((element) {
            out += '$key:$element\n';
            total++;
          });
        }
      });
      if (out.isNotEmpty) {
        String totalPadding = 'total: $total'.padLeft(29);
        print('''
Undefined states:
=============================
$out
=============================
$totalPadding

''');
      }
      // override;
      out = "";
      total = 0;
      undefined.keys.forEach((key) {
        Map<String, List> c = defined[key];
        if (c['override'].isNotEmpty) {
          c['override'].forEach((value) {
            out += '$key:$value\n';
            total++;
          });
        }
      });
      if (out.isNotEmpty) {
        String totalPadding = 'total: $total'.padLeft(29);
        print('''Override states:
=============================
$out
=============================
$totalPadding

''');
      }
      //
      out = "";
      total = 0;
      undefined.keys.forEach((key) {
        Map<String, List> c = defined[key];
        if (c['unused'].isNotEmpty) {
          c['unused'].forEach((value) {
            out += '$key:$value\n';
            total++;
          });
        }
      });
      if (out.isNotEmpty) {
        String totalPadding = 'total: $total'.padLeft(29);
        print('''Unused states:
=============================
$out
=============================
$totalPadding

''');
      }
      if (configDebuggable) {
        print('\n$defined\n$undefined');
      }
    }
  }
}

abstract class LibraryLexer extends RegexLexer<JParse> {
  RegexLexer _next;
  String _root;
  loadNext(RegexLexer next) {
    _next = next;
  }

  loadRoot(String root) {
    _root = root ?? _root;
  }

  String get symbolInSys => '$hashCode';

  @override
  RegExpFlags get flags =>
      _next?.flags ??
      RegExpFlags(
        dotAll: true,
        multiline: true,
      );

  @override
  Map<String, List<JParse>> get parses => _next != null
      ? {
          symbolInSys: [
            JParse.lexer(_next, doActionsWithoutState: [CLEAR, _next.root])
          ]
        }
      : null;

  @override
  String get root => _next != null ? symbolInSys : _root;
}

abstract class DTokenedRegexLexer extends RegexLexer<JParse> {
  DTokenedRegexLexer({
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
}
