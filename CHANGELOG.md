## 1.1.0
* support **DynamicToken** which you can define your own Token.
* support **DynamicToken.from** to create from a exist Token like `DynamicToken.from(Token.Text)`, and they are equal in operator '=='
* if exist `.token` will return a Token on DynamicToken or else return **Token.Dynamic**
* example now is easier to learn, you can try your own Domain Specific Language on Dart or Flutter now!

## 1.0.2+1
* Add two utils tools function "RegstrInvoke" && "groupPureOrLinkCapture" for easy from string to call a function.
    
* Optimize implementation of ON && ONPOP function in core parsing block using the newly added function *RegstrInvoke*
    
* Try to build simple RegRules from RegstrInvoke to Dart Function for a short DSL instead of using Lexer.The latter one is too heavy.
## 1.0.0
    
* support Lexer parse inside Lexer by adding Parse.lexer factory constructor.

* add common parses rules which provide a public parsing rules.
    
* add pretty stingify method to make unprocessed tokens processed.
    
* add more POP methods to support nesting Lexer Parsing.

* add more tests.
    
## 0.1.0+1

* fix nextState(or newState) prop lost in GroupParse.

* add tutoring doc.
    
* add lexers/senior/dart_import.dart only for senior use show and test.

* add POPTO function in utils/poprouter.dart