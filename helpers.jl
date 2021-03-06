@enum Types begin
    INT
    STRING
    KEYWORD
    INTRINSIC
end

@enum Keywords begin
    IMPORT
    MACRO
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

const KEYWORD_BY_NAME = Dict(
    "MACRO" => MACRO,
    "IMPORT" => IMPORT,
    "IF" => IF,
    "ELSE" => ELSE,
    "WHILE" => WHILE,
    "DO" => DO,
    "END" => END
)

const TOKENS_REQUIRING_END = Dict(
    "MACRO" => MACRO,
    "IF" => IF,
    "DO" => DO
)

const INTRINSICS_BY_NAME = Dict(
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

const EXTENSION = ".sbm"

function check_file(file)
    file_path = abspath(file)

    if isfile(file_path * Main.EXTENSION)
        file_path = file_path * Main.EXTENSION
    elseif !isfile(file_path)
        error("opening file $(file_path): No such file or directory", 1)
    end

    return file_path
end