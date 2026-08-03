@model function model_1(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_w ~ filldist(Exponential(1), 2)
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

  σ_e ~ filldist(Exponential(), 2)
  ρ_e ~ LKJ(2, 2)
  Σ_e = Symmetric(Diagonal(σ_e) * ρ_e * Diagonal(σ_e))
  ab_e ~ filldist(MvNormal([0,0], Σ_e),1)
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 20.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end