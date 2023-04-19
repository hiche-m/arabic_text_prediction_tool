import codecs
import re
import os
import json
from collections import defaultdict, Counter
import argparse

def addPadding(result, padding, maxRow):    #Emettre un padding dans un vecteur 2D
    for i, row in enumerate(result):
        if len(row)<maxRow:
            if padding == "Pre":
                result[i] = [0]*(maxRow-len(row)) + row
            elif padding == "Post":
                result[i].extend([0]*(maxRow-len(row)))
            else:
                print("Invalid padding value")
    return result

def sequence(data, tokenizer, padding, recurrent, running=False, oov=False):    #Créer des séquences NGrams et/ou convertir les Strings au tokens
    result = []
    maxRow = 0
    for row in data:
        temp = []
        if not running:
          for word in row:
              temp.append(tokenizer[word.lower()])
        else:
          for word in row:
              if word.lower() not in tokenizer and oov:
                temp.append(tokenizer['<OOV>'])
              elif word.lower() in tokenizer:
                temp.append(tokenizer[word.lower()])
        result.append(temp)
        if len(temp)>maxRow: maxRow = len(temp)

    recount = 0
    resultBak = result.copy()
    for i, row in enumerate(resultBak):
        if len(row)==0:
            result.pop(i-recount)
            recount+=1
    
    maxRow=0
    for row in result:
        if maxRow<len(row):
            maxRow=len(row)

    recurrent_sequences = []
    if recurrent:
        for j, row in enumerate(result):
            temp = []
            for i in range(0, len(row)):
                NGram = result[j][:i+1]
                temp.append(NGram)
            recurrent_sequences.extend(temp)
          
        recurrent_sequences = addPadding(recurrent_sequences, padding, maxRow) if padding != 'None' else recurrent_sequences
    else:
        for j, row in enumerate(result):
            recurrent_sequences.extend(row)
          
        recurrent_sequences = addPadding(recurrent_sequences, padding, maxRow) if padding != 'None' else recurrent_sequences
  
    result = addPadding(result, padding, maxRow) if padding != 'None' else result

    return result, recurrent_sequences

def tokenize(path, ar, padding="None", recurrent=False, oov=True, running=False, corpus={}):    #Lire un fichier/String et lui préparer pour traitement
    num_row=0
    num_word=0
    data=[]
    stats=[]
    romanLNReg = r"[^a-zA-Z0-9]+"
    arabicLNReg = r'[^\u0621-\u064A0-9]+'
    reg = arabicLNReg if ar else romanLNReg
    tokenizer = {"<OOV>" : 1} if oov else {}
    id_word = 2 if oov else 1
    if type(path) is str:
      with codecs.open(path, "r", encoding="utf-8") as f:
        fil = [line for line in f]
    else:
      fil = path
    for row in fil:
        num_row+=1
        pattern = re.compile(reg)
        my_string = pattern.sub(' ', row)
        words = my_string.strip().split()
        if not running:
          for word in words:
              if word.lower() not in tokenizer:
                  tokenizer[word.lower()] = id_word
                  id_word+=1
        else:
          tokenizer = corpus
        num_word_row = len(words)
        num_word+=num_word_row
        data.append(words)
        if num_word_row!=0: stats.append(num_word_row)
    if not running: print("Total number of rows: ",num_row,"\nTotal number of words: ",num_word)

    result, reseq = sequence(data, tokenizer, padding, recurrent, running, oov)

    return {"vocabulary":tokenizer, "sequences": result, "stats": stats, "data": data, "reseq": reseq}

def tokenToString(sequence, vocabulary): return [list(vocabulary.keys())
      [list(vocabulary.values()).index(seq)] for seq in sequence]

def getTopN(data, n, vocabulary):
    flat_list = [num for sublist in data for num in sublist]

    number_counts = Counter(flat_list)
    top_n = number_counts.most_common()[:n]

    frequencies = [x[1] for x in top_n]
    labels = tokenToString([x[0] for x in top_n], vocabulary)

    return [[labels[i], frequencies[i]] for i in range(len(top_n))]

def searchSeq(data, sequence):  #Fonction de recherche
    indices = []
    seq_len = len(sequence)
    for i, sublist in enumerate(data):
        for j in range(len(sublist) - seq_len + 1):
            if sublist[j:j + seq_len] == sequence:
                indices.append((i, j))
    return indices  #Retourne une liste des indices ou la séquence de mots ou bien le mot est trouvé

def getOdds(query, sequences, vocabulary):
    newTokenizer = tokenize(path=[query], ar=True, corpus=vocabulary, running=True)
    seqs = newTokenizer['sequences'][0]
    occurs = searchSeq(sequences, seqs)

    if len(occurs)==0 and len(seqs)>1:
        words = query.split()
        query = " ".join(words[1:])
        return getOdds(query, sequences)

    words = defaultdict(int)
    words_gen = []
    for index in occurs:
        if len(sequences[index[0]]) > index[1] + len(seqs):
            word = sequences[index[0]][index[1] + len(seqs)]
            words_gen.append(word)

    for word in words_gen:
        words[word] += 1
    words = dict(sorted(words.items(), key=lambda item: item[1], reverse=True))
    return words

def nextWord(query, sequences, num_words, vocabulary, n):
    tokens = getOdds(query, sequences, vocabulary)
    #next = tokenToString([[key for key in tokens.keys()][0]], vocabulary)
    
    next = tokenToString(list(tokens.keys())[:n], vocabulary)

    #query += " " + " ".join(next)
    if num_words>1:
        return nextWord(query, sequences, num_words-1, vocabulary, n)
    else: return next



def run(command):
    if command["cmd"]==0:
        inputD = command["input"]

        if not os.path.isfile(inputD["path"]):
            return {"error": "File not found"}

        tokenizer = tokenize(inputD["path"], ar=True)
        
        vocabulary = tokenizer['vocabulary']
        sequences = tokenizer['sequences']

        query = bytes(inputD["query"], 'utf-8').decode('unicode_escape')
        result = nextWord(query, sequences, inputD["num"], vocabulary, inputD["filtre"])

        return {"result": result}
    
    elif command["cmd"]==1:
        inputD = command["input"]
        if not os.path.isfile(inputD["path"]):
            return {"error": "File not found"}
        
        tokenizer = tokenize(inputD["path"], ar=True)

        stats = tokenizer['stats']
        result = {"stats":stats}

        return {"result": result}
    
    elif command["cmd"]==2:
        inputD = command["input"]
        if not os.path.isfile(inputD["path"]):
            return {"error": "File not found"}

        tokenizer = tokenize(inputD["path"], ar=True)
        
        vocabulary = tokenizer['vocabulary']
        sequences = tokenizer['sequences']

        return getTopN(sequences, inputD["num"], vocabulary)
    
    else:
        return {'Error':'Command not found.'}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--uuid")
    args = parser.parse_args()
    stream_start = f"`S`T`R`E`A`M`{args.uuid}`S`T`A`R`T`"
    stream_end = f"`S`T`R`E`A`M`{args.uuid}`E`N`D`"
    while True:
        cmd = input()
        cmd = json.loads(cmd)
        try:
            result = run(cmd)
        except Exception as e:
            result = {"exception": e.__str__()}
        result = json.dumps(result)
        print(stream_start + result + stream_end)