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
NUM_PARTICIPANTS = 4
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,ERP,word,surprisal,tags,component)
    a   ~ Normal(0,1)
    a_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    a_w ~ MvNormal(zeros(NUM_TYPES),1)
    a_e ~ Normal(0,1)

    σ_a  = 1
    σ_ap = 1
    σ_aw = 1
    σ_ae = 1

    b   ~ Normal(0,0.5)
    b_p ~ MvNormal(zeros(NUM_PARTICIPANTS),0.5)
    b_w ~ MvNormal(zeros(NUM_WORDS),0.5)
    b_e ~ Normal(0,0.5)

    σ_b  = 1
    σ_bp = 1
    σ_bw = 1
    σ_be = 1
    
    # my a is an a_i, my a_i is the word type
    # contact sean, weds lunch pref 12 but can do 1
    # plot regression on word type
    # whisker plot
    # for each variable take the relevant columns and plot them as violin plot/ HDI plot
    # contact Davide for POS

    μ = (((a .* σ_a) .+ (a_p[Int.(participant.+1)] .* σ_ap) .+ (a_w[Int.(tags.+1)] .* σ_aw) .+ (a_e .* σ_ae))
     .+  ((b .* σ_b) .+ (b_p[Int.(participant.+1)] .* σ_bp) .+ (b_w[Int.(tags.+1)] .* σ_bw) .+ (b_e .* σ_be)) .* surprisal)

    ζ ~ Normal(0,1)
    σ ~ truncated(Cauchy(0,20),0,1000)
    
    ERP = σ .* ζ .+ μ
end

df = CSV.read("savedData/df_2.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :component => ByRow(==(2)))
mod=model(df_modified.Participant, df_modified.ERP,df_modified.word,df_modified.surprisal,df_modified.tags,df_modified.component)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("savedData/m_df_a.jls",m)


# Highest Density Interval