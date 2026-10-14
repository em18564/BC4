using ColorSchemes
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
    elseif(TYPE_STRUCTURE == "FullCFAdp")
        NUM_TYPES = 6
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
                subset(df_modified, :fullTag => ByRow((==(12)))),
                subset(df_modified, :fullTag => ByRow((==(13)))),
                subset(df_modified, :fullTag => ByRow((==(8)))),
                subset(df_modified, :fullTag => ByRow((==(3)))))
        f.fullTag .= 4
        lexAdp = subset(df_modified, :fullTag => ByRow((==(11))))
        lexAdp.fullTag .= 5
        df_modified = vcat(adj,noun,verb,adv,f,lexAdp)
        wordTypes = ["Adjective","Noun","Verb","Adverb","Function", "Lexical Adposition"]
        cols = [palette(:tab10)[i] for i in range(1,6)]
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
    elseif(TYPE_STRUCTURE == "CFAdp")
        c = vcat( subset(df_modified, :fullTag => ByRow((==(0)))),
          subset(df_modified, :fullTag => ByRow((==(5)))),
          subset(df_modified, :fullTag => ByRow((==(9)))),
          subset(df_modified, :fullTag => ByRow((==(11)))),
          subset(df_modified, :fullTag => ByRow((==(2)))))
        f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(1)))),

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
        NUM_TYPES = 10
        wordTypes = ["Adjective","Adverb",
                        "Conjunction","Determiner","Noun","Numeral", 
                        "Pronoun","Particle","Verb","Adposition"]
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
        adp2.fullTag.=9
        adp3.fullTag.=9

        df_modified = vcat(words,vcat(adp1,adp2,adp3))
        cols = [palette(:default)[i] for i in range(1,NUM_TYPES)]

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

    elseif(TYPE_STRUCTURE == "FullTwoADP")
        NUM_TYPES = 11
        wordTypes = ["Adjective","Adverb",
                        "Conjunction","Determiner","Noun","Numeral", 
                        "Pronoun","Particle","Verb","Adposition (lex)", "Adposition (other)"]
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
        adp3.fullTag.=10

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
    elseif(TYPE_STRUCTURE == "NoNum")
        NUM_TYPES = 11
        wordTypes = ["Adjective","Adverb",
                        "Conjunction","Determiner","Noun",
                        "Pronoun","Particle","Verb","Adposition (lex)", "Adposition (sub)", "Adposition (syn)"]
        df_modified.fullTag.= max.(df_modified.fullTag.-1,0)
        wordsPreNum= vcat(  subset(df_modified, :fullTag => ByRow((==(0)))),
                            subset(df_modified, :fullTag => ByRow((==(1)))),
                            subset(df_modified, :fullTag => ByRow((==(2)))),
                            subset(df_modified, :fullTag => ByRow((==(3)))),
                            subset(df_modified, :fullTag => ByRow((==(4)))))

        wordsPostNum= vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                            subset(df_modified, :fullTag => ByRow((==(7)))),
                            subset(df_modified, :fullTag => ByRow((==(8)))))
        
        wordsPostNum.fullTag = wordsPostNum.fullTag.-1

        adp1  = subset(df_modified, :fullTag => ByRow((==(10))))
        adp2  = subset(df_modified, :fullTag => ByRow((==(11))))
        adp3  = subset(df_modified, :fullTag => ByRow((==(12))))

        adp1.fullTag.=8
        adp2.fullTag.=9
        adp3.fullTag.=10

        df_modified = vcat(wordsPreNum,wordsPostNum,adp1,adp2,adp3)
        cols = [palette(:default)[i] for i in range(1,NUM_TYPES)]
    elseif(TYPE_STRUCTURE == "detSplit")
        NUM_TYPES = 12
        wordTypes = ["Adjective","Adverb",
                        "Conjunction","Determiner","Noun",
                        "Pronoun","Particle","Verb","Adposition (lex)", "Adposition (sub)", "Adposition (syn)","Determiner (following verb)"]
        df_modified.fullTag.= max.(df_modified.fullTag.-1,0)
        wordsPreNum= vcat(  subset(df_modified, :fullTag => ByRow((==(0)))),
                            subset(df_modified, :fullTag => ByRow((==(1)))),
                            subset(df_modified, :fullTag => ByRow((==(2)))),
                            subset(df_modified, :fullTag => ByRow((==(3)))),
                            subset(df_modified, :fullTag => ByRow((==(4)))))

        wordsPostNum= vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                            subset(df_modified, :fullTag => ByRow((==(7)))),
                            subset(df_modified, :fullTag => ByRow((==(8)))))
        
        wordsPostNum.fullTag = wordsPostNum.fullTag.-1

        adp1  = subset(df_modified, :fullTag => ByRow((==(10))))
        adp2  = subset(df_modified, :fullTag => ByRow((==(11))))
        adp3  = subset(df_modified, :fullTag => ByRow((==(12))))

        detFolVerb  = subset(df_modified, :fullTag => ByRow((==(20))))
        adp1.fullTag.=8
        adp2.fullTag.=9
        adp3.fullTag.=10
        detFolVerb.fullTag.= 11

        df_modified = vcat(wordsPreNum,wordsPostNum,adp1,adp2,adp3,detFolVerb)
        cols = [palette(:default)[i] for i in range(1,NUM_TYPES)]
    
    elseif(TYPE_STRUCTURE == "NounDetSplit_Old")
        wordTypes = [   "Adjective",            "Adverb",                   "Conjunction",                  "Numeral",                  "Pronoun",
                        "Particle",             "Verb",
                        "Adposition (lex)",     "Adposition (sub)",         "Adposition (syn)",
                        "Determiner (Subject)", "Determiner (D-Object)",    "Determiner (ID-Object)",
                        "Noun (Subject)",       "Noun (D-Object)",          "Noun (ID-Object)",]

        NUM_TYPES   = length(wordTypes)

        Adjective   = subset(df_modified, :fullTag => ByRow((==(0))))
        Adverb      = subset(df_modified, :fullTag => ByRow((==(2))))
        Conjunction = subset(df_modified, :fullTag => ByRow((==(3))))
        Numeral     = subset(df_modified, :fullTag => ByRow((==(6))))
        Pronoun     = subset(df_modified, :fullTag => ByRow((==(7))))
        Particle    = subset(df_modified, :fullTag => ByRow((==(8))))
        Verb        = subset(df_modified, :fullTag => ByRow((==(9))))

        adp1        = subset(df_modified, :fullTag => ByRow((==(10))))
        adp2        = subset(df_modified, :fullTag => ByRow((==(11))))
        adp3        = subset(df_modified, :fullTag => ByRow((==(12))))


        Determiner  = subset(df_modified, :fullTag => ByRow((==(4))))

        det1        = subset(Determiner, :detTags => ByRow((==(1))))
        det2        = subset(Determiner, :detTags => ByRow((==(2))))
        det3        = vcat( subset(Determiner, :detTags => ByRow((==(3)))),
                            subset(Determiner, :detTags => ByRow((==(4)))))

        Noun        = subset(df_modified, :fullTag => ByRow((==(5))))

        noun1       = subset(Noun, :nounTags => ByRow((==(1))))
        noun2       = subset(Noun, :nounTags => ByRow((==(2))))
        noun3       = vcat( subset(Noun, :nounTags => ByRow((==(3)))),
                            subset(Noun, :nounTags => ByRow((==(4)))))



        Adjective.fullTag   .= 0
        Adverb.fullTag      .= 1
        Conjunction.fullTag .= 2
        Numeral.fullTag     .= 3
        Pronoun.fullTag     .= 4
        Particle.fullTag    .= 5
        Verb.fullTag        .= 6
        adp1.fullTag        .= 7
        adp2.fullTag        .= 8
        adp3.fullTag        .= 9
        det1.fullTag        .= 10
        det2.fullTag        .= 11
        det3.fullTag        .= 12
        noun1.fullTag       .= 13
        noun2.fullTag       .= 14
        noun3.fullTag       .= 15



        df_modified = vcat(
            Adjective,Adverb,Conjunction,Numeral,Pronoun,Particle,Verb,
            adp1,adp2,adp3,
            det1,det2,det3,
            noun1,noun2,noun3)
        cols = [palette(ColorSchemes.viridis, NUM_TYPES)[i] for i in range(1,NUM_TYPES)]

    elseif(TYPE_STRUCTURE == "NounDetSplit_New")
        wordTypes = [   "Adjective",            "Adverb",                   "Conjunction",                  "Numeral",                  "Pronoun",
                        "Particle",             "Verb",
                        "Adposition (lex)",     "Adposition (sub)",         "Adposition (syn)", "Adposition (Adverbial)",
                        "Determiner (Subject)", "Determiner (D-Object)",    "Determiner (ID-Object)",
                        "Noun (Subject)",       "Noun (D-Object)",          "Noun (ID-Object)",]

        NUM_TYPES   = length(wordTypes)

        Adjective   = subset(df_modified, :newBaseTags => ByRow((==(0))))
        Adverb      = subset(df_modified, :newBaseTags => ByRow((==(2))))
        Conjunction = subset(df_modified, :newBaseTags => ByRow((==(3))))
        Numeral     = subset(df_modified, :newBaseTags => ByRow((==(6))))
        Pronoun     = subset(df_modified, :newBaseTags => ByRow((==(7))))
        Particle    = subset(df_modified, :newBaseTags => ByRow((==(8))))
        Verb        = subset(df_modified, :newBaseTags => ByRow((==(9))))

        Adposition  = subset(df_modified, :newBaseTags => ByRow((==(1))))

        adp1        = subset(Adposition, :adpTags => ByRow((==(1))))
        adp2        = subset(Adposition, :adpTags => ByRow((==(2))))
        adp3        = subset(Adposition, :adpTags => ByRow((==(3))))
        adp4        = subset(Adposition, :adpTags => ByRow((==(4))))


        Determiner  = subset(df_modified, :newBaseTags => ByRow((==(4))))

        det1        = subset(Determiner, :detTags => ByRow((==(1))))
        det2        = subset(Determiner, :detTags => ByRow((==(2))))
        det3        = vcat( subset(Determiner, :detTags => ByRow((==(3)))),
                            subset(Determiner, :detTags => ByRow((==(4)))))

        Noun        = subset(df_modified, :newBaseTags => ByRow((==(5))))

        noun1       = subset(Noun, :nounTags => ByRow((==(1))))
        noun2       = subset(Noun, :nounTags => ByRow((==(2))))
        noun3       = vcat( subset(Noun, :nounTags => ByRow((==(3)))),
                            subset(Noun, :nounTags => ByRow((==(4)))))



        Adjective.fullTag   .= 0
        Adverb.fullTag      .= 1
        Conjunction.fullTag .= 2
        Numeral.fullTag     .= 3
        Pronoun.fullTag     .= 4
        Particle.fullTag    .= 5
        Verb.fullTag        .= 6
        adp1.fullTag        .= 7
        adp2.fullTag        .= 8
        adp3.fullTag        .= 9
        adp4.fullTag        .= 10
        det1.fullTag        .= 11
        det2.fullTag        .= 12
        det3.fullTag        .= 13
        noun1.fullTag       .= 14
        noun2.fullTag       .= 15
        noun3.fullTag       .= 16



        df_modified = vcat(
            Adjective,Adverb,Conjunction,Numeral,Pronoun,Particle,Verb,
            adp1,adp2,adp3,adp4,
            det1,det2,det3,
            noun1,noun2,noun3)
        cols = [palette(ColorSchemes.viridis, NUM_TYPES)[i] for i in range(1,NUM_TYPES)]

    elseif(TYPE_STRUCTURE == "NewTags")
        wordTypes = [   "Adjective",            "Adverb",                   "Conjunction",                  "Numeral",                  "Pronoun",
                        "Particle",             "Verb",
                        "Adposition (lex)",     "Adposition (sub)",         "Adposition (syn)", "Adposition (Adverbial)",
                        "Determiner",
                        "Noun"]

        NUM_TYPES   = length(wordTypes)

        Adjective   = subset(df_modified, :newBaseTags => ByRow((==(0))))
        Adverb      = subset(df_modified, :newBaseTags => ByRow((==(2))))
        Conjunction = subset(df_modified, :newBaseTags => ByRow((==(3))))
        Numeral     = subset(df_modified, :newBaseTags => ByRow((==(6))))
        Pronoun     = subset(df_modified, :newBaseTags => ByRow((==(7))))
        Particle    = subset(df_modified, :newBaseTags => ByRow((==(8))))
        Verb        = subset(df_modified, :newBaseTags => ByRow((==(9))))

        Adposition  = subset(df_modified, :newBaseTags => ByRow((==(1))))

        adp1        = subset(Adposition, :adpTags => ByRow((==(1))))
        adp2        = subset(Adposition, :adpTags => ByRow((==(2))))
        adp3        = subset(Adposition, :adpTags => ByRow((==(3))))
        adp4        = subset(Adposition, :adpTags => ByRow((==(4))))


        Determiner  = subset(df_modified, :newBaseTags => ByRow((==(4))))

        Noun        = subset(df_modified, :newBaseTags => ByRow((==(5))))



        Adjective.fullTag   .= 0
        Adverb.fullTag      .= 1
        Conjunction.fullTag .= 2
        Numeral.fullTag     .= 3
        Pronoun.fullTag     .= 4
        Particle.fullTag    .= 5
        Verb.fullTag        .= 6
        adp1.fullTag        .= 7
        adp2.fullTag        .= 8
        adp3.fullTag        .= 9
        adp4.fullTag        .= 10
        Determiner.fullTag  .= 11
        Noun.fullTag        .= 12




        df_modified = vcat(
            Adjective,Adverb,Conjunction,Numeral,Pronoun,Particle,Verb,
            adp1,adp2,adp3,adp4,
            Determiner,
            Noun)
        cols = [palette(ColorSchemes.viridis, NUM_TYPES)[i] for i in range(1,NUM_TYPES)]

    else()
        throw("Illegal type structure")
    end


    return NUM_TYPES,df_modified,wordTypes,cols
end



