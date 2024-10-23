using Word2Vec,CSV,DataFrames,Statistics,Distances,PlotlyJS,Serialization
df   = CSV.read("../Bayes/input/df_WithWords.csv", DataFrame)
df2 = filter(row -> row.Participant<1,df)

io = open("data/df_fullSents.txt", "w") do io

    for i in unique(df2[!,:sent_pos])
        for j in filter(row -> row.sent_pos==i,df2)[!,:realWord]
            print(io,j * " ")
        end
        println(io,"")
    end

end