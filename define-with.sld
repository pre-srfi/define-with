(define-library (define-with)
  (export declarations declaration-ref define-with with)
  (import (scheme base))
  (begin

    (define declarations '())

    (define (add-declarations! name more-declarations)
      (let ((pair (or (assoc name declarations)
                      (let ((pair (cons name '())))
                        (begin (set! declarations (cons pair declarations))
                               pair)))))
        (set-cdr! pair (append (cdr pair) more-declarations))
        (cdr pair)))

    (define (declaration-ref name which)
      (let ((pair (assoc name declarations)))
        (and pair (let ((pair (assoc which (cdr pair))))
                    (and pair (cdr pair))))))

    (define-syntax with
      (syntax-rules ()
        ((_ . ignored) (syntax-error "invalid use of with"))))

    (define-syntax define-with
      (syntax-rules (with)
        ;; Variable
        ((_ name value (with more-declarations ...))
         (begin (define name value)
                (add-declarations! 'name '(more-declarations ...))))
        ((_ name value)
         (define name value))
        ;; Procedure with dotted tail
        ((_ (name args ... . tail) (with more-declarations ...) body ...)
         (begin (define (name args ... . tail) body ...)
                (add-declarations! 'name '(more-declarations ...))))
        ((_ (name args ... . tail) body ...)
         (define (name args ... . tail) body ...))
        ;; Procedure without dotted tail
        ((_ (name args ...) (with more-declarations ...) body ...)
         (begin (define (name args ...) body ...)
                (add-declarations! 'name '(more-declarations ...))))
        ((_ (name args ...) body ...)
         (define (name args ...) body ...))))))
