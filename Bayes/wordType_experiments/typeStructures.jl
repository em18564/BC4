
# 0 Adj
# 1 Adp
# 2 Adv
# 3 Conj
# 4 Det
# 5 Noun
# 6 Num
# 7 Pron
# 8 Prt
# 9 Verb
# 10 X


function processTypeStructure(df_modified,TYPE_STRUCTURE)
    if(TYPE_STRUCTURE == "FullCF")
        NUM_TYPES = 5
        adj = subset(df_modified, :fullTag => ByRow((==(0))))
        adj.fullTag .= 0
        noun = subset(df_modified, :fullTag => ByRow((==(5))))
        noun.fullTag .= 1
        verb = subset(df_modified, :fullTag => ByRow((==(9))))
        verb.fullTag .= 2
        adv = subset(df_modified, :fullTag => ByRow((==(2))))
        adv.fullTag .= 3
        f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(1)))),
                subset(df_modified, :fullTag => ByRow((==(11)))),
                subset(df_modified, :fullTag => ByRow((==(12)))),
                subset(df_modified, :fullTag => ByRow((==(13)))),
                subset(df_modified, :fullTag => ByRow((==(8)))),
                subset(df_modified, :fullTag => ByRow((==(3)))))
        f.fullTag .= 4
        df_modified = vcat(adj,noun,verb,adv,f)
        wordTypes = ["Adjective","Noun","Verb","Adverb","Function"]
        cols = [palette(:tab10)[i] for i in range(1,5)]
    elseif(TYPE_STRUCTURE == "CF")
        c = vcat( subset(df_modified, :fullTag => ByRow((==(0)))),
          subset(df_modified, :fullTag => ByRow((==(5)))),
          subset(df_modified, :fullTag => ByRow((==(9)))),
          subset(df_modified, :fullTag => ByRow((==(2)))))
        f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(1)))),
                subset(df_modified, :fullTag => ByRow((==(11)))),
                subset(df_modified, :fullTag => ByRow((==(12)))),
                subset(df_modified, :fullTag => ByRow((==(13)))),
                subset(df_modified, :fullTag => ByRow((==(8)))),
                subset(df_modified, :fullTag => ByRow((==(3)))))
        c.fullTag .= 0
        f.fullTag .= 1
        df_modified = vcat(c,f)
        NUM_TYPES = 2
        wordTypes = ["Content","Function"]
        cols = ["#3D9970", "#7D0DC3"]
    elseif(TYPE_STRUCTURE == "Full")

        throw("need to reimpliment")


    elseif(TYPE_STRUCTURE == "FullADP")
        NUM_TYPES = 12
        wordTypes = ["Adjective","Adverb",
                        "Conjunction","Determiner","Noun","Numeral", 
                        "Pronoun","Particle","Verb","Adposition (lex)", "Adposition (sub)", "Adposition (syn)"]
        df_modified.fullTag.= max.(df_modified.fullTag.-1,0)
        words = vcat(   subset(df_modified, :fullTag => ByRow((==(0)))),
                        subset(df_modified, :fullTag => ByRow((==(1)))),
                        subset(df_modified, :fullTag => ByRow((==(2)))),
                        subset(df_modified, :fullTag => ByRow((==(3)))),
                        subset(df_modified, :fullTag => ByRow((==(4)))),
                        subset(df_modified, :fullTag => ByRow((==(5)))),
                        subset(df_modified, :fullTag => ByRow((==(6)))),
                        subset(df_modified, :fullTag => ByRow((==(7)))),
                        subset(df_modified, :fullTag => ByRow((==(8)))))

        adp1  = subset(df_modified, :fullTag => ByRow((==(10))))
        adp2  = subset(df_modified, :fullTag => ByRow((==(11))))
        adp3  = subset(df_modified, :fullTag => ByRow((==(12))))

        adp1.fullTag.=9
        adp2.fullTag.=10
        adp3.fullTag.=11

        df_modified = vcat(words,adp1,adp2,adp3)
        cols = [palette(:default)[i] for i in range(1,NUM_TYPES)]

    elseif(TYPE_STRUCTURE == "DendroCustom")
        NUM_TYPES = 4

        noun = subset(df_modified, :fullTag => ByRow((==(5))))
        noun.fullTag .= 0

        numeral = subset(df_modified, :fullTag => ByRow((==(6))))
        numeral.fullTag .= 1

        verbadp = vcat( subset(df_modified, :fullTag => ByRow((==(9)))),
                        subset(df_modified, :fullTag => ByRow((==(1)))),
                        subset(df_modified, :fullTag => ByRow((==(11)))),
                        subset(df_modified, :fullTag => ByRow((==(12)))),
                        subset(df_modified, :fullTag => ByRow((==(13)))))
        verbadp.fullTag .= 2

        f = vcat( subset(df_modified, :fullTag => ByRow((==(0)))),
                subset(df_modified, :fullTag => ByRow((==(2)))),
                subset(df_modified, :fullTag => ByRow((==(3)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(8)))))
        f.fullTag .= 3
        df_modified = vcat(noun,numeral,verbadp,f)
        wordTypes = ["Noun","Numeral","Verb/Adposition","NewFunction"]
        cols = [palette(:tab10)[i] for i in range(1,4)]
    else()
        throw("Illegal type structure")
    end


    return NUM_TYPES,df_modified,wordTypes,cols
end



