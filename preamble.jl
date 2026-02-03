

# ================================================
#   Julia libraries
# ================================================  
using BenchmarkTools    #premade tools for benchmarking
using Printf            #for formatting string
using Random            #for setting a seed for the RNG
Random.seed!(1234)      #seed to ensure consistent test cases
using LinearAlgebra     #norm of vectors and other standard linear algebra
using OrdinaryDiffEq    #solve differential equation for time-evolution or steady state
using NonlinearSolve    #addition to OrdinaryDiffEq for nonlinear EoMs
using Bessels           #Bessel functions for fiber equation and modes


# ================================================
#   Files
# ================================================
include("benchmarks.jl")
include("utility.jl")
include("figs.jl")