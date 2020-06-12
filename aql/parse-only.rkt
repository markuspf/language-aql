#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(provide (rename-out [parser-only-mb #%module-begin]))

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module basic-parser-mod aql/parse-only
       #,parse-tree)))
(module+ reader (provide read-syntax))

(define-macro (parser-only-mb PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
