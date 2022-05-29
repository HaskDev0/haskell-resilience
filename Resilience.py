import math
import fractions
import time
import array as ar

n = 258

a = time.time_ns()

primes = ar.array('I',[i for i in range(2,n + 1)])
primes_bool = ar.array('I',[True for i in range(2,n + 1)])

for i in range(0,int(math.sqrt(n + 1))):
    if primes_bool[i] == True:
        for j in range((i + 2)*(i + 2) - 2, (n - 1), (i + 2)):
            primes_bool[j] = False

k = 0

for i in range(0, n - 1):
    if not(primes_bool[i]):
        primes.pop(k)
        k = k - 1
    k = k + 1

b = time.time_ns()

#Res List
def resilience_list(val):
    mult = 2
    old_mult = 2
    tot = 1
    old_tot = 1
    i = 1

    while fractions.Fraction(tot,(mult - 1)) >= val:
        old_mult = mult
        old_tot = tot
        mult = mult*primes[i]
        tot = tot*(primes[i] - 1)
        i = i + 1

    return (i,old_mult,old_tot)

def binary_search(list_to_search,q_value,old_mult,old_tot):
    min = 0
    max = len(list_to_search) - 1
    while not(min == max):
        index = (min + max) // 2
        value = fractions.Fraction(old_tot*(list_to_search[index]),(old_mult*(list_to_search[index]) - 1))
        if value < q_value:
            max = index
        else:
            min = index + 1
    return max

def integer_answer(tonv,val):
    lts = [(i + 1) for i in range(1,primes[tonv[0] - 1])]
    m = binary_search(lts,val,tonv[1],tonv[2])
    int_answer = tonv[1]*lts[m]
    return int_answer

c = time.time_ns()

list_of_Qs = []
num_of_lines_to_read = int(input())
for l in range(1,num_of_lines_to_read + 1):
    #lines are in the form 'int int'
    num = input()
    #separate them to ['int','int']
    nums = num.split()
    #create fractions
    list_of_Qs.append(fractions.Fraction(int(nums[0]),int(nums[1])))

list_of_answers = []
for l in range(1,num_of_lines_to_read + 1):
    val = list_of_Qs[l - 1]
    ans = integer_answer(resilience_list(val),val)
    list_of_answers.append(ans)

for l in range(1,num_of_lines_to_read + 1):
    print(list_of_answers[l - 1])

d = time.time_ns()

print('b - a =',(b - a)/1000000000)
print("{} = {}".format("d - c",(d - c)/1000000000))
print("{} = {}".format("d - a",(d - a)/1000000000))
