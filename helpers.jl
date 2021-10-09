@enum Types begin
    WORD
    INT
    STRING
    KEYWORD
    INTRINSIC
end

@enum Keywords begin
    IF
    ELSE
    WHILE
    DO
    END
end

@enum Intrinsics begin
    PLUS
    MIN
    DIV
    MUL
    EQ
    GT
    GE
    LT
    LE
    NE
    OR
    AND
    DROP
    SWAP
    DUP
    OVER
    ROT
    PRINT
    PRINTS
end

struct Token
    Type::Types
    Text::String
    Value::Union{Int, String, Intrinsics, Keywords}
    jump_loc::Union{Int, Missing}
end

KEYWORD_BY_NAME = Dict(
    "IF" => IF,
    "ELSE" => ELSE,
    "WHILE" => WHILE,
    "DO" => DO,
    "END" => END
)

INTRINSICS_BY_NAME = Dict(
    "+" => PLUS,
    "-" => MIN,
    "/" => DIV,
    "*" => MUL,
    "=" => EQ,
    ">" => GT,
    ">=" => GE,
    "<" => LT,
    "<=" => LE,
    "!=" => NE,
    "|" => OR,
    "&" => AND,
    "drop" => DROP,
    "swap" => SWAP,
    "dup" => DUP,
    "over" => OVER,
    "rot" => ROT,
    "print" => PRINT,
    "prints" => PRINTS
)