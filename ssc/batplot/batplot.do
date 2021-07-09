pda
/*
use "u:\data\epi\projects\jj\bioreclaim3",replace
batplot gcm daz
batplot gcm daz if _n<10
*/
clear
set obs 40
gen y1 = invnorm(uniform())
gen y2 = invnorm(uniform())
*batplot y1 y2 
*batplot y1 y2 , notrend info xlab(-2(1)2) 
*batplot y1 y2 if y2<0
*batplot y1 y2 if y2<0, notrend info 
*batplot y1 y2 if y2<0, info 
batplot y1 y2 if y2<0, info dp(3)






