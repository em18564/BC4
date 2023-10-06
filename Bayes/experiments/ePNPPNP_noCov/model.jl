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
@model function model(participant,word,surprisal,tags,ePNP,pNP)
  a_w_s1 ~ filldist(Normal(0,1),NUM_TYPES)
  b_w_s1 ~ filldist(Normal(0,0.5),NUM_TYPES)
  a_w_e   = a_w_s1[tags.+1]
  b_w_e   = b_w_s1[tags.+1]

  a_p_s1 ~ filldist(Normal(0,1),NUM_PARTICIPANTS)
  b_p_s1 ~ filldist(Normal(0,0.5),NUM_PARTICIPANTS)
  a_p_e   = a_p_s1[participant.+1]
  b_p_e   = b_p_s1[participant.+1]

  a_e_e ~ Normal(0,1)
  b_e_e ~ Normal(0,0.5)

  a_w_s2 ~ filldist(Normal(0,1),NUM_TYPES)
  b_w_s2 ~ filldist(Normal(0,0.5),NUM_TYPES)
  a_w_p   = a_w_s2[tags.+1]
  b_w_p   = b_w_s2[tags.+1]

  a_p_s2 ~ filldist(Normal(0,1),NUM_PARTICIPANTS)
  b_p_s2 ~ filldist(Normal(0,0.5),NUM_PARTICIPANTS)
  a_p_p   = a_p_s2[participant.+1]
  b_p_p   = b_p_s2[participant.+1]

  a_e_p ~ Normal(0,1)
  b_e_p ~ Normal(0,0.5)

    μ_ePNP = @. a_w_e + a_p_e + a_e_e + ((b_w_e + b_p_e + b_e_e) * surprisal)
    μ_PNP = @. a_w_p + a_p_p + a_e_p + ((b_w_p + b_p_p + b_e_p) * surprisal)

    σ_ePNP ~ truncated(Cauchy(0,20),0,1000)
    σ_pNP ~ truncated(Cauchy(0,20),0,1000)

    for i in eachindex(ePNP)
      ePNP[i] ~ Normal(μ_ePNP[i],σ_ePNP)
      pNP[i] ~ Normal(μ_PNP[i],σ_pNP)
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