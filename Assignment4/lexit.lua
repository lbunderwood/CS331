-- lexit.lua
-- VERSION 3
-- Glenn G. Chappell
-- Started: 2021-02-03
-- Updated: 2021-02-05
--
-- For CS F331 / CSCE A331 Spring 2021
-- In-Class lexit Module

-- Updated for Assignment 3
-- Luke Underwood
-- 2/13/21
-- converted to lexit

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

-- Usage:
--
--    program = "print a+b;"  -- program to lex
--    for lexstr, cat in lexit.lex(program) do
--        -- lexstr is the string form of a lexeme.
--        -- cat is a number representing the lexeme category.
--        --  It can be used as an index for array lexit.catnames.
--    end


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexit = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexit.KEY    = 1  -- keyword
lexit.ID     = 2  -- identifier
lexit.NUMLIT = 3  -- numeric literal
lexit.STRLIT = 4  -- string literal
lexit.OP     = 5  -- operator
lexit.PUNCT  = 6  -- punctuation
lexit.MAL    = 7  -- malformed


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexit.catnames = {
    "Keyword",        -- 1
    "Identifier",     -- 2
    "NumericLiteral", -- 3
    "StringLiteral",  -- 4
    "Operator",       -- 5
    "Punctuation",    -- 6
    "Malformed",      -- 7
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


-- isPrintableASCII
-- Returns true if string c is a printable ASCII character (codes 32 " "
-- through 126 "~"), false otherwise.
local function isPrintableASCII(c)
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end


-- *********************************************************************
-- The lexer
-- *********************************************************************


-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexit.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexit.lex(program)
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
    local STR    = 5  -- string literal, a " was read
    
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
      
        -- illegal character, must be malformed
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
            
        -- looks like an identifier or keyword
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
            
        -- looks like a numeric literal
        elseif isDigit(ch) then
            add1()
            state = DIGIT
            
        -- looks like a string literal
        elseif ch == "\"" then
            add1()
            state = STR
            
        -- single character operator lexemes - no state needed
        elseif ch == "+" or ch == "-" or ch == "*" or ch == "/" or ch == "%" or ch == "[" or ch == "]" then
            add1()
            state = DONE
            category = lexit.OP
            
        -- two-character operator lexemes - still seems useless to have a seperate state
        elseif ch == "=" or ch == ">" or ch == "<" then
            add1()
            if currChar() == "=" then
                add1()
            end
            state = DONE
            category = lexit.OP     
        -- the "=" is not optional, so "!" needs to be processed differently 
        elseif ch == "!" and nextChar() == "=" then
            add1()
            add1()
            state = DONE
            category = lexit.OP
            
        -- if we got here, it has to be punctuation
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end

    -- State LETTER: we are in an ID or keyword
    local function handle_LETTER()
      
        -- add to the lexeme and move on
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            
            -- check if it's a keyword
            local keywords = {"and", "char", "cr", "def", "dq", "elseif", "else", "false", "for", 
                              "if", "not", "or", "readnum", "return", "true", "write"}
            local isntKey = true
            for k, v in pairs(keywords) do
                if lexstr == v then
                  category = lexit.KEY
                  isntKey = false
                  break
                end
            end
            
            -- if it wasn't a keyword, it's an identifier
            if isntKey then
                category = lexit.ID
            end
        end
    end

    -- State DIGIT: we are in a NUMLIT, and we have NOT seen ".".
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
                category = lexit.NUMLIT
            end
            
        -- end the lexeme
        else
            state = DONE
            category = lexit.NUMLIT
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
            category = lexit.NUMLIT
        end
    end
    
    -- State STR: we are in a string literal
    local function handle_STR()
      
        -- if we see a " the lexeme is over
        if ch == "\"" then
            add1()
            state = DONE
            category = lexit.STRLIT
            
        -- string literal did not conclude correctly
        elseif ch == "" or ch == "\n" then
            state = DONE
            category = lexit.MAL
            
        -- add to lexeme and move on
        else
            add1()
        end
    end

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,     -- lexeme has been read in completely
        [START]=handle_START,   -- lexeme has not been read at all yet
        [LETTER]=handle_LETTER, -- letters have been read. Keyword or Identifier
        [DIGIT]=handle_DIGIT,   -- numbers have been read
        [DIGEXP]=handle_DIGEXP, -- numbers and an e have been read
        [STR]=handle_STR,       -- string literal, a " was read
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


return lexit

