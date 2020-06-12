#lang br/quicklang
(require "lexer.rkt" brag/support)

(provide make-tokenizer)

(define (make-tokenizer port [path #f])
  (port-count-lines! port)
  (lexer-file-path path)
  (define (next-token)
    (aql-lexer port))
  next-token)
