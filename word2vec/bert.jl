using Word2Vec,CSV,DataFrames,Statistics,Distances,PlotlyJS,Serialization
aj = open("data/avg_aj2.txt") do f
    readlines(f) |> (s->parse.(Float64, s))
end
av = open("data/avg_av2.txt") do f
    readlines(f) |> (s->parse.(Float64, s))
end
f = open("data/avg_f2.txt") do f
    readlines(f) |> (s->parse.(Float64, s))
end
n = open("data/avg_n2.txt") do f
    readlines(f) |> (s->parse.(Float64, s))
end
v = open("data/avg_v2.txt") do f
    readlines(f) |> (s->parse.(Float64, s))
end
ds1 = [aj,n,v,av,f]
function cos_sims(data)
    out = zeros(5,5)
    for i in range(1,5)
        for j in range(1,5)
            out[i,j] = cosine_dist(data[i],data[j])  # 1 - dot(x, y) / (norm(x) * norm(y))
        end
    end
    return out
end
o1 = cos_sims(ds1)
types = ["Adjective","Noun","Verb","Adverb","Function"]
function plot_ds(data)
        PlotlyJS.plot([
            PlotlyJS.bar(x=types, y=data[1,:], name="Adjective", marker_color="#3D9970"),
            PlotlyJS.bar(x=types, y=data[2,:], name="Noun", marker_color="#FF4136"),
            PlotlyJS.bar(x=types, y=data[3,:], name="Verb", marker_color="#FF851B"),
            PlotlyJS.bar(x=types, y=data[4,:], name="Adverb", marker_color="#4040FF"),
            PlotlyJS.bar(x=types, y=data[5,:], name="Function", marker_color="#7D0DC3")
            ], Layout(yaxis_title_text="Cosine Distance",barmode="group",font=attr(size=40)))
    end
plot_ds(o1)