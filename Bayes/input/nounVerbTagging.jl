# %%
using DataFrames,CSV,StatsBase
using Pkg
Pkg.add("PythonCall")

sent                = CSV.File("sentences.csv", header=false) |> Tables.matrix


df_with_words       = CSV.read("df_WithWords.csv",DataFrame)
words               = df_with_words[df_with_words.Participant.==0,"realWord"]
wordIds             = df_with_words[df_with_words.Participant.==0,"word"]
wordTags            = df_with_words[df_with_words.Participant.==0,"tags"]


restructureArray(wordArray) = [filter((i) -> i != "",[replace(innerword,"." => ""," "=>"") for innerword in split(innersent,",")[2:end]])
                                for innersent in wordArray]

r_sent              = restructureArray(sent)

engSent = [replace(replace(s,",,"=>"@"),","=>" ","@"=>",") for s in sent]


# %%