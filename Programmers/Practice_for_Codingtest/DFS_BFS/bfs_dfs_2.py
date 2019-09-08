#! /usr/bin/python3.5

'''
Programmers
n개의 음이 아닌 정수가 있습니다. 이 수를 적절히 더하거나 빼서 타겟 넘버를 만들려고 합니다. 예를 들어 [1, 1, 1, 1, 1]로 숫자 3을 만들려면 다음 다섯 방법을 쓸 수 있습니다.

-1+1+1+1+1 = 3
+1-1+1+1+1 = 3
+1+1-1+1+1 = 3
+1+1+1-1+1 = 3
+1+1+1+1-1 = 3
사용할 수 있는 숫자가 담긴 배열 numbers, 타겟 넘버 target이 매개변수로 주어질 때 숫자를 적절히 더하고 빼서 타겟 넘버를 만드는 방법의 수를 return 하도록 solution 함수를 작성해주세요.

제한사항
주어지는 숫자의 개수는 2개 이상 20개 이하입니다.
각 숫자는 1 이상 50 이하인 자연수입니다.
타겟 넘버는 1 이상 1000 이하인 자연수입니다.
'''
import time
##Input##
numbers= [1,1,1,1,1]
target = 3
#########

#############################
print("# Example 1")
#############################
st = time.time()
def solution(numbers,target):
    if not numbers and target == 0 :
        return 1
    elif not numbers:
        return 0
    else :
        return solution(numbers[1:],target-numbers[0])+solution(numbers[1:],target+numbers[0])


print(solution(numbers,target))
print(time.time()-st)

#############################
print("# Example 2")
#############################
st = time.time()
answer = 0
def DFS(idx,numbers,target,value):
    global answer
    N = len(numbers)
    if(idx==N and target==value):
        answer += 1
        return
    if(idx==N):
        return

    DFS(idx+1,numbers,target,value+numbers[idx])
    DFS(idx+1,numbers,target,value-numbers[idx])

def solution(numbers, target):
    global answer
    DFS(0,numbers,target,0)
    return answer

print(solution(numbers,target))
print(time.time()-st)

#############################
print("# Example 3")
#############################
st = time.time()
def solution(n,t):
    answer = 0
    for i in range(2**len(n)):
        tmp = []
        for j in range(len(n)):
            if i&(2**j) == 0:
                tmp.append(n[j])
            else :
                tmp.append(-1*n[j])
        if sum(tmp) == t:
            answer += 1
    return answer

print(solution(numbers,target))
print(time.time()-st)
