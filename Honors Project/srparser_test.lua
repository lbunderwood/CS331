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
    result = {}
    for str, cat in lexsr.lex(str) do
        table.insert(result, str.. " - "..lexsr.catnames[cat])
    end
    printTable(result)
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

