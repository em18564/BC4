rangeVals = 1.0



function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end



function concludeAndPlot(m,output_loc,pc,wordTypes,cols)


    if(pc == 1)
    #wait for all other PCs to finish before greating plots
    global is_waiting = true
    while(is_waiting)
        if(isfile(output_loc*"/out1.jls") && isfile(output_loc*"/out2.jls") && isfile(output_loc*"/out3.jls") && isfile(output_loc*"/out4.jls"))
        print("plotting graphs")
        plotGraphs(output_loc,wordTypes,cols) 
        global is_waiting=false
        else
        print("Waiting for other PCs to complete")
        sleep(30)
        end
        
    end
    end


end





function violin_grouped(data,wordTypes,cols)
    days = data[:,:PCA]
    ys = []
    for type in wordTypes
        append!(ys,[subset(data, :WordType => ByRow((==(type))))[:,:data]])
    end
    days = data[:,:PCA]
    # y_adj = subset(data, :WordType => ByRow((==("Adjective"))))[:,:data]
    # y_nou = subset(data, :WordType => ByRow((==("Noun"))))[:,:data]
    # y_ver = subset(data, :WordType => ByRow((==("Verb"))))[:,:data]
    # y_adv = subset(data, :WordType => ByRow((==("Adverb"))))[:,:data]
    # y_fun = subset(data, :WordType => ByRow((==("Function"))))[:,:data]

    colors = cols
    names = wordTypes
    #ys = (y_adj, y_nou, y_ver,y_adv,y_fun)
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
        PlotlyJS.violin(
            y=y, name=name, x=days, jitter=0, points="all",
            marker=attr(symbol="line-ew", color=color, meanline_visible=true)
        ) for (y, name, color) in zip(ys, names, colors)
    ]
    
    PlotlyJS.plot(data, layout)
end

function getBox(i,mdifs,ldifs,hdifs,wordTypes,cols)
    return box(
        name       =wordTypes[i],
        median     = [mdifs[i,j] for j in range(1,length(wordTypes))],
        q1         = [ldifs[i,j] for j in range(1,length(wordTypes))],
        q3         = [hdifs[i,j] for j in range(1,length(wordTypes))],
        mean       = [mdifs[i,j] for j in range(1,length(wordTypes))],
        lowerfence = [ldifs[i,j] for j in range(1,length(wordTypes))],
        upperfence = [hdifs[i,j] for j in range(1,length(wordTypes))],
        marker_color=cols[i],
        x = wordTypes
    )
end


function HDIs(data,wordTypes,cols)
    mdifs = zeros(length(wordTypes),length(wordTypes))
    ldifs = zeros(length(wordTypes),length(wordTypes))
    udifs = zeros(length(wordTypes),length(wordTypes))
    if data[1,:PCA] == "PC1"
        layout = Layout(yaxis=attr(title="97% HDI Difference",range=[-rangeVals,rangeVals]),
                        boxmode="group")
    else
        layout = Layout(yaxis=attr(range=[-rangeVals,rangeVals]),
                        boxmode="group")
    end

    
    for (i,w1) in pairs(wordTypes)
        for (j,w2) in pairs(wordTypes)
            dfw1 = subset(data, :WordType => ByRow((==(w1))))[:,:data]
            dfw2 = subset(data, :WordType => ByRow((==(w2))))[:,:data]
            mdifs[i,j],ldifs[i,j],udifs[i,j] = HDI(dfw1-dfw2)
        end
    end
    #traces = [getBox(1,mdifs,ldifs,udifs),getBox(2,mdifs,ldifs,udifs)]
    traces = [getBox(i,mdifs,ldifs,udifs,wordTypes,cols) for i in range(1,length(wordTypes))]
    PlotlyJS.plot(traces, layout)
end



function subplots(data,wordTypes,cols)
    p1 = violin_grouped(data,wordTypes,cols)
    p2 = HDIs(data,wordTypes,cols)
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
    p.plot.layout["yaxis2"] = attr(range=(-rangeVals, rangeVals), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")
    p.plot.layout["yaxis1"] = attr(range=(-rangeVals, rangeVals), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")

    p.plot.layout["font"]   = attr(size=22)


    p
end



function fullSubPlots(wordTypes,cols)
    pa1 = violin_grouped(df1,wordTypes,cols)
    pa2 = violin_grouped(df2,wordTypes,cols)
    pa3 = violin_grouped(df3,wordTypes,cols)
    pa4 = violin_grouped(df4,wordTypes,cols)
    pa5 = violin_grouped(df5,wordTypes,cols)
    pa6 = violin_grouped(df6,wordTypes,cols)
    pb1 = HDIs(df1,wordTypes,cols)
    pb2 = HDIs(df2,wordTypes,cols)
    pb3 = HDIs(df3,wordTypes,cols)
    pb4 = HDIs(df4,wordTypes,cols)
    pb5 = HDIs(df5,wordTypes,cols)
    pb6 = HDIs(df6,wordTypes,cols)
    
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





function plotGraphs(outputDir,wordTypes,cols)
    chainLength = 1000
    noPCS = 4
        
    #df = CSV.read("savedData/df_2.csv", DataFrame)
    chn1 = deserialize(outputDir*"/out1.jls")
    chn2 = deserialize(outputDir*"/out2.jls")
    chn3 = deserialize(outputDir*"/out3.jls")
    chn4 = deserialize(outputDir*"/out4.jls")
    chn_df1 = DataFrames.DataFrame(chn1)
    chn_df2 = DataFrames.DataFrame(chn2)
    chn_df3 = DataFrames.DataFrame(chn3)
    chn_df4 = DataFrames.DataFrame(chn4)

    d = zeros(4,2,length(wordTypes),chainLength)
    vd = []
    for j in range(1,length(wordTypes))
        for i in range(1,2)
            try
                d[1,i,j,:] = chn_df1[:,"ab_w["*string(i)*", "*string(j)*"]"]
                d[2,i,j,:] = chn_df2[:,"ab_w["*string(i)*", "*string(j)*"]"]
                d[3,i,j,:] = chn_df3[:,"ab_w["*string(i)*", "*string(j)*"]"]
                d[4,i,j,:] = chn_df4[:,"ab_w["*string(i)*", "*string(j)*"]"]
            catch
                if(i==1)
                    d[1,i,j,:] = chn_df1[:,"a_ws["*string(j)*"]"]
                    d[2,i,j,:] = chn_df1[:,"a_ws["*string(j)*"]"]
                    d[3,i,j,:] = chn_df1[:,"a_ws["*string(j)*"]"]
                    d[4,i,j,:] = chn_df1[:,"a_ws["*string(j)*"]"]
                else
                    d[1,i,j,:] = chn_df1[:,"b_ws["*string(j)*"]"]
                    d[2,i,j,:] = chn_df1[:,"b_ws["*string(j)*"]"]
                    d[3,i,j,:] = chn_df1[:,"b_ws["*string(j)*"]"]
                    d[4,i,j,:] = chn_df1[:,"b_ws["*string(j)*"]"]
                end


            end

            vd = vcat(vd, d[1,i,j,:],d[2,i,j,:],d[3,i,j,:],d[4,i,j,:])
        end
    end
    wt = fill(wordTypes[1],Int(length(vd)/length(wordTypes)))
    for i in range(2,length(wordTypes))
        wt = vcat(wt,fill(wordTypes[i],Int(length(vd)/length(wordTypes))))
    end
    df = DataFrames.DataFrame( data     = vd,
                    PCA      = repeat(vcat(fill("PC1",chainLength),fill("PC2",chainLength),fill("PC3",chainLength),fill("PC4",chainLength)),Int(length(vd)/(noPCS*chainLength))),
                    AB       = repeat(vcat(fill("Intercept",(noPCS*chainLength)),fill("Gradient",(noPCS*chainLength))),length(wordTypes)),
                    WordType = wt)
    df.PCWT = string.(df.WordType, " ",  df.PCA)
    dfI = subset(df, :AB => ByRow((==("Intercept"))))
    # df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
    #               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
    #               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
    df1 = subset(dfI, :PCA => ByRow((==("PC1"))))
    df2 = subset(dfI, :PCA => ByRow((==("PC2"))))
    df3 = subset(dfI, :PCA => ByRow((==("PC3"))))
    df4 = subset(dfI, :PCA => ByRow((==("PC4"))))


    dfG = subset(df, :AB => ByRow((==("Gradient"))))
    # df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
    #               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
    #               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
    dfg1 = subset(dfG, :PCA => ByRow((==("PC1"))))
    dfg2 = subset(dfG, :PCA => ByRow((==("PC2"))))
    dfg3 = subset(dfG, :PCA => ByRow((==("PC3"))))
    dfg4 = subset(dfG, :PCA => ByRow((==("PC4"))))

    dfs = [df1,df2,df3,df4]
    dfsg = [dfg1,dfg2,dfg3,dfg4]
    
    PlotlyJS.savefig(subplots(df1,wordTypes,cols),outputDir*"/i1.png",width=415,height=850)
    for i in 2:4
        PlotlyJS.savefig(subplots(dfs[i],wordTypes,cols),outputDir*"/i"*string(i)*".png",width=365,height=850)
    end

    PlotlyJS.savefig(subplots(dfg1,wordTypes,cols),outputDir*"/g1.png",width=415,height=850)
    for i in 2:4
        PlotlyJS.savefig(subplots(dfsg[i],wordTypes,cols),outputDir*"/g"*string(i)*".png",width=365,height=850)
    end
    # vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference with full Covariance"),Guide.xlabel("Posterior"),
    #                     layer(df1, x=:WordType,y=:data,color=:WordType,Geom.violin));

    # draw(PNG("violinCov.png", 8inch, 8inch, dpi=300), vio)


    essRhat([chn1,chn2,chn3,chn4],outputDir)
    combinePlots(outputDir)
end

function essRhat(chns,outputDir)
    gr(size=(1800,800), dpi=600)
    colNames = String.(Vector(DataFrames.DataFrame(summarystats(chns[1]; append_chains=true)).parameters))

    as    = vcat(   findall(x -> startswith(x, "ab_w[1"), colNames),
                    findall(x -> startswith(x, "ab_p[1"), colNames),
                    findall(x -> startswith(x, "ab_e[1"), colNames),
                    findall(x -> startswith(x, "a_w"), colNames),
                    findall(x -> startswith(x, "a_p"), colNames),
                    findall(x -> startswith(x, "a_e"), colNames))
    alabs = vcat(   filter(x -> startswith(x, "ab_w[1"), colNames),
                    filter(x -> startswith(x, "ab_p[1"), colNames),
                    filter(x -> startswith(x, "ab_e[1"), colNames),
                    filter(x -> startswith(x, "a_w"), colNames),
                    filter(x -> startswith(x, "a_p"), colNames),
                    filter(x -> startswith(x, "a_e"), colNames))
    alabs = map(x -> startswith(x, "ab_w") ? "Word-type" :
                    startswith(x, "ab_p") ? "Participant" : 
                    startswith(x, "ab_e") ? "Intercept" :
                    startswith(x, "a_w") ? "Word-type" :
                    startswith(x, "a_p") ? "Participant" : 
                    startswith(x, "a_e") ? "Intercept" : x, alabs)
    bs    = vcat(   findall(x -> startswith(x, "ab_w[2"), colNames),
                    findall(x -> startswith(x, "ab_p[2"), colNames),
                    findall(x -> startswith(x, "ab_e[2"), colNames),
                    findall(x -> startswith(x, "b_w"), colNames),
                    findall(x -> startswith(x, "b_p"), colNames),
                    findall(x -> startswith(x, "b_e"), colNames))
    blabs = vcat(   filter(x -> startswith(x, "ab_w[2"), colNames),
                    filter(x -> startswith(x, "ab_p[2"), colNames),
                    filter(x -> startswith(x, "ab_e[2"), colNames),
                    filter(x -> startswith(x, "b_w"), colNames),
                    filter(x -> startswith(x, "b_p"), colNames),
                    filter(x -> startswith(x, "b_e"), colNames))
    blabs = map(x -> startswith(x, "ab_w") ? "Word-type" :
                    startswith(x, "ab_p") ? "Participant" : 
                    startswith(x, "ab_e") ? "Intercept" : 
                    startswith(x, "b_w") ? "Word-type" :
                    startswith(x, "b_p") ? "Participant" : 
                    startswith(x, "b_e") ? "Intercept" : x, blabs)
    σs    = vcat(   findall(x -> startswith(x, "σ"), colNames),
                    findall(x -> startswith(x, "ρ"), colNames))
    σlabs = vcat(   filter(x -> startswith(x, "σ"), colNames),
                    filter(x -> startswith(x, "ρ"), colNames))
    σlabs = map(x -> startswith(x, "σ_w") ? "Word-type" :
                    startswith(x, "σ_p") ? "Participant" : 
                    startswith(x, "σ_e") ? "Intercept" :
                    startswith(x, "ρ") ? "LKJ" : x, σlabs)
    plts = []

    for i in range(1,4)

        myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][as],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][as],xlabel = "R-hat",ylabel = "ess (as)",title="PC " * string(i),group=alabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
        myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][bs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][bs],xlabel = "R-hat",ylabel = "ess (bs)",group=blabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
        myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][σs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][σs],xlabel = "R-hat",ylabel = "ess (σs)",group=σlabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
    end

    essRhat = Plots.plot(   plts[1],plts[4],plts[7],plts[10],
                            plts[2],plts[5],plts[8],plts[11],
                            plts[3],plts[6],plts[9],plts[12]
                            ,layout=grid(3,4),left_margin=15mm,bottom_margin=15mm
                            ,plot_title="EssRhat of 8 participants with Noun Verb Adj Adv & Func")
    Plots.savefig(essRhat,outputDir*"/essRhat.png")
end


function combinePlots(outputDir)
    img = load(outputDir*"/g1.png")
    for i in range(2,4)
        img = hcat(img,load(outputDir*"/g"*string(i)*".png"))
    end
    img2 = load(outputDir*"/g1.png")
    for i in range(2,4)
        img2 = hcat(img2,load(outputDir*"/i"*string(i)*".png"))
    end
    Images.save(outputDir*"/gradient.png",img)
    Images.save(outputDir*"/intercept.png",img2)
end