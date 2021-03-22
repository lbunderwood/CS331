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

testLexsr("(1 + a)")

testParser("(1 + a)", true)