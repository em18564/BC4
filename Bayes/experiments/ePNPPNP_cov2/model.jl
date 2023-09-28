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

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 12
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,eEGs)
    a_w_e ~ Normal(0,1)
    b_w_e ~ Normal(0,0.5)
    σ_w_e ~ filldist(Exponential(), 2)
    ρ_w_e ~ LKJ(2, 2)
    Σ_w_e = (σ_w_e .* σ_w_e') .* ρ_w_e
    ab_w_e ~ filldist(MvNormal([a_w_e,b_w_e], Σ_w_e),NUM_TYPES)
    a_w_e = ab_w_e[1,tags.+1]
    b_w_e = ab_w_e[2,tags.+1]
    
    a_p_e ~ Normal(0,1)
    b_p_e ~ Normal(0,0.5)
    σ_p_e ~ filldist(Exponential(), 2)
    ρ_p_e ~ LKJ(2, 2)
    Σ_p_e = (σ_p_e .* σ_p_e') .* ρ_p_e
    ab_p_e ~ filldist(MvNormal([a_p_e,b_p_e], Σ_p_e),NUM_PARTICIPANTS)
    a_p_e = ab_p_e[1,participant.+1]
    b_p_e = ab_p_e[2,participant.+1]

    a_e_e ~ Normal(0,1)
    b_e_e ~ Normal(0,0.5)
    σ_e_e ~ filldist(Exponential(), 2)
    ρ_e_e ~ LKJ(2, 2)
    Σ_e_e = (σ_e_e .* σ_e_e') .* ρ_e_e
    ab_e_e ~ filldist(MvNormal([a_e_e,b_e_e], Σ_e_e),1)
    a_e_e = ab_e_e[1,1]
    b_e_e = ab_e_e[2,1]

    a_w_p ~ Normal(0,1)
    b_w_p ~ Normal(0,0.5)
    σ_w_p ~ filldist(Exponential(), 2)
    ρ_w_p ~ LKJ(2, 2)
    Σ_w_p = (σ_w_p .* σ_w_p') .* ρ_w_p
    ab_w_p ~ filldist(MvNormal([a_w_p,b_w_p], Σ_w_p),NUM_TYPES)
    a_w_p = ab_w_p[1,tags.+1]
    b_w_p = ab_w_p[2,tags.+1]
    
    a_p_p ~ Normal(0,1)
    b_p_p ~ Normal(0,0.5)
    σ_p_p ~ filldist(Exponential(), 2)
    ρ_p_p ~ LKJ(2, 2)
    Σ_p_p = (σ_p_p .* σ_p_p') .* ρ_p_p
    ab_p_p ~ filldist(MvNormal([a_p_p,b_p_p], Σ_p_p),NUM_PARTICIPANTS)
    a_p_p = ab_p_p[1,participant.+1]
    b_p_p = ab_p_p[2,participant.+1]

    a_e_p ~ Normal(0,1)
    b_e_p ~ Normal(0,0.5)
    σ_e_p ~ filldist(Exponential(), 2)
    ρ_e_p ~ LKJ(2, 2)
    Σ_e_p = (σ_e_p .* σ_e_p') .* ρ_e_p
    ab_e_p ~ filldist(MvNormal([a_e_p,b_e_p], Σ_e_p),1)
    a_e_p = ab_e_p[1,1]
    b_e_p = ab_e_p[2,1]

    μ_ePNP = @. a_w_e + a_p_e + a_e_e + ((b_w_e + b_p_e + b_e_e) * surprisal)
    μ_PNP = @. a_w_p + a_p_p + a_e_p + ((b_w_p + b_p_p + b_e_p) * surprisal)

    σ_μ ~ filldist(truncated(Cauchy(0,20),0,1000), 2)
    ρ_μ ~ LKJ(2, 2)
    Σ_μ = (σ_μ .* σ_μ') .* ρ_μ


    for i in eachindex(participant)
      eEGs[i,:] ~ MvNormal([μ_ePNP[i],μ_PNP[i]],Σ_μ)
      end
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,[df_modified.EPNP df_modified.PNP])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)

# Highest Density Interval