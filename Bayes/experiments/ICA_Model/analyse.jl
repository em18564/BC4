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
using PlotlyJS
using Plots
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end


function performPlots(val)
    chn = deserialize("output/out" *string(val)*".jls")
    ess_rhat_df = DataFrame(ess_rhat(chn))
    xs = ess_rhat_df[!,"rhat"]
    ys = ess_rhat_df[!,"ess"]
    p1 = Plots.scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
    chn_df = DataFrame(chn)
    dif1 = chn_df[!,"a_w_s[2]"]-chn_df[!,"a_w_s[1]"]
    dif2 = chn_df[!,"b_w_s[2]"]-chn_df[!,"b_w_s[1]"]
    m1,l1,u1 = HDI(dif1)
    m2,l2,u2 = HDI(dif2)
    p2 = PlotlyJS.plot(box(
        name="Δa_w & Δb_w for PC1",
        q1=[l1, l2],
        median=[m1, m2],
        q3=[u1, u2],
        mean=[m1, m2],
        lowerfence=[l1, l2],
        upperfence=[u1, u2]
    ))
    return p1,p2
end
p1,p2 = performPlots(1)
p3,p4 = performPlots(2)
p5,p6 = performPlots(3)
p7,p8 = performPlots(4)
p9,p10 = performPlots(5)
p11,p12 = performPlots(6)
# #df = CSV.read("savedData/df_2.csv", DataFrame)
# chn = deserialize("output/out1.jls")
# chn_ss = DataFrame(summarystats(chn))
# chn_df = DataFrame(chn)
# # density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
# # density!(chn_df[!,"ab_w[2,2]"],label = "Function")
# # savefig("output/dens.png")
# CSV.write("output/ss1.csv", chn_ss)
# density(chn_df[!,"ab_w[2,2]"]-chn_df[!,"ab_w[2,1]"],label = "Difference",xaxis="Posterior Effect")
# savefig("output2/dif1.png")

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
