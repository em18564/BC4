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
sample(chn,2000)