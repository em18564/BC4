include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../setup.jl")
include("../../plottingFuncs.jl")



df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols = createVariables()

output_loc = "output_" * TYPE_STRUCTURE * "_" * string(NUM_PARTICIPANTS) * "_" * string(NUM_WORDS)

if(pc == 1)
  #wait for all other PCs to finish before greating plots
  global is_waiting = true
  while(is_waiting)
    if(isfile(output_loc*"/out1.jls") && isfile(output_loc*"/out2.jls") && isfile(output_loc*"/out3.jls") && isfile(output_loc*"/out4.jls"))
      print("plotting graphs")
      plotGraphs(output_loc,wordTypes,cols) 
      global is_waiting=false
    else
      print("Waiting for other PCs to complete")
      sleep(30)
    end
    
  end
end
