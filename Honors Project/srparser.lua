-- srparser.lua
-- Luke Underwood
-- Created 2/16/21
-- CS 331 Honors Project
-- Shift-reduce parser module srparser

lexsr = require "lexsr"

local srparser = {}

------------------------------------------------
-- The Parser
------------------------------------------------

-- takes an arithmetic expression
-- returns boolean indicating whether 
function srparser.parse(program)
    
    -- states          -- top of stack looks like:
    local START   = 1  -- 
    local ID      = 2  -- ID
    local NUM     = 3  -- NUMLIT
    local PAR     = 4  -- (
    local PARF    = 5  -- ( factor
    local PART    = 6  -- ( term
    local PARE    = 7  -- ( expr
    local PEP     = 8  -- ( expr )
    local FACT    = 9  -- factor
    local TERM    = 10 -- term
    local TSTAR   = 11 -- term *
    local TSF     = 12 -- term * factor
    local EXPR    = 13 -- expr
    local EPLUS   = 14 -- expr +
    local EPF     = 15 -- expr + factor
    local EPT     = 16 -- expr + term
    local EEND    = 17 -- expr $
    local ALL     = 18 -- all
    local ERR     = 19 -- Something has gone wrong
    local DONE    = 20 -- mark that parsing is complete
    
    --nonterminals for representing them in the stack
    local ntAll  = {1}
    local ntExpr = {2}
    local ntTerm = {3}
    local ntFact = {4}
    
    
    -- variables
    local stack = { {ntAll, START} } -- top item contains most recent symbol and current state
    local AST = {}                   -- Abstract Syntax Tree - returned set of instructions for interpreter
    local validSyntax = true         -- this will be set to false if something is wrong, and will be returned at the end
    local currSym                    -- stores current symbol (not yet added to stack)
    local lexArr = {}                -- stores all of the lexemes
    local pos = 1                    -- keeps track of our current position in lexArr
    
    -- lastSym returns the current symbol and its lexeme category from the stack
    -- (category is nil for nonterminals)
    local function lastSym()
        return stack[table.maxn(stack)][1]
    end
    
    -- currState returns the current state from the stack
    local function currState()
        return stack[table.maxn(stack)][2]
    end
    
    -- shift function - adds the current symbol and state to the stack
    local function shift(newState)
        table.insert(stack, {currSym, newState})
        pos = pos + 1
        currSym = lexArr[pos]
    end
    
    --goTo function
    local function goTo(nt)
        if currState() == START then
            if nt == ntAll then
                return ALL
            elseif nt == ntExpr then
                return EXPR
            elseif nt == ntFact then
                return FACT
            elseif nt == ntTerm then
                return TERM
            else
                return ERR
            end
        elseif currState() == PAR then
            if nt == ntExpr then
                return PARE
            elseif nt == ntFact then
                return PARF
            elseif nt == ntTerm then
                return PART
            else
                return ERR
            end
        elseif currState() == TSTAR then
            if nt == ntFact then
                return TSF
            else
                return ERR
            end
        elseif currState() == EPLUS then
            if nt == ntTerm then
                return EPT
            elseif nt == ntFact then
                return EPF
            else
                return ERR
            end
        else
            return ERR
        end
    end
    
    -- production codes for passing to reduce function
    local eendToAll  = 1
    local termToExpr = 2
    local eptToExpr  = 3
    local factToTerm = 4
    local tsfToTerm  = 5
    local idToFact   = 6
    local numToFact  = 7
    local pepToFact  = 8
    
    -- production information to be used by reduce
    -- the number represents the number of symbols in the right side of the production
    -- the second element represents the nonterminal on the left side
    local productions =
    {
        [eendToAll]  = {2, ntAll },
        [termToExpr] = {1, ntExpr},
        [eptToExpr]  = {3, ntExpr},
        [factToTerm] = {1, ntTerm},
        [tsfToTerm]  = {3, ntTerm},
        [idToFact]   = {1, ntFact},
        [numToFact]  = {1, ntFact},
        [pepToFact]  = {3, ntFact},
    }
        
    -- reduce function - reduce symbols by reversing grammar production
    local function reduce(num)
        prod = productions[num]
        for i = 1, prod[1], 1 do
            table.remove(stack)
        end
        table.insert(stack, {prod[2], goTo(prod[2])})
    end
    
    -- state handler functions
    
    -- No symbols have been parsed yet
    local function handle_START()
        if currSym[2] == lexsr.ID then
            shift(ID)
        elseif currSym[2] == lexsr.NUMLIT then
            shift(NUM)
        elseif currSym[1] == "(" then
            shift(PAR)
        else
            shift(ERR)
        end
    end
    
    -- last symbol was an identifier
    local function handle_ID()
        reduce(idToFact)
    end
    
    -- last symbol was a numeric literal
    local function handle_NUM()
        reduce(numToFact)
    end
    
    -- last symbol was "("
    local function handle_PAR()
        if currSym[2] == lexsr.ID then
            shift(ID)
        elseif currSym[2] == lexsr.NUMLIT then
            shift(NUM)
        elseif currSym[1] == "(" then
            shift(PAR)
        else
            shift(ERR)
        end
    end
        
    -- last two symbols were "(" and factor
    local function handle_PARF()
        reduce(factToTerm)
    end
    
    -- last two symbols were "(" and term
    local function handle_PART()
        if currSym[1] == "*" or currSym[1] == "/" then
            shift(TSTAR)
        else
            reduce(termToExpr)
        end
    end
    
    -- last two symbols were "(" and expr
    local function handle_PARE()
        if currSym[1] == "+" or currSym[1] == "-" then
            shift(EPLUS)
        elseif currSym[1] == ")" then
            shift(PEP)
        else
            shift(ERR)
        end
    end
    
    -- last three symbols were "(", expr, ")"
    local function handle_PEP()
        reduce(pepToFact)
    end
        
    -- last symbol was a factor
    local function handle_FACT()
        reduce(factToTerm)
    end
    
    -- last symbol was a term
    local function handle_TERM()
        if currSym[1] == "+" or currSym[1] == "-" or currSym[1] == "" then
            reduce(termToExpr)
        elseif currSym[1] == "*" or currSym[1] == "/" then
            shift(TSTAR)
        else
            shift(ERR)
        end
    end
    
    -- last two symbols were term and ("*" | "/")
    local function handle_TSTAR()
        if currSym[2] == lexsr.ID then
            shift(ID)
        elseif currSym[2] == lexsr.NUMLIT then
            shift(NUM)
        elseif currSym[1] == "(" then
            shift(PAR)
        else
            shift(ERR)
        end
    end
    
    -- last three symbols were term, ("*" | "/"), and factor
    local function handle_TSF()
        reduce(tsfToTerm)
    end
    
    -- last symbol was an expression
    local function handle_EXPR()
        if currSym[1] == "+" or currSym[1] == "-" then
            shift(EPLUS)
        elseif currSym[1] == "" then
            shift(EEND)
        else
            shift(ERR)
        end
    end
      
    -- last two symbols were expression and ("+" | "-")
    local function handle_EPLUS()
        if currSym[2] == lexsr.ID then
            shift(ID)
        elseif currSym[2] == lexsr.NUMLIT then
            shift(NUM)
        elseif currSym[1] == "(" then
            shift(PAR)
        else
            shift(ERR)
        end
    end
    
    -- last three symbols were expr, ("+" | "-"), factor
    local function handle_EPF()
        reduce(factToTerm)
    end
    
    -- last three symbols were expr, ("+" | "-"), term
    local function handle_EPT()
        if currSym[1] == "*" or currSym[1] == "/" then
            shift(TSTAR)
        else
            reduce(eptToExpr)
        end
    end
    
    -- last two symbols were expr, ""
    local function handle_EEND()
        reduce(eendToAll)
    end
    
    -- last symbol was all
    local function handle_ALL()
        shift(DONE)
    end
    
    -- we encountered incorrect input
    local function handle_ERR()
        validSyntax = false
        shift(DONE)
    end
    
    -- we should never call this function, but it is here for consistency and error handling
    local function handle_DONE()
        print("We should not handle the done state")
    end
    
    local handlers =
    {
        [START] = handle_START,
        [ID] = handle_ID,
        [NUM] = handle_NUM,
        [PAR] = handle_PAR,
        [PARF] = handle_PARF,
        [PART] = handle_PART,
        [PARE] = handle_PARE,
        [PEP] = handle_PEP,
        [FACT] = handle_FACT,
        [TERM] = handle_TERM,
        [TSTAR] = handle_TSTAR,
        [TSF] = handle_TSF,
        [EXPR] = handle_EXPR,
        [EPLUS] = handle_EPLUS,
        [EPF] = handle_EPF,
        [EPT] = handle_EPT,
        [EEND] = handle_EEND,
        [ALL] = handle_ALL,
        [ERR] = handle_ERR,
        [DONE] = handle_DONE,
    }
    
    -- main body of parse function
    
    for str, cat in lexsr.lex(program) do
        table.insert(lexArr, {str, cat})
    end
    table.insert(lexArr, {""})
    
    currSym = lexArr[pos]
    while currState() ~= DONE do
        handlers[currState()]()
    end
    
    return validSyntax, AST
    
end

return srparser