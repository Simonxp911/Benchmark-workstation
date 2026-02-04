

"""
Plot the benchmark trial results as bars 
to compare across different computers and parameters
"""
function fig_compareBenchmarks(benchmarkName, results)
    nBars = length(results)
    
    # Set title, labels, and colors
    titl = L"Results from running the benchmark \"%$(benchmarkName)\"\\ Bar shows mean, range shows min/max$$"
    labels = [latexstring(result[1], "\$\$") for result in results]
    colors = distinguishable_colors(nBars, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)
    
    # Set parameters defining size and separations of bars
    groupSep = 0.3
    barSep   = 0.0
    barWidth = 0.3
    groupWidth = (nBars - 1)*(barSep + barWidth)
    
    # Get the xs for the bars
    group_xs = (0:nBars-1)*(barSep + barWidth)
    
    
    # Start figure 
    fig = Figure(size=(1000, 400))
    
    # Make title and axis
    Label(fig[1, 1:4], titl, tellwidth=false)
    ax1 = Axis(fig[2, 1:2],
               xticks=([groupWidth/2, 1.5*groupWidth + groupSep + barWidth], [L"Time$$", L"GC time$$"]),
               ylabel=L"nanoseconds$$")
    ax2 = Axis(fig[2, 3],
               xticks=([groupWidth/2], [L"Memory$$"]),
               ylabel=L"bytes$$")
    ax3 = Axis(fig[2, 4],
               xticks=([groupWidth/2], [L"Allocs$$"]))
               
    # Prepare and plot data
    for (ax, key, xs) in zip([ax1, ax1, ax2, ax3],
                             [:time, :gctime, :memory, :allocs],
                             [group_xs, group_xs .+ (groupWidth + groupSep + barWidth), group_xs, group_xs])
        # Prepare data
        means = []
        minDiff = []
        maxDiff = []
        for result in results
            push!(means, getfield(mean(result[2]), key))
            push!(minDiff, means[end] - getfield(minimum(result[2]), key))
            push!(maxDiff, getfield(maximum(result[2]), key) - means[end])
        end
        
        # Plot
        barplot!(ax, xs, means, color=colors, width=barWidth)
        errorbars!(ax, xs, means, minDiff, maxDiff, color=:black, whiskerwidth=10)
    end
    
    # Finish figure
    display(GLMakie.Screen(), fig)
    elements = [PolyElement(polycolor=color) for color in colors]
    Legend(fig[2, 5], elements, labels) 
end


"""
Plot the benchmark trial results for the computation time 
to compare across different computers and parameters
"""
function fig_compareBenchmarks_time(benchmarkName, results)
    nBars = length(results)
    
    # Set title, labels, and colors
    titl = L"Time results from running the benchmark \"%$(benchmarkName)\"\\ Bar shows mean, range shows min/max$$"
    labels = [latexstring(result[1], "\$\$") for result in results]
    colors = distinguishable_colors(nBars, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)
    
    # Set parameters defining size and separations of bars
    barSep   = 0.0
    barWidth = 0.3
    groupWidth = (nBars - 1)*(barSep + barWidth)
    
    # Get the xs for the bars
    group_xs = (0:nBars-1)*(barSep + barWidth)
    
    
    # Start figure 
    fig = Figure(size=(600, 400))
    
    # Make title and axis
    Label(fig[1, 1], titl, tellwidth=false)
    ax1 = Axis(fig[2, 1],
               xticks=([groupWidth/2], [L"Time$$"]),
               ylabel=L"nanoseconds$$")
               
    # Prepare data
    means = []
    minDiff = []
    maxDiff = []
    for result in results
        push!(means, getfield(mean(result[2]), :time))
        push!(minDiff, means[end] - getfield(minimum(result[2]), :time))
        push!(maxDiff, getfield(maximum(result[2]), :time) - means[end])
    end
    
    # Plot
    barplot!(ax1, group_xs, means, color=colors, width=barWidth)
    errorbars!(ax1, group_xs, means, minDiff, maxDiff, color=:black, whiskerwidth=10)
    
    # Finish figure
    display(GLMakie.Screen(), fig)
    elements = [PolyElement(polycolor=color) for color in colors]
    Legend(fig[2, 2], elements, labels) 
end