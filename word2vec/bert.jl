using Flux,Transformers
using Transformers.TextEncoders
using Transformers.HuggingFace
textencoder, bert_model = hgf"bert-base-uncased"
text1 = "Peter Piper picked a peck of pickled peppers"
text2 = "Fuzzy Wuzzy was a bear"

text = [[ text1, text2 ]] # 1 batch of contiguous sentences
sample = encode(textencoder, text) # tokenize + pre-process (add special tokens + truncate / padding + one-hot encode)
