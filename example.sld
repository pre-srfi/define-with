(define-library (example)
  (export factor add)
  (import (except (scheme base) define)
          (rename (define-with) (define-with define)))
  (begin

    (define factor (make-parameter 1)
      (with (doc "Scaling factor to use for all numerical operations.")
            (foo (speed 0))))

    (define (add a b)
      (with (doc "Add two numbers."
                 ""
                 "Takes the global scaling factor into account.")
            (optimize (speed 0))
            (test 1 2 => 3))
      (define (scale x)
        (with (doc "Scale the given number."))
        (* (factor) x))
      (scale (+ a b)))

    (define (append/no-with . xs)
      (apply append xs))

    (define (append/with . xs)
      (with (doc "Like append, but with extra crunch."))
      (apply append xs))))
