using StatsPlots
using Distributions
# x = 1:10; y = rand(10); # These are the plotting data
# plot(x,y, label="my label")

plot(Exponential(20),xlims=(-10,1000))
plot!(truncated(Cauchy(0,20),0,1000))