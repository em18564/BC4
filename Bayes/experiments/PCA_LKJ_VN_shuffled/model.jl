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
Pkg.add("LinearAlgebra")


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
using LinearAlgebra

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,PCA)

  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
  ab_w ~ filldist(MvNormal([0,0], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags]
  b_w = ab_w[2,tags]


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

    σ ~ truncated(Cauchy(0., 20.); lower = 0)

    for i in eachindex(PCA)
      PCA[i] ~ Normal(μ[i],σ)
      end
end
args = map(x->string(x), ARGS)
pc   = parse(Int,args[1])
dfTags   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../../input/dfPCANorm.csv", DataFrame)
df[!,"fullTag"] = dfTags
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
df_modified   = subset(df_modified, :fullTag => ByRow((>=(7))))
df_modified   = subset(df_modified, :fullTag => ByRow((<=(9))))
df_modified   = subset(df_modified, :fullTag => ByRow((!=(8))))
df_modified.fullTag = df_modified.fullTag.-7
df_modified.fullTag = df_modified.fullTag./2
df_modified.fullTag = Int64.(df_modified.fullTag.+1)
dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4, :PC_5, :PC_6]]

mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,shuffle(df_modified.fullTag),dfPCA[:,pc])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out"*args[1]*".jls",m)

# Highest Density Interval