include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../plottingFuncs.jl")
include("../../setup.jl")
include("modelDef.jl")

timeStart = now()
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean = createVariables()
NUM_UNIQUE_WORDS = maximum(df_modified.uniqueWordId)
mod=model_10(df_modified.Participant,df_modified.uniqueWordId,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean)
runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean)

print("\ntime taken", now()-timeStart)
