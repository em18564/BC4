
@model function model_exp(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)

  σ_aw ~ Exponential(1)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ Exponential(1)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1].*σ_aw
  b_w = b_ws[tags.+1].*σ_bw

  τ_p ~ truncated(Cauchy(0, 1); lower=0) #global shrinkage
  λ_p ~ filldist(truncated(Cauchy(0, 1); lower=0), NUM_PARTICIPANTS) #participant shrinkage
  β_p ~ MvNormal(Diagonal((λ_p .* τ_p).^2)) # Coefficients construction
  σ_ap ~ Exponential(1) #participant effect scale
  a_p = β_p[participant.+1].*σ_ap


  σ_bp ~ Exponential(1)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  b_p = b_ps[participant.+1].*σ_bp

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end