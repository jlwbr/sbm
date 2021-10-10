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

if length(ARGS) <= 0
    help()
elseif ARGS[1] == "sim"

    if length(ARGS) < 2
        error("No source file given!", 1)
    end

    file = abspath(ARGS[2])

    tokens = lexer.tokenize_file(file)

    @time emulator.emulate(lexer.parse(tokens))
else
    println("Subcommand not found, help:")
    help()
end
