
@model function model_12_1(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ Exponential(1)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ Exponential(1)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1].*σ_aw
  b_w = b_ws[tags.+1].*σ_bw

  σ_p ~ filldist(Exponential(), 2)
  L_p ~ LKJCholesky(2, 2)
  z_p ~ filldist(MvNormal(zeros(2), I), NUM_PARTICIPANTS)
  alpha = Diagonal(σ_p) * L_p.L * z_p
  a_p = alpha[1,participant.+1]
  b_p = alpha[2,participant.+1]


  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end