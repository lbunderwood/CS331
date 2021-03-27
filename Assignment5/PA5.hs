-- PA5.hs
-- Glenn G. Chappell
-- 2021-03-16
--
-- For CS F331 / CSCE A331 Spring 2021
-- Solutions to Assignment 5 Exercise B

-- modified 2021-03-22
-- by Luke Underwood
-- completed all module components 

module PA5 where



-- collatzCounts
-- a list of itegers where element k is the number of recursive calls to the collatz function
-- that would be required to reduce k + 1 to 1
collatzCounts :: [Integer]
collatzCounts = listCollatz 1 where

    -- function that produces the list as described above when 1 is given as input
    listCollatz :: Integer -> [Integer]
    listCollatz i = (countIter i 0):(listCollatz (i + 1)) where

        -- function that performs collatz function and counts iterations
        countIter n i
                -- base case: the number has been reduced to 1
            | n == 1 = i
                -- recursive case: n is even
            | even n = countIter (n `div` 2) (i + 1) 
                -- recursive case: n is odd
            | otherwise = countIter (3 * n + 1) (i + 1)
        


-- findList
-- returns the index of the position of first in second, 
-- or returns nothing if first does not appear in second
findList :: Eq a => [a] -> [a] -> Maybe Int
findList first second = searchList 0 0 where

    -- recursively iterate through the list (i = index of first, j = index of second)
    searchList i j
            -- base case: a complete match was found
        | length first == i = Just (j - i)
            -- base case: nothing was found
        | length second == j = Nothing
            -- recursive case: a possible match that requires further investigation
        | first !! i == second !! j = searchList (i + 1) (j + 1)
            -- recursive case: nothing found yet, keep looking
        | otherwise = searchList 0 (j + 1)




-- operator ##
-- returns the number of instances in first and second of 
-- the same element appearing at the same index
(##) :: Eq a => [a] -> [a] -> Int
first ## second = searchList 0 0 where

    -- recursively iterate through the lists, i = index, n = number of matches found
    searchList i n
            -- base cases: we have reached the end of one of the lists
        | length first == i || length second == i = n
            -- recursive case: we found a match
        | first !! i == second !! i = searchList (i + 1) (n + 1)
            -- recursive case: we did not find a match
        | otherwise = searchList (i + 1) n




-- filterAB
-- returns a list of items from the second list for which the corresponding element
-- in the first list returned true when passed to the boolean function
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB boolFunc first second = searchList [] 0 where

    -- recursively iterate through the lists, i = index, list = output
    searchList list i 
            -- base cases: we reached the end of one of the lists
        | length first == i || length second == i = list
            -- recursive case: the element met the condition
        | boolFunc (first !! i) = searchList (list ++ [second !! i]) (i + 1)
            -- recursive case: the element did not meet the condition
        | otherwise = searchList list (i + 1)



-- sumEvenOdd
-- return the sum of all the even numbers, and the sum of all the odd numbers in a tuple
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written using a fold.
  Something like this:

    sumEvenOdd xs = fold* ... xs where
        ...

  Above, "..." should be replaced by other code. The "fold*" must be
  one of the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd list = (foldr (+) 0 (evenOdd !! 0), foldr (+) 0 (evenOdd !! 1)) where
    
    -- return a list containing two lists: one for each of the even and odd indices
    evenOdd = sortList 0 [] [] where
        -- recursively iterate through the list
        sortList i evens odds
                -- base case: reached end of list
            | length list == i = [evens, odds]
                -- recursive case: even index
            | even i = sortList (i + 1) ((list !! i):evens) odds
                -- recursive case: odd index
            | otherwise = sortList (i + 1) evens ((list !! i):odds)
