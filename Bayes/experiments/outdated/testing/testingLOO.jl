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
using ParetoSmooth

Random.seed!(5)

@model function model(data)
    μ ~ Normal()
    for i in 1:length(data)
        data[i] ~ Normal(μ, 1)
    end
end

@model function model2(data)
    μ ~ Normal(5,0.1)
    for i in 1:length(data)
        data[i] ~ Normal(μ, 1)
    end
end

data = rand(Normal(0, 1), 100)

chain = sample(model(data), NUTS(), 1000)
psis_loo(model(data), chain)

# chain2 = sample(model2(data), NUTS(), 1000)
# psis_loo(model2(data), chain2)

# x = rand(Normal(5,3),1000)
# yi = x .+ x.^2
# y = zeros(1000)
# for i in eachindex(yi)
#     y[i] = rand(Normal(yi[i]))
# end
# @model function model1(y, x)
#     a ~ Normal(5,5)
#     x ~ Normal(a,3)
#     σ ~ Exponential()
#     for i in eachindex(y)     
#         y[i] ~ Normal(x[i],σ)
#       end
# end
# @model function model2(y, x)
#     a ~ Normal(5,5)
#     x ~ Normal(a,3)
#     σ ~ Exponential()
#     for i in eachindex(y)       
#         yi = x[i] + x[i]^2
#         y[i] ~ Normal(yi,σ)
#       end
# end
# mod =model1(y,x)
# mod2=model2(y,x)
# m = sample(mod, NUTS(), 1000)
# m2 = sample(mod2, NUTS(), 1000)
# psis_loo(mod,m)
# psis_loo(mod2,m2)
# Highest Density Interval