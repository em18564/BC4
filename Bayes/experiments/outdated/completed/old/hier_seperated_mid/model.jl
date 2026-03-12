using Random
using StatsBase
using Distributions
using StatsPlots
using StatsFuns
using Logging

using Turing
using CSV
using DataFrames
using Optim
using StatisticalRethinking

using MCMCDiagnosticTools
using Serialization

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 6
NUM_WORDS = 800
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,eLAN,lAN,n400,ePNP,p600,pNP)
  a_w ~ filldist(Normal(0,1),6)
  b_w ~ filldist(Normal(0,0.5),6)
  σ_w ~ filldist(Exponential(), 12)
  reshape(σ_w,(6,2))
  ρ_w_1 ~ LKJ(2, 2)
  ρ_w_2 ~ LKJ(2, 2)
  ρ_w_3 ~ LKJ(2, 2)
  ρ_w_4 ~ LKJ(2, 2)
  ρ_w_5 ~ LKJ(2, 2)
  ρ_w_6 ~ LKJ(2, 2)
  Σ_w_1 = (σ_w[1] .* σ_w[1]') .* ρ_w_1
  Σ_w_2 = (σ_w[2] .* σ_w[2]') .* ρ_w_2
  Σ_w_3 = (σ_w[3] .* σ_w[3]') .* ρ_w_3
  Σ_w_4 = (σ_w[4] .* σ_w[4]') .* ρ_w_4
  Σ_w_5 = (σ_w[5] .* σ_w[5]') .* ρ_w_5
  Σ_w_6 = (σ_w[6] .* σ_w[6]') .* ρ_w_6

  ab_w_1 ~ filldist(MvNormal([a_w[1],b_w[1]], Σ_w_1),NUM_TYPES)
  a_w_1 = ab_w_1[1,tags.+1]
  b_w_1 = ab_w_1[2,tags.+1]

  ab_w_2 ~ filldist(MvNormal([a_w[2],b_w[2]], Σ_w_2),NUM_TYPES)
  a_w_2 = ab_w_2[1,tags.+1]
  b_w_2 = ab_w_2[2,tags.+1]

  ab_w_3 ~ filldist(MvNormal([a_w[3],b_w[3]], Σ_w_3),NUM_TYPES)
  a_w_3 = ab_w_3[1,tags.+1]
  b_w_3 = ab_w_3[2,tags.+1]

  ab_w_4 ~ filldist(MvNormal([a_w[4],b_w[4]], Σ_w_4),NUM_TYPES)
  a_w_4 = ab_w_4[1,tags.+1]
  b_w_4 = ab_w_4[2,tags.+1]

  ab_w_5 ~ filldist(MvNormal([a_w[5],b_w[5]], Σ_w_5),NUM_TYPES)
  a_w_5 = ab_w_5[1,tags.+1]
  b_w_5 = ab_w_5[2,tags.+1]

  ab_w_6 ~ filldist(MvNormal([a_w[6],b_w[6]], Σ_w_6),NUM_TYPES)
  a_w_6 = ab_w_6[1,tags.+1]
  b_w_6 = ab_w_6[2,tags.+1]


  
  a_p ~ filldist(Normal(0,1),6)
  b_p ~ filldist(Normal(0,0.5),6)
  σ_p ~ filldist(Exponential(), 12)
  reshape(σ_p,(6,2))
  ρ_p_1 ~ LKJ(2, 2)
  ρ_p_2 ~ LKJ(2, 2)
  ρ_p_3 ~ LKJ(2, 2)
  ρ_p_4 ~ LKJ(2, 2)
  ρ_p_5 ~ LKJ(2, 2)
  ρ_p_6 ~ LKJ(2, 2)
  Σ_p_1 = (σ_p[1] .* σ_p[1]') .* ρ_p_1
  Σ_p_2 = (σ_p[2] .* σ_p[2]') .* ρ_p_2
  Σ_p_3 = (σ_p[3] .* σ_p[3]') .* ρ_p_3
  Σ_p_4 = (σ_p[4] .* σ_p[4]') .* ρ_p_4
  Σ_p_5 = (σ_p[5] .* σ_p[5]') .* ρ_p_5
  Σ_p_6 = (σ_p[6] .* σ_p[6]') .* ρ_p_6

  ab_p_1 ~ filldist(MvNormal([a_p[1],b_p[1]], Σ_p_1),NUM_PARTICIPANTS)
  a_p_1 = ab_p_1[1,participant.+1]
  b_p_1 = ab_p_1[2,participant.+1]

  ab_p_2 ~ filldist(MvNormal([a_p[2],b_p[2]], Σ_p_2),NUM_PARTICIPANTS)
  a_p_2 = ab_p_2[1,participant.+1]
  b_p_2 = ab_p_2[2,participant.+1]

  ab_p_3 ~ filldist(MvNormal([a_p[3],b_p[3]], Σ_p_3),NUM_PARTICIPANTS)
  a_p_3 = ab_p_3[1,participant.+1]
  b_p_3 = ab_p_3[2,participant.+1]

  ab_p_4 ~ filldist(MvNormal([a_p[4],b_p[4]], Σ_p_4),NUM_PARTICIPANTS)
  a_p_4 = ab_p_4[1,participant.+1]
  b_p_4 = ab_p_4[2,participant.+1]

  ab_p_5 ~ filldist(MvNormal([a_p[5],b_p[5]], Σ_p_5),NUM_PARTICIPANTS)
  a_p_5 = ab_p_5[1,participant.+1]
  b_p_5 = ab_p_5[2,participant.+1]

  ab_p_6 ~ filldist(MvNormal([a_p[6],b_p[6]], Σ_p_6),NUM_PARTICIPANTS)
  a_p_6 = ab_p_6[1,participant.+1]
  b_p_6 = ab_p_6[2,participant.+1]

  ae ~ Normal(0,1)
  be ~ Normal(0,0.5)
  σ_e ~ filldist(Exponential(), 2)
  ρ_e ~ LKJ(2, 2)
  Σ_e = (σ_e .* σ_e') .* ρ_e
  ab_e ~ filldist(MvNormal([ae,be], Σ_e),NUM_ERP)
  
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]
  μ_eLAN = @. a_w_1 + a_p_1 + a_e + ((b_w_1 + b_p_1 + b_e) * surprisal)
  a_e = ab_e[1,2]
  b_e = ab_e[2,2]
  μ_lAN  = @. a_w_2 + a_p_2 + a_e + ((b_w_2 + b_p_2 + b_e) * surprisal)
  a_e = ab_e[1,3]
  b_e = ab_e[2,3]
  μ_n400 = @. a_w_3 + a_p_3 + a_e + ((b_w_3 + b_p_3 + b_e) * surprisal)
  a_e = ab_e[1,4]
  b_e = ab_e[2,4]
  μ_ePNP = @. a_w_4 + a_p_4 + a_e + ((b_w_4 + b_p_4 + b_e) * surprisal)
  a_e = ab_e[1,5]
  b_e = ab_e[2,5]
  μ_p600 = @. a_w_5 + a_p_5 + a_e + ((b_w_5 + b_p_5 + b_e) * surprisal)
  a_e = ab_e[1,6]
  b_e = ab_e[2,6]
  μ_pNP  = @. a_w_6 + a_p_6 + a_e + ((b_w_6 + b_p_6 + b_e) * surprisal)

  # b_w - 2, 12 of them, pair of word type and erp. add pooling. regression gives means for each erp with correlation  matrix
  # e.g. correlation n400 with pnp -1

  # put a hierachy into b? b_w_e drawn from dist from Beta_w Normal(0,Beta_w) Beta_w ~ Exp(1)
  # look for changes in Beta_w

  # just have regression eq for Mew to a_e + b_e * surprisal
  # sigma_0 = a_p  + a_w + (b+p+b_w) * surprisal
  # sigma ~ Exp(sigma_0)
  # erp ~ Normal(mu_e, sigma)

  # try multiplicative

  # if works could be best!
  # have two indices, b_w_e, MVGaus structure so ERP have correlation matrix for LKJ
  # mu_e = a_e+a_ep+a_ew+ (b_e+b_ep+b_ew)*surprisal
  # Sigma ~ LKJ(6,2) up to the factors
  # erp ~ MVNormal([mu_e],Sigma)

  σ ~ truncated(Cauchy(0,20),0,1000)

  for i in eachindex(participant)
    eLAN[i] ~ Normal(μ_eLAN[i],σ)
    lAN[i]  ~ Normal(μ_lAN[i],σ)
    n400[i] ~ Normal(μ_n400[i],σ)
    ePNP[i] ~ Normal(μ_ePNP[i],σ)
    p600[i] ~ Normal(μ_p600[i],σ)
    pNP[i]  ~ Normal(μ_pNP[i],σ)
    end
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.ELAN,df_modified.LAN,df_modified.N400,df_modified.EPNP,df_modified.P600,df_modified.PNP)
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)


# Highest Density Interval