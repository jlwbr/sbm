module lexer

    function pop_or_error(Array)
        if size(Array, 1) < 1
            Main.error("Lexer error, Block closure tag without corresponding opening tag", 1)
        end

        pop!(Array)
    end

    function tokenize_file(file::IO)
        lines = readlines(file, )
        tokens::Array{String} = []

        for line in lines
            low::Int = 1

            for (column, character) in enumerate(line)
                if column == length(line)
                    push!(tokens, line[low:column])
                elseif isspace(only(character))
                    push!(tokens, line[low:(column - 1)])
                    low = column + 1
                elseif only(character) == '\"'
                    push!(tokens, line[low:(column - 1)])
                    push!(tokens, "\"")
                    low = column + 1
                elseif only(character) == '#'
                    break
                end
            end
        end

        return [s for s in tokens if !isempty(s)]
    end

    function find_token_type(token::String)
        int_or_nothing = tryparse(Int, token)
        if int_or_nothing !== nothing return (Main.INT, int_or_nothing) end

        intrinsic_or_nothing = get(Main.INTRINSICS_BY_NAME, token, nothing)
        if intrinsic_or_nothing !== nothing return (Main.INTRINSIC, intrinsic_or_nothing) end

        keyword_or_nothing = get(Main.KEYWORD_BY_NAME, token, nothing)
        if keyword_or_nothing !== nothing return (Main.KEYWORD, keyword_or_nothing) end

        return (nothing, nothing)
    end

    function parse(tokens::Array{String})
        program::Array{Main.Token} = []
        jump_stack::Array{Int} = []

        parsing_string::Bool = false
        string_accumulator::Array{String} = []
        for token in tokens
            (token_type, value) = find_token_type(token)

            if token == "\""
                if parsing_string
                    string::String = join(string_accumulator, " ")
                    push!(program, Main.Token(Main.STRING, string, string, missing))
                end
                
                parsing_string = !parsing_string
            elseif parsing_string
                push!(string_accumulator, token)
            elseif token_type !== nothing
                push!(program, Main.Token(token_type, token, value, missing))

                if token_type == Main.KEYWORD
                    if (value == Main.IF) | (value == Main.WHILE) | (value == Main.DO)
                        push!(jump_stack, length(program))
                    elseif value == Main.END
                        jump_addr = pop_or_error(jump_stack)
                        loc = program[jump_addr]

                        program[jump_addr] = Main.Token(loc.Type, loc.Text, loc.Value, length(program))
                        if loc.Value == Main.DO
                            while_addr = pop_or_error(jump_stack)
                            loc = program[length(program)]
                            program[length(program)] = Main.Token(loc.Type, loc.Text, loc.Value, while_addr)
                        end
                    elseif value == Main.ELSE
                        jump_addr = pop_or_error(jump_stack)
                        loc = program[jump_addr]

                        program[jump_addr] = Main.Token(loc.Type, loc.Text, loc.Value, length(program))
                        push!(jump_stack, length(program))
                    end
                end
            end
        end

        return program
    end
end