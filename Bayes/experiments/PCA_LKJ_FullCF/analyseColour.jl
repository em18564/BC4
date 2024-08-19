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
function plotHDIs(input1,input2,title)
    chn_df1 = DataFrame(chn1)
    dif11 = chn_df1[!,"ab_w[1,"*string(input1)*"]"]-chn_df1[!,"ab_w[1,"*string(input2)*"]"]
    dif12 = chn_df1[!,"ab_w[2,"*string(input1)*"]"]-chn_df1[!,"ab_w[2,"*string(input2)*"]"]
    m11,l11,u11 = HDI(dif11)
    m12,l12,u12 = HDI(dif12)

    chn_df2 = DataFrame(chn2)
    dif21 = chn_df2[!,"ab_w[1,"*string(input1)*"]"]-chn_df2[!,"ab_w[1,"*string(input2)*"]"]
    dif22 = chn_df2[!,"ab_w[2,"*string(input1)*"]"]-chn_df2[!,"ab_w[2,"*string(input2)*"]"]
    m21,l21,u21 = HDI(dif21)
    m22,l22,u22 = HDI(dif22)

    chn_df3 = DataFrame(chn3)
    dif31 = chn_df3[!,"ab_w[1,"*string(input1)*"]"]-chn_df3[!,"ab_w[1,"*string(input2)*"]"]
    dif32 = chn_df3[!,"ab_w[2,"*string(input1)*"]"]-chn_df3[!,"ab_w[2,"*string(input2)*"]"]
    m31,l31,u31 = HDI(dif31)
    m32,l32,u32 = HDI(dif32)

    chn_df4 = DataFrame(chn4)
    dif41 = chn_df4[!,"ab_w[1,"*string(input1)*"]"]-chn_df4[!,"ab_w[1,"*string(input2)*"]"]
    dif42 = chn_df4[!,"ab_w[2,"*string(input1)*"]"]-chn_df4[!,"ab_w[2,"*string(input2)*"]"]
    m41,l41,u41 = HDI(dif41)
    m42,l42,u42 = HDI(dif42)

    chn_df5 = DataFrame(chn5)
    dif51 = chn_df5[!,"ab_w[1,"*string(input1)*"]"]-chn_df5[!,"ab_w[1,"*string(input2)*"]"]
    dif52 = chn_df5[!,"ab_w[2,"*string(input1)*"]"]-chn_df5[!,"ab_w[2,"*string(input2)*"]"]
    m51,l51,u51 = HDI(dif51)
    m52,l52,u52 = HDI(dif52)

    chn_df6 = DataFrame(chn6)
    dif61 = chn_df6[!,"ab_w[1,"*string(input1)*"]"]-chn_df6[!,"ab_w[1,"*string(input2)*"]"]
    dif62 = chn_df6[!,"ab_w[2,"*string(input1)*"]"]-chn_df6[!,"ab_w[2,"*string(input2)*"]"]
    m61,l61,u61 = HDI(dif61)
    m62,l62,u62 = HDI(dif62)

    x1 = ["PC1","PC2","PC3","PC4","PC5","PC6"]

    trace1 = box(
        name       ="Δa_w",
        median     = [m11,m21,m31,m41,m51,m61],
        q1         = [l11,l21,l31,l41,l51,l61],
        q3         = [u11,u21,u31,u41,u51,u61],
        mean       = [m11,m21,m31,m41,m51,m61],
        lowerfence = [l11,l21,l31,l41,l51,l61],
        upperfence = [u11,u21,u31,u41,u51,u61],
        marker_color="#3D9970",
        x = x1
    )

    trace2 = box(
        name       ="Δb_w",
        median     = [m12,m22,m32,m42,m52,m62],
        q1         = [l12,l22,l32,l42,l52,l62],
        q3         = [u12,u22,u32,u42,u52,u62],
        mean       = [m12,m22,m32,m42,m52,m62],
        lowerfence = [l12,l22,l32,l42,l52,l62],
        upperfence = [u12,u22,u32,u42,u52,u62],
        marker_color="#FF4136",
        x = x1
    )
    data1 = [trace1, trace2]

    layout = Layout(;title=attr(text="97% HDI for "*title,font=attr(size=25),x=0.5),yaxis=attr(title="Posterior Effect",range=[-0.3,0.3]),
                        boxmode="group")
    p1 = PlotlyJS.plot(data1, layout)
    #PlotlyJS.savefig(p1,"output/diffullCol1.png",width=4*150, height=3*150, scale=10)

    x2 = ["Δa_w","Δb_w"]

    trace1 = box(
        name       ="PC1",
        median     = [m11,m12],
        q1         = [l11,l12],
        q3         = [u11,u12],
        mean       = [m11,m12],
        lowerfence = [l11,l12],
        upperfence = [u11,u12],
        marker_color="#3D9970",
        x = x2
    )

    trace2 = box(
        name       ="PC2",
        median     = [m21,m22],
        q1         = [l21,l22],
        q3         = [u21,u22],
        mean       = [m21,m22],
        lowerfence = [l21,l22],
        upperfence = [u21,u22],
        marker_color="#FF4136",
        x = x2
    )

    trace3 = box(
        name       ="PC3",
        median     = [m31,m32],
        q1         = [l31,l32],
        q3         = [u31,u32],
        mean       = [m31,m32],
        lowerfence = [l31,l32],
        upperfence = [u31,u32],
        marker_color="#FF851B",
        x = x2
    )

    trace4 = box(
        name       ="PC4",
        median     = [m41,m42],
        q1         = [l41,l42],
        q3         = [u41,u42],
        mean       = [m41,m42],
        lowerfence = [l41,l42],
        upperfence = [u41,u42],
        marker_color="#rgb(214, 12, 140)",
        x = x2
    )

    trace5 = box(
        name       ="PC5",
        median     = [m51,m52],
        q1         = [l51,l52],
        q3         = [u51,u52],
        mean       = [m51,m52],
        lowerfence = [l51,l52],
        upperfence = [u51,u52],
        marker_color="rgba(93, 164, 214, 0.5)",
        x = x2
    )

    trace6 = box(
        name       ="PC6",
        median     = [m61,m62],
        q1         = [l61,l62],
        q3         = [u61,u62],
        mean       = [m61,m62],
        lowerfence = [l61,l62],
        upperfence = [u61,u62],
        marker_color="rgba(79, 90, 117, 0.5)",
        x = x2
    )

    data2 = [trace1, trace2,trace3,trace4,trace5,trace6]



    return data1,data2,layout
    #PlotlyJS.savefig(p2,"output/diffullCol2.png",width=4*150, height=3*150, scale=10)
end

function savePlots(input1,input2,title)
    d1a,d2a,layout = plotHDIs(input1,input2,title)
    p1a     = PlotlyJS.plot(d1a, layout)
    p2a     = PlotlyJS.plot(d2a, layout)
    PlotlyJS.savefig(p1a,"output/diffullCol"* title *"1.png",width=4*150, height=3*150, scale=10)
    PlotlyJS.savefig(p2a,"output/diffullCol"* title *"2.png",width=4*150, height=3*150, scale=10)
end
savePlots(1,2,"adjective-noun")
savePlots(1,3,"adjective-verb")
savePlots(2,3,"noun-verb")
savePlots(1,4,"adjective-adverb")
savePlots(2,4,"noun-adverb")
savePlots(3,4,"verb-adverb")
savePlots(1,5,"adjective-function")
savePlots(2,5,"noun-function")
savePlots(3,5,"verb-function")
savePlots(4,5,"adverb-function")



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
