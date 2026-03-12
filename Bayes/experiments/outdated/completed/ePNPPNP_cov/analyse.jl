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
using PlotlyJS
using Plots
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end
chn = deserialize("output/out.jls")
ess_rhat_df = DataFrame(ess_rhat(chn))
xs = ess_rhat_df[!,"rhat"]
ys = ess_rhat_df[!,"ess"]
scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
savefig("output/essRhat.png")
#df = CSV.read("savedData/df_2.csv", DataFrame)
chn = deserialize("output/out.jls")
chn_ss = DataFrame(summarystats(chn))
chn_df = DataFrame(chn)
# density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
# density!(chn_df[!,"ab_w[2,2]"],label = "Function")
# savefig("output/dens.png")
CSV.write("output/ss.csv", chn_ss)
dif1 = chn_df[!,"ab_w_e[1,2]"]-chn_df[!,"ab_w_e[1,1]"]
dif2 = chn_df[!,"ab_w_e[2,2]"]-chn_df[!,"ab_w_e[2,1]"]
dif3 = chn_df[!,"ab_w_p[1,2]"]-chn_df[!,"ab_w_p[1,1]"]
dif4 = chn_df[!,"ab_w_p[2,2]"]-chn_df[!,"ab_w_p[2,1]"]
m1,l1,u1 = HDI(dif1)
m2,l2,u2 = HDI(dif2)
m3,l3,u3 = HDI(dif3)
m4,l4,u4 = HDI(dif4)
p = PlotlyJS.plot(box(
    name="Δa_w & Δb_w for EPNP (0,1) & PNP (2,3) with covariance",
    q1=[l1, l2,l3,l4],
    median=[m1, m2,m3,m4],
    q3=[u1, u2,u3,u4],
    mean=[m1, m2,m3,m4],
    lowerfence=[l1, l2,l3,l4],
    upperfence=[u1, u2,u3,u4]
))
PlotlyJS.savefig(p,"output/dif.png")
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
