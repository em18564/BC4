# %%
include("../typeStructures.jl")
include("../setup.jl")
# %%
include("../model_master.jl")
include("../plottingFuncs.jl")
args = ["1", "6", "23", "1931", "NoNum", "11", "2", "1", "1", "1", "1"]
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain = createVariables(args)
# %%
fullSurps = []
gr(size=(1600,950), dpi=600)

p=Plots.scatter([], [],layout=(3,4),label=false)

for typeId in range(0,NUM_TYPES-1)
    surps = df_modified[df_modified.fullTag.==typeId,"Surprisal"]
    surps = ((surps.-mean(surps))./std(surps))
    Plots.histogram!(surps,subplot=typeId+1)
    fullSurps = vcat(fullSurps,surps)
end


