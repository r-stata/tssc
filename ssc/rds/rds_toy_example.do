
* example with 20 data points from:
*Heckathorn, DD. 2002. Respondent-driven sampling II: deriving valid population estimates 
*from chain-referral samples of hidden populations. Social problems 49 (1):11-34.

clear all

input id ref1 ref2 ref3 degree str1 var
1  2 3 4 8 a
2 5 6 .  8 a
3 7 8 9 . a
4 10 . .  10 b
5 11 12 13 5 a
6 . . . 7 b
7 14 15 16 4 b
8 17 . . 7 b
9 18 19 20 5 a 
10 . . . 2 b
11  . . . 4 a 
12  . . .  . b
13 . . . 3 a 
14 . . . 2 b
15 . . . 3 b
16 . . . 3 a
17 . . . 7 b
18 . . . 3 b
19 . . . 5 a 
20 . . . 8 b
end;
 
gen key= var=="b"

rds_network key , id(id) coupon(ref) ncoupon(3) degree(degree) ancestor(my_ancestor) depth(my_depth) recruiter_id(p_id) recruiter_var(p_key)
rds key, id(id) recruiter_id(p_id) recruiter_var(p_key) wgt(w) wgt_pop(wpop) degree(degree)





