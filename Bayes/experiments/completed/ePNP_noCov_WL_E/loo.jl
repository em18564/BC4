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
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,ePNP,wordLength)
  a_w_s ~ filldist(Normal(0,1),NUM_TYPES)
  b_w_s ~ filldist(Normal(0,0.5),NUM_TYPES)
  c_w_s ~ filldist(Normal(0,1),NUM_TYPES)
  a_w   = a_w_s[tags.+1]
  b_w   = b_w_s[tags.+1]
  c_w   = c_w_s[tags.+1]

  a_p_s ~ filldist(Normal(0,1),NUM_PARTICIPANTS)
  b_p_s ~ filldist(Normal(0,0.5),NUM_PARTICIPANTS)
  a_p   = a_p_s[participant.+1]
  b_p   = b_p_s[participant.+1]

  a_e ~ Normal(0,1)
  b_e ~ Normal(0,0.5)

  

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal) + ((c_w) * wordLength)

  σ ~ truncated(Cauchy(0., 20.); lower = 0)

  for i in eachindex(ePNP)
    ePNP[i] ~ Normal(μ[i],σ)
    end
end

df = CSV.read("../../input/dfHierarchicalNorm.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.PNP,df_modified.Wordlen)

chain = deserialize("output/out.jls")
p= psis_loo(mod,chain)