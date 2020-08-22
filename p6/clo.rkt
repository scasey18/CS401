#lang racket	  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	  
;
; Project 6 -- closure conversion -- implementing first-class functions
; 
; The goal of this project is to write a functional compiler pass for bottom-up closure conversion.	  
; Bottom-up closure conversion implements lambdas by turning them into a top-level definition 
; of a non-higher-order (C-style) function and a closure-creation point that pairs this function	   	
; with values for its free variables in a vector. Each (lambda (x y) ...) should turn into a	  
; top-level proc (proc (lam5 env5 x y) (let ([z (vector-ref env5 1)]) ...)) with an added parameter
; for its environment to be passed to it (this example shows one free variable, z), and a closure
; (vector lam5 z) which saves this top-level function-pointer together with its free variables in some order. 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide prim? 
         closure-convert)


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


	   	
;;; Input language; CPS
; ce ::= (let ([x (prim-op ae ...)]) ce)	  
;     |  (ae ae ...) 
;     |  (if ae ce ce)	   	
; ae ::= x | n | (lambda (x ...) ce) 
; x is a symbol?  (possibly 'halt)
; n is a number?	   	
; prim-op is a prim?


(define (prim? op) 
  (if (member op '(< = <= + - * vector vector-ref))
      #t
      #f))	  


(define (closure-convert e) 
  ; Bottom up takes an expression and current list of procs, and returns a list	  
  ; `(,e+ ,freee+ ,procs+) of the converted expression, its free variables, and a possibly-updated list of procs 
  (define (bottom-up e procs)	  
    (match e	   	
      [`(let ([,x ,rhs]) ,bdy)	  
       (match-define `(,rhs+ ,free0 ,procs0) 
         (bottom-up rhs procs))	   	
       (match-define `(,bdy+ ,free1 ,procs1)	
         (bottom-up bdy procs0))	  
       `((let ([,x ,rhs+]) ,bdy+) 
         ,(set-union free0 (set-remove free1 x))
         ,procs1)]	  
      ; TODO: Add your other cases here
      [(? number? n) `(,n ,(set) ,procs)]
      [(? symbol? x) `(,x ,(set x) ,procs)]
      [`(if ,ae ,ce1 ,ce2)
       (match-define `(,rhs+ ,free0 ,procs0) 
         (bottom-up ce1 procs))	   	
       (match-define `(,bdy+ ,free1 ,procs1)	
         (bottom-up ce2 procs0))	  
       `(,e
         ,(set-union free0 free1)
         ,procs1)]
      ;similar to let
      [`(lambda ,xs ,bdy)
       (match-define `(,bdy+ ,free+ ,procs+) (bottom-up bdy procs))
       (define free++ (set-subtract free+ (list->set xs)))
       (define ordered-free-vars (set->list free++))
       (define lam (gensym `lam))
       (define env (gensym `env))
       `((vector ,lam ,@ordered-free-vars) 
         ,free++
         ,(cons `(proc (,lam ,env . ,xs) 
                       ,(cdr (foldl (lambda (x acc) 
                                      (match-define (cons i bdy+) acc)
                                      (cons (+ 1 i) 
                                            `(let ([,x (vector-ref ,env ,i)])
                                               ,bdy+)))
                                    (cons 1 bdy+)
                                    ordered-free-vars)))
                procs+))]
		 
      [`(,(? prim? op) ,bdy ...)
       (foldr (lambda (ae acc)
                (match-define `((,prim-op ,aes+ ...) ,free0 ,procs) acc)
                (match-define `(,ae+ ,free1 ,procs+) (bottom-up ae procs))
                `((,prim-op ,ae+ . ,aes+) ,(set-union free0 free1) ,procs+))
              `((,op) ,(set) ,procs) bdy)]
		
      [`(,aes ...) 
       (foldr (lambda (ae acc)
                (match-define `((clo-app ,aes+ ...) ,free0 ,procs) acc)
                (match-define `(,ae+ ,free1 ,procs+) (bottom-up ae procs))
                `((clo-app ,ae+ . ,aes+) ,(set-union free0 free1) ,procs+))
              `((clo-app) ,(set) ,procs) aes)]
      )) 
  ; Use bottom-up to generate a main procedure from the program expression e	   	
  (match-define `(,main-body ,freevars ,procs)	   	
    (bottom-up e '()))	   	
  `((proc (main) ,main-body) . ,procs))


;;; Output Language	
; prog ::= proc ...
; proc ::= (proc (x ...) ce) 
; ce ::= (let ([x (prim-op ae ...)]) ce)	   	
;     |  (clo-app ae ae ...)	  
;     |  (if ae ce ce)
; ae ::= x | n | (prim-op ae ...)
; x is a symbol?  (possibly 'halt)	  
; n is a number? 
; prim-op is a prim?	  