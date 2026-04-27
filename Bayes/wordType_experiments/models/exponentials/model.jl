include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../setup.jl")
include("../../plottingFuncs.jl")

@model function model(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean)

  σ_aw ~ Exponential(ExpMean)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ Exponential(ExpMean)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1]
  b_w = b_ws[tags.+1]

  σ_ap ~ Exponential(ExpMean)
  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  σ_bp ~ Exponential(ExpMean)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1]
  b_p = b_ps[participant.+1]

  a_e  ~ Normal(0,ExpMean)
  b_e  ~ Normal(0,ExpMean)

  μ = @. a_w*σ_aw + a_p*σ_ap + a_e + ((b_w*σ_bw + b_p*σ_bp + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., cauchyMean); lower = 0)
  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
end


timeStart = now()
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean = createVariables()
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean)
runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean)

print("\ntime taken", now()-timeStart)