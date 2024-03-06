using Serialization,CSV,DataFrames,StatsBase,Distributions,Plots,Random,StatsFuns


df     = CSV.read("../../input/dfPCANorm.csv", DataFrame)
dfTags = CSV.read("../../input/full_tags.csv", DataFrame)
dfWord = filter(row -> row.Participant==0, df)[:,"Word"]

function lookup(x)
    return findfirst(item -> item == x, dfWord)
end



dfTags = filter(row -> row.Participant==0, dfTags)
dfTags = dfTags[!,"tags"]
data   = Matrix(select(df, ([:"Word", :"PC_1", :"PC_2",:"PC_3",:"PC_4",:"PC_5",:"PC_6"])))

perm   = shuffle(1:length(data[:,1]))
dataSorted = data[perm,:]

Xtr    = lookup.(dataSorted[1:2:end,1])
Ytr    = Matrix(dataSorted[1:2:end,2:7])

Xte    = lookup.(dataSorted[2:2:end,1])
Yte    = Matrix(dataSorted[2:2:end,2:7])


W1 = transpose(indicatormat(dfTags))
W2 = rand(11,6)./11
encoder = zeros((1726,1726))
for i in 1:1726
    encoder[i,i]=1
end

function forward(xs)
    z   = encoder[xs,:]*W1
    h   = logistic.(z)
    v   = h*W2
    out = logistic.(v)
    return z,h,v,out
end

function forward2(ys)
    z = ys * transpose(W2)
    h = logistic.(z)
    v = h * transpose(W1)
    out= logistic.(v)
    return z,h,v,out
end

function runModel(batchSize,epochs,iterations)
    for i in 1:iterations
        for j in 1:epochs
            sample = shuffle(1:length(Xtr[:,1]))[1:batchSize]
            z,h,v,out = forward(Xtr[sample])
            println("forward-"*string(i) * "-" *string(j))
        end
        for j in 1:epochs
            sample = shuffle(1:length(Xtr[:,1]))[1:batchSize]
            z,h,v,out = forward2(Ytr[sample,:])
            println("backward-"*string(i) * "-" *string(j))
        end
    end
end