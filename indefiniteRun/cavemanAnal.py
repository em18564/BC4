import numpy as np
import matplotlib.pyplot as plt
import sys,math
agents = []
def hammingDistance(a,b):
    output = 0
    for i in range(len(a)):
        if a[i] == b[i]:
            output+=1
    return output
def compareStability(adultAgent,learnerAgent,meaningSpace):
    sum=0
    for m in meaningSpace:
        if(not np.array_equiv(learnerAgent.meaningSignalPairings[tuple(m)],(adultAgent.meaningSignalPairings[tuple(m)]))):
            sum+=1
    return(sum/len(meaningSpace))
def sigmoid(a):
    return 1/(1 + np.exp(-a))

class agent():
    def __init__(self,W1,W2):
        self.W1 = W1
        self.W2 = W2
        self.meaningSignalPairings={}

    def forward(self,s):
        z = np.matmul(s,self.W1)
        h = sigmoid(z)
        v = np.matmul(h,self.W2)
        m = sigmoid(v)
        return z,h,v,m


    def generateObvert(self,signalSpace,meaningSpace):
        _,_,_,PMeanings = self.forward(signalSpace)
        confidence = np.ones((len(meaningSpace),len(signalSpace)))
        meaningSignalPairings = {}
        pairings = []
        uniqueSignals = []
        for m in range(len(meaningSpace)):
            for s in range(len(signalSpace)):
                for i in range(len(meaningSpace[0])):
                    if(meaningSpace[m][i] == 0):
                        confidence[m][s]*=(1-PMeanings[s][i])
                    else:
                        confidence[m][s]*=(PMeanings[s][i])
            signal = signalSpace[np.argmax(confidence[m])]
            meaningSignalPairings[tuple(meaningSpace[m])] = signal
            #print(str(meaningSpace[m]) + " - " + str(meaningSignalPairings[tuple(meaningSpace[m])]))
            if tuple(signal) not in uniqueSignals:
                uniqueSignals.append(tuple(signal))
        self.meaningSignalPairings=meaningSignalPairings
        return len(uniqueSignals)/len(signalSpace)
    def analyseHammingData(self):
        output = 0
        total  = 0
        for pair1 in self.meaningSignalPairings.keys():
            for pair2 in self.meaningSignalPairings.keys():
                if pair1 != pair2:
                    hdM = hammingDistance(pair1,pair2)
                    hdS = hammingDistance(self.meaningSignalPairings[pair1], self.meaningSignalPairings[pair2])
                    if(hdM == hdS):
                        output += 1
                    total += 1
                    #print("Hamming Distance: Meaning: ",hdM," - Signal: ",hdS)

        return output/total




def generate_space(size):
    quantity = np.power(size[1], size[0])
    space    = np.zeros((quantity,size[0]))
    for i in range(quantity):
        for j in range(size[0]):
            scale       = np.power(size[1], (j))
            space[i][j] = int(i / scale) % size[1]
    return space
signalSpace = generate_space((8,2))

meaningSpace = generate_space((8,2))
import seaborn as sns
def calculate_stabilities(stab):
    local_sum=0
    local_tot=0
    out_grp_sum=0
    out_grp_tot=0
    for i in range(30):
        for j in range(30):
            if i != j:
            #print(agents[i].meaningSignalPairings)
                if(math.floor((i)/5)==math.floor((j)/5)):
                    local_sum+=stab[i][j]
                    local_tot+=1
                else:
                    out_grp_sum+=stab[i][j]
                    out_grp_tot+=1

    return local_sum/local_tot,out_grp_sum/out_grp_tot
def performPlotTwo(age):
    agents = []
    string = 'stability' + str(age) + '.csv'
    stabs = np.genfromtxt(string, delimiter=',')

    stabilities = np.zeros((30,30))
    for i in range(len(stabs)):
        for j in range(len(stabs[0])):
            #print(agents[i].meaningSignalPairings)
            stabilities[j%30][int(j/30)] = stabs[i][j]
        print(str((i+1)*100),"-",calculate_stabilities(stabilities))    
        ax = sns.heatmap(stabilities, linewidth=0.5,vmin=0,vmax=1).set(title=(str(age) +"% external communication at step " + str((i+1)*100)))
        sns.color_palette("rocket_r", as_cmap=True)
        plt.xlabel ('Agent ID')
        plt.ylabel ('Agent ID')
        plt.show()

    

def performPlot(age):
    agents = []
    for i in range(25):
        string = str(age)+'.agentW1-' + str(i+1) + '.csv'
        W1 = np.genfromtxt(string, delimiter=',')
        string = str(age)+'.agentW2-' + str(i+1) + '.csv'
        W2 = np.genfromtxt(string, delimiter=',')
        agents.append(agent(W1,W2))
        agents[i].generateObvert(signalSpace,meaningSpace)
        print(agents[i].analyseHammingData())


    stabilities = np.zeros((25,25))


    for i in range(25):
        for j in range(25):
            #print(agents[i].meaningSignalPairings)
            stabilities[i][j] = (compareStability(agents[i],agents[j],meaningSpace))

    np.savetxt('stabilities.csv',stabilities, delimiter=',')




    stabs = np.genfromtxt('stabilities.csv', delimiter=',')

    import seaborn as sns

    ax = sns.heatmap(stabs, linewidth=0.5)
    plt.xlabel ('Agent ID')
    plt.ylabel ('Agent ID')
    plt.show()

# for i in range(200,2001,200):
#     print(i)
#     performPlot(i)
# performPlot(1000)
# performPlot(1200)
# if __name__ == "__main__":
#     performPlotTwo(sys.argv[1])
def getStabs():
    for i in range(11):
        string = 'stability' + str(10+i) + '.csv'
        stabs = np.genfromtxt(string, delimiter=',')

        stabilities = np.zeros((30,30))
        for j in range(len(stabs[0])):
            #print(agents[i].meaningSignalPairings)
            stabilities[j%30][int(j/30)] = stabs[9][j]
        print(i,calculate_stabilities(stabilities))
    
getStabs()