#lang racket	  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	   	
; 
; Lab 12 -- Contract examples	
; 
; The goal of this lab is to protect two functions using define/contract so they fail gracefully.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(provide fib 
         append) 



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


(define (fib n)
  (if (and (number? n) (positive? n))
          (if (<= n 1)	   	
              n	   	
              (+ (fib (- n 1)) 
                 (fib (- n 2))))
      (raise-arguments-error 'fib "contract violation")))


(define (append lst0 lst1)
  (if (and (list? lst0) (list? lst1))
      (if (null? lst0)
          lst1
          (cons (car lst0) 
                (append (cdr lst0) 
                        lst1)))
      (raise-arguments-error 'append "contract violation")))


; (define (fib n)
; (if (<= n 1)	   	
; n	   	
; (+ (fib (- n 1)) 
; (fib (- n 2)))))	


; (define (append lst0 lst1)
; (if (null? lst0)
; lst1
; (cons (car lst0) 
; (append (cdr lst0) 
; lst1)))) 



