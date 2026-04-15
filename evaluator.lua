-- evaluator.lua
-- Glenn G. Chappell
-- Started: 2026-04-02
-- Updated: 2026-04-03
--
-- For CS 331 Spring 2026
-- Evaluator for Arithmetic Expression AST (rdparser3.lua format)
-- See calculator.lua for a sample main program.


local evaluator = {}  -- Our module


-- Symbolic Constants for AST

local BIN_OP     = 1
local NUMLIT_VAL = 2
local SIMPLE_VAR = 3


-- Primary Function

-- evaluator.eval
-- Takes AST for an expression, in format specified in rdparser3.lua,
-- and table holding values of variables. Returns numeric value of
-- expression.
--
-- Example of a simple tree-walk interpreter.
function evaluator.eval(ast, vars)
    local literal, varname, result, op, arg1_val, arg2_val

    assert(type(ast) == "table")
    assert(type(vars) == "table")

    assert(#ast >= 2 and #ast <= 3)
    if ast[1] == NUMLIT_VAL then      -- Numeric literal
        assert(#ast == 2)
        literal = ast[2]
        assert(type(literal) == "string")
        return tonumber(literal)

    elseif ast[1] == SIMPLE_VAR then  -- Simple variable
        assert(#ast == 2)
        varname = ast[2]
        assert(type(varname) == "string")
        result = vars[varname]
        if result == nil then  -- Undefined variable has value 0
            result = 0
        end
        return result

    else                              -- Binary operator
        assert(#ast == 3)
        assert(type(ast[1]) == "table")
        assert(type(ast[2]) == "table")
        assert(type(ast[3]) == "table")
        assert(#ast[1] == 2)
        assert(ast[1][1] == BIN_OP)

        op = ast[1][2]
        assert(type(op) == "string")

        arg1_val = evaluator.eval(ast[2], vars)
        assert(type(arg1_val) == "number")

        arg2_val = evaluator.eval(ast[3], vars)
        assert(type(arg2_val) == "number")

        if op == "+" then
            return arg1_val + arg2_val
        elseif op == "-" then
            return arg1_val - arg2_val
        elseif op == "*" then
            return arg1_val * arg2_val
        elseif op == "/" then
            return arg1_val / arg2_val  -- Let Lua floating-point
                                        --  handle div by zero, etc.
        else
            assert(false, "Illegal binary operator in AST")
        end
    end
end


-- Module Export

return evaluator

