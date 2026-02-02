

using BenchmarkTools    #premade tools for benchmarking

using Random            #for setting a seed for the RNG
Random.seed!(1234)      #seed to ensure consistent test cases

using LinearAlgebra     #norm of vectors and other standard linear algebra
BLAS.set_num_threads(1) # Necessary on the workstation for LinearAlgebra to work properly

using MPI
MPI.Init()
const comm     = MPI.COMM_WORLD
const root     = 0
const myRank   = MPI.Comm_rank(comm)
const commSize = MPI.Comm_size(comm)


# ================================================
#   Main functions
# ================================================
function main()
    
    # benchmarkable = benchmarkarble_matrixInversion()
    benchmarkable = benchmarkable_matrixEigenbasis()
    
    runAndPrintBenchmarkable(benchmarkable)
    
end


function runBenchmarkable(benchmarkable)
    println("My rank is $myRank, I am running the benchmarkable now")
    trial = run(benchmarkable)
    result = [myRank, trial]
    
    results = MPI.gather(result, comm, root=root)
    
    if myRank == root
        sort!(results, by=x->x[1])
        for result in results
            display("Rank: $(result[1])")
            display(result[2])
        end
    end
end


# ================================================
#   Benchmark functions
# ================================================
function benchmarkarble_matrixInversion()
    A = rand(1000, 1000)
    return @benchmarkable inv($A) samples = 10 seconds = 100
end


function benchmarkable_matrixEigenbasis()
    A = rand(1000, 1000)
    return @benchmarkable eigen($A) samples = 10 seconds = 100
end



    

main()