#!/usr/bin/env julia
include("helpers.jl")
include("lexer.jl")
include("emulator.jl")
include("testing.jl")

using TOML
export TOML

function error(info, exit_code)
    printstyled("ERROR: ", color = :red)
    println(info)
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
    println("   run         Run program using the simulator.")
    println("   test        Test program or folder using the simulator.")
end

if length(ARGS) <= 0
    help()
elseif ARGS[1] == "run"

    if length(ARGS) < 2
        error("No source file given!", 1)
    end

    file = open(ARGS[2], "r")
    tokens = lexer.tokenize_file(file)
    close(file)

    @time emulator.emulate(lexer.parse(tokens))
elseif ARGS[1] == "test"
    if length(ARGS) < 2
        error("No source folder given!", 1)
    end

    if isdir(ARGS[2])
        testing.test(ARGS[2], length(ARGS) > 2 ? ARGS[2:length(ARGS)] : undef)
    else
        error("source folder is not a directory!", 1)
    end
end