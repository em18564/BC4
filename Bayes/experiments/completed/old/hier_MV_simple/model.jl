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
NUM_PARTICIPANTS = 6
NUM_WORDS = 800
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,eLAN,lAN,n400,ePNP,p600,pNP)
  a_w ~ Normal(0,1)
  b_w ~ Normal(0,0.5)
  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = (σ_w .* σ_w') .* ρ_w
  ab_w ~ filldist(MvNormal([a_w,b_w], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]
  

  a_p ~ Normal(0,1)
  b_p ~ Normal(0,0.5)
  σ_p ~ filldist(Exponential(), 2)
  ρ_p ~ LKJ(2, 2)
  Σ_p = (σ_p .* σ_p') .* ρ_p
  ab_p ~ filldist(MvNormal([a_p,b_p], Σ_p),NUM_PARTICIPANTS)
  a_p = ab_p[1,participant.+1]
  b_p = ab_p[2,participant.+1]

  a_e ~ Normal(0,1)
  b_e ~ Normal(0,0.5)
  σ_e ~ filldist(Exponential(), 2)
  ρ_e ~ LKJ(2, 2)
  Σ_e = (σ_e .* σ_e') .* ρ_e
  ab_e ~ filldist(MvNormal([a_e,b_e], Σ_e),NUM_ERP)
  
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]
  μ_eLAN = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,2]
  b_e = ab_e[2,2]
  μ_lAN = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,3]
  b_e = ab_e[2,3]
  μ_n400 = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,4]
  b_e = ab_e[2,4]
  μ_ePNP = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,5]
  b_e = ab_e[2,5]
  μ_p600 = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,6]
  b_e = ab_e[2,6]
  μ_pNP = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  
  σ_σ ~ filldist(Exponential(10), 6)
  ρ_σ ~ LKJ(6, 2) # identity matrix sanity checks
  Σ_σ = ((σ_σ .* σ_σ') .* ρ_σ)

  samples = [eLAN lAN n400 ePNP p600 pNP]
  μs = [μ_eLAN μ_lAN μ_n400 μ_ePNP μ_p600 μ_pNP]

  for i in eachindex(participant)
    samples[i,:] ~ μs[i,:] +Σ_σ*MvNormal(zeros(6),ones(6))
    end
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.ELAN,df_modified.LAN,df_modified.N400,df_modified.EPNP,df_modified.P600,df_modified.PNP)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)


# Highest Density Interval