using Serialization,CSV,DataFrames,StatsBase,Distributions,Plots,Random,StatsFuns


df     = CSV.read("../../input/dfPCANorm.csv", DataFrame)
dfTags = CSV.read("../../input/full_tags.csv", DataFrame)
dfWord = filter(row -> row.Participant==0, df)[:,"Word"]
lr = 0.01

function lookup(x)
    return findfirst(item -> item == x, dfWord)
end

function mse(preds,targets)
    return 0.5*(sum(preds-targets)^2)
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
    out = h*W2
    return z,h,out
end

function dSigmoid_dA(a)
    return logistic.(a).*(1 .-logistic.(a))
end

function backprop(xs,z,h,preds,targets)
    dLoss_dP     = preds - targets
    dLoss_dW2    = transpose(h) * dLoss_dP
    dLoss_dH     = dLoss_dP * transpose(W2)
    dS_dZ        = dSigmoid_dA(z)
    dLoss_dZ     = dS_dZ .* dLoss_dH
    dLoss_dW1    = transpose(xs) * dLoss_dZ
    return dLoss_dW1,dLoss_dW2
end



function learnW2()
    inp = Xtr[1:100]
    labels = Ytr[1:100,:]
    z,h,v,out = forward(inp)
    dLoss_dW2 = backprop(inp,z,h,v,out,labels)
    global W2,lr
    W2 = W2 .- (lr * dLoss_dW2)
    return(mse(out,labels))
end
function runModel(batchSize,iterations)
    global W1,W2,lr

    for i in 1:iterations
        sample = shuffle(1:length(Xtr[:,1]))[1:batchSize]
        inp = Xtr[sample]
        labels = Ytr[sample,:]
        z,h,out = forward(inp)
        dLoss_dW1,dLoss_dW2 = backprop(inp,z,h,out,labels)
        W1 = W1 .- (lr * dLoss_dW1)
        W2 = W2 .- (lr * dLoss_dW2)
        println("forward-"*string(i) * "-" *string(j) * ":" * string(mse(out,labels)))
    end
end