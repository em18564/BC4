include("../../typeStructures.jl")
include("../../model_master.jl")
include("../../plottingFuncs.jl")
include("../../setup.jl")

@model function model(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean)



  σ_aw ~ Exponential(0.5)
  σ_bw ~ Exponential(0.5)
  a_ws ~ filldist(Normal(0, 1), NUM_UNIQUE_WORDS)
  b_ws ~ filldist(Normal(0, 1), NUM_UNIQUE_WORDS)
  a_w = a_ws[word].*σ_aw
  b_w = b_ws[word].*σ_bw

  σ_ap ~ Exponential(0.5)
  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  σ_bp ~ Exponential(0.5)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1].*σ_ap
  b_p = b_ps[participant.+1].*σ_bp

  a_e  ~ Normal(0,0.5)
  b_e  ~ Normal(0,0.5)

    μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end


timeStart = now()
df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean = createVariables()
NUM_UNIQUE_WORDS = maximum(df_modified.uniqueWordId)
mod=model(df_modified.Participant,df_modified.uniqueWordId,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean)
runModel(mod,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean)

print("\ntime taken", now()-timeStart)
