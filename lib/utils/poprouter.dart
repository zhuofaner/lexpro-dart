String decryptPOP(String popingName) {
  var poping = popingName?.split('#pop:');
  if (poping != null && poping.length == 2) {
    return poping[1];
  }
  return popingName;
}

String POPTO(stateNameOrNum) {
  if (stateNameOrNum is String && stateNameOrNum.contains('#pop:'))
    throw Error();
  return '#pop:$stateNameOrNum';
}

/// Recursive self invoke is dangerous!!!(NOT TESTED YET)
String ON(String stateName, {String POP, String DO, String ELSE}) {
  var ret = '#on:$stateName';
  if (POP != null) {
    ret += '#pop:$POP';
  }
  if (DO != null) {
    ret += '#do:{$DO}';
  }
  if (ELSE != null) {
    ret += '#else:{$ELSE}';
  }
  return ret;
}

/// Recursive self invoke is dangerous!!!(NOT TESTED YET)
String ONPOP(String stateName, {String DO, String ELSE}) {
  return ON(stateName, POP: stateName, DO: DO, ELSE: ELSE);
}
