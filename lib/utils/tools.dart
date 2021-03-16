import 'package:lexpro/base/token.dart';

/// maxCount support upto 10.
dynamic RegstrInvoke(String invokeFrom, List<List<dynamic>> patternMappers,
    {int maxCount, Function invoker}) {
  if (patternMappers.isNotEmpty) {
    assert(patternMappers[0].length >= 2);
    assert(patternMappers[0][1] is Iterable);
  }
  if (maxCount == null) {
    maxCount = 0;
    patternMappers.forEach((element) {
      if (element[1].length > maxCount) {
        maxCount = element[1].length;
      }
    });
  }
  for (List singleRule in patternMappers) {
    bool isPureOrLink = singleRule.length > 2;
    RegExpMatch rem = RegExp(singleRule[0]).matchAsPrefix(invokeFrom);
    List<String> groupPureOrLink = isPureOrLink
        ? groupPureOrLinkCapture(invokeFrom, singleRule[0], singleRule[2])
        : null;
    if (rem != null) {
      groupValue(v) => (v is int && v > 0
          ? (isPureOrLink ? groupPureOrLink[v] : rem.group(v))
          : v);
      if (invoker == null) {
        return singleRule[1].map((v) => groupValue(v)).toList();
      } else {
        switch (maxCount) {
          case 1:
            return invoker(groupValue(singleRule[1][0]));
          case 2:
            return invoker(
                groupValue(singleRule[1][0]), groupValue(singleRule[1][1]));
          case 3:
            return invoker(groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]), groupValue(singleRule[1][2]));
          case 4:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]));
          case 5:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]));
          case 6:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]),
                groupValue(singleRule[1][5]));
          case 7:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]),
                groupValue(singleRule[1][5]),
                groupValue(singleRule[1][6]));
          case 8:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]),
                groupValue(singleRule[1][5]),
                groupValue(singleRule[1][6]),
                groupValue(singleRule[1][7]));
          case 9:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]),
                groupValue(singleRule[1][5]),
                groupValue(singleRule[1][6]),
                groupValue(singleRule[1][7]),
                groupValue(singleRule[1][8]));
          case 10:
            return invoker(
                groupValue(singleRule[1][0]),
                groupValue(singleRule[1][1]),
                groupValue(singleRule[1][2]),
                groupValue(singleRule[1][3]),
                groupValue(singleRule[1][4]),
                groupValue(singleRule[1][5]),
                groupValue(singleRule[1][6]),
                groupValue(singleRule[1][7]),
                groupValue(singleRule[1][8]),
                groupValue(singleRule[1][9]));
          default:
            throw new Error();
        }
      }
    }
  }
}

/// groupPureOrLink is patterns like this (()|()|())+?
/// in case below
/// r'exec(((( a)|( b)|( c))+?)| -name((( d)|( e)|( f))+?))+'
/// replaceGroupIndexs is {
///   3 : [4,5,6],
///   8 : [9,10,11]
/// }
List<String> groupPureOrLinkCapture(
    String string, String pattern, Map<int, List<int>> pureOrLinkGroupIndexs) {
  assert(pattern.contains("?") == true);
  String target = string;
  RegExpMatch m = RegExp(pattern).matchAsPrefix(target) as RegExpMatch;
  List<String> groups;
  while (m != null
      // && replaceGroupIndexs.any((index) => m.group(index) != null) == true
      ) {
    groups = groups ?? m.groups(genIndices(m.groupCount));
    // assert(pureOrLinkGroupIndexs.entries != null);
    pureOrLinkGroupIndexs.entries.forEach((MapEntry<int, List<int>> replaced) {
      var rplc = m.group(replaced.key);
      if (rplc != null) {
        replaced.value.forEach((refreshIndex) {
          groups[refreshIndex] = groups[refreshIndex] ?? m.group(refreshIndex);
        });
        target = target.replaceFirst(rplc, "");
      }
    });
    m = RegExp(pattern).matchAsPrefix(target);
  }
  return groups;
}

List<int> genIndices(int count) {
  var ret = <int>[];
  for (int i = 0; i <= count; i++) {
    ret.add(i);
  }
  return ret;
}

// TODO: UNFINISHED
// can remember where matches;
smartMatch(String text, List<List<String>> constantRules,
    [List<List<RegExpMatch>> matched]) {
  for (List<String> rules in constantRules) {
    rules.forEach((pattern) {
      if (text.length < pattern.length) {
        // RegExp(pattern).firstMatch()
      }
    });
  }
}

List<List<RegExpMatch>> enumSplitMatches(
    List<String> splitText, List<List<String>> constantRules,
    {List<List<String>> templates,
    List<List<List<String>>> matchedFromTemplate,

    /// mode=1; 全部返回（默认）
    /// mode=2; 存在匹配（最小匹配，不继续匹配其他，但速度最快，用于快速检测是否有值）
    /// mode=3; 全称匹配（完整匹配）
    int matchMode = 1}) {
  List<List<RegExpMatch>> res = [];
  List<List<dynamic>> allRules = [];
  allRules.addAll(
      enumAllConstants(constantRules).map<List<dynamic>>((e) => [e, null]));
  if (templates != null) {
    allRules.addAll(
        enumSplitTemplates(constantRules, templates, matchedFromTemplate));
  }
  allRules.forEach((ruleWrapper) {
    final rule = ruleWrapper[0];
    final departTexts = ruleWrapper[1];
    List<RegExpMatch> matches = [];
    Iterable<String> it = splitText.expand((element) =>
        (departTexts?.contains(element) ?? false) ? [] : [element]);
    Function _inner = (text) {
      RegExpMatch m;
      if ((m = RegExp(text).firstMatch(rule)) != null) {
        matches.add(m);
        return true;
      }
      return false;
    };
    switch (matchMode) {
      case 1:
        it.forEach(_inner);
        break;
      case 2:
        if (!it.any(_inner)) return;
        break;
      case 3:
        if (!it.every(_inner)) return;
    }
    if (matches.isNotEmpty) {
      res.add(matches);
    }
  });
  return res;
}

List<RegExpMatch> enumAllMatches(String text, List<List<String>> constantRules,
    {List<List<String>> templates}) {
  List<RegExpMatch> res = [];
  List<String> allRules = [];
  allRules.addAll(enumAllConstants(constantRules));
  if (templates != null) {
    allRules.addAll(enumAllTemplates(constantRules, templates));
  }
  allRules.forEach((rule) {
    RegExpMatch m;
    if ((m = RegExp(text).firstMatch(rule)) != null) {
      res.add(m);
    }
  });
  return res;
}

List<String> splitTextRange(String pattern, List<String> splitText,
    {List<int> cacheRange,
    int mode =
        3 // 1: Biggest(最大覆盖，两端的匹配片段可能未被完全匹配) 2: Smallest(最小覆盖，裁减掉两端多余匹配) 3:必须正好
    }) {
  RegExpMatch m;
  cacheRange ??= range(splitText);
  if ((m = RegExp(pattern).firstMatch(splitText.join())) != null) {
    var start = 0;
    for (; start <= splitText.length; start++) {
      if (mode == 3 && cacheRange[start] == m.start) {
        break;
      } else if (mode == 2 && cacheRange[start] >= m.start) {
        break;
      } else if (mode == 1 &&
          cacheRange[start] <= m.start &&
          cacheRange[start + 1] > m.start) {
        break;
      }
    }
    var end = start;
    for (; end <= splitText.length; end++) {
      if (mode == 3 && cacheRange[end] == m.end) {
        break;
      } else if (mode == 2 &&
          cacheRange[end] <= m.end &&
          cacheRange[end + 1] > m.end) {
        break;
      } else if (mode == 1 && cacheRange[end] >= m.end) {
        break;
      }
    }
    return splitText.sublist(start, end);
  }
}

List<int> range(List<String> texts) {
  if (texts?.isEmpty ?? true) return [];
  List<int> ranges = [0];
  texts.forEach((element) {
    ranges.add(ranges.last + element.length);
  });
  return ranges;
}

String constantEscape(String constant) {
  List<String> constants = [constant];
  if (constant.contains(r'\')) {
    constants = constant.split(r'\');
  }
  return constants.map<String>((cstnt) {
    return [
      cstnt,
      '.',
      '+',
      '?',
      '*',
      '(',
      ')',
      '^',
      '|',
      '[',
      ']',
      '{',
      '}',
      r'$'
    ].reduce((value, element) {
      if (value.contains(element)) {
        return value.replaceAll(element, r'\' + element);
      }
      return value;
    });
  }).join(r'\\');
}

//每一个 String template 规则 对应一个 List<String> matchedFromTemplate
//返回一个 [['rule', ['var1','var2']],..]
List<List<dynamic>> enumSplitTemplates(
    List<List<String>> constantRules,
    List<List<String>> templates,
    List<List<List<String>>> matchedFromTemplate) {
  if (templates?.isEmpty ?? true) return [];
  var i;
  List<List<dynamic>> res = [];
  for (i = 0; i < templates.length; i++) {
    if (templates[i] != null)
      res.addAll(multiply(enumAllConstants(constantRules.sublist(0, i)),
          templates[i], matchedFromTemplate[i]));
  }
  return res;
}

/// wd10 匹配 width_10
/// width_$
/// minwidth_$
/// maxwidth_$
List<String> enumAllTemplates(
    List<List<String>> constantRules, List<List<String>> templates) {
  if (templates?.isEmpty ?? true) return <String>[];
  var i;
  List<String> res = <String>[];
  for (i = 0; i < templates.length; i++) {
    if (templates[i] != null)
      res.addAll(enumAllConstants(
          [enumAllConstants(constantRules.sublist(0, i)), templates[i]]));
  }
  return res;
}

List<List<dynamic>> multiply(
    List<String> patterns, List<String> templates, List<List<String>> matched) {
  List<List<dynamic>> res = [];
  for (var i = 0; i < templates.length; i++) {
    patterns.forEach((pattern) {
      var constant = pattern + templates[i];
      res.add([constant, (matched != null ? matched[i] : [])]);
    });
  }
  return res;
}

List<String> enumAllConstants(List<List<String>> constantRules) {
  if (constantRules?.isEmpty ?? true) return <String>[];
  var res = constantRules.reduce((value, element) {
    if (value.isEmpty)
      return element;
    else if (element.isEmpty)
      return value;
    else
      return value
          .expand<String>((innerValue) =>
              element.map<String>((innerElement) => innerValue + innerElement))
          .toList();
  });
  return res;
}

String const2Pattern(List<List<String>> constantRules) {
  return constantRules.whereType<List<String>>().map((element) {
    List<String> orparts = <String>[]..addAll(element);
    bool blankAllowed = false;
    orparts = (orparts
          ..removeWhere((element) {
            return element.isEmpty && (blankAllowed = true);
          }))
        .map((cstnt) => constantEscape(cstnt))
        .toList();
    if (orparts.isNotEmpty) {
      return '(' + orparts.join('|') + ')' + (blankAllowed ? '?' : '');
    } else
      return "";
  }).join();
}

String tokenName(Object token) {
  if (token is DynamicToken) {
    return token.name;
  } else if (token is Token) {
    return token.toString().substring(6);
  } else
    return token.toString();
}

String enumTokenName(Object token) {
  token ??= Token.Enum;
  String name;
  if (token is DynamicToken) {
    name = token.name;
  } else if (token is Token) {
    name = token.toString().substring(6);
  } else
    name = token.toString();
  return name;
}

String varName(int index) => index == 0 ? r'$' : r'$' '$index';

wrapPrintRegExpLL(List<List<RegExpMatch>> target) {
  target.forEach((inner) {
    print('\n[' + inner[0].input);
    inner.forEach((exp) => print('\n${exp.group(0)} : ${exp.start}'));
    print(']');
  });
  return target;
}
