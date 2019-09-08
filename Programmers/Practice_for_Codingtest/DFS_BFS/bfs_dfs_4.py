#! /usr/bin/python3.5

'''
[programmers#3] DFS/BFS (4)
주어진 항공권을 모두 이용하여 여행경로를 짜려고 합니다. 항상 ICN 공항에서 출발합니다.

항공권 정보가 담긴 2차원 배열 tickets가 매개변수로 주어질 때, 방문하는 공항 경로를 배열에 담아 return 하도록 solution 함수를 작성해주세요.

제한사항
모든 공항은 알파벳 대문자 3글자로 이루어집니다.
주어진 공항 수는 3개 이상 10,000개 이하입니다.
tickets의 각 행 [a, b]는 a 공항에서 b 공항으로 가는 항공권이 있다는 의미입니다.
주어진 항공권은 모두 사용해야 합니다.
만일 가능한 경로가 2개 이상일 경우 알파벳 순서가 앞서는 경로를 return 합니다.
모든 도시를 방문할 수 없는 경우는 주어지지 않습니다.
입출력 예
tickets	return
[[ICN, JFK], [HND, IAD], [JFK, HND]]	[ICN, JFK, HND, IAD]
[[ICN, SFO], [ICN, ATL], [SFO, ATL], [ATL, ICN], [ATL,SFO]]	[ICN, ATL, ICN, SFO, ATL, SFO]
'''
###### Programmers 다른 사람 코드 수정 #######
def dfs(port, tickets, route, list_result):
    ## 현재 경로 출발지 -> 목적지 생성
    route = '{0} {1}'.format(route, port)
    ## 티켓을 다 쓴 경우에는 재귀 탈출
    if len(tickets) == 0:
        list_result.append(route)
        return
    ## 현재 티켓을 기준으로 재귀 다시 시작
    for t in tickets:
        ## 새로운 티켓의 출발지가 현재 티켓의 목적지와 같은경우 다시 재귀 시작
        if t[0] == port:
            c_tickets = tickets.copy()
            c_tickets.remove(t)
            ## 새로운 티켓의 도착지를 이용해서 다시 재귀 시작
            dfs(t[1], c_tickets, route, list_result)

def solution(tickets):
    list_result = []
    ## ICN 출발행 티켓만 찾기
    ticket_icn = [[x,y] for x,y in tickets if x == "ICN"]
    ## ICN 출발행을 기준으로 깊이탐색시작
    for t in ticket_icn:
        # 사용한 티켓 제거
        c_tickets = tickets.copy()
        c_tickets.remove(t)
        # 다음 목적지 기준 다음 행선지 찾기(회귀)
        dfs(t[1], c_tickets, t[0], list_result)
    # 알파벳 기준으로 가장 앞서는 경로만 반환
    list_result.sort()

    return list_result[0].split(' ')


####################################
tickets = [["ICN","JFK"],["HND","IAD"],["JFK","HND"]]
####################################
print("Input : ",tickets)
print(solution(tickets))

####################################
tickets = [["ICN","SFO"],["ICN","ATL"],["SFO","ATL"],["ATL","ICN"],["ATL","SFO"]]
####################################
print("Input : ",tickets)
print(solution(tickets))

#######################Fail#########################
from collections import Counter
def solution(tickets):
    T = {x:[] for x,_ in tickets}
    for x,y in tickets:
        T[x].append(y)
    visited = Counter([ x for x,_ in tickets])    
    answer =["ICN"]
    S = []
    ticket_used=[]
    ticket_copy=tickets[:]
    v = "ICN"
    visited[v] -= 1
    S.extend(T[v])
    while S:
        if len(answer) == len(tickets)+1 :
            break
        v = S.pop()
        if visited[v] > 0 and [answer[-1],v] in ticket_copy:
            ticket_used.append([answer[-1],v])
            ticket_copy.remove([answer[-1],v])
            visited[v]-=1
            answer.append(v)
            if v in T.keys():
                S.extend(T[v])
        elif sum(visited.values()) == 0 :
            answer.append(ticket_copy[0][1])
    return answer

