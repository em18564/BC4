using Flux,Serialization,CSV,DataFrames,StatsBase,Distributions,Plots,Random,StatsFuns,MLDatasets,Flux.Data,CUDA

# custom join layer
struct Join{T, F}
    combine::F
    paths::T
end
  
  # allow Join(op, m1, m2, ...) as a constructor


df     = CSV.read("../../input/dfHierarchical.csv", DataFrame)
dfTags = CSV.read("../../input/full_tags.csv", DataFrame)
PCA_3  = CSV.read("../../input/dfPCA_3.csv", DataFrame)
PCA_4  = CSV.read("../../input/dfPCA_4.csv", DataFrame)
df[!,"tags"] = dfTags[!,"tags"]


dfWord = filter(row -> row.Participant==0, df)[:,"Word"]
dfTags = filter(row -> row.Participant==0, dfTags)
dfTags = dfTags[!,"tags"]
data = Matrix(select(df, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP",:"tags"])))
#data = Matrix(select(df, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP"])))
data_PC3 = Matrix(select(PCA_3, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP",:"PC_1",:"PC_2",:"PC_3",:"PC_4",:"PC_5",:"PC_6"])))
data_PC4 = Matrix(select(PCA_4, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP",:"PC_1",:"PC_2",:"PC_3",:"PC_4",:"PC_5",:"PC_6"])))

device = cpu # where will the calculations be performed?
L1, L2 = 5, 4 # layer dimensions
IL1,IL2,words = 3, 5,11

wtProp = 2
η = 0.01 # learning rate for ADAM optimization algorithm
batch_size = 5000; # batch size for optimization

function lookup(x)
    return findfirst(item -> item == x, dfWord)
end

perm   = shuffle(1:length(data[:,1]))
dataSorted = data[perm,:]

Xtr_l    = transpose(dataSorted[1:2:end,:])
Xtr      = Xtr_l[1:6,:]
Ytr      = indicatormat(Xtr_l[7,:])
Xte_l    = transpose(dataSorted[2:2:end,:])
Xte      = Xte_l[1:6,:]
Yte      = indicatormat(Xte_l[7,:])


function get_data(batch_size)
    d = prod(size(Xtr)[1]) # input dimension
    xtrain1d = reshape(Xtr, d, :) # reshape input as a 784-dimesnonal vector (28*28)
    dl = Flux.DataLoader((data=xtrain1d, label=Ytr), batchsize=batch_size, shuffle=true)
    dl, d
end

dl, d = get_data(batch_size)


function train!(model_loss, model_params, opt, loader, epochs = 1000)
    train_steps = 0
    "Start training for total $(epochs) epochs" |> println
    for epoch = 1:epochs
        print("Epoch $(epoch): ")
        ℒ = 0
        for (x,y) in loader
            loss, back = Flux.pullback(model_params) do
                model_loss(x,y,epoch/epochs |> device)
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

enc1    = Dense(d, L1, leakyrelu)
enc2    = Dense(L1, L2, leakyrelu)
dec3    = Dense(L2, L1, leakyrelu)
dec4    = Dense(L1, d)
m = Chain( Dense(d, L1, leakyrelu),
            Dense(L1, L2, leakyrelu),
                Parallel(vcat,
                    Chain(Dense(L2, L1, leakyrelu) ,Dense(L1, d)),
                    Chain(Dense(L2, IL1, leakyrelu),Dense(IL1, IL2, leakyrelu),Dense(IL2, words, leakyrelu))))

loss(x, y,scale) = (1-scale)*Flux.Losses.mse(m(x)[1:6,:], x) + (scale)*Flux.Losses.mse(m(x)[7:17,:], y) 


opt = ADAM(η)
ps = Flux.params(m) # parameters
train!(loss, ps, opt, dl, 5000)
