using Turing
using DataFrames
using CSV
using Random
using Distributions
using StatisticalRethinking
using StatisticalRethinking: link
using StatisticalRethinkingPlots
using StatsPlots
using StatsBase
using Logging
using LinearAlgebra
using PDMats
default(label=false);
Logging.disable_logging(Logging.Warn);

a = 3.5    # average morning wait time
b = -1     # average difference afternoon wait time
σ_a = 1    # std dev in intercepts
σ_b = 0.5  # std dev in slopes
ρ = -0.7;  # correlation between intercepts and slopes
μ = [a, b];
cov_ab = σ_a * σ_b * ρ
Σ = [[σ_a^2, cov_ab] [cov_ab, σ_b^2]]
reshape(1:4, (2,2))
sigmas = [σ_a, σ_b]
Ρ = [[1, ρ] [ρ, 1]]
Σ = Diagonal(sigmas) * Ρ * Diagonal(sigmas);
N_cafes = 20;
Random.seed!(5)
vary_effect = rand(MvNormal(μ, Σ), N_cafes);
a_cafe = vary_effect[1,:]
b_cafe = vary_effect[2,:];
Random.seed!(1)
N_visits = 10

afternoon = repeat(0:1, N_visits*N_cafes ÷ 2)
cafe_id = repeat(1:N_cafes, inner=N_visits)
μ = a_cafe[cafe_id] + b_cafe[cafe_id] .* afternoon
σ = 0.5
wait = rand.(Normal.(μ, σ))
d = DataFrame(cafe=cafe_id, afternoon=afternoon, wait=wait);

@model function m1(cafe, afternoon, wait)
    a ~ Normal(5, 2)
    b ~ Normal(-1, 0.5)
    σ_cafe ~ filldist(Exponential(), 2)
    Rho ~ LKJ(2, 2)
    # build sigma matrix manually, to avoid numerical errors
#     (σ₁, σ₂) = σ_cafe
#     sc = [[σ₁^2, σ₁*σ₂] [σ₁*σ₂, σ₂^2]]
#     Σ = Rho .* sc
    # the same as above, but shorter and generic
    Σ = (σ_cafe .* σ_cafe') .* Rho
    ab ~ filldist(MvNormal([a,b], Σ), N_cafes)
    a = ab[1,cafe]
    b = ab[2,cafe]
    μ = @. a + b * afternoon
    σ ~ Exponential()
    for i ∈ eachindex(wait)
        wait[i] ~ Normal(μ[i], σ)
    end
end

@model function m2(cafe, afternoon, wait)
    a ~ Normal(5, 2)
    b ~ Normal(-1, 0.5)
    μ = @. a + b * afternoon
    σ ~ Exponential()
    for i ∈ eachindex(wait)
        wait[i] ~ Normal(μ[i], σ)
    end
end

@model function m3(cafe, afternoon, wait)
    σ_cafe ~ filldist(Exponential(), 2)
    Rho ~ LKJ(2, 2)
    # build sigma matrix manually, to avoid numerical errors
#     (σ₁, σ₂) = σ_cafe
#     sc = [[σ₁^2, σ₁*σ₂] [σ₁*σ₂, σ₂^2]]
#     Σ = Rho .* sc
    # the same as above, but shorter and generic
    Σ = (σ_cafe .* σ_cafe') .* Rho
    ab ~ filldist(MvNormal([5,-1], Σ), N_cafes)
    a = ab[1,cafe]
    b = ab[2,cafe]
    μ = @. a + b * afternoon
    σ ~ Exponential()
    for i ∈ eachindex(wait)
        wait[i] ~ Normal(μ[i], σ)
    end
end


@model function m4(cafe, afternoon, wait)
    a ~ Normal(5, 2)
    b ~ Normal(-1, 0.5)
    sigma ~ filldist(Exponential(), 2)
    F ~ LKJCholesky(2, 2.0)
    Σ_L = Diagonal(sigma) * F.L
    Sigma = PDMat(Cholesky(Σ_L + eps() * I))
    ab ~ filldist(MvNormal([a,b], Sigma), N_cafes)

    μ = @. a + b * afternoon
    σ ~ Exponential()
    for i ∈ eachindex(wait)
        wait[i] ~ Normal(μ[i], σ)
    end
end



Random.seed!(1)
m1_c = sample(m1(d.cafe, d.afternoon, d.wait), NUTS(), 1000)
m2_c = sample(m2(d.cafe, d.afternoon, d.wait), NUTS(), 1000)
m3_c = sample(m3(d.cafe, d.afternoon, d.wait), NUTS(), 1000)
m4_c = sample(m4(d.cafe, d.afternoon, d.wait), NUTS(), 1000)
