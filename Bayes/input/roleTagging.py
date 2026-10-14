
# %%
import spacy
import pandas as pd
import csv

nlp = spacy.load("en_core_web_sm")
nlp2 = spacy.load("en_core_web_lg")
df = pd.read_csv('full_tags.csv')
df_with_words = pd.read_csv('df_with_words_2.csv')
finalDf = pd.read_csv('dfWithTagsReintigrated.csv')
tags = list(df[df.Participant==0].newTags)
words = list(df_with_words[df_with_words.Participant==0].realWord)
# %%

with open('sentences.csv', newline='') as f:
    reader = csv.reader(f)
    data = list(reader)
sentences = []
for sent in data:
    innersent = sent[0]
    innersent = innersent.replace(",,","@")
    innersent = innersent.replace(","," ")
    innersent = innersent.replace("@",", ")
    innersent = innersent.replace(".","")
    sentences.append(innersent)
# %%

baseDict = {
  "ADJ":    0,

  "ADP":    1,

  "ADV":    2,

  
  "SCONJ":  3,
  "CCONJ":  3,

  "DET":    4,

  
  "PROPN":  5,
  "NOUN":   5,

  "NUM":    6,

  "PRON":   7,

  "PART":   8,

  
  "AUX":    9,
  "VERB":   9,
}

nounAdditionalDict = {
  "S":      1,
  "D":      2,
  "ID":     3,
  "PREP":   4,
  "ADVMOD": 5
}

adpAdditionalDict = {
    10:     1,
    "A":    1,

    11:     2,
    "S":    2,
    
    12:     3,
    "D":    3,

    13:     4,
    "F":    4
}
inv_baseDict = {v: k for k, v in baseDict.items()}
inv_nounAdditionalDict = {v: k for k, v in nounAdditionalDict.items()}
inv_nounAdditionalDict[0] = "NotFound"
inv_adpAdditionalDict = {v: k for k, v in adpAdditionalDict.items()}
inv_adpAdditionalDict[0] = "NotFound"
inv_detAdditionalTags = {0: "NotFound",
                         1: "S",
                         2: "D",
                         3: "ID",
                         4: "PREP",
                         5: "ADVMOD"}
maxLen = 15
def matchNounVal(tok,doc,j,prevNoun):
    match (tok):
        case "nsubj":
            return "S"
        case "nsubjpass":
            return "S"
        case "attr":
            return "S"
        case "dep":
            return "S"
        
        case "dobj":
            return "D"
        case "oprd":
            return "D"
        
        case "dative":
            return "ID"
        case "pobj":
            return "PREP"
        case "appos":
            return "PREP"
        case "advmod":
            return "ADVMOD"
        case "npadvmod":
            return "ADVMOD"

        case "conj":
            return prevNoun
        case "poss":
            token = doc[j+1]
            return matchNounVal(token.dep_,doc,j+1,prevNoun)
        case "compound":
            token = doc[j+1]
            return matchNounVal(token.dep_,doc,j+1,prevNoun)
        case "case":
            token = doc[j+1]
            return matchNounVal(token.dep_,doc,j+1,prevNoun)
        case _:
            print("NOT FOUND: ",tok)

def addTagDetails(tag,finalDf,counter):
    match tag:
        case "NOUN":
            return tag + " (" + inv_nounAdditionalDict[finalDf.nounTags[counter]] +")"
        case "ADP":
            return tag + " (" + inv_adpAdditionalDict[finalDf.adpTags[counter]] +")"
        case "DET":
            return tag + " (" + inv_detAdditionalTags[finalDf.detTags[counter]] +")"
        case _:
            return tag

counter = 0
newtags = tags
prevNoun = ""
baseTags = []
nounTags = []
adpTags  = []
words    = []
for sent in sentences: 
    splitSent = sent.split()
    doc  = nlp2(sent)
    offset = 0
    tagSentOld = ' ' * (maxLen+1)
    tagSentNew = ' ' * (maxLen+1)
    print('(',splitSent[0],')', ' ' *(maxLen-len(splitSent[0])-2), end=' ',sep='')
    for i in range(1,len(splitSent)):
        j = i+offset
        found = False
        while(not found):
            token =doc[j]
            if splitSent[i].startswith(token.text) or token.text.startswith(splitSent[i]):
                print(splitSent[i],' ' *(maxLen-len(splitSent[i])), end=' ',sep='') #token.pos_, token.tag_, token.dep_,
                baseTags.append(baseDict[token.pos_])
                # if(token.pos_ =="NOUN") or (token.pos_ =="PROPN"):
                #     prevNoun = matchNounVal(token.dep_,doc,j,prevNoun)
                #     nounTags.append(nounAdditionalDict[prevNoun])
                # else:
                #     nounTags.append(0)
                # if(token.pos_ =="ADP"):
                #     ans = ""
                #     while (ans != "A") & (ans != "S") & (ans != "D") & (ans != "F"):
                #         print("(A) Lexical: prepositions used for location and time in English")
                #         print("  e.g: Nina put the book *on/under/at/next* to DP the table.")
                #         print()
                #         print("(S) Subcategorised: grammaticized, collocative, non-lexical or dependent")
                #         print("  e.g: Everyone picked *on* the new student.")
                #         print()
                #         print("(D) Syntactic:  possessive *of*, passive *by*")
                #         print("  e.g: The younger children are assisted *by* their teachers.")
                #         print()
                #         print("(F) PARTICLE")
                #         print("(A) Lexical, (S) Subcategorised, (D) Syntactic or (F) Unsure")
                #         print()
                #         print(" ".join(splitSent[0:i]),"*",splitSent[i],"*"," ".join(splitSent[i+1:]))
                #         ans = input()
                #         print(ans)
                #     adpTags.append(adpAdditionalDict[ans])
                            
                # else:
                #     adpTags.append(0)
                tag1 = inv_baseDict[finalDf.tags[counter]]
                tag2 = inv_baseDict[finalDf.newBaseTags[counter]]
                tag1 = addTagDetails(tag1,finalDf,counter)
                tag2 = addTagDetails(tag2,finalDf,counter)
                tagSentOld += tag1 +' ' *(1+maxLen-len(tag1))
                tagSentNew += tag2 +' ' *(1+maxLen-len(tag2))
                found = True
                words.append(splitSent[i])
                counter+=1
            else:
                offset+=1
            j+=1
    print()
    print(tagSentOld)
    print(tagSentNew)
    
    print("\n")

# %%
with open("baseTags.csv", 'w', newline='') as myfile:
     wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
     wr.writerow(baseTags)
# %%
with open("nounTags.csv", 'w', newline='') as myfile:
     wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
     wr.writerow(nounTags)
with open("adpTags.csv", 'w', newline='') as myfile:
     wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
     wr.writerow(adpTags)
# %%
df = pd.DataFrame({"nounTags":nounTags})
df.to_csv("fixedNouns.csv",index=False, header=True)

# %%
df = pd.DataFrame({"baseTags":baseTags,"nounTags":nounTags,"adpTags":adpTags})
df.to_csv("fixedDF2.csv",index=False, header=True)

# %%
