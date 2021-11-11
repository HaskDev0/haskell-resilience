The program is about efficiently finding the numbers with target resilience.

The program reads from the file information of the form:

T
a_1 b_1
a_2 b_2
.
.
.

where T is the number of the lines to read after it, a_i and b_i are integers representing the ratio q_i. 
The algorithm then calculates for each q_i the smallest integer d_i, s.t. R(d) (the ratio of its proper fractions that are resilient) is smaller than q_i.
Then it prints all calculated numbers in the file "Results.txt".
