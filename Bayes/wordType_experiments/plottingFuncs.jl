rangeVals = 3.0

function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end



function concludeAndPlot(m,output_loc,pc,wordTypes,cols,noPCS)


    if(pc == 1)
    #wait for all other PCs to finish before greating plots
    global is_waiting = true
    while(is_waiting)
        if(reduce(&,[isfile(output_loc*"/out"*string(i)*".jls") for i in range(1,noPCS)]))
            println("plotting graphs")
            plotGraphs(output_loc,wordTypes,cols,noPCS) 
            global is_waiting=false
        else
        println("Waiting for other PCs to complete")
        sleep(30)
        end
        
    end
    end


end


function violin_grouped(data,wordTypes,cols) # old version for doing by PC
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


    if data[1,:PCA] == "PC6"
        data = [
        PlotlyJS.violin(
            y=y, name=name, x=days, jitter=0, points="all",
            marker=attr(symbol="line-ew", color=color, meanline_visible=true,width=0.1,showlegend=false)
        ) for (y, name, color) in zip(ys, names, colors)
    ]   
    else
data = [
        PlotlyJS.violin(
            y=y, name=name, x=days, jitter=0, points="all",
            marker=attr(symbol="line-ew", color=color, meanline_visible=true,width=0.1,showlegend=false)
        ) for (y, name, color) in zip(ys, names, colors)
    ]
    end
    PlotlyJS.plot(data, layout)
end


function violin_grouped(data,columnTypes,columLabel,xLabel,x1,cols)
    ys = []
    for type in unique(data.AB)
        append!(ys,[subset(data, "AB" => ByRow((==(type))))[:,:data]])
    end
    days = data.PCA
    # y_adj = subset(data, :WordType => ByRow((==("Adjective"))))[:,:data]
    # y_nou = subset(data, :WordType => ByRow((==("Noun"))))[:,:data]
    # y_ver = subset(data, :WordType => ByRow((==("Verb"))))[:,:data]
    # y_adv = subset(data, :WordType => ByRow((==("Adverb"))))[:,:data]
    # y_fun = subset(data, :WordType => ByRow((==("Function"))))[:,:data]

    colors = cols
    names = ["Intercept", "Posterior"]
    #ys = (y_adj, y_nou, y_ver,y_adv,y_fun)
    # if data[1,xLabel] ==  x1
        
    # else
    #     layout = Layout(
    #     yaxis=attr(title="Intercept Posterior",font_size=30),
    #     violinmode="group",
    #     title=attr(text=data[1,xLabel], font_size=30,y=0.95,
    #     x=0.5,
    #     xanchor= "center",
    #     yanchor= "top")
    # )
    # end
    layout = Layout(
        yaxis=attr(title="Intercept Posterior",range=(-rangeVals, rangeVals), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000"),
        font=attr(size=25),
        violinmode="group",
        title=attr(text=data[1,xLabel], font_size=30,y=0.975,
        x=0.5,
        xanchor= "center",
        yanchor= "top"),
        violingap = 0.05,
        violingroupgap = 0.1
    )
    data = [
        PlotlyJS.violin(
            y=y, name=name, x=days, jitter=0, points="all",
            marker=attr(symbol="line-ew", color=color, meanline_visible=true,width=15)
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
        x = wordTypes,
        showlegend=false
    )
end


function HDIs(data,wordTypes,cols)
    mdifs = zeros(length(wordTypes),length(wordTypes))
    ldifs = zeros(length(wordTypes),length(wordTypes))
    udifs = zeros(length(wordTypes),length(wordTypes))
    if data[1,:PCA] == "PC1"
        layout = Layout(yaxis=attr(title="97% HDI Difference",range=[-rangeVals,rangeVals]),
                        boxmode="group",xaxis = attr(
                                                    tickangle = 90
                                                ))
    else
        layout = Layout(yaxis=attr(range=[-rangeVals,rangeVals]),
                        boxmode="group",xaxis = attr(
                                                    tickangle = 90
                                                ))
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
    if data[1,:PCA] != "PC6"
        p.plot.layout["showlegend"] = false
    end
    p.plot.layout["height"] = 1450
    p.plot.layout.grid = attr(rows=2, columns=1, rowgap=2)
    # p.plot.layout["violingap"] = 0
    # p.plot.layout["violingroupgap"] = 0
    p.plot.layout["boxgroupgap"] = 0.15
    p.plot.layout["boxgap"] = 0.4
    if data[1,:PCA] == "PC1"
        p.plot.layout["margin"] =attr(l=55, r=5, b=15, t=15)
        p.plot.layout["width"] = 0.01


    else
        p.plot.layout["margin"] =attr(l=5, r=5, b=15, t=15)
        p.plot.layout["width"] = 0.01
    end
    
    p.plot.layout["xaxis2"] = attr(range=(-0.35, 0.35), constrain="domain")
    p.plot.layout["yaxis2"] = attr(range=(-rangeVals, rangeVals), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")
    p.plot.layout["yaxis1"] = attr(range=(-rangeVals, rangeVals), constrain="domain",zeroline=true,zerolinewidth=1,zerolinecolor = "#000000")

    p.plot.layout["font"]   = attr(size=22)
    global p = p


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





function plotGraphs(outputDir,wordTypes,cols,noPCS,noInChain)
    chainLength = noInChain*4
    includeSigma = true
    if includeSigma
        global rangeVals = 0.225
    else
        global rangeVals = 3.0
    end
    #df = CSV.read("savedData/df_2.csv", DataFrame)

    chn_dfs = []
    ss_dfs  = []
    for i in range(1,6)
        push!(chn_dfs,CSV.read(outputDir*"/chndf_"*string(i),DataFrame,delim=";"))
        push!(ss_dfs,CSV.read(outputDir*"/ssdf_"*string(i),DataFrame,delim=";"))

        chn_dfs[i] = filter(row -> all(x -> !(x isa Number && isnan(x)), row), chn_dfs[i])
        ss_dfs[i] = filter(row -> all(x -> !(x isa Number && isnan(x)), row), ss_dfs[i])

    end
    global testA = chn_dfs
    global testB = ss_dfs
    
    #essRhat(chn_dfs,ss_dfs,outputDir)
    essRhatOverall(chn_dfs,ss_dfs,outputDir)
    return # EARLY RETURN
    d = zeros(noPCS,2,length(wordTypes),chainLength)
    vd = []
    for j in range(1,length(wordTypes))
        for i in range(1,2)
            try
                # _________________OPTION 1__LKJ REINTRODUCED_________________________
                for chn_dfId in eachindex(chn_dfs)
                    chn_df = chn_dfs[chn_dfId]
                    sigs  = [Diagonal([chn_df[:,"σ_w[1]"][innerI], chn_df[:,"σ_w[2]"][innerI]]) * Matrix([  chn_df[:,"Lcorr_w.L[1, 1]"][innerI] chn_df[:,"Lcorr_w.L[2, 1]"][innerI];
                                                                                                chn_df[:,"Lcorr_w.L[2, 1]"][innerI] chn_df[:,"Lcorr_w.L[2, 2]"][innerI]]) for innerI in range(1,chainLength)]       
                                                                                                                                                                            
                    z_abs = [reduce(vcat,[[chn_df[:,"z_ab_w[1, "*string(innerJ)*"]"][innerI] chn_df[:,"z_ab_w[2, "*string(innerJ)*"]"][innerI]] for innerJ in eachindex(wordTypes)]) for innerI in range(1,chainLength)]
                    ab_ws = reshape(reduce(hcat, [sigs[innerI]*transpose(z_abs[innerI]) for innerI in range(1,chainLength)]),2,length(wordTypes),:)
                    if includeSigma
                        d[chn_dfId,i,j,:] = ab_ws[i,j,:]
                    else
                        d[chn_dfId,i,j,:]  = chn_df[:,"z_ab_w["*string(i)*", "*string(j)*"]"]
                    end
                end

            catch
                try
                    # _________________OPTION 2__NO LKJ_________________________
                    
                    for pc in range(1,noPCS)
                        if i==1
                            d[pc,i,j,:] = chn_dfs[pc][:,"a_ws["*string(j)*"]"].*chn_dfs[pc][:,"σ_aw"]
                        else
                            d[pc,i,j,:] = chn_dfs[pc][:,"b_ws["*string(j)*"]"].*chn_dfs[pc][:,"σ_bw"]
                        end
                    end
                    
                catch
                    # _________________OPTION 3__ORIGINAL LKJ_________________________
                    for pc in range(1,noPCS)
                        d[pc,i,j,:] = chn_dfs[pc][:,"ab_w["*string(i)*", "*string(j)*"]"]
                    end

                end
                
            end

            for pc in range(1,noPCS)
                vd = vcat(vd, d[pc,i,j,:])
            end
            
        end
    end
                
 
    
    wt = fill(wordTypes[1],Int(length(vd)/length(wordTypes)))
    for i in range(2,length(wordTypes))
        wt = vcat(wt,fill(wordTypes[i],Int(length(vd)/length(wordTypes))))
    end
    df = DataFrames.DataFrame( data     = vd,
                    PCA      = repeat(reduce(vcat,([fill("PC"*string(i),chainLength) for i in range(1,noPCS)])),Int(length(vd)/(noPCS*chainLength))),
                    AB       = repeat(vcat(fill("Intercept",(noPCS*chainLength)),fill("Gradient",(noPCS*chainLength))),length(wordTypes)),
                    WordType = wt)
    

    groupByWordCats = true      

    # OPTION 1
    if groupByWordCats
        df.AB_PC = string.(df.AB, " ",  df.PCA)
        pclabs = unique(df.AB_PC)
        dfWTs = [subset(df, :WordType => ByRow((==(wt)))) for wt in wordTypes]
        cols = reduce(vcat,([[col; col*0.7] for col in palette(:default)[1:11]]))
        for dfWt in eachindex(dfWTs)
            p = violin_grouped(dfWTs[dfWt],pclabs,"AB_PC","WordType","Adjective",cols[2*dfWt-1:2*dfWt])
            PlotlyJS.savefig(p,outputDir*"/"*"WT_"*string(dfWt)*".png",width=800,height=700)
        end
        
        global p = p
    else
        # OPTION 2
        df.PCWT = string.(df.WordType, " ",  df.PCA)

        dfI = subset(df, :AB => ByRow((==("Intercept"))))
        # df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
        #               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
        #               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))



        dfG = subset(df, :AB => ByRow((==("Gradient"))))
        # df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
        #               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
        #               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))


        dfs  = [subset(dfI, :PCA => ByRow((==("PC"*string(i))))) for i in range(1,noPCS)]
        dfsg = [subset(dfG, :PCA => ByRow((==("PC"*string(i))))) for i in range(1,noPCS)]
        baseWidth = 550
        offsetEnd = 240 # TWEAK THIS IF GRAPHS ARENT LINING UP
        offsetBeginning = 50
        PlotlyJS.savefig(subplots(dfs[1],wordTypes,cols),outputDir*"/i1.png",width=baseWidth+offsetBeginning,height=1450)
        for i in 2:noPCS-1
            PlotlyJS.savefig(subplots(dfs[i],wordTypes,cols),outputDir*"/i"*string(i)*".png",width=baseWidth,height=1450)
        end
        PlotlyJS.savefig(subplots(dfs[6],wordTypes,cols),outputDir*"/i"*string(6)*".png",width=baseWidth+offsetEnd,height=1450)



        PlotlyJS.savefig(subplots(dfsg[1],wordTypes,cols),outputDir*"/g1.png",width=baseWidth+offsetBeginning,height=1450)
        for i in 2:noPCS-1
            PlotlyJS.savefig(subplots(dfsg[i],wordTypes,cols),outputDir*"/g"*string(i)*".png",width=baseWidth,height=1450)
        end
        PlotlyJS.savefig(subplots(dfsg[6],wordTypes,cols),outputDir*"/g"*string(6)*".png",width=baseWidth+offsetEnd,height=1450)

        # vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference with full Covariance"),Guide.xlabel("Posterior"),
        #                     layer(df1, x=:WordType,y=:data,color=:WordType,Geom.violin));

        # draw(PNG("violinCov.png", 8inch, 8inch, dpi=300), vio)

        combinePlots(outputDir,noPCS)
    end

end

function essRhat(chn_dfs,ss_dfs,outputDir)
    gr(size=(1800,800), dpi=600)
    colNames = ss_dfs[1].parameters
    as    = vcat(   findall(x -> startswith(x, "ab_w[1"), colNames),
                    findall(x -> startswith(x, "ab_p[1"), colNames),
                    findall(x -> startswith(x, "ab_e[1"), colNames),
                    findall(x -> startswith(x, "z_ab_w[1"), colNames),
                    findall(x -> startswith(x, "z_ab_p[1"), colNames),
                    findall(x -> startswith(x, "a_w"), colNames),
                    findall(x -> startswith(x, "a_p"), colNames),
                    findall(x -> startswith(x, "a_e"), colNames))
    alabs = vcat(   filter(x -> startswith(x, "ab_w[1"), colNames),
                    filter(x -> startswith(x, "ab_p[1"), colNames),
                    filter(x -> startswith(x, "ab_e[1"), colNames),
                    filter(x -> startswith(x, "z_ab_w[1"), colNames),
                    filter(x -> startswith(x, "z_ab_p[1"), colNames),
                    filter(x -> startswith(x, "a_w"), colNames),
                    filter(x -> startswith(x, "a_p"), colNames),
                    filter(x -> startswith(x, "a_e"), colNames))
    alabs = map(x -> startswith(x, "ab_w") ? "Word-type" :
                    startswith(x, "ab_p") ? "Participant" : 
                    startswith(x, "ab_e") ? "Intercept" :
                    startswith(x, "a_w") ? "Word-type" :
                    startswith(x, "a_p") ? "Participant" : 
                    startswith(x, "z_ab_w") ? "Word-type" : 
                    startswith(x, "z_ab_p") ? "Participant" : 
                    startswith(x, "a_e") ? "Intercept" : x, alabs)
    bs    = vcat(   findall(x -> startswith(x, "ab_w[2"), colNames),
                    findall(x -> startswith(x, "ab_p[2"), colNames),
                    findall(x -> startswith(x, "ab_e[2"), colNames),
                    findall(x -> startswith(x, "z_ab_w[2"), colNames),
                    findall(x -> startswith(x, "z_ab_p[2"), colNames),
                    findall(x -> startswith(x, "b_w"), colNames),
                    findall(x -> startswith(x, "b_p"), colNames),
                    findall(x -> startswith(x, "b_e"), colNames))
    blabs = vcat(   filter(x -> startswith(x, "ab_w[2"), colNames),
                    filter(x -> startswith(x, "ab_p[2"), colNames),
                    filter(x -> startswith(x, "ab_e[2"), colNames),
                    filter(x -> startswith(x, "z_ab_w[2"), colNames),
                    filter(x -> startswith(x, "z_ab_p[2"), colNames),
                    filter(x -> startswith(x, "b_w"), colNames),
                    filter(x -> startswith(x, "b_p"), colNames),
                    filter(x -> startswith(x, "b_e"), colNames))
    blabs = map(x -> startswith(x, "ab_w") ? "Word-type" :
                    startswith(x, "ab_p") ? "Participant" : 
                    startswith(x, "ab_e") ? "Intercept" : 
                    startswith(x, "b_w") ? "Word-type" :
                    startswith(x, "b_p") ? "Participant" : 
                    startswith(x, "z_ab_w") ? "Word-type" : 
                    startswith(x, "z_ab_p") ? "Participant" : 
                    startswith(x, "b_e") ? "Intercept" : x, blabs)
    σs    = vcat(   findall(x -> startswith(x, "σ"), colNames),
                    findall(x -> startswith(x, "ρ"), colNames),
                    findall(x -> startswith(x, "Lcorr_w"), colNames),
                    findall(x -> startswith(x, "Lcorr_p"), colNames))
    σlabs = vcat(   filter(x -> startswith(x, "σ"), colNames),
                    filter(x -> startswith(x, "ρ"), colNames),
                    filter(x -> startswith(x, "Lcorr_w"), colNames),
                    filter(x -> startswith(x, "Lcorr_p"), colNames))
    σlabs = map(x -> startswith(x, "σ_w") ? "Word-type" :
                    startswith(x, "σ_p") ? "Participant" : 
                    startswith(x, "σ_e") ? "Intercept" :
                    startswith(x, "Lcorr") ? "LKJ" :
                    startswith(x, "ρ") ? "LKJ" : x, σlabs)
    plts = []
    if length(colNames) != length(as) + length(bs)  + length(σs) 
        println("POTENTIAL MISSING COLUMN FOR ESSRHAT")
        println("Overall = ", length(colNames))
        println(colNames)
        println("a = ", length(as))
        println(as)
        println("b = ", length(bs))
        println(bs)
        println("σ = ", length(σs))
        println(σs)

        println("Missing: " )
        full = vcat(as,bs,σs)
        for i in range(1,length(colNames))
            if !(i in full)
                println(colNames[i])
            end
        end
    end
    for i in range(1,length(ss_dfs))

        myplot = Plots.scatter(ss_dfs[i][:,"rhat"][as],ss_dfs[i][:,"ess_bulk"][as],xlabel = "R-hat",ylabel = "ess (as)",title="PC " * string(i),group=alabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
        myplot = Plots.scatter(ss_dfs[i][:,"rhat"][bs],ss_dfs[i][:,"ess_bulk"][bs],xlabel = "R-hat",ylabel = "ess (bs)",group=blabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
        myplot = Plots.scatter(ss_dfs[i][:,"rhat"][σs],ss_dfs[i][:,"ess_bulk"][σs],xlabel = "R-hat",ylabel = "ess (σs)",group=σlabs,ylims=(0,1200),xlims=(.99,1.25))
        push!(plts,myplot)
    end
    r = reshape(plts,3,:)
    reshapedPlots = reduce(vcat,[r[i,:] for i in range(1,length(r[:,1]))])
    essRhat = Plots.plot(   (reshapedPlots[i] for i in range(1,length(reshapedPlots)))...;
                             layout=grid(3,length(ss_dfs)),left_margin=15mm,bottom_margin=15mm
                            ,plot_title="EssRhat of 8 participants with Noun Verb Adj Adv & Func")
    Plots.savefig(essRhat,outputDir*"/essRhat.png")
end
function essRhatOverall(chn_dfs,ss_dfs,outputDir)
    theme(:ggplot2)
    gr(size=(1600,950), dpi=600)
    MyMarkSize = 4
    MyMarkOpacity = 0.7
    myMarkerStrokeWith = 0.5
    global ss_dfsTest = ss_dfs

    maxRhat = maximum([maximum(ss_dfs[i][:,"rhat"]) for i in range(1,6)]) *1.001
    maxEss  = maximum([maximum(ss_dfs[i][:,"ess_bulk"]) for i in range(1,6)]) *1.001
    myXlims=(.997,maxRhat)
    myYlims=(0,maxEss)
    essStep = 250
    if maxEss >2000
        essStep = 500
    end
    if maxEss>4000
        essStep = 1000
    end
    rhatStep = 0.005
    if maxRhat>1.02
        rhatStep = 0.01
    end
    myMainPlotXTicks = range(1,step=rhatStep,maxRhat - maxRhat%rhatStep)
    myMainPlotYTicks = range(0,step=essStep,maxEss-maxEss%essStep)
    # mySubPlotXTicks  = [1,1.015]
    # mySubPlotYTicks  = [0,3000,6000,9000]
    default(titlefontsize=12, guidefontsize=12, tickfontsize=12, legendfontsize=12)
    colNames = ss_dfs[1].parameters
    lexicalCatsA    = vcat( findall(x -> startswith(x, "ab_w[1"), colNames),
                            findall(x -> startswith(x, "z_ab_w[1"), colNames),
                            findall(x -> startswith(x, "a_w"), colNames))

    lexicalCatsB    = vcat( findall(x -> startswith(x, "ab_w[2"), colNames),
                            findall(x -> startswith(x, "z_ab_w[2"), colNames),
                            findall(x -> startswith(x, "b_w"), colNames))

    lexicalCatsAσ   =       findall(x -> startswith(x, "σ_aw"), colNames)
    lexicalCatsBσ   =       findall(x -> startswith(x, "σ_bw"), colNames)

    lexicalCats     = [lexicalCatsA,lexicalCatsB,lexicalCatsAσ,lexicalCatsBσ]

    participantA    = vcat( findall(x -> startswith(x, "ab_p[1"), colNames),
                            findall(x -> startswith(x, "z_ab_p[1"), colNames),
                            findall(x -> startswith(x, "a_p"), colNames))

    participantB    = vcat( findall(x -> startswith(x, "ab_p[2"), colNames),
                            findall(x -> startswith(x, "z_ab_p[2"), colNames),
                            findall(x -> startswith(x, "b_p"), colNames))
    
    participantAσ   = vcat( findall(x -> startswith(x, "σ_ap"), colNames),
                            findall(x -> startswith(x, "σ_p[1]"), colNames))
    participantBσ   = vcat( findall(x -> startswith(x, "σ_bp"), colNames),
                            findall(x -> startswith(x, "σ_p[2]"), colNames))
    
    #participantLKJ  = findall(x -> startswith(x, "ρ_p"), colNames)
    participants     = [participantA,participantB,participantAσ,participantBσ]#,participantLKJ]


    offsetA         = vcat( findall(x -> startswith(x, "ab_e[1"), colNames),
                            findall(x -> startswith(x, "z_ab_e[1"), colNames),
                            findall(x -> startswith(x, "a_e"), colNames))

    offsetB         = vcat( findall(x -> startswith(x, "ab_e[2"), colNames),
                            findall(x -> startswith(x, "z_ab_e[2"), colNames),
                            findall(x -> startswith(x, "b_e"), colNames))

    overallσ        = findall(x -> ==(x, "σ"), colNames)

    offset          = [offsetA,offsetB,overallσ]

    γBase           = findall(x -> ==(x, "γ"), colNames)
    γsParticipant   = vcat( findall(x -> startswith(x, "z_γp"), colNames))
    γsigma          = findall(x -> ==(x, "σ_γp"), colNames)

    participantSigmaConstruction = [γBase,γsParticipant,γsigma]


    allCats = [lexicalCats,participants,participantSigmaConstruction,offset]
    
    flatAllCats = []
    for cat in allCats
        for innercat in cat
            flatAllCats = vcat(flatAllCats,innercat)
        end
    end
    println(flatAllCats)
    for i in range(1,length(colNames))
        if !(i in flatAllCats)
            println("ERROR: " * string(i) * " not found (" * colNames[i] *")")
        end
    end
    colScheme = cgrad(:Paired_8,categorical = true)

    global gss_dfs = ss_dfs
    p=Plots.scatter([], [],layout=(2,4),label=false)
    for i in range(1,6)
        x = ss_dfs[i][:,"rhat"]
        y = ss_dfs[i][:,"ess_bulk"]
        for catId in eachindex(allCats)
            plotLegend=true
            for innerCatId in eachindex(allCats[catId])
                println("PC " * string(i) * ": " * "category " * string(catId) * " - subcategory " * string(innerCatId))
                if plotLegend && i == 1
                    if length(allCats[catId][innerCatId])>0
                        if catId == 1
                                Plots.scatter!([], label=" σ (relative to colour)", grid=false, showaxis=false,subplot=4,legend=:topleft,c=:grey,m=:xcross)
                                Plots.scatter!([], label=" sample (relative to colour)", grid=false, showaxis=false,subplot=4,legend=:topleft,c=:grey,m=:circle)
                                # if length(allCats[2][5])>0
                                #     Plots.scatter!([], label=" LKJ prior (relative to colour)", grid=false, showaxis=false,subplot=4,legend=:topleft,c=:grey,m=:cross)
                                # end 
                                Plots.scatter!([], label=" Lexical Intercept", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[1],m=:rect,bg_inside=:white, margin = 5mm)
                                Plots.scatter!([], label=" Lexical Gradient", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[2],m=:rect)
                                Plots.scatter!([], grid=false, showaxis=false,subplot=8,bg_inside=:white,label=false)
                        elseif catId == 2
                                Plots.scatter!([], label=" Participant Intercept", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[3],m=:rect)
                                Plots.scatter!([], label=" Participant Gradient", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[4],m=:rect)
                        elseif catId == 3
                                Plots.scatter!([], label=" γ Base", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[7],m=:rect)
                                Plots.scatter!([], label=" γ Participant", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[8],m=:rect)
                        elseif catId == 4
                                Plots.scatter!([], label=" Offset Intercept", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[5],m=:rect)
                                Plots.scatter!([], label=" Offset Gradient", grid=false, showaxis=false,subplot=4,legend=:topleft,c=colScheme[6],m=:rect)
                                if length(allCats[catId][3])>0
                                    Plots.scatter!([], label=" Overall σ", grid=false, showaxis=false,subplot=4,legend=:topleft,c=:black,m=:xcross)
                                end
                        end
                        plotLegend=false
                    end
                    
                end




                myCol  = :black
                myMark = :circle
                if catId == 1
                    #lexical
                    if innerCatId == 1
                        #A
                        myCol = colScheme[1]
                    elseif innerCatId == 2
                        #B
                        myCol = colScheme[2]
                    elseif innerCatId == 3
                        #Asig
                        myMark = :xcross
                        myCol = colScheme[1]
                    else
                        #Bsig
                        myMark = :xcross
                        myCol = colScheme[2]
                    end 
                elseif catId == 2
                    #participant
                    if innerCatId == 1
                        #A
                        myCol = colScheme[3]
                    elseif innerCatId == 2
                        #B
                        myCol = colScheme[4]
                    elseif innerCatId == 3
                        #Asig
                        myMark = :xcross
                        myCol = colScheme[3]
                    elseif innerCatId == 4
                        #Bsig
                        myMark = :xcross
                        myCol = colScheme[4]
                    elseif innerCatId == 5
                        #LKJ Prior
                        myMark = :cross
                        myCol = colScheme[4]
                    end 
                
                elseif catId == 3
                    #participantSigmaConstruction
                    if innerCatId == 1
                        #γBase
                        myCol = colScheme[7]
                    elseif innerCatId == 2
                        #γParticipant
                        myCol = colScheme[8]
                    else
                        #γsig
                        myCol = colScheme[8]
                        myMark = :xcross
                    end 
                elseif catId == 4
                    #offset
                    if innerCatId == 1
                        #A
                        myCol = colScheme[5]
                    elseif innerCatId == 2
                        #B
                        myCol = colScheme[6]
                    else
                        #sig
                        myMark = :xcross
                    end 
                end
                plotVal = i
                if i>3
                    plotVal = i+1
                end
                Plots.scatter!(p,x[allCats[catId][innerCatId]], y[allCats[catId][innerCatId]], subplot=plotVal,c=myCol,m=myMark,label=false,title="\nPC " *string(i),xticks=myMainPlotXTicks,yticks=myMainPlotYTicks,ylims=myYlims,xlims=myXlims, margin = 5mm)
            end
        end
        
    end
    println("got to save fig")
    global myplot
    myplot = p
    #Plots.savefig(p,outputDir*"/essRhatOverall6.png")
end

function essRhatOverall_OLD(chn_dfs,ss_dfs,outputDir)
    theme(:ggplot2)
    gr(size=(1000,800), dpi=600)
    MyMarkSize = 4
    MyMarkOpacity = 0.7
    myMarkerStrokeWith = 0.5
    myXlims=(.997,1.016)
    myYlims=(0,9000)
    myMainPlotXTicks = [1,1.005, 1.010, 1.015]
    myMainPlotYTicks = 0:1000:9000
    mySubPlotXTicks  = [1,1.015]
    mySubPlotYTicks  = [0,3000,6000,9000]
    default(titlefontsize=12, guidefontsize=12, tickfontsize=12, legendfontsize=12)
    global ss_dfsTest = ss_dfs
    colNames = ss_dfs[1].parameters
    lexicalCatsA    = vcat( findall(x -> startswith(x, "ab_w[1"), colNames),
                            findall(x -> startswith(x, "z_ab_w[1"), colNames),
                            findall(x -> startswith(x, "a_w"), colNames))

    lexicalCatsB    = vcat( findall(x -> startswith(x, "ab_w[2"), colNames),
                            findall(x -> startswith(x, "z_ab_w[2"), colNames),
                            findall(x -> startswith(x, "b_w"), colNames))

    lexicalCatsAσ   =       findall(x -> startswith(x, "σ_aw"), colNames)
    lexicalCatsBσ   =       findall(x -> startswith(x, "σ_bw"), colNames)

    lexicalCats     = [lexicalCatsA,lexicalCatsB,lexicalCatsAσ,lexicalCatsBσ]

    participantA    = vcat( findall(x -> startswith(x, "ab_p[1"), colNames),
                            findall(x -> startswith(x, "z_ab_p[1"), colNames),
                            findall(x -> startswith(x, "a_p"), colNames))

    participantB    = vcat( findall(x -> startswith(x, "ab_p[2"), colNames),
                            findall(x -> startswith(x, "z_ab_p[2"), colNames),
                            findall(x -> startswith(x, "b_p"), colNames))
    
    participantAσ   =       findall(x -> startswith(x, "σ_ap"), colNames)
    participantBσ   =       findall(x -> startswith(x, "σ_bp"), colNames)

    participants     = [participantA,participantB,participantAσ,participantBσ]


    offsetA         = vcat( findall(x -> startswith(x, "ab_e[1"), colNames),
                            findall(x -> startswith(x, "z_ab_e[1"), colNames),
                            findall(x -> startswith(x, "a_e"), colNames))

    offsetB         = vcat( findall(x -> startswith(x, "ab_e[2"), colNames),
                            findall(x -> startswith(x, "z_ab_e[2"), colNames),
                            findall(x -> startswith(x, "b_e"), colNames))

    overallσ        = findall(x -> ==(x, "σ"), colNames)

    offset          = [offsetA,offsetB,overallσ]

    allCats = [lexicalCats,participants,offset]
    
    flatAllCats = []
    for cat in allCats
        for innercat in cat
            flatAllCats = vcat(flatAllCats,innercat)
        end
    end
    println(flatAllCats)
    for i in range(1,length(colNames))
        if !(i in flatAllCats)
            println("ERROR: " * string(i) * " not found (" * colNames[i] *")")
        end
    end

    global gss_dfs = ss_dfs
    x = ss_dfs[1][:,"rhat"]
    y = ss_dfs[1][:,"ess_bulk"]
    cols = cgrad(:balance,6,categorical=true)
    myplot = Plots.scatter(x,y,xlabel = "R-hat",ylabel = "ess",ylims=myYlims,xlims=myXlims,label = "PC 1",ms=MyMarkSize,ma=MyMarkOpacity,c=cols[1],markerstrokewidth=myMarkerStrokeWith,legend=:topleft,xticks=myMainPlotXTicks,yticks=myMainPlotYTicks)
    for i in range(2,length(ss_dfs))
        x = ss_dfs[i][:,"rhat"]
        y = ss_dfs[i][:,"ess_bulk"]
        Plots.scatter!(x,y,xlabel = "R-hat",ylabel = "ess",label="PC "*string(i),ms=MyMarkSize,ma=MyMarkOpacity,c=cols[i],markerstrokewidth=myMarkerStrokeWith)

    end
    for i in range(1,length(ss_dfs))
        x = ss_dfs[i][:,"rhat"]
        y = ss_dfs[i][:,"ess_bulk"]
        xpos = 0.48+0.3*((i-1)%2)
        ypos = 0+0.3*floor((i-1)/2)

        scatter!(x,y,ms=MyMarkSize,ma=MyMarkOpacity*0.5,c=cols[i],markerstrokewidth=myMarkerStrokeWith,inset = (1, bbox(xpos,ypos,0.2,0.2)),subplot=i+1)
        covellipse!([mean(x),mean(y)], cov([x y]),showaxes=true, label="Covariance of PC " * string(i),fillalpha=MyMarkOpacity,c=cols[i],subplot=i+1,xlims=myXlims,ylims=myYlims,legend=false,xticks=mySubPlotXTicks,yticks=mySubPlotYTicks,minorticks=3)
        annotate!(1.0065, 8000, text("PC " * string(i) * " Covariance", :center, 12, :black),subplot=i+1)

    end
    Plots.savefig(myplot,outputDir*"/essRhatOverall5.png")
end
function combinePlots(outputDir,noPCS)
    img = load(outputDir*"/g1.png")
    for i in range(2,noPCS)
        img = hcat(img,load(outputDir*"/g"*string(i)*".png"))
    end
    img2 = load(outputDir*"/i1.png")
    for i in range(2,noPCS)
        img2 = hcat(img2,load(outputDir*"/i"*string(i)*".png"))
    end
    Images.save(outputDir*"/gradient.png",img)
    Images.save(outputDir*"/intercept.png",img2)

    img3 = load(outputDir*"/WT_1.png")
    for i in range(2,4)
        img3 = hcat(img3,load(outputDir*"/WT_"*string(i)*".png"))
    end
    img4 = load(outputDir*"/WT_5.png")
    for i in range(6,8)
        img4 = hcat(img4,load(outputDir*"/WT_"*string(i)*".png"))
    end
    img5 = load(outputDir*"/WT_9.png")
    white_img = fill(RGB{N0f8}(1, 1, 1), size(img5))
    for i in range(10,11)
        img5 = hcat(img5,load(outputDir*"/WT_"*string(i)*".png"))
    end
    img5 = hcat(img5,white_img)
    Images.save(outputDir*"/wts.png",vcat(img3,img4,img5))

end