#! /usr/bin/python3.5

'''
programmers
문제 설명
두 개의 단어 begin, target과 단어의 집합 words가 있습니다. 아래와 같은 규칙을 이용하여 begin에서 target으로 변환하는 가장 짧은 변환 과정을 찾으려고 합니다.

1. 한 번에 한 개의 알파벳만 바꿀 수 있습니다.
2. words에 있는 단어로만 변환할 수 있습니다.
예를 들어 begin이 hit, target가 cog, words가 [hot,dot,dog,lot,log,cog]라면 hit -> hot -> dot -> dog -> cog와 같이 4단계를 거쳐 변환할 수 있습니다.

두 개의 단어 begin, target과 단어의 집합 words가 매개변수로 주어질 때, 최소 몇 단계의 과정을 거쳐 begin을 target으로 변환할 수 있는지 return 하도록 solution 함수를 작성해주세요.

제한사항
각 단어는 알파벳 소문자로만 이루어져 있습니다.
각 단어의 길이는 3 이상 10 이하이며 모든 단어의 길이는 같습니다.
words에는 3개 이상 50개 이하의 단어가 있으며 중복되는 단어는 없습니다.
begin과 target은 같지 않습니다.
변환할 수 없는 경우에는 0를 return 합니다.

# Need to build graph first
# Use BFS and find the shortest way
'''
####################################################
begin="hit"
target="cog"
words=['hot', 'dot', 'dog', 'lot', 'log', 'cog']
####################################################

##BFS
from collections import deque as queue

transistable = lambda a,b: sum((1 if x!=y else 0) for x,y in zip(a,b)) == 1

def solution(begin,target,words):
    q, d = queue(), dict()
    q.append((begin, 0))
    d[begin] = set(filter(lambda x:transistable(x,begin), words))
    for w in words:
        d[w] = set(filter(lambda x:transistable(x,w), words))
       
    while q:
        cur, level  = q.popleft()
        if level > len(words):
            return 0
        for w in d[cur]:
            if w == target:
                return level + 1
            else:
                q.append((w, level + 1))
    return 0

print(solution(begin,target,words))

'''
def BFS(G,v):
    D = [0 for i in range(len(G))]
    P = D[:]
    visited=D[:]
    
    D[v] = 0
    P[v] = v
    Q=[v]
    visited[v] = True

    while Q:
        v = Q.pop(0)
        for w in G[v]:
            Q.append(w)
            visited[w]=True
            D[w]=D[v]+1
            P[w]=v
    return D[-1]

def Make_Graph(begin,words):
    words.insert(0,begin)
    n = len(words)
    G = [[0]*n]*n
    for i in range(n):
        for j in range(n):
            c=0
            for a,b in zip(words[i],words[j]):
                if a!=b :
                    c += 1
            if c == 1:
                G[i][j] = 1
            else :
                G[i][j] = 0
    return G
                
def solution(begin, target, words):
    if not target in words:
        return 0
    else :
        G = Make_Graph(begin,words)
        return BFS(G,0)


print(solution(begin,target,words))
'''

def solution(begin, target, words):
    answer = 0

    if target not in words :
        return 0

    word_len = len(begin)
    total_words = len(words)
    graph = {}

    for word in words :
        graph[word] = []

    # make adjency list
    for f in words :
        for t in words :
            count = 0

            for i in range(word_len) :
                if f[i] != t[i] :
                    count += 1

            if count != 1 :
                continue
            else :
                lst = graph[f] 
                lst.append(t)
                graph[f] = list(set(lst))

                lst = graph[t]
                lst.append(f)
                graph[t] = list(set(lst))

    # Set start nodes
    graph[begin] = []
    for word in words :
        count = 0
        for i in range(word_len) :
            if word[i] != begin[i] :
                count += 1

        if count == 1 :
            lst = graph[begin]
            lst.append(word)
            graph[begin] = lst

            lst = graph[word]
            lst.append(begin)
            graph[word] = lst


    # BFS with queue
    Q = []
    visit = {}
    for word in words :
        visit[word] = 0
    visit[begin] = 0

    Q.append([begin, 0])
    answer = 0
    isEnd = False
    while(Q != []) :
        node, level = Q[0]
        del Q[0]
        visit[node] = 1

        nodes = graph[node]
        for w in nodes :
            if w == target :
                isEnd = True
                answer = level + 1
                break

            if visit[w] == 0 :

                Q.append([w, level + 1])

        if isEnd == True :
            break


    return answer

print(solution(begin,target,words))


from collections import defaultdict

def nextword(cur,words):
    ret = []
    for word in words:
        cnt = 0
        for idx in range(len(word)):
            if word[idx] == cur[idx]:
                cnt += 1

        if cnt == len(cur) -1:
            ret.append(word)

    return ret


def bfs(begin,target,words):
    visited = defaultdict(lambda: False)
    queue = nextword(begin,words)
    count = 0
    min = 1e9

    while(len(queue) > 0):
        size = len(queue)
        count += 1

        for _ in range(size):
            key = queue.pop(0)
            visited[key] = True
            if(key == target and count < min):
                min = count
            for candidate in nextword(key,words):
                if (visited[candidate] == False):
                    queue.append(candidate)
    if min == 1e9:
        return 0
    else :
        return min

def solution(begin, target,words):
    answer = bfs(begin,target,words)
    return answer

print(solution(begin,target,words))



##############
def solution(begin, target, words):
    answer = 0
    if not target in words :
        return answer 
    else :
        words.insert(0,begin)
        G={x:[] for x in words}
        for i in range(len(words)):
            start = words[i]
            for word in words[1:] :
                a=0
                for i in range(len(word)):
                    if start[i] != word[i] :
                        a+=1
                if a == 1:
                    G[start].append(word)
        D = [0]*len(words)
        Q = []
        visited = [False]*len(words)
        
        D[0] = 0
        Q.append(0)
        visited[0] = True
        while Q :
            v = Q.pop(0)
            for w in G[words[v]] :
                w = words.index(w)
                if not visited[w] :
                    Q.append(w)
                    visited[w] = True
                    D[w] = D[v] +1
        answer = D[words.index(target)]
        return answer
