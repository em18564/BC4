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
    a   ~ MvNormal(zeros(NUM_WORDS),1)
    a_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    a_w ~ MvNormal(zeros(NUM_TYPES),1)
    a_e ~ MvNormal(zeros(NUM_ERP),1)

    σ_a  ~ Exponential(1)
    σ_ap ~ Exponential(1)
    σ_aw ~ Exponential(1)
    σ_ae ~ Exponential(1)

    b   ~ MvNormal(zeros(NUM_WORDS),1)
    b_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    b_w ~ MvNormal(zeros(NUM_WORDS),1)
    b_e ~ MvNormal(zeros(NUM_ERP),1)

    σ_b  ~ Exponential(1)
    σ_bp ~ Exponential(1)
    σ_bw ~ Exponential(1)
    σ_be ~ Exponential(1)
    
    # my a is an a_i, my a_i is the word type
    # contact sean, weds lunch pref 12 but can do 1
    # plot regression on word type
    # whisker plot
    # for each variable take the relevant columns and plot them as violin plot/ HDI plot
    # contact Davide for POS

    μ = (((a[Int.(word)] .* σ_a) .+ (a_p[Int.(participant.+1)] .* σ_ap) .+ (a_w[Int.(tags.+1)] .* σ_aw) .+ (a_e[Int.(component.+1)] .* σ_ae))
     .+  ((b[Int.(word)] .* σ_b) .+ (b_p[Int.(participant.+1)] .* σ_bp) .+ (b_w[Int.(tags.+1)] .* σ_bw) .+ (b_e[Int.(component.+1)] .* σ_be)) .* surprisal)

    ζ ~ Normal(0,1)
    σ ~ Exponential(20)
    
    ERP = σ .* ζ .+ μ
end

df = CSV.read("savedData/df_2.csv", DataFrame)
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
mod=model(df_modified.Participant, df_modified.ERP,df_modified.word,df_modified.surprisal,df_modified.tags,df_modified.component)
m = sample(mod, NUTS(), MCMCThreads(), 5,4)
display(m)
serialize("savedData/m_df.jls",m)


# Highest Density Interval