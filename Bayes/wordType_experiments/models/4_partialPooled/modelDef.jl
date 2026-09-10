
@model function model_pp(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS,NUM_WORDS)
  σ_ac ~ truncated(Normal(0., 1.); lower = 0)
  a_cs ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bc ~ truncated(Normal(0., 1.); lower = 0)
  b_cs ~ filldist(Normal(0, 1),NUM_TYPES)
  a_c = a_cs[tags.+1].*σ_ac
  b_c = b_cs[tags.+1].*σ_bc


  σ_aw ~ truncated(Normal(0., 1.); lower = 0)
  a_ws ~ filldist(Normal(0, 1),NUM_WORDS)
  σ_bw ~ truncated(Normal(0., 1.); lower = 0)
  b_ws ~ filldist(Normal(0, 1),NUM_WORDS)
  a_w = a_ws[tags.+1].*σ_aw
  b_w = b_ws[tags.+1].*σ_bw

  σ_ap ~ truncated(Normal(0., 1.); lower = 0)
  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  σ_bp ~ truncated(Normal(0., 1.); lower = 0)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1].*σ_ap
  b_p = b_ps[participant.+1].*σ_bp

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

  μ = @. a_w + a_p + a_e + a_c + ((b_w + b_p + b_e + b_c) * surprisal)

  γ    ~ Normal(0,1)
  σ_γp ~ truncated(Normal(0., 1.); lower = 0)
  z_γp ~ filldist(Normal(0., 1.),NUM_PARTICIPANTS)

  γ_p = z_γp[participant.+1].*σ_γp

  σ_p = exp.(γ.+γ_p)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ_p[i])
  end
  
end
