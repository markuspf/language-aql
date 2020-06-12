#lang br
(require brag/support)

(provide aql-lexer)
; keywords are case insensitive
(define-lex-trans keyword
  (λ(stx)
    (syntax-case stx ()
      [(_ str)
       (with-syntax ([((DLETT . ULETT) ...)
                      (for/list [(x (in-string (syntax->datum #'str)))]
                        (cons (char-downcase x) (char-upcase x)))]) 
         #'(:seq (:or DLETT ULETT) ...))])))

(define-lex-abbrevs
  [lex:underscore (:or #\_)]
  [lex:letter (:or (:/ #\a #\z) (:/ #\A #\Z))]
  [lex:zero (:or #\0)]
  [lex:nonzero-digit (:/ #\1 #\9)]
  [lex:digit (:/ #\0 #\9)]
  [lex:number(:or lex:zero (:: lex:nonzero-digit (:* lex:digit)))]
  [lex:ident-char (:or lex:letter lex:digit lex:underscore)]
  [lex:whitespace (:or #\newline #\return #\tab #\space #\vtab)]
  [lex:comment (:: (:* lex:whitespace) "comment" (:* (:~ #\;)) #\;)]
  [lex:stringlett (:or (:: #\\ any-char) (:: #\\ lex:digit lex:digit lex:digit) (:~ #\" #\newline))]
  [lex:ident (:or (:: lex:letter (:* lex:ident-char))
                  (:: (:+ lex:underscore) (:+ lex:letter) (:* lex:ident-char)))]
  )

(define aql-lexer
  (lexer-srcloc
   [(:+ lex:whitespace) (token lexeme #:skip? #t)] 
   [(eof) (return-without-srcloc eof)]
   ; TODO: Store locations of comments?
   [(from/to "//" "\n") (token lexeme #:skip? #t)]             
   [(from/to "/*" "*/")
    (token lexeme #:skip? #t)]
   ; keywords
   [(keyword "FOR")       (token 'FOR)]     
   [(keyword "LET")       (token 'LET)]
   [(keyword "FILTER")    (token 'FILTER)]
   [(keyword "RETURN")    (token 'RETURN)]
   [(keyword "COLLECT")   (token 'COLLECT)]
   [(keyword "SORT")      (token 'SORT)]
   [(keyword "LIMIT")     (token 'LIMIT)]
   [(keyword "DISTINCT")  (token 'DISTINCT 'DISTINCT)]
   [(keyword "AGGREGATE") (token 'AGGREGATE)]
   [(keyword "ASC")       (token 'ASC)]
   [(keyword "DESC")      (token 'DESC)]
   [(keyword "NOT")       (token 'NOT)]
   [(keyword "AND")       (token 'AND)]
   [(keyword "OR")        (token 'OR)]
   [(keyword "IN")        (token 'IN)]
   [(keyword "INTO")      (token 'INTO)]
   [(keyword "WITH")      (token 'WITH)]
   [(keyword "REMOVE")    (token 'REMOVE)]
   [(keyword "INSERT")    (token 'INSERT)]
   [(keyword "UPDATE")    (token 'UPDATE)]
   [(keyword "REPLACE")   (token 'REPLACE)]
   [(keyword "UPSERT")    (token 'UPSERT)]
   [(keyword "GRAPH")     (token 'GRAPH)]
   [(keyword "SHORTEST_PATH") (token 'SHORTEST-PATH)]
   [(keyword "K_SHORTEST_PATHS") (token 'K-SHORTEST-PATHS)]
   [(keyword "OUTBOUND")  (token 'OUTBOUND)]
   [(keyword "INBOUND")   (token 'INBOUND)]
   [(keyword "ANY")       (token 'ANY)]
   [(keyword "ALL")       (token 'ALL)]
   [(keyword "NONE")      (token 'NONE)]
   [(keyword "LIKE")      (token 'LIKE)]
   [(keyword "OPTIONS")   (token 'OPTIONS)]
   [(keyword "SEARCH")    (token 'SEARCH)]
   
   ; literals
   [(keyword "NULL")      (token 'NULL 'aql-null)]
   [(keyword "TRUE")      (token 'TRUE 'aql-true)]
   [(keyword "FALSE")     (token 'FALSE 'aql-false)]
   ; operators 
   ["=~" (token 'REGEX-MATCH)]
   ["!~" (token 'REGEX-NON-MATCH)]
   ["==" (token 'EQUALS)]
   ["!=" (token 'NOT-EQUALS)]
   [">=" (token 'GREATER-OR-EQUAL)]
   [">"  (token 'GREATER)]
   ["<=" (token 'LESS-OR-EQUAL)]
   ["<"  (token 'LESS)]
   ["="  (token 'ASSIGN)]
   ["!"  (token 'NOT)]
   ["&&" (token 'AND)]
   ["||" (token 'OR)]
   ["+"  (token 'PLUS 'plus)]
   ["-"  (token 'MINUS 'minus)]
   ["*"  (token 'MULT 'times)]
   ["/"  (token 'DIV)]
   ["%"  (token 'MOD)]
   ["?"  (token 'QUESTION)]
   ["::" (token 'SCOPE)]
   [":"  (token 'COLON)]
   [".." (token 'RANGE)]
   ; punctutation
   ["."  (token 'DOT)]
   [","  (token 'COMMA)]
   ["("  (token 'LPARENS)]
   [")"  (token 'RPARENS)]
   ["{"  (token 'LCURL)]
   ["}"  (token 'RCURL)]
   ["["  (token 'LSQUARE)]
   ["]"  (token 'RSQUARE)]
   ["@"  (token 'AT)]

   [(:: "@" lex:ident) (token 'BIND (string->symbol lexeme))]
   [(:: "@@" lex:ident) (token 'COLLECTION-BIND (string->symbol lexeme))] 
   
   ; identifier
   [lex:ident (token 'IDENT (string->symbol lexeme))]

   ; string literals
   [(from/to "`" "`") (token 'STRING (trim-ends "`" lexeme "`"))]
   [(from/to "\"" "\"") (token 'STRING (trim-ends "\"" lexeme "\""))]
   [(from/to "´" "´") (token 'STRING (trim-ends "´́" lexeme "´"))]

   ; integer literals
   [lex:number (token 'INTEGER (string->number lexeme))] 

   ; float literals
   [(:: (:? lex:number) (:or
                         (:: #\.
                             (:+ lex:digit))
                         (:: #\.
                             (:+ lex:digit)
                             (:or #\e #\E)
                             (:? (:or #\- #\+))
                             (:+ lex:digit))
                         (:: (:or #\e #\E)
                             (:? (:or #\- #\+))
                             (:+ lex:digit))))
    (token 'DOUBLE (string->number lexeme))]
   ))
