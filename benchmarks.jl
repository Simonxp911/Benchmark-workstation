

"""
Simple function to get the benchmark described by benchmarkName
"""
function getBenchmark(benchmarkName)
    if     benchmarkName == "matrixInversion"     return benchmark_matrixInversion()
    elseif benchmarkName == "matrixEigenbasis"    return benchmark_matrixEigenbasis()
    elseif benchmarkName == "solveFiberEquation"  return benchmark_solveFiberEquation()
    else
        throw(ArgumentError("benchmarkName = $benchmarkName was not recognized in getBenchmark"))
    end
end


"""
Perform inversion of a random 1000x1000 matrix
"""
function benchmark_matrixInversion()
    A = rand(1000, 1000)
    return @benchmarkable inv($A) samples = 100 seconds = 1000
end


"""
Find eigenbasis of a random 1000x1000 matrix
"""
function benchmark_matrixEigenbasis()
    A = rand(3000, 3000)
    return @benchmarkable eigen($A) samples = 100 seconds = 3600
end


"""
Solve the (nonlinear) fiber equation for a set of parameters corresponding to a single-mode fiber
"""
function benchmark_solveFiberEquation()
    function dbesselj(derivOrder, n, x)
        return sum([(-1)^i*binomial(derivOrder, i)*besselj(n - (derivOrder - 2*i), x) for i in 0:derivOrder])/2^derivOrder
    end
    function dbesselk(derivOrder, n, x)
        return (-1)^derivOrder*sum([binomial(derivOrder, i)*besselk(n - (derivOrder - 2*i), x) for i in 0:derivOrder])/2^derivOrder
    end
    function fiber_equation(x, params)
        ω, ρf, n = params
        
        h   = sqrt(n^2*ω^2 - x^2)
        q   = sqrt(abs(x^2 - ω^2))
        hρf = h*ρf
        qρf = q*ρf
        
        J0  = dbesselj(0, 0, hρf)
        J1  = dbesselj(0, 1, hρf)
        K1  = dbesselk(0, 1, qρf)
        K1p = dbesselk(1, 1, qρf)
        
        A  = J0/(hρf*J1)
        B  = (n^2 + 1)/(2*n^2) * K1p/(qρf*K1)
        C  = -1/hρf^2
        D1 = ((n^2 - 1)/(2*n^2) * K1p/(qρf*K1))^2
        D2 = x^2/(n^2*ω^2) * (1/qρf^2 + 1/hρf^2)^2
        D  = sqrt(D1 + D2)
        return A + B + C + D
    end
    
    ω, ρf, n = 2π, 0.5, 1.45
    xspan = (ω + eps(ω), n*ω - eps(n*ω))
    params = (ω, ρf, n)
    prob = IntervalNonlinearProblem(fiber_equation, xspan, params)
    
    return @benchmarkable NonlinearSolve.solve($prob) samples = 100 seconds = 1000
end



# function benchmark_optimize??()