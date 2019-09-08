#! /usr/bin/python3.5
###### Programmers 다른 사람 코드 수정 #######
def dfs(i,port, tickets, route) :
    ## 현재 경로 출발지 -> 목적지 생성
    route = '{0} {1}'.format(route, port)
    ## 티켓을 다 쓴 경우에는 재귀 탈출
    if len(tickets) == 0:
        list_result=route
        return
    ## 현재 티켓을 기준으로 재귀 다시 시작
    for t in tickets:
        ## 새로운 티켓의 출발지가 현재 티켓의 목적지와 같은경우 다시 재귀 시작
        if t[0] == port:
            c_tickets = tickets.copy()
            c_tickets.remove(t)
            ## 새로운 티켓의 도착지를 이용해서 다시 재귀 시작
            dfs(i,t[1], c_tickets, route)
            i+=1
            print(i,t[1], c_tickets, route)

def solution(tickets):
    i = 0
    answers=[]
    ## ICN 출발행 티켓만 찾기
    ticket_icn = [[x,y] for x,y in tickets if x == "ICN"]
    ## ICN 출발행을 기준으로 깊이탐색시작
    for t in ticket_icn:
        # 사용한 티켓 제거
        c_tickets = tickets.copy()
        c_tickets.remove(t)
        # 다음 목적지 기준 다음 행선지 찾기(회귀)
        answers.append(dfs(i,t[1], c_tickets, t[0]))
    # 알파벳 기준으로 가장 앞서는 경로만 반환
    print(answers)
    answers.sort()

    return answers[0].split(' ')

####################################
tickets = [["ICN","SFO"],["ICN","ATL"],["SFO","ATL"],["ATL","ICN"],["ATL","SFO"]]
####################################
print("Input : ",tickets)
print(solution(tickets))
