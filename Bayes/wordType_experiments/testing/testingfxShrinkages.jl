include("../typeStructures.jl")
include("../setup.jl")
# %%
include("../model_master.jl")
include("../plottingFuncs.jl")
args = ["1", "6", "23", "1931", "NounDetSplit_New", "11", "2", "1", "1", "1", "1"]
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain = createVariables(args)
