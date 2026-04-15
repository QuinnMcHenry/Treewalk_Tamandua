#!/usr/bin/env lua
-- interpit_test.lua
-- Glenn G. Chappell
-- 2026-04-06
--
-- For CS 331 Spring 2026
-- Test Program for Module interpit
-- Used in Assignment 6, Exercise A

interpit = require "interpit"  -- Import interpit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

EXIT_ON_FIRST_FAILURE = false
-- If EXIT_ON_FIRST_FAILURE is true, then this program exits after the
-- first failing test. If it is false, then this program executes all
-- tests, reporting success/failure for each.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

-- To print output for a test using tester object:
-- (1) Call tester:test1, passing the name of the test (string).
-- (2) Call tester:test2, passing success/failure (boolean).
-- The test may be done, and success determined, between the two calls.
-- Call tester:allPassed to find whether all tests passed.

function tester.test1(self, testName)
    io.write("    Test: ", testName, " - ")
    io.flush()  -- Flush output
end

function tester.test2(self, success)
    self.countTests = self.countTests+1
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


-- terminate
-- Called to end the program. Currently simply ends. To make the program
-- prompt the user and wait for the user to press ENTER, uncomment the
-- commented-out lines in the function body. The parameter is the
-- program's return value.
function terminate(status)
    -- Uncomment to following to wait for the user before terminating.
    --io.write("\nPress ENTER to quit ")
    --io.read("*l")

    os.exit(status)
end


function failExit()
    if EXIT_ON_FIRST_FAILURE then
        io.write("**************************************************\n")
        io.write("* This test program is configured to exit after  *\n")
        io.write("* the first failing test. To make it execute all *\n")
        io.write("* tests, reporting success/failure for each, set *\n")
        io.write("* variable                                       *\n")
        io.write("*                                                *\n")
        io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
        io.write("*                                                *\n")
        io.write("* to false, near the start of the test program.  *\n")
        io.write("**************************************************\n")

        -- Terminate program, signaling error
        terminate(1)
    end
end


function endMessage(passed)
    if passed then
        io.write("All tests successful\n")
    else
        io.write("Tests ********** UNSUCCESSFUL **********\n")
        io.write("\n")
        io.write("**************************************************\n")
        io.write("* This test program is configured to execute all *\n")
        io.write("* tests, reporting success/failure for each. To  *\n")
        io.write("* make it exit after the first failing test, set *\n")
        io.write("* variable                                       *\n")
        io.write("*                                                *\n")
        io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
        io.write("*                                                *\n")
        io.write("* to true, near the start of the test program.   *\n")
        io.write("**************************************************\n")
    end
end


-- printValue
-- Given a value, print it in (roughly) Lua literal notation if it is
-- nil, number, string, boolean, or table -- calling this function
-- recursively for table keys and values. For other types, print an
-- indication of the type. The second argument, if passed, is max_items:
-- the maximum number of items in a table to print.
function printValue(...)
    assert(select("#", ...) == 1 or select("#", ...) == 2,
           "printValue: must pass 1 or 2 arguments")
    local x, max_items = select(1, ...)  -- Get args (may be nil)
    if type(max_items) ~= "nil" and type(max_items) ~= "number" then
        error("printValue: max_items must be a number")
    end

    if type(x) == "nil" then
        io.write("nil")
    elseif type(x) == "number" then
        io.write(x)
    elseif type(x) == "string" then
        io.write(string.format('%q', x))
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) ~= "table" then
        io.write('<', type(x), '>')
    else  -- type is "table"
        io.write("{")
        local first = true  -- First iteration of loop?
        local key_count, unprinted_count = 0, 0
        for k, v in pairs(x) do
            key_count = key_count + 1
            if max_items ~= nil and key_count > max_items then
                unprinted_count = unprinted_count + 1
            else
                if first then
                    first = false
                else
                    io.write(",")
                end
                io.write(" [")
                printValue(k, max_items)
                io.write("]=")
                printValue(v, max_items)
            end
        end
        if unprinted_count > 0 then
            if first then
                first = false
            else
                io.write(",")
            end
            io.write(" <<", unprinted_count)
            if key_count - unprinted_count > 0 then
                io.write(" more")
            end
            if unprinted_count == 1 then
                io.write(" item>>")
            else
                io.write(" items>>")
            end
        end
        io.write(" }")
    end
end


-- printArray
-- Like printValue, but prints top-level tables as arrays.
-- Uses printValue.
-- The second argument, if passed, is max_items: the maximum number of
-- items in a table to print.
function printArray(...)
    assert(select("#", ...) == 1 or select("#", ...) == 2,
           "printArray: must pass 1 or 2 arguments")
    local x, max_items = select(1, ...)  -- Get args (may be nil)
    if type(max_items) ~= "nil" and type(max_items) ~= "number" then
        error("printArray: max_items must be a number")
    end

    if type(x) ~= "table" then
        printValue(x, max_items)
    else
        io.write("{")
        local first = true  -- First iteration of loop?
        local key_count, unprinted_count = 0, 0
        for k, v in ipairs(x) do
            key_count = key_count + 1
            if max_items ~= nil and key_count > max_items then
                unprinted_count = unprinted_count + 1
            else
                if first then
                    first = false
                else
                    io.write(",")
                end
                io.write(" ")
                printValue(v, max_items)
            end
        end
        if unprinted_count > 0 then
            if first then
                first = false
            else
                io.write(",")
            end
            io.write(" <<", unprinted_count)
            if key_count - unprinted_count > 0 then
                io.write(" more")
            end
            if unprinted_count == 1 then
                io.write(" item>>")
            else
                io.write(" items>>")
            end
        end
        io.write(" }")
    end
end


-- numKeys
-- Given a table, return the number of keys in it.
function numKeys(tab)
    local keycount = 0
    for k, v in pairs(tab) do
        keycount = keycount + 1
    end
    return keycount
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


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Symbolic Constants for AST
-- Names differ from those in assignment, to avoid interference.
local PROGRAMx     = 1
local EMPTYxSTMT   = 2
local PRINTxSTMT   = 3
local PRINTLNxSTMT = 4
local RETURNxSTMT  = 5
local INCxSTMT     = 6
local DECxSTMT     = 7
local ASSNxSTMT    = 8
local FUNCxCALL    = 9
local FUNCxDEF     = 10
local IFxSTMT      = 11
local WHILExLOOP   = 12
local STRLITxOUT   = 13
local CHRxCALL     = 14
local BINxOP       = 15
local UNxOP        = 16
local NUMLITxVAL   = 17
local READxCALL    = 18
local RNDxCALL     = 19
local SIMPLExVAR   = 20
local ARRAYxVAR    = 21


-- deepcopy
-- Returns deep copy of given value.
-- From http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- isState
-- Return true if given value is properly formatted Nilgai state table,
-- false otherwise.
function isState(tab)
    -- Is table?
    if type(tab) ~= "table" then
        return false
    end

    -- Has exactly 3 keys?
    if numKeys(tab) ~= 3 then
        return false
    end

    -- Has f, v, a keys?
    if tab.f == nil or tab.v == nil or tab.a == nil then
        return false
    end

    -- f, v, a keys are tables?
    if type(tab.f) ~= "table"
      or type(tab.v) ~= "table"
      or type(tab.a) ~= "table" then
        return false
    end

    -- All items in f are string:table
    -- String begins with "[_A-Za-z]"
    for k, v in pairs(tab.f) do
        if type(k) ~= "string" or type(v) ~= "table" then
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            return false
        end
    end

    -- All items in v are string:number
    -- String begins with "[_A-Za-z]"
    for k, v in pairs(tab.v) do
        if type(k) ~= "string" or type(v) ~= "number" then
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            return false
        end
    end

    -- All items in a are string:table
    -- String begins with "[_A-Za-z]"
    -- All items in values in a are number:number
    for k, v in pairs(tab.a) do
        if type(k) ~= "string" or type(v) ~= "table" then
            return false
        end
        if k:sub(1,1) ~= "_"
           and (k:sub(1,1) < "A" or k:sub(1,1) > "Z")
           and (k:sub(1,1) < "a" or k:sub(1,1) > "z") then
            return false
        end
        for kk, vv in pairs(v) do
            if type(kk) ~= "number" or type(vv) ~= "number" then
                return false
            end
        end
    end

    return true
end


-- checkInterp
-- Given tester object, string giving name of the test, AST, input
-- state, expected output state, array of input strings, array of
-- expected output strings, and OPTIONAL array of expected parameters
-- for random and array of random numbers to return. Calls
-- interpit.interp and checks whether its behavior matches expectations.
-- Prints result. If test fails and EXIT_ON_FIRST_FAILURE is true, then
-- print detailed results and exits program.
function checkInterp(t, testname, ast,
                     statein, expstateout,
                     input, expoutput,
                     exprndargs, rndout)  -- Optional parameters

    t:test1(testname)

    -- Error flags
    local err_incallparam = false
    local err_outcallnil = false
    local err_outcallnonstr = false
    local err_rndcallnil = false
    local err_rndcallnonnum = false

    if exprndargs == nil then
        exprndargs = {}
    end
    if rndout == nil then
        rndout = {}
    end

    local util = {}

    local incount = 0
    function util.input(param)
        if param ~= nil then
            err_incallparam = true
        end
        incount = incount + 1
        if incount <= #input then
            return input[incount]
        else
            return ""
        end
    end

    local output = {}
    function util.output(str)
        if type(str) == "string" then
            table.insert(output, str)
        elseif str == nil then
            err_outcallnil = true
            table.insert(output, "")
        else
            err_outcallnonstr = true
            table.insert(output, "")
        end
    end

    local rndparams = {}
    local rndcount = 0
    function util.random(n)
        if n == nil then
            err_rndcallnil = true
        elseif type(n) ~= "number" then
            err_rndcallnonnum = true
        end
        rndcount = rndcount + 1
        rndparams[rndcount] = n
        if rndcount <= #rndout then
            return rndout[rndcount]
        else
            return 0
        end
    end

    local pass = true
    local msg = ""

    local success, result = pcall(interpit.interp,
                                  ast, statein, util)
    if not success then
        pass = false
        msg = msg.."interpit.interp crashed:".."\n  "..result.."\n"
    else
        local stateout = result

        if incount > #input then
            pass = false
            msg = msg .. "Too many calls to util.input\n"
        elseif incount < #input then
            pass = false
            msg = msg .. "Too few calls to util.input\n"
        end

        if err_incallparam then
            pass = false
            msg = msg .. "util.input called with parameter\n"
        end

        if #output > #expoutput then
            pass = false
            msg = msg .. "Too many calls to util.output\n"
        elseif #output < #expoutput then
            pass = false
            msg = msg .. "Too few calls to util.output\n"
        end

        if err_outcallnil then
            pass = false
            msg = msg ..
                 "util.output called with nil or missing parameter\n"
        end
        if err_outcallnonstr then
            pass = false
            msg = msg .. "util.output called"
                      .. " with non-string parameter\n"
        end

        if not equal(output, expoutput) then
            pass = false
            msg = msg .. "Output incorrect\n"
        end

        if err_rndcallnil then
            pass = false
            msg = msg .. "util.random called"
                      .. " with nil or missing parameter\n"
        end
        if err_rndcallnonnum then
            pass = false
            msg = msg .. "util.random called"
                      .. " with non-number parameter\n"
        end

        if rndcount > #exprndargs then
            pass = false
            msg = msg .. "Too many calls to util.random\n"
        elseif rndcount < #exprndargs then
            pass = false
            msg = msg .. "Too few calls to util.random\n"
        elseif not equal(rndparams, exprndargs) then
            pass = false
            msg = msg .. "Parameters to util.random incorrect\n"
        end

        if isState(stateout) then
            if not equal(stateout, expstateout) then
                pass = false
                msg = msg .. "Returned state is incorrect\n"
            end
        else
            pass = false
            msg = msg .. "Returned state is not a Nilgai state\n"
        end
    end

    t:test2(pass)
    if pass or not EXIT_ON_FIRST_FAILURE then
        return
    end

    io.write("\n")
    io.write(msg)
    io.write("\n")
    failExit()
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_pre_written(t)
    io.write("Test Suite: programs that work with pre-written"
             .." interpit.lua\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Empty program
    ast = {PROGRAMx}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Empty program",
      ast, statein, expstateout, input, expoutput)

    -- Empty statement
    ast = {PROGRAMx, {EMPTYxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Empty statement",
      ast, statein, expstateout, input, expoutput)

    -- Empty statements
    ast = {PROGRAMx, {EMPTYxSTMT}, {EMPTYxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "2 empty statements",
      ast, statein, expstateout, input, expoutput)

    -- Empty output
    ast = {PROGRAMx, {PRINTxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output nothing",
      ast, statein, expstateout, input, expoutput)

    -- Output newline
    ast = {PROGRAMx, {PRINTLNxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output newline",
      ast, statein, expstateout, input, expoutput)

    -- Output: empty string
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '""'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {""}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: empty string",
      ast, statein, expstateout, input, expoutput)

    -- Output: string, double-quoted
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"def"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"def"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: string, double-quoted",
      ast, statein, expstateout, input, expoutput)

    -- Output: string, single-quoted
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, "'def'"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"def"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: string, single-quoted",
      ast, statein, expstateout, input, expoutput)

    -- Output: string + newline
    ast = {PROGRAMx, {PRINTLNxSTMT, {STRLITxOUT, '"ghi"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"ghi","\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: string, double-quoted",
      ast, statein, expstateout, input, expoutput)

    -- Output: string + string
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"abc"'},
      {STRLITxOUT, '"def"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc", "def"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: string + string",
      ast, statein, expstateout, input, expoutput)

    -- Output: number
    ast = {PROGRAMx, {PRINTxSTMT, {NUMLITxVAL, "999"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"999"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: number",
      ast, statein, expstateout, input, expoutput)

    -- Output: number + number + mumber
    ast = {PROGRAMx, {PRINTxSTMT, {NUMLITxVAL, "78"},
          {NUMLITxVAL, "78e2"}, {NUMLITxVAL, "78e+4"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"78", "7800", "780000"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: number + number + number",
      ast, statein, expstateout, input, expoutput)

    -- Output: string + number + number + string
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"abc"'},
      {NUMLITxVAL, "045"}, {NUMLITxVAL, "1"}, {STRLITxOUT, '"x"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc", "45", "1", "x"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output: string + number + number + string",
      ast, statein, expstateout, input, expoutput)

    -- Func, no call
    ast = {PROGRAMx, {FUNCxDEF, "x",
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, f={["x"]={PROGRAMx,
      {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}}}
    checkInterp(t, "Func, no call",
      ast, statein, expstateout, input, expoutput)

    -- Call, no func
    ast = {PROGRAMx, {FUNCxCALL, "x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Call, no func",
      ast, statein, expstateout, input, expoutput)

    -- Func with call (wrong name)
    ast = {PROGRAMx, {FUNCxDEF, "x",
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}},
      {FUNCxCALL, "y"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, f={["x"]={PROGRAMx,
      {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}}}
    checkInterp(t, "Func with call (wrong name)",
      ast, statein, expstateout, input, expoutput)

    -- Func with call (right name)
    ast = {PROGRAMx, {FUNCxDEF, "x",
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}},
      {FUNCxCALL, "x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc"}
    expstateout = {v={}, a={}, f={["x"]={PROGRAMx,
      {PRINTxSTMT, {STRLITxOUT, '"abc"'}}}}}
    checkInterp(t, "Func with call (right name)",
      ast, statein, expstateout, input, expoutput)

    -- Func defs func, no call
    ast = {PROGRAMx, {FUNCxDEF, "x",
      {PROGRAMx, {FUNCxDEF, "y", {PROGRAMx}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, f={["x"]={PROGRAMx,
      {FUNCxDEF, "y", {PROGRAMx}}}}}
    checkInterp(t, "Func defs func, no call",
      ast, statein, expstateout, input, expoutput)

    -- Func defs func, with call
    ast = {PROGRAMx, {FUNCxDEF, "x",
      {PROGRAMx, {FUNCxDEF, "y", {PROGRAMx}}}},
      {FUNCxCALL, "x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, f={["x"]={PROGRAMx,
      {FUNCxDEF, "y", {PROGRAMx}}},
      ["y"]={PROGRAMx}}}
    checkInterp(t, "Func defs func, with call",
      ast, statein, expstateout, input, expoutput)
end


function test_simple(t)
    io.write("Test Suite: simple programs\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Simple assignment: number
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "a"},
      {NUMLITxVAL, "12"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["a"]=12}, a={}, f={}}
    checkInterp(t, "Simple assignment: number",
      ast, statein, expstateout, input, expoutput)

    -- Simple if #1
    ast = {PROGRAMx, {IFxSTMT, {NUMLITxVAL, "0"}, {PROGRAMx}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Simple if #1",
      ast, statein, expstateout, input, expoutput)

    -- Simple if #2
    ast = {PROGRAMx, {IFxSTMT, {NUMLITxVAL, "4"}, {PROGRAMx}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Simple if #2",
      ast, statein, expstateout, input, expoutput)

    -- Simple while
    ast = {PROGRAMx, {WHILExLOOP, {NUMLITxVAL, "0"}, {PROGRAMx}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Simple while",
      ast, statein, expstateout, input, expoutput)

    -- Output: undefined variable
    ast = {PROGRAMx, {PRINTxSTMT, {SIMPLExVAR, "d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Output: undefined variable",
      ast, statein, expstateout, input, expoutput)

   -- Simple input
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "b"},
      {READxCALL}}}
    input = {"37"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["b"]=37}, a={}, f={}}
    checkInterp(t, "Simple input",
      ast, statein, expstateout, input, expoutput)

    -- Set + output: variable
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "c"},
      {NUMLITxVAL, "57"}}, {PRINTxSTMT, {SIMPLExVAR, "c"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"57"}
    expstateout = {v={["c"]=57}, a={}, f={}}
    checkInterp(t, "Set + output: variable",
      ast, statein, expstateout, input, expoutput)

    -- Set + output: other variable
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "c"},
      {NUMLITxVAL, "57"}}, {PRINTxSTMT, {SIMPLExVAR, "d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {v={["c"]=57}, a={}, f={}}
    checkInterp(t, "Set + output: other variable",
      ast, statein, expstateout, input, expoutput)

    -- Set + output: var, number, eol
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "x"}, {NUMLITxVAL, "5"}},
      {PRINTLNxSTMT, {SIMPLExVAR, "x"}, {NUMLITxVAL, "28"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"5", "28", "\n"}
    expstateout = {v={["x"]=5}, a={}, f={}}
    checkInterp(t, "Set + output: var + number + eol",
      ast, statein, expstateout, input, expoutput)

    -- Input + output: variable
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "c"},
      {READxCALL}}, {PRINTxSTMT, {SIMPLExVAR, "c"}}}
    input = {"12"}
    statein = deepcopy(emptystate)
    expoutput = {"12"}
    expstateout = {v={["c"]=12}, a={}, f={}}
    checkInterp(t, "Input + output: variable",
      ast, statein, expstateout, input, expoutput)

    -- Input + output: other variable
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "c"},
      {READxCALL}}, {PRINTxSTMT, {SIMPLExVAR, "d"}}}
    input = {"24"}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {v={["c"]=24}, a={}, f={}}
    checkInterp(t, "Input + output: other variable",
      ast, statein, expstateout, input, expoutput)

    -- Set array
    ast = {PROGRAMx, {ASSNxSTMT,
      {ARRAYxVAR, "a", {NUMLITxVAL, "2"}},
      {NUMLITxVAL, "7"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={["a"]={[2]=7}}, f={}}
    checkInterp(t, "Set array",
      ast, statein, expstateout, input, expoutput)
end


function test_state(t)
    io.write("Test Suite: modified initial state\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Empty program
    ast = {PROGRAMx}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: empty program",
      ast, statein, expstateout, input, expoutput)

    -- Set simple var #1
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "a"}, {NUMLITxVAL, "3"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = {v={["a"]=3,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    checkInterp(t, "Modified initial state: set simple var #1",
      ast, statein, expstateout, input, expoutput)

    -- Set simple var #2
    ast = {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "c"}, {NUMLITxVAL, "3"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = {v={["a"]=1,["b"]=2,["c"]=3},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    checkInterp(t, "Modified initial state: set simple var #2",
      ast, statein, expstateout, input, expoutput)

    -- Set array #1
    ast = {PROGRAMx, {ASSNxSTMT,
      {ARRAYxVAR, "b", {NUMLITxVAL, "2"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=9,[4]=3}}, f={}}
    checkInterp(t, "Modified initial state: set array #1",
      ast, statein, expstateout, input, expoutput)

    -- Set array #2
    ast = {PROGRAMx, {ASSNxSTMT,
      {ARRAYxVAR, "b", {NUMLITxVAL, "-5"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3,[-5]=9}}, f={}}
    checkInterp(t, "Modified initial state: set array #2",
      ast, statein, expstateout, input, expoutput)

    -- Set array #3
    ast = {PROGRAMx, {ASSNxSTMT,
      {ARRAYxVAR, "c", {NUMLITxVAL, "0"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {}
    expstateout = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3},["c"]={[0]=9}},
      f={}}
    checkInterp(t, "Modified initial state: set array #3",
      ast, statein, expstateout, input, expoutput)

    -- Output simple var #1
    ast = {PROGRAMx, {PRINTxSTMT, {SIMPLExVAR, "a"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: Output simple var #1",
      ast, statein, expstateout, input, expoutput)

    -- Output simple var #2
    ast = {PROGRAMx, {PRINTxSTMT, {SIMPLExVAR, "c"}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: Output simple var #2",
      ast, statein, expstateout, input, expoutput)

    -- Output array #1
    ast = {PROGRAMx, {PRINTxSTMT, {ARRAYxVAR, "a",
      {NUMLITxVAL, "4"}}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: Output array #1",
      ast, statein, expstateout, input, expoutput)

    -- Output array #2
    ast = {PROGRAMx, {PRINTxSTMT, {ARRAYxVAR, "a",
      {NUMLITxVAL, "8"}}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: Output array #2",
      ast, statein, expstateout, input, expoutput)

    -- Output array #3
    ast = {PROGRAMx, {PRINTxSTMT, {ARRAYxVAR, "c",
      {NUMLITxVAL, "8"}}}}
    input = {}
    statein = {v={["a"]=1,["b"]=2},
      a={["a"]={[2]=3,[4]=7},["b"]={[2]=7,[4]=3}}, f={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Modified initial state: Output array #3",
      ast, statein, expstateout, input, expoutput)

    -- Output-set-output-input-output
    ast = {PROGRAMx,
      {PRINTxSTMT, {SIMPLExVAR, "abc"}},
      {ASSNxSTMT, {SIMPLExVAR, "abc"}, {NUMLITxVAL, "55"}},
      {PRINTxSTMT, {SIMPLExVAR, "abc"}},
      {ASSNxSTMT, {SIMPLExVAR, "abc"}, {READxCALL}},
      {PRINTxSTMT, {SIMPLExVAR, "abc"}}}
    input = {"66"}
    statein = {v={["abc"]=44}, a={}, f={}}
    expoutput = {"44", "55", "66"}
    expstateout = {v={["abc"]=66}, a={}, f={}}
    checkInterp(t, "Modified initial state: Out-set-out-in-out",
      ast, statein, expstateout, input, expoutput)

    -- Call func
    ast = {PROGRAMx, {FUNCxCALL, "q"}}
    input = {}
    statein = {v={}, a={}, f={["q"]=
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"x"'}}}
    }}
    expoutput = {"x"}
    expstateout = {v={}, a={}, f={["q"]=
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"x"'}}}
    }}
    checkInterp(t, "Modified initial state: Function",
      ast, statein, expstateout, input, expoutput)
end


function test_special_chars(t)
    io.write("Test Suite: output special characters\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- output with char()
    ast = {PROGRAMx, {PRINTxSTMT, {CHRxCALL, {NUMLITxVAL, "65"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"A"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output with char()",
      ast, statein, expstateout, input, expoutput)

    -- char() containing nontrivial expression
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}, {CHRxCALL,
      {{BINxOP, "+"}, {NUMLITxVAL, "60"}, {NUMLITxVAL, "6"}}},
      {STRLITxOUT, '"z"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a", "B", "z"}
    expstateout = deepcopy(statein)
    checkInterp(t, "char() containing nontrivial expression",
      ast, statein, expstateout, input, expoutput)

    -- char() containing out-of-range value #1
    ast = {PROGRAMx, {PRINTxSTMT, {CHRxCALL, {{UNxOP, "-"},
      {NUMLITxVAL, "1"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {string.char(0)}
    expstateout = deepcopy(statein)
    checkInterp(t, "char() containing out-of-range value #1",
      ast, statein, expstateout, input, expoutput)

    -- char() containing out-of-range value #2
    ast = {PROGRAMx, {PRINTxSTMT, {CHRxCALL, {NUMLITxVAL, "1000"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {string.char(0)}
    expstateout = deepcopy(statein)
    checkInterp(t, "char() containing out-of-range value #2",
      ast, statein, expstateout, input, expoutput)

    -- Output several special characters
    ast =
      {PROGRAMx,{PRINTLNxSTMT,{CHRxCALL,{NUMLITxVAL,"1"}},
        {CHRxCALL,{NUMLITxVAL,"2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {string.char(1), string.char(2), '\n'}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output several special characters",
      ast, statein, expstateout, input, expoutput)

    -- String with backslash
    ast = {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"\\n"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, "String with backslash",
      ast, statein, expstateout, input, expoutput)
end


function test_expr(t)
    io.write("Test Suite: expressions\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Output unary +
    ast = {PROGRAMx, {PRINTxSTMT,
      {{UNxOP, "+"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"5"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output unary +",
      ast, statein, expstateout, input, expoutput)

    -- Output unary -
    ast = {PROGRAMx, {PRINTxSTMT,
      {{UNxOP, "-"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-5"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output unary -",
      ast, statein, expstateout, input, expoutput)

    -- Output not #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{UNxOP, "!"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output not #1",
      ast, statein, expstateout, input, expoutput)

    -- Output not #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{UNxOP, "!"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output not #2",
      ast, statein, expstateout, input, expoutput)

    -- Output not not
    ast = {PROGRAMx, {PRINTxSTMT,
      {{UNxOP, "!"},{{UNxOP, "!"}, {NUMLITxVAL, "0"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output not not",
      ast, statein, expstateout, input, expoutput)

    -- Output binary +
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "+"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output binary +",
      ast, statein, expstateout, input, expoutput)

    -- Output binary -
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "-"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"3"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output binary -",
      ast, statein, expstateout, input, expoutput)

    -- Output *
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "*"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"10"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output *",
      ast, statein, expstateout, input, expoutput)

    -- Output /
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "/"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"2"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output /",
      ast, statein, expstateout, input, expoutput)

    -- Output / (div by zero)
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "/"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output / (div by zero)",
      ast, statein, expstateout, input, expoutput)

    -- Output %
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "%"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output %",
      ast, statein, expstateout, input, expoutput)

    -- Output % (div by zero)
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "%"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output % (div by zero)",
      ast, statein, expstateout, input, expoutput)

    -- Output == #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "=="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output == #1",
      ast, statein, expstateout, input, expoutput)

    -- Output == #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "=="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output == #2",
      ast, statein, expstateout, input, expoutput)

    -- Output != #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "!="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output != #1",
      ast, statein, expstateout, input, expoutput)

    -- Output != #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "!="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output != #2",
      ast, statein, expstateout, input, expoutput)

    -- Output < #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output < #1",
      ast, statein, expstateout, input, expoutput)

    -- Output < #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output < #2",
      ast, statein, expstateout, input, expoutput)

    -- Output < #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output < #3",
      ast, statein, expstateout, input, expoutput)

    -- Output <= #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output <= #1",
      ast, statein, expstateout, input, expoutput)

    -- Output <= #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output <= #2",
      ast, statein, expstateout, input, expoutput)

    -- Output <= #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output <= #3",
      ast, statein, expstateout, input, expoutput)

    -- Output > #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output > #1",
      ast, statein, expstateout, input, expoutput)

    -- Output > #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output > #2",
      ast, statein, expstateout, input, expoutput)

    -- Output > #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output > #3",
      ast, statein, expstateout, input, expoutput)

    -- Output >= #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output >= #1",
      ast, statein, expstateout, input, expoutput)

    -- Output >= #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output >= #2",
      ast, statein, expstateout, input, expoutput)

    -- Output >= #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output >= #3",
      ast, statein, expstateout, input, expoutput)

    -- Output && #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output && #1",
      ast, statein, expstateout, input, expoutput)

    -- Output && #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output && #2",
      ast, statein, expstateout, input, expoutput)

    -- Output && #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output && #3",
      ast, statein, expstateout, input, expoutput)

    -- Output && #4
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output && #4",
      ast, statein, expstateout, input, expoutput)

    -- Output || #1
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output || #1",
      ast, statein, expstateout, input, expoutput)

    -- Output || #2
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output || #2",
      ast, statein, expstateout, input, expoutput)

    -- Output || #3
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output || #3",
      ast, statein, expstateout, input, expoutput)

    -- Output || #4
    ast = {PROGRAMx, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Output || #4",
      ast, statein, expstateout, input, expoutput)

    -- Longer expression
    ast =
      {PROGRAMx,
        {PRINTxSTMT,
          {{UNxOP, "-"},
            {{BINxOP, "-"},
              {{BINxOP, "=="}, {SIMPLExVAR, "x"}, {NUMLITxVAL, "3"}},
              {{BINxOP, "*"},
                {{BINxOP, "+"},
                  {NUMLITxVAL, "8"},
                  {SIMPLExVAR, "x"}},
                {{UNxOP, "+"}, {SIMPLExVAR, "y"}}
              }
            }
          }
        }
      }
    input = {}
    statein = {v={["x"]=3, ["y"]=5}, a={}, f={}}
    expoutput = {"54"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Longer expression",
      ast, statein, expstateout, input, expoutput)
end


function test_intconv(t)
    io.write("Test Suite: integer conversion\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Numeric literal #1
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "n"}, {NUMLITxVAL, "5.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["n"]=5}, a={}, f={}}
    checkInterp(t, "Integer conversion: numeric literal #1",
      ast, statein, expstateout, input, expoutput)

    -- Numeric literal #2
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "n"}, {NUMLITxVAL, "-7.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["n"]=-7}, a={}, f={}}
    checkInterp(t, "Integer conversion: numeric literal #2",
      ast, statein, expstateout, input, expoutput)

    -- Numeric literal #3
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "n"}, {NUMLITxVAL, "5.74e1"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["n"]=57}, a={}, f={}}
    checkInterp(t, "Integer conversion: numeric literal #3",
      ast, statein, expstateout, input, expoutput)

    -- Input
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "n"}, {READxCALL}}
      }
    input = {"2.9"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["n"]=2}, a={}, f={}}
    checkInterp(t, "Integer conversion: input",
      ast, statein, expstateout, input, expoutput)

    -- Division + multiplication #1
    ast =
      {PROGRAMx,
        {PRINTxSTMT,
          {{BINxOP, "*"},
            {{BINxOP, "/"}, {NUMLITxVAL, "10"}, {NUMLITxVAL, "3"}},
            {NUMLITxVAL, "3"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"9"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Integer conversion: division + multiplication #1",
      ast, statein, expstateout, input, expoutput)

    -- Division + multiplication #2
    ast =
      {PROGRAMx,
        {PRINTxSTMT,
          {{BINxOP, "*"},
            {{BINxOP, "/"}, {NUMLITxVAL, "-3"}, {NUMLITxVAL, "2"}},
            {NUMLITxVAL, "2"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-2"}
    expstateout = deepcopy(statein)
    checkInterp(t, "Integer conversion: division + multiplication #2",
      ast, statein, expstateout, input, expoutput)
end


function test_if(t)
    io.write("Test Suite: if-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- If #1
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "4"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If #1",
      ast, statein, expstateout, input, expoutput)

    -- If #2
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If #2",
      ast, statein, expstateout, input, expoutput)

    -- If-else #1
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "5"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-else #1",
      ast, statein, expstateout, input, expoutput)

    -- If-else #2
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-else #2",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif #1
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "6"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "7"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif #1",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif #2
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "7"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif #2",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif #3
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif #3",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif-else #1
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "6"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "7"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif-else #1",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif-else #2
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "7"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif-else #2",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif-else #3
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif-else #3",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif*-else #1
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "8"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
      {NUMLITxVAL, "9"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"e"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"f"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif*-else #1",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif*-else #2
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
      {NUMLITxVAL, "9"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"e"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"f"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif*-else #2",
      ast, statein, expstateout, input, expoutput)

    -- If-elseif*-else #3
    ast = {PROGRAMx, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}},
      {NUMLITxVAL, "0"},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"e"'}}},
      {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"f"'}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"f"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "If-elseif*-else #3",
      ast, statein, expstateout, input, expoutput)

    -- Nested if-else #1
    ast =
      {PROGRAMx,
        {IFxSTMT,
          {NUMLITxVAL, "1"},
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}
            }
          },
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Nested if-else #1",
      ast, statein, expstateout, input, expoutput)

    -- Nested if-else #2
    ast =
      {PROGRAMx,
        {IFxSTMT,
          {NUMLITxVAL, "1"},
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}
            }
          },
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Nested if-else #2",
      ast, statein, expstateout, input, expoutput)

    -- Nested if-else #3
    ast =
      {PROGRAMx,
        {IFxSTMT,
          {NUMLITxVAL, "0"},
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}
            }
          },
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Nested if-else #3",
      ast, statein, expstateout, input, expoutput)

    -- Nested if-else #4
    ast =
      {PROGRAMx,
        {IFxSTMT,
          {NUMLITxVAL, "0"},
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"a"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"b"'}}}
            }
          },
          {PROGRAMx,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"c"'}}},
              {PROGRAMx, {PRINTxSTMT, {STRLITxOUT, '"d"'}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, "Nested if-else #4",
      ast, statein, expstateout, input, expoutput)
end


function test_while(t)
    io.write("Test Suite: while-loops\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- While loop: counted
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "i"}, {NUMLITxVAL, "0"}},
        {WHILExLOOP,
          {{BINxOP, "<"}, {SIMPLExVAR, "i"}, {NUMLITxVAL, "7"}},
          {PROGRAMx,
            {PRINTxSTMT,
              {{BINxOP, "*"}, {SIMPLExVAR, "i"}, {SIMPLExVAR, "i"}}
            },
            {ASSNxSTMT,
              {SIMPLExVAR, "i"},
              {{BINxOP, "+"}, {SIMPLExVAR, "i"}, {NUMLITxVAL, "1"}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0", "1", "4", "9", "16", "25", "36"}
    expstateout = {v={["i"]=7},a={}, f={}}
    checkInterp(t, "While loop: counted",
      ast, statein, expstateout, input, expoutput)

    -- While loop: input with sentinel
    ast =
      {PROGRAMx,
        {ASSNxSTMT, {SIMPLExVAR, "notdone"}, {NUMLITxVAL, "1"}},
        {WHILExLOOP,
          {SIMPLExVAR, "notdone"},
          {PROGRAMx,
            {ASSNxSTMT, {SIMPLExVAR, "n"}, {READxCALL}},
            {IFxSTMT,
              {{BINxOP, "=="}, {SIMPLExVAR, "n"}, {NUMLITxVAL, "99"}},
              {PROGRAMx,
                {ASSNxSTMT, {SIMPLExVAR, "notdone"}, {NUMLITxVAL, "0"}}
              },
              {PROGRAMx,
                {PRINTLNxSTMT, {SIMPLExVAR, "n"}}
              }
            }
          }
        },
        {PRINTLNxSTMT, {STRLITxOUT, '"Bye!"'}}
      }
    input = {"1", "8", "-17", "13.5", "99"}
    statein = deepcopy(emptystate)
    expoutput = {"1", "\n", "8", "\n", "-17", "\n", "13", "\n",
      "Bye!", "\n"}
    expstateout = {v={["notdone"]=0, ["n"]=99}, a={}, f={}}
    checkInterp(t, "While loop: input with sentinel",
      ast, statein, expstateout, input, expoutput)
end


function test_return(t)
    io.write("Test Suite: returning a value\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Writing a return value
    ast =
      {PROGRAMx,
        {FUNCxDEF, "sq",
          {PROGRAMx,
            {RETURNxSTMT,
              {{BINxOP, "*"}, {SIMPLExVAR, "a"}, {SIMPLExVAR, "a"}}
            }
          }
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {NUMLITxVAL, "7"}
        },
        {PRINTLNxSTMT,
          {FUNCxCALL, "sq"}
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"49","\n"}
    expstateout = {v={["a"]=7,["return"]=49}, a={}, f={["sq"]=
      {PROGRAMx, {RETURNxSTMT, {{BINxOP, "*"}, {SIMPLExVAR, "a"},
      {SIMPLExVAR, "a"}}}}
    }}
    checkInterp(t, "Writing a return value",
      ast, statein, expstateout, input, expoutput)

    -- Assigning a return value
    ast =
      {PROGRAMx,
        {FUNCxDEF, "sq",
          {PROGRAMx,
            {RETURNxSTMT,
              {{BINxOP, "*"}, {SIMPLExVAR, "a"}, {SIMPLExVAR, "a"}}
            }
          }
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {NUMLITxVAL, "7"}
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "c"},
          {FUNCxCALL, "sq"}
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["a"]=7,["c"]=49,["return"]=49}, a={}, f={["sq"]=
      {PROGRAMx, {RETURNxSTMT, {{BINxOP, "*"}, {SIMPLExVAR, "a"},
      {SIMPLExVAR, "a"}}}}
    }}
    checkInterp(t, "Assigning a return value",
      ast, statein, expstateout, input, expoutput)

    -- Returning a return value
    ast =
      {PROGRAMx,
        {FUNCxDEF, "p",
          {PROGRAMx,
            {RETURNxSTMT,
              {{BINxOP, "+"}, {SIMPLExVAR, "a"}, {NUMLITxVAL, "2"}}
            }
          }
        },
        {FUNCxDEF, "sq2",
          {PROGRAMx,
            {RETURNxSTMT,
              {{BINxOP, "*"}, {FUNCxCALL, "p"}, {FUNCxCALL, "p"}}
            }
          }
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {NUMLITxVAL, "7"}
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "c"},
          {FUNCxCALL, "sq2"}
        }
          }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["a"]=7,["c"]=81,["return"]=81}, a={}, f={["p"]=
      {PROGRAMx, {RETURNxSTMT, {{BINxOP, "+"}, {SIMPLExVAR, "a"},
      {NUMLITxVAL, "2"}}}},["sq2"]={PROGRAMx, {RETURNxSTMT,
      {{BINxOP, "*"}, {FUNCxCALL, "p"}, {FUNCxCALL, "p"}}}}
    }}
    checkInterp(t, "Returning a return value",
      ast, statein, expstateout, input, expoutput)

    -- Returning a value that is not used
    ast =
      {PROGRAMx,
        {FUNCxDEF, "sq",
          {PROGRAMx,
            {RETURNxSTMT,
              {{BINxOP, "*"}, {SIMPLExVAR, "a"}, {SIMPLExVAR, "a"}}
            }
          }
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {NUMLITxVAL, "7"}
        },
        {FUNCxCALL, "sq"},
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["a"]=7,["return"]=49}, a={}, f={["sq"]=
      {PROGRAMx, {RETURNxSTMT, {{BINxOP, "*"}, {SIMPLExVAR, "a"},
      {SIMPLExVAR, "a"}}}}
    }}
    checkInterp(t, "Returning a value that is not used",
      ast, statein, expstateout, input, expoutput)

    -- Using a return value when nothing is returned
    ast =
      {PROGRAMx,
        {FUNCxDEF, "f",
          {PROGRAMx,
            {ASSNxSTMT,
              {SIMPLExVAR, "b"},
              {{BINxOP, "*"}, {SIMPLExVAR, "a"}, {SIMPLExVAR, "a"}}
            }
          }
        },
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {NUMLITxVAL, "7"}
        },
        {PRINTLNxSTMT,
          {FUNCxCALL, "f"}
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0","\n"}
    expstateout = {v={["a"]=7,["b"]=49}, a={}, f={["f"]=
      {PROGRAMx, {ASSNxSTMT, {SIMPLExVAR, "b"}, {{BINxOP, "*"},
      {SIMPLExVAR, "a"}, {SIMPLExVAR, "a"}}}}
    }}
    checkInterp(t, "Using a return value when nothing is returned",
      ast, statein, expstateout, input, expoutput)

    -- Using a previous return value
    ast =
      {PROGRAMx,
        {FUNCxDEF, "f",
          {PROGRAMx,
            {RETURNxSTMT,
              {NUMLITxVAL, "8"}
            }
          }
        },
        {FUNCxDEF, "g",
          {PROGRAMx,
            {PRINTxSTMT,
              {STRLITxOUT, '"x"'}
            }
          }
        },
        {FUNCxCALL, "f"},
        {ASSNxSTMT,
          {SIMPLExVAR, "a"},
          {FUNCxCALL, "g"}
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"x"}
    expstateout = {v={["a"]=8,["return"]=8}, a={}, f={["f"]={PROGRAMx,
      {RETURNxSTMT, {NUMLITxVAL, "8"}}}, ["g"]={PROGRAMx, {PRINTxSTMT,
      {STRLITxOUT, '"x"'}}}
    }}
    checkInterp(t, "Using a previous return value",
      ast, statein, expstateout, input, expoutput)
end


function test_rnd(t)
    io.write("Test Suite: random numbers\n")

    local ast, statein, expoutput, expstateout, exprndargs, rndout
    local emptystate = {v={}, a={}, f={}}

    -- Single rnd call
    ast = {PROGRAMx, {PRINTxSTMT, {RNDxCALL, {NUMLITxVAL, "10"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"5"}
    expstateout = deepcopy(statein)
    exprndargs = {10}
    rndout = {5}
    checkInterp(t, "Single rnd call",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    -- Many rnd calls
    ast =
      {PROGRAMx,
        {ASSNxSTMT,
          {SIMPLExVAR, "i"},
          {NUMLITxVAL, "0"}
        },
        {WHILExLOOP,
          {{BINxOP, "<"}, {SIMPLExVAR, "i"}, {NUMLITxVAL, "100"}},
          {PROGRAMx,
            {PRINTxSTMT, {RNDxCALL, {SIMPLExVAR, "i"}}},
            {ASSNxSTMT,
              {SIMPLExVAR, "i"},
              {{BINxOP, "+"}, {SIMPLExVAR, "i"}, {NUMLITxVAL, "1"}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0", "0", "1", "0", "2", "0", "3", "0", "4", "0", "5",
                 "0", "6", "0", "7", "0", "8", "0", "9", "0", "10",
                 "0", "11", "0", "12", "0", "13", "0", "14", "0", "15",
                 "0", "16", "0", "17", "0", "18", "0", "19", "0", "20",
                 "0", "21", "0", "22", "0", "23", "0", "24", "0", "25",
                 "0", "26", "0", "27", "0", "28", "0", "29", "0", "30",
                 "0", "31", "0", "32", "0", "33", "0", "34", "0", "35",
                 "0", "36", "0", "37", "0", "38", "0", "39", "0", "40",
                 "0", "41", "0", "42", "0", "43", "0", "44", "0", "45",
                 "0", "46", "0", "47", "0", "48", "0", "49", "0"}
    expstateout = {v={["i"]=100}, a={}, f={}}
    exprndargs = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
                   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28,
                   29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
                   42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
                   55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67,
                   68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
                   81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93,
                   94, 95, 96, 97, 98, 99}
    rndout = {0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9,
               0, 10, 0, 11, 0, 12, 0, 13, 0, 14, 0, 15, 0, 16, 0, 17,
               0, 18, 0, 19, 0, 20, 0, 21, 0, 22, 0, 23, 0, 24, 0, 25,
               0, 26, 0, 27, 0, 28, 0, 29, 0, 30, 0, 31, 0, 32, 0, 33,
               0, 34, 0, 35, 0, 36, 0, 37, 0, 38, 0, 39, 0, 40, 0, 41,
               0, 42, 0, 43, 0, 44, 0, 45, 0, 46, 0, 47, 0, 48, 0, 49,
               0}
    checkInterp(t, "Many rnd calls",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    -- Recursive rnd calls
    ast =
      {PROGRAMx,
        {PRINTxSTMT,
          {RNDxCALL,
            {RNDxCALL,
              {{BINxOP, "+"},
                {NUMLITxVAL, "1"},
                {RNDxCALL,
                  {RNDxCALL,
                    {NUMLITxVAL,"10"}
                  }
                }
              }
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"2"}
    expstateout = deepcopy(statein)
    exprndargs = {10, 9, 8, 4}
    rndout = {9, 7, 4, 2}
    checkInterp(t, "Recursive rnd calls",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    -- rnd call on complex exprssion
    ast =
      {PROGRAMx,
        {ASSNxSTMT,
          {ARRAYxVAR, "x", {NUMLITxVAL, "3"}},
          {NUMLITxVAL, "7"}
        },
        {PRINTxSTMT,
          {RNDxCALL,
            {{BINxOP, "+"},
              {{BINxOP, "*"},
                {ARRAYxVAR, "x",
                  {{BINxOP, "+"},
                    {NUMLITxVAL, "1"},
                    {NUMLITxVAL, "2"}
                  }
                },
                {NUMLITxVAL, "4"}
              },
              {{BINxOP, "*"}, {NUMLITxVAL, "7"}, {READxCALL}}
            }
          }
        }
      }
    input = {"11"}
    statein = deepcopy(emptystate)
    expoutput = {"73"}
    expstateout = {v={}, a={x={[3]=7}}, f={}}
    exprndargs = {105}
    rndout = {73}
    checkInterp(t, "rnd call on complex expression",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)
end


function test_incdec(t)
    io.write("Test Suite: increment & decrement statements\n")

    local ast, statein, expstateout, input, expoutput, exprndargs,
          rndout
    local emptystate = {v={}, a={}, f={}}

    ast = {PROGRAMx,{ASSNxSTMT,{SIMPLExVAR,"a"},{NUMLITxVAL,"2"}},
            {INCxSTMT,{SIMPLExVAR,"a"}}}
    statein = deepcopy(emptystate)
    statein.v["x"]=1
    expstateout = {v={["a"]=3,["x"]=1}, a={}, f={}}
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Increment simple variable",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    ast = {PROGRAMx,{ASSNxSTMT,{SIMPLExVAR,"b"},{NUMLITxVAL,"5"}},
            {DECxSTMT,{SIMPLExVAR,"b"}}}
    statein = deepcopy(emptystate)
    statein.v["x"]=7
    expstateout = {v={["b"]=4,["x"]=7}, a={}, f={}}
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Decrement simple variable",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    ast = {PROGRAMx,{ASSNxSTMT,{ARRAYxVAR,"c",{NUMLITxVAL,"1"}},
            {NUMLITxVAL,"2"}},{INCxSTMT,{ARRAYxVAR,"c",
            {NUMLITxVAL,"1"}}}}
    statein = deepcopy(emptystate)
    expstateout = {v={}, a={["c"]={[1]=3}}, f={}}
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Increment array item",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    ast = {PROGRAMx,{ASSNxSTMT,{ARRAYxVAR,"d",{NUMLITxVAL,"2"}},
            {NUMLITxVAL,"8"}},{DECxSTMT,{ARRAYxVAR,"d",
            {NUMLITxVAL,"2"}}}}
    statein = deepcopy(emptystate)
    expstateout = {v={}, a={["d"]={[2]=7}}, f={}}
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Decrement array item",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    ast = {PROGRAMx,{FUNCxDEF,"f",{PROGRAMx,{INCxSTMT,{ARRAYxVAR,"a",
            {NUMLITxVAL,"3"}}},{RETURNxSTMT,{NUMLITxVAL,"3"}}}},
            {ASSNxSTMT,{ARRAYxVAR,"a",{NUMLITxVAL,"3"}},
            {NUMLITxVAL,"7"}},{INCxSTMT,{ARRAYxVAR,"a",
            {FUNCxCALL,"f"}}}}
    statein = deepcopy(emptystate)
    expstateout = {v={["return"]=3}, a={["a"]={[3]=9}},
                   f={["f"]={PROGRAMx,{INCxSTMT,{ARRAYxVAR,"a",
                     {NUMLITxVAL,"3"}}},{RETURNxSTMT,
                     {NUMLITxVAL,"3"}}}}}
    statein = deepcopy(emptystate)
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Increment array item with side effect in index",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)

    ast = {PROGRAMx,{FUNCxDEF,"f",{PROGRAMx,{DECxSTMT,{ARRAYxVAR,"a",
            {NUMLITxVAL,"3"}}},{RETURNxSTMT,{NUMLITxVAL,"3"}}}},
            {ASSNxSTMT,{ARRAYxVAR,"a",{NUMLITxVAL,"3"}},
            {NUMLITxVAL,"7"}},{DECxSTMT,{ARRAYxVAR,"a",
            {FUNCxCALL,"f"}}}}
    statein = deepcopy(emptystate)
    expstateout = {v={["return"]=3}, a={["a"]={[3]=5}},
                   f={["f"]={PROGRAMx,{DECxSTMT,{ARRAYxVAR,"a",
                     {NUMLITxVAL,"3"}}},{RETURNxSTMT,
                     {NUMLITxVAL,"3"}}}}}
    statein = deepcopy(emptystate)
    input = {}
    expoutput = {}
    exprndargs = {}
    rndout = {}
    checkInterp(t, "Increment array item with side effect in index",
      ast, statein, expstateout, input, expoutput, exprndargs, rndout)
end


function test_fancy(t)
    io.write("Test Suite: fancy programs\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, f={}}

    -- Recursion
    ast =
      {PROGRAMx,
        {FUNCxDEF, "x",
          {PROGRAMx,
            {PRINTxSTMT, {SIMPLExVAR, "c"}},
            {ASSNxSTMT,
              {SIMPLExVAR, "c"},
              {{BINxOP, "-"}, {SIMPLExVAR, "c"}, {NUMLITxVAL, "1"}}
            },
            {IFxSTMT,
              {{BINxOP, ">"}, {SIMPLExVAR, "c"}, {NUMLITxVAL, "0"}},
              {PROGRAMx, {FUNCxCALL, "x"}}
            }
          }
        },
        {ASSNxSTMT, {SIMPLExVAR, "c"}, {NUMLITxVAL, "3"}},
        {FUNCxCALL, "x"}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"3", "2", "1"}
    expstateout = {v={["c"]=0}, a={}, f={["x"]=
      {PROGRAMx, {PRINTxSTMT, {SIMPLExVAR, "c"}},
      {ASSNxSTMT, {SIMPLExVAR, "c"},
      {{BINxOP, "-"}, {SIMPLExVAR, "c"}, {NUMLITxVAL, "1"}}},
      {IFxSTMT, {{BINxOP, ">"}, {SIMPLExVAR, "c"}, {NUMLITxVAL, "0"}},
      {PROGRAMx, {FUNCxCALL, "x"}}}}
    }}
    checkInterp(t, "Recursion",
      ast, statein, expstateout, input, expoutput)

    -- Using complex expression as array index
    ast =
      {PROGRAMx,
        {ASSNxSTMT,
          {SIMPLExVAR, "i"},
          {NUMLITxVAL, "0"}
        },
        {WHILExLOOP,
          {{BINxOP, "<"},
            {SIMPLExVAR, "i"},
            {NUMLITxVAL, "100"}
          },
          {PROGRAMx,
            {ASSNxSTMT,
              {ARRAYxVAR,
                "a",
                {{BINxOP, "=="},
                  {{BINxOP, "%"},
                    {SIMPLExVAR, "i"},
                    {NUMLITxVAL, "3"}
                  },
                  {NUMLITxVAL, "0"}
                }
              },
              {{BINxOP, "+"},
                {ARRAYxVAR,
                  "a",
                  {{BINxOP, "=="},
                    {{BINxOP, "%"},
                      {SIMPLExVAR, "i"},
                      {NUMLITxVAL, "3"}
                    },
                    {NUMLITxVAL, "0"}
                  }
                },
                {NUMLITxVAL, "1"}
              }
            },
            {ASSNxSTMT,
              {SIMPLExVAR, "i"},
              {{BINxOP, "+"},
                {SIMPLExVAR, "i"},
                {NUMLITxVAL, "1"}
              }
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["i"]=100}, a={["a"]={[0]=66,[1]=34}}, f={}}
    checkInterp(t, "Using complex expression as array index",
      ast, statein, expstateout, input, expoutput)

    -- Fibonacci example
    ast =
      {PROGRAMx,{FUNCxDEF,"fibo",{PROGRAMx,{ASSNxSTMT,
        {SIMPLExVAR,"currfib"},{NUMLITxVAL,"0"}},{ASSNxSTMT,
        {SIMPLExVAR,"nextfib"},{NUMLITxVAL,"1"}},{ASSNxSTMT,
        {SIMPLExVAR,"i"},{NUMLITxVAL,"0"}},{WHILExLOOP,{{BINxOP,"<"},
        {SIMPLExVAR,"i"},{SIMPLExVAR,"n"}},{PROGRAMx,{ASSNxSTMT,
        {SIMPLExVAR,"tmp"},{{BINxOP,"+"},{SIMPLExVAR,"currfib"},
        {SIMPLExVAR,"nextfib"}}},{ASSNxSTMT,{SIMPLExVAR,"currfib"},
        {SIMPLExVAR,"nextfib"}},{ASSNxSTMT,{SIMPLExVAR,"nextfib"},
        {SIMPLExVAR,"tmp"}},{INCxSTMT,{SIMPLExVAR,"i"}}}},{RETURNxSTMT,
        {SIMPLExVAR,"currfib"}}}},{ASSNxSTMT,
        {SIMPLExVAR,"how_many_to_print"},{NUMLITxVAL,"20"}},
        {PRINTLNxSTMT,{STRLITxOUT,'"Fibonacci Numbers"'}},{ASSNxSTMT,
        {SIMPLExVAR,"j"},{NUMLITxVAL,"0"}},{WHILExLOOP,{{BINxOP,"<"},
        {SIMPLExVAR,"j"},{SIMPLExVAR,"how_many_to_print"}},{PROGRAMx,
        {ASSNxSTMT,{SIMPLExVAR,"n"},{SIMPLExVAR,"j"}},{ASSNxSTMT,
        {SIMPLExVAR,"ff"},{FUNCxCALL,"fibo"}},{PRINTLNxSTMT,
        {STRLITxOUT,'"F("'},{SIMPLExVAR,"j"},{STRLITxOUT,'") = "'},
        {SIMPLExVAR,"ff"}},{INCxSTMT,{SIMPLExVAR,"j"}}}},
        {PRINTLNxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"Fibonacci Numbers", "\n",
                 "F(", "0", ") = ", "0", "\n",
                 "F(", "1", ") = ", "1", "\n",
                 "F(", "2", ") = ", "1", "\n",
                 "F(", "3", ") = ", "2", "\n",
                 "F(", "4", ") = ", "3", "\n",
                 "F(", "5", ") = ", "5", "\n",
                 "F(", "6", ") = ", "8", "\n",
                 "F(", "7", ") = ", "13", "\n",
                 "F(", "8", ") = ", "21", "\n",
                 "F(", "9", ") = ", "34", "\n",
                 "F(", "10", ") = ", "55", "\n",
                 "F(", "11", ") = ", "89", "\n",
                 "F(", "12", ") = ", "144", "\n",
                 "F(", "13", ") = ", "233", "\n",
                 "F(", "14", ") = ", "377", "\n",
                 "F(", "15", ") = ", "610", "\n",
                 "F(", "16", ") = ", "987", "\n",
                 "F(", "17", ") = ", "1597", "\n",
                 "F(", "18", ") = ", "2584", "\n",
                 "F(", "19", ") = ", "4181", "\n",
                 "\n"}
    expstateout = {["v"]={["return"]=4181,["j"]=20,["i"]=19,
      ["tmp"]=6765,["nextfib"]=6765,["n"]=19,["currfib"]=4181,
      ["how_many_to_print"]=20,["ff"]=4181},["a"]={},["f"]={["fibo"]=
        {PROGRAMx,{ASSNxSTMT,{SIMPLExVAR,"currfib"},{NUMLITxVAL,"0"}},
          {ASSNxSTMT,{SIMPLExVAR,"nextfib"},{NUMLITxVAL,"1"}},
          {ASSNxSTMT,{SIMPLExVAR,"i"},{NUMLITxVAL,"0"}},{WHILExLOOP,
          {{BINxOP,"<"},{SIMPLExVAR,"i"},{SIMPLExVAR,"n"}},{PROGRAMx,
          {ASSNxSTMT,{SIMPLExVAR,"tmp"},{{BINxOP,"+"},
          {SIMPLExVAR,"currfib"},{SIMPLExVAR,"nextfib"}}},{ASSNxSTMT,
          {SIMPLExVAR,"currfib"},{SIMPLExVAR,"nextfib"}},{ASSNxSTMT,
          {SIMPLExVAR,"nextfib"},{SIMPLExVAR,"tmp"}},{INCxSTMT,
          {SIMPLExVAR,"i"}}}},{RETURNxSTMT,{SIMPLExVAR,"currfib"}}}
    }}
    checkInterp(t, "Fibonacci example",
      ast, statein, expstateout, input, expoutput)
end


function test_interpit(t)
    io.write("TEST SUITES FOR MODULE interpit\n")
    test_pre_written(t)
    test_simple(t)
    test_state(t)
    test_special_chars(t)
    test_expr(t)
    test_intconv(t)
    test_if(t)
    test_while(t)
    test_return(t)
    test_rnd(t)
    test_incdec(t)
    test_fancy(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_interpit(tester)
io.write("\n")
endMessage(tester:allPassed())

-- Terminate program, signaling no error
terminate(0)

