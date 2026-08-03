
@model function model_14(participant,word,surprisal,tags,PCA,ExpMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)
  ε1   ~ MvNormal(length(PCA), 1.0)
  ε2   ~ MvNormal(length(PCA), 1.0)
  ε3   ~ MvNormal(length(PCA), 1.0)
  ε4   ~ MvNormal(length(PCA), 1.0)
  
  σ_aw ~ filldist(Exponential(1),NUM_TYPES)
  a_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  σ_bw ~ filldist(Exponential(1),NUM_TYPES)
  b_ws ~ filldist(Normal(0, 1),NUM_TYPES)
  a_w = a_ws[tags.+1].+ε1.*σ_aw[tags.+1]
  b_w = b_ws[tags.+1].+ε2.*σ_bw[tags.+1]

  σ_ap ~ filldist(Exponential(1),NUM_PARTICIPANTS)
  a_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  σ_bp ~ filldist(Exponential(1),NUM_PARTICIPANTS)
  b_ps ~ filldist(Normal(0, 1),NUM_PARTICIPANTS)
  a_p = a_ps[participant.+1].+ε3.*σ_ap[participant.+1]
  b_p = b_ps[participant.+1].+ε4.*σ_bp[participant.+1]

  a_e  ~ Normal(0,1)
  b_e  ~ Normal(0,1)

    μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

  σ ~ truncated(Cauchy(0., 1.); lower = 0)

  for i in eachindex(PCA)
    PCA[i] ~ Normal(μ[i],σ)
  end
  
end