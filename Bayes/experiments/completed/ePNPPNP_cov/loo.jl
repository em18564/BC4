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
@model function model(participant,word,surprisal,tags,ePNP,pNP)
  σ_w_e ~ filldist(Exponential(), 2)
  ρ_w_e ~ LKJ(2, 2)
  Σ_w_e = (σ_w_e .* σ_w_e') .* ρ_w_e
  ab_w_e ~ filldist(MvNormal([0,0], Σ_w_e),NUM_TYPES)
  a_w_e = ab_w_e[1,tags.+1]
  b_w_e = ab_w_e[2,tags.+1]
  
  σ_p_e ~ filldist(Exponential(), 2)
  ρ_p_e ~ LKJ(2, 2)
  Σ_p_e = (σ_p_e .* σ_p_e') .* ρ_p_e
  ab_p_e ~ filldist(MvNormal([0,0], Σ_p_e),NUM_PARTICIPANTS)
  a_p_e = ab_p_e[1,participant.+1]
  b_p_e = ab_p_e[2,participant.+1]

  σ_e_e ~ filldist(Exponential(), 2)
  ρ_e_e ~ LKJ(2, 2)
  Σ_e_e = (σ_e_e .* σ_e_e') .* ρ_e_e
  ab_e_e ~ filldist(MvNormal([0,0], Σ_e_e),1)
  a_e_e = ab_e_e[1,1]
  b_e_e = ab_e_e[2,1]

  σ_w_p ~ filldist(Exponential(), 2)
  ρ_w_p ~ LKJ(2, 2)
  Σ_w_p = (σ_w_p .* σ_w_p') .* ρ_w_p
  ab_w_p ~ filldist(MvNormal([0,0], Σ_w_p),NUM_TYPES)
  a_w_p = ab_w_p[1,tags.+1]
  b_w_p = ab_w_p[2,tags.+1]
  
  σ_p_p ~ filldist(Exponential(), 2)
  ρ_p_p ~ LKJ(2, 2)
  Σ_p_p = (σ_p_p .* σ_p_p') .* ρ_p_p
  ab_p_p ~ filldist(MvNormal([0,0], Σ_p_p),NUM_PARTICIPANTS)
  a_p_p = ab_p_p[1,participant.+1]
  b_p_p = ab_p_p[2,participant.+1]

  σ_e_p ~ filldist(Exponential(), 2)
  ρ_e_p ~ LKJ(2, 2)
  Σ_e_p = (σ_e_p .* σ_e_p') .* ρ_e_p
  ab_e_p ~ filldist(MvNormal([0,0], Σ_e_p),1)
  a_e_p = ab_e_p[1,1]
  b_e_p = ab_e_p[2,1]

  μ_ePNP = @. a_w_e + a_p_e + a_e_e + ((b_w_e + b_p_e + b_e_e) * surprisal)
  μ_PNP = @. a_w_p + a_p_p + a_e_p + ((b_w_p + b_p_p + b_e_p) * surprisal)

  σ_ePNP ~ truncated(Cauchy(0,20),0,1000)
  σ_pNP ~ truncated(Cauchy(0,20),0,1000)

  for i in eachindex(ePNP)
    ePNP[i] ~ Normal(μ_ePNP[i],σ_ePNP)
    pNP[i] ~ Normal(μ_PNP[i],σ_pNP)
    end
end

chain = deserialize("output/out.jls")
df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.EPNP,df_modified.PNP)
psis_loo(mod,chain)