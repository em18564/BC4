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
NUM_WORDS = 800
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,eRP,word,surprisal,tags,component)
    a   ~ Normal(0,1)
    a_p ~ MvNormal(zeros(NUM_PARTICIPANTS),1)
    a_w ~ MvNormal(zeros(NUM_TYPES),1)
    a_e ~ MvNormal(zeros(NUM_ERP),1)

    σ_a  = 1
    σ_ap = 1
    σ_aw = 1
    σ_ae = 1

    b   ~ Normal(0,0.5)
    b_p ~ MvNormal(zeros(NUM_PARTICIPANTS),0.5)
    b_w ~ MvNormal(zeros(NUM_TYPES),0.5)
    b_e ~ MvNormal(zeros(NUM_ERP),0.5)

    σ_b  = 1
    σ_bp = 1
    σ_bw = 1
    σ_be = 1

    
    σ ~ truncated(Cauchy(0,20),0,1000)
    for i in eachindex(eRP)
        #ζ ~ Normal(0,1)
        μ = (((a * σ_a) + (a_p[Int(participant[i]+1)] * σ_ap) + (a_w[Int(tags[i]+1)] * σ_aw) + (a_e[Int.(component[i]+1)] * σ_ae))
        +    ((b * σ_b) + (b_p[Int(participant[i]+1)] * σ_bp) + (b_w[Int(tags[i]+1)] * σ_bw) + (b_e[Int.(component[i]+1)] * σ_be)) * surprisal[i])
        eRP[i] ~ Normal(μ,σ)
      end
end

df = CSV.read("savedData/df.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified_2 = subset(df_modified_1, :word => ByRow(<(NUM_WORDS)))
df_modified = subset(df_modified_2, :component => ByRow(==(2)))
mod=model(df_modified.Participant, df_modified.ERP,df_modified.word,df_modified.surprisal,df_modified.tags,df_modified.component)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("savedData/m_df_ltd.jls",m)


# Highest Density Interval