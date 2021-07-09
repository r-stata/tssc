clear
// Powers 2012
//Daniel A. Powers (2012). "Black-White Differences in Maternal Age, Maternal Birth Cohort, and 
//Period Effects on Infant Mortality in the U.S. (1983-2002)." Presented at the annual meetings 
//of the Population Research Association of America, San Francisco, CA, May 4 2012.
input period age d n
1985    15  261     11687
1985    20  12425   966368
1985    25  25153   2690494
1985    30  21643   2899837
1985    35  12138   1635236
1985    40  3980    474653
1985    45  722     64697
1990    15  395     21115
1990    20  18598   1609930
1990    25  34274   4099337
1990    30  33073   5044245
1990    35  21502   3299577
1990    40  7888    1096974
1990    45  1534    159806
1995    15  382     25392
1995    20  14681   1683424
1995    25  24240   3673658
1995    30  22647   4417767
1995    35  17667   3639992
1995    40  8859    1570498
1995    45  2008    284124
2000    15  243     16468
2000    20  10168   1260643
2000    25  18026   3008647
2000    30  15999   3379035
2000    35  13227   3001556
2000    40  7421    1433094
2000    45  2067    299174
end

tab age, gen(a)
scal arow = r(r)
tab period, gen(p)
scal prow = r(r)
qui gen cohort = period - age
tab cohort, gen(c)
scal crow = r(r) 

* construct ANOVA normalization using last category as reference

forval i = 1/`=arow' {
 gen aC`i' = a`i' - a`=arow'
 }

forval i = 1/`=prow' {
 gen pC`i' = p`i' - p`=prow'
 }
 
forval i = 1/`=crow' {
 gen cC`i' = c`i' - c`=crow'
}


   gen logr = log(d/n)
   gen logn = log(n)
   
   
ie_reg logr aC1-aC6 pC1-pC3 cC1-cC9
ie_norm, groups(aC1-aC7, pC1-pC4, cC1-cC10)
ie_reg, irr

   
ie_rate d aC1-aC6 pC1-pC3 cC1-cC9, offset(logn)
ie_norm, groups(aC1-aC7, pC1-pC4, cC1-cC10)
ie_rate, irr


