
import Pkg
Pkg.instantiate()
using Random
# using StatsBase
using Distributions
# using StatsPlots
# using StatsFuns
# using Logging

using Turing
using CSV
using DataFrames
#using Optim
# using StatisticalRethinking

# using MCMCDiagnosticTools
using Serialization
using LinearAlgebra
# %%
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 23
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 4 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,PCA)

  σ_aw ~ Exponential()
  a_ws ~ filldist(Normal(0, σ_aw),NUM_TYPES)
  σ_bw ~ Exponential()
  b_ws ~ filldist(Normal(0, σ_bw),NUM_TYPES)
  a_w = a_ws[tags.+1]
  b_w = b_ws[tags.+1]


  σ_ap ~ Exponential()
  a_ps ~ filldist(Normal(0, σ_ap),NUM_PARTICIPANTS)
  σ_bp ~ Exponential()
  b_ps ~ filldist(Normal(0, σ_bp),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1]
  b_p = b_ps[participant.+1]

  σ_ae ~ Exponential()
  a_e  ~ Normal(0,σ_ae)
  σ_be ~ Exponential()
  b_e  ~ Normal(0,σ_be)
  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 20.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
end
args = map(x->string(x), ARGS)
pc   = parse(Int,args[1])
# %%
dfTags   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../../input/dfPCANorm_corrected.csv", DataFrame)
#%%
df[!,"fullTag"] = dfTags
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
#%%
c = vcat( subset(df_modified, :fullTag => ByRow((==(0)))),
          subset(df_modified, :fullTag => ByRow((==(5)))),
          subset(df_modified, :fullTag => ByRow((==(9)))),
          subset(df_modified, :fullTag => ByRow((==(2)))))
# adj = subset(df_modified, :fullTag => ByRow((==(0))))
# noun = subset(df_modified, :fullTag => ByRow((==(5))))
# noun.fullTag .= 1
# verb = subset(df_modified, :fullTag => ByRow((==(9))))
# verb.fullTag .= 2
# adv = subset(df_modified, :fullTag => ByRow((==(2))))
# adv.fullTag .= 3
f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
          subset(df_modified, :fullTag => ByRow((==(4)))),
          subset(df_modified, :fullTag => ByRow((==(7)))),
          subset(df_modified, :fullTag => ByRow((==(1)))),
          subset(df_modified, :fullTag => ByRow((==(8)))),
          subset(df_modified, :fullTag => ByRow((==(3)))))
c.fullTag .= 0
f.fullTag .= 1
# %%
# for p in range(1,NUM_PARTICIPANTS)
#   for t in range(1,NUM_TYPES)

#   end
# end
# %%
df_modified = vcat(c,f)
# %%
dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4]]
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output_noLKJ/out"*string(pc)*".jls",m)

# Highest Density Interval