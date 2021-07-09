*! SEMatch.do

version 13.1

clear *
set more off

/* This example demonstrates how to obtain the same standard errors of the 
   estimates as SAS obtains. 
   
   The example is from http://sas-and-r.blogspot.com/2010/11/example-815-firth-logistic-regression.html
   
   SAS code and results from the blog are commented-out and included for information. */

/* data testfirth;
   pred=1; outcome=1; weight=20; output;
   pred=0; outcome=1; weight=20; output;
   pred=0; outcome=0; weight=200; output;
run; */

input byte(pred outcome) int weight
1 1  20
0 1  20
0 0 200
end

/* proc logistic data = testfirth;
  class outcome pred (param=ref ref='0');
  model outcome(event='1') = pred / cl firth;
  weight weight;
run; */

firthlogit outcome i.pred [fweight=weight], nolog

/*             Analysis of Maximum Likelihood Estimates

                              Standard         Wald
Parameter     DF   Estimate      Error   Chi-Square   Pr > ChiSq

Intercept      1    -2.2804     0.2324      96.2774       <.0001
pred      1    1     5.9939     1.4850      16.2926       <.0001 */

tempname B
matrix define `B' = e(b)

logit outcome i.pred [fweight=weight], asis iterate(0) from(`B', copy) nolog

exit
