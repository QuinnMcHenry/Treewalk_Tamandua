-- parseit.lua  
-- Quinn D. McHenry
-- Started: 2026-02-20
-- Updated: 2026-02-22
--
-- Parser for Assignment 4
-- Requires lexit.lua

local lexit = require "lexit"

-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************

local parseit = {}  -- Our module

-- *********************************************************************
-- Variables
-- *********************************************************************

-- For lexer iteration
local iter          -- Iterator returned by lexit.lex
local state         -- State for above iterator (maybe not used)
local lexer_out_s   -- Return value #1 from above iterator
local lexer_out_c   -- Return value #2 from above iterator

-- For current lexeme
local lexcat = 0    -- Category of current lexeme:
                    --  one of categories below, or 0 for past the end
-- For last matched lexeme
local matched = ""  -- String form of last matched lexeme

-- *********************************************************************
-- Symbolic Constants for AST
-- *********************************************************************

local PROGRAM      = 1
local EMPTY_STMT   = 2
local PRINT_STMT   = 3
local PRINTLN_STMT = 4
local RETURN_STMT  = 5
local INC_STMT     = 6
local DEC_STMT     = 7
local ASSN_STMT    = 8
local FUNC_CALL    = 9
local FUNC_DEF     = 10
local IF_STMT      = 11
local WHILE_LOOP   = 12
local STRLIT_OUT   = 13
local CHR_CALL     = 14
local BIN_OP       = 15
local UN_OP        = 16
local NUMLIT_VAL   = 17
local READ_CALL    = 18
local RND_CALL     = 19
local SIMPLE_VAR   = 20
local ARRAY_VAR    = 21

-- *********************************************************************
-- Utility Functions
-- *********************************************************************

-- advance
-- Go to next lexeme and load it into lexstr, lexcat.
-- Must be called once before any parsing is done.
-- Function init must be called before this function is called.
local function advance()
    -- Advance the iterator
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)
    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
end

-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexit.lex(prog)
    advance()
end

-- atEnd
-- Return true if pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end

-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then set "matched" to the matched string, advance to next lexeme
-- & return true. If not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        matched = lexstr
        advance()
        return true
    else
        return false
    end
end

-- matchCat
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then set "matched" to the string form of the
-- matched lexeme, advance to next lexeme & return true. If not, then do
-- not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        matched = lexstr
        advance()
        return true
    else
        return false
    end
end

-- *********************************************************************
-- "local" Statements for Parsing Functions
-- *********************************************************************

local parse_program
local parse_statement
local parse_print_arg
local parse_expr
local parse_compare_expr
local parse_arith_expr
local parse_term
local parse_factor


-- *********************************************************************
-- The Parser: Function "parse" - EXPORTED
-- *********************************************************************


-- parse
-- Given program, initialize parser and call parsing function for start
-- symbol. Returns pair of booleans & AST. First boolean indicates
-- successful parse or not. Second boolean indicates whether the parser
-- reached the end of the input or not. AST is only valid if first
-- boolean is true.
function parseit.parse(prog)
    -- Initialization
    init(prog)

    -- Get results from parsing
    local good, ast = parse_program()  -- Parse start symbol
    local done = atEnd()

    -- And return them
    return good, done, ast
end

-- *********************************************************************
-- Parsing Functions
-- *********************************************************************

-- Each of the following is a parsing function for a nonterminal in the
-- grammar. Each function parses the nonterminal in its name and returns
-- a pair: boolean, AST. On a successul parse, the boolean is true, the
-- AST is valid, and the current lexeme is just past the end of the
-- string the nonterminal expanded into. Otherwise, the boolean is
-- false, the AST is not valid, and no guarantees are made about the
-- current lexeme. See the AST Specification in the Assignment 4
-- description for the format of the returned AST.

-- NOTE. Declare parsing functions "local" above, but not below. This
-- allows them to be called before their definitions.

-- parse_program
-- Parsing function for nonterminal "program".
-- Function init must be called before this function is called.
function parse_program()
    local good, ast, ast2

    ast = { PROGRAM }
    while lexstr == ";"
          or lexstr == "print"
          or lexstr == "println"
          or lexstr == "return"
          or lexstr == "++"
          or lexstr == "--"
          or lexcat == lexit.ID
          or lexstr == "func"
          or lexstr == "if"
          or lexstr == "while" do
        good, ast2 = parse_statement()
        if not good then
            return false, nil
        end

        table.insert(ast, ast2)
    end

    return true, ast
end

-- parse_statement
-- Parsing function for nonterminal "statement".
-- Function init must be called before this function is called.
function parse_statement()
    local stmtkind, good, ast1, ast2, saveid

    if matchString(";") then
        return true, { EMPTY_STMT }

    elseif matchString("print") or matchString("println") then
        if matched == "print" then
            stmtkind = PRINT_STMT
        else
            stmtkind = PRINTLN_STMT
        end
        if not matchString("(") then
            return false, nil
        end

        if matchString(")") then
            if not matchString(";") then
                return false, nil
            end
            return true, { stmtkind }
        end
        good, ast2 = parse_print_arg()
        if not good then
            return false, nil
        end

        ast1 = { stmtkind, ast2 }

        while matchString(",") do
            good, ast2 = parse_print_arg()
            if not good then
                return false, nil
            end
            table.insert(ast1, ast2)
        end
        if not matchString(")") then
            return false, nil
        end

        if not matchString(";") then
            return false, nil
        end
        return true, ast1

    -- RETURN -- 
    elseif matchString("return") then
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        if not matchString(";") then
            return false, nil
        end

        return true, { RETURN_STMT, ast1 }

    -- INC/DEC --
    elseif matchString("++") or matchString("--") then -- saw an inc/dec
        if matched == "++" then
            stmtkind = INC_STMT
        else
            stmtkind = DEC_STMT
        end
        if matchCat(lexit.ID) then -- must call inc/dec on an indentifier.
            saveid = matched
        else
            return false, nil
        end
        if matchString("[") then  -- case 1: identifer is an array variable
            good, ast1 = parse_expr()
            if not good then 
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            if not matchString(";") then
                return false, nil
            else
                return true, { stmtkind, {ARRAY_VAR, saveid, ast1 } }
            end
        elseif not matchString(";") then -- case 2: id is a simple variable.
            return false, nil
        else
            return true, { stmtkind, { SIMPLE_VAR, saveid } }
        end

    -- ASSIGNMENT - SIMPLE OR ARRAY VAR --            
    elseif matchCat(lexit.ID) then -- saw an id
        saveid = matched
        if matchString("(") then -- case 1: id is a function call
            if not matchString(")") then
                return false, nil
            end
            if not matchString(";") then
                return false, nil
            end
            return true, { FUNC_CALL, saveid }
        elseif matchString("[") then -- case 2: id is an array variable
            good, ast1 =  parse_expr()
            if not good then
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            if not matchString("=") then
                return false, nil
            end
            good, ast2 = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString(";") then
                return false, nil
            end
            return true, { ASSN_STMT, { ARRAY_VAR, saveid, ast1 }, ast2 }
        else                        -- case 3: id is a simple var assignment
            if not matchString("=") then
                return false, nil
            end
            good, ast1 = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString(";") then
                return false, nil
            end
            return true, { ASSN_STMT, { SIMPLE_VAR, saveid }, ast1 }
        end
        
    -- FUNC DEF -- 
    elseif matchString("func") then -- saw a func keyword
        if not matchCat(lexit.ID) then -- must have name
            return false, nil
        end
        saveid = matched
        if not matchString("(") then
            return false, nil
        end

        if not matchString(")") then
            return false, nil
        end

        if not matchString("{") then
            return false, nil
        end
        good, ast1 = parse_program()
        if not good then
            return false, nil
        end

        if not matchString("}") then
            return false, nil
        end
        return true, { FUNC_DEF, saveid, ast1 }

    -- WHILE LOOP -- 
    elseif matchString("while") then -- saw a while keyword
        if not matchString("(") then
            return false, nil
        end
        good, ast1 = parse_expr() -- while condition
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        if not matchString("{") then
            return false, nil
        end
        good, ast2 = parse_program() -- while body
        if not good then
            return false, nil
        end
        if not matchString("}") then
            return false, nil
        end
        return true, { WHILE_LOOP, ast1, ast2 }

    -- IF COND --
    elseif matchString("if") then -- saw an if keyword
        local ast
        if not matchString("(") then
            return false, nil
        end
        good, ast1 = parse_expr() -- if condition
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        if not matchString("{") then
            return false, nil
        end
        good, ast2 = parse_program() -- if body
        if not good then
            return false, nil
        end
        if not matchString("}") then
            return false, nil
        end
        ast = { IF_STMT, ast1, ast2 }

        -- ELSIF --
        while matchString("elsif") do
            if not matchString("(") then
                return false, nil
            end
            good, ast1 = parse_expr() -- elsif condition
            if not good then
                return false, nil
            end
            if not matchString(")") then
                return false, nil
            end
            if not matchString("{") then
                return false, nil
            end
            good, ast2 = parse_program() -- elsif body
            if not good then
                return false, nil
            end
            if not matchString("}") then
                return false, nil
            end
            table.insert(ast, ast1)
            table.insert(ast, ast2)
        end 
        
        -- ELSE --
        if matchString("else") then
            if not matchString("{") then
                return false, nil
            end
            good, ast1 = parse_program() -- else body 
            if not good then
                return false, nil
            end
            if not matchString("}") then
                return false, nil
            end
            table.insert(ast, ast1)
        end                   
        return true, ast

    else  
        return false, nil

    end
end

-- parse_print_arg
-- Parsing function for nonterminal "print_arg".
-- Function init must be called before this function is called.
function parse_print_arg()
    local good, ast
    if matchCat(lexit.STRLIT) then -- inside of print() or println() is a strlit
        return true, { STRLIT_OUT, matched }
    elseif matchString("chr") then
        if not matchString("(") then
            return false, nil
        end
        good, ast = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, { CHR_CALL, ast }
    else                        -- inside of print() or println() is not a strlit
        good, ast = parse_expr()
        if not good then
            return false, nil
        end
        return true, ast
    end
end

-- parse_expr
-- Parsing function for nonterminal "expr".
-- Function init must be called before this function is called.
function parse_expr() -- now we recursively descend the grammar
    local good, ast, saveop, newast
    good, ast = parse_compare_expr()
    if not good then
        return false, nil
    end
    
    while matchString("&&") or matchString("||") do
        saveop = matched
        good, newast = parse_compare_expr()
        if not good then 
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end

    return true, ast
end

-- parse_compare_expr
-- Parsing function for nonterminal "compare_expr".
-- Function init must be called before this function is called.
function parse_compare_expr()
    local good, ast, saveop, newast
    good, ast = parse_arith_expr()
    if not good then 
        return false, nil
    end
    while matchString("==") or matchString("!=") or matchString("<") or matchString("<=") or matchString(">") or matchString(">=") do
        saveop = matched
        good, newast = parse_arith_expr()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end

-- parse_arith_expr
-- Parsing function for nonterminal "arith_expr".
-- Function init must be called before this function is called.
function parse_arith_expr()
    local good, ast, saveop, newast
    good, ast = parse_term()
    if not good then
        return false, nil
    end
    while matchString("+") or matchString("-") do
        saveop = matched
        good, newast = parse_term()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end

-- parse_term
-- Parsing function for nonterminal "term".
-- Function init must be called before this function is called.
function parse_term()
    local good, ast, saveop, newast
    good, ast = parse_factor()
    if not good then
        return false, nil
    end
    while matchString("*") or matchString("/") or matchString("%") do
        saveop = matched
        good, newast = parse_factor()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end

-- parse_factor
-- Parsing function for nonterminal "factor".
-- Function init must be called before this function is called.
function parse_factor()
    local good, ast, saveop, saveid
    if matchString("+") or matchString("-") or matchString("!") then -- unaries
        saveop = matched
        good, ast = parse_factor() -- call self
        if not good then
            return false, nil
        end
        return true, { {UN_OP, saveop}, ast }
    elseif matchCat(lexit.NUMLIT) then
        return true, { NUMLIT_VAL, matched }
    elseif matchString("(") then
        good, ast = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, ast
    elseif matchString("readint") then
        if not matchString("(") then 
            return false, nil
        end
        if not matchString(")") then 
            return false, nil
        end
        return true, { READ_CALL }
    elseif matchString("rnd") then
        if not matchString("(") then
            return false, nil
        end
        good, ast = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, { RND_CALL, ast}
    elseif matchCat(lexit.ID) then
        saveid = matched
        if matchString("(") then
            if not matchString(")") then
                return false, nil
            end
            return true, { FUNC_CALL, saveid }
        elseif matchString("[") then
            good, ast = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            return true, { ARRAY_VAR, saveid, ast }
        else
            return true, { SIMPLE_VAR, saveid }
        end
    else
        return false, nil
    end       
end

-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return parseit
