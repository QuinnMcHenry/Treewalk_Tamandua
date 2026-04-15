-- lexit.lua
-- Quinn McHenry
-- Started: 2026-02-11
-- Last Revision: 2026-02-16

-- lexit module for assignment 3

lexit = {}

-- numeric constants representing lexeme categories
lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP     = 5
lexit.PUNCT  = 6
lexit.MAL    = 7

-- catnames
-- printable names of lexeme categories. indices ^
lexit.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}

-------- KIND OF CHAR FUNCTIONS---------

-- isLetter
local function isLetter(c)
    assert(type(c) == "string")
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end

-- isDigit
local function isDigit(c)
    assert(type(c) == "string")
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end

-- isWhitespace
local function isWhitespace(c)
    assert(type(c) == "string")
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r" or c == "\f" then 
        return true
    else
        return false
    end
end

-- isPrintableASCII
local function isPrintableASCII(c)
    assert(type(c) == "string")
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end

-- isIllegal
local function isIllegal(c)
    assert(type(c) == "string")
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end

-- function lexit.lex
function lexit.lex(program) 

    local pos, state, ch, lexstr, category, handlers
      
    local DONE    = 0
    local START   = 1
    local LETTER  = 2
    local DIGIT   = 3
    local PLUS    = 6
    local MINUS   = 7
    local EQUALS  = 8
    local STRLIT  = 9
    local ANDOR   = 10
    local EXPSTART= 11
    local EXPDIG  = 12
    local EXPPLUS = 13

-- currChar - return current character at index pos
    local function currChar()
        return program:sub(pos, pos)
    end

-- nextChar - return next character at index pos + 1
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end
   
-- nextNextChar - return character at index pos + 2 
---- for checking type of exponent
    local function nextNextChar()
        return program:sub(pos+2, pos+2)
    end

-- drop1 - move pos + 1
    local function drop1()
        pos = pos+1
    end

-- add1 - append current character to lexeme, move pos + 1
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end
    
-- skipToNextLexeme - skip whitespace and comments, move pos to start of next lexeme
    local function skipToNextLexeme()
        while true do
            -- skip whitespace
            while isWhitespace(currChar()) do
                drop1()
            end
            
            -- done if no comment
            if currChar() ~= "#" then
                break
            end

            -- case comment
            drop1()
            while currChar() ~= "\n" and currChar() ~= "" do
                drop1()
            end
            if currChar() == "" then
                return
            end
        end
    end

---- HANDLER FUNCTIONS ----

-- state STRLIT
    local function handle_STRLIT()
        local symbol = lexstr:sub(1,1) -- the opening quote 
        if ch == symbol then -- valid end of string
            add1()
            state = DONE
            category = lexit.STRLIT
        elseif ch == "\n" or ch == "" then -- invalid string
            state = DONE
            category = lexit.MAL
        else
            add1() --process inside of string
        end
    end

-- state DONE
    local function handle_DONE()
        error("'DONE' state must not be handled\n")
    end

-- state START 
    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "+" then
            add1()
            state = PLUS
        elseif ch == "-" then
            add1()
            state = MINUS
        elseif ch == "=" or ch == "!" or ch == "<" or ch == ">" then
            add1()
            state = EQUALS
        elseif ch == "/" or ch == "*" or ch == "[" or ch == "]" or ch == "%" then
            add1()
            state = DONE
            category = lexit.OP
        elseif ch == '"' or ch == "'" then
            add1()
            state = STRLIT
        elseif ch == "&" or ch == "|" then
            add1()
            state = ANDOR
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end

-- handle letter and keyword
    local function handle_LETTER()
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            if lexstr == "chr" or lexstr == "else" or lexstr == "elsif" or lexstr == "func" or lexstr == "if" or lexstr == "print" or lexstr == "println" or lexstr == "readint" or lexstr == "return" or lexstr == "rnd" or lexstr == "while" then
                category = lexit.KEY
            else
                category = lexit.ID
            end
        end
    end

-- handle DIGIT
    local function handle_DIGIT()
        if isDigit(ch) then
            add1()
        elseif ch == "e" or ch == "E" then
            state = EXPSTART
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

-- handle EXPSTART
    local function handle_EXPSTART()
        -- ch is e or E. this is the first e we see in the potential NUMLIT
        if isDigit(nextChar()) then -- valid NUMLIT with e and no "+"
            add1() -- add the e go to expdig
            state = EXPDIG
        elseif nextChar() == "+" and isDigit(nextNextChar()) then
            add1() -- add e, and we know there is plus and digit next
            state = EXPPLUS  
        else
            state = DONE
            category = lexit.NUMLIT -- we saw e with no digit or no plus after  
        end    
    end

-- handle EXPDIG -for when we saw a valid use of e, so far
    local function handle_EXPDIG()
        -- the e has just been added.
        if isDigit(ch) then
            add1() -- add digits on the other end of e till NUMLIT ends as usual.
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

--handle EXPPLUS
    local function handle_EXPPLUS()
       -- current is + with a digit coming next.
        if ch == "+" then
            add1()
            state = EXPDIG -- going back to expdig ensures we handle future invalid +
        end            
    end

-- handle ANDOR
    local function handle_ANDOR()
        local symbol = lexstr:sub(1,1) -- current symbol
        if symbol == "&" then
            if ch == "&" then
                add1()
                state = DONE
                category = lexit.OP
            else
                state = DONE
                category = lexit.PUNCT
            end
        elseif symbol == "|" then
            if ch == "|" then
                add1()  
                state = DONE
                category = lexit.OP
            else
                state = DONE
                category = lexit.PUNCT
            end
        end
    end

-- handle PLUS
    local function handle_PLUS() -- can be itself, or 2 of itself.
        if ch == "+" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

-- handle MINUS
    local function handle_MINUS()
        if ch == "-" then -- can be itself, or 2 of itself.
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

-- handle EQUALS - for all the ops who can be themselves or themselves with an '='
    local function handle_EQUALS()
        if ch == "=" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

---- handler functions table ----
    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [EQUALS]=handle_EQUALS,
        [STRLIT]=handle_STRLIT,
        [ANDOR]=handle_ANDOR,
        [EXPSTART]=handle_EXPSTART,
        [EXPDIG]=handle_EXPDIG,
        [EXPPLUS]=handle_EXPPLUS,
    }

    assert(type(program) == "string")

-- main logic
    return coroutine.wrap(function()
        pos = 1
        while true do

            skipToNextLexeme()
    
            -- case: no more lexemes
            if pos > program:len() then
                return nil, nil
            end

            -- case: more lexemes
            lexstr = ""
            state = START
            while state ~= DONE do
                ch = currChar()
                handlers[state]()
            end

            -- eat lexeme
            coroutine.yield(lexstr, category)
        end
    end)
end

return lexit
