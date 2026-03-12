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



                    
# df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
#               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
#               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
# vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference with full Covariance"),Guide.xlabel("Posterior"),
#                     layer(df, x=:group,y=:data,color=:ERP,Geom.violin),
#                     layer(df, x=:group,y=:data,Geom.boxplot(suppress_outliers=true,method=[0.015,0.015,0.50,0.985,0.985])),Coord.cartesian(ymin=-1, ymax=1));

# draw(PNG("violinCov2.png", 8inch, 8inch, dpi=300), vio)
