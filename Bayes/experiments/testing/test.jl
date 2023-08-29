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

@model function testMod()

    e_cor ~ MvNormal(zeros(6),ones(6))
  σ_cor ~ filldist(Exponential(), 6)
  ρ_cor ~ LKJ(6, 2)
  Σ_cor = ((σ_cor .* σ_cor') .* ρ_cor)
  cor ~ filldist(MvNormal(e_cor,Σ_cor), 1)

    # a_w ~ MvNormal(0,1)
    # b_w ~ Normal(0,0.5)

    # σ_w ~ filldist(Exponential(), 2)
    # ρ_w ~ LKJ(2, 2)
    # Σ_w = ((σ_w .* σ_w') .* ρ_w)
    # ab_w ~ filldist(MvNormal([a_w,b_w], Σ_w),2)

    println(cor)
end
m = sample(testMod(), NUTS(), 1)



