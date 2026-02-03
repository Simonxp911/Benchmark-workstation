

include("preamble.jl")
const saveDir = "C:/Users/Simon/Forskning/Data/benchmark_workstation_data/"

using GLMakie           #for plotting, incl. specialized interactive plots


# ================================================
#   Main functions
# ================================================
function main()
    
    
    fig_compareBenchmarks("test", 10)
    
    
    # # Choose which benchmark to run from ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    # benchmarkName = "solveFiberEquation"
    
    # runBenchmark(benchmarkName)
    
end


function runBenchmark(benchmarkName)
    benchmark = getBenchmark(benchmarkName)
    trial = run(benchmark)
    println("Printing results from running the benchmark '$benchmarkName' ($(benchmark.params.samples) samples)")
    println("Local laptop results:")
    printTrial(trial)
end





@time begin
    println("\n -- Running main() -- \n")
    main()
    println(" -- -- ")
    println("@time of main():")
end