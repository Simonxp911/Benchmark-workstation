

include("preamble.jl")
const saveDir = "C:/Users/Simon/Forskning/Data/benchmark_workstation_data/"

using GLMakie           #for plotting, incl. specialized interactive plots


# ================================================
#   Main functions
# ================================================
function main()
    
    
    
    # # TEMP
    # results = []
    # for benchmarkName in ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    #     benchmark = getBenchmark(benchmarkName)
    #     trial = run(benchmark)
    #     push!(results, [benchmarkName, trial])
    # end
    
    # fig_compareBenchmarks("test", 0, results)
    # # TEMP
    
    
    
    # Choose which benchmark to run from ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    benchmarkName = "solveFiberEquation"
    
    runBenchmark(benchmarkName)
    
end


function runBenchmark(benchmarkName)
    benchmark = getBenchmark(benchmarkName) 
    trial = run(benchmark)
    println("Printing results from running the benchmark '$benchmarkName' ($(benchmark.params.samples) samples)")
    println("Local laptop results:")
    printTrial(trial)
    
    results = [["laptop", trial]]
    postfix = postfix_benchmarkResult(benchmarkName, "laptop")
    filename = "bRes_" * postfix
    save_as_jld2(results, saveDir, filename)
end


function plot_benchmarkResults(benchmarkName)
    results = []
    for (computerDesc, commSize) in zip(["laptop", "workstation", "workstation"],
                                        [nothing, 10, 1])
        postfix = postfix_benchmarkResult(benchmarkName, computerDesc, commSize)
        filename = "bRes_" * postfix
        append!(results, load_as_jld2(saveDir, filename))
    end
    
    fig_compareBenchmarks(benchmarkName, results)
end




@time begin
    println("\n -- Running main() -- \n")
    main()
    println(" -- -- ")
    println("@time of main():")
end