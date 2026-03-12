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
chn1 = deserialize("output/out1.jls")
chn2 = deserialize("output/out2.jls")
chn3 = deserialize("output/out3.jls")
chn4 = deserialize("output/out4.jls")
chn5 = deserialize("output/out5.jls")
chn6 = deserialize("output/out6.jls")
# #df = CSV.read("savedData/df_2.csv", DataFrame)
# chn = deserialize("output/out1.jls")
# chn_ss = DataFrame(summarystats(chn))
# chn_df = DataFrame(chn)
# # density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
# # density!(chn_df[!,"ab_w[2,2]"],label = "Function")
# # savefig("output/dens.png")
# CSV.write("output/ss1.csv", chn_ss)
chn_df1 = DataFrame(chn1)
dif11 = chn_df1[!,"ab_w[1,1]"]-chn_df1[!,"ab_w[1,2]"]
dif12 = chn_df1[!,"ab_w[2,1]"]-chn_df1[!,"ab_w[2,2]"]
m11,l11,u11 = HDI(dif11)
m12,l12,u12 = HDI(dif12)

chn_df2 = DataFrame(chn2)
dif21 = chn_df2[!,"ab_w[1,1]"]-chn_df2[!,"ab_w[1,2]"]
dif22 = chn_df2[!,"ab_w[2,1]"]-chn_df2[!,"ab_w[2,2]"]
m21,l21,u21 = HDI(dif21)
m22,l22,u22 = HDI(dif22)

chn_df3 = DataFrame(chn3)
dif31 = chn_df3[!,"ab_w[1,1]"]-chn_df3[!,"ab_w[1,2]"]
dif32 = chn_df3[!,"ab_w[2,1]"]-chn_df3[!,"ab_w[2,2]"]
m31,l31,u31 = HDI(dif31)
m32,l32,u32 = HDI(dif32)

chn_df4 = DataFrame(chn4)
dif41 = chn_df4[!,"ab_w[1,1]"]-chn_df4[!,"ab_w[1,2]"]
dif42 = chn_df4[!,"ab_w[2,1]"]-chn_df4[!,"ab_w[2,2]"]
m41,l41,u41 = HDI(dif41)
m42,l42,u42 = HDI(dif42)

chn_df5 = DataFrame(chn5)
dif51 = chn_df5[!,"ab_w[1,1]"]-chn_df5[!,"ab_w[1,2]"]
dif52 = chn_df5[!,"ab_w[2,1]"]-chn_df5[!,"ab_w[2,2]"]
m51,l51,u51 = HDI(dif51)
m52,l52,u52 = HDI(dif52)

chn_df6 = DataFrame(chn6)
dif61 = chn_df6[!,"ab_w[1,1]"]-chn_df6[!,"ab_w[1,2]"]
dif62 = chn_df6[!,"ab_w[2,1]"]-chn_df6[!,"ab_w[2,2]"]
m61,l61,u61 = HDI(dif61)
m62,l62,u62 = HDI(dif62)

p = PlotlyJS.plot(box(
    name="Δa_w & Δb_w of 6 PCs for Content/Function",
    median=[m11, m12,m21, m22,m31, m32,m41, m42,m51, m52,m61, m62],
    q1=[l11, l12,l21, l22,l31, l32,l41, l42,l51, l52,l61, l62],
    q3=[u11, u12,u21, u22,u31, u32,u41, u42,u51, u52,u61, u62],
    mean=[m11, m12,m21, m22,m31, m32,m41, m42,m51, m52,m61, m62],
    lowerfence=[l11, l12,l21, l22,l31, l32,l41, l42,l51, l52,l61, l62],
    upperfence=[u11, u12,u21, u22,u31, u32,u41, u42,u51, u52,u61, u62],
    x = ["a1","b1","a2","b2","a3","b3","a4","b4","a5","b5","a6","b6"]
))
PlotlyJS.savefig(p,"output/diffull.png")
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
