% Created by Luke Underwood
% 2021-04-19
% collcount.pl
% Assignment 7
% CS331
% contains predicate collcount, which correlates a number with the number of
% iterations of the collatz function required to reduce the number to 1

% counter/3
% counter(+n, +s, ?i) 
% i is the number of iterations that have already been performed
% n is the number initially given to collcount
% s is a starting point for i, should always be set to 0 by collcount
counter(1, S, I) :- I is S.
counter(N, S, I) :- 
                N > 1,
                N mod 2 =:= 0,
                S1 is S + 1,
                N1 is N / 2,
                counter(N1, S1, I).
counter(N, S, I) :- 
                N > 1,
                mod(N, 2) > 0,
                S1 is S + 1,
                N1 is N * 3 + 1,
                counter(N1, S1, I).


% collcount/2
% collcount(+n, ?c) c is iterations of collatz for number n
collcount(N, C) :- 
                N >= 1,
                counter(N, 0, C).