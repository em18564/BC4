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
NUM_WORDS = 500
NUM_TYPES = 11
NUM_ERP = 4 # ELAN, LAN, N400, EPNP, P600, PNP
NUM_PARTICIPANTS = 2


dfTags   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../../input/dfPCANorm_corrected.csv", DataFrame)
df[!,"fullTag"] = dfTags
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4]]
u = unique(df_modified.uniqueWordId)
id_map = Dict(p => i for (i, p) in enumerate(u))
ids = [id_map[p] for p in df_modified.uniqueWordId]
df_modified.innerUniqueWordId = ids

# %%
NUM_UNIQUE_WORDS = maximum(df_modified.innerUniqueWordId)

@model function model(participant,word,surprisal,tags,PCA)

  σ_wt ~ filldist(Exponential(), 2)
  ρ_wt ~ LKJ(2, 2)
  Σ_wt = Symmetric(Diagonal(σ_wt) * ρ_wt * Diagonal(σ_wt))
  ab_wt ~ filldist(MvNormal([0,0], Σ_wt),NUM_TYPES)
  a_wt = ab_wt[1,tags.+1]
  b_wt = ab_wt[2,tags.+1]


  σ_w ~ filldist(Exponential(2), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
  ab_w ~ filldist(MvNormal([0,0], Σ_w),NUM_UNIQUE_WORDS)
  a_w = ab_w[1,word]
  b_w = ab_w[2,word]



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

  μ = @. a_wt + a_p + a_e + a_w + ((b_wt + b_p + b_e + b_w) * surprisal)

  σ ~ truncated(Cauchy(0., 20.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end

end

# args = map(x->string(x), ARGS)
# pc   = parse(Int,args[1])


CSV.write("output_withWT/usedDF.csv",df_modified)
for pc in range(1,4)
  mod = model(df_modified.Participant,df_modified.uniqueWordId,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc])
  m   = sample(mod, NUTS(), MCMCThreads(), 250,4)
  display(m)
  serialize("output_withWT/out"*string(pc)*".jls",m)
end


# Highest Density Interval