*! version 2.0 N.Orsini, I. Buchan, 25 Jan 06
*! version 1.0 N.Orsini, J.Higgins, M.Bottai, 16 Feb 2005

capture program drop heterogi
program heterogi, rclass
version 8
syntax anything [, Level(int $S_level) Format(string) NCchi2 ]

tempname Q K df H2 I2 SElnH LB_H_III UB_H_III  I22 levelci clevelci

tokenize "`anything'"
scalar `Q' = `1'
scalar `df' = `2'
scalar `K' = `df' + 1

/* CHECK ARGUMENTS */

if `Q' < 0 {
 di in r "Q must be positive"
 exit 198
}

if `df' < 2 {
 di in r "df must be at least 2"
 exit 198
}

if `level' <10 | `level'>99 { 
 di in red "level() invalid"
 exit 198
}   

scalar `levelci' = `level' * 0.005 + 0.50
scalar `clevelci' = 1- `levelci'  

if "`format'" == "" { 
 local formatI2 = "%4.0f"
 local formatH = "%4.1f"
}   
else {
 local formatI2 = "`format'"
 local formatH = "`format'"
}

preserve

/* COMPUTE INTERVAL */

scalar `H2' = `Q'/`df'
scalar `I2' = max(0, (100*(`Q' -`df')/(`Q' )) )
scalar `I22' = max(0, (`H2'-1)/`H2')

if sqrt(`H2') < 1 scalar `H2' = 1

* CI for H (Higgins & Thompson, Stats in Medicine 2002) 
if `Q' > `K'  {
 scalar `SElnH' = .5*[  (log(`Q')-ln(`df')) / ( sqrt(2*`Q') - sqrt(2*`K'-3) ) ]
}
else {
 scalar `SElnH' = sqrt( ( 1/(2*(`K'-2) )*(1-1/(3*(`K'-2)^2)) )  )
}
scalar `LB_H_III' = exp( log(sqrt(`H2')) - invnorm(`levelci') * `SElnH' )
scalar `UB_H_III' = exp( log(sqrt(`H2')) + invnorm(`levelci') * `SElnH' )
if  `LB_H_III' < 1 scalar  `LB_H_III' = 1

* CI interval for I2 based var(logH), formula not indicated in (Higgins & Thompson, Stats in Medicine) 
tempname varI2 lb_I2 ub_I2 lb_I22 ub_I22
scalar `varI2'  = 4*`SElnH'^2/exp(4*log(sqrt(`H2')))
scalar `lb_I2' = `I22'-invnorm(`levelci')*sqrt(`varI2')
scalar `ub_I2' = `I22'+invnorm(`levelci')*sqrt(`varI2')

if  `lb_I2' < 0 {
 scalar  `lb_I2' = 0
}
if  `ub_I2' > 1 {
 scalar  `ub_I2' = 1
}

if `c(N)' < 10  qui set obs 10

if "`ncchi2'" != "" {
 tempname UB_NC LB_NC LB_H_H UB_H_H LB_I2_H UB_I2_H nc
 * seek ci for non-centrality parameter (nc=q-df), thence for h and i-square
 scalar `nc' = max(0, `Q' - `df')
 * check if q < df , in this case no need to seek the lower bound
 if `Q' < `df' {
  gen `LB_NC' = 0
 }
 else {
  gen `LB_NC' =  invnchi2(`df',`nc',`clevelci')
 }
 gen `UB_NC' =  invnchi2(`df',`nc',`levelci')
 scalar `LB_H_H' = max(1, sqrt(`LB_NC'/`df') )
 scalar `LB_I2_H' = max(0, (`LB_H_H'^2 - 1)/`LB_H_H'^2 )
 scalar `UB_H_H' = sqrt(`UB_NC'/`df')  
 scalar `UB_I2_H' = (`UB_H_H'^2 - 1)/`UB_H_H'^2 
} // end option ncchi2

 

* preparing variables to be displayed with tabdisp

tempname LB_I2_HT UB_I2_HT
scalar `LB_I2_HT' = max(0,(`LB_H_III'^2-1)/`LB_H_III'^2)
scalar `UB_I2_HT' = (`UB_H_III'^2-1)/`UB_H_III'^2
tempvar a b c d e 
quietly {
 gen `e' = ""
 gen `d' = ""
 gen `c' = ""
 label var `d' "Statistic" 
 label var `e' " "
 egen `a'  = seq(), from(1) to(2) block(2)
 egen `b'  = seq(),  to(2)  
 replace `d' = "H" if `a'  == 1
 replace `d' = "I^2" if `a'  == 2
 replace `e' = "Estimate" if `b'  == 1 
 replace `e' = "[`level'% Conf. Interval]" if `b'  == 2
 if "`ncchi2'" != "" {
  replace `c' = string(sqrt(`H2'),"`formatH'")   if `a' == 1 & `b'  == 1 
  replace `c' = string(`LB_H_H',"`formatH'") + "    " + string(`UB_H_H',"`formatH'") if `a' == 1 & `b'  == 2 
  replace `c' = string(`I22'*100,"`formatI2'")   if `a' == 2 & `b'  == 1 
  replace `c' = string(`LB_I2_H'*100,"`formatI2'") + "    " + string(`UB_I2_H'*100,"`formatI2'") if `a' ==2 & `b'  == 2 
 }
 else {
  replace `c' = string(sqrt(`H2'),"`formatH'") if `a' == 1 & `b'  == 1 
  replace `c' = string(`LB_H_III', "`formatH'") + "    " + string(`UB_H_III',"`formatH'") if `a' == 1 & `b'  == 2 
  replace `c' = string(`I22'*100,"`formatI2'") if `a' == 2 & `b'  == 1 
  replace `c' = string(`LB_I2_HT'*100, "`formatI2'") + "    " + string(`UB_I2_HT'*100,"`formatI2'") if `a' == 2 & `b'  == 2 
 } 
}
 
tabdisp `d' `e' , cell(`c') center

di   as text "Q-test = " as res  `Q'  as text " d.f. = " as res `df' as text " p-value = " as res %5.4f chiprob(`df', `Q')

* return saved scalars
return local cmd = "heterogi2"
return scalar Q = `Q'
return scalar df = `df'
return scalar pval = chiprob(`df', `Q')
return scalar H = sqrt(`H2')
return scalar lb_H_M1 = `LB_H_III'
return scalar ub_H_M1 = `UB_H_III'
return scalar lb_I2_M1 = `LB_I2_HT'
return scalar ub_I2_M1 = `UB_I2_HT'
return scalar I2 = `I22'
if "`ncchi2'" != "" {
 return scalar lb_H_M2 = `LB_H_H'
 return scalar ub_H_M2 = `UB_H_H'
 return scalar lb_I2_M2 = `LB_I2_H'
 return scalar ub_I2_M2 = `UB_I2_H'
 return scalar lb_ncp = max(0,`LB_NC')
 return scalar ub_ncp = `UB_NC'
}

end


