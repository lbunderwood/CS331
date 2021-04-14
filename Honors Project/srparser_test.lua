-- srparser_test.lua
-- Luke Underwood
-- Created 2/16/2021
-- program to test and use srparser and lexsr

lexsr = require "lexsr"
srparser = require "srparser"

function printTable(table)
    io.write("{ \n")
    for k, v in ipairs(table) do
        io.write("\t"..v.."\n")
    end
    io.write("}\n\n")
end

-- equal
-- Compare equality of two values. Returns false if types are different.
-- Uses "==" on non-table values. For tables, recurses for the value
-- associated with each key.
function equal(...)
    assert(select("#", ...) == 2,
           "equal: must pass exactly 2 arguments")
    local x1, x2 = select(1, ...)  -- Get args (may be nil)

    local type1 = type(x1)
    if type1 ~= type(x2) then
        return false
    end

    if type1 ~= "table" then
       return x1 == x2
    end

    -- Get number of keys in x1 & check values in x1, x2 are equal
    local x1numkeys = 0
    for k, v in pairs(x1) do
        x1numkeys = x1numkeys + 1
        if not equal(v, x2[k]) then
            return false
        end
    end

    -- Check number of keys in x1, x2 same
    local x2numkeys = 0
    for k, v in pairs(x2) do
        x2numkeys = x2numkeys + 1
    end
    return x1numkeys == x2numkeys
end

function testLexsr(str)
    local result = {}
    for str, cat in lexsr.lex(str) do
        table.insert(result, str.. " - "..lexsr.catnames[cat])
    end
    printTable(result)
end

function testParser(str, expected, expAST)
    local function bool2str(bool)
        if bool then
            return "true"
        else
            return "false"
        end
    end
    
    local result, AST = srparser.parse(str)
    io.write(str.."\n"..bool2str(expected).." - "..bool2str(result).."\n")
    if result ~= expected then
        io.write(" parsed incorrectly!\n")
    end
    
    if result ~= false then
        if equal(AST[1], expAST) then
            io.write("AST matched!")
        else
            io.write("AST did NOT match!!!!!")
        end
    end
    io.write("\n\n")
end


testParser("1", true, {"1", lexsr.NUMLIT})
testParser("(1)", true, {"1", lexsr.NUMLIT})
testParser("(((1)))", true, {"1", lexsr.NUMLIT})
testParser("1 + 2", true, {"+", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("1 - 2", true, {"-", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("1 * 2", true, {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("1 / 2", true, {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("(1 + 2)", true, {"+", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("(1 - 2)", true, {"-", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("(1 * 2)", true, {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("(1 / 2)", true, {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}})
testParser("1 + 2 + 3", true, 
    {"+", lexsr.OP, 
        {"+", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 + 2 - 3", true, 
    {"-", lexsr.OP, 
        {"+", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 + 2 * 3", true, 
    {"+", lexsr.OP, 
        {"1", lexsr.NUMLIT},
        {"*", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("1 + 2 / 3", true, 
    {"+", lexsr.OP,
        {"1", lexsr.NUMLIT},
        {"/", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("1 - 2 + 3", true, 
    {"+", lexsr.OP, 
        {"-", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 - 2 - 3", true, 
    {"-", lexsr.OP, 
        {"-", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 - 2 * 3", true, 
    {"-", lexsr.OP,  
        {"1", lexsr.NUMLIT},
        {"*", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("1 - 2 / 3", true, 
    {"-", lexsr.OP,
        {"1", lexsr.NUMLIT},
        {"/", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("1 * 2 + 3", true, 
    {"+", lexsr.OP, 
        {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 * 2 - 3", true, 
    {"-", lexsr.OP, 
        {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 * 2 * 3", true, 
    {"*", lexsr.OP, 
        {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 * 2 / 3", true, 
    {"/", lexsr.OP, 
        {"*", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 / 2 + 3", true, 
    {"+", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 / 2 - 3", true, 
    {"-", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 / 2 * 3", true, 
    {"*", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("1 / 2 / 3", true, 
    {"/", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("(1 / (2 + 3))", true, 
    {"/", lexsr.OP,
        {"1", lexsr.NUMLIT},
        {"+", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("1 / (2 - 3)", true, 
    {"/", lexsr.OP,
        {"1", lexsr.NUMLIT},
        {"-", lexsr.OP, {"2", lexsr.NUMLIT}, {"3", lexsr.NUMLIT}}
    })
testParser("(1 / 2) * 3", true, 
    {"*", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("((1 / 2) / 3)", true, 
    {"/", lexsr.OP, 
        {"/", lexsr.OP, {"1", lexsr.NUMLIT}, {"2", lexsr.NUMLIT}}, 
        {"3", lexsr.NUMLIT}
    })
testParser("*", false, {})
testParser("1 *", false, {})
testParser("* 1", false, {})
testParser("+", false, {})
testParser("1 +", false, {})
testParser("+ 1", false, {})
testParser("1 * + 2", false, {})
testParser("()", false, {})
testParser("(1", false, {})
testParser("1)", false, {})
