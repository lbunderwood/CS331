\ Created by Luke Underwood
\ 2021-04-18
\ collcount.fs
\ Assignment 7
\ CS 331
\ contains definition of word collcount, which has stack effect (n -- c), 
\   where n is a positive integer, and c is the number of iterations of the 
\   Collatz function required to take n to 1

\ perform collatz function on n, increment i, leave i on stack in base case
: collatz { n i -- c }
    \ BASE CASE: n == 1, return i
    n 1 = if
        i

    \ RECURSIVE CASE: n != 1, perform collatz and recurse
    else
        i 1 + to i
        n 2 MOD 0= if
            n 2 / to n
            n i recurse
        else
            n 3 * 1 + to n
            n i recurse
        then
    then
;

: collcount { n -- c }
    n 1 < if
        ." Bad input - please try again!"
    else
        n 0 collatz
    then
;
