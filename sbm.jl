#!/usr/bin/env julia
include("helpers.jl")
include("lexer.jl")
include("emulator.jl")

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
    println(" ___ ___ __  __ ")
    println("/ __| _ )  \\/  |")
    println("\\__ \\ _ \\ |\\/| |")
    println("|___/___/_|  |_|")
    println("")
    println("ARUMENTS:")
    println("   sim         Simulate program using the simulator.")
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

if length(ARGS) <= 0
    help()
else
    (args, options) = parse_args(ARGS)

    if args[1] == "sim"
        if length(args) < 2
            error("No source file given!", 1)
        end

        file = abspath(args[2])

        tokens = lexer.tokenize_file(file)

        @time emulator.emulate(lexer.parse(tokens))
    else
        println("Subcommand $(args[1]) not found, help:")
        help()
    end
end
