using Word2Vec,CSV,DataFrames,Statistics,Distances,PlotlyJS
#word2vec("text8", "text8-vec.txt", verbose=true)
model = wordvectors("text8-vec.txt")
df   = CSV.read("../Bayes/input/df_WithWords.csv", DataFrame)
eq_v(tags::String7)  = tags == "VERB"
eq_n(tags::String7)  = tags == "NOUN"
eq_av(tags::String7) = tags == "ADV"
eq_aj(tags::String7) = tags == "ADJ"
eq_f(tags::String7)  = (tags != "VERB" && tags != "NOUN" && tags != "ADV" && tags != "ADJ")

df_v  = String.(filter(:tags => eq_v,  df)[:,:realWord])
df_n  = String.(filter(:tags => eq_n,  df)[:,:realWord])
df_av = String.(filter(:tags => eq_av, df)[:,:realWord])
df_aj = String.(filter(:tags => eq_aj, df)[:,:realWord])
df_f  = String.(filter(:tags => eq_f,  df)[:,:realWord])

df_uv  = unique(df_v)
df_un  = unique(df_n)
df_uav = unique(df_av)
df_uaj = unique(df_aj)
df_uf  = unique(df_f)

function get_vector_mod(word::String)
    try
        get_vector(model,word)
    catch

    end
end

function getMean(arr)
    vals = get_vector_mod.(arr)
    filter!(x->x!=nothing, vals)
    return mean(vals)
end

m_v  = getMean(df_v)
m_n  = getMean(df_n)
m_av = getMean(df_av)
m_aj = getMean(df_aj)
m_f  = getMean(df_f)

m_uv  = getMean(df_uv)
m_un  = getMean(df_un)
m_uav = getMean(df_uav)
m_uaj = getMean(df_uaj)
m_uf  = getMean(df_uf)

ds1 = [m_aj,m_n,m_v,m_av,m_f]
ds2 = [m_uaj,m_un,m_uv,m_uav,m_uf]
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
o2 = cos_sims(ds2)
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
plot_ds(o2)