
@model function model_exp(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ truncated(Normal(0., 1.); lower = 0)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ truncated(Normal(0., 1.); lower = 0)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1].*σ_aw
  b_w = b_ws[tags.+1].*σ_bw


  σ_p  ~ filldist(truncated(Normal(0., 1.); lower = 0), 2)
  L_p  ~ LKJCholesky(2, 2)
  z_p  ~ filldist(MvNormal(zeros(2), I), NUM_PARTICIPANTS)
  ab_p = Diagonal(σ_p) * L_p.L * z_p
  a_p  = ab_p[1,participant.+1]
  b_p  = ab_p[2,participant.+1]


  μ = @. a_w + a_p + ((b_w + b_p) * surprisal)

  σ ~ truncated(Normal(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end