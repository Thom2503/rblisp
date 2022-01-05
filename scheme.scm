(define r 10)
(* 3.14 (* r r))

(define square
	(lambda (x)
		(* x x)))

(square 4)

(quote (a b c))

(if (> r 1)
		(square r)
		(* 3.14 (* r r)))

(define x 5)
(set! x 6)

(quote x)

(begin (define y 5) (+ y y))
