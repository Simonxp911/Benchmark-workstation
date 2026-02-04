

include("preamble.jl")
const saveDir = "C:/Users/Simon/Forskning/Data/benchmark_workstation_data/"

using GLMakie           #for plotting, incl. specialized interactive plots


# ================================================
#   Main functions
# ================================================
function main()
    
    # Choose which benchmark to run from ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    benchmarkName = "matrixEigenbasis"
    
    
    # runBenchmark(benchmarkName)
    plot_benchmarkResults(benchmarkName)
end


function runBenchmark(benchmarkName)
    benchmark = getBenchmark(benchmarkName) 
    trial = run(benchmark)
    println("Printing results from running the benchmark '$benchmarkName'")
    println("Local laptop results:")
    printTrial(trial)
    
    results = [["Laptop", trial]]
    postfix = postfix_benchmarkResult(benchmarkName, "laptop")
    filename = "bRes_" * postfix
    save_as_jld2(results, saveDir, filename)
end


function plot_benchmarkResults(benchmarkName)
    
    # postfix = postfix_benchmarkResult(benchmarkName, "laptop")
    # filename = "bRes_" * postfix
    # results = load_as_jld2(saveDir, filename)
    
    # for nJTh in [1, 2, "auto (2)"], nMPI in 1:2, nCPU in 1:2
    #     postfix = postfix_benchmarkResult(benchmarkName, "workstation", nCPU, nMPI, nJTh)
    #     filename = "bRes_" * postfix
    #     append!(results, load_as_jld2(saveDir, filename))
    #     results[end][1] *= ", nCPU $nCPU, nMPI $nMPI, nJTh $nJTh"
    # end
    # for nJTh in [1, "auto (4)"], nMPI in [1, 4], nCPU in [4]
    #     postfix = postfix_benchmarkResult(benchmarkName, "workstation", nCPU, nMPI, nJTh)
    #     filename = "bRes_" * postfix
    #     append!(results, load_as_jld2(saveDir, filename))
    #     results[end][1] *= ", nCPU $nCPU, nMPI $nMPI, nJTh $nJTh"
    # end
    
    iters = []
    push!(iters, Iterators.product(["laptop"], [nothing], [nothing], [nothing]))
    push!(iters, Iterators.product(["workstation"], [1, 2, "auto (2)"], 1:2, 1:2))
    push!(iters, Iterators.product(["workstation"], [1, "auto (4)"], [1, 4], [4]))
    
    results = []
    for (computerDesc, nJTh, nMPI, nCPU) in Iterators.flatten(iters)
        postfix = postfix_benchmarkResult(benchmarkName, computerDesc, nCPU, nMPI, nJTh)
        filename = "bRes_" * postfix
        results_temp = load_as_jld2(saveDir, filename)
        if computerDesc == "workstation"
            for result in results_temp
                result[1] *= ", nCPU $nCPU, nMPI $nMPI, nJTh $nJTh"
            end
        end
        append!(results, results_temp)
        
    end
    
    # fig_compareBenchmarks(benchmarkName, results)
    fig_compareBenchmarks_time(benchmarkName, results)
end




@time begin
    println("\n -- Running main() -- \n")
    main()
    println(" -- -- ")
    println("@time of main():")
end