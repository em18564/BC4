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
using PlotlyJS
# using Plots
# using Gadfly
# import Cairo, Fontconfig

wordTypes = ["Adjective","Noun","Verb","Adverb","Function"]
cols = ["#3D9970", "#FF4136", "#FF851B","#4040FF","#7D0DC3"]
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

d = zeros(6,2,5,1000)
vd = []
for j in range(1,5)
    for i in range(1,2)
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
                AB       = repeat(vcat(fill("Intercept",6000),fill("Gradient",6000)),5),
                WordType = vcat(fill("Adjective",12000),fill("Noun",12000),fill("Verb",12000),fill("Adverb",12000),fill("Function",12000)))
df.PCWT = string.(df.WordType, " ",  df.PCA)
dfI = subset(df, :AB => ByRow((==("Intercept"))))
# df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
#               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
#               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
df1 = subset(dfI, :PCA => ByRow((==("PC1"))))
df2 = subset(dfI, :PCA => ByRow((==("PC2"))))
df3 = subset(dfI, :PCA => ByRow((==("PC3"))))
df4 = subset(dfI, :PCA => ByRow((==("PC4"))))
df5 = subset(dfI, :PCA => ByRow((==("PC5"))))
df6 = subset(dfI, :PCA => ByRow((==("PC6"))))

dfG = subset(df, :AB => ByRow((==("Gradient"))))
# df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
#               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
#               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
dfg1 = subset(dfG, :PCA => ByRow((==("PC1"))))
dfg2 = subset(dfG, :PCA => ByRow((==("PC2"))))
dfg3 = subset(dfG, :PCA => ByRow((==("PC3"))))
dfg4 = subset(dfG, :PCA => ByRow((==("PC4"))))
dfg5 = subset(dfG, :PCA => ByRow((==("PC5"))))
dfg6 = subset(dfG, :PCA => ByRow((==("PC6"))))







function violin_grouped(data)
    days = data[:,:PCA]
    y_adj = subset(data, :WordType => ByRow((==("Adjective"))))[:,:data]
    y_nou = subset(data, :WordType => ByRow((==("Noun"))))[:,:data]
    y_ver = subset(data, :WordType => ByRow((==("Verb"))))[:,:data]
    y_adv = subset(data, :WordType => ByRow((==("Adverb"))))[:,:data]
    y_fun = subset(data, :WordType => ByRow((==("Function"))))[:,:data]

    colors = cols
    names = wordTypes
    ys = (y_adj, y_nou, y_ver,y_adv,y_fun)
    if data[1,:PCA] == "PC1"
        layout = Layout(
        yaxis=attr(title="Intercept Posterior"),
        violinmode="group"
    )
    else
        layout = Layout(
        violinmode="group"
    )
    end
    
    data = [
        violin(
            y=y, name=name, x=days, jitter=0, points="all",
            marker=attr(symbol="line-ew", color=color, meanline_visible=true)
        ) for (y, name, color) in zip(ys, names, colors)
    ]
    
    plot(data, layout)
end

function getBox(i,mdifs,ldifs,hdifs)
    return box(
        name       =wordTypes[i],
        median     = [mdifs[i,1],mdifs[i,2],mdifs[i,3],mdifs[i,4],mdifs[i,5]],
        q1         = [ldifs[i,1],ldifs[i,2],ldifs[i,3],ldifs[i,4],ldifs[i,5]],
        q3         = [hdifs[i,1],hdifs[i,2],hdifs[i,3],hdifs[i,4],hdifs[i,5]],
        mean       = [mdifs[i,1],mdifs[i,2],mdifs[i,3],mdifs[i,4],mdifs[i,5]],
        lowerfence = [ldifs[i,1],ldifs[i,2],ldifs[i,3],ldifs[i,4],ldifs[i,5]],
        upperfence = [hdifs[i,1],hdifs[i,2],hdifs[i,3],hdifs[i,4],hdifs[i,5]],
        marker_color=cols[i],
        x = wordTypes
    )
end


function HDIs(data)
    mdifs = zeros(length(wordTypes),length(wordTypes))
    ldifs = zeros(length(wordTypes),length(wordTypes))
    udifs = zeros(length(wordTypes),length(wordTypes))
    if data[1,:PCA] == "PC1"
        layout = Layout(yaxis=attr(title="97% HDI Difference",range=[-0.3,0.3]),
                        boxmode="group")
    else
        layout = Layout(yaxis=attr(range=[-0.3,0.3]),
                        boxmode="group")
    end

    
    for (i,w1) in pairs(wordTypes)
        for (j,w2) in pairs(wordTypes)
            dfw1 = subset(data, :WordType => ByRow((==(w1))))[:,:data]
            dfw2 = subset(data, :WordType => ByRow((==(w2))))[:,:data]
            mdifs[i,j],ldifs[i,j],udifs[i,j] = HDI(dfw1-dfw2)
        end
    end
    traces = [getBox(1,mdifs,ldifs,udifs),getBox(2,mdifs,ldifs,udifs),getBox(3,mdifs,ldifs,udifs),getBox(4,mdifs,ldifs,udifs),getBox(5,mdifs,ldifs,udifs)]
    plot(traces, layout)
end



function subplots(data)
    p1 = violin_grouped(data)
    p2 = HDIs(data)
    p = [p2 
    p1]
    p.plot.layout.boxmode="group"
    p.plot.layout.violinmode="group"
    p.plot.layout["showlegend"] = false
    p.plot.layout["height"] = 850
    p.plot.layout["violingap"] = 0
    p.plot.layout["violingroupgap"] = 0.3
    p.plot.layout["boxgroupgap"] = 0.25
    p.plot.layout["boxgap"] = 0.4
    if data[1,:PCA] == "PC1"
        p.plot.layout["margin"] =attr(l=55, r=5, b=15, t=15)
        p.plot.layout["width"] = 415

    else
        p.plot.layout["margin"] =attr(l=5, r=5, b=15, t=15)
        p.plot.layout["width"] = 365

    end

    
    p.plot.layout["xaxis2"] = attr(range=(-0.5, 0.5), constrain="domain")
    p.plot.layout["yaxis2"] = attr(range=(-0.35, 0.35), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")
    p.plot.layout["yaxis1"] = attr(range=(-0.25, 0.25), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")

    p.plot.layout["font"]   = attr(size=22)


    p
end
dfs = [df1,df2,df3,df4,df5,df6]
dfsg = [dfg1,dfg2,dfg3,dfg4,dfg5,dfg6]


function fullSubPlots()
    pa1 = violin_grouped(df1)
    pa2 = violin_grouped(df2)
    pa3 = violin_grouped(df3)
    pa4 = violin_grouped(df4)
    pa5 = violin_grouped(df5)
    pa6 = violin_grouped(df6)
    pb1 = HDIs(df1)
    pb2 = HDIs(df2)
    pb3 = HDIs(df3)
    pb4 = HDIs(df4)
    pb5 = HDIs(df5)
    pb6 = HDIs(df6)
    
    p = [pb1 pb2 pb3 pb4 pb5 pb6
    pa1 pa2 pa3 pa4 pa5 pa6]
    p.plot.layout.boxmode="group"
    p.plot.layout.violinmode="group"
    p.plot.layout["showlegend"] = true
    p.plot.layout["height"] = 1000
    p.plot.layout["violingap"] = 0
    p.plot.layout["violingroupgap"] = 0.3
    p.plot.layout["boxgap"] = 0.2
    p.plot.layout["boxgroupgap"] = 0
    p.plot.layout["zeroline"] = true
    
    p.plot.layout["margin"] =attr(l=55, r=5, b=5, t=5)
    p.plot.layout["width"] = 10000

    p.plot.layout["font"]   = attr(size=22)
    p.plot.layout["xaxis1"] = attr(range=(-0.5,  0), constrain="domain")
    p.plot.layout["yaxis3"] = attr(range=(-0.4, 0.4), constrain="domain")
    p.plot.layout["yaxis2"] = attr(range=(-0.4, 0.4), constrain="domain")
    p.plot.layout["yaxis1"] = attr(range=(-0.4, 0.4), constrain="domain")



    p

end
savefig(subplots(df1),"output/i1.png",width=415,height=850)
for i in 2:6
    savefig(subplots(dfs[i]),"output/i"*string(i)*".png",width=365,height=850)
end

savefig(subplots(dfg1),"output/g1.png",width=415,height=850)
for i in 2:6
    savefig(subplots(dfsg[i]),"output/g"*string(i)*".png",width=365,height=850)
end
# vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference with full Covariance"),Guide.xlabel("Posterior"),
#                     layer(df1, x=:WordType,y=:data,color=:WordType,Geom.violin));

# draw(PNG("violinCov.png", 8inch, 8inch, dpi=300), vio)
