#!/usr/bin/env lua
-- calculator.lua
-- Glenn G. Chappell
-- 2026-04-02
--
-- For CS 331 Spring 2026
-- REPL for evaluator.lua
-- Requires lexer.lua, rdparser3.lua, evaluator.lua


rdparser3 = require "rdparser3"
evaluator = require "evaluator"


-- ***** Values of Named Variables *****


varValues = {
    ["answer"] = 42,
    ["e"]   = 2.71828182845904523536,
    ["pi"]  = 3.14159265358979323846,
    ["phi"] = 1.61803398874989484820,
    ["tau"] = 6.28318530717958647693,
    ["year"] = 2026,

    -- p, p2, p3, ..., p9 will hold recent results.
}


-- ***** Helper Functions *****


-- printHelp
-- Print help for REPL.
local function printHelp()
    io.write("Type an arithmetic expression to evaluate it.\n")
    io.write("Some named variables have values (e.g., pi, year).\n")
    io.write("Variables p, p2, p3, ..., p9 hold recent results.\n")
    io.write("These are not updated if there is an error.\n")
    io.write("Note that \"1+2\" is illegal; type \"1 + 2\" instead.\n")
    io.write("To exit, type \"exit\". To repeat this, type \"help\".\n")
end


-- errMsg
-- Given an error message, prints it in flagged-error form, with a
-- newline appended.
local function errMsg(msg)
    assert(type(msg) == "string")

    io.write("*** ERROR - "..msg.."\n")
end


-- elimSpace
-- Given a string, remove all leading & trailing whitespace, and return
-- result. If given nil, returns nil.
local function elimSpace(s)
    if s == nil then
        return nil
    end

    local ss = s:gsub("^%s+", "")
    ss = ss:gsub("%s+$", "")
    return ss
end


-- updateRecent
-- Update values of recent results stored in named variables.
local function updateRecent(result)
    varValues.p9 = varValues.p8
    varValues.p8 = varValues.p7
    varValues.p7 = varValues.p6
    varValues.p6 = varValues.p5
    varValues.p5 = varValues.p4
    varValues.p4 = varValues.p3
    varValues.p3 = varValues.p2
    varValues.p2 = varValues.p
    varValues.p = result
end


-- ***** Primary Funtion *****


-- repl
-- Our REPL. Prompt & get a line. If it is "exit" or "help", do that.
-- If EOF occurs, then exit. Otherwise, try to treat the line as an
-- arithmetic expression, parsing and evaluating it. If this succeeds,
-- then print the result. If it fails, then print an error message,
-- UNLESS it is an incomplete expression. In that case, keep inputting,
-- and continue to attempt to evaluate. REPEAT.
function repl()
    local line, good, done, ast, result
    local source = ""

    printHelp()
    while true do
        -- Print newline if not continuing existing expression
        if source == "" then
            io.write("\n")
        end

        -- Input a line until nonblank line read
        repeat
            if source == "" then
                io.write(">> ")
            else
                io.write(".. ")
            end
            io.flush()  -- Ensure previous output is done before input
            line = io.read("*l")  -- Read a line
            line = elimSpace(line)
        until line ~= ""

        -- Check for commands
        if line == nil                 -- Read error (EOF?)
           or line == "exit" then      -- Exit command
            io.write("\n")
            break
        elseif line == "help" then
            source = ""
            printHelp()
        else
            -- Parse
            source = source .. line
            good, done, ast = rdparser3.parse(source)

            -- Handle results of parse
            if good then
                if done then
                    -- good, done: CORRECT PARSE; EVALUATE
                    result = evaluator.eval(ast, varValues)
                    io.write(result,"\n")
                    source = ""
                    updateRecent(result)
                else
                    -- good, not done: EXTRA CHARS @ END
                    errMsg("Syntax error (extra characters at end)")
                    source = ""
                end
            else
                if done then
                    -- not good, done: INCOMPLETE
                    source = source .. "\n"
                else
                    -- not good, not done: SYNTAX ERROR
                    errMsg("Syntax error")
                    source = ""
                end
            end
        end

    end
end


-- ***** Main Program *****


io.write("\n")
repl()  -- Run our REPL

