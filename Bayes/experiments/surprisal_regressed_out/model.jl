import Pkg
Pkg.add("Random")
#Pkg.add("StatsBase")
Pkg.add("Distributions")
#Pkg.add("StatsPlots")
#Pkg.add("StatsFuns")
#Pkg.add("Logging")

Pkg.add("Turing")
Pkg.add("CSV")
Pkg.add("DataFrames")
#Pkg.add("Optim")
#Pkg.add("StatisticalRethinking")
#Pkg.add("MCMCDiagnosticTools")
Pkg.add("Serialization")
Pkg.add("LinearAlgebra")
# %%

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

# args = map(x->string(x), ARGS)
# pc   = parse(Int,args[1])
# %%
NUM_WORDS = 1931 # max 1931
NUM_TYPES = 2
NUM_ERP = 4 # ELAN, LAN, N400, EPNP, P600, PNP
NUM_PARTICIPANTS = 24 # max 24


dfTags   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../../input/dfPCANorm_corrected.csv", DataFrame)
df[!,"fullTag"] = dfTags
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
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
df_modified = vcat(c,f)

dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4]]

# %%
#NUM_UNIQUE_WORDS = maximum(df_modified.innerUniqueWordId)

@model function model(participant,word,surprisal,tags,PCA)
  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
  ab_w ~ filldist(MvNormal([0,0], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]

  σ ~ Exponential(1)
  
  μ = @. a_w + (b_w * surprisal)
  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
end

for pc in range(1,4)
  mod = model(df_modified.Participant,df_modified.uniqueWordId,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc])
  m   = sample(mod, NUTS(), MCMCThreads(), 250,4)
  display(m)
  serialize("output_withWT/out"*string(pc)*".jls",m)
end


# Highest Density Interval