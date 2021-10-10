module emulator
    function pop_or_error(Array::Array{Int}, location::Main.Location)
        if size(Array, 1) < 1
            Main.error("Runtime error, tried to pop non existing element from the stack", 1, location)
        end

        pop!(Array)
    end
    
    function prev(array::Array, index::Int)
        return length(array) > index - 1 ? array[index - 1] : nothing
    end

    function emulate(program::Array{Main.Lexeme})
        stack::Array{Int} = []
        R::Array{Int8} = zeros(1, 32)
        string_storage::Array{String} = []

        ip = 1
        while ip <= length(program)
            op::Main.Lexeme = program[ip]
            new_ip::Int = ip + 1

            if op.Type == Main.INT
                push!(stack, op.Value)
            elseif op.Type == Main.STRING
                push!(string_storage, op.Value)

                push!(stack, length(op.Value))
                push!(stack, length(string_storage))
            elseif op.Type == Main.KEYWORD
                if (op.Value == Main.DO) | (op.Value == Main.IF)
                    R[25] = pop_or_error(stack, op.location)

                    new_ip = R[25] == 1 ? ip + 1 : op.jump_loc + 1      
                elseif op.Value == Main.ELSE
                    new_ip = op.jump_loc
                elseif op.Value == Main.END
                    if (op.jump_loc !== missing) && (program[op.jump_loc].Value == Main.WHILE)
                        new_ip = op.jump_loc
                    end
                end
            elseif op.Type == Main.INTRINSIC
                if op.Value == Main.PLUS
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, R[24] + R[25])
                elseif op.Value == Main.MIN
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, R[24] - R[25])
                elseif op.Value == Main.DIV
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, floor(R[24] / R[25]))
                elseif op.Value == Main.MUL
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, floor(R[24] * R[25]))
                elseif op.Value == Main.EQ
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] == R[24] ? 1 : 0)
                elseif op.Value == Main.GT
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] > R[25] ? 1 : 0)
                elseif op.Value == Main.GE
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] >= R[25] ? 1 : 0)
                elseif op.Value == Main.LT
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] < R[25] ? 1 : 0)
                elseif op.Value == Main.LE
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] <= R[25] ? 1 : 0)
                elseif op.Value == Main.NE
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] != R[25] ? 1 : 0)
                elseif op.Value == Main.OR
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] | R[25])
                elseif op.Value == Main.AND
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    
                    push!(stack, R[24] & R[25])
                elseif op.Value == Main.DROP
                    pop_or_error(stack, op.location)
                elseif op.Value == Main.SWAP
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, R[25])
                    push!(stack, R[24])
                elseif op.Value == Main.DUP
                    R[25] = pop_or_error(stack, op.location)

                    push!(stack, R[25])
                    push!(stack, R[25])
                elseif op.Value == Main.OVER
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)

                    push!(stack, R[24])
                    push!(stack, R[25])
                    push!(stack, R[24])
                elseif op.Value == Main.ROT
                    R[25] = pop_or_error(stack, op.location)
                    R[24] = pop_or_error(stack, op.location)
                    R[23] = pop_or_error(stack, op.location)

                    push!(stack, R[25])
                    push!(stack, R[24])
                    push!(stack, R[23])
                elseif op.Value == Main.PRINT
                    R[25] = pop_or_error(stack, op.location)

                    println(R[25])
                elseif op.Value == Main.PRINTS
                    R[25] = pop_or_error(stack, op.location)

                    println(string_storage[R[25]])
                end
            end

            ip = new_ip
        end

        return stack
    end
end