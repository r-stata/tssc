*! lehmann.do  Version 1.0  2004-05-07 JRC
* van Elteren test example from E. L. Lehmann
* (and H. J. M. D'Abrera), _Nonparametrics.  Statistical
* Methods Based on Ranks_  (San Francisco:  Holden-Day, Inc.,
* 1975), pp. 132-141.
clear
input byte block byte treatment int consumption
1 1 236  
1 2 255
2 1 183  
2 2 179  
2 2 193
3 1 115  
3 1 128  
3 2 132
4 1 61  
4 1 70  
4 1 79  
4 2 67  
4 2 84  
4 2 88
end
vanelteren consumption, by(treatment) strata(block)
display r(p)
*  The results differ from asymptotic results reported 
*  by Lehmann due to rounding in Lehmann's calculations.  
*  (Lehmann also tests a directional hypothesis.)
*  Results for -vanelteren- with this dataset, however, match
*  those reported by SAS on its website 
*  ( http://ftp.sas.com/techsup/download/stat/vanelter.html )
*  for its implementation of of van Elteren's test, 
*  which uses PROC FREQ . . . SCORES=MODRIDIT and reports
*  a chi-square test statistic of 2.744, df = 1, P = 0.098,
*  (P = 0.09765 in the annotations).
exit
