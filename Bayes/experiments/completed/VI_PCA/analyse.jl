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
using MCMCChains
using Serialization
using Plots
using PlotlyJS
using ParetoSmooth
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end
q = deserialize("out3.jls")
chn = deserialize("outOld.jls")
chn_df = DataFrame(chn)

z = rand(q, 10_000);

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

    σ ~ truncated(Cauchy(0,20),0,1000)

    for i in eachindex(ePNP)
      ePNP[i] ~ Normal(μ[i],σ)
      end
end

# Instantiate model
df = CSV.read("../../input/dfHierarchicalNorm.csv", DataFrame)
df_modified_1 = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
m=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.Tags,df_modified.PNP)
_, sym2range = bijector(m, Val(true));

#density(z[getindex(sym2range, :σ)[1][1],:])

#density(z[getindex(sym2range, :a_w_s)[1][2],:])
#density!(z[getindex(sym2range, :a_w_s)[1][1],:])
s = zeros(nrow(df))
vals = zeros((nrow(df),2))
for i in 1:nrow(df)
    a_p = mean(z[getindex(sym2range, :a_p_s)[1][df[i,:Participant]+1],:])
    b_p = mean(z[getindex(sym2range, :b_p_s)[1][df[i,:Participant]+1],:])
    a_w = mean(z[getindex(sym2range, :a_w_s)[1][df[i,:Tags]+1],:])
    b_w = mean(z[getindex(sym2range, :b_w_s)[1][df[i,:Tags]+1],:])
    a_e = mean(z[getindex(sym2range, :a_e)[1][1]])
    b_e = mean(z[getindex(sym2range, :b_e)[1][1]])
    surprisal = df[i,:Surprisal]
    PNP = df[i,:PNP]
    σ   = mean(z[getindex(sym2range, :σ)[1][1]])
    μ   = a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
    dist = Normal(μ,σ)
    global vals[i,1] = rand(dist)
    global vals[i,2] = df[i,:PNP]
    global s[i]=pdf(dist,df[i,:PNP])
end

s2    = zeros(nrow(df))
vals2 = zeros((nrow(df),2))
for i in 1:nrow(df)
    a_p = mean(chn_df[!,"a_p_s"*string([df[1,:Participant]+1])*""])
    b_p = mean(chn_df[!,"b_p_s"*string([df[1,:Participant]+1])*""])
    a_w = mean(chn_df[!,"a_w_s"*string([df[1,:Tags]+1])*""])
    b_w = mean(chn_df[!,"b_w_s"*string([df[1,:Tags]+1])*""])
    a_e = mean(chn_df[!,"a_e"])
    b_e = mean(chn_df[!,"b_e"])
    surprisal = df[i,:Surprisal]
    PNP = df[i,:PNP]
    σ   = mean(chn_df[!,"σ"])
    μ   = a_w + a_p + a_e + ((b_w + b_p + b_e) * surprisal)
    dist = Normal(μ,σ)
    global s2[i]=pdf(dist,df[i,:PNP])
    global vals2[i,1] = rand(dist)
    global vals2[i,2] = df[i,:PNP]
end


    
# av2 = s/nrow(df)


# # savefig("output/dens.png")
#CSV.write("output/ss.csv", chn_ss)


dif1 = z[getindex(sym2range, :a_w_s)[1][2],:]-z[getindex(sym2range, :a_w_s)[1][1],:]
dif2 = z[getindex(sym2range, :b_w_s)[1][2],:]-z[getindex(sym2range, :b_w_s)[1][1],:]
m1,l1,u1 = HDI(dif1)
m2,l2,u2 = HDI(dif2)
p = PlotlyJS.plot(box(
    name="Δa_w & Δb_w for EPNP with no covariance",
    q1=[l1, l2],
    median=[m1, m2],
    q3=[u1, u2],
    mean=[m1, m2],
    lowerfence=[l1, l2],
    upperfence=[u1, u2]
))
PlotlyJS.savefig(p,"dif2.png")
# density(chn_df[!,"ab_w[2,2]"]-chn_df[!,"ab_w[2,1]"],label = "Difference",xaxis="Posterior Effect")
# savefig("output/dif.png")

# #density(chn_df[!,"b_e"],label="n400",xaxis="Posterior Effect")

# ELAN  = (chn_df[!,"ab_e[2,1]"])
# LAN = (chn_df[!,"ab_e[2,2]"])
# N400 = (chn_df[!,"ab_e[2,3]"])
# EPNP = (chn_df[!,"ab_e[2,4]"])
# P600  = (chn_df[!,"ab_e[2,5]"])
# PNP = (chn_df[!,"ab_e[2,6]"])
# y = [ELAN,LAN,N400,EPNP,P600,PNP]
# violin(["ELAN" "LAN" "N400" "EPNP" "P600" "PNP" ], y, legend=false,xaxis="Posterior Effect")
# savefig("output/violin.png")

# ess_rhat_df = DataFrame(ess_rhat(chn))
# xs = ess_rhat_df[!,"rhat"]
# ys = ess_rhat_df[!,"ess"]
# scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
# savefig("output/essRhat.png")

#plot(truncated(Cauchy(-20),0,1000),lw=3,xlims=(-1, 100),legend=false,title="Half-Cauchy")

# density(chn_df[!,"σ"],label="n400")
#savefig("graphs/n400.png")
# histogram(ess_rhat_df[!,"rhat"],label="rhat")
# savefig("graphs/rhat.png")

# histogram(ess_rhat_df[!,"ess"],label="ess")
# savefig("graphs/ess.png")


# plot(chn, colordim = :parameter; size=(1680, 800))
# savefig("graphs/trace.png")

# autocorplot(chn,size=(1680,800))
# savefig("graphs/autocor.png")
