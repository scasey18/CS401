#lang racket	   	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
; Project 4 -- A church compiler -- Scheme -> Lambda	   	
;
; The goal of this project is to write a functional compiler that transforms 
; code in an input language (a significant subset of Scheme, roughly) into 
; equivalent code in the lambda calculus. Details below. 
;	   	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  

(provide churchify church-encode) 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;	   	
; Honor pledge (please write your name.)	  
;	   	
; I **Samuel Casey** have completed this code myself, without	  
; unauthorized assistance, and have followed the academic honor code.	   	
;	   	
; Edit the code below to complete your solution.	   	
;	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	   	
	  

;; Your task is to compile the input language:	   	
; 
; e ::= (letrec ([x (lambda (x ...) e)]) e)	   	
;     | (let ([x e] ...) e)	  
;     | (lambda (x ...) e) 
;     | (e e ...)	   	
;     | x 
;     | (and e e) | (or e e) 
;     | (if e e e) 
;     | (prim e) | (prim e e)	   	
;     | datum	  
; datum ::= nat | (quote ()) | #t | #f
; nat ::= < satisfies natural? > 
; x ::= < satisfies symbol? >	   	
; prim ::= < is a primitive operation in: >
(define prims '(+ * - = add1 sub1 cons car cdr null? not zero?))

;; To the lambda calculus, output language:	   	
; 
; e ::= (lambda (x) e) 
;     | (e e) 
;     | x
; 

;; Only 501 students are required to support '=, '-, and 'sub1 

;; The input language should behave as it does evaluated by Racket, 
;; however, you do not need to handle non-booleans being treated as #t	   	
;; at guard expressions, or at and/or expressions.	  

;; The grammar above does not include variadic lambdas or apply.

;; No test will produce a negative number, input '(- 1 3) is undefined.	   	
	   	
;; Implementing your church encodings and these primitive operations,	  
;; you are free to look up standard church encodings online	   	
;; (e.g., on wikipedia), as long as you understand them, but are not
;; allowed to use an existing church-encoder or to get help in writing 
;; your church compiler itself.	   	


(define (prim? prim)	  
  (if (member prim prims) #t #f))


; Note how churchify is called from church-encode below.	   	
; To make output less verbose, intead of inserting a church encoding,	  
; e.g., for 'car, at each occurance of a constant or prim-op,	  
; it's recommended you bind them to a variable prefixed with 'church:,
; e.g., 'church:car, and then use this function to generate that name 
; from the name of the primitive operation. 
; (churchify-prim 'car) => 'church:car	   	
(define (churchify-prim prim) 
  (string->symbol (string-append "church:" (symbol->string prim))))

(define (natHelp nat)
  (cond
    [(eq? nat 1) `(f x)]
    [else `(f ,(natHelp (- nat 1)))]
    )
  )

; This is your main compiler transformation rewriting exp -> exp	  
(define (churchify e)
  (match e 
    ; Tagged expressions	   	
    [`(let ([,xs ,e0s] ...) ,e1)
     ; A common idiom will be to make a tail call.
     ; In this case, if xs is '(a b), the recursive call
     ; to churchify should perform the needed currying.	   	
     ; Watch out for forming infinite loops!
     (churchify `((lambda ,xs ,e1) . ,e0s))] 

    [`(lambda () ,e0) 
     `,(churchify e0)]	  
    [`(lambda (,x) ,e0)	   	
     `(lambda (,x) ,(churchify e0))]	  
    [`(lambda (,x . ,rest) ,e0)	   	
     `(lambda (,x) ,(churchify `(lambda (,@rest) ,e0)))]	  

    ;; TODO: are there more match cases to add?

    [`(letrec ([,f ,lam]) ,body)
     (churchify `(let ([,f (Y-comb (,f ,lam))]) ,body))]
    ; (churchify `(let ([,f (Y-comb (lambda (,f) ,lam))]) ,body))
    [`(and ,e0 ,e1)
     (churchify `(if ,e0 ,e1 #f))]
    [`(if ,guard ,iftrue ,iffalse)
     `,(churchify `(,guard (lambda (_) ,iftrue) (lambda (_) ,iffalse)))]
    
    ; Variables
    [(? symbol? x)
     (if (prim? x)
         (churchify-prim x)
         x
         )]	

    ; Datums	   	
    [(? natural? nat)	   	
     (cond
       [(eq? nat 0) `(lambda (f) (lambda (x) x))]
       [else `(lambda (f) (lambda (x) ,(natHelp nat)))]
       )]
    
    [''()	   	
     `(lambda (when-cons) (lambda (when-null) (when-null when-null)))]
    
    [#t	  
     `(lambda (tt) (lambda (ft) (tt tt)))]	  
    [#f
     `(lambda (tt) (lambda (ft) (ft ft)))] 

    ; Untagged application (has to go last)	   	
    [`(,fun)
     `,(churchify fun)]	   	
    [`(,fun ,arg)
     `(,(churchify fun) ,(churchify arg))] 
    [`(,fun ,arg . ,rest)	   	
     `,(churchify `((,fun ,arg) ,@rest))]))	  

;; This is the top-level church encoder 
;; You might find it convenient to define your church:prim functions here,	   	
;; as illustrated, but this also means testing at the REPL will be easier	  
;; by calling churchify directly and seeing that its output looks correct.
(define (church-encode expr) 
  (define Y-comb `(lambda (y) (lambda (f) (f (lambda (x) (((y y) f) x))))))
  (define church:null? `(lambda (p) (p (lambda (a b) #f) (lambda (_) #t))))	
  (define church:cons `(lambda (a b) (lambda (when-cons) (lambda (when-null) (when-cons a b))))) 
  (define church:car `(lambda (lst) ((lst (lambda (h t) h)) (lambda (x) x))))
  (define church:cdr `(lambda (lst) ((lst (lambda (h t) t)) (lambda (x) x))))
  ; Because these are all passed through churchify, we do not need to curry 
  (define church:add1 `(lambda (n0) (lambda (f x) (f ((n0 f) x))))) 
  ;(define church:sub1 `TODO12) bonus
  (define church:zero? `(lambda (n) (n (lambda (x) #f) #t)))
  (define church:+ `(lambda (n) (lambda (m) (lambda (f) (lambda (x) ((n f) ((m f) x)))))))
  ;(define church:- `TODO15) bonus
  (define church:* '(lambda (n) (lambda (m) (lambda (f) (lambda (x) ((n (m f)) x))))))	  
  ;(define church:= `TODO17) bonus
  (define church:not `(lambda (p) (lambda (a) (lambda (b) (p b a)))))	  
  (churchify 
   `(let ([Y-comb ,Y-comb] 
          [church:null? ,church:null?]	   	
          [church:cons ,church:cons]	  
          [church:car ,church:car]
          [church:cdr ,church:cdr]
          [church:add1 ,church:add1] 
          ;[church:sub1 ,church:sub1] bonus
          [church:+ ,church:+]	   	
          ;[church:- ,church:-]	bonus
          [church:* ,church:*]	  
          [church:zero? ,church:zero?]	   	
          ;[church:= ,church:=]	  bonus
          [church:not ,church:not]
          )
      ,expr))) 


