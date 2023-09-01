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

# @model function testMod()
#   σ_cor ~ filldist(Exponential(), 6)
#   ρ_cor ~ LKJ(6, 2)
#   Σ_cor = ((σ_cor .* σ_cor') .* ρ_cor)

#   a_w_es ~ filldist(MvNormal(zeros(6), Σ_cor),2)
#   b_w_es ~ filldist(MvNormal(zeros(6), Σ_cor),2)

#   a_p_es ~ filldist(MvNormal(zeros(6), Σ_cor),10)
#   b_p_es ~ filldist(MvNormal(zeros(6), Σ_cor),10)

#   a_e ~ Normal(0,1)
#   b_e ~ Normal(0,0.5)
#   σ_e ~ filldist(Exponential(), 2)
#   ρ_e ~ LKJ(2, 2)
#   Σ_e = (σ_e .* σ_e') .* ρ_e
#   ab_e ~ filldist(MvNormal([a_e,b_e], Σ_e),6)
  
#   a_e = ab_e[1,1]
#   b_e = ab_e[2,1]
#   a_w_e = a_w_es[1,2]
#   b_w_e = b_w_es[1,2]
#   a_p_e = a_p_es[1,5]
#   b_p_e = b_p_es[1,5]
#   μ_eLAN = @. a_w_e + a_p_e + a_e + ((b_w_e + b_p_e + b_e) * 0.2)

#   σ_σ ~ filldist(Exponential(),6)
#   ρ_σ ~ LKJ(6, 2)
#   Σ_σ = ((σ_σ .* σ_σ') .* ρ_σ)

#   mvNorm = MvNormal([μ_eLAN,μ_eLAN,μ_eLAN,μ_eLAN,μ_eLAN,μ_eLAN],Σ_σ)
#   a=1
#   b=2
#   c=3
#   d=4
#   e=5
#   f=6
#   fff = [a,b,c,d,e,f]
#   fff ~ mvNorm
#   println(a)
# end
# m = sample(testMod(), NUTS(), 1)



a = [1 2 ; -3 4]
println(@. sqrt(a * a))