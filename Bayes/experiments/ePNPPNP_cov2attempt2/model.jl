import Pkg

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
using TransformVariables
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP



@model function model(participant,word,surprisal,tags,eEGs)
    σ_w_e ~ filldist(Exponential(), 2)
    ρ_w_e ~ LKJ(2, 2)
    Σ_w_e = (σ_w_e .* σ_w_e') .* ρ_w_e
    ab_w_e ~ filldist(MvNormal([0,0], Σ_w_e),NUM_TYPES)
    a_w_e = ab_w_e[1,tags.+1]
    b_w_e = ab_w_e[2,tags.+1]
    
    σ_p_e ~ filldist(Exponential(), 2)
    ρ_p_e ~ LKJ(2, 2)
    Σ_p_e = (σ_p_e .* σ_p_e') .* ρ_p_e
    ab_p_e ~ filldist(MvNormal([0,0], Σ_p_e),NUM_PARTICIPANTS)
    a_p_e = ab_p_e[1,participant.+1]
    b_p_e = ab_p_e[2,participant.+1]

    σ_e_e ~ filldist(Exponential(), 2)
    ρ_e_e ~ LKJ(2, 2)
    Σ_e_e = (σ_e_e .* σ_e_e') .* ρ_e_e
    ab_e_e ~ filldist(MvNormal([0,0], Σ_e_e),1)
    a_e_e = ab_e_e[1,1]
    b_e_e = ab_e_e[2,1]

    σ_w_p ~ filldist(Exponential(), 2)
    ρ_w_p ~ LKJ(2, 2)
    Σ_w_p = (σ_w_p .* σ_w_p') .* ρ_w_p
    ab_w_p ~ filldist(MvNormal([0,0], Σ_w_p),NUM_TYPES)
    a_w_p = ab_w_p[1,tags.+1]
    b_w_p = ab_w_p[2,tags.+1]

    σ_p_p ~ filldist(Exponential(), 2)
    ρ_p_p ~ LKJ(2, 2)
    Σ_p_p = (σ_p_p .* σ_p_p') .* ρ_p_p
    ab_p_p ~ filldist(MvNormal([0,0], Σ_p_p),NUM_PARTICIPANTS)
    a_p_p = ab_p_p[1,participant.+1]
    b_p_p = ab_p_p[2,participant.+1]

    σ_e_p ~ filldist(Exponential(), 2)
    ρ_e_p ~ LKJ(2, 2)
    Σ_e_p = (σ_e_p .* σ_e_p') .* ρ_e_p
    ab_e_p ~ filldist(MvNormal([0,0], Σ_e_p),1)
    a_e_p = ab_e_p[1,1]
    b_e_p = ab_e_p[2,1]

    μ_ePNP = @. a_w_e + a_p_e + a_e_e + ((b_w_e + b_p_e + b_e_e) * surprisal)
    μ_PNP = @. a_w_p + a_p_p + a_e_p + ((b_w_p + b_p_p + b_e_p) * surprisal)

    sigma ~ filldist(truncated(Cauchy(0., 20.); lower = 0), 2)
    n, eta = 2.0, 1.0
    #solution from https://discourse.julialang.org/t/singular-exception-with-lkjcholesky/85020/2
    trans = CorrCholeskyFactor(n)
    R_tilde ~ filldist(Turing.Flat(), dimension(trans))
    R_U, logdetJ = transform_and_logjac(trans, R_tilde)
    F = Cholesky(R_U)
    Turing.@addlogprob! logpdf(LKJCholesky(n, eta), F) + logdetJ
    Σ_L = LowerTriangular(collect((sigma .+ 1e-6) .* R_U'))
    Sigma = PDMat(Cholesky(Σ_L))
    if any(i -> iszero(Σ_L[i]), diagind(Σ_L))
      Turing.@addlogprob! Inf
    else
      for i in eachindex(participant)
        eEGs[i,:] ~ MvNormal([μ_ePNP[i],μ_PNP[i]],Sigma)
        end
    end


    
end

df = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,[df_modified.EPNP df_modified.PNP])
m = sample(mod, NUTS(0.8), MCMCThreads(), 250,4)
display(m)
serialize("output/out.jls",m)

# Highest Density Interval