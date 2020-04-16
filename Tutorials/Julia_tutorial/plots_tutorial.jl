using CSV
using DataFrames
using Plots

### Import data

# Generate a temporary file path
tmp = tempname()

# Download data in the temporary file path from the UCI website
download("https://archive.ics.uci.edu/ml/machine-learning-databases/00236/seeds_dataset.txt",
        tmp)

# Read the seeds dataset
# Dropmissing used to drop pseudo-missing values in the raw dataset
seeds = dropmissing(CSV.read(tmp; header=0, delim='\t'))

# Name the variables (measures of wheat kernels = grains)
# 1 = area (A)
# 2 = perimeter (P)
# 3 = compactness (C = 4*pi*A/P^2)
# 4 = length of kernel (Fr: graine)
# 5 = width of kernel
# 6 = asymmetry coefficient
# 7 = length of kernel groove (Fr: rainure)
# 8 = cultivar (1, 2 or 3) : variety of wheat
rename!(seeds,
  [:Column1 => :area, :Column2 => :perimeter,
  :Column3 => :compactness, :Column4 => :kernel_length,
  :Column5 => :kernel_width, :Column6 => :asymmetry,
  :Column7 => :kernel_groove, :Column8 => :cultivar]
  )


### Scatter plots

## Length of kernel groove as a function of kernel length

# Basic plot
scatter(seeds.kernel_length, seeds.kernel_groove)

# Make it pretty
plotA = scatter(seeds.kernel_length, seeds.kernel_groove,
                color=:grey, alpha=0.8,
                label="",
                frame=:box, dpi=120,
                smooth=true, linecolor=RGB(204/255,121/255,167/255), linewidth=3)
xaxis!(xlabel="Kernel length (cm)", xlims=(4.8,6.8))
yaxis!(ylabel="Groove length (cm)", ylims=(4.4,6.7))

# Add 1:1 line
x=minimum(seeds.kernel_length):0.1:maximum(seeds.kernel_length)
plot!(x, x,
     label="1:1",
     linestyle=:dot, linecolor=:black, linewidth=1,
     legend=:right, foreground_color_legend=nothing)




### Density plots
using StatsPlots
plotB = density(seeds.kernel_length, groups=seeds.cultivar,
                linewidth=2,
                xlabel="Kernel length (cm)", ylabel="Density",
                xlims=(4.8,6.8),
                label=["C1" "C2" "C3"],
                legend=:topright, foreground_color_legend=nothing,
                frame=:box, dpi=120)

plotC = density(seeds.kernel_groove, groups=seeds.cultivar,
                linewidth=2,
                xlabel="Groove length (cm)", ylabel="Density",
                xlims=(4.4,6.7),
                label=["C1" "C2" "C3"],
                legend=:topright, foreground_color_legend=nothing,
                frame=:box, dpi=120)


### Plots together
l = @layout [a; b c]
plot(plotA, plotB, plotC, layout=l,
    legend = false,
    title = ["($i)" for j in 1:1, i in 1:3], titleloc = :right, titlefont = font(8))
savefig(joinpath("tutorials/Julia_tutorial", "fig"))



### Resources
# http://docs.juliaplots.org/latest/

### To go further
# Gadfly.jl: https://github.com/GiovineItalia/Gadfly.jl
# PyPlot.jl: https://github.com/JuliaPy/PyPlot.jl
# StatsPlots.jl: https://github.com/JuliaPlots/StatsPlots.jl
