-- median.hs
-- created 2021-03-22
-- by Luke Underwood
-- for CS331
-- full program median, takes a series of numbers and outputs the median

------------------------------------------------------------------------------------
-- THIS MODULE IS NOT ROBUST - IF NON-INTEGERS ARE ENTERED BY THE USER IT WILL CRASH.
------------------------------------------------------------------------------------
module Main where
import Data.List
import System.IO


-- main
-- loops recursively until the user tells it to stop
main = do
    -- print instructions
    putStr "\nEnter a list of integers, one on each line.\n"
    putStr "I will compute the median of the list.\n\n"
    putStr "Please ONLY enter INTEGERS. Any other input will cause an error.\n\n"
    
    -- get input and print result
    computeMedian []

    putStr "Do you want to compute another median? [y/n]: "
    hFlush stdout
    line <- getLine

    -- recursive case: compute another median
    if line == "y" || line == "Y"
    then main

    -- base case: print message and leave the function
    else putStr "Bye!\n"


-- computeMedian
-- collects input in a recursive loop, then outputs the median
computeMedian :: [Integer] -> IO ()
computeMedian list = do

    -- get the number
    ioNum <- getNum
    let num = read ioNum :: Integer

    -- base case: blank line is read
    if ioNum == ""
    then do
        -- output the median
        putStr "The median is: "
        putStr $ show $ (sort list) !! (length list `div` 2)
        putStr "\n"

    -- recursive case: add the input and loop
    else do
        computeMedian (num:list)


-- getNum
-- prints a prompt and returns a string from the user
getNum = do
    putStr "Enter one number (blank line to end): "
    hFlush stdout
    line <- getLine
    return line