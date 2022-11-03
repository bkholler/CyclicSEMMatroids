import sys
import numpy as np
import functools
import operator
import gc


class Graph:
    
    def __init__(self, p:int, l:list):
        '''
        p: number of nodes
        l: a list indicating the position of edges, only upper traingular part. For i<j, l[(i-1)*p+j-1] = 1 means i->j and -1 means j->i
        '''
        if len(l) != p*(p-1)//2:
            raise ValueError('Non compatible input!')
        
        # u/l triangular indices
        ind_u = np.triu_indices(p, k=1)
        ind_l = np.tril_indices(p, k=-1)
        mg = np.zeros((p, p)).astype(int)
        mg[ind_u] = l
        mg[mg < 0] = -1
        mg[mg > 0] = 1
        #mg = np.clip(mg, 0, 1)
        mg = mg + mg.T
        mg[ind_u] = mg[ind_u] > 0
        mg[ind_l] = mg[ind_l] < 0
        self._mg = mg.copy()
        
        self._out = [sum(mg[i,:]) for i in range(p)]
    
    def _closure(self, i, j):
        # find the parental closure containing j, j in ch(i)
        stack = [j]
        res = set([j])
        while (len(stack) > 0):
            node = stack.pop()
            for k in range(len(self._mg)):
                if self._mg[k,j] and self._mg[i,k]+self._mg[k,i]:
                    if not k in res:
                        res.add(k)
                        stack.append(k)
        return res
    
    #@property
    def pclosure(self, i:int):
        unvisited = set(range(len(self._mg)))
        unvisited -= {i}
        res = []
        for j in range(len(self._mg)):
            if self._mg[i,j] and j in unvisited:
                tmp = self._closure(i, j)
                #to remove replicate?
                if tmp not in res:
                    res.append(tmp)
                #unvisited -= tmp
                unvisited -= {j}
        #return res
        return res
    
    @property
    def mg(self):
        return self._mg
    
    @property
    def out(self):
        # outdegree sequence
        return self._out
        
    
# generate 0-1 sequence of length 'length', with 'num' 1's    
def seqlist(length, num):
    if num >= length:
        return [[1 for i in range(length)]]
    if length == 1:
        return [[int(num == 1)]]
    if num == 0:
        return [[0 for i in range(length)]]
    res = [x + [0] for x in seqlist(length-1, num)] + [x + [1] for x in seqlist(length-1, num-1)]
    return res


# create a generator of powerset of a given set/list s
def powerset(s):
    x = len(s)
    masks = [1 << i for i in range(x)]
    for i in range(1 << x):
        yield [ss for mask, ss in zip(masks, s) if i & mask]

# 
def powerset_u(s):
    x = len(s)
    masks = [1 << i for i in range(x)]
    tmp = [set({}).union(*[ss for mask, ss in zip(masks, s) if i & mask]) for i in range(1 << x)]
    return [set(item) for item in set(frozenset(item) for item in tmp)] # unhashable type set...

def allminus1(l:list):
    # given a list l, output all lists obtained by modifying some nonzero entries to -1
    res = []
    ind = [i for i in range(len(l)) if l[i] == 1]
    ps = [x for x in powerset(ind)]
    for s in ps:
        lt = np.array(l)
        if s:
            ind = np.array(s)
            lt[ind] = -1
        res.append(lt.tolist())
    return res

def eq_L(g1:Graph, g2:Graph):
    # false: different matroids ensured by proposition 4.8
    for i in range(len(g1.mg)):
        L1 = powerset_u(g1.pclosure(i))
        L2 = powerset_u(g2.pclosure(i))
        ch1 = set(k for k in range(len(g1.mg)) if g1.mg[i,k])
        ch2 = set(k for k in range(len(g2.mg)) if g2.mg[i,k])
        if any([l.intersection(ch1) > l.intersection(ch2) for l in L1]):
            return False
        if any([l.intersection(ch1) < l.intersection(ch2) for l in L2]):
            return False
    return True


# wrap the class constructor as a function, and define a partial function for map operation
def generateG(l, p):
    return Graph(p, l)

generateG_p = functools.partial(generateG, p=p)


# pass arguments
p = int(sys.argv[1])
n_edges = int(sys.argv[2])

# generate all graph objects that has p nodes and n_edges edges
seq = functools.reduce(lambda x,y: x+y, map(allminus1, seqlist(p*(p-1)//2, n_edges)))
glist = list(map(generateG_p, seq))
#glist = (generateG_p(s) for s in seq)

count = 0
for i in range(len(glist)):
    for j in range(i+1, len(glist)):
        if operator.eq(glist[i].out, glist[j].out) and eq_L(glist[i], glist[j]):
            count += 1
print(count, len(seq)*(len(seq)-1)//2)

# compare outdegree sequences
#count = 0
#for i, x in enumerate(glist):
    #glist2 = (generateG_p(s) for s in seq[i+1:])
    #for j, y in enumerate(glist2):
        #if operator.eq(x.out, y.out) and eq_L(x, y):
            #count += 1
    #gc.collect()
#print(count, len(seq)*(len(seq)-1)//2)

#obtain the first different pair
#for i in range(len(glist)):
#    for j in range(i+1, len(glist)):
#        if operator.eq(glist[i].out, glist[j].out) and eq_L(glist[i], glist[j]):
#            print(i,j)
#            break
#    else:
#        continue
#    break

