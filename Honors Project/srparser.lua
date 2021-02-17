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
    
    --nonterminals for representing them in the stack
    local ntAll  = {1, nil}
    local ntExpr = {2, nil}
    local ntTerm = {3, nil}
    local ntFact = {4, nil}
    
    
    -- variables
    local stack = { {ntAll, START} } -- top item contains most recent symbol and current state
    local state = START            -- this must be set to the same as table.maxn(stack)[2]
    local validSyntax = true       -- this will be set to false if something is wrong, and will be returned at the end
    local currSym = {nil, nil}     -- currSym holds the current symbol and its lexeme category 
                                      -- (category is nil for nonterminals)
    
    -- shift function - adds the current symbol and state to the stack
    local function shift(newState)
        table.insert(stack, {currSym, newState}) -- TODO: Put real input here
        state = newState
    end
    
    --goTo function
    local function goTo(nt)
        local previousState = table.maxn(stack)[2]
        if previousState = START then
            if nt == ntAll then
                return ALL
            elseif nt == ntExpr then
                return EXPR
            elseif nt == ntFact then
                return FACT
            elseif nt == ntTerm then
                return TERM
            end
        elseif previousState == PAR then
            if nt == ntExpr then
                return PARE
            elseif nt == ntFact then
                return PARF
            elseif nt == ntTerm then
                return PART
            end
        elseif previousState == TSTAR then
            if nt == ntFact then
                return TSF
            end
        elseif previousState == EPLUS then
            if nt == ntTerm then
                return EPT
            elseif nt == ntFact then
                return EPF
            end
        end
    end
    
    -- reduce functions - reduce symbols by reversing grammar productions
    local function exprToAll()
        newState = goTo(ntAll)
        table.remove(stack)
        table.insert(stack, {ntAll, newState})
    end 
    local function termToExpr()
        newState = goTo(ntExpr)
        table.remove(stack)
        table.insert(stack, {ntExpr, newState})
    end
    local function ETToExpr()
        newState = goTo(ntExpr)
        table.remove(stack)
        table.remove(stack)
        table.remove(stack)
        table.insert(stack, {ntExpr, newState})
    end
    local function factToTerm()
        newState = goTo(ntTerm)
        table.remove(stack)
        table.insert(stack, {ntTerm, newState})
    end
    local function TFToTerm()
        newState = goTo(ntTerm)
        table.remove(stack)
        table.remove(stack)
        table.remove(stack)
        table.insert(stack, {ntTerm, newState})
    local function idToFact()
        newState = goTo(ntFact)
        table.remove(stack)
        table.insert(stack, {ntFact, newState})
    end
    local function numToFact()
        newState = goTo(ntFact)
        table.remove(stack)
        table.insert(stack, {ntFact, newState})
    end
    local function pepToFact()
        newState = goTo(ntFact)
        table.remove(stack)
        table.remove(stack)
        table.remove(stack)
        table.insert(stack, {ntFact, newState})
    end
    
    -- reduce function table for easy calling
    local reduce = 
    {
        exprToAll
        termToExpr
        ETToExpr
        factToTerm
        TFToTerm
        idToFact
        numToFact
        pepToFact
    }
    
    -- state handler functions
    
    -- No lexemes have been processed yet
    local function handle_START()
        if currSym[2] == lexsr.ID then
            shift(ID)
        elseif currSym[2] == lexsr.NUMLIT then
            shift(NUM)
        elseif currSym[1] == "(" then
            shift(PAR)
        else
            state = ERR
        end
    end
    
    
    local function handle_ID()
        
        
    end
    local function handle_NUM()
    local function handle_PAR()
    local function handle_PARF()
    local function handle_PART()
    local function handle_PEP()
    local function handle_FACT()
    local function handle_TERM()
    local function handle_TSTAR()
    local function handle_TSF()
    local function handle_EXPR()
    local function handle_EPLUS()
    local function handle_EPF()
    local function handle_EPT()
    local function handle_EEND()
    local function handle_ALL()
    local function handle_ERR()
    
    local handlers =
    {
        [START] = handle_START,
        [ID] = handle_ID,
        [NUM] = handle_NUM,
        [PAR] = handle_PAR,
        [PARF] = handle_PARF,
        [PART] = handle_PART,
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
    }
    
    -- main body of parse function
    
    
end

return srparser