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
dfTags   = CSV.read("full_tags.csv", DataFrame).newTags
df       = CSV.read("dfPCANorm_corrected_6.csv", DataFrame)
df.fullTag = dfTags
df.fullTagDetSplit = dfTags
#df.Participant.+=1
# %%
for rowId in range(2,size(df)[1])
    if (df[rowId,"fullTag"]==4 && df[rowId-1,"fullTag"]==9 && df[rowId,"Wordpos"]>df[rowId-1,"Wordpos"])
        df[rowId,"fullTagDetSplit"] = 20
    end
end
# %%
CSV.write("dfPCANorm_corrected_6_WithDetSplit.csv",df)