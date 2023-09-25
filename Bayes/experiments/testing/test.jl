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
using LinearAlgebra
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




# @model function testMod()
#     Σ_σ = [ 21.8175     4.64296    1.51328   0.207691  -1.55949   -2.02525
#     4.64296   30.0462    12.4095    7.12357    0.718256   1.56873
#     1.51328   12.4095    15.9679    4.7445     3.63401    2.57624
#     0.207691   7.12357    4.7445   14.6443     4.69082   11.0562
#     -1.55949    0.718256   3.63401   4.69082   13.6554    10.7355
#     -2.02525    1.56873    2.57624  11.0562    10.7355    18.2697]
    

# end
Σ_σ = [ 21.8175     4.64296    1.51328   0.207691  -1.55949   -2.02525
  4.64296   30.0462    12.4095    7.12357    0.718256   1.56873
  1.51328   12.4095    15.9679    4.7445     3.63401    2.57624
  0.207691   7.12357    4.7445   14.6443     4.69082   11.0562
 -1.55949    0.718256   3.63401   4.69082   13.6554    10.7355
 -2.02525    1.56873    2.57624  11.0562    10.7355    18.2697]
# a = [1 2 ; -3 4]
# println(@. sqrt(a * a))
s=sqrt(Σ_σ)
e=LinearAlgebra.eigvals(Σ_σ)
e2=LinearAlgebra.eigvals(s)