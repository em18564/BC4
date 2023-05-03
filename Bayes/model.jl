using CSV
using Random
using StatsBase
using DataFrames
using Distributions
using Turing
using StatsPlots
using StatisticalRethinking

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
@model function model(participant,ERP,word,surprisal)
    a1 ~ Normal(0,1)
    a2 ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    a3 ~ MvNormal(zeros(NUM_WORDS),1)

    b1 ~ Normal(0,1)
    b2 ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    b3 ~ MvNormal(zeros(NUM_WORDS),1)
    μ = (a1 .+ a2[Int.(participant)] .+ a3[Int.(word)]) .+ (b1 .+ b2[Int.(participant)] .+ b3[Int.(word)]) .* surprisal
    σ ~ Uniform(0, 1)
    ERP ~ MvNormal(μ, σ)
end

df = CSV.read("savedData/df.csv", DataFrame)
#precis(df)
mod=model(df.Participant, df.ERP,df.word,df.surprisal)
m = sample(mod, NUTS(), MCMCThreads(), 1000, 4)
m_df = DataFrame(m)
CSV.write("savedData/m_df.csv", m_df)
