#lang br
(require "lexer.rkt" brag/support rackunit)
(require racket)
(require "lexer.rkt")

(define (lex str)
  (apply-lexer aql-lexer str))

(lex "FOR _x IN 1 OUTBOUND 0.12e4")
(lex "1e4")
(lex ".1")
(lex "0.1")
(lex ".1e4")
(lex "2.5e5")
(lex "1e+3")
(lex "1e-3")
(lex "1.2e-3")

(lex "@hello")
(lex "@@hello")
