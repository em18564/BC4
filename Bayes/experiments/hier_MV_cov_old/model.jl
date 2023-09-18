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
NUM_PARTICIPANTS = 2
NUM_WORDS = 400
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,eEGs)
  a_w ~ Normal(0,1)
  b_w ~ Normal(0,0.5)
  σ_w ~ filldist(Exponential(), 2)
  ρ_w ~ LKJ(2, 2)
  Σ_w = (σ_w .* σ_w') .* ρ_w
  ab_w ~ filldist(MvNormal([a_w,b_w], Σ_w),NUM_TYPES)
  a_w = ab_w[1,tags.+1]
  b_w = ab_w[2,tags.+1]
  

  a_p ~ Normal(0,1)
  b_p ~ Normal(0,0.5)
  σ_p ~ filldist(Exponential(), 2)
  ρ_p ~ LKJ(2, 2)
  Σ_p = (σ_p .* σ_p') .* ρ_p
  ab_p ~ filldist(MvNormal([a_p,b_p], Σ_p),NUM_PARTICIPANTS)
  a_p = ab_p[1,participant.+1]
  b_p = ab_p[2,participant.+1]

  a_e ~ Normal(0,1)
  b_e ~ Normal(0,0.5)
  σ_e ~ filldist(Exponential(), 2)
  ρ_e ~ LKJ(2, 2)
  Σ_e = (σ_e .* σ_e') .* ρ_e
  ab_e ~ filldist(MvNormal([a_e,b_e], Σ_e),NUM_ERP)
  
  a_e = ab_e[1,1]
  b_e = ab_e[2,1]
  μ_eLAN = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,2]
  b_e = ab_e[2,2]
  μ_lAN = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,3]
  b_e = ab_e[2,3]
  μ_n400 = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,4]
  b_e = ab_e[2,4]
  μ_ePNP = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,5]
  b_e = ab_e[2,5]
  μ_p600 = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
  a_e = ab_e[1,6]
  b_e = ab_e[2,6]
  μ_pNP = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

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
  Σ_σ = [ 21.8175     4.64296    1.51328   0.207691  -1.55949   -2.02525
  4.64296   30.0462    12.4095    7.12357    0.718256   1.56873
  1.51328   12.4095    15.9679    4.7445     3.63401    2.57624
  0.207691   7.12357    4.7445   14.6443     4.69082   11.0562
 -1.55949    0.718256   3.63401   4.69082   13.6554    10.7355
 -2.02525    1.56873    2.57624  11.0562    10.7355    18.2697]

  for i in eachindex(participant)
    eEGs[i,:] ~ [μ_eLAN[i], μ_lAN[i], μ_n400[i], μ_ePNP[i], μ_p600[i], μ_pNP[i]] + Σ_σ*MvNormal(zeros(6),ones(6))
    end
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,[df_modified.ELAN df_modified.LAN df_modified.N400 df_modified.EPNP df_modified.P600 df_modified.PNP])
m = sample(mod, NUTS(), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)


# Highest Density Interval~