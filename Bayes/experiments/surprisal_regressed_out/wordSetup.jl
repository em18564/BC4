# %%

using Random
# using StatsBase
using Distributions
# using StatsPlots
# using StatsFuns
# using Logging

using Turing
using CSV
using DataFrames
#using Optim
# using StatisticalRethinking

# using MCMCDiagnosticTools
using Serialization
using LinearAlgebra
# %%
dfTagsVals   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df           = CSV.read("../../input/dfPCANorm_corrected.csv", DataFrame)
df_WithWords = CSV.read("../../input/df_WithWords.csv", DataFrame).realWord
dfTags       = Matrix(CSV.read("../../input/df_WithWords.csv", DataFrame)[!,["tags","realWord"]])
pairs = [(row[1], row[2]) for row in eachrow(dfTags)]
u = unique(pairs)
id_map = Dict(p => i for (i, p) in enumerate(u))
ids = [id_map[p] for p in pairs]
df.uniqueWordId = ids
CSV.write("../../input/dfPCANorm_corrected.csv",df)