capture program drop umeta
program define umeta, eclass  sortpreserve byable(recall)
version 11.2
if _by() {
local BY `"by `_byvars'`_byrc0':"'
}

if  !replay()  {

#delimit;
syntax varlist(numeric min=2  max=9) [if] [in] [ , 
COVvar(string)
EQuations(string)
LEVEL(integer 95)  
PREDint
TScale(string)
noESTimates
BSsd
Zci
I2 
Qhet *];
#delimit cr

qui {
marksample touse, strok novarlist


if _by()  {
qui replace `touse' = 0  if  `_byindex' != _byindex()
}

tokenize "`varlist'", parse(" ")
local outcome: word count("`varlist'")


if `outcome' > 4  & missing( "`covvar'") {
di as err "{p 0 4 2}You must specify {cmdab:cov:var(rho)} or {cmdab:cov:var(cov)}"
di in red "depending on whether you are using"
di in red "within-correlation(s) or covariance(s){p_end}"
exit 198
}


if `outcome'  < 3  {

local yvars "`1'"
local svars "`2'"
replace `yvars'=0 if `yvars'==.
}
else if `outcome' > 4  & `outcome' < 6  {
local yvars "`1' `2'"
local svars "`3' `4'"
local rvars "`5'"
foreach yguy in `yvars' {
replace `yguy'=0 if `yguy'==.
}
foreach sguy in `svars' {
replace `sguy'=1e12 if `sguy'==.
}
replace `rvars'= 0 if `rvars'==.
}
 
else if `outcome' > 6  {
local yvars "`1' `2' `3'"
local svars "`4' `5' `6'"
local rvars "`7' `8' `9'"
foreach yguy in `yvars' {
replace `yguy'=0 if `yguy'==.
}
foreach sguy in `svars' {
replace `sguy'=1e12 if `sguy'==.
}
foreach rguy in `rvars' {
replace `rguy'= 0 if `rguy'==.
}
}
else error 102

markout `touse' `varlist'

if "`constant'" != "noconstant" {
    tempvar xcons
    gen `xcons' = 1
}

tokenize "`equations'", parse(",")
local neqs 0
while "`1'"!="" {
    local ++neqs
    gettoken eqy rest : 1, parse(":")
    gettoken junk eqx : rest, parse(":")
    if "`eqy'"!="" unab eqy`neqs' : `eqy'
    if "`eqx'"!="" unab eqx`neqs' : `eqx'
    mac shift 2
}

//  Now see if we have any covariates for it

local p = wordcount("`yvars'")

forvalues r=1/`p'  {
local var`r':  word `r' of "`yvars'"
forvalues eq=1/`neqs' {
if "`var`r''"=="`eqy`eq''" local xvars_`r' `eqx`eq''
 }
 _rmcoll `xvars_`r'', `constant'
 local xvars_`r' = r(varlist)
 if "`xvars_`r''" == "." local xvars_`r'
 if "`xvars_`r''"=="" & "`constant'"=="noconstant" {
  di as error "No covariates and no constant for outcome `r'"
  exit 498
   }
   }

if `outcome'  < 3 {
mata:  univar("`varlist'", "`touse'")
}

else if `outcome' > 4  & `outcome' < 6  {
if "`covvar'" == "cov" {
mata:  ubivar("`varlist'", "`touse'")
}
else if "`covvar'" == "rho" {
mata:  ubirho("`varlist'", "`touse'")
}
}
 
else if `outcome' > 6  {
if "`covvar'" == "cov" {
mata:  utrivar("`varlist'", "`touse'")
}
else if "`covvar'" == "rho" {
mata:  utrirho("`varlist'", "`touse'")
}
}

global touse=`touse'
global yvars `yvars'
tempname  b V Sigma rho
tempname YY SS Vtyp Isqmat Qmat 
mat `b' =  r(b)
local dims=colsof(`b')
mat `Qmat'=r(Q)
mat `V' =  r(V)
mat `YY' = r(Ymat)
mat `SS' = r(Smat)
mat `Sigma' =  r(Sigma)
mat `Vtyp' = r(vtyp)
mat `Isqmat' = r(Isq)


if `dims' >=2 {
mat `rho'=r(rho)
}

local N = r(N)
if "`zci'" == "" {
local df = r(df)
}
local Qdf=r(Qdf)


forvalues r=1/`dims' {
local eqname: word `r' of `yvars'
local eqs `eqs' `eqname'
local eqq  eq`r'
local eq `eq' `eqq'
}

mat coleq `b' = `eq'
mat coleq `V' = `eq'
mat roweq `V' = `eq'
mat colnames `b' = `eqs'
mat colnames `V' = `eqs'
mat rownames `V' = `eqs'
mat colnames `YY' =  `eqs'
mat colnames `Qmat '=  `eqs'
mat colnames `Sigma' = `eqs'
mat rownames `Sigma' =   `eqs'
mat colnames `Vtyp' = `eqs'
mat colnames `Isqmat' = `eqs'

forvalues r=1/`dims' {
local eqname2: word `r' of `svars'
local eq2 `eq2' `eqname2'
}
mat colnames `SS' =  `eq2'


tempvar esamp
gen `esamp'= `touse'

if "`zci'" == "zci" {
eret post `b' `V', esample(`esamp') obs(`N')  
}
else if  "`zci'" == "" {
eret post `b' `V', esample(`esamp') obs(`N')  dof(`df')
}
eret mat yvars `YY'
eret mat Vtyp `Vtyp'
eret mat svars `SS'
eret mat Sigma  `Sigma'
eret mat Qmat  `Qmat'
eret mat Isqmat `Isqmat' 



if `dims' >=2 {
eret mat rho  `rho'
}

eret sca N = `N'
eret sca Qdf=`Qdf'
eret sca dims=`dims'
eret local ynames "`yvars'"
eret local snames "`svars'"
eret local predict  "umetap"
eret local cmdline "umeta `0'"
eret local cmd= "umeta"

}
}

else { // replay
if  "`e(cmd)'" != "umeta" error 301  // last estimates not found
	if _by() error 190
#delimit;
syntax [if] [in] 
[, Level(cilevel)  
Zci
PREDint
noESTimates
TScale(string)
BSsd
I2  
 Qhet *];
#delimit cr
}
di ""
di ""
if "`tscale'"== "logit" {
local tscale "invlogit"
}
else if "`tscale'"== "log" {
local tscale "exp"
}
else if "`tscale'"== "asin" {
local tscale "tanh"
}
else local tscale "" 
foreach mat in Vtyp Qmat Isqmat Sigma rho {
 tempname `mat'
 mat ``mat'' = e(`mat')
		} 
	
local yname $yvars

local p=e(dims)
if "`zci'"=="" {
local z= invttail(e(N)-2, 0.5 - `level'/200)
}
else if "`zci'"=="zci" {
local z = invnormal((100 + `level')/200)	
}
if mi("`estimates'") {
nois di  in smcl in gr   _newline(1)  "{hilite: U-statistics-based Random-effects Meta-analysis}"
di ""
di _col(36) as text "Number of dimensions " _col(60) "=" as result %6.0f e(dims)
di _col(36) as text "Number of observations " _col(60) "=" %6.0f as result e(N)
if "`zci'"=="" di _col(36) as text "Degrees of freedom " _col(60) "=" _col(60) %6.0f as result e(df_r)
di ""

tempname b V 
mat `b'= e(b)
mat `V'= e(V)
nois di in smcl  _newline(1)   "{hilite:Pooled Effect Estimate(s)}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
if mi("`predint'") {
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "Mean" _col(40) "SE" _col(48)  `"[`=strsubdp("`level'") '% Conf. Interval]"'
} 
else if !mi("`predint'") {
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "Mean" _col(40) "SE" _col(48)  `"[`=strsubdp("`level'") '% Pred. Interval]"'
}
nois di as txt "{hline 21}{c +}{hline 46}"
forv r = 1(1)`p'  {
if mi("`predint'") {
 local est`r'   = `tscale'(`b'[1,`r']) in `r'
 local se`r'   =  `tscale'(sqrt(`V'[`r',`r'])) in `r'
 local lb`r' =  `tscale'(`b'[1,`r'] - `z' * sqrt(`V'[`r',`r'])) in `r'
 local ub`r' =  `tscale'(`b'[1,`r'] + `z' * sqrt(`V'[`r',`r'])) in `r'
 }
 else if !mi("`predint'") {
 local t=invttail(e(N)-2, 0.5 - `level'/200)
 local est`r'   = `tscale'(`b'[1,`r']) in `r'
 local se`r'   =  `tscale'(sqrt(`V'[`r',`r'])) in `r'
 local lb`r' =  `tscale'(`b'[1,`r'] - `t' * sqrt(`V'[`r',`r'] + `Sigma'[`r',`r'])) in `r'
 local ub`r' =  `tscale'(`b'[1,`r'] + `t' * sqrt(`V'[`r',`r'] + `Sigma'[`r',`r'])) in `r'
 }
 local namevar : word  `r' of `yname'
nois di as txt %~12s "`namevar'" _col(22) "{c |}" as res _col(25) %7.3f `est`r''  as res _col(38) %7.3f `se`r''  ///
as res _col(45) %9.3f `lb`r''  as res _col(60) %5.3f `ub`r''
}  
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"  
}

forvalues r=1/`p' {
 local s2`r' = `Vtyp'[1,`r']
 local Q`r' = `Qmat'[1,`r']
 local Qdf=e(Qdf)
cap uhet `Q`r'' `Qdf'
if _rc {
local I2est`r' = max(0, 100*`Isqmat'[1,`r'])
local I2lb`r' = .
local I2ub`r' = .	
local I2se`r'=.
}
else {
local I2est`r' = 100*r(Isq)
local I2lb`r' = 100*r(Isqlo)
local I2ub`r' = 100*r(Isqhi)
local I2se`r'=	 (`I2ub`r'' - `I2lb`r'' )/(2* `z')
}
foreach guy in est`r' se`r' lb`r' ub`r'  {
local bssd`guy' = sqrt(`I2`guy'' * `s2`r'' /(100- `I2`guy''))	
local bsvar`guy' = `I2`guy'' * `s2`r'' /(100- `I2`guy'')	
	}	
	}
if mi("`estimates'") {
if mi("`bssd'") & mi("`predint'") {
nois di in smcl  _newline(1)   "{hilite: Between-study Variance(s)}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "Variance" _col(40) "" _col(48)  `"[`=strsubdp("`level'") '% Conf. Interval]"'
nois di as txt "{hline 21}{c +}{hline 46}"
forvalues r=1/`p' {
local namevar : word  `r' of `yname'
nois di as txt %~12s "`namevar'" _col(22) "{c |}" as res _col(25) %7.3f `bsvarest`r'' ///
 as res _col(38) %7.3f  as res _col(45) %9.3f `bsvarlb`r''  as res _col(60) %5.3f `bsvarub`r''
	}
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"   
}
else  if !mi("`bssd'") & mi("`predint'")  {
nois di in smcl  _newline(1)   "{hilite: Between-study SD(s)}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "BSSD" _col(40) "" _col(48)  `"[`=strsubdp("`level'") '% Conf. Interval]"'
nois di as txt "{hline 21}{c +}{hline 46}"
forvalues r=1/`p' {
local namevar : word  `r' of `yname'
nois di as txt %~12s "`namevar'" _col(22) "{c |}" as res _col(25) %7.3f `bssdest`r''  as res _col(38) %7.3f   /// 
as res _col(45) %9.3f `bssdlb`r''  as res _col(60) %5.3f `bssdub`r''
	}    
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"   	
} 
	
if `p' > 1 & mi("`predint'") {
nois di in smcl  _newline(1)   "{hilite: Between-study Correlation(s)}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
nois di as txt %~12s " Variables" _col(22) "{c |}" _col(28) "Corr" _col(40) "" _col(48)  `"[`=strsubdp("`level'") '% Conf. Interval]"'
nois di as txt "{hline 21}{c +}{hline 46}"
forvalues r=1/`p' {
local rminus1 = `r'-1
forvalues s=1/`rminus1' {
local sdsd = (`Sigma'[`r',`r']*`Sigma'[`s',`s'])
local covar = (`Sigma'[`s',`r'])
local rcor = `covar'/sqrt(`sdsd')               
local n = e(N)
local rstar =.5*ln((1+`rcor')/(1-`rcor'))
local se = (`n'-3)^-.5
local z = invnormal(.5+ `level'/200)
local lb = `rstar' - `z'*`se'
local ub = `rstar' + `z'*`se'
foreach guy in se lb ub {
local `guy' =  (exp(2*``guy'')-1)/(exp(2*``guy'')+1)
}
local lb = max(-1.000, `lb')
local ub = min(1.000, `ub')
if `rcor' > 1.000 {
local rcor=min(1.000, `rcor')
}
else if `rcor' < -1.000 {
local rcor=max(-1.000, `rcor')
}

if `rcor' ==-1.000 | `rcor' == 1.000 {
local se = .
local lb = .
local ub = .
}

local rname : word  `r' of `yname'
local sname : word  `s' of `yname'
nois di as txt %~12s "`rname' vs `sname'" _col(22) "{c |}" as res _col(25) %7.3f `rcor'  as res _col(38) %7.3f   ///
 as res _col(45) %9.3f `lb'  as res _col(60) %5.3f `ub' 
}
}
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"  
}
}
nois di " "
nois di " "

if !mi("`i2'")  {
nois di in smcl  _newline(1)   "{hilite: Inconsistency (I^2) Statistic(s)}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "I^2" _col(40) "SE" _col(48)  `"[`=strsubdp("`level'") '% Conf. Interval]"'
nois di as txt "{hline 21}{c +}{hline 46}"
forvalues r=1/`p' {
local namevar : word  `r' of `yname'
nois di as txt %~12s "`namevar'" _col(22) "{c |}" as res _col(23) %7.0f `I2est`r''  /// 
as res _col(35) %7.0f `I2se`r''  as res _col(45) %9.0f `I2lb`r''  as res _col(60) %3.0f `I2ub`r''
	}
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"     
} 

if !mi("`qhet'")  {
di _new as text "{hilite: Cochran's Q test(s) for heterogeneity}"
nois   di in smcl as text "{hline 21}{c TT}{hline 46}"
nois di as txt %~12s "Variable" _col(22) "{c |}" _col(28) "Q" _col(40) "df" _col(48)  "pvalue"
nois di as txt "{hline 21}{c +}{hline 46}"
forvalues r=1/`p' {
 local namevar : word  `r' of `yname'
nois di as txt %~12s "`namevar'" _col(22) "{c |}" as res _col(25) %7.3f `Q`r''  as res _col(40) `Qdf'  /// 
as res _col(45) %9.5f chiprob(`Qdf', `Q`r'')  
}
nois   di in smcl as text "{hline 21}{c BT}{hline 46}"  
}



end



capture program drop uhet
program uhet, rclass

syntax anything [, Level(int 95) ]

tempname Q K df I2 I22 varI2 lb_I2 ub_I2 levelci 
tokenize "`anything'"
scalar `Q' = `1'
scalar `df' = `2'
scalar `K' = `df' + 1


if `level' <10 | `level'>99 { 
 di in red "level() invalid"
 exit 198
}   

scalar `levelci' = `level' * 0.005 + 0.50


preserve
tempname varI2 lb_I2 ub_I2 
scalar H2 = `Q' / `df'
scalar I2 = max(0, (100*(`Q' -`df')/(`Q' )) )
scalar I22 = max(0, (H2-1)/H2)
if sqrt(H2) < 1 scalar H2 = 1
if `Q' > `K'  {
 scalar SElnH1 = .5*[(log(`Q')-ln(`df')) / ( sqrt(2*`Q') - sqrt(2*`K'-3) )]
}
else {
 scalar SElnH1 = sqrt( ( 1/(2*(`K'-2) )*(1-1/(3*(`K'-2)^2)) )  )
}
scalar `varI2'  = 4*SElnH1^2/exp(4*log(sqrt(H2)))
scalar `lb_I2' = I22-invnormal(`levelci')*sqrt(`varI2')
scalar `ub_I2' = I22+invnormal(`levelci')*sqrt(`varI2')

if  `lb_I2' < 0 {
 scalar  `lb_I2' = 0
}
else scalar `lb_I2' = `lb_I2'
if  `ub_I2' > 1 {
 scalar  `ub_I2' = 1
}
else scalar `ub_I2' = `ub_I2'

return scalar Isq =  I22
return scalar Isqlo = `lb_I2'
return scalar Isqhi = `ub_I2'
return scalar df = `df'
return scalar Q = `Q'
return scalar pval= chiprob(`df', `Q')

end



mata:
mata set matastrict on
void univar(string scalar varlist, string scalar touse)
{
	real matrix              M, H1, H11
	real colvector        Y, BB, V, UCOV, SIGMA
	real scalar              n, nobs, nobsminus1
	
	M = Y = V = .
	st_view(M,  ., tokens(varlist), touse)
	Y=M[., 1]
	V=M[., 2]
	nobs=rows(Y)
	nobsminus1=nobs-1
	n=rows(Y)

H1=J(nobsminus1,nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		H1[i,(j-1)]=H1[i,(j-1)]:+((Y[i]-Y[j])^2-V[i]-V[j]):/(V[i]+V[j])
}
}
	H11=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H11[i,(j-1)]=H11[i,(j-1)]:+1/(V[i]:+V[j])
}
}
	H11=2*sum(H11):/(n:*(n-1))
	SIGMA=sum(H1):/(n:*(n-1)):/H11 

BB=1:/sum(1:/(SIGMA:+V))*sum(Y:/(SIGMA:+V))
UCOV=1:/sum(1:/(SIGMA:+V))
	V=1:/V
	sumV=sum(V)
	sumV11=sumV*sumV
	sumV22=sum(V:*V)
	Vtyp=sum(V:*nobsminus1):/(sumV11:-sumV22)
Isq=(SIGMA:/(SIGMA:+Vtyp))
 Q= nobsminus1/(1-Isq)

	st_numscalar("r(df)", nobsminus1)
	st_numscalar("r(Qdf)", nobsminus1)
	st_numscalar("r(N)", nobs)
	st_matrix("r(Ymat)", Y)
    st_matrix("r(Smat)", V)
	st_matrix("r(b)", BB)
	st_matrix("r(V)", UCOV)
	st_matrix("r(vtyp)", Vtyp)
	st_matrix("r(Sigma)", SIGMA)
	st_matrix("r(Q)", Q)
	st_matrix("r(Isq)", Isq)
}

void ubivar(string scalar varlist, string scalar touse)
{
	real matrix              M, Y,  V, UVAR, H1, H2, H3, H11, H21, H31, UVARS, UCOV, UVCOV,  SIGMA, PSI, EVAL
	real colvector        Y1, Y2, V1, V2, COV12, R1, R2, EVEC, WSUM, YWSUM, UMU, UMUCOV, YSI, BB, BSCOV
	real scalar              n1, n2, n12, nobs, nobsminus1, twcorr
	M = Y = Y1 = Y2 = V1 = V2 = COV12 = V = .
	st_view(M,  ., tokens(varlist), touse)
	st_subview(Y1, M, .,  1)
	st_subview(Y2, M, .,  2)
	st_subview(V1, M, .,  3)
	st_subview(V2, M, .,  4)
	st_subview(COV12, M, ., 5)
	Y=M[.,  (1,2)]
	V=M[.,  (3,4)]
	nobs=rows(Y)
	nobsminus1=nobs-1
	R1=J(nobs,1, 1)
	R2=J(nobs,1, 1)
	n1=sum(R1)
	n2=sum(R2)
	n12=sum(R1:*R2)
	 // u-stat based between-study variances and covariance (untruncated)
	 UVAR=J(1, 3, 0)  
	 // estimated between-study variance of y1, tau1.
	 H1=J(nobsminus1,nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		H1[i,(j-1)]=H1[i,(j-1)]:+R1[i]:*R1[j]:*((Y1[i]-Y1[j])^2-V1[i]-V1[j]):/(V1[i]+V1[j])
}
}
	H11=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H11[i,(j-1)]=H11[i,(j-1)]:+R1[i]:*R1[j]:/(V1[i]:+V1[j])
}
}
	H11=2*sum(H11):/(n1:*(n1-1))
	UVAR[1,1]=sum(H1):/(n1:*(n1-1)):/H11   
	// estimated between-study variance of Y2, tau2.

	H2=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		   
		H2[i,(j-1)]=H2[i,(j-1)]:+R2[i]:*R2[j]:*((Y2[i]-Y2[j])^2-V2[i]-V2[j]):/(V2[i]:+V2[j])
}
}
	H21=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		   	H21[i,(j-1)]=H21[i,(j-1)]:+R2[i]:*R2[j]:/(V2[i]:+V2[j])
}
}
	H21=2*sum(H21):/(n2*(n2-1))
	UVAR[1,2]=sum(H2)/(n2:*(n2-1)):/H21 
	if (sum(COV12) !=0) {
	// estimated between-study covariance between Y1and Y2, tau12.
	H3=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H3[i,(j-1)]=H3[i,(j-1)]+R1[i]:*R1[j]:*R2[i]:*R2[j]:*((Y1[i]-Y1[j]):*(Y2[i]-Y2[j])-COV12[i]-COV12[j]):/(COV12[i]:+COV12[j])
	if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  {
	H3[i,(j-1)]=0 
}  
}
}
	H31=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		H31[i,(j-1)]=H31[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:/(COV12[i]:+COV12[j])
	if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0) {
	 H31[i,(j-1)]=0 
}
}
}
H31=2:*sum(H31):/(n12:*(n12-1))
UVAR[1,3]=sum(H3):/(n12:*(n12-1)):/H31 
}
else if (sum(COV12) ==0) {
H3=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H3[i,(j-1)]=H3[i,(j-1)]+R1[i]:*R1[j]:*R2[i]:*R2[j]:*(Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j])
if (R1[i]:*R1[j]:*R2[i]*R2[j]==0)  H3[i,(j-1)]=0   
}
}
UVAR[1,3]=sum(H3):/(n12:*(n12-1))
}
	UVARS=(UVAR[1,1], UVAR[1,3] \ UVAR[1,3], UVAR[1,2])
	// estimation based on truncated between-study variance matrix
	// truncated between-study variance matrix (2 variances and a covariance)
	symeigensystem(UVARS, EVEC=., EVAL=.)
	for (i =1; i <=2;  i++) {
	if (EVAL[1,i] < 0) {
	EVAL[1,i] ==0
}
}
	//UVCOV=(EVEC[,1]*EVAL[1]*EVEC[,1]')+ (EVEC[,2]*EVAL[2]*EVEC[,2]')
	
		UVCOV=EVEC*diag(EVAL)*EVEC'
	
	// estimated between-study variance matrix 
	SIGMA=(UVCOV[1,1], UVCOV[1,2] \ UVCOV[1,2], UVCOV[2,2])
	// twcorr= trucated between-study correlation
	if (UVCOV[1,1]:*UVCOV[2,2]!=0) twcorr=UVCOV[1,2]:/sqrt(UVCOV[1,1]:*UVCOV[2,2])
	else twcorr=0
	if (twcorr >= 1) twcorr=1.000
	if (twcorr <= -1) twcorr=-1.000
   
	SIGMA1=UVCOV[1,1]
	SIGMA2=UVCOV[2,2]
	// estimate of beta and its variance
	WSUM=0
	YWSUM=0
	// pooled mean (beta)
	UMU=J(2, 1, 0) 
	// estimated variance of beta
	UMUCOV=J(1, 3, 0) 
	for (i =1; i <=nobs;  i++) {
	YSI=Y[1::nobs,][i,]
	PSI=(V[1::nobs,][i,1], COV12[i] \ COV12[i], V[1::nobs,][i,2])
	WSUM=WSUM:+ invsym(SIGMA:+PSI)
	YWSUM=YWSUM:+invsym(SIGMA:+PSI):*YSI
}

	YWSUM=YWSUM[,2] + YWSUM[,1]
	UMU=invsym(WSUM):*YWSUM'
	UMU=(UMU[,2] + UMU[,1])
	UMUCOV[1,1]=invsym(WSUM)[1,1]
	UMUCOV[1,2]=invsym(WSUM)[2,2]
	UMUCOV[1,3]=invsym(WSUM)[1,2]
	UCOV=(UMUCOV[1,1], UMUCOV[1,3] \ UMUCOV[1,3], UMUCOV[1,2])
	UMU=UMU'
	BB = (UMU[1,1], UMU[1,2])
V1=1:/V[,1]
sumV1=sum(V1)
sumV11=sumV1:*sumV1
sumV111=sum(V1:*V1)
Vtyp1=sum(V1:*nobsminus1):/(sumV11:-sumV111)
Isq1=SIGMA1:/(SIGMA1:+Vtyp1)
Q1= nobsminus1/(1-Isq1)
V2=1:/V[,2]
sumV2=sum(V2)
sumV22=sumV2:*sumV2
sumV222=sum(V2:*V2)
Vtyp2=sum(V2:*nobsminus1):/(sumV22:-sumV222)
Isq2=SIGMA2:/(SIGMA2:+Vtyp2)
Vtyp=(Vtyp1, Vtyp2)
Q2= nobsminus1/(1-Isq2)
Isq=(Isq1, Isq2)
Q= (Q1,Q2)
st_numscalar("r(df)", nobs-2)
st_numscalar("r(Qdf)", nobsminus1)
st_numscalar("r(N)", nobs)
st_matrix("r(rho)", twcorr)
st_matrix("r(Ymat)", Y)
st_matrix("r(Smat)", V)
st_matrix("r(b)", BB)
st_matrix("r(V)", UCOV)
st_matrix("r(Sigma)", SIGMA)
st_matrix("r(vtyp)", Vtyp)
st_matrix("r(Isq)", Isq)
st_matrix("r(Q)", Q)
}	

void ubirho(string scalar varlist, string scalar touse)
{
	real matrix              M, Y,  V, UVAR, H1, H2, H3, H11, H21, H31, UVARS, UCOV, UVCOV,  SIGMA, PSI, EVAL
	real colvector        Y1, Y2, V1, V2, RHO12, R1, R2, EVEC, WSUM, YWSUM, UMU, UMUCOV, YSI, BB, BSCOV
	real scalar              n1, n2, n12, nobs, nobsminus1, twcorr
	M = Y = Y1 = Y2 = V1 = V2 = RHO12 = V = .
	st_view(M,  ., tokens(varlist), touse)
	st_subview(Y1, M, .,  1)
	st_subview(Y2, M, .,  2)
	st_subview(V1, M, .,  3)
	st_subview(V2, M, .,  4)
	st_subview(RHO12, M, ., 5)
	Y=M[.,  (1,2)]
	V=M[.,  (3,4)]
	nobs=rows(Y)
	nobsminus1=nobs-1
	R1=J(nobs,1, 1)
	R2=J(nobs,1, 1)
	n1=sum(R1)
	n2=sum(R2)
	n12=sum(R1:*R2)
	 // u-stat based between-study variances and covariance (untruncated)
	 UVAR=J(1, 3, 0)  
	 // estimated between-study variance of y1, tau1.
	 H1=J(nobsminus1,nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		H1[i,(j-1)]=H1[i,(j-1)]:+R1[i]:*R1[j]:*((Y1[i]-Y1[j])^2-V1[i]-V1[j]):/(V1[i]+V1[j])
}
}
	H11=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H11[i,(j-1)]=H11[i,(j-1)]:+R1[i]:*R1[j]:/(V1[i]:+V1[j])
}
}
	H11=2*sum(H11):/(n1:*(n1-1))
	UVAR[1,1]=sum(H1):/(n1:*(n1-1)):/H11   
	// estimated between-study variance of Y2, tau2.

	H2=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		   
		H2[i,(j-1)]=H2[i,(j-1)]:+R2[i]:*R2[j]:*((Y2[i]-Y2[j])^2-V2[i]-V2[j]):/(V2[i]:+V2[j])
}
}
	H21=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		   	H21[i,(j-1)]=H21[i,(j-1)]:+R2[i]:*R2[j]:/(V2[i]:+V2[j])
}
}
	H21=2*sum(H21):/(n2*(n2-1))
	UVAR[1,2]=sum(H2)/(n2:*(n2-1)):/H21 
	if (sum(RHO12) !=0) {
	// estimated between-study covariance between Y1and Y2, tau12.
	H3=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H3[i,(j-1)]=H3[i,(j-1)]+R1[i]:*R1[j]:*R2[i]:*R2[j]:*((Y1[i]-Y1[j]):*(Y2[i]-Y2[j])-RHO12[i]:*sqrt(V1[i]:*V2[i])-RHO12[j]:*sqrt(V1[j]:*V2[j])):/(RHO12[i]:*sqrt(V1[i]:*V2[i]):+RHO12[j]:*sqrt(V1[j]:*V2[j]))
	if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  {
	H3[i,(j-1)]=0 
}  
}
}
	H31=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
		H31[i,(j-1)]=H31[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:/(RHO12[i]:*sqrt(V1[i]:*V2[i]):+RHO12[j]:*sqrt(V1[j]:*V2[j]))
	if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0) {
	 H31[i,(j-1)]=0 
}
}
}
H31=2:*sum(H31):/(n12:*(n12-1))
UVAR[1,3]=sum(H3):/(n12:*(n12-1)):/H31 
}
else if (sum(RHO12) ==0) {
H3=J(nobsminus1, nobsminus1, 0)
	for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H3[i,(j-1)]=H3[i,(j-1)]+R1[i]:*R1[j]:*R2[i]:*R2[j]:*(Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j])
if (R1[i]:*R1[j]:*R2[i]*R2[j]==0)  H3[i,(j-1)]=0   
}
}
UVAR[1,3]=sum(H3):/(n12:*(n12-1))
}
	UVARS=(UVAR[1,1], UVAR[1,3] \ UVAR[1,3], UVAR[1,2])
	// estimation based on truncated between-study variance matrix
	// truncated between-study variance matrix (2 variances and a covariance)
	symeigensystem(UVARS, EVEC=., EVAL=.)
	for (i =1; i <=2;  i++) {
	if (EVAL[1,i] < 0) {
	EVAL[1,i] ==0
}
}
	// UVCOV=(EVEC[,1]*EVAL[1]*EVEC[,1]')+ (EVEC[,2]*EVAL[2]*EVEC[,2]')
	
	UVCOV=EVEC*diag(EVAL)*EVEC'
	
	// estimated between-study variance matrix 
	SIGMA=(UVCOV[1,1], UVCOV[1,2] \ UVCOV[1,2], UVCOV[2,2])
	// twcorr= trucated between-study correlation
	if (UVCOV[1,1]:*UVCOV[2,2]!=0) twcorr=UVCOV[1,2]:/sqrt(UVCOV[1,1]:*UVCOV[2,2])
	else twcorr=0
	if (twcorr >= 1) twcorr=1.000
	if (twcorr <= -1) twcorr=-1.000
   
	SIGMA1=UVCOV[1,1]
	SIGMA2=UVCOV[2,2]
	// estimate of beta and its variance
	WSUM=0
	YWSUM=0
	// pooled mean (beta)
	UMU=J(2, 1, 0) 
	// estimated variance of beta
	UMUCOV=J(1, 3, 0) 
	for (i =1; i <=nobs;  i++) {
	YSI=Y[1::nobs,][i,]
	PSI=(V[1::nobs,][i,1], RHO12[i]*R1[i]*R2[i]*sqrt(V[1::nobs,][i,1]*V[1::nobs,][i,2]) \ RHO12[i]*R1[i]*R2[i]*sqrt(V[1::nobs,][i,1]*V[1::nobs,][i,2]), V[1::nobs,][i,2])
	WSUM=WSUM:+ invsym(SIGMA:+PSI)
	YWSUM=YWSUM:+invsym(SIGMA:+PSI):*YSI
}

	YWSUM=YWSUM[,2] + YWSUM[,1]
	UMU=invsym(WSUM):*YWSUM'
	UMU=(UMU[,2] + UMU[,1])
	UMUCOV[1,1]=invsym(WSUM)[1,1]
	UMUCOV[1,2]=invsym(WSUM)[2,2]
	UMUCOV[1,3]=invsym(WSUM)[1,2]
	UCOV=(UMUCOV[1,1], UMUCOV[1,3] \ UMUCOV[1,3], UMUCOV[1,2])
	UMU=UMU'
	BB = (UMU[1,1], UMU[1,2])
V1=1:/V[,1]
sumV1=sum(V1)
sumV11=sumV1:*sumV1
sumV111=sum(V1:*V1)
Vtyp1=sum(V1:*nobsminus1):/(sumV11:-sumV111)
Isq1=SIGMA1:/(SIGMA1:+Vtyp1)
Q1= nobsminus1/(1-Isq1)
V2=1:/V[,2]
sumV2=sum(V2)
sumV22=sumV2:*sumV2
sumV222=sum(V2:*V2)
Vtyp2=sum(V2:*nobsminus1):/(sumV22:-sumV222)
Isq2=SIGMA2:/(SIGMA2:+Vtyp2)
Vtyp=(Vtyp1, Vtyp2)
Q2= nobsminus1/(1-Isq2)
Isq=(Isq1, Isq2)
Q= (Q1,Q2)
st_numscalar("r(df)", nobs-2)
st_numscalar("r(Qdf)", nobsminus1)
st_numscalar("r(N)", nobs)
st_matrix("r(rho)", twcorr)
st_matrix("r(Ymat)", Y)
st_matrix("r(Smat)", V)
st_matrix("r(b)", BB)
st_matrix("r(V)", UCOV)
st_matrix("r(Sigma)", SIGMA)
st_matrix("r(vtyp)", Vtyp)
st_matrix("r(Isq)", Isq)
st_matrix("r(Q)", Q)

}	


void utrirho(string scalar varlist, string scalar touse)
{
	real matrix              M, Y,  V, UVAR, H1, H2, H3, H11, H21, H31, UVARS, UCOV, UVCOV,  SIGMA, PSI, EVAL
	real colvector        Y1, Y2, Y3, V1, V2, V3, RHO12, RHO13 , RHO23,  R1, R2, R3, EVEC, WSUM, YWSUM, UMU, UMUCOV, YSI, BB, BSCOV
	real scalar              n1, n2, n12, nobs, nobsminus1, twcorr
	M = Y = Y1 = Y2 = Y3 = V1 = V2 = V3 = RHO12 = V = RHO13 = RHO23 = .
	st_view(M,  ., tokens(varlist), touse)
	st_subview(Y1, M, .,  1)
	st_subview(Y2, M, .,  2)
	st_subview(Y3, M, .,  3)
	st_subview(V1, M, .,  4)
	st_subview(V2, M, .,  5)
	st_subview(V3, M, .,  6)
	st_subview(RHO12, M, ., 7)
	st_subview(RHO13, M, ., 8)
	st_subview(RHO23, M, ., 9)
	Y=M[.,  (1,2, 3)]
	V=M[.,  (4,5, 6)]
	nobs=rows(Y)
	ndims=cols(Y)
	nobsminus1=nobs:-1
	R1=J(nobs,1, 1)
	R2=J(nobs,1, 1)
	R3=J(nobs,1, 1)
	n1=sum(R1)
	n2=sum(R2)
	n3=sum(R3)
	n12=sum(R1:*R2)
	n13=sum(R1:*R3)
	n23=sum(R2:*R3)
	RHO12 = RHO12:*R1:*R2
	RHO13 = RHO13:*R1:*R3
	RHO23 = RHO23:*R2:*R3

	UVAR=J(1, 6, 0)  //ustat-based between-study variances and covariance (untruncated): tau1, tau2, tau3, tau12, tau13, tau23

H1=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H1[i,(j-1)]=H1[i,(j-1)]:+R1[i]:*R1[j]:*((Y1[i]:-Y1[j])^2:-V1[i]:-V1[j]):/(V1[i]:+V1[j])
}
}

H11=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {       
H11[i,(j-1)]=H11[i,(j-1)]:+R1[i]:*R1[j]:/(V1[i]:+V1[j])
}
}

H11=2:*sum(H11):/(n1:*(n1:-1))
UVAR[1,1]=sum(H1):/(n1:*(n1:-1)):/H11    //estimated between-study variance of Y1, tau1.



H2=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H2[i,(j-1)]=H2[i,(j-1)]:+R2[i]:*R2[j]:*((Y2[i]:-Y2[j])^2:-V2[i]:-V2[j]):/(V2[i]:+V2[j])
}
}

H21=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H21[i,(j-1)]=H21[i,(j-1)]:+R2[i]:*R2[j]:/(V2[i]:+V2[j])
}
}

H21=2:*sum(H21):/(n2:*(n2:-1))
UVAR[1,2]=sum(H2):/(n2:*(n2:-1)):/H21  //estimated between-study variance of Y2, tau2.



H2=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H2[i,(j-1)]=H2[i,(j-1)]:+R3[i]:*R3[j]:*((Y3[i]:-Y3[j])^2:-V3[i]:-V3[j]):/(V3[i]:+V3[j])
}
}

H21=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H21[i,(j-1)]=H21[i,(j-1)]:+R3[i]:*R3[j]:/(V3[i]:+V3[j])
}
}

H21=2:*sum(H21):/(n3:*(n3:-1))
UVAR[1,3]=sum(H2):/(n3:*(n3:-1)):/H21  //estimated between-study variance of Y3, tau3.


// between-study covariance between Y1 and Y2
if (sum(RHO12)!=0) // modified 
{
H12=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H12[i,(j-1)]=H12[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:*((Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j]):-RHO12[i]:*sqrt(V1[i]:*V2[i]):-RHO12[j]:*sqrt(V1[j]:*V2[j])):/(RHO12[i]:*sqrt(V1[i]:*V2[i]):+RHO12[j]:*sqrt(V1[j]:*V2[j]))
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H12[i,(j-1)]=0   

}
}

H121=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H121[i,(j-1)]=H121[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:/(RHO12[i]:*sqrt(V1[i]:*V2[i]):+RHO12[j]:*sqrt(V1[j]:*V2[j]))
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H121[i,(j-1)]=0 
}
}

H121=2:*sum(H121):/(n12:*(n12:-1))
UVAR[1,4]=sum(H12):/(n12:*(n12:-1)):/H121  //estimated between-study covariance between Y1 and Y2, tau12.
} else
{
H12=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H12[i,(j-1)]=H12[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:*(Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j])
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H12[i,(j-1)]=0   

}
}
UVAR[1,4]=sum(H12):/(n12:*(n12:-1))
}


 //between-study covariance between Y1 and Y3
if (sum(RHO13)!=0) //#modified 
{
H13=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H13[i,(j-1)]=H13[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:*((Y1[i]:-Y1[j]):*(Y3[i]:-Y3[j]):-RHO13[i]:*sqrt(V1[i]:*V3[i]):-RHO13[j]:*sqrt(V1[j]:*V3[j])):/(RHO13[i]:*sqrt(V1[i]:*V3[i]):+RHO13[j]:*sqrt(V1[j]:*V3[j]))
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H13[i,(j-1)]=0   

}
}

H131=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H131[i,(j-1)]=H131[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:/(RHO13[i]:*sqrt(V1[i]:*V3[i]):+RHO13[j]:*sqrt(V1[j]:*V3[j]))
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H131[i,(j-1)]=0 
}
}

H131=2:*sum(H131):/(n13:*(n13:-1))
UVAR[1,5]=sum(H13):/(n13:*(n13:-1)):/H131  //estimated between-study covariance between Y1 and Y3, tau13.
} else
{
H13=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H13[i,(j-1)]=H13[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:*(Y1[i]:-Y1[j]):*(Y3[i]:-Y3[j])
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H13[i,(j-1)]=0   

}
}
UVAR[1,5]=sum(H13):/(n13:*(n13:-1))
}



 //between-study covariance between Y2 and Y3
if (sum(RHO23)!=0) //#modified 
{
H23=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H23[i,(j-1)]=H23[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:*((Y2[i]:-Y2[j]):*(Y3[i]:-Y3[j]):-RHO23[i]:*sqrt(V2[i]:*V3[i]):-RHO23[j]:*sqrt(V2[j]:*V3[j])):/(RHO23[i]:*sqrt(V2[i]:*V3[i]):+RHO23[j]:*sqrt(V2[j]:*V3[j]))
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H23[i,(j-1)]=0   

}
}

H231=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {   
H231[i,(j-1)]=H231[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:/(RHO23[i]:*sqrt(V2[i]:*V3[i]):+RHO23[j]:*sqrt(V2[j]:*V3[j]))
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H231[i,(j-1)]=0 
}
}

H231=2:*sum(H231):/(n23:*(n23:-1))
UVAR[1,6]=sum(H23):/(n23:*(n23:-1)):/H231  //estimated between-study covariance between Y2 and Y3, tau23.
} else
{
H23=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H23[i,(j-1)]=H23[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:*(Y2[i]:-Y2[j]):*(Y3[i]:-Y3[j])
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H23[i,(j-1)]=0   

}
}
UVAR[1,6]=sum(H23):/(n23:*(n23:-1))
}
UVARS=(UVAR[1,1], UVAR[1,4], UVAR[1,5] \ UVAR[1,4], UVAR[1,2], UVAR[1,6] \ UVAR[1,5], UVAR[1,6], UVAR[1,3])

symeigensystem(UVARS, EVEC=., EVAL=.)
for (i =1; i <=ndims;  i++) {
if (EVAL[1,i] < 0) {
EVAL[1,i] ==0
}
}

// UVCOV=(EVEC[,1]*EVAL[1]*EVEC[,1]')+ (EVEC[,2]*EVAL[2]*EVEC[,2]')+ (EVEC[,3]*EVAL[3]*EVEC[,3]')

UVCOV=EVEC*diag(EVAL)*EVEC'

SIGMA=(UVCOV[1,1], UVCOV[1,2], UVCOV[1,3] \ UVCOV[2,1], UVCOV[2,2], UVCOV[2,3] \ UVCOV[3,1], UVCOV[3,2], UVCOV[3,3])



	if (UVCOV[1,1]:*UVCOV[2,2]!=0) twcorr12=UVCOV[1,2]:/sqrt(UVCOV[1,1]:*UVCOV[2,2])
	else twcorr12=0
	if (twcorr12 >= 1) twcorr12=1.000
	if (twcorr12 <= -1) twcorr12=-1.000
	if (UVCOV[1,1]:*UVCOV[3,3]!=0) twcorr13=UVCOV[1,3]:/sqrt(UVCOV[1,1]:*UVCOV[3,3])
	else twcorr13=0
	if (twcorr13 >= 1) twcorr13=1.000
	if (twcorr13 <= -1) twcorr13=-1.000
	if (UVCOV[2,2]:*UVCOV[3,3]!=0) twcorr23=UVCOV[2,3]:/sqrt(UVCOV[2,2]:*UVCOV[3,3])
	else twcorr23=0
	if (twcorr23 >= 1) twcorr23=1.000
	if (twcorr23 <= -1) twcorr23=-1.000
	
	SIGMA1=UVCOV[1,1]
	SIGMA2=UVCOV[2,2]
	SIGMA3=UVCOV[3,3]
	twcorr=(twcorr12, twcorr13, twcorr23)
	
// estimate of pooled beta 
WSUM=0
YWSUM=0

 // estimate of beta and its variance
UMU=J(3, 1, 0)  //pooled mean (beta)
UMUCOV=J(1, 6, 0)  //estimated variance of beta

	for (i =1; i <=nobs;  i++) {
YSI=Y[1::nobs,][i,]
PSI=(V[1::nobs,][i,1], RHO12[i]:*R1[i]:*R2[i]:*sqrt(V[1::nobs,][i,1]:*V[1::nobs,][i,2]),RHO13[i]:*R1[i]:*R3[i]:*sqrt(V[1::nobs,][i,1]:*V[1::nobs,][i,3]) \
RHO12[i]:*R1[i]:*R2[i]:*sqrt(V[1::nobs,][i,1]:*V[1::nobs,][i,2]), V[1::nobs,][i,2], RHO23[i]:*R2[i]:*R3[i]:*sqrt(V[1::nobs,][i,2]:*V[1::nobs,][i,3]) \
RHO13[i]:*R1[i]:*R3[i]:*sqrt(V[1::nobs,][i,1]:*V[1::nobs,][i,3]), RHO23[i]:*R2[i]:*R3[i]:*sqrt(V[1::nobs,][i,2]:*V[1::nobs,][i,3]), V[1::nobs,][i,3])
WSUM=WSUM:+ invsym(SIGMA:+PSI)
YWSUM=YWSUM:+invsym(SIGMA:+PSI):*YSI
}

    YWSUM=YWSUM[,3] + YWSUM[,2] + YWSUM[,1]
	UMU=invsym(WSUM):*YWSUM'
	UMU=(UMU[,3] + UMU[,2] + UMU[,1])
	UMUCOV[1,1]=invsym(WSUM)[1,1]
	UMUCOV[1,2]=invsym(WSUM)[2,2]
	UMUCOV[1,3]=invsym(WSUM)[3,3]
	UMUCOV[1,4]=invsym(WSUM)[1,2]
	UMUCOV[1,5]=invsym(WSUM)[1,3]
	UMUCOV[1,6]=invsym(WSUM)[2,3]
	
	UCOV=(UMUCOV[1,1], UMUCOV[1,4], UMUCOV[1,5] \ UMUCOV[1,4], UMUCOV[1,2], UMUCOV[1,6] \ UMUCOV[1,5], UMUCOV[1,6], UMUCOV[1,3])
	UMU=UMU'
	BB = (UMU[1,1], UMU[1,2], UMU[1,3])
V1=1:/V[,1]
sumV1=sum(V1)
sumV11=sumV1:*sumV1
sumV111=sum(V1:*V1)
Vtyp1=sum(V1:*nobsminus1):/(sumV11:-sumV111)
Isq1=SIGMA1:/(SIGMA1:+Vtyp1)
Q1= nobsminus1/(1-Isq1)
V2=1:/V[,2]
sumV2=sum(V2)
sumV22=sumV2:*sumV2
sumV222=sum(V2:*V2)
Vtyp2=sum(V2:*nobsminus1):/(sumV22:-sumV222)
Isq2=SIGMA2:/(SIGMA2:+Vtyp2)
Q2= nobsminus1/(1-Isq2)

V3=1:/V[,3]
sumV3=sum(V3)
sumV33=sumV3:*sumV3
sumV333=sum(V3:*V3)
Vtyp3=sum(V3:*nobsminus1):/(sumV33:-sumV333)
Isq3=SIGMA3:/(SIGMA3:+Vtyp3)
Q3= nobsminus1/(1-Isq3)
Vtyp=(Vtyp1, Vtyp2, Vtyp3)
Isq=(Isq1, Isq2, Isq3)
Q= (Q1, Q2, Q3)
	st_numscalar("r(df)", nobs-3)
	st_numscalar("r(Qdf)", nobsminus1)
	st_numscalar("r(N)", nobs)
	st_matrix("r(rho)", twcorr)
	st_matrix("r(Ymat)", Y)
    st_matrix("r(Smat)", V)
	st_matrix("r(b)", BB)
	st_matrix("r(V)", UCOV)
	st_matrix("r(Sigma)", SIGMA)
	st_matrix("r(vtyp)", Vtyp)
	st_matrix("r(Isq)", Isq)
	st_matrix("r(Q)", Q)
	}
	
	void utrivar(string scalar varlist, string scalar touse)
{
	real matrix              M, Y,  V, UVAR, H1, H2, H3, H11, H21, H31, UVARS, UCOV, UVCOV,  SIGMA, PSI, EVAL
	real colvector        Y1, Y2, Y3, V1, V2, V3, COV12, COV13 , COV23,  R1, R2, R3, EVEC, WSUM, YWSUM, UMU, UMUCOV, YSI, BB, BSCOV
	real scalar              n1, n2, n12, nobs, nobsminus1, twcorr
	M = Y = Y1 = Y2 = Y3 = V1 = V2 = V3 = COV12 = V = COV13 = COV23 = .
	st_view(M,  ., tokens(varlist), touse)
	st_subview(Y1, M, .,  1)
	st_subview(Y2, M, .,  2)
	st_subview(Y3, M, .,  3)
	st_subview(V1, M, .,  4)
	st_subview(V2, M, .,  5)
	st_subview(V3, M, .,  6)
	st_subview(COV12, M, ., 7)
	st_subview(COV13, M, ., 8)
	st_subview(COV23, M, ., 9)
	Y=M[.,  (1,2, 3)]
	V=M[.,  (4,5, 6)]
	nobs=rows(Y)
	ndims=cols(Y)
	nobsminus1=nobs:-1
	R1=J(nobs,1, 1)
	R2=J(nobs,1, 1)
	R3=J(nobs,1, 1)
	n1=sum(R1)
	n2=sum(R2)
	n3=sum(R3)
	n12=sum(R1:*R2)
	n13=sum(R1:*R3)
	n23=sum(R2:*R3)
	COV12 = COV12:*R1:*R2
	COV13 = COV13:*R1:*R3
	COV23 = COV23:*R2:*R3

	UVAR=J(1, 6, 0)  //ustat-based between-study variances and covariance (untruncated): tau1, tau2, tau3, tau12, tau13, tau23

H1=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H1[i,(j-1)]=H1[i,(j-1)]:+R1[i]:*R1[j]:*((Y1[i]:-Y1[j])^2:-V1[i]:-V1[j]):/(V1[i]:+V1[j])
}
}

H11=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {       
H11[i,(j-1)]=H11[i,(j-1)]:+R1[i]:*R1[j]:/(V1[i]:+V1[j])
}
}

H11=2:*sum(H11):/(n1:*(n1:-1))
UVAR[1,1]=sum(H1):/(n1:*(n1:-1)):/H11    //estimated between-study variance of Y1, tau1.



H2=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H2[i,(j-1)]=H2[i,(j-1)]:+R2[i]:*R2[j]:*((Y2[i]:-Y2[j])^2:-V2[i]:-V2[j]):/(V2[i]:+V2[j])
}
}

H21=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H21[i,(j-1)]=H21[i,(j-1)]:+R2[i]:*R2[j]:/(V2[i]:+V2[j])
}
}

H21=2:*sum(H21):/(n2:*(n2:-1))
UVAR[1,2]=sum(H2):/(n2:*(n2:-1)):/H21  //estimated between-study variance of Y2, tau2.



H2=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H2[i,(j-1)]=H2[i,(j-1)]:+R3[i]:*R3[j]:*((Y3[i]:-Y3[j])^2:-V3[i]:-V3[j]):/(V3[i]:+V3[j])
}
}

H21=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H21[i,(j-1)]=H21[i,(j-1)]:+R3[i]:*R3[j]:/(V3[i]:+V3[j])
}
}

H21=2:*sum(H21):/(n3:*(n3:-1))
UVAR[1,3]=sum(H2):/(n3:*(n3:-1)):/H21  //estimated between-study variance of Y3, tau3.


// between-study covariance between Y1 and Y2
if (sum(COV12)!=0) // modified 
{
H12=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H12[i,(j-1)]=H12[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:*((Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j]):-COV12[i]:-COV12[j]):/(COV12[i]:+COV12[j])
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H12[i,(j-1)]=0   

}
}

H121=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
       
H121[i,(j-1)]=H121[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:/(COV12[i]:+COV12[j])
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H121[i,(j-1)]=0 
}
}

H121=2:*sum(H121):/(n12:*(n12:-1))
UVAR[1,4]=sum(H12):/(n12:*(n12:-1)):/H121  //estimated between-study covariance between Y1 and Y2, tau12.
} else
{
H12=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H12[i,(j-1)]=H12[i,(j-1)]:+R1[i]:*R1[j]:*R2[i]:*R2[j]:*(Y1[i]:-Y1[j]):*(Y2[i]:-Y2[j])
if (R1[i]:*R1[j]:*R2[i]:*R2[j]==0)  H12[i,(j-1)]=0   

}
}
UVAR[1,4]=sum(H12):/(n12:*(n12:-1))
}


 //between-study covariance between Y1 and Y3
if (sum(COV13)!=0) //#modified 
{
H13=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H13[i,(j-1)]=H13[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:*((Y1[i]:-Y1[j]):*(Y3[i]:-Y3[j]):-COV13[i]:-COV13[j]):/(COV13[i]:+COV13[j])
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H13[i,(j-1)]=0   

}
}

H131=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H131[i,(j-1)]=H131[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:/(COV13[i]:+COV13[j])
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H131[i,(j-1)]=0 
}
}

H131=2:*sum(H131):/(n13:*(n13:-1))
UVAR[1,5]=sum(H13):/(n13:*(n13:-1)):/H131  //estimated between-study covariance between Y1 and Y3, tau13.
} else
{
H13=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H13[i,(j-1)]=H13[i,(j-1)]:+R1[i]:*R1[j]:*R3[i]:*R3[j]:*(Y1[i]:-Y1[j]):*(Y3[i]:-Y3[j])
if (R1[i]:*R1[j]:*R3[i]:*R3[j]==0)  H13[i,(j-1)]=0   

}
}
UVAR[1,5]=sum(H13):/(n13:*(n13:-1))
}



 //between-study covariance between Y2 and Y3
if (sum(COV23)!=0) //#modified 
{
H23=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
		for (j = i+1; j<=nobs; j++) {
	H23[i,(j-1)]=H23[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:*((Y2[i]:-Y2[j]):*(Y3[i]:-Y3[j]):-COV23[i]:-COV23[j]):/(COV23[i]:+COV23[j])
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H23[i,(j-1)]=0   

}
}

H231=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {   
H231[i,(j-1)]=H231[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:/(COV23[i]:+COV23[j])
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H231[i,(j-1)]=0 
}
}

H231=2:*sum(H231):/(n23:*(n23:-1))
UVAR[1,6]=sum(H23):/(n23:*(n23:-1)):/H231  //estimated between-study covariance between Y2 and Y3, tau23.
} else
{
H23=J(nobsminus1,nobsminus1, 0)
for (i =1; i <=nobsminus1;  i++) {
for (j = i+1; j<=nobs; j++) {
H23[i,(j-1)]=H23[i,(j-1)]:+R2[i]:*R2[j]:*R3[i]:*R3[j]:*(Y2[i]:-Y2[j]):*(Y3[i]:-Y3[j])
if (R2[i]:*R2[j]:*R3[i]:*R3[j]==0)  H23[i,(j-1)]=0   

}
}
UVAR[1,6]=sum(H23):/(n23:*(n23:-1))
}
UVARS=(UVAR[1,1], UVAR[1,4], UVAR[1,5] \ UVAR[1,4], UVAR[1,2], UVAR[1,6] \ UVAR[1,5], UVAR[1,6], UVAR[1,3])

symeigensystem(UVARS, EVEC=., EVAL=.)
for (i =1; i <=ndims;  i++) {
if (EVAL[1,i] < 0) {
EVAL[1,i] ==0
}
}

// UVCOV=(EVEC[,1]*EVAL[1]*EVEC[,1]')+ (EVEC[,2]*EVAL[2]*EVEC[,2]')+ (EVEC[,3]*EVAL[3]*EVEC[,3]')

UVCOV=EVEC*diag(EVAL)*EVEC'

SIGMA=(UVCOV[1,1], UVCOV[1,2], UVCOV[1,3] \ UVCOV[2,1], UVCOV[2,2], UVCOV[2,3] \ UVCOV[3,1], UVCOV[3,2], UVCOV[3,3])



	if (UVCOV[1,1]:*UVCOV[2,2]!=0) twcorr12=UVCOV[1,2]:/sqrt(UVCOV[1,1]:*UVCOV[2,2])
	else twcorr12=0
	if (twcorr12 >= 1) twcorr12=1.000
	if (twcorr12 <= -1) twcorr12=-1.000
	if (UVCOV[1,1]:*UVCOV[3,3]!=0) twcorr13=UVCOV[1,3]:/sqrt(UVCOV[1,1]:*UVCOV[3,3])
	else twcorr13=0
	if (twcorr13 >= 1) twcorr13=1.000
	if (twcorr13 <= -1) twcorr13=-1.000
	if (UVCOV[2,2]:*UVCOV[3,3]!=0) twcorr23=UVCOV[2,3]:/sqrt(UVCOV[2,2]:*UVCOV[3,3])
	else twcorr23=0
	if (twcorr23 >= 1) twcorr23=1.000
	if (twcorr23 <= -1) twcorr23=-1.000
	
	SIGMA1=UVCOV[1,1]
	SIGMA2=UVCOV[2,2]
	SIGMA3=UVCOV[3,3]
	twcorr=(twcorr12, twcorr13, twcorr23)
	
// estimate of pooled beta 
WSUM=0
YWSUM=0

 // estimate of beta and its variance
UMU=J(3, 1, 0)  //pooled mean (beta)
UMUCOV=J(1, 6, 0)  //estimated variance of beta

	for (i =1; i <=nobs;  i++) {
YSI=Y[1::nobs,][i,]
PSI=(V[1::nobs,][i,1], COV12[i], COV13[i] \ COV12[i], V[1::nobs,][i,2], COV23[i] \ COV13[i], COV23[i], V[1::nobs,][i,3])
WSUM=WSUM:+ invsym(SIGMA:+PSI)
YWSUM=YWSUM:+invsym(SIGMA:+PSI):*YSI
}

	UMU=invsym(WSUM):*YWSUM'
	UMU=(UMU[,3] + UMU[,2] + UMU[,1])
	UMUCOV[1,1]=invsym(WSUM)[1,1]
	UMUCOV[1,2]=invsym(WSUM)[2,2]
	UMUCOV[1,3]=invsym(WSUM)[3,3]
	UMUCOV[1,4]=invsym(WSUM)[1,2]
	UMUCOV[1,5]=invsym(WSUM)[1,3]
	UMUCOV[1,6]=invsym(WSUM)[2,3]
	
	UCOV=(UMUCOV[1,1], UMUCOV[1,4], UMUCOV[1,5] \ UMUCOV[1,4], UMUCOV[1,2], UMUCOV[1,6] \ UMUCOV[1,5], UMUCOV[1,6], UMUCOV[1,3])
	UMU=UMU'
	BB = (UMU[1,1], UMU[1,2], UMU[1,3])
V1=1:/V[,1]
sumV1=sum(V1)
sumV11=sumV1:*sumV1
sumV111=sum(V1:*V1)
Vtyp1=sum(V1:*nobsminus1):/(sumV11:-sumV111)
Isq1=SIGMA1:/(SIGMA1:+Vtyp1)
Q1= nobsminus1/(1-Isq1)
V2=1:/V[,2]
sumV2=sum(V2)
sumV22=sumV2:*sumV2
sumV222=sum(V2:*V2)
Vtyp2=sum(V2:*nobsminus1):/(sumV22:-sumV222)
Isq2=SIGMA2:/(SIGMA2:+Vtyp2)
Q2= nobsminus1/(1-Isq2)

V3=1:/V[,3]
sumV3=sum(V3)
sumV33=sumV3:*sumV3
sumV333=sum(V3:*V3)
Vtyp3=sum(V3:*nobsminus1):/(sumV33:-sumV333)
Isq3=SIGMA3:/(SIGMA3:+Vtyp3)
Q3= nobsminus1/(1-Isq3)
Vtyp=(Vtyp1, Vtyp2, Vtyp3)
Isq=(Isq1, Isq2, Isq3)
Q= (Q1, Q2, Q3)
	st_numscalar("r(df)", nobs-3)
	st_numscalar("r(Qdf)", nobsminus1)
	st_numscalar("r(N)", nobs)
	st_matrix("r(rho)", twcorr)
	st_matrix("r(Ymat)", Y)
    st_matrix("r(Smat)", V)
	st_matrix("r(b)", BB)
	st_matrix("r(V)", UCOV)
	st_matrix("r(Sigma)", SIGMA)
	st_matrix("r(vtyp)", Vtyp)
	st_matrix("r(Isq)", Isq)
	st_matrix("r(Q)", Q)
	}


end


