include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../plottingFuncs.jl")
include("../../setup.jl")
include("modelDef.jl")



timeStart = now()
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS = createVariables()
mod=model_11(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)
runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS)

print("\ntime taken", now()-timeStart)
