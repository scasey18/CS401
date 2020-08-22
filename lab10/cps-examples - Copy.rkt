#lang racket 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; 
; Lab 10 -- Two simple examples in CPS	  
;
; The goal of this lab is to practice our understanding of CPS on two simple	   	
; functions, append and reverse. Write a version of each in CPS where every	  
; function and continuation takes a new zeroth parameter to be passed the current continuation. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	   	


(provide append reverse)	   	


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


; CPS convert two more examples manually as practice: append & reverse	   	

; e.g.  (append (lambda (_ lst) (print lst)) '(1) '(2))	   	

(define (append k lst0 lst1)	   	
  (let ([nullb (null? lst0)])	
    (if nullb	  
        (k k lst1)	  
        (let ([nulla (null? lst1)])
          (if nulla
              (k k lst1)
              (let ([newlist (foldr cons lst1 lst0)])
                (k k newlist)))))))

; What makes reverse simpler to CPS convert in some sense?	   	

(define (reverse k lst)	  
  (define (trev lst0 lst1) 
    (let ([nullv (null? lst1)])
      (if nullv
          lst0
          (let ([f (car lst1)] [v (cdr lst1)])
            (let ([lst (trev f v)])
              (flatten (cons lst lst0)))))))	   	
  (let ([nulllst (null? lst)])
    (if nulllst
        (k k lst)
        (let ([f (car lst)]
              [v (cdr lst)])
          (let ([lst0 (trev f v)])
            (k k lst0))))))   	



