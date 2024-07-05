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

  σ_w1 ~ filldist(Exponential(), 2)
  ρ_w1 ~ LKJ(2, 2)
  Σ_w1 = Symmetric(Diagonal(σ_w1) * ρ_w1 * Diagonal(σ_w1))
  ab_w1 ~ filldist(MvNormal([0,0], Σ_w1),NUM_TYPES)
  a_w1 = ab_w1[1,tags.+1]
  b_w1 = ab_w1[2,tags.+1]
  
  σ_w2 ~ filldist(Exponential(), 2)
    ρ_w2 ~ LKJ(2, 2)
    Σ_w2 = Symmetric(Diagonal(σ_w2) * ρ_w2 * Diagonal(σ_w2))
    ab_w2 ~ filldist(MvNormal([0,0], Σ_w2),NUM_TYPES)
    a_w2 = ab_w2[1,tags.+1]
    b_w2 = ab_w2[2,tags.+1]

    σ_w3 ~ filldist(Exponential(), 2)
    ρ_w3 ~ LKJ(2, 2)
    Σ_w3 = Symmetric(Diagonal(σ_w3) * ρ_w3 * Diagonal(σ_w3))
    ab_w3 ~ filldist(MvNormal([0,0], Σ_w3),NUM_TYPES)
    a_w3 = ab_w3[1,tags.+1]
    b_w3 = ab_w3[2,tags.+1]

    σ_w4 ~ filldist(Exponential(), 2)
    ρ_w4 ~ LKJ(2, 2)
    Σ_w4 = Symmetric(Diagonal(σ_w4) * ρ_w4 * Diagonal(σ_w4))
    ab_w4 ~ filldist(MvNormal([0,0], Σ_w4),NUM_TYPES)
    a_w4 = ab_w4[1,tags.+1]
    b_w4 = ab_w4[2,tags.+1]

    σ_w5 ~ filldist(Exponential(), 2)
    ρ_w5 ~ LKJ(2, 2)
    Σ_w5 = Symmetric(Diagonal(σ_w5) * ρ_w5 * Diagonal(σ_w5))
    ab_w5 ~ filldist(MvNormal([0,0], Σ_w5),NUM_TYPES)
    a_w5 = ab_w5[1,tags.+1]
    b_w5 = ab_w5[2,tags.+1]

    σ_w6 ~ filldist(Exponential(), 2)
    ρ_w6 ~ LKJ(2, 2)
    Σ_w6 = Symmetric(Diagonal(σ_w6) * ρ_w6 * Diagonal(σ_w6))
    ab_w6 ~ filldist(MvNormal([0,0], Σ_w6),NUM_TYPES)
    a_w6 = ab_w6[1,tags.+1]
    b_w6 = ab_w6[2,tags.+1]






    σ_p1 ~ filldist(Exponential(), 2)
    ρ_p1 ~ LKJ(2, 2)
    Σ_p1 = Symmetric(Diagonal(σ_p1) * ρ_p1 * Diagonal(σ_p1))
    ab_p1 ~ filldist(MvNormal([0,0], Σ_p1),NUM_PARTICIPANTS)
    a_p1 = ab_p1[1,participant.+1]
    b_p1 = ab_p1[2,participant.+1]

    σ_p2 ~ filldist(Exponential(), 2)
    ρ_p2 ~ LKJ(2, 2)
    Σ_p2 = Symmetric(Diagonal(σ_p2) * ρ_p2 * Diagonal(σ_p2))
    ab_p2 ~ filldist(MvNormal([0,0], Σ_p2),NUM_PARTICIPANTS)
    a_p2 = ab_p2[1,participant.+1]
    b_p2 = ab_p2[2,participant.+1]

    σ_p3 ~ filldist(Exponential(), 2)
    ρ_p3 ~ LKJ(2, 2)
    Σ_p3 = Symmetric(Diagonal(σ_p3) * ρ_p3 * Diagonal(σ_p3))
    ab_p3 ~ filldist(MvNormal([0,0], Σ_p3),NUM_PARTICIPANTS)
    a_p3 = ab_p3[1,participant.+1]
    b_p3 = ab_p3[2,participant.+1]

    σ_p4 ~ filldist(Exponential(), 2)
    ρ_p4 ~ LKJ(2, 2)
    Σ_p4 = Symmetric(Diagonal(σ_p4) * ρ_p4 * Diagonal(σ_p4))
    ab_p4 ~ filldist(MvNormal([0,0], Σ_p4),NUM_PARTICIPANTS)
    a_p4 = ab_p4[1,participant.+1]
    b_p4 = ab_p4[2,participant.+1]

    σ_p5 ~ filldist(Exponential(), 2)
    ρ_p5 ~ LKJ(2, 2)
    Σ_p5 = Symmetric(Diagonal(σ_p5) * ρ_p5 * Diagonal(σ_p5))
    ab_p5 ~ filldist(MvNormal([0,0], Σ_p5),NUM_PARTICIPANTS)
    a_p5 = ab_p5[1,participant.+1]
    b_p5 = ab_p5[2,participant.+1]

    σ_p6 ~ filldist(Exponential(), 2)
    ρ_p6 ~ LKJ(2, 2)
    Σ_p6 = Symmetric(Diagonal(σ_p6) * ρ_p6 * Diagonal(σ_p6))
    ab_p6 ~ filldist(MvNormal([0,0], Σ_p6),NUM_PARTICIPANTS)
    a_p6 = ab_p6[1,participant.+1]
    b_p6 = ab_p6[2,participant.+1]

    

    σ_e ~ filldist(Exponential(), 2)
    ρ_e ~ LKJ(2, 2)
    Σ_e = Symmetric(Diagonal(σ_e) * ρ_e * Diagonal(σ_e))
    ab_e ~ filldist(MvNormal([0,0], Σ_e),NUM_ERP)
    a_e = ab_e[1,:]
    b_e = ab_e[2,:]

    μ1 = @. a_w1 + a_p1 + a_e[1] + ((b_w1 + b_p1 + b_e[1]) * surprisal)
    μ2 = @. a_w2 + a_p2 + a_e[2] + ((b_w2 + b_p2 + b_e[2]) * surprisal)
    μ3 = @. a_w3 + a_p3 + a_e[3] + ((b_w3 + b_p3 + b_e[3]) * surprisal)
    μ4 = @. a_w4 + a_p4 + a_e[4] + ((b_w4 + b_p4 + b_e[4]) * surprisal)
    μ5 = @. a_w5 + a_p5 + a_e[5] + ((b_w5 + b_p5 + b_e[5]) * surprisal)
    μ6 = @. a_w6 + a_p6 + a_e[6] + ((b_w6 + b_p6 + b_e[6]) * surprisal)

    σ ~ truncated(Cauchy(0., 20.); lower = 0)

    for i in eachindex(PCA[:,1])
      PCA[i,1] ~ Normal(μ1[i],σ)
      PCA[i,2] ~ Normal(μ2[i],σ)
      PCA[i,3] ~ Normal(μ3[i],σ)
      PCA[i,4] ~ Normal(μ4[i],σ)
      PCA[i,5] ~ Normal(μ5[i],σ)
      PCA[i,6] ~ Normal(μ6[i],σ)
      end
end
df   = CSV.read("../../input/dfPCANorm.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))

dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4, :PC_5, :PC_6]]

mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,dfPCA)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)

# Highest Density Interval