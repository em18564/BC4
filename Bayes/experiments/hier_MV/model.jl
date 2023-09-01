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
NUM_PARTICIPANTS = 12
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,eLAN,lAN,n400,ePNP,p600,pNP)
  σ_cor ~ filldist(Exponential(), 6)
  ρ_cor ~ LKJ(6, 2)
  Σ_cor = ((σ_cor .* σ_cor') .* ρ_cor)

  a_w_es ~ filldist(MvNormal(zeros(6), Σ_cor),NUM_TYPES)
  b_w_es ~ filldist(MvNormal(zeros(6), Σ_cor),NUM_TYPES)

  a_p_es ~ filldist(MvNormal(zeros(6), Σ_cor),NUM_PARTICIPANTS)
  b_p_es ~ filldist(MvNormal(zeros(6), Σ_cor),NUM_PARTICIPANTS)

    #[a_ep,b_ep] ~ MvNormal(zero, LKJ)

  ae ~ Normal(0,1)
  be ~ Normal(0,0.5)
  σ_e ~ filldist(Exponential(), 2)
  ρ_e ~ LKJ(2, 2)
  Σ_e = (σ_e .* σ_e') .* ρ_e
  ab_e ~ filldist(MvNormal([ae,be], Σ_e),NUM_ERP)
  
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]
  a_w_e = a_w_es[1,tags.+1]
  b_w_e = b_w_es[1,tags.+1]

  a_p_e = a_p_es[1,participant.+1]
  b_p_e = b_p_es[1,participant.+1]
  μ_eLAN = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)
  a_e = ab_e[1,2]
  b_e = ab_e[2,2]
  a_w_e = a_w_es[2,tags.+1]
  b_w_e = b_w_es[2,tags.+1]

  a_p_e = a_p_es[2,participant.+1]
  b_p_e = b_p_es[2,participant.+1]
  μ_lAN = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)
  a_e = ab_e[1,3]
  b_e = ab_e[2,3]
  a_w_e = a_w_es[3,tags.+1]
  b_w_e = b_w_es[3,tags.+1]

  a_p_e = a_p_es[3,participant.+1]
  b_p_e = b_p_es[3,participant.+1]
  μ_n400 = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)
  a_e = ab_e[1,4]
  b_e = ab_e[2,4]
  a_w_e = a_w_es[4,tags.+1]
  b_w_e = b_w_es[4,tags.+1]

  a_p_e = a_p_es[4,participant.+1]
  b_p_e = b_p_es[4,participant.+1]
  μ_ePNP = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)
  a_e = ab_e[1,5]
  b_e = ab_e[2,5]
  a_w_e = a_w_es[5,tags.+1]
  b_w_e = b_w_es[5,tags.+1]

  a_p_e = a_p_es[5,participant.+1]
  b_p_e = b_p_es[5,participant.+1]
  μ_p600 = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)
  a_e = ab_e[1,6]
  b_e = ab_e[2,6]
  a_w_e = a_w_es[6,tags.+1]
  b_w_e = b_w_es[6,tags.+1]

  a_p_e = a_p_es[6,participant.+1]
  b_p_e = b_p_es[6,participant.+1]
  μ_pNP = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * surprisal)

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

  #σ ~ truncated(Cauchy(0,20),0,1000)

  σ_σ ~ filldist(Exponential(10), 6)
  ρ_σ ~ LKJ(6, 2)
  Σ_σ = ((σ_σ .* σ_σ') .* ρ_σ)

  samples = [eLAN lAN n400 ePNP p600 pNP]
  μs = [μ_eLAN μ_lAN μ_n400 μ_ePNP μ_p600 μ_pNP]

  for i in eachindex(participant)
    samples[i,:] ~ MvNormal(μs[i,:],Σ_σ)
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