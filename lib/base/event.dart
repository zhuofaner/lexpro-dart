import 'package:lexpro/base/lexer.dart';
import 'package:lexpro/base/parser.dart';

abstract class Context {
  Map<String, Iterable> get definitions;
  List<UnprocessedToken> get tokens;
  List<UnprocessedToken> get added;
}

class TokenContext implements Context {
  final Map<String, Iterable> defs;
  final List<UnprocessedToken> tkns;
  final int lstL;
  const TokenContext(this.defs, this.tkns, this.lstL);

  @override
  List<UnprocessedToken> get added => tkns.sublist(lstL);

  @override
  Map<String, Iterable> get definitions => defs;

  @override
  List<UnprocessedToken> get tokens => tkns;

  @override
  String toString() {
    return '''
${super.toString()}-added:$added
''';
  }
}

abstract class RawEventDispatcher {
  bool dispatchEvent(
      Token eventType, String eventFlag, String stateName, Context context);
}

mixin BlankComplementMixin on FullEventListener {
  @override
  bool onCondition(String eventFlag) {}

  @override
  bool onConditionInclude(String eventFlag) {}

  @override
  onRuleMatched(String stateName, Context context,
      {String enter, String leave}) {}

  @override
  onRuleMissed(String ruleMissedFlag) {}

  @override
  onRuleWillStart(String ruleStartFlag) {}

  @override
  onStateWillEnd(String stateName) {}

  @override
  onStateWillRestart(String stateName) {}

  @override
  onStateWillStart(String stateName) {}
}

/// You can directly extends RawEventDispatcher and define your own lifecycle.
abstract class FullEventListener implements RawEventDispatcher {
  onStateWillStart(String stateName);
  onStateWillRestart(String stateName);
  onStateWillEnd(String stateName);
  onRuleWillStart(String ruleStartFlag);
  onRuleMissed(String ruleMissedFlag);
  onRuleMatched(String stateName, Context context,
      {String enter, String leave});
  bool onCondition(String eventFlag);
  bool onConditionInclude(String eventFlag);
  bool dispatchEvent(
      Token eventType, String eventFlag, String stateName, Context context) {
    switch (eventType) {
      case Token.EventOnConditionInclude:
        return onConditionInclude(eventFlag);
      case Token.EventOnCondition:
        return onCondition(eventFlag);
      case Token.EventOnRuleMatchedEnterLeave:
        final Map data = decryptEvent(eventFlag);

        /// TODO: 分解字段
        onRuleMatched(stateName, context,
            enter: data['enter'], leave: data['leave']);
        break;
      case Token.EventOnRuleMissed:
        onRuleMissed(eventFlag);
        break;
      case Token.EventOnRuleWillStart:
        onRuleWillStart(eventFlag);
        break;
      case Token.EventOnStateWillStart:
        onStateWillStart(stateName);
        break;
      case Token.EventOnStateWillRestart:
        onStateWillRestart(stateName);
        break;
      case Token.EventOnStateWillEnd:
        onStateWillEnd(stateName);
        break;
      case Token.EventUnknown:
      default:
    }
    return false;
  }
}
