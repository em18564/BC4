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
Pkg.add("ParetoSmooth")
Pkg.add("JLD2")

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
using ParetoSmooth
using JLD2
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 8
NUM_WORDS = 800
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,ePNP,	ζ) #NGRAM surprisal LOO
    σ_w ~ filldist(Exponential(), 2)
    ρ_w ~ LKJ(2, 2) # LKJ prior on the correlation matrix
    Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
    ab_w ~ filldist(MvNormal([0,0], Σ_w),NUM_TYPES)
    a_w = ab_w[1,tags.+1]
    b_w = ab_w[2,tags.+1]
    
    σ_p ~ filldist(Exponential(), 2)
    ρ_p ~ LKJ(2, 2)
    Σ_p = Symmetric(Diagonal(σ_p) * ρ_p * Diagonal(σ_p))
    ab_p ~ filldist(MvNormal([0,0], Σ_p),NUM_PARTICIPANTS)
    a_p = ab_p[1,participant.+1]
    b_p = ab_p[2,participant.+1]

    σ_e ~ filldist(Exponential(), 2)
    ρ_e ~ LKJ(2, 2)
    Σ_e = Symmetric(Diagonal(σ_e) * ρ_e * Diagonal(σ_e))
    ab_e ~ filldist(MvNormalm([0,0], Σ_e),1)
    a_e_epnp = ab_e[1,1]
    b_e_epnp = ab_e[2,1]

    a_ts ~ filldist(Normal(0,ζ),NUM_WORDS)
    b_ts ~ filldist(Normal(0,ζ),NUM_WORDS)
    a_t = a_ts[Int.(word)]
    b_t = a_ts[Int.(word)]


    μ_epnp = @. a_w + a_p + a_e_epnp + a_t + ((b_w + b_p + b_e_epnp + b_t) * surprisal)

    σ ~ truncated(Cauchy(0,20),0,1000)

    for i in eachindex(ePNP)
        ePNP[i] ~ Normal(μ_epnp[i],σ)
    end
end
args = map(x->string(x), ARGS)
ζ    = parse(Float64,args[1])/10
df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,ζ)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out"*args[1]*".jls",m)
ps1   = psis_loo(mod,m)
print(ps1.estimates[1])
jldsave("output/outjld"*args[1]*".jls",m)



# Highest Density Interval
