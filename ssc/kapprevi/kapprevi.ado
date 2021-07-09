*! v 1.0.0 N.Orsini & D.Rizzuto 19Oct2005

capture program drop kapprevi
program kapprevi, rclass
version 8.2
syntax , r1(string) r2(string)  ///
[ NOgraph ///
  * ] /// all scatter options

tempname sens1 spec1 sens2 spec2 alpha1 alpha2 beta1 beta2 maxkappa maxprev

if "`r1'" == "" {
	di in red "specify sensitivity and specificity for rater 1"
	exit 198
}   
else {
	tokenize "`r1'"
	confirm number `1'
	confirm number `2'

	scalar `sens1' = `1'
	scalar `spec1' = `2'
}

if "`r2'" == "" {
	di in red "specify sensitivity and specificity for raters 2"	
	exit 198
}   
else {
	tokenize "`r2'"
	confirm number `1'
	confirm number `2'

	scalar `sens2' = `1'
	scalar `spec2' = `2'
}

// check range of the values 

if inrange(`sens1',0,1)== 0 {
		di in red "sensitivity of r1() has to range between 0 and 1"	
		exit 198
	}   

if inrange(`spec1',0,1)== 0 {
		di in red "specificity of r1() has to range between 0 and 1"	
		exit 198
	}   

if inrange(`sens2',0,1)== 0 {
		di in red "sensitivity of r2() has to range between 0 and 1"	
		exit 198
	}   

if inrange(`spec2',0,1)== 0 {
		di in red "specificity of r2() has to range between 0 and 1"	
		exit 198
	}   
		
global options = "`options'"

preserve
 
if `c(N)' < 1000 qui set obs 1000
tempvar prev p1 p2 kappa

set seed 1324789
gen `prev' = uniform()
sort `prev'

scalar `alpha1' = 1-`spec1'
scalar beta1 = 1 - `sens1'

scalar `alpha2' = 1-`spec2'
scalar beta2 = 1 - `sens2'

gen double `p1' = `prev'*`sens1' + (1-`prev')*(1-`spec1')
gen double `p2' = `prev'*`sens2' + (1-`prev')*(1-`spec2')

gen double `kappa' = (2*`prev'*(1-`prev')*(1-`alpha1'-beta1)*(1-`alpha2'-beta2))/(`p1'*(1-`p2')+`p2'*(1-`p1'))

/* See Appendix Thompson and Walter, 1988 pag 958 for the explicit formula for the maximum value of kappa

scalar `maxkappa' = ( 2*(1-`alpha1'-beta1)*(1-`alpha2'-beta2) ) / [ 2-`alpha1'*(1-beta2)-(1-`alpha1')*beta2-`alpha2'*(1-beta1)-(1-`alpha2')*beta1 ///
+ 2*sqrt( (`alpha1'*(1-`alpha2')+(1-`alpha1')*`alpha2')*(beta1*(1-beta2)+(1-beta1)*beta2) ) ]

*/

// Another way to get the maximum kappa value and the corresponding prevalence

sort `kappa' 
scalar `maxkappa' = `kappa'[_N]  
scalar `maxprev' =  `prev'[_N]   

di _n as text "Maximum value (kappa, prevalence) = " as res "(" %4.3f  `maxkappa'   ", " as res %4.3f `maxprev' ")"   

return scalar maxkappa = `maxkappa'
return scalar maxprev = `maxprev'
return local cmd = "kapprevi"

// graph

label var `kappa' "Kappa"
label var `prev'  "True prevalence" 

if "`nograph'" == "" {
tw scatter `kappa'  `prev', sort  ylabel(0(.1)1) xlabel(0(.1)1)    ///
c(l) s(i)  $options 
}
end

