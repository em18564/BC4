using Random
using Turing
using Turing: Variational

using Turing
using CSV
using DataFrames

using Serialization
using LinearAlgebra

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,ePNP)
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
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0,20),0,1000)

  for i in eachindex(ePNP)
    ePNP[i] ~ Normal(μ[i],σ)
    end
end

# Instantiate model
df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
m=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.PNP)
advi = ADVI(10, 1000)
q = vi(m, advi);