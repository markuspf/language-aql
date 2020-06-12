#lang brag

aql-query: [ aql-with ] aql-pure-query

aql-pure-query: [ aql-statement ] aql-final-statement 
 
aql-collection-bind-param: COLLECTION-BIND
aql-bind-param: BIND

aql-with: /WITH aql-collection-bind-param [/COMMA aql-collection-bind-param]*

aql-statement: aql-for
             | aql-let
             | aql-filter
             | aql-collect
             | aql-sort
             | aql-limit
             | aql-remove
             | aql-insert
             | aql-update
             | aql-replace
             | aql-upsert

aql-final-statement: aql-return
                   | aql-remove
                   | aql-insert
                   | aql-update
                   | aql-replace
                   | aql-upsert 

; FOR
aql-search: /SEARCH aql-expression

aql-options: /OPTIONS aql-object

aql-graph-direction: ANY | INBOUND | OUTBOUND
aql-prune: /PRUNE aql-expression
aql-named-graph: /GRAPH aql-bind-param
               | /GRAPH STRING
aql-edge-collection: [ aql-graph-direction ] STRING
aql-edge-collections: aql-edge-collection ( COMMA aql-edge-collection )*
aql-graph-subject: aql-edge-collections
                 | aql-named-graph

aql-traversal: aql-expression [ aql-prune ] [ aql-options ]

aql-shortest-path: aql-graph-direction /SHORTEST-PATH aql-expression /TO aql-expression aql-graph-subject [ aql-options ]

aql-k-shortest-paths: aql-graph-direction /K-SHORTEST-PATHS aql-expression /TO aql-expression aql-graph-subject [ aql-options ]

aql-for: /FOR aql-ident /IN aql-expression [ aql-search ] [ aql-options ]
       | /FOR aql-ident /IN aql-traversal
       | /FOR aql-ident /IN aql-shortest-path
       | /FOR aql-ident /IN aql-k-shortest-paths

; LET
aql-variable-assign: aql-ident /ASSIGN aql-expression
aql-variable-assigns: aql-variable-assign ( /COMMA aql-variable-assign )*
aql-let: /LET aql-variable-assigns

; FILTER
aql-filter: /FILTER aql-expression

; COLLECT
aql-ident-list: IDENT ( /COMMA IDENT )*

aql-collect: /COLLECT WITH COUNT INTO IDENT [ aql-options ]
           | /COLLECT aql-variable-assigns /WITH /COUNT /INTO IDENT [ aql-options ]
           | /COLLECT AGGREGATE aql-variable-assigns [/INTO [ IDENT | aql-variable-assign ] ] [ aql-options ]
           | /COLLECT aql-variable-assigns AGGREGATE [/INTO [ IDENT | aql-variable-assign ] ] [ aql-options ]
           | /COLLECT aql-variable-assigns
           | /COLLECT aql-variable-assigns [ /INTO IDENT ] [ KEEP aql-ident-list ] [ aql-options ] 

; SORT
aql-sort-item: aql-expression [ ASC | DESC | aql-simple-value ]
aql-sort: SORT aql-sort-item ( /COMMA aql-sort-item )*

; LIMIT
aql-limit: /LIMIT INTEGER ( /COMMA INTEGER )*

aql-in-or-into-collection: ( /IN | /INTO ) aql-collection-reference

aql-collection-reference: IDENT
                        | STRING
                        | aql-collection-bind-param
; INSERT
aql-insert: /INSERT aql-expression aql-in-or-into-collection aql-options

; REMOVE
aql-remove: /REMOVE aql-expression aql-in-or-into-collection aql-options

; UPDATE
aql-update: /UPDATE aql-expression aql-in-or-into-collection aql-options
          | /UPDATE aql-expression /WITH aql-expression aql-in-or-into-collection aql-options

; REPLACE
aql-replace: /REPLACE aql-expression aql-in-or-into-collection aql-options
           | /REPLACE aql-expression /WITH aql-expression aql-in-or-into-collection aql-options

; UPSERT
aql-upsert: /UPSERT aql-expression /INSERT aql-expression /UPDATE aql-expression aql-in-or-into-collection aql-options
          | /UPSERT aql-expression /INSERT aql-expression /REPLACE aql-expression aql-in-or-into-collection aql-options

; RETURN
aql-return: /RETURN [ DISTINCT ] aql-expression

; expression
aql-range: aql-expression /RANGE aql-expression

aql-expression: aql-expression-or
              | aql-operator-ternary
              | aql-reference
              | aql-range

aql-operator-unary: PLUS aql-expression
                  | MINUS aql-expression
                  | NOT aql-expression
aql-quantifier: ALL | ANY | NONE
aql-quantified-operator-binary: EQUALS
                              | NOT-EQUALS
                              | LESS
                              | GREATER
                              | LESS-OR-EQUAL
                              | GREATER-OR-EQUAL
                              | IN


aql-operator-binary-relation: EQUALS
                            | NOT-EQUALS
                            | LESS
                            | GREATER
                            | LESS-OR-EQAL
                            | GREATER-OR-EQUAL
                            | IN
                            | NOT IN
                            | NOT LIKE
                            | NOT REGEX-MATCH
                            | NOT REGEX-NON-MATCH
                            | LIKE
                            | REGEX-MATCH
                            | REGEX-NON-MATCH
                            | aql-quantifier aql-quantified-operator-binary
                            | ALL NOT IN | ANY NOT IN | NONE NOT IN

aql-expression-atom   : aql-value | aql-reference
aql-expression-factor : [ aql-expression-atom ]
aql-expression-term   : aql-expression-factor ( ( MULT | DIV | MOD ) aql-expression-factor )*
aql-expression-arith  : aql-expression-term ( ( PLUS | MINUS ) aql-expression-term )* 
aql-expression-rel    : [ NOT ] aql-expression-arith [ aql-operator-binary-relation aql-expression-arith ]
aql-expression-and    : aql-expression-rel ( /AND aql-expression-rel )*
aql-expression-or     : aql-expression-and ( /OR aql-expression-and )*

aql-operator-ternary  : aql-expression /QUESTION [ aql-expression ] /COLON aql-expression

; Arrays
aql-array-elements: aql-expression ( /COMMA aql-expression )*
aql-array: /LSQUARE [ aql-array-elements ] /RSQUARE

; Objects
aql-object-element: IDENT
                  | IDENT /COLON aql-expression
                  | aql-bind-param /COLON aql-expression
                  | /LSQUARE aql-expression /RSQUARE /COLON aql-expression
aql-object-elements: aql-object-element ( /COMMA aql-object-element )*
aql-object: /LCURL [ aql-object-elements ] /RCURL

aql-compound-value: aql-array | aql-object

aql-expression-or-query: aql-expression | aql-pure-query
aql-function-call-arguments: aql-expression-or-query ( COMMA aql-expression-or-query )*

aql-function-name: IDENT ( SCOPE IDENT )*
aql-function-call: aql-function-name /LPARENS [ aql-function-call-arguments ] /RPARENS

; Reference
aql-array-filter: ( MULT )+ 

aql-reference: aql-ident
             | aql-compound-value
             | aql-bind-param
             | aql-function-call
             | /LPARENS aql-expression-or-query /RPARENS
             | aql-reference DOT IDENT
             | aql-reference DOT aql-bind-param
             | aql-reference LSQUARE aql-expression RSQUARE
             | aql-reference LSQUARE aql-array-filter [aql-filter] [aql-limit] RSQUARE

aql-integer : INTEGER
aql-double  : DOUBLE
aql-bool    : TRUE | FALSE
aql-string  : STRING
aql-null    : NULL
aql-value   : aql-integer | aql-double | aql-bool | aql-string | aql-null

aql-simple-value: aql-value
                | aql-bind-param

aql-ident: IDENT
