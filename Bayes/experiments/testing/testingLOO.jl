using Random
using StatsBase
using Distributions
using StatsPlots
using StatsFuns
using Logging

using Turing
using CSV
using DataFrames
using Optim
using StatisticalRethinking

using MCMCDiagnosticTools
using Serialization

x = rand(Normal(),1000)
yi = x .+ x.^2
y = zeros(1000)
for i in eachindex(yi)
    y[i] = rand(Normal(yi[i]))
end
@model function model1(y, x)

    for i in eachindex(y)
        x[i] ~ Normal()
        y[i] ~ Normal(x[i])
      end
end
@model function model2(y, x)
    for i in eachindex(y)
        x[i] ~ Normal()
        yi = x[i] + x[i]^2
        y[i] ~ Normal(yi)
      end
end
mod=model1(y,x)
mod2=model2(y,x)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
m2 = sample(mod2, NUTS(), MCMCThreads(), 250,4)

# Highest Density Interval