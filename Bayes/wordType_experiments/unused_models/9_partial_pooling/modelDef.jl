
@model function model(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean)

  σ_awt ~ Exponential(0.5)
  a_wts ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bwt ~ Exponential(0.5)
  b_wts ~ filldist(Normal(0, 1),NUM_TYPES)
  a_wt = a_wts[tags.+1].* σ_awt
  b_wt = b_wts[tags.+1].* σ_bwt

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

    μ = @. a_wt + a_w + a_p + a_e + ((b_wt + b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end