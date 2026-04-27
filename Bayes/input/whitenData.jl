# %%
import Pkg
Pkg.instantiate()
using Random
using Distributions
using Turing
using CSV
using DataFrames
using Serialization
using LinearAlgebra
using StatsBase
using StatsFuns
using Logging
using Plots
using PlotlyJS
using Images, FileIO
using Measures


# %%
dfTags   = CSV.read("full_tags.csv", DataFrame).tags
df       = CSV.read("dfPCANorm_corrected.csv", DataFrame)

df.Participant.+=1
