

include("preamble.jl")
const saveDir = ARGS[1] * "/benchmark_workstation_data/"

BLAS.set_num_threads(1) #necessary on the workstation for LinearAlgebra to work properly

using MPI               #for parallel computing
MPI.Init()
const comm     = MPI.COMM_WORLD
const root     = 0
const myRank   = MPI.Comm_rank(comm)
const commSize = MPI.Comm_size(comm)


# ================================================
#   Main functions
# ================================================
function main()
    
    # Choose which benchmark to run from ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    benchmarkName = "solveFiberEquation"
    
    runBenchmark(benchmarkName)
    
end


function runBenchmark(benchmarkName)
    println("My rank is $myRank, I am running the benchmark now")
    
    benchmark = getBenchmark(benchmarkName)
    trial = run(benchmark)
    result = [myRank, trial]
    
    results = MPI.gather(result, comm, root=root)
    
    if myRank == root
        sort!(results, by=x->x[1])
        println("")
        println("Printing results from running the benchmark '$benchmarkName' ($(benchmark.params.samples) samples)")
        for result in results
            println("Rank: $(result[1])")
            printTrial(result[2])
            println("")
        end
        
        postfix = postfix_benchmarkResult(benchmarkName, "workstation", commSize)
        filename = "bRes" * postfix
        save_as_jld2(results, saveDir, filename)
    end
end





@time begin
    println("\n -- Running main() on rank $myRank -- \n")
    main() 
    println(" -- -- ")
    println("@time of main() on rank $myRank:")
end