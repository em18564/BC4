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
@model function model(participant,eRP,word,surprisal,tags,component)
  a_w ~ Normal(0,1)
  b_w ~ Normal(0,0.5)
  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = (σ_w .* σ_w') .* ρ_w
  ab_w ~ filldist(MvNormal([a_w,b_w], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]
  

  a_p ~ Normal(0,1)

  a_e ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + (b_w * surprisal)

  σ ~ truncated(Cauchy(0,20),0,1000)

  for i in eachindex(eRP)
      eRP[i] ~ Normal(μ[i],σ)
    end
end

df = CSV.read("savedData/df.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant, df_modified.ERP,df_modified.word,df_modified.surprisal,df_modified.tags,df_modified.component)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("savedData/m_df_ltd_word.jls",m)


# Highest Density Interval
