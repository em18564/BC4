
@model function model_6_05(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ Exponential(0.5)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ Exponential(0.5)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1]
  b_w = b_ws[tags.+1]

  σ_ap ~ Exponential(0.5)
  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  σ_bp ~ Exponential(0.5)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1]
  b_p = b_ps[participant.+1]

  a_e  ~ Normal(0,0.5)
  b_e  ~ Normal(0,0.5)

    μ = @. a_w*σ_aw + a_p*σ_ap + a_e + ((b_w*σ_bw + b_p*σ_bp + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end