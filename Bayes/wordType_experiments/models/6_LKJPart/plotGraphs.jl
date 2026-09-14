# %%
include("../../typeStructures.jl")
include("../../setup.jl")
# %%
include("../../model_master.jl")
include("../../plottingFuncs.jl")
plotExistingModelGraphs(["1", "6", "23", "1931", "NoNum", "1", "2", "1", "1", "1", "1"])
#Plots.savefig(myplot,"test.png")