#lang racket


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; 
; Lab 9 -- A control, environment, (k)ontinuation (CEK) interpreter	  
;
; The goal of this lab is to extend your interpreter from Lab 6 to include let,	   	
; call/cc, an explicitly represented stack, and first-class continuations. Details below.	  
;	  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	  


(provide interp-CEK) 


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


; Define interp-CEK, a tail recursive (small-step) interpreter for the language: 
;;;  e ::= (lambda (x) e)
;;;      | (e e)	  
;;;      | x
;;;      | (let ([x e]) e)            ;; <-- only these two forms are
;;;      | (call/cc (lambda (x) e))   ;; <-- new compared with Lab 6 
;;;      | (if e e e)
;;;      | (and e e)	   	
;;;      | (or e e) 
;;;      | (not e)	   	
;;;      | b 
;;;  x ::= < any variable satisfying symbol? >	   	
;;;  b ::= #t | #f	  

; You can use (error ...) to handle errors, but will only be tested on	   	
; on correct inputs. The language should work as described in Lab 6, except	  
; with added (call/cc ...) and (let ...) forms intended to work as 
; in Scheme/Racket. In order to implement call/cc properly, your interpreter	  
; must implement a stack (as opposed to using Racket's stack by making the	   	
; interpreter directly recursive) yourself and then allow whole stacks to be	   	
; used as first-class values, captured by the call/cc form. Because your	   	
; interpreter implements its own stack, it does not use Racket's stack, 
; and so every call to interp-CEK must be in tail position! 
; Use the symbol 'halt for an initial, empty stack. When a value is returned 
; to the 'halt continuation, that value is finally returned from interp-CEK.	  
; For first-class continuations, use a tagged `(kont ,k) form where k is the	   	
; stack, just as in the CE interpreter you used a tagged `(closure ,lam ,env)
; form for representing closures.	  

; Two examples:	   	
;;; (interp-CEK `(call/cc (lambda (k) (and (k #t) #f))) (hash) 'halt)	  
; should yield a value equal? to #t, and	  
;;; (interp-CEK `(call/cc (lambda (k0) ((call/cc (lambda (k1) (k0 k1))) #f))) (hash) 'halt)	   	
; should yield a value equal? to `(kont (ar #f ,(hash 'k0 '(kont halt)) halt))	   	
	  

(define (interp-CEK cexp env kont) 
  (define (return kont v)	   	
    (match kont
      [`(andk ,e0 ,env ,k)	
       (if v	   	
           (interp-CEK e0 env k)	  
           (return k v))]
      ; TODO: more continuations...
      [`(ork ,e1 ,env ,kont)
       (if v
           (return kont v)
           (interp-CEK e1 env kont)
           )]
      
      [`(notk ,env ,kont)
       (if v
           (return kont #f)
           (return kont #t))]
      
      [`(ifk ,e1 ,e2 ,env ,kont)
       (if v
           (interp-CEK e1 env kont)
           (interp-CEK e2 env kont)
           )]
      
      [`(ar ,arg ,env+ ,kont)
       (interp-CEK arg env+ `(fn ,v ,kont))
       ]
      [`(fn (closure (lambda (,x) ,body) ,env+) ,kont)
       (interp-CEK body (hash-set env+ x v) kont)]
      [`(fn (kont ,k) ,_)
       (return k v)]

      [`(letk ,x1 ,e1 ,env1 ,kont1)
       (interp-CEK e1 (hash-set env1 x1 v) kont1)]

      
      ['halt v]
      
      )) 
  (match cexp	
    [`(and ,e0 ,e1) 
     (interp-CEK e0 env `(andk ,e1 ,env ,kont))]
    
    ; TODO: more language forms...
    [`(lambda (,x) ,body) (return kont `(closure ,cexp ,env))]
    [(? boolean? x)         (return kont x)]
    [(? symbol? x)          (return kont (hash-ref env x))]
    
    [`(not ,e) (interp-CEK e env `(notk ,env ,kont))]
    
    [`(or ,e0 ,e1) (interp-CEK e0 env `(ork ,e1 ,env ,kont))]
    
    [`(if ,e ,e1 ,e2) (interp-CEK e env `(ifk ,e1 ,e2 ,env ,kont))]
    
    [`(call/cc (lambda (,x) ,e)) (interp-CEK e (hash-set env x `(kont ,kont)) kont)]
    
    [`(let ([,x ,e]) ,body)
     (interp-CEK e env `(letk ,x ,body ,env ,kont))]
    
    [`(,fun ,arg)
     (interp-CEK fun env `(ar ,arg ,env ,kont))
     ]
    
    
    [else (error (format "Exp not recognized: ~a" cexp))]))	  




