-- Luke Underwood
-- 2/5/21
-- CS331
-- pa2.lua
-- contains module pa2
-- pa2 includes functions filterArray, concatMax, collatz, and substrings

-- module to export
local pa2 = {}


------------------------------------------------------------------------
-- filterArray function
-- t must be an array-like table
-- p must be a single-parameter function that takes an item from array t
-- filterArray returns an array of all the values v from t for which p(v) is truthy
function pa2.filterArray(p, t)
  
  -- table to hold values that come back truthy
  local output = {}
  
  -- iterate over t
  for k, v in ipairs(t) do
    -- put all the truthy ones in the table
    if p(v) then table.insert(output, v) end
  end
  
  -- return the values we want
  return output
end


------------------------------------------------------------------------
-- concatMax function
-- str is a string, len is an integer
-- returns the longest concatonation of str that has length <= len
function pa2.concatMax(str, len)
  
  -- string to hold concatonation
  output = ""
  
  -- keep looping until an additional concatonation would surpass the limit
  while string.len(output) + string.len(str) <= len do
    -- add str to the end of output
    output = output..str
  end
  
  -- return the concatonated string
  return output
end


------------------------------------------------------------------------
-- collatz iterator function
-- k is an integer
-- returns iterator that produces collatz sequence starting at k
-- can be used as an iterator in a for loop
function pa2.collatz(k)
  
  -- this value will be used to mark when the sequence is done
  DONE = -1
  
  -- iterator function
  local function iter()
    
    -- save_k will be the value returned
    save_k = k
    
    -- check if the sequence is finished, return nil if so
    if k == DONE then 
      return nil
      
    -- check if k == 1, signal that the sequence is finished if so
    elseif k == 1 then 
      k = DONE
      
    -- if k is even, divide k by 2
    elseif k % 2 == 0 then 
      k =  k / 2
      
    -- if k is odd and not 1, multiply by 3 and add 1
    else 
      k =  3 * k + 1 
    end
    
    -- return the previous value of k
    return save_k
  end
  
  -- return the iter function
  return iter
end


------------------------------------------------------------------------
-- substrings coroutine function
-- s is a string
-- returns all substrings of s
-- be sure to use the coroutine module with this function
function pa2.substrings(s)
  
  -- yield the empty string, because it is a substring of every string
  coroutine.yield("")
  
  -- keeps track of the current length of substring to output
  substrLength = 1
  
  -- loop until the substring length exceeds the string length
  while substrLength <= string.len(s) do
    
    -- keeps track of the current position in the string
    stringPos = 0
    
    -- loop over the string until the next substring would go off the end of the string
    while stringPos + substrLength <= string.len(s) do
      
      -- yield the substring
      coroutine.yield(string.sub(s, stringPos + 1, stringPos + substrLength))
      
      -- increment position in string
      stringPos = stringPos + 1
    end
    
    -- increment size of substring
    substrLength = substrLength + 1
  end
end -- run off end to conclude coroutine



-- export module
return pa2