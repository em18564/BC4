using Random
using Turing
using Turing: Variational

using Turing
using CSV
using DataFrames

using Serialization


NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
@model function model(participant,word,surprisal,tags,ePNP)
    a_w_s ~ filldist(Normal(0,1),NUM_TYPES)
    b_w_s ~ filldist(Normal(0,0.5),NUM_TYPES)
    a_w   = a_w_s[tags.+1]
    b_w   = b_w_s[tags.+1]

    a_p_s ~ filldist(Normal(0,1),NUM_PARTICIPANTS)
    b_p_s ~ filldist(Normal(0,0.5),NUM_PARTICIPANTS)
    a_p   = a_p_s[participant.+1]
    b_p   = b_p_s[participant.+1]

    a_e ~ Normal(0,1)
    b_e ~ Normal(0,0.5)

    μ = @. a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)

    σ ~ truncated(Cauchy(0., 10.); lower = 0)

    for i in eachindex(ePNP)
      ePNP[i] ~ Normal(μ[i],σ)
      end
end

# Instantiate model
df = CSV.read("../../input/dfHierarchicalNorm.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
m=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.PNP)
advi = ADVI(10, 1000)
q = vi(m, advi);
serialize("out2.jls",q)

