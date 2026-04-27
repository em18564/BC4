
function customMod(x,v) # helper modulo function to give x % v and x = v if divisible
    y = x % v
    if(y==0)
        y = v
    end
    return Int(y)
end



function createVariables()
    args = map(x->string(x), ARGS)
    arrayId = parse(Int,args[1])
    maxArrayId = parse(Int,args[2])
    pc   = customMod(arrayId,4)

    NUM_PARTICIPANTS = parse(Int,args[3])
    NUM_WORDS = parse(Int,args[4])
    TYPE_STRUCTURE = args[5]
    isPlotting = parse(Int,args[6])
    analyseEssRhat = parse(Int,args[7])
    min_exp = parse(Float64,args[8])
    max_exp = parse(Float64,args[9])
    min_cauchy = parse(Float64,args[10])
    max_cauchy = parse(Float64,args[11])
    if (maxArrayId == 4)
        expMean = min_exp
        cauchyMean = min_cauchy
    else
        groupId = 1 + (arrayId-customMod(arrayId,4))/4
        max = maxArrayId/4
        noCols = Int(sqrt(max))
        expVals = range(min_exp,max_exp,noCols)
        cauchyVals = range(min_cauchy,max_cauchy,noCols)
        expId = customMod(groupId,noCols)
        cauchyId = Int(1 + (groupId-expId)/noCols)
        expMean = expVals[expId]
        cauchyMean = cauchyVals[cauchyId]
    end

    
    dfTags   = CSV.read("../../../input/full_tags.csv", DataFrame).tags
    df       = CSV.read("../../../input/dfPCANorm_corrected.csv", DataFrame)
    df[!,"fullTag"] = dfTags
    df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
    df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
    NUM_TYPES,df_modified,wordTypes,cols = processTypeStructure(df_modified,TYPE_STRUCTURE)
    dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4]]

    output_loc = "output_" * TYPE_STRUCTURE * "_" * string(NUM_PARTICIPANTS) * "_" * string(NUM_WORDS)
    if (!isdir(output_loc))
        mkdir(output_loc)
    end
    return df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean
end



function runModel(model,df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean)
    m = sample(model, NUTS(), MCMCThreads(), 250,4)
    display(m)
    
    
    if(analyseEssRhat==1)
        output_loc = output_loc * "/" * string(expMean) * "_" * string(cauchyMean)
        if (!isdir(output_loc))
            mkdir(output_loc)
        end
        
    end

    serialize(output_loc*"/out"*string(pc)*".jls",m)

    if(analyseEssRhat == 1)
        essRhatScore(pc,expMean,cauchyMean,output_loc)
    end

    if(isPlotting==1)
        concludeAndPlot(m,output_loc,pc,wordTypes,cols)
    end
end


function essRhatScore(pc,expMean,cauchyMean,output_loc)
    m = deserialize(output_loc*"/out"*string(pc)*".jls")
    ss = DataFrame(summarystats(m; append_chains=true))
    colNames = String.(ss.parameters)
    labels = ["Overall","as","bs","σs","ws","ps","es","σ"]
    as    = findall(x -> startswith(x, "a"), colNames)
    bs    = findall(x -> startswith(x, "b"), colNames)
    σs    = findall(x -> startswith(x, "σ"), colNames)

    ws    = findall(x -> contains(x,"w"), colNames)
    ps    = findall(x -> contains(x,"p"), colNames)
    es    = findall(x -> contains(x,"e"), colNames)
    σ    = findall(x -> x == "σ", colNames)

    rhatScores = [  mean(ss[!,"rhat"]),
                    mean(ss[as,"rhat"]),mean(ss[bs,"rhat"]),mean(ss[σs,"rhat"]),
                    mean(ss[ws,"rhat"]),mean(ss[ps,"rhat"]),mean(ss[es,"rhat"]),
                    mean(ss[σ,"rhat"])]
    essScores  = [  mean(ss[!,"ess_bulk"]),
                    mean(ss[as,"ess_bulk"]),mean(ss[bs,"ess_bulk"]),mean(ss[σs,"ess_bulk"]),
                    mean(ss[ws,"ess_bulk"]),mean(ss[ps,"ess_bulk"]),mean(ss[es,"ess_bulk"]),
                    mean(ss[σ,"ess_bulk"])]

    score = DataFrame(label=labels,ess=essScores,rhat=rhatScores)
    params = DataFrame(param=["Exponential mean","Cauchy mean"],value=[expMean,cauchyMean])
    CSV.write(output_loc*"/score"*string(pc)*".csv",score)
    CSV.write(output_loc*"/params"*string(pc)*".csv",params)
end
