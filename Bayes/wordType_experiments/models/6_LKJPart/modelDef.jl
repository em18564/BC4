
@model function model_12_1(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ Exponential(1)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ Exponential(1)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1].*σ_aw
  b_w = b_ws[tags.+1].*σ_bw

  σ_p ~ filldist(Exponential(), 2)
  ρ_p ~ LKJ(2, 2)
  Σ_p = Symmetric(Diagonal(σ_p) * ρ_p * Diagonal(σ_p))
  ab_p ~ filldist(MvNormal([0,0], Σ_p),NUM_PARTICIPANTS)
  a_p = ab_p[1,participant.+1]
  b_p = ab_p[2,participant.+1]

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

    μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end