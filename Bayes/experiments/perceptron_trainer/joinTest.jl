using Flux, CUDA

model = Chain(Dense(3 => 5),
                     Parallel(vcat, Dense(5 => 4), Chain(Dense(5 => 7), Dense(7 => 4))),
                     Dense(8 => 17));