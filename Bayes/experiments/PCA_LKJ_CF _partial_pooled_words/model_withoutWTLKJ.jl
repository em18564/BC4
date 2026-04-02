# import Pkg
# Pkg.add("Random")
# Pkg.add("Distributions")
# Pkg.add("Turing")
# Pkg.add("CSV")
# Pkg.add("DataFrames")
# Pkg.add("Serialization")
# Pkg.add("LinearAlgebra")

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
output_folder = "noLKJ/output_withoutWT_10"
NUM_WORDS = 1931
NUM_TYPES = 11
NUM_ERP = 4 # ELAN, LAN, N400, EPNP, P600, PNP
NUM_PARTICIPANTS = 10


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
df_modified.Participant .= df_modified.Participant.+1

# %%
NUM_UNIQUE_WORDS = maximum(df_modified.innerUniqueWordId)

@model function model(participant,word,surprisal,tags,PCA)


  σ_aw ~ Exponential(2)
  a_ws ~ filldist(Normal(0, σ_aw),NUM_UNIQUE_WORDS)
  σ_bw ~ Exponential(2)
  b_ws ~ filldist(Normal(0, σ_bw),NUM_UNIQUE_WORDS)
  a_w = a_ws[word]
  b_w = b_ws[word]


  σ_ap ~ Exponential()
  a_ps ~ filldist(Normal(0, σ_ap),NUM_PARTICIPANTS)
  σ_bp ~ Exponential()
  b_ps ~ filldist(Normal(0, σ_bp),NUM_PARTICIPANTS)
  a_p = a_ps[participant]
  b_p = b_ps[participant]

  σ_ae ~ Exponential()
  a_e  ~ Normal(0,σ_ae)
  σ_be ~ Exponential()
  b_e  ~ Normal(0,σ_be)

  μ = @. a_p + a_e + a_w + ((b_p + b_e + b_w) * surprisal)

  σ ~ truncated(Cauchy(0., 20.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end


end

args = map(x->string(x), ARGS)
pc   = parse(Int,args[1])


CSV.write(output_folder*"/usedDF.csv",df_modified)
mod = model(df_modified.Participant,df_modified.uniqueWordId,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc])
m   = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize(output_folder*"/out"*string(pc)*".jls",m)



# Highest Density Interval