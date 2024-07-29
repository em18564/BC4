# using Random
using StatsBase
using Distributions
#using StatsPlots
using StatsFuns
using Logging

using Turing
using CSV
using DataFrames

using MCMCDiagnosticTools
using MCMCChains
using Serialization
# using PlotlyJS
# using Plots
using Gadfly
import Cairo, Fontconfig
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end

#df = CSV.read("savedData/df_2.csv", DataFrame)
chn1 = deserialize("output/out1.jls")
chn2 = deserialize("output/out2.jls")
chn3 = deserialize("output/out3.jls")
chn4 = deserialize("output/out4.jls")
chn5 = deserialize("output/out5.jls")
chn6 = deserialize("output/out6.jls")
chn_df1 = DataFrame(chn1)
chn_df2 = DataFrame(chn2)
chn_df3 = DataFrame(chn3)
chn_df4 = DataFrame(chn4)
chn_df5 = DataFrame(chn5)
chn_df6 = DataFrame(chn6)

d = zeros(6,2,4,1000)
vd = []
for i in range(1,2)
    for j in range(1,4)
        d[1,i,j,:] = chn_df1[:,"ab_w["*string(i)*","*string(j)*"]"]
        d[2,i,j,:] = chn_df2[:,"ab_w["*string(i)*","*string(j)*"]"]
        d[3,i,j,:] = chn_df3[:,"ab_w["*string(i)*","*string(j)*"]"]
        d[4,i,j,:] = chn_df4[:,"ab_w["*string(i)*","*string(j)*"]"]
        d[5,i,j,:] = chn_df5[:,"ab_w["*string(i)*","*string(j)*"]"]
        d[6,i,j,:] = chn_df6[:,"ab_w["*string(i)*","*string(j)*"]"]
        global vd = vcat(vd, d[1,i,j,:],d[2,i,j,:],d[3,i,j,:],d[4,i,j,:],d[5,i,j,:],d[6,i,j,:])
    end
end

df = DataFrame( data     = vd,
                PCA      = repeat(vcat(fill("PC1",1000),fill("PC2",1000),fill("PC3",1000),fill("PC4",1000),fill("PC5",1000),fill("PC6",1000)),Int(length(vd)/6000)),
                AB       = repeat(vcat(fill("Intercept",6000),fill("Gradient",6000)),4),
                WordType = vcat(fill("Adjective",12000),fill("Noun",12000),fill("Verb",12000),fill("Adverb",12000)))
df.PCWT = string.(df.WordType, " ",  df.PCA)
df1 = subset(df, :AB => ByRow((==("Intercept"))))
# df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
#               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
#               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference with full Covariance"),Guide.xlabel("Posterior"),
                    layer(df1, x=:PCWT,y=:data,color=:PCA,Geom.violin));

draw(PNG("violinCov.png", 8inch, 8inch, dpi=300), vio)
