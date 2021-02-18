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

function testLexsr(str)
    local result = {}
    for str, cat in lexsr.lex(str) do
        table.insert(result, str.. " - "..lexsr.catnames[cat])
    end
    printTable(result)
end

function testParser(str, expected)
    local function bool2str(bool)
        if bool then
            return "true"
        else
            return "false"
        end
    end
    
    local result = srparser.parse(str)
    io.write(str.."\n"..bool2str(expected).." - "..bool2str(result))
    if result ~= expected then
        io.write("!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end
    io.write("\n\n")
end

testLexsr("a")
testLexsr("longidentifier")
testLexsr("1")
testLexsr("1e5")
testLexsr("1e")
testLexsr("15+e5")
testLexsr("15e+5")
testLexsr("987E+")
testLexsr("+")
testLexsr("-")
testLexsr("*")
testLexsr("(1 + a) / 6")
testLexsr("1345678765434567654567")
testLexsr("+-=/*)(())()()")
testLexsr("A!@$%^&*()_+=-{}[]\"    '`~VADSD:;<>,.?/|\"#garbage")

testParser("1", true)
testParser("a", true)
testParser("1 + a", true)
testParser("1 * a", true)
testParser("(1)", true)
testParser("(a)", true)
testParser("(1 + a)", true)
testParser("1 / 6", true)
testParser("1 + 4", true)
testParser("asdgbtergasdfafasdfasdaghdsafasd * 1243567865432456767543214675432", true)
testParser("&", false)
testParser("1 1", false)
testParser("1 a", false)
testParser("a +", false)


