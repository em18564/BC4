
@model function model_11(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_w ~ filldist(Exponential(1), 2)
  Lcorr_w ~ LKJCholesky(2, 2)
  L_w = Diagonal(σ_w) * Matrix(Lcorr_w.L)
  z_ab_w ~ filldist(MvNormal([0.0,0.0], I(2)), NUM_TYPES)
  ab_w = L_w * z_ab_w
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]


  σ_p ~ filldist(Exponential(1), 2)
  Lcorr_p ~ LKJCholesky(2, 2)
  L_p = Diagonal(σ_p) * Matrix(Lcorr_p.L)
  z_ab_p ~ filldist(MvNormal([0.0,0.0], I(2)), NUM_PARTICIPANTS)
  ab_p = L_p * z_ab_p
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