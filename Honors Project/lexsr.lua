-- lexsr.lua
-- VERSION 5
-- Glenn G. Chappell
-- Started: 2021-02-03
-- Updated: 2021-02-05
--
-- For CS F331 / CSCE A331 Spring 2021
-- In-Class lexer Module

-- Updated for Assignment 3
-- Luke Underwood
-- 2/13/21
-- converted to lexit

-- Updated to lexsr 2/16/21 by Luke Underwood
-- lex - SR for Shift-Reduce

-- History:
-- - v1:
--   - Framework written. lexer treats every character as punctuation.
-- - v2:
--   - Add state LETTER, with handler. Write skipWhitespace. Add
--     comment on invariants.
-- - v3:
--   - Finished (hopefully). Add states DIGIT, DIGEXP, OPER, PLUS, MINUS,
--     STAR. Comment each state-handler function. Check for MAL lexeme.
-- - v4:
--   - Converted to lexit for Assignment 3
-- - v5:
--   - Converted to lexsr for shift-reduce parser honors project

-- Usage:
--
--    program = "print a+b;"  -- program to lex
--    for lexstr, cat in lexsr.lex(program) do
--        -- lexstr is the string form of a lexeme.
--        -- cat is a number representing the lexeme category.
--        --  It can be used as an index for array lexsr.catnames.
--    end


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexsr = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexsr.ID     = 1  -- identifier
lexsr.NUMLIT = 2  -- numeric literal
lexsr.OP     = 3  -- operator
lexsr.PUNCT  = 4  -- punctuation
lexsr.MAL    = 5  -- malformed


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexsr.catnames = {
    "Identifier",     -- 1
    "NumericLiteral", -- 2
    "Operator",       -- 3
    "Punctuation",    -- 4
    "Malformed",      -- 5
}


-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end


-- *********************************************************************
-- The lexer
-- *********************************************************************


-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexsr.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexsr.lex(program)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE   = 0  -- lexeme has been read in completely
    local START  = 1  -- lexeme has not been read at all yet
    local LETTER = 2  -- letters have been read. Keyword or Identifier
    local DIGIT  = 3  -- numbers have been read
    local DIGEXP = 4  -- numbers and an e have been read
    
    -- ***** Character-Related Utility Functions *****

    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipWhitespace()
        while true do
            -- Skip whitespace characters
            while isWhitespace(currChar()) do
                drop1()
            end

            -- Done if no comment
            if currChar() ~= "#" then
                break
            end

            -- Skip comment
            while currChar() ~= "\n" do
                if currChar() == "" then  -- End of input?
                   return
                end
                drop1()  -- Drop character inside comment
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    -- State DONE: lexeme is done; this handler should not be called.
    local function handle_DONE()
        error("'DONE' state should not be handled\n")
    end

    -- State START: no character read yet.
    local function handle_START()
      
        -- looks like an identifier
        if isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
            
        -- looks like a numeric literal
        elseif isDigit(ch) then
            add1()
            state = DIGIT
            
        -- single-character operator lexemes - no state needed
        elseif ch == "+" or ch == "-" or ch == "*" or ch == "/" then
            add1()
            state = DONE
            category = lexsr.OP
            
        -- single-character punctuation lexemes - no state needed
        elseif ch == "(" or ch == ")" then
            add1()
            state = DONE
            category = lexsr.PUNCT
            
        -- if we got here, it has to be an illegal character
        else
            add1()
            state = DONE
            category = lexsr.MAL
        end
    end

    -- State LETTER: we are in an ID
    local function handle_LETTER()
      
        -- add to the lexeme and move on
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexsr.ID
        end
    end

    -- State DIGIT: we are in a NUMLIT, and we have NOT seen "e" or "E".
    local function handle_DIGIT()
      
        -- add to the lexeme and move on
        if isDigit(ch) then
            add1()
            
        -- it may have an exponential portion
        elseif ch == "e" or ch == "E" then
        
            -- check that what follows is definitely part of a numeric literal
            if (nextChar() == "+" and isDigit(program:sub(pos+2, pos+2))) or isDigit(nextChar()) then
                add1()
                if currChar() == "+" then
                    add1()
                end
                state = DIGEXP
                
            -- if it isn't, then leave the e/E off because it's the start of something else
            else
                state = DONE
                category = lexsr.NUMLIT
            end
            
        -- end the lexeme
        else
            state = DONE
            category = lexsr.NUMLIT
        end
    end

    -- State DIGEXP: we are in a NUMLIT, and we have seen "e" or "E" and maybe a "+".
    local function handle_DIGEXP()
      
        -- add to lexeme and move on
        if isDigit(ch) then
            add1()
            
        -- end lexeme
        else
            state = DONE
            category = lexsr.NUMLIT
        end
    end
    

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,     -- lexeme has been read in completely
        [START]=handle_START,   -- lexeme has not been read at all yet
        [LETTER]=handle_LETTER, -- letters have been read. Keyword or Identifier
        [DIGIT]=handle_DIGIT,   -- numbers have been read
        [DIGEXP]=handle_DIGEXP, -- numbers and an e have been read
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipWhitespace()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexsr

