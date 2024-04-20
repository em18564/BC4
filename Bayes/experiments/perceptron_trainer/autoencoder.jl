using Flux,Serialization,CSV,DataFrames,StatsBase,Distributions,Plots,Random,StatsFuns,MLDatasets,Flux.Data

df     = CSV.read("../../input/dfHierarchical.csv", DataFrame)
dfTags = CSV.read("../../input/full_tags.csv", DataFrame)
PCA_3  = CSV.read("../../input/dfPCA_3.csv", DataFrame)
PCA_4  = CSV.read("../../input/dfPCA_4.csv", DataFrame)
dfWord = filter(row -> row.Participant==0, df)[:,"Word"]
dfTags = filter(row -> row.Participant==0, dfTags)
dfTags = dfTags[!,"tags"]
dataWithWords = Matrix(select(df, ([:"Word", :"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP"])))
data = Matrix(select(df, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP"])))
device = cpu # where will the calculations be performed?
L1, L2 = 4, 3 # layer dimensions
η = 0.01 # learning rate for ADAM optimization algorithm
batch_size = 100; # batch size for optimization

function lookup(x)
    return findfirst(item -> item == x, dfWord)
end

perm   = shuffle(1:length(data[:,1]))
dataSorted = data[perm,:]

Xtr    = transpose(dataSorted[1:2:end,:])

Xte    = transpose(dataSorted[2:2:end,:])


function get_data(batch_size)
    d = prod(size(Xtr)[1]) # input dimension
    xtrain1d = reshape(Xtr, d, :) # reshape input as a 784-dimesnonal vector (28*28)
    dl = Flux.DataLoader(xtrain1d, batchsize=batch_size, shuffle=true)
    dl, d
end

dl, d = get_data(batch_size)


function train!(model_loss, model_params, opt, loader, epochs = 10)
    train_steps = 0
    "Start training for total $(epochs) epochs" |> println
    for epoch = 1:epochs
        print("Epoch $(epoch): ")
        ℒ = 0
        for x in loader
            loss, back = Flux.pullback(model_params) do
                model_loss(x |> device)
            end
            grad = back(1f0)
            Flux.Optimise.update!(opt, model_params, grad)
            train_steps += 1
            ℒ += loss
        end
        println("ℒ = $ℒ")
    end
    "Total train steps: $train_steps" |> println

end
data_sample = dl |> first |> device;

enc1 = Dense(d, L1, leakyrelu)
enc2 = Dense(L1, L2, leakyrelu)
dec3 = Dense(L2, L1, leakyrelu)
dec4 = Dense(L1, d)
m = Chain(enc1, enc2, dec3, dec4) |> device
loss(x) = Flux.Losses.mse(m(x), x)
loss(data_sample)
opt = ADAM(η)
ps = Flux.params(m) # parameters
train!(loss, ps, opt, dl, 100)