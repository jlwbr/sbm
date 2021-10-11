#!/usr/bin/env julia
include("helpers.jl")
include("lexer.jl")
include("emulator.jl")

import Dates

function error(info, exit_code = -1, location = undef, std = stderr)
    printstyled(std, "ERROR: ", color = :red)
    println(std, info)

    if location !== undef
        printstyled(std, "      @ ", color = :light_black)
        printstyled(std, location, color = :light_black)
        print(std, "\n")
    end

    if exit_code >= 0
        exit(exit_code)
    end
end

function help()
    str = sprint() do io
        println(io, " ___ ___ __  __ ")
        println(io, "/ __| _ )  \\/  |")
        println(io, "\\__ \\ _ \\ |\\/| |")
        println(io, "|___/___/_|  |_|")
        print(io, "\n")
        println(io, "ARUMENTS:")
        println(io, "   sim         Simulate program using the simulator.")
    end

    print(str)
end

function parse_args(arguments::Core.Array{Core.String,1})
    args::Array{String} = []
    options::Array{String} = []

    for arg in arguments
        if only(arg[1]) == '-'
            if only(arg[2]) == '-'
                push!(options, arg[2:length(arg)])
            else
                push!(options, arg[1:length(arg)])
            end
        else
            push!(args, arg)
        end
    end

    return (args, options)
end

function main()
    if length(ARGS) <= 0
        help()
    else
        (args, options) = parse_args(ARGS)
    
        if args[1] == "sim"
            if length(args) < 2
                error("No source file given!", 1)
            end
    
            file = abspath(args[2])

            if !isfile(file)
                error("opening file $(file): No such file or directory", 1)
            end
            
            run(`clear`)
            
            print("Simulation started at ")
            printstyled(Dates.format(Dates.now(), "HH:MM on d-m-yyyy"), color = :green)
            println()
    
            tokens = lexer.tokenize_file(file)

            stats = @timed emulator.emulate(lexer.parse(tokens))
            size = displaysize(stdout)

            print("\e[$(size[1] - 1);1H")
            println("Simulation exited succesfully, took: $(stats.time), gc time: $(stats.gctime)")
            
        else
            println("Subcommand $(args[1]) not found, help:")
            help()
        end
    end 
end

main()
