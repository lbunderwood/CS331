#lang scheme
; Created by Luke Underwood
; 2021-04-18
; addpairs.scm
; Assignment 7
; CS331
; contains definition of procedure addpairs, which adds consecutive pairs of integers


; addpairs procedure
(define (addpairs . args)

  ; set up a loop
  (let loop
    (
    ; holds the numbers after they've been added
    [pairs '()]
    ; holds the numbers that have yet to be added
    [nums args]
    )
    
    ; perform operations on these two lists
    (if (pair? nums)
        (if [null? (cdr nums)]

            ; BASE CASE 1: odd number of arguments
            [append pairs nums]

            ; RECURSIVE CASE: add first two terms in nums and recurse
            [loop (append pairs (cons (+ (car nums) (cadr nums)) null)) (cddr nums)]
            )

        ; BASE CASE 2: even number of arguments
        pairs
        )
    )
  )