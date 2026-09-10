include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../plottingFuncs.jl")
include("../../setup.jl")
include("modelDef.jl")



timeStart = now()
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain = createVariables()

word = getWordIds(df_modified)
NUM_WORDS = maximum(word)

mod=model_pp(df_modified.Participant,word,renormaliseSurps(df_modified,NUM_TYPES),df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS,NUM_WORDS)
runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain)

print("\ntime taken", now()-timeStart)
