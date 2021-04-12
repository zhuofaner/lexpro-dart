# lexpro 2

[<img src="https://pic1.zhimg.com/v2-1570b618531c9b0bcf6d273d5fe88cfa_1440w.jpg" width="800"/>](https://zhuanlan.zhihu.com/p/356951579)

[中文版](https://github.com/zhuofaner/lexpro-dart/blob/master/README_CN.md)

Here is new features in 2.1.1

* add `splitAutoCompletingMatches` to get a detailed List< List< RegExpMatch>> to decorate your autoCompleting ListView

Here is new features in 2.1

* support **Templates** extends JParse
    for better match for split text auto completing.

    - use `$`、`$1`、`$2` .. for variable injection in a template string.
    - support `variables extracting` from exited `tokens` or matches a `pattern` from the given split text.
    - support extracting failed basic variable value
    - if `enumnone` not given and extracting failed to match anyone, template rule with symbol `$` ignored.

* support `splitAutoCompleting` which can match split words that `autoCompleting` can not match
    
    - `wd40` split in letters `w` `d` `4` `0` **matches** width_40、width="40"、maxWidth_40、minWidth_40、 maxWidth="40"、minWidth="40"
    - if `length="400"` exists, wd40 also matches width_400
    
Here is features in 2

* support **Event System** to build your AST or directly do your stuff.
    
    * support self defined `LIFE_CYCLE`s and `onCondition`s Events

    * in `onRuleMatched` function will return a `Context` including newly added Tokens.

* support build Parsers from known **Constants**

* support DynamicToken create from **Enums** or **asEnum** to collect from parsed known message.

* support create pure **Library Lexer** only loaded in root Lexer's common part.

* support parse from a configgable **LexerMain** with a **Library Chain**

    * support static `dependencyAnalyze` with no parsers running.

* support **Auto Completing** from **Constants and Enums** reuse a cached runtime context.
(*not tested launched from other than **Lexer Main**)*

## 1.Event System
### usage 
#### step1 : add Event Parsers in your Lexer:

```dart
        ...
        ///Event-Examples
        'include-pure-jamv-attr': [
          JParse.eventOnStateWillStart(),
          JParse.eventOnStateWillRestart(),
          JParse.include('jamv-attr-align'),
          JParse.eventOnConditionInclude('for some tags text-align is not necessary', [JParse.include('jamv-attr-text-align')]),
          //JParse.include('jamv-attr-text-align'),
          JParse.eventOnRuleMissed('not align'),
          JParse.include('jamv-attr-pos'),
          JParse.eventOnCondition('condition true to jump new states',
              [MATCHED(LEAVE: 'pop'), POP]),
          JParse.include('jamv-attr-size',
              replaceAllNewStates: [MATCHED(), POP]),
          JParse.eventOnStateWillEnd()
        ],
        ...
```
**LIFECYCLE EVENT** only need to appear in a state, order and times are skipped, they are:

- `JParse.eventOnStateWillStart`
    
- `JParse.eventOnStateWillRestart`
    
- `JParse.eventOnStateWillEnd`

others will be invoked in order and by times.

For `MATCHED(String ENTER,String LEAVE)` state Action will cause `onRuleMatched` function in a **FullEventListener**

#### step2 : Implements RawEventDispatcher or extends FullEventListener
here is definations:

```dart
abstract class RawEventDispatcher {
  bool dispatchEvent(
      Token eventType, String eventFlag, String stateName, Context context);
}

/// You can directly extends RawEventDispatcher and define your own lifecycle.
abstract class FullEventListener extends RawEventDispatcher {
  onStateWillStart(String stateName);
  onStateWillRestart(String stateName);
  onStateWillEnd(String stateName);
  onRuleWillStart(String ruleStartFlag);
  onRuleMissed(String ruleMissedFlag);
  onRuleMatched(String stateName, Context context,
      {String enter, String leave});
  bool onCondition(String eventFlag);
  bool onConditionInclude(String eventFlag);
  ...
}
```

#### step3 : config set your event listener or dispatcher

```dart
LexerMain
..load(..)
..config = {
      ..
      'eventDispatcher': MyEventListener(),
      'debuggable': false,
    }
```

## 2. Auto Completing

Now try to use 'Constant's and 'Enum's to takeplace of some Regular Expression Case

### usage of constants

```dart
 JParse.constants([['a','b','c',''],['1','2']], Name),
 // the same as
 JParse(r'(a|b|c)?(1|2)', Name)
```

constant value `''` will change to symbol `?` so don't do this:

```dart
JParse.constants([[.. ''],[.. ''],[.. '']])
/// the same as
JParse.empty()
```

### strict mode

```dart
/// strict
JParse(r'(a|b|c)?(1|2)', DynamicToken.fromEnum(['a1','a2','b1','b2','c1','c2', '1','2'],named: Name));

/// not strict but auto completing system work fine
JParse(r'(\w)?(1|2)', DynamicToken.fromEnum(['a1','a2','b1','b2','c1','c2', '1','2'],named: Name));

/// strict, auto completing system will enum tokens who had matched this rule.
JParse(r'(\w)?(1|2)', DynamicToken.asEnum(Name));
```

### usage of constingroups

Still you don't want all words to match `r(\w)?(1|2)`
use constant in a group, expand from List into a pattern part where `(..)` appears.

```dart
/// simple strict but too much words need to enum
JParse.constingroups(r'((..)(1|2))',[['a','b','c','']] DynamicToken.fromEnum(['a1','a2','b1','b2','c1','c2', '1','2'],named: Name));

/// Better when depart
var LETTER_SL = ['a','b','c',''];
var NUMBER_SL = ['1','2'];
/// as one combination however cannot enum words from constants
JParse.constingroups(r'((..))(="\d+")', [LETTER_SL, NUMBER_SL],[DynamicToken.asEnum(Name), null, null, VALUE]); 

/// Good for both of words typing and auto completing system.
/// a,b,c,1,2 these values only appear once
JParse.constingroups(r'(..)(="\d+")', [LETTER_SL, NUMBER_SL],
/// take care of this, constant in groups will not match only one token, instead match each as a single token
[DynamicToken.fromEnum(LETTER_SL,named: NAMEL),
DynamicToken.fromEnum(NUMBER_SL, named: NAMEN),
// here VALUE is not wrapped by DynamicToken.asEnum(), in strict mode will match nothing, instead unstrict mode match all VALUE user has given, even not in this state.
VALUE
])

```
### Warning:

You should always make sure Tokens all linked matches the pattern, or else words lost from token system will cause unknown problems.

use `null` to take place already matched token if necessary.

### Here is an example:

```dart
'test/lexers/library/JamvAttrLib.dart'
class JamvAttrLib extends LibraryLexer {
    final AlignSV = 'align';
    final AlignValuesSL = ['left', 'right', 'center'];
    ...
    @override
    Map<String, List<JParse>> commonparses(
          Map<String, List<JParse>> currentCommon) => {
        ...
        'jamv-attr-align': [
          JParse.constingroups(r'(' + AlignSV + r')(=")(..)(")', [
            AlignValuesSL
          ], [
            DynamicToken.fromEnum([AlignSV], named: Attr),
            DynamicToken.asEnum(Vstart),
            DynamicToken.fromEnum(AlignValuesSL, named: ValuePart),
            DynamicToken.asEnum(Vend),
          ], [
            POP
          ]),
          JParse.constants([AlignValuesSL], Attr, [POP])
        ],
    }
}
```

`align`,`left`,`right`,`center` these words will enter auto completing system.

## 3.Library Lexer

Even though we can use JParse.lexer to contain another lexer in runtime.
However each lexer's own parsing definations are isolated and will not give it to a nested lexer, this cause context loosing problems.

Library Lexer only need to complement `commonparses` and this cause a single-lined context, root lexer don't need `BREAK` to get back.

Later on we will optimize the loading phase to ignore function nesting.

### usage

when you test libraries, you can give a `libraryRootState` to tell where to start.
OrElse library don't work alone without root Lexer.

```dart

 LexerMain lexer = LexerMain.load(libraries: [
    JamvAttrOnceLib(),
    JamvAttrLib(),
  ], 
    //root: MyTestedLexer()
  )
    ..libraryRootState('include-jamv-attr')
    ..config = {
      'stateWillListTokens': [Attr, Token.Error],
      'savingRuntimeContext': true,
      'willAutoCompleteErrors': true,
      'eventDispatcher': MyEventListener(),
      'debuggable': true,
      'enumStrict': false
    }
    ..dependencyAnalyze();

    print(lexer.pretty(..));
    lexer.configPrint();
    
```

library load from bottom to top, so `JamvAttrOnceLib` overrides `JamvAttrLib`, `dependencyAnalyze()` and `configPrint()` will give you more message.

Now let's try auto completing by `List<String> autoCompleting(String text, String statename)`, the error message and unfinished words need you to collect.(From Event System or List `<`UnprocessedToken`>`