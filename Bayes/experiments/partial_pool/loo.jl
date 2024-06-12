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

using MCMCDiagnosticTools
using Serialization
using LinearAlgebra
using ParetoSmooth
using Plots

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 12
NUM_WORDS = 1931
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
    ab_e ~ filldist(MvNormal([0,0], Σ_e),1)
    a_e_epnp = ab_e[1,1]
    b_e_epnp = ab_e[2,1]


    a_t ~ Normal(0,ζ)
    b_t ~ Normal(0,ζ)


    μ_epnp = @. a_w + a_p + a_e_epnp + a_t + ((b_w + b_p + b_e_epnp + b_t) * surprisal)

    σ ~ truncated(Cauchy(0,20),0,1000)

    for i in eachindex(ePNP)
        ePNP[i] ~ Normal(μ_epnp[i],σ)
    end
end
args = map(x->string(x), ARGS)
df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))

chain = deserialize("output/out1.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.1)
ps1   = psis_loo(mod,chain)

chain = deserialize("output/out2.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.2)
ps2   = psis_loo(mod,chain)

chain = deserialize("output/out3.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.3)
ps3   = psis_loo(mod,chain)

chain = deserialize("output/out4.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.4)
ps4   = psis_loo(mod,chain)

chain = deserialize("output/out5.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.5)
ps5   = psis_loo(mod,chain)

chain = deserialize("output/out6.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.6)
ps6   = psis_loo(mod,chain)

chain = deserialize("output/out7.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.7)
ps7   = psis_loo(mod,chain)

chain = deserialize("output/out8.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.8)
ps8   = psis_loo(mod,chain)

chain = deserialize("output/out9.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,0.9)
ps9   = psis_loo(mod,chain)

chain = deserialize("output/out10.jls")
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,1)
ps10   = psis_loo(mod,chain)

Plots.plot(1:10,[[ps1.estimates[1],ps2.estimates[1],ps3.estimates[1],ps4.estimates[1],ps5.estimates[1],ps6.estimates[1],ps7.estimates[1],ps8.estimates[1],ps9.estimates[1],ps10.estimates[1]]])