include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../setup.jl")
include("../../plottingFuncs.jl")

@model function model(participant,word,surprisal,tags,PCA)

  σ_a ~ Exponential()
  σ_b ~ Exponential()

  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1]
  b_w = b_ws[tags.+1]

  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1]
  b_p = b_ps[participant.+1]

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

  μ = @. a_w*σ_a + a_p*σ_a + a_e + ((b_w*σ_b + b_p*σ_b + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)
  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
end



df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols = createVariables()
output_loc = "output_" * TYPE_STRUCTURE * "_" * string(NUM_PARTICIPANTS) * "_" * string(NUM_WORDS)
if (!isdir(output_loc))
  mkdir(output_loc)
end

mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize(output_loc*"/out"*string(pc)*".jls",m)

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
