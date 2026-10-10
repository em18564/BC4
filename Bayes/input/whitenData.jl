# %%
import Pkg
Pkg.instantiate()
using Random
using Distributions
using Turing
using CSV
using DataFrames
using Serialization
using LinearAlgebra
using StatsBase
using StatsFuns
using Logging
using Plots
using PlotlyJS
using Images, FileIO
using Measures


# %%
dfTags   = CSV.read("full_tags.csv", DataFrame).newTags
df       = CSV.read("dfPCANorm_corrected_6.csv", DataFrame)
df.fullTag = dfTags
df.fullTagDetSplit = dfTags
#df.Participant.+=1
# %%
for rowId in range(2,size(df)[1])
    if (df[rowId,"fullTag"]==4 && df[rowId-1,"fullTag"]==9 && df[rowId,"Wordpos"]>df[rowId-1,"Wordpos"])
        df[rowId,"fullTagDetSplit"] = 20
    end
end
# %%
CSV.write("dfPCANorm_corrected_6_WithDetSplit.csv",df)


# %%
sent                = CSV.File("sentences.csv", header=false) |> Tables.matrix
df_with_words       = CSV.read("df_WithWords.csv",DataFrame)
words               = df_with_words[df_with_words.Participant.==0,"realWord"]
wordIds             = df_with_words[df_with_words.Participant.==0,"word"]
wordTags            = df_with_words[df_with_words.Participant.==0,"tags"]


restructureArray(wordArray) = [filter((i) -> i != "",[replace(innerword,"." => ""," "=>"") for innerword in split(innersent,",")[1:end]])
                                for innersent in wordArray]

r_sent              = restructureArray(sent)
OnePartDF = subset(df,:Participant => ByRow(==(0)))
sentenceId  = 1
innerWordId = 1
sentenceBuilder = ""
foundDetSentence = false
wordIds = Int.(OnePartDF.Word)
fullsentences = []
for wordId in eachindex(wordIds)[2:length(OnePartDF.Word)]
    
    if ((wordIds[wordId]-wordIds[wordId-1]) > 1)
        if foundDetSentence
            fullsentences = vcat(fullsentences,sentenceBuilder)
        end
        sentenceId  +=1
        innerWordId = 1
        sentenceBuilder = "("*r_sent[sentenceId][innerWordId] * ") "
        foundDetSentence = false
    end
    if OnePartDF.fullTagDetSplit[wordId] == 4
        sentenceBuilder = sentenceBuilder * "*" * (r_sent[sentenceId][innerWordId+1] * "* ")
        foundDetSentence = true
    elseif OnePartDF.fullTagDetSplit[wordId] == 20
        sentenceBuilder = sentenceBuilder * "{" * (r_sent[sentenceId][innerWordId+1] * "} ")
        foundDetSentence = true
    else
        sentenceBuilder = sentenceBuilder * (r_sent[sentenceId][innerWordId+1] * " ")
    end

    

    innerWordId+=1
end
# %%

CSV.write("determinerSentences.csv",Tables.table(string.(fullsentences)), header=false)