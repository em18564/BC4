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

df   = CSV.read("../../input/dfPCA.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4, :PC_5, :PC_6]]

chain = deserialize("output/out1.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,1])
ps1   = psis_loo(mod,chain)

chain = deserialize("output/out2.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,2])
ps2   = psis_loo(mod,chain)

chain = deserialize("output/out3.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,3])
ps3   = psis_loo(mod,chain)

chain = deserialize("output/out4.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,4])
ps4   = psis_loo(mod,chain)

chain = deserialize("output/out5.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,5])
ps5   = psis_loo(mod,chain)

chain = deserialize("output/out6.jls")
mod   = model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA[:,6])
ps6   = psis_loo(mod,chain)

Plots.plot(1:6,[[ps1.estimates[1],ps2.estimates[1],ps3.estimates[1],ps4.estimates[1],ps5.estimates[1],ps6.estimates[1]]])