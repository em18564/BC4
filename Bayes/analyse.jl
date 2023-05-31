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
using MCMCChains
using Serialization
using Plots

chn = deserialize("savedData/m_df.jls")

ess_rhat_df = DataFrame(ess_rhat(chn))

histogram(ess_rhat_df[!,"rhat"],label="rhat")
savefig("graphs/rhat.png")

histogram(ess_rhat_df[!,"ess"],label="ess")
savefig("graphs/ess.png")


plot(chn, colordim = :parameter; size=(1680, 800))
savefig("graphs/trace.png")

# autocorplot(chn,size=(1680,800))
# savefig("graphs/autocor.png")

