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
      groupValue(v) => (v is int && v > 0 && v <= maxCount
          ? (isPureOrLink ? groupPureOrLink[v] : rem.group(v))
          : '$v');
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
groupPureOrLinkCapture(String string,
    [String pattern, Map<int, List<int>> pureOrLinkGroupIndexs]) {
  assert(pattern?.contains("?") == true);
  String target = string;
  RegExpMatch m = RegExp(pattern).matchAsPrefix(target);
  List<String> groups;
  while (m != null
      // && replaceGroupIndexs.any((index) => m.group(index) != null) == true
      ) {
    groups = groups ?? m.groups(genIndices(m.groupCount));
    assert(pureOrLinkGroupIndexs?.entries != null);
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
