import Pkg
Pkg.add("Random")
Pkg.add("StatsBase")
Pkg.add("Distributions")
Pkg.add("StatsPlots")
Pkg.add("StatsFuns")
Pkg.add("Logging")

Pkg.add("Turing")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Optim")
Pkg.add("StatisticalRethinking")
Pkg.add("MCMCDiagnosticTools")
Pkg.add("Serialization")


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
using LinearAlgebra
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 12
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 2 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,ePNP,pNP) #NGRAM surprisal LOO
    σ_w ~ filldist(Exponential(), 2)
    ρ_w ~ LKJ(2, 2) # LKJ prior on the correlation matrix
    Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
    α_a_w ~ Normal(0,1)
    α_b_w ~ Normal(0,1)
    ab_w ~ filldist(MvNormal([α_a_w,α_b_w], Σ_w),NUM_TYPES*NUM_ERP)
    ab_w = reshape(ab_w, (2,NUM_TYPES,NUM_ERP))
    a_w = ab_w[1,tags.+1,:]
    b_w = ab_w[2,tags.+1,:]
    
    σ_p ~ filldist(Exponential(), 2)
    ρ_p ~ LKJ(2, 2)
    Σ_p = Symmetric(Diagonal(σ_p) * ρ_p * Diagonal(σ_p))
    α_a_p ~ Normal(0,1)
    α_b_p ~ Normal(0,1)
    ab_p ~ filldist(MvNormal([α_a_p,α_b_p], Σ_p),NUM_PARTICIPANTS*NUM_ERP)
    ab_p = reshape(ab_p, (2,NUM_PARTICIPANTS,NUM_ERP))

    a_p = ab_p[1,participant.+1,:]
    b_p = ab_p[2,participant.+1,:]

    σ_e ~ filldist(Exponential(), 2)
    ρ_e ~ LKJ(2, 2)
    Σ_e = Symmetric(Diagonal(σ_e) * ρ_e * Diagonal(σ_e))
    α_a_e ~ Normal(0,1)
    α_b_e ~ Normal(0,1)
    ab_e ~ filldist(MvNormal([α_a_e,α_b_e], Σ_e),NUM_ERP)
    a_e = ab_e[1,:]
    b_e = ab_e[2,:]

    μ_epnp = @. a_w[1] + a_p[1] + a_e[1] + ((b_w[1] + b_p[1] + b_e[1]) * surprisal)
    μ_pnp  = @. a_w[2] + a_p[2] + a_e[2] + ((b_w[2] + b_p[2] + b_e[2]) * surprisal)

    σ ~ truncated(Cauchy(0,20),0,1000)

    for i in eachindex(ePNP)
        ePNP[i] ~ Normal(μ_epnp[i],σ)
        pNP[i]  ~ Normal(μ_pnp[i],σ)
    end
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,df_modified.PNP)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)

# Highest Density Interval
