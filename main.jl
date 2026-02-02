

using BenchmarkTools    #premade tools for benchmarking
using Printf            #for formatting string
using Random            #for setting a seed for the RNG
Random.seed!(1234)      #seed to ensure consistent test cases
using LinearAlgebra     #norm of vectors and other standard linear algebra
BLAS.set_num_threads(1) #necessary on the workstation for LinearAlgebra to work properly

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
    
    runBenchmarkable(benchmarkable)
    
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
            printTrial(result[2])
            println("")
        end
    end
end


function printTrial(trial)
    trialMin  = minimum(trial)
    TrialMean = mean(trial)
    trialMax  = maximum(trial)
    # TrialMedian = median(trial)
    # Trialstd = std(trial)
    
    for (varName, min_, mean_, max_) in zip(["Variable", "Time", "GC time", "Memory", "Allocs"],
                                            ["min", prettytime(trialMin.time), prettytime(trialMin.gctime), prettymemory(trialMin.memory), trialMin.allocs],
                                            ["mean", prettytime(TrialMean.time), prettytime(TrialMean.gctime), prettymemory(TrialMean.memory), TrialMean.allocs],
                                            ["max", prettytime(trialMax.time), prettytime(trialMax.gctime), prettymemory(trialMax.memory), trialMax.allocs])
        println(rpad("$varName:", 15, " ") * lpad(min_, 10, " ") * "  |" * lpad(mean_, 10, " ") * "  |" * lpad(max_, 10, " "))
    end
end


function prettytime(t)
    if t < 1e3
        value, units = t, "ns"
    elseif t < 1e6
        value, units = t / 1e3, "μs"
    elseif t < 1e9
        value, units = t / 1e6, "ms"
    else
        value, units = t / 1e9, "s"
    end
    return string(@sprintf("%.3f", value), " ", units)
end


function prettymemory(b)
    if b < 1024
        return string(b, " bytes")
    elseif b < 1024^2
        value, units = b / 1024, "KiB"
    elseif b < 1024^3
        value, units = b / 1024^2, "MiB"
    else
        value, units = b / 1024^3, "GiB"
    end
    return string(@sprintf("%.2f", value), " ", units)
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