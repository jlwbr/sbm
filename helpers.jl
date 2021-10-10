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


struct Location
    File::String
    Line::Int
    Column::Int
  end

struct Token
    Value::String
    location::Location
end

Base.show(io::IO, l::Location) = print(io, "$(l.File):$(l.Line):$(l.Column)")

struct Lexeme
    Type::Types
    Text::String
    Value::Union{Int, String, Intrinsics, Keywords}
    jump_loc::Union{Int, Missing}
    location::Location
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