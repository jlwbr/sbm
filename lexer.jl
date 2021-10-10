module lexer

    function pop_or_error(Array, location::Main.Location)
        if size(Array, 1) < 1
            Main.error("Lexer error, Block closure tag without corresponding opening tag", 1, location)
        end

        pop!(Array)
    end

    function tokenize_file(file::AbstractString)
        lines = readlines(file)
        tokens::Array{Main.Token} = []
        

        for (n, line) in enumerate(lines)
            low::Int = 1

            for (column, character) in enumerate(line)
                if column == length(line)
                    push!(tokens, Main.Token(line[low:column], Main.Location(file, n, column)))
                elseif isspace(only(character))
                    push!(tokens, Main.Token(line[low:(column - 1)],  Main.Location(file, n, column)))
                    low = column + 1
                elseif only(character) == '\"'
                    push!(tokens, Main.Token(line[low:(column - 1)],  Main.Location(file, n, column)))
                    push!(tokens, Main.Token("\"",  Main.Location(file, n, column)))
                    low = column + 1
                elseif only(character) == '#'
                    break
                end
            end
        end

        return [s for s in tokens if !isempty(s.Value)]
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

    function parse(tokens::Array{Main.Token}, jump_stack_offset::Int = 0)
        program::Array{Main.Lexeme} = []
        macro_stack::Dict{String, Array{Main.Lexeme}} = Dict()
        jump_stack::Array{Int} = []

        i = 1
        while i <= length(tokens)
            new_i = i + 1
            token::String = tokens[i].Value
            location::Main.Location = tokens[i].location
            (token_type, value) = find_token_type(token)

            if token == "\""
                string_accumulator::Array{String} = []

                j = i + 1
                while (j < length(tokens)) & (tokens[j].Value != "\"")
                    push!(string_accumulator, tokens[j].Value)
                    j += 1
                end
                
                string::String = join(string_accumulator, " ")
                push!(program, Main.Lexeme(Main.STRING, string, string, missing, location))
                new_i = j + 1
            elseif token_type !== nothing
                if value !== Main.MACRO
                    push!(program, Main.Lexeme(token_type, token, value, missing, location))
                end

                if token_type == Main.KEYWORD
                    if (value == Main.IF) | (value == Main.WHILE) | (value == Main.DO)
                        push!(jump_stack, length(program))
                    elseif value == Main.END
                        jump_addr = pop_or_error(jump_stack, location)
                        loc = program[jump_addr]

                        program[jump_addr] = Main.Lexeme(loc.Type, loc.Text, loc.Value, jump_stack_offset + length(program), loc.location)
                        if loc.Value == Main.DO
                            while_addr = pop_or_error(jump_stack, location)
                            loc = program[length(program)]
                            program[length(program)] = Main.Lexeme(loc.Type, loc.Text, loc.Value, while_addr, loc.location)
                        end
                    elseif value == Main.ELSE
                        jump_addr = pop_or_error(jump_stack, location)
                        loc = program[jump_addr]

                        program[jump_addr] = Main.Lexeme(loc.Type, loc.Text, loc.Value, jump_stack_offset + length(program), loc.location)
                        push!(jump_stack, length(program))
                    end
                end
            elseif get(macro_stack, token, nothing) !== nothing
                program = [program; macro_stack[token]]
            end
            
            i = new_i
        end

        return program
    end
end