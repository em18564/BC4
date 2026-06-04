@model function model_4(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ Exponential(1)
  a_ws ~ filldist(Normal(0, σ_aw),NUM_TYPES)
  σ_bw ~ Exponential(1)
  b_ws ~ filldist(Normal(0, σ_bw),NUM_TYPES)
  a_w = a_ws[tags.+1]
  b_w = b_ws[tags.+1]

  σ_ap ~ Exponential(1)
  a_ps ~ filldist(Normal(0, σ_ap),NUM_PARTICIPANTS)
  σ_bp ~ Exponential(1)
  b_ps ~ filldist(Normal(0, σ_bp),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1]
  b_p = b_ps[participant.+1]

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end