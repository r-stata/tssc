
program _ivcrc_estimator, eclass		

	syntax [anything] [if] [in]  	///
        [,NOConstant				///
	AVErage(string)					///				  
	Ranks(integer 50)			///
	Kernel(string)					///
	GENerate(string)				///
	BANDwidth(string)				///
	BOOTstrap(string)				///
   	DENDOG(varlist fv ts)				///
	USERANK(varlist) 				///
	SAVECOEF(string)				/// 
	VARCOEF(string)  *]

** Preliminaries
if trim("`varcoef'")=="" {
_iv_parse `0'   
local lhs `s(lhs)'
local endog `s(endog)'
local exog `s(exog)'
local inst `s(inst)'
local 0 `s(zero)'			
local vnames = "`endog' `dendog' `exog' _cons"		
local kendog : word count `endog'
tempvar rankstat 
tempname beta subbeta smtb bsub bbw			
marksample touse
markout `touse' `lhs' `exog' `inst' `endog' `dendog'	
if trim("`bandwidth'") == "" local bandwidth .05 
if trim("`average'")=="" local average "0(0)1"
mata: aveparse("`average'")	
if `kendog'==1 & `ascendflag'>0 {
	dis as err "Integral subsets must not overlap"
	error 198
}	
}			
else if trim("`varcoef'")!="" {
if trim("`bandwidth'") == "" {
	dis as err "Option {bf: bandwidth()} must be specified with {bf: varcoef()}"
	error 198
}
if trim("`average'")=="" {
	dis as err "Option {bf: average()} must be specified with {bf: varcoef()}"
	error 198
}			
gettoken varclist 0 : 0, parse(",")
tokenize "`varclist'"
local lhs "`1'"
macro shift 
local exog "`*'" 
fvexpand `exog'
local exog `r(varlist)'
local vnames = "`exog' _cons" 
local kendog : word count `varcoef'	
tempname beta subbeta smtb bsub bbw			
marksample touse
markout `touse' `lhs' `exog' `varcoef'	
mata: aveparse("`average'")	
}		
	
	
	
** SAMPLE AVERAGE METHOD 
if "`sampleave'"=="1" & `kendog'==1 & trim("`varcoef'")=="" {

if "`userank'"=="" {	
display in gr "(estimating the conditional rank of `endog')"  	
qui rank_estimate , rankvar(`rankstat') endogvar(`endog') instvar(`inst') exogvar(`exog') tousevar(`touse') ranks(`ranks') generate(`generate') bootstrap(`bootstrap')
}
else qui gen `rankstat' = `userank' if `touse'
dis in gr "(estimating beta(r) at each r[i] rank in the sample)" 
mata: ivcrc_beta_onevar("`lhs'","`endog' `dendog' `exog'","`rankstat'","`touse'")
qui count if `touse'==1		
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")	
ereturn local cmd "ivcrc"
}
	
	

** SAMPLE AVERAGE METHOD -- multiple basic endogenous variables
if "`sampleave'"=="1" & `kendog'>1 & trim("`varcoef'")=="" {

if "`userank'"=="" {
foreach v of varlist `endog' { 	
	display in gr "(estimating the conditional rank of `v')"
	tempvar rankstat`v'  	
	qui rank_estimate , rankvar(`rankstat`v'') endogvar(`v') instvar(`inst') exogvar(`exog') tousevar(`touse') ranks(`ranks') generate(`generate') bootstrap(`bootstrap')
	local ranklist = "`ranklist' `rankstat`v''"
	if "`savecoef'"!="" local ranknames = "`ranknames' rank_`v'"
}
}
else {
tokenize "`userank'"
local r 1
foreach v of varlist `endog' { 	
	qui gen `rankstat`v'' = `1'
	local ranklist = "`ranklist' `rankstat`v''"
	if "`savecoef'"!="" local ranknames = "`ranknames' rank_`v'"
}	
}
dis in gr "(estimating beta(r) at each r[i] rank vector in the sample)" 
mata: ivcrc_beta_multivar("`lhs'","`endog' `dendog' `exog'","`ranklist'","`touse'")
qui count if `touse'==1		
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")
ereturn local cmd "ivcrc" 
}


	
** GRID METHOD 	
if "`sampleave'"=="" & `kendog'==1 & trim("`varcoef'")=="" {

if "`userank'"=="" {	
display in gr "(estimating the conditional rank of `endog')"  	
qui rank_estimate , rankvar(`rankstat') endogvar(`endog') instvar(`inst') exogvar(`exog') tousevar(`touse') ranks(`ranks') generate(`generate') bootstrap(`bootstrap')
}
else qui gen `rankstat' = `userank' if `touse'
dis in gr "(estimating beta(r) at specified grid points r)" 
mata: ivcrc_beta_grid("`lhs'","`endog' `dendog' `exog'","`rankstat'","`touse'")
qui count if `touse'==1	
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")	
ereturn local cmd "ivcrc"
}



** VARYING COEFFICIENT MODEL
if trim("`varcoef'")!=""  & "`sampleave'"=="1"  & `kendog'==1 {
display in gr "(estimating beta(`=abbrev("`varcoef'",7)') at each `varcoef'[i] in the sample)" 
mata: ivcrc_beta_onevar("`lhs'","`exog'","`varcoef'","`touse'")
qui count if `touse'==1	
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")
ereturn local cmd "ivcrc - varying coefficient estimator"
}
if trim("`varcoef'")!="" & "`sampleave'"=="1"  & `kendog'>1 {
display in gr "(estimating beta(v) at each vector v = (`varcoef') in the sample)" 
mata: ivcrc_beta_multivar("`lhs'","`exog'","`varcoef'","`touse'")
qui count if `touse'==1	
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")
ereturn local cmd "ivcrc - varying coefficient estimator"
}
if trim("`varcoef'")!="" & "`sampleave'"==""  & `kendog'==1 {
display in gr "(estimating beta(`=abbrev("`varcoef'",7)') at each `varcoef'[i] in the sample)" 
mata: ivcrc_beta_grid("`lhs'","`exog'","`varcoef'","`touse'")
qui count if `touse'==1	
ereturn post beta, esample(`touse') obs(`r(N)') depname("`lhs'")
ereturn local cmd "ivcrc - varying coefficient estimator"
}




				
end






program rank_estimate 

	syntax [anything] 			 /// 
	[, RANKVAR(string) 			///
	ENDOGVAR(varlist fv ts) 		///
	INSTVAR(varlist fv ts) 			/// 
	EXOGVAR(varlist fv ts)  		///
	TOUSEVAR(varlist)  			///
	RANKS(integer 50)  			///
	GENERATE(string)  			///
	BOOTSTRAP(string)   * ] 

forval s = 1(1)`= `ranks' - 1' {
	local ss = `s'/`ranks'
	_qreg `endogvar' `instvar' `exogvar' if `tousevar', quantile(`ss') 
	tempvar q_`s' ind_`s'
	predict `q_`s'' if `tousevar'
	gen `ind_`s'' = `q_`s''<=`endogvar' if `tousevar'
	local ind_list `ind_list' `ind_`s''
}
egen `rankvar' = rowmean(`ind_list') if `tousevar'
	
tokenize "`generate'", parse(",")
if "`generate'" != "" & trim("`bootstrap'") == "" {
if "`2'" == "" | ("`2'" == "," & "`3'" == "") {
	gen `1'`endogvar' = `rankvar' if `tousevar'
	display in gr "(conditional rank of `endogvar' saved to `1'`endogvar')"
}
else if "`2'" == "," & ("`3'" == "replace" | "`3'" == "rep" | "`3'" == "repl" | "`3'" == "re" | "`3'" == "r") {
	replace `1'`endogvar' = `rankvar' if `tousevar'
	display in gr "(conditional rank of `endogvar' saved to `1'`endogvar')"
} 
else {
	display as err "Syntax error with rank generate()"
	error 198
}		
}	

end



	
	

mata: 
function aveparse(avestr)
{	
vect = select(tokens(strtrim(avestr),","),strmatch(tokens(strtrim(avestr),","),","):==0)
if (vect[1,cols(vect)]=="report") {
	st_local("subsetcoef",strofreal(1))
	vect = vect[1,1::(cols(vect)-1)]
}
else {
	st_local("subsetcoef",strofreal(0))
}
subsL = substr(vect,J(1,cols(vect),1),strpos(vect,"(")-J(1,cols(vect),1))
subsU = substr(vect,strpos(vect,")")+J(1,cols(vect),1),strlen(vect)-strpos(vect,")"))
gstep = substr(vect,strpos(vect,"(")+J(1,cols(vect),1),strpos(vect,")")-strpos(vect,"(")-J(1,cols(vect),1))
st_local("nsubsets",strofreal(cols(vect)))		
for(i=1;i<=cols(vect);i++) {
	st_local("aveL" + strofreal(i),subsL[1,i])
	st_local("aveU" + strofreal(i),subsU[1,i])
}
if (sum(strtoreal(substr(vect,strpos(vect,"(")+J(1,cols(vect),1),strpos(vect,")")-strpos(vect,"(")-J(1,cols(vect),1))))==0) st_local("sampleave","1")
ascendflag = J(1,cols(vect)-1,0)
for(i=1;i<=cols(vect);i++) {
	if (i<cols(vect)) ascendflag[1,i] = (strtoreal(subsU[1,i])>=strtoreal(subsL[1,i+1]))
	if (strtoreal(gstep)!=J(1,cols(gstep),0)) st_local("int" + strofreal(i),vect[1,i])
}		
st_local("ascendflag",strofreal(sum(ascendflag)))				
}
end





mata:
function ivcrc_beta_onevar(yvar, xvars, rankvars, tousevar)
{
lhs = st_data( . , (yvar) , tousevar )
rhs = st_data( . , (xvars) , tousevar )
R   = st_data( . , (rankvars) , tousevar )
bw  = strtoreal(select(tokens(strtrim(st_local("bandwidth")),","),strmatch(tokens(strtrim(st_local("bandwidth")),","),","):==0))
		
for(h=1;h<=cols(bw);h++) {  	
for(i=1;i<=rows(lhs);i++) {
	if ( (st_local("kernel")=="uniform") | (st_local("kernel")=="rectangle") | (st_local("kernel")=="unif") | (st_local("kernel")=="rec")) {
 		w = (1/2)*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triangle") | (st_local("kernel")=="triangular") | (st_local("kernel")=="tri")) {
		w = ( 1 :- abs( (R :- R[i]):/bw[h] ) ):*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="biweight") | (st_local("kernel")=="biweigh") | (st_local("kernel")=="bi")) {
		w = (15/16)*( ( 1 :- ( (R :- R[i]):/bw[h] ):^2 ):^2 ):*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triweight") | (st_local("kernel")=="triweigh") | (st_local("kernel")=="tri")) {
		w = (35/32)*( ( 1 :- ( (R :- R[i]):/bw[h] ):^2 ):^3 ):*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="cosine") | (st_local("kernel")=="cos")) {
		w = (pi()/4)*cos( (pi()/2)*(R :- R[i]):/bw[h] ):*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="") | (st_local("kernel")=="epanechnikov") | (st_local("kernel")=="epanech") | (st_local("kernel")=="epan") | (st_local("kernel")=="ep")) {
		w = (3/4)*( 1 :- ( (R :- R[i]):/bw[h] ):^2 ):*( abs( (R :- R[i]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="gaussian") | (st_local("kernel")=="gauss") | (st_local("kernel")=="gaus") | (st_local("kernel")=="gau")) {
		w = (1/sqrt(2*pi()))*exp( -(1/2)*( (R :- R[i]):/bw[h] ):^2 )
	}
	else {
		stata(`"display "Error specifying kernel function""')
		exit(error(198))
	}
	if (st_local("noconstant")=="noconstant") wx = sqrt(w):*rhs
	else wx =  sqrt(w):*(rhs , J(rows(rhs),1,1)) 
	if (i==1) betar = ( R[i] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	else betar = betar \ ( R[i] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	if (st_local("savecoef")!="") {
		if (i==1) {
		stata("tempname ivcrc_coef")
		stata(sprintf("file open %s using %s.csv, replace write text",st_local("ivcrc_coef"),st_local("savecoef")))
		stata(sprintf(`"file write %s "bandwidth , rank ,  %s " _n "',st_local("ivcrc_coef"),invtokens(tokens(st_local("vnames")),",")))
		}
		stata(sprintf(`"file write %s "%s , %s" _n"',st_local("ivcrc_coef"),strofreal(bw[h]),invtokens(strofreal(betar[i,.]),",")))	
	}		
}
if ( (strtoreal(st_local("nsubsets"))==1) & (strtoreal(st_local("subsetcoef"))==0) ) {
	tb = select(betar , betar[.,1]:>=strtoreal(st_local("aveL1")))
	tb = select(tb, tb[.,1]:<=strtoreal(st_local("aveU1")))
	mtb = mean(tb)
	if (h==1) {
		st_matrix("beta", mtb[. , 2 .. cols(mtb)])
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", mtb[. , 2 .. cols(mtb)])
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb"')
	}
}
else if ( (strtoreal(st_local("nsubsets"))>1) & (strtoreal(st_local("subsetcoef"))==0) ) {
	for(s=1;s<=strtoreal(st_local("nsubsets"));s++) {
		tb = select(betar , betar[.,1]:>=strtoreal(st_local( sprintf("aveL%s",strofreal(s)))))
		tb = select(tb, tb[.,1]:<=strtoreal(st_local( sprintf("aveU%s",strofreal(s)))))
		if (s==1) subbetar = tb[. , 2 .. cols(betar)]
		else subbetar = subbetar \ tb[. , 2 .. cols(betar)]
	}
	if (h==1) {
		st_matrix("beta", mean(subbetar))
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", mean(subbetar))
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb"')
	}
}
else if ( (strtoreal(st_local("nsubsets"))>1) & (strtoreal(st_local("subsetcoef"))==1) ){
	for(s=1;s<=strtoreal(st_local("nsubsets"));s++) {
		tb = select(betar , betar[.,1]:>=strtoreal(st_local( sprintf("aveL%s",strofreal(s)))))
		tb = select(tb, tb[.,1]:<=strtoreal(st_local( sprintf("aveU%s",strofreal(s)))))
		mtb = mean(tb)
		st_matrix("smtb", mtb[. , 2 .. cols(mtb)])
		stata( sprintf("matrix colnames smtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames smtb = sa_%s_%s_%s:",st_local(sprintf("aveL%s",strofreal(s))),st_local(sprintf("aveU%s",strofreal(s))),strofreal(bw[h])) ) 
		if (s==1) {
			subbetar = tb[. , 2 .. cols(betar)]
			stata(`"matrix subbeta = smtb"')
		}
		else if (s>1) {
			subbetar = subbetar \ tb[. , 2 .. cols(betar)]
			stata(`"matrix subbeta = subbeta , smtb"')
		}
	}
	if (h==1) {
		st_matrix("beta", mean(subbetar))
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , subbeta"')	
	}
	else if (h>1) {
		st_matrix("mtb", mean(subbetar))
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb , subbeta"')
	}
}
}
if (st_local("savecoef")!="") stata(sprintf("file close %s",st_local("ivcrc_coef")))
}
end






mata:
function ivcrc_beta_multivar(yvar, xvars, rankvars, tousevar)
{
lhs = st_data( . , (yvar) , tousevar )
rhs = st_data( . , (xvars) , tousevar )
R = st_data( . , (rankvars) , tousevar )
bw  = strtoreal(select(tokens(strtrim(st_local("bandwidth")),","),strmatch(tokens(strtrim(st_local("bandwidth")),","),","):==0))

for(h=1;h<=cols(bw);h++) {  	  	
for(i=1;i<=rows(lhs);i++) {
	if ( (st_local("kernel")=="uniform") | (st_local("kernel")=="rectangle") | (st_local("kernel")=="unif") | (st_local("kernel")=="rec")) {
 		w = (1/2)*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triangle") | (st_local("kernel")=="triangular") | (st_local("kernel")=="tri")) {
		w = ( 1 :- abs( (R :- R[i,.]):/bw[h] ) ):*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="biweight") | (st_local("kernel")=="biweigh") | (st_local("kernel")=="bi")) {
		w = (15/16)*( ( 1 :- ( (R :- R[i,.]):/bw[h] ):^2 ):^2 ):*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triweight") | (st_local("kernel")=="triweigh") | (st_local("kernel")=="tri")) {
		w = (35/32)*( ( 1 :- ( (R :- R[i,.]):/bw[h] ):^2 ):^3 ):*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="cosine") | (st_local("kernel")=="cos")) {
		w = (pi()/4)*cos( (pi()/2)*(R :- R[i,.]):/bw[h] ):*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="") | (st_local("kernel")=="epanechnikov") | (st_local("kernel")=="epanech") | (st_local("kernel")=="epan") | (st_local("kernel")=="ep")) {
		w = (3/4)*( 1 :- ( (R :- R[i,.]):/bw[h] ):^2 ):*( abs( (R :- R[i,.]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="gaussian") | (st_local("kernel")=="gauss") | (st_local("kernel")=="gaus") | (st_local("kernel")=="gau")) {
		w = (1/sqrt(2*pi()))*exp( -(1/2)*( (R :- R[i,.]):/bw[h] ):^2 )
	}
	else {
		stata(`"display "Error specifying kernel function""')
		exit(error(198))
	}	
	w = exp(rowsum(log(w)))
	if (st_local("noconstant")=="noconstant") wx = sqrt(w):*rhs
	else wx =  sqrt(w):*(rhs , J(rows(rhs),1,1)) 
	if (i==1) betar = ( R[i,.] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	else betar = betar \ ( R[i,.] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	if (st_local("savecoef")!="") {
		if (i==1) {
		stata("tempname ivcrc_coef")
		stata(sprintf("file open %s using %s.csv, replace write text",st_local("ivcrc_coef"),st_local("savecoef")))
		stata(sprintf(`"file write %s "bandwidth , %s ,  %s " _n "',st_local("ivcrc_coef"),invtokens(tokens(st_local("ranknames")),","),invtokens(tokens(st_local("vnames")),",")))
		}
		stata(sprintf(`"file write %s "%s , %s" _n"',st_local("ivcrc_coef"),strofreal(bw[h]),invtokens(strofreal(betar[i,.]),",")))	
	}	
}
if (strtoreal(st_local("nsubsets"))==1) {
	tb = select(betar , rowsum(betar[.,1 .. cols(R)]:>=strtoreal(st_local("aveL1"))):==cols(R))
	tb = select(tb, rowsum(tb[.,1 .. cols(R)]:<=strtoreal(st_local("aveU1"))):==cols(R))
	mtb = mean(tb)	
	if (h==1) {
		st_matrix("beta", mtb[. , 1 + cols(R) .. cols(mtb)])
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = samv_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", mtb[. , 1 + cols(R) .. cols(mtb)])
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = samv_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb"')
	}
}
else if (strtoreal(st_local("nsubsets"))>1)  {
	tb = select(betar , betar[.,1]:>=strtoreal(st_local("aveL1")))
	tb = select(tb, tb[.,1]:<=strtoreal(st_local("aveU1")))
	for(v=2;v<=strtoreal(st_local("nsubsets"));v++) {
		tb = select(tb , tb[.,v]:>=strtoreal(st_local( sprintf("aveL%s",strofreal(v)))))
		tb = select(tb, tb[.,v]:<=strtoreal(st_local( sprintf("aveU%s",strofreal(v)))))
	}
	if (h==1) {
		st_matrix("beta", mtb[. , 1 + cols(R) .. cols(mtb)])
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = samv_%s",strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", mtb[. , 1 + cols(R) .. cols(mtb)])
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = samv_%s",strofreal(bw[h])) )
		stata(`"matrix beta = beta , mtb"')
	}
}
}
if (st_local("savecoef")!="") stata(sprintf("file close %s",st_local("ivcrc_coef")))
}
end








mata:
function ivcrc_beta_grid(yvar, xvars, rankvars, tousevar)
{
lhs = st_data( . , (yvar) , tousevar )
rhs = st_data( . , (xvars) , tousevar )
R = st_data( . , (rankvars) , tousevar )
bw  = strtoreal(select(tokens(strtrim(st_local("bandwidth")),","),strmatch(tokens(strtrim(st_local("bandwidth")),","),","):==0))
  	
for(s=1;s<=strtoreal(st_local("nsubsets"));s++) { 
	stata(sprintf(`"numlist "%s""',st_local(sprintf("int%s",strofreal(s)))))
	if (s==1) grid = strtoreal(tokens(st_global("r(numlist)")))
	else if (s>1) grid = ( grid , strtoreal(tokens(st_global("r(numlist)"))) )
}
for(h=1;h<=cols(bw);h++) {
for(r=1;r<=cols(grid);r++) {		
	if ( (st_local("kernel")=="uniform") | (st_local("kernel")=="rectangle") | (st_local("kernel")=="unif") | (st_local("kernel")=="rec")) {
		w = (1/2)*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triangle") | (st_local("kernel")=="triangular") | (st_local("kernel")=="tri")) {
		w = ( 1 :- abs( (R :- grid[r]):/bw[h] ) ):*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="biweight") | (st_local("kernel")=="biweigh") | (st_local("kernel")=="bi")) {
		w = (15/16)*( ( 1 :- ( (R :- grid[r]):/bw[h] ):^2 ):^2 ):*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="triweight") | (st_local("kernel")=="triweigh") | (st_local("kernel")=="tri")) {
		w = (35/32)*( ( 1 :- ( (R :- grid[r]):/bw[h] ):^2 ):^3 ):*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="cosine") | (st_local("kernel")=="cos")) {
		w = (pi()/4)*cos( (pi()/2)*(R :- grid[r]):/bw[h] ):*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="") | (st_local("kernel")=="epanechnikov") | (st_local("kernel")=="epanech") | (st_local("kernel")=="epan") | (st_local("kernel")=="ep")) {
		w = (3/4)*( 1 :- ( (R :- grid[r]):/bw[h] ):^2 ):*( abs( (R :- grid[r]):/bw[h] ) :<= 1 )
	}
	else if ((st_local("kernel")=="gaussian") | (st_local("kernel")=="gauss") | (st_local("kernel")=="gaus") | (st_local("kernel")=="gau")) {
		w = (1/sqrt(2*pi()))*exp( -(1/2)*( (R :- grid[r]):/bw[h] ):^2 )
	}
	else {
		stata(`"display "Error specifying kernel function""')
		exit(error(198))
	}
	if (st_local("noconstant")=="noconstant") wx = sqrt(w):*rhs
	else wx =  sqrt(w):*(rhs , J(rows(rhs),1,1)) 
	if (r==1) betar = ( grid[r] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	else betar = betar \ ( grid[r] , (invsym(cross(wx,wx))*cross(wx,sqrt(w):*lhs))' )
	if (st_local("savecoef")!="") {
		if (r==1) {
		stata("tempname ivcrc_coef")
		stata(sprintf("file open %s using %s.csv, replace write text",st_local("ivcrc_coef"),st_local("savecoef")))
		stata(sprintf(`"file write %s "bandwidth , rank ,  %s " _n "',st_local("ivcrc_coef"),invtokens(tokens(st_local("vnames")),",")))
		}
		stata(sprintf(`"file write %s "%s , %s" _n"',st_local("ivcrc_coef"),strofreal(bw[h]),invtokens(strofreal(betar[r,.]),",")))	
	}	
}
if ( (strtoreal(st_local("nsubsets"))==1) & (strtoreal(st_local("subsetcoef"))==0) ) {
	tb = select(betar , betar[.,1]:>=strtoreal(st_local("aveL1")))
	tb = select(tb, tb[.,1]:<=strtoreal(st_local("aveU1")))
	mtb = mean(tb)
	if (h==1) {
		st_matrix("beta", mtb[. , 2 .. cols(mtb)])
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", mtb[. , 2 .. cols(mtb)])
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local("aveU1"),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb"')
	}
}
else if ( (strtoreal(st_local("nsubsets"))>1) & (strtoreal(st_local("subsetcoef"))==0) ) {
	for(s=1;s<=strtoreal(st_local("nsubsets"));s++) {
		tb = select(betar , betar[.,1]:>=strtoreal(st_local( sprintf("aveL%s",strofreal(s)))))
		tb = select(tb, tb[.,1]:<=strtoreal(st_local( sprintf("aveU%s",strofreal(s)))))
		if (s==1) subbetar = mean(tb[. , 2 .. cols(betar)]):*( strtoreal(st_local( sprintf("aveU%s",strofreal(s)))) - strtoreal(st_local( sprintf("aveL%s",strofreal(s)))) ):/( strtoreal(st_local( sprintf("aveU%s",st_local("nsubsets")))) - strtoreal(st_local("aveL1")) )
		else subbetar = subbetar \ mean(tb[. , 2 .. cols(betar)]):*( strtoreal(st_local( sprintf("aveU%s",strofreal(s)))) - strtoreal(st_local( sprintf("aveL%s",strofreal(s)))) ):/( strtoreal(st_local( sprintf("aveU%s",st_local("nsubsets")))) - strtoreal(st_local("aveL1")) )
	}
	if (h==1) {
		st_matrix("beta", colsum(subbetar))
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 	
	}
	else if (h>1) {
		st_matrix("mtb", colsum(subbetar))
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb"')
	}
}
else if ( (strtoreal(st_local("nsubsets"))>1) & (strtoreal(st_local("subsetcoef"))==1) ){
	for(s=1;s<=strtoreal(st_local("nsubsets"));s++) {
		tb = select(betar , betar[.,1]:>=strtoreal(st_local( sprintf("aveL%s",strofreal(s)))))
		tb = select(tb, tb[.,1]:<=strtoreal(st_local( sprintf("aveU%s",strofreal(s)))))
		st_matrix("smtb", mean(tb[. , 2 .. cols(betar)]))
		stata( sprintf("matrix colnames smtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames smtb = sa_%s_%s_%s:",st_local(sprintf("aveL%s",strofreal(s))),st_local(sprintf("aveU%s",strofreal(s))),strofreal(bw[h])) ) 
		if (s==1) {
			subbetar = mean(tb[. , 2 .. cols(betar)]):*( strtoreal(st_local( sprintf("aveU%s",strofreal(s)))) - strtoreal(st_local( sprintf("aveL%s",strofreal(s)))) ):/( strtoreal(st_local( sprintf("aveU%s",st_local("nsubsets")))) - strtoreal(st_local("aveL1")) )
			stata(`"matrix subbeta = smtb"')
		}
		else if (s>1) {
			subbetar = subbetar \ mean(tb[. , 2 .. cols(betar)]):*( strtoreal(st_local( sprintf("aveU%s",strofreal(s)))) - strtoreal(st_local( sprintf("aveL%s",strofreal(s)))) ):/( strtoreal(st_local( sprintf("aveU%s",st_local("nsubsets")))) - strtoreal(st_local("aveL1")) ) 
			stata(`"matrix subbeta = subbeta , smtb"')
		}
	}	
	if (h==1) {
		st_matrix("beta", colsum(subbetar))
		stata( sprintf("matrix colnames beta = %s",st_local("vnames")) )
		stata( sprintf("matrix colnames beta = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , subbeta"')	
	}
	else if (h>1) {
		st_matrix("mtb", colsum(subbetar))
		stata( sprintf("matrix colnames mtb = %s",st_local("vnames")))
		stata( sprintf("matrix colnames mtb = sa_%s_%s_%s:",st_local("aveL1"),st_local(sprintf("aveU%s",st_local("nsubsets"))),strofreal(bw[h])) ) 
		stata(`"matrix beta = beta , mtb , subbeta"')
	}
}
}	
if (st_local("savecoef")!="") stata(sprintf("file close %s",st_local("ivcrc_coef")))
}
end



