

# ================================================
#   Printing functions
# ================================================
"""
A nice print of benchmark trial results
"""
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
        println(rpad("$varName:", 10, " ") * lpad(min_, 12, " ") * "  |" * lpad(mean_, 12, " ") * "  |" * lpad(max_, 12, " "))
    end
end


"""
A nice formatting of a time t (given in nanoseconds)
"""
function prettytime(t)
    if t < 1e3
        value, units = t, "ns"
    elseif t < 1e6
        value, units = t / 1e3, "mis"
    elseif t < 1e9
        value, units = t / 1e6, "ms"
    else
        value, units = t / 1e9, "s"
    end
    return string(@sprintf("%.3f", value), " ", units)
end


"""
A nice formatting of a quantity of memory b (given in bytes)
"""
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
#   Saving and loading functions
# ================================================
function save_as_jld2(data, saveDir, filename)
    JLD2.save(saveDir * filename * ".jld2", "data", data)
end


function load_as_jld2(saveDir, filename)
    return JLD2.load(saveDir * filename * ".jld2", "data")
end


"""
Postfix for saving/loading the benchmark results
"""
function postfix_benchmarkResult(benchmarkName, computerDesc, nCPU=nothing, nMPI=nothing, nJTh=nothing)
    postfix_components = [
        benchmarkName, 
        computerDesc
    ]
    if !isnothing(nCPU) push!(postfix_components, "nCPU_$nCPU") end
    if !isnothing(nMPI) push!(postfix_components, "nMPI_$nMPI") end
    if !isnothing(nMPI) push!(postfix_components, "nJTh_$nJTh") end
    return join(postfix_components, "_")
end