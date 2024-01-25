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
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,PCA)
    a_w_s ~ filldist(Normal(0,1),NUM_TYPES)
    b_w_s ~ filldist(Normal(0,0.5),NUM_TYPES)
    a_w   = a_w_s[tags.+1]
    b_w   = b_w_s[tags.+1]

    a_p_s ~ filldist(Normal(0,1),NUM_PARTICIPANTS)
    b_p_s ~ filldist(Normal(0,0.5),NUM_PARTICIPANTS)
    a_p   = a_p_s[participant.+1]
    b_p   = b_p_s[participant.+1]

    a_e ~ Normal(0,1)
    b_e ~ Normal(0,0.5)

    μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

    σ ~ truncated(Cauchy(0., 20.); lower = 0)

    for i in eachindex(PCA)
      PCA[i] ~ Normal(μ[i],σ)
      end
end
args = map(x->string(x), ARGS)
pc   = parse(Int,args[1])
df   = CSV.read("../../input/dfPCA.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))

dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4, :PC_5, :PC_6]]



mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,pc])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out"*args[1]*".jls",m)

# Highest Density Interval