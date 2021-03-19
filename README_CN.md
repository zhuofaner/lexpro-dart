# lexpro 2
[<img src="https://pic1.zhimg.com/v2-1570b618531c9b0bcf6d273d5fe88cfa_1440w.jpg" width="800"/>](https://zhuanlan.zhihu.com/p/356951579)

## 前言：

这是我发布的[lexpro2.0](https://pub.dev/packages/lexpro)版本的ReadMe文件，包含了大量新特性，抛弃繁琐的 `lex / yacc ->ast` 桌面端编程语言流程，支持符号解析，语法树生成，代码着色，代码修复，自动补全，静态分析，多种调试选项，以及为便于大型规则集拆分而创建的库Lexer。

适应于短平快，DSL 符号多变以及 `DSL 内嵌 DSL` 语言的场景，依赖的文件超级小，自己设计规则自己调试，非常适合我本身正在做的项目（嗯，量身定制）

正如新设计的 logo 一样,lexpro2是领域特定语言制造 (DomainSpecificLanguageProducer) 组合包 (ALL IN ONE)。

## New Feature 新特性

### here is new features in 2.1.0
### 这是2.1版本的新重要特性

* support **Templates** extends JParse

* 支持模板匹配
    
> for better match for split text auto completing.  
> 模板匹配是为了分隔文字的匹配而优化
  
  *
    - use `$`、`$1`、`$2` .. for variable injection in a template string.
    
    - 模板匹配中使用美元符号 `$` 代表变量，`$`表示第一个变量，`$1`表示第二个，以此类推。
    
    - support `variables extracting` from exited `tokens` or matches a `pattern` from the given split text.

    - 支持将变量匹配已知符号（含已知枚举 和做为枚举两类枚举符号），或者从分隔文本中匹配正则表达式来提取。
  
    - support extracting failed basic variable value

    - 如果以上匹配值都为空，支持设置一个默认值
    
    - if `enumnone` not given and extracting failed to match anyone, template rule with symbol `$` ignored.

    - 如果没有默认值变量值为空，则该条含有变量注入的模板规则被跳过，不含变量的规则不受影响。

* support `splitAutoCompleting` which can match split words that `autoCompleting` can not match
    
* 自动补全现在支持将目标文本分隔成几个部分进行全量匹配（分隔的几个部分都要有所匹配）

    - `wd40` split in letters `w` `d` `4` `0` **matches** width_40、width="40"、maxWidth_40、minWidth_40、 maxWidth="40"、minWidth="40"
    
    - 它可以匹配 `wd40` 这种非完整连接的单词和数字的组合， 将其应用于诸如 `width_$`，`minWidth="$"` 的模板规则中，从而完成自动补全。

    - if `length="400"` exists, wd40 also matches width_400

    - 也可以通过设置`$` 匹配 DynamicToken.asEnum(Number)来代入用户输入过的数字，比如这里的 40 也匹配 400。

注意：模板规则应被设置成从当前符号位置匹配至结尾
比如有五个符号位 Attr、Number、Number、Number、Number
在四个位置的匹配规则应该如下 `width_$_0_$_0`、`_$_$_$_$`、`_0_0_0`、`_0_0`、`_0`

### here is features in 2.0.0

### 这是2.0版本的重要特性

* support **Event System** to build your AST or directly do your stuff.
* 支持用来构建语法树或者直接做你想做的操作的 **事件机制**
  * support self defined `LIFE_CYCLE`s and `onCondition`s Events
    * 支持可以自定义的`生命周期函数`和各种基于`条件判断` 的事件
* in `onRuleMatched` function will return a `Context` including newly added Tokens.
    * 在`规则匹配`函数中返回一个叫`上下文`的类型，它包含了新增加的字符
* support build Parsers from known **Constants**
* 支持添加从已知的**常量**创建的解析规则
* support DynamicToken create from **Enums** or **asEnum** to collect from parsed known message.
* 动态符号现在支持从**已知枚举**和**作为枚举**来创建动态符号，后者使用上下文来自动推断枚举值。
* support create pure **Library Lexer** only loaded in root Lexer's common part.
* 支持`库Lexer`，它会加载到`根Lexer` 的公共规则部分。
* support parse from a configgable **LexerMain** with a **Library Chain**
* 从一个 `库Lexer` 链中配置到`LexerMain`,并用其对字符进行解析
    * support static `dependencyAnalyze` with no parsers running.
    * 支持非运行态的静态依赖分析
* support **Auto Completing** from **Constants and Enums** reuse a cached runtime context.
(*not tested launched from other than **Lexer Main**)*

## 1.Event System 事件机制

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

## 2. Auto Completing 自动补全

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

## 3.Library Lexer 库Lexer

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