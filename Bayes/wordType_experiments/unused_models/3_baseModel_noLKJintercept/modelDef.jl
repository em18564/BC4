@model function model_3(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = Symmetric(Diagonal(σ_w) * ρ_w * Diagonal(σ_w))
  ab_w ~ filldist(MvNormal([0,0], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]

  σ_p ~ filldist(Exponential(), 2)
  ρ_p ~ LKJ(2, 2)
  Σ_p = Symmetric(Diagonal(σ_p) * ρ_p * Diagonal(σ_p))
  ab_p ~ filldist(MvNormal([0,0], Σ_p),NUM_PARTICIPANTS)
  a_p = ab_p[1,participant.+1]
  b_p = ab_p[2,participant.+1]


  a_e ~ Normal(0,1)
  b_e ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end