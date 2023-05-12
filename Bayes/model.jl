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

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 4
NUM_WORDS = 1931
@model function model(participant,ERP,word,surprisal)
    a ~ Normal(0,1)
    a_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    a_w ~ MvNormal(zeros(NUM_WORDS),1)

    σ_a  ~ Exponential(1)
    σ_ap ~ Exponential(1)
    σ_aw ~ Exponential(1)

    b ~ Normal(0,1)
    b_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    b_w ~ MvNormal(zeros(NUM_WORDS),1)

    σ_b  ~ Exponential(1)
    σ_bp ~ Exponential(1)
    σ_bw ~ Exponential(1)


    μ = ((a .* σ_a) .+ (a_p[Int.(participant)] .* σ_ap) .+ (a_w[Int.(word)] .* σ_aw)) .+ ((b .* σ_b) .+ (b_p[Int.(participant)] .* σ_bp) .+ (b_w[Int.(word)] .* σ_bw)) .* surprisal

    ζ ~ Normal(0,1)
    σ ~ Exponential(20)
    
    ERP = σ .* ζ .+ μ
end

df = CSV.read("savedData/df.csv", DataFrame)
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS+1)))
mod=model(df_modified.Participant, df_modified.ERP,df_modified.word,df_modified.surprisal)
m = sample(mod, NUTS(), MCMCThreads(), 1,10)
m_df = DataFrame(m)
display(m)
#CSV.write("savedData/m_df.csv", m_df)
