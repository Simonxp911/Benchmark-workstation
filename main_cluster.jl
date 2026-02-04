

include("preamble.jl")
const saveDir = ARGS[1] * "/benchmark_workstation_data/"
const nCPU = ARGS[2]
if length(ARGS) >= 3
    if ARGS[3] == "auto"
        const nJTh = ARGS[3] * " ($(Threads.nthreads()))"
    else
        const nJTh = ARGS[3]
    end
else
    const nJTh = "not set ($(Threads.nthreads()))"
end

BLAS.set_num_threads(1) #necessary on the workstation for LinearAlgebra to work properly

using MPI               #for parallel computing
MPI.Init()
const comm   = MPI.COMM_WORLD
const root   = 0
const myRank = MPI.Comm_rank(comm)
const nMPI   = MPI.Comm_size(comm)


# ================================================
#   Main functions
# ================================================
function main()
    
    
    # TEMP
    # println(Threads.nthreads())
    
    # a = zeros(10)
    # Threads.@threads for i = 1:10
    #     a[i] = Threads.threadid()
    # end
    # println(a)
    
    
    # println(nCPU)
    # println(nMPI)
    # println(nJTh)
    # TEMP
    
    
    # Choose which benchmark to run from ["matrixInversion", "matrixEigenbasis", "solveFiberEquation"]
    benchmarkName = "matrixEigenbasis"
    
    runBenchmark(benchmarkName)
end


function runBenchmark(benchmarkName)
    println("My rank is $myRank, I am running the benchmark now")
    
    benchmark = getBenchmark(benchmarkName)
    trial = run(benchmark)
    result = ["Rank $myRank of $nMPI", trial]
    
    results = MPI.gather(result, comm, root=root)
    
    if myRank == root
        sort!(results, by=x->x[1])
        println("")
        println("Printing results from running the benchmark '$benchmarkName' ($(benchmark.params.samples) samples)")
        for result in results
            println(result[1])
            printTrial(result[2])
            println("")
        end
        
        postfix = postfix_benchmarkResult(benchmarkName, "workstation", nCPU, nMPI, nJTh)
        filename = "bRes_" * postfix
        save_as_jld2(results, saveDir, filename)
    end
end





# @time begin
    # println("\n -- Running main() on rank $myRank -- \n")
    main() 
    # println(" -- -- ")
    # println("@time of main() on rank $myRank:")
# end