include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../plottingFuncs.jl")
include("../../setup.jl")
include("modelDef.jl")
# %%
vars = ["1", "6", "5", "1931", "FullADP", "1", "2", "1", "1", "1", "1"]

df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain = createVariables(vars)
isPlotting = 0
# %%
for i in range(1,noPCS)
    pc = i
    timeStart = now()
    println("Model " * string(i) * " of " * string(noPCS))
    println("__________________________________________")
    mod=model_tp2(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)
    runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean,noPCS,noInChain)
    println("\ntime taken", now()-timeStart)
end


