*! blp 2.0 04april2015
*! David Vincent, email: davivincent@deloitte.co.uk
program blp, eclass
version 10.1
set more off

if replay() {
	if "`e(cmd)'"!="blp" {
		error 301 
	}
	ereturn display
}
else {

syntax varlist [if] [in], 	///
	stochastic(string) 	///
	endog(string) 		///
	markets(name) [ 		///
	draws(integer 200)	///
	Optinsta			///
	Optinstb(string)		///
	Itera				///
	Iterb(string)		///	
	demofile(string)		///
      tolin(real 10E-15) 	///
	tolout(real 10E-12)	///
	initsd(string)		///
	initdemo(string)		///
	elast(string)		///
	NOIsily			///
	NOCons 			///
	ROBUSTWeight 		///
	ROBUST			///
	RANdom			///
	Burn(string) ]		///
			
	
marksample touse								
gettoken y_var exog_vars: varlist					
local exog_vars2 `exog_vars'						

//indicators					
local use_optinst = "`optinsta'"!="" |"`optinstb'"!=""	//use optimal instruments 
local optinst = cond(`use_optinst', "`optinstb'", "")		//optimal instruments (varlist) for endogenous vars
local robustweight = "`robustweight'"!=""				//use robustweighting matrix (i.e. permits E[u_jt,u_kt]!=sig_jk,t)
local robust = "`robust'"!=""						//use robust standard errors 
local noisily = "`noisily'"!=""					//display contraction mapping by market 
local random = "`random'"!=""						//random instead of halton draws								


//exit if share variable outside interval (0,1)
qui sum `y_var'
if r(min)<=0 | r(max)>=1{
	di as error "share variable must be within the interval 0,1"
	exit 498
} 

//exit if iterative estimator specified when no iteration required
if ("`itera'"!="" | "`iterb'"!="") & !`robustweight' & !`use_optinst' {
	di as err "may only specify {opt iterate()} for options {opt robustweight} or {opt optinst()}" 
	exit 198
}

//iterative estimator options
if "`itera'"!=""{
	local numiter=1000	//option iter specified - set to 1000 iterations
}
else if "`iterb'"==""{
	local numiter=1		//iter & iter(#) not specified - set to 1 iteration
}
else{
	//exit if not real
	if missing(real("`iterb'")){
		di as err "{opt iter()} must be a positive integer"	 
		exit 198
	}
	//exit if not an integer or negative
	if `iterb'!=int(`iterb') | `iterb'<1 {
		di as err "{opt iter()} must be a positive integer"	
		exit 198
	}
	local numiter=`iterb'	//set to number specified
}

//exit if draws in monte-carlo integration not a positive integer
if `draws'<=0{
	di as err "{opt draws()} must be an positive integer"
	exit 198
}

//exit if random draws and burns (initial elements dropped in Halton sequences) specified
if `random' & "`burn'"!=""{
	di as err "cannot combine {opt burn()} with {opt random}"
	exit 198
}

//burns options
if "`burn'"==""{
	local burn=15		//defualt value for Halton draws 
}
else{
	//exit if not real
	if missing(real("`burn'")){
		di as err "{opt burn()} must be a non-negative integer"
		exit 198
	}
	//exit if not an integer or negative
	if `burn'!=int(`burn') | `burn'<0 {
		di as err "{opt burn()} must be a non-negative integer"
		exit 198
	}
}

//create constant & include in exogenous varlist
if "`nocons'"=="" {
	tempvar cons
	gen `cons'=1
	local exog_vars `cons' `exog_vars'
}

//parse stochastic input
gettoken eqn_1 stochastic: stochastic, parse(",") 
gettoken eqn_0 stochastic: stochastic, parse(",") 
gettoken lhs rhs_1: eqn_1, parse("=")		//lhs is the first variable with a stochastic parameter
gettoken rhs_0 rhs_1: rhs_1, parse("=")		//rhs_1 is the list of demographic variables in first stochastic parameter 
local stoch_vars `stoch_vars' `lhs'			//variables with stochastic parameters
local rhs `rhs' `rhs_1'					//all demographic variables specified

//continue parsing for remaining varnames in stochastic
local c=1
while "`eqn_0'"==","{
	local c `++c'
	gettoken eqn_`c' stochastic: stochastic, parse(",")
	gettoken eqn_0 stochastic: stochastic, parse(",")
	gettoken lhs rhs_`c': eqn_`c', parse("=")
	gettoken rhs_0 rhs_`c': rhs_`c', parse("=")
	local stoch_vars `stoch_vars' `lhs'
	local rhs `rhs' `rhs_`c''
}

local rows: word count `stoch_vars'			//number of variables with stochastic parameters
local uniq_rhs: list uniq rhs				//unique demographic variables 
local cols: word count `uniq_rhs'			//number of unique demographic variables
local num_rhs_vars: word count `rhs'		//total number of demographic variables in all equations


//initial values for random parameter standard deviations
if "`initsd'"==""{					
	matrix A_INIT_SD=J(1,`rows',0.5)		//default values 0.5
}
else{
	matrix A_INIT_SD=`initsd'			//user specified
	
	//exit if insufficient supplied
	if colsof(A_INIT_SD)<`rows'{
		di as err "insufficient initial values specified in {opt initsd()} for standard deviations of stochastic coefficients"
		exit 498	
	}
	//exit if too many supplied
	else if colsof(A_INIT_SD)>`rows'{	
		di as err "too many initial values specified in {opt initsd()} for standard deviations of stochastic coefficients"
		exit 498	
	}
}

//exit if negative initial values
mata: st_numscalar("neginitsd",sum(st_matrix("A_INIT_SD"):<=0))			
if neginitsd>0{
	di as err "initial values in {opt initsd()} must be positive"
	exit 498
}

//exit if variables in stochastic are not found
foreach var of local stoch_vars {
	capture confirm variable `var'
	if _rc {
		di as err "stochastic coefficient variable " "`var'"  " not found"
		exit 111
	}
}

//exit if market varname not in dataset
capture confirm variable `markets'
if _rc {
	di as err "market identifier " "`markets'"  " not found in share data"
	exit 111
}


//parse demand elasticity input
gettoken elast_x elast_t: elast, parse(",")	
gettoken elast_0 elast_t: elast_t, parse(",")	
gettoken elast_t elast_0: elast_t, parse(",")	
gettoken elast_0 elast_n: elast_0, parse(",")	
local elast_x_vars: word count `elast_x'		//elasticity variable
local elast_t_vars: word count `elast_t'		//markets(numeric) for elasticities to be computed
local elast_n_vars: word count `elast_n'		//product string labels variable (optional)


//option elast specified
if "`elast'"!=""{

	//exit if multiple elasticity variables specified
	if `elast_x_vars'>1{
		di as err "cannot include more than one variable in option {opt elast()}"
		exit 198
	}

	//exit if multiple markets specified 
	if `elast_t_vars'>1{
		di as err "cannot include more than one market in option {opt elast()}"
		exit 198
	}

	//exit if multiple product label variables specified
	if `elast_n_vars'>1{
		di as err "cannot include more than one product name variable in option {opt elast()}"
		exit 198
	}

	//exit if elasticity variable not found
	capture confirm variable `elast_x'
	if _rc{
		di as err "variable " "`elast_x'"  " in option {opt elast()} not found"
		exit 111
	}

	//exit if product label variable not found
	capture confirm variable `elast_n'
	if _rc & "`elast_n'"!=""{
		di as err "variable " "`elast_n'"  " in option {opt elast()} not found"
		exit 111
	}

	local c=0
	foreach var of local stoch_vars {
		local c=`c'+strmatch("`elast_x'","`var'")
	}

	//exit if elasticity variable does not appear in stochastic
	if !`c'{
		di as error "variable " "`elast_x'"  " in option {opt elast()} does not appear in {opt stochastic()} "
		exit 111
	}

	//exit if elasticity market not specified 
	if "`elast_t'"==""{
		di as error "must specify a market to compute elasticities"
		exit 198
	}
	else{
		//exit if elasticity market not observed in data
		qui sum `markets'
		if `elast_t'<r(min) | `elast_t'>r(max){
			di as error "selected market for computing elasticities not found"
			exit 111
		}	
	}
}

//exit if demographic variables not included when demographic variable specified
if "`demofile'"=="" & "`initdemo'"!=""{
		di as err "initial values specified in {opt initdemo()} but no demographic file provided in {opt demofile()}"
		exit 198
}


//demographic file specified

if "`demofile'"!=""{

	//exit when observations are excluded 
	qui count if `touse'
	if r(N)!=_N{
		di as err "cannot combine if or in when using demographic data"
		exit 198
	}

	//exit if model does not include any demographic variables
	if !`cols' {
		di as err "no demographic variables entered but demographic file specified in {opt demofile()}"
		exit 198
	}

	preserve
	use "`demofile'",clear

	//exit if market varname does not match varname in demofile
	capture confirm variable `markets'
	if _rc {
		di as err "market identifier " "`markets'"  " not found in demographic data"
		exit 111
	}

	//exit if demographic variables not found
	foreach var of local uniq_rhs {
		capture confirm variable `var'
			if _rc {
			di as err "demographic variable " "`var'"  " not found in demographic data"
			exit 111
		}
	}

	//create copy of demographic data
	mata: demo_data_in("`uniq_rhs'","`markets'")	

	//exit if the number of demographic draws differs between markets
	if rowsof(uniq_D)!=1{
		di as err "number of demographic draws must be equal between markets, check data"
		exit 498
	}
	else{	
		local draws=uniq_D[1,1]
		di as txt "number of draws set to number in demographic data file"
		di as txt "draws per market is:  " "`draws'"	
	}
	restore

	//initial values for demographic variable coefficients
	if "`initdemo'"==""{
		matrix A_INIT_DEMO=J(1,`num_rhs_vars',0.5)	//default values 0.5
	}
	else{
		matrix A_INIT_DEMO=`initdemo'				//user specified

		//exit if insufficient supplied
		if colsof(A_INIT_DEMO)<`num_rhs_vars'{
			di as err "insufficient initial values specified in {opt initdemo()} for impacts of demographic-variables in stochastic coefficient equations"
			exit 498	
		}

		//exit if too many supplied
		else if colsof(A_INIT_DEMO)>`num_rhs_vars'{
			di as err "too many initial values specified in {opt initdemo()} for impacts of demographic-variables in stochastic coefficient equations"
			exit 498	
		}

	}
	
	//populate the parameter matrix PI in: beta(i)~N(PI*D(i),Sigma)
	local index=0
	matrix PI=J(`rows',`cols',.)					
	forvalues i=1/`rows' {
		forvalues j=1/`cols' {
			local ij=0
			local m: word `j' of `uniq_rhs'	
			foreach v of local rhs_`i' {					
				local ij=`ij'+strmatch("`v'","`m'")			//indicator for inclusion of demographic variable m in ith-stochastic equation
			}
			local index=`index'+`ij'					//location of parameter in initial values vector
			if `ij'{
				matrix PI[`i',`j']=A_INIT_DEMO[1,`index']		//assign parameter value
			}
		}
	}

	//display included demographic variables and initial values
	di as txt "Initial values for included demographic-variables in stochastic coefficient equations"
	matrix rownames PI = `stoch_vars'
	matrix colnames PI = `uniq_rhs'
	matrix list PI, noheader
	
	local a=0
	while !`a' {
		display as txt "Do you wish to continue?: 1=yes, 0=no?" _request(ans)		//ask for user confirmation
		if "$ans"=="0"{
			di as txt "estimation aborted"
			exit
		}
		else if "$ans"=="1" {
			di as txt "estimation continuing"
			local a=1
		}
		else {
			di as err "incorrect selection"
		} 
	}
	
}

//no demographic file specified

else{
	mata: D=.	

	//exit if demographic variables specified
	if `cols' {
		di as err "cannot include demographic variables without specifying {opt demofile()}"
		exit 198
	}
}


//parse endog input
gettoken endog inst: endog, parse("=") 	//endog contains endogenous variables
gettoken inst_0 inst: inst, parse("=")	//inst contains instruments		

//model does not contain any endogenous variables

if "`inst_0'"=="" {				
	
	local inst `endog'			//endog are all instruments
	local endog					//set to empty
	
	foreach var_1 of local exog_vars {
		foreach var_2 of local inst {	
			capture confirm variable `var_2'

			//exit if instrument is not found 
			if _rc {
				di as err "instrument " "`var_2'"  " not found"
				exit 111
			}

			//exit if instrument appears in the exogenous varlist
			if strmatch("`var_1'","`var_2'") {
				di as err "`var_2'" " is exogenous and already used as an instrument"
				exit 498
			}				
		}
	}
} 

//model contains endogenous variables

else{
	
	foreach var_1 of local exog_vars {	
		foreach var_2 of local endog {
			capture confirm variable `var_2'

			//exit if endogenous variable not found
			if _rc {
				di as err "endogenous variable " "`var_2'"  " not found"
				exit 111
			}

			//exit if endogenous variable appears in the exogenous varlist
			if strmatch("`var_1'","`var_2'") {
				di as err "`var_2'" " is included in both the exogenous and endogenous variable list"
				exit 498
			}
		}
	}	

	foreach var_1 of local exog_vars  {	
		foreach var_2 of local inst {	
			capture confirm variable `var_2'

			//exit if instrument not found
			if _rc {
				di as err "instrument " "`var_2'"  " not found"
				exit 111
			}

			//exit if instrument appears in the exogenous varlist
			if strmatch("`var_1'","`var_2'") {
				di as err "`var_2'" " is exogenous and already used as an instrument"
				exit 498
			}
		}
	}
}


local inst_all `exog_vars' `inst'	//all instruments 
local vars `exog_vars' `endog'	//all variables

//exit if more parameters than instruments
if wordcount("`vars' `rhs' `stoch_vars'")>wordcount("`inst_all'"){
		di as err "insufficient instruments"
		exit 481
}

//set to one step estimator if instruments equal parameters
if wordcount("`vars' `rhs' `stoch_vars'")==wordcount("`inst_all'") & `robustweight'{
		di as err "parameters exactly identified, switching from {opt robustweight} to one step GMM-estimator"
		local robustweight=0
}


if "`nocons'"==""{
	local vars2 cons `exog_vars2' `endog'	//model includes a constant 
}
else{
	local vars2 `exog_vars2' `endog'		//model excludes a constant
}

foreach var_1 of local stoch_vars{
	local c=0
	foreach var_2 of local vars2{
		local c=`c'+strmatch("`var_1'","`var_2'")
	}

	//exit if variable stochastic does snot appear in exogenous or endogenous varlist
	if !`c'{
		di as err "stochastic coefficient variable " "`var_1'"  " does not appear as an exogenous or endogenous variable in the model."
		di as err "To include a constant in {opt stochastic()} generate a variable named cons and ensure that {opt nocons()} is not included"
		exit 498
	}
}


//use chamberlain optimal instruments

if `use_optinst' {

	//exit if robust weighting matrix specified
	if `robustweight'{
		di as err "cannot combine {opt robustweight} with { opt optinst()}"
		exit 198
	}


	//exit if no endogenous variable specified but instruments included in optinst()
	if "`endog'"=="" & "`optinst'"!="" {
		di as err "instruments specified in {opt optinst()} but no endogenous variables included in {opt endog()} . 
            di as err "Type {opt optinst}  to use optimal instruments for model without endogenous variables"
		exit 498
	}

	//exit if more endogenous variables specified than instruments included in optinst()
	if wordcount("`endog'")>wordcount("`optinst'"){
		di as err "insufficient instruments specified in {opt optinst()} for endogneous variables"
		exit 481
	}

	foreach var_1 of local exog_vars {
		foreach var_2 of local optinst {
			capture confirm variable `var_2'

			//exit if instrument in optinst() not found 
			if _rc {
				di as err "variable " "`var_2'"  " in {opt optinst()} not found"
				exit 111
			}

			//exit if instrument in optinst() included in the exogenous varlist (already included by default)
			if strmatch("`var_1'","`var_2'") {
				di as err "`var_2'" " in {opt optinst()} is exogenous and already included in the instrument set for " "`endog'""
				exit 498
			}
		}
	}

	foreach var_1 of local endog{
		foreach var_2 of local optinst{
			if strmatch("`var_1'","`var_2'"){

				//exit if instrument in optinst() included in endogenous varlist 
				di as err "`var_2'" " in {opt optinst()} is endogenous and cannot be included"
				exit 498
			}
		}
	}	
}


//call the mata subroutine that estimates the BLP-model
mata: blp("`y_var'","`exog_vars'","`endog'","`inst'",`use_optinst',"`optinst'","`stoch_vars'","`markets'",`robustweight',`robust',`noisily',"`touse'","`elast_x'","`elast_t'","`elast_n'","`nocons'",`draws',`tolin',`tolout',`numiter',`random',`burn')

//post the estimation results
ereturn post b VAR, esample(`touse')
ereturn scalar N=r(N)				//number of observations
ereturn scalar T=r(T)				//number of markets
ereturn scalar conv=conv			//indicator for convergence
ereturn scalar draws=`draws'			//number of random draws

if !`random'{
	ereturn scalar burn=`burn'		//number of burns if halton sequence used
}

ereturn scalar obj=r(obj)			//value of GMM-objective function
ereturn local cmd "blp"				
ereturn matrix initsd=A_INIT_SD		//initial values for random parameter standard deviations

if "`demofile'"!=""{
	ereturn matrix initd=A_INIT_DEMO	//initial values for demographic variable coefficients
}

if "`elast'"!=""{
	ereturn matrix elast=elast		//elasticity matrix
}
	

//display the parameter estimates and options specified
display _newline as txt "GMM estimator of BLP-model" 

if `robustweight'{
	display _newline as txt "GMM weight matrix: robust" _col(45)"Number of obs " _col(70)"=  " as result e(N)
}
else if `use_optinst'{
		display  _newline as txt "Instruments: Chamberlain optimal" _col(45)"Number of obs " _col(70)"=  " as result e(N)
}
else{
	display _newline as txt "GMM weight matrix: unadjusted" _col(45)"Number of obs " _col(70)"=  " as result e(N)
}

display as txt _col(45)"Number of markets" _col(70)"=  " as result e(T)

if `random'{
	display as txt _col(45)"Number of random draws " _col(70)"=  " as result `draws'
}
else{
	display as txt _col(45)"Number of Halton draws " _col(70)"=  " as result `draws'

}
	
if `robust'{
	ereturn local vcetype "Robust"
}
ereturn display
}
end


//mata subroutine that estimates the BLP-model

mata:
void blp(string scalar y_var,
	   string scalar exog_vars,
	   string scalar endog_vars,
         string scalar inst_vars,
	   real scalar use_optinst,
	   string scalar optinst,
	   string scalar stoch_vars,
	   string scalar markets, 
	   real scalar robustweight,
	   real scalar robust,
	   real scalar noisily,
         string scalar touse,
	   string scalar elast_x,
	   string scalar elast_t,
	   string scalar elast_n,
	   string scalar nocons,
	   real scalar draws,
	   real scalar tolin,
	   real scalar tolout,
	   real scalar numiter,
	   real scalar random,
	   real scalar burn)
{

 //note: externals mainly used for variables that are updated by eval_blp and need 
 //to be accessed by other mata subroutines 

 external PI_ID,beta,PI_HAT,R,tol_in,tol_out,F,u,N,V,T,mkt_rows_D
 external mkt,mkt_rows,w,K_1,K_S,K_D,K_PI,K_2,e_R,e_KS

 real matrix X_exog,X_endog,X_int,X_S,X,Z
 real vector ST,FI,A_VEC_INIT
 external D,A				

 //view matrices onto the data
 st_view(s, .,y_var,touse)				//share variable (dependent variable)		
 st_view(X_exog, .,tokens(exog_vars),touse)	//exogenous variables
 st_view(X_endog, .,tokens(endog_vars),touse)	//endogenous variables
 st_view(X_inst, .,tokens(inst_vars),touse)	//standard instruments
 st_view(X_optinst, .,tokens(optinst),touse)	//instruments for endogenous variables
 st_view(X_S, .,tokens(stoch_vars),touse)		//stochastic parameter variables
 st_view(mkt, .,tokens(markets),touse)		//panel identifier (market)
 X=(X_exog,X_endog)					//all variables in mean-utility equation [i.e. delta(jt]
 Z=(X_exog,X_inst)					//all instruments

 //market observations
 mkt_rows=panelsetup(mkt,1)				//start & finish rows in data of each market
 ST=mkt_rows[,1]						//market start rows
 FI=mkt_rows[,2]						//market finish rows

 //scalars
 N=rows(X)							//total number of observations JT
 T=rows(mkt_rows)						//number of markets
 K_1=cols(X)						//number of variables in mean utility equation 
 K_S=cols(X_S)						//number of variables with stochastic coefficients
 K_D=cols(D)						//number of demographic variables
 R=draws							//number of random (or halton) draws
 tol_in=tolin						//tolerance for inner-loop contraction mapping
 tol_out=tolout						//tolerance for outer-loop GMM objective function
 
 //vectors of 1's
 e_R=J(R,1,1)						
 e_KS=J(K_S,1,1)

 //pointers to the marekt specific random or halton draws
 V=J(T,1,NULL)
 for(t=1;t<=T;t++){	
	V[t]=(random ? &rnormal(K_S,R,0,1) : &invnormal(halton(R,K_S,(1+burn+R*(t-1)))'))	//dimension K_S x R
 }

 //GMM-weighting matrix: assumes iid errors
 W=invsym(Z'Z)	
 
 //exponential of the initial mean-utilities w(jt)=exp(delta(jt))
 w=J(N,1,.)
 for(t=1;t<=T;t++){
 	panelsubview(s_t,s,t,mkt_rows)
	w[|ST[t],.\FI[t],.|]=s_t:/(1:-sum(s_t))   
 }
 //beta=J(K_1,1,0)


 //Initial values for standard deviations of stochastic coefficients 

 A_VEC_INIT=log(st_matrix("A_INIT_SD"))				//log scale to ensure non-negativity

 //optimization handle (structure) with default values
 S_H = optimize_init()

 //modify the properties of S
 optimize_init_evaluatortype(S_H, "d1")				//derivative method
 optimize_init_conv_ptol(S_H, tol_out)				//outer-loop tolerance
 optimize_init_technique(S_H, "nr")					//newton method technique
 optimize_init_conv_maxiter(S_H, 50)				//max iterations - operates within iter()
 optimize_init_singularHmethod(S_H, "hybrid")			//if hessian is singular
 optimize_init_which(S_H,"min")					//minimization problem

 //set the intput arguments
 optimize_init_argument(S_H, 1, s)					//product shares
 optimize_init_argument(S_H, 2, X)					//variables in mean utility equation
 optimize_init_argument(S_H, 3, X_S)				//stochastic parameter variables
 optimize_init_argument(S_H, 4, Z)					//all instruments
 optimize_init_argument(S_H, 5, W)					//weighting matrix
 optimize_init_argument(S_H, 6, noisily)				//indicator to display iteration log
 optimize_init_evaluator(S_H, &eval_blp())			//pointer to function being evaluated

 //if model excludes demographic variables
 if(missing(D)){								
	INIT=A_VEC_INIT							//set initial values 
	K_PI=0								//demographic parameters
 }

 //model includes demographic variables
 else{									
	PI_INIT=st_matrix("PI")						//PI matrix (rows = vars with stochastic parms, cols = demographic vars)
	PI_INIT=vec(PI_INIT')						//stack transpose of columns 
	PI_ID=PI_INIT:~=.							//indicator for inclusion of demographic variables
	PI_INIT=select(PI_INIT,PI_ID)					//remove missing variables
	INIT=(A_VEC_INIT,PI_INIT')					//total initial values
	K_PI=sum(PI_ID)							//number of demographic parameters
 }

 K_2=K_S+K_PI								//total heterogeneity parameters 
 optimize_init_params(S_H, INIT)					//set initial values

 //initial estimates of the model
 P = optimize(S_H)							//parameter estimates
 obj=optimize_result_value(S_H)					//value of objective function


 //gmm with optimal instruments or robust weighting matrix		
 if(use_optinst | robustweight){						
	iter=1
	P_diff=tolout+0.1
	while(P_diff>tolout & iter<=numiter){			

		//set display labels
		lab=(use_optinst ? "optimal instruments" : "robust GMM weighting matrix")
		printf("{txt:Estimation iteration with %s}\n",lab+": "+strofreal(iter))
		P_prior=P

		if(use_optinst){
			Z=optInst(X_exog,X_endog,X_optinst,X_S)	//compute optimal instruments
			W=invsym(Z'Z)					//weighting matrix (estimates do not depend on W)
		}
		else{
			S=cov_moments(Z,u,mkt_rows)			//robust estimate of asymptotic variance matrix of sample moments
			W=invsym(S)						//optimal weighting matrix
		}	

		optimize_init_params(S_H, INIT)			//original starting values in first iter
		P=optimize(S_H)
		P_diff=mreldif(P,P_prior)
		obj=optimize_result_value(S_H)	
		INIT=P							//update starting values with previous estimates
		++iter
	}

	if(use_optinst){							//final update of optimal instruments for inference
		Z=optInst(X_exog,X_endog,X_optinst,X_S)
		W=invsym(Z'Z)		
	}
	else{
		S=cov_moments(Z,u,mkt_rows)				//final update of variance matrix
		W=invsym(S)
	}	

 }
 
 
 if(!robustweight){							//robust weighting matrix not used (i.e. one step or optinst)
	if(robust){ 							

 		S=cov_moments(Z,u,mkt_rows)				//robust estimate of asymptotic variance matrix of sample moments
 	}
	 else{								//assume errors are iid
		sigma2_u=(u'u)/(N-(K_1+K_2))
		S=invsym(W)*sigma2_u
 	}
 }
 
 VAR=cov_estimator(X,Z,W,S)						//estimate of asymptotic variance matrix of GMM-estimator

 //labels for stroed estimates
 if(missing(D)){		
	eqn_names=(tokens(stoch_vars))'				//string vector of vars with random parameters
	eqn_vars=J(K_S,1,"SD")						//string vector of SD's (standard deviations)
	eqn_coef=diagonal(A)						//standard deviations of random parameters
 }
 else{	
	dvars=tokens(st_local("uniq_rhs"))				//unique demographic variables	
	eqn_vars=J(K_S,K_D,"")						//rows=random coefficients, cols = demographic variables
	M=J(K_S,K_D,.)					
	PI=st_matrix("PI")						//matrix of initial values (see above)
	c=K_1+K_S+1								//counter 

	for(i=1;i<=rows(PI);i++){					
		for(j=1;j<=cols(PI);j++){						
			if(PI[i,j]!=.){
				eqn_vars[i,j]=dvars[j]			//set element to name of demographic variable if used
				M[i,j]=c					//set element to c-th parameter in (K_1,K_2)
				++c
			}
			else{
				eqn_vars[i,j]=""
			}
		}	
	}
	eqn_names=vec(J(K_D+1,1,tokens(stoch_vars)))		//names of variables with random parameters
	eqn_vars=vec((eqn_vars,J(K_S,1,"SD"))')			//demographic names & SD strings
	eqn_coef=vec((PI_HAT,diagonal(A))')				//demographic coefficients & standard deviations
	Ind=vec((PI:~=.,J(K_S,1,1))')					//indicator if demographic variables included in equation

	eqn_names=select(eqn_names,Ind)				//select rows where demographic variables are included
	eqn_vars=select(eqn_vars,Ind)
	eqn_coef=select(eqn_coef,Ind)
	
	M=(1::K_1\vec((M,(K_1+1::K_1+K_S))'))			//order of coefficients to be displayed
	M=select(M,M:~=.)							//keep demo-vars included in random coefficient equations
 	VAR=matorder(VAR,M)						//rearrange order to correspond to order of M		
 }

 //stored estimates
 conv=optimize_result_converged(S_H)				//convergence achieved
 vars=(tokens(exog_vars),tokens(endog_vars))'			//all variables (covariates)

 if(nocons=="") vars[1]="cons"	

 eqn_names=(J(K_1,1,"Mean utility")\eqn_names)			
 eqn_vars=(vars\eqn_vars)						
 eqn_coef=(beta\eqn_coef)					 	
	
 st_matrix("b",eqn_coef')						//parameter estimates
 mstripe=(eqn_names,eqn_vars)
 st_matrixcolstripe("b",mstripe)					//column stripe beta
 st_matrix("VAR",VAR)							//VAR matrix
 st_matrixcolstripe("VAR",mstripe)					//column stripe VAR
 st_matrixrowstripe("VAR",mstripe) 					//row stripe VAR

 st_numscalar("r(N)",N)							//number of obs
 st_numscalar("r(T)",rows(mkt_rows))				//number of markets
 st_numscalar("conv",conv)						
 st_numscalar("r(obj)",obj)						//objective function value


 //compute and store matrix of demand elasticites
 if(elast_x!="") elast_mat(s,X,X_S,elast_x,elast_t,elast_n,stoch_vars,vars,touse)
	
} 


void eval_blp(todo,theta,s,X,X_S,Z,W,noisily,Q,g,H)	
{
 //constructs GMM-objective function

 real matrix X_S_t,E_t
 real vector s_hat_t,ST,FI,w_t,delta
 real scalar i,j,r,c,t

 external D,beta,A,PI_HAT,R,tol_in,tol_out,D_A_delta,F,mkt_rows,u
 external N,V,T,mkt_rows_D,R,e_R,e_D,mv,w,K_1,K_S,K_D,K_PI,K_2
 
  A=diag(exp(theta[1::K_S]))						//trial values of random parameters in levels
 _diag(A,editvalue(diagonal(A),0,1E-14))			


 //model includes demographic variables
 if(!missing(D)){
	e_D=J(K_D,1,1)
	PI_VEC=theta[K_S+1::cols(theta)]				//trial values of demographic parameters
	PI_HAT=st_matrix("PI")							

	//create matrix of demographic parameters
	c=0
	for(i=1;i<=rows(PI_HAT);i++){
		for(j=1;j<=cols(PI_HAT);j++){
			if(PI_HAT[i,j]!=.){
				c++
				PI_HAT[i,j]=PI_VEC[c]
			}
		}
	}
	_editmissing(PI_HAT,0)			
 }
 
 D_A_delta=J(N,K_2,.)							//JT X K_2 matrix of derivatives of mean utility wrt heterogeneity parameters					
 ST=mkt_rows[,1]								//market start rows	
 FI=mkt_rows[,2]								//market finish rows

 if(noisily){
	displayas("txt")
      printf("{txt:Contraction mapping by market}\n")	//display iteration log
 }

 //computations by market
 mv=0
 for(t=1;t<=T;t++){		
     	if(noisily){
		t
	}
	tol=tol_in
	X_S_t=panelsubmatrix(X_S,t,mkt_rows)			//market observations for variables with random parameters
	panelsubview(s_t,s,t,mkt_rows)				//product shares
	w_t=panelsubmatrix(w,t,mkt_rows)			
	E_t=randomEffects(X_S_t,t)					//individual draws v_ijt where d_ijt=d_jt+v_ijt(theta2)
	e_J=J(1,rows(w_t),1)
	s_hat_t=((w_t:*E_t):/(e_J*(w_t:*E_t):+1))*e_R*(1/R)	//predicted market shares
	r=0

	//contraction mapping
	while (mreldif(ln(s_hat_t),ln(s_t))>tol){ 	
		w_t=w_t:*(s_t:/s_hat_t)							//exponential of mean utiltiies
		s_hat_t=((w_t:*E_t):/(e_J*(w_t:*E_t):+1))*e_R*(1/R)
		++r
		tol=tol_in*10^floor(r/1000)						//reduces the tolerance by 10E-1 every 1000 iterations
	}
	
	w[|ST[t],.\FI[t],.|]=w_t							//populate JT vector 
		
	D_A_delta[|ST[t],.\FI[t],.|]=partialDelta(w_t,E_t,X_S_t,t)		//analytical derivatives 
}

 delta=log(w)										//mean utilities
 beta=invsym(X'Z*W*Z'X)*(X'Z*W*Z'delta)						//estimator of parameters in mean utility equation
 u=delta-X*beta										//JT X 1 vector of residuals

//compute GMM objective function
 if(mv){
	Q=10E+10								//if not defined
 }
 else{
	Q=editmissing((Z'u)'W*(Z'u),10E+10)				//objective function
 }
		
 if(todo) {
 	g=(D_A_delta'*Z*W*Z'*u)'					//analytical derivatives
	
 }

 if(noisily){
	displayas("txt")
      printf("{txt:Estimated standard deviations of random coefficients}\n")
	A
	if(!missing(D)){
		printf("{txt:Estimated impacts of demographic variables (rows=coefficient equations, cols=variables)}\n")
		PI_HAT
	}
	printf("{txt:Gradient of objective function}\n")
	g
 }
				
 _diag(F=J(K_1+K_2,K_1+K_2,0),(J(1,K_1,1),exp(theta[1::K_S]),J(1,K_PI,1)))	//delta method to compute var(theta)

}


real matrix randomEffects(X_S_t,t)
{
 //contructs the individual draws v_ijt where d_ijt=d_jt+v_ijt(theta2)

 external D,A,V,PI_HAT,mv,R,mkt_rows_D
 real matrix E_t
 real scalar j

 j=rows(X_S_t)

 //no demographic variables
 if(missing(D)){
 	E_t=exp(X_S_t*A*(*V[t]))					//individual draws J X R
 }
 else{
	panelsubview(D_t,D,t,mkt_rows_D)	   			//start & finish rows for the mkt demographic draws
	E_t=exp(X_S_t*(A*(*V[t])+PI_HAT*D_t'))
 }
 _editvalue(E_t,0,.)

 if(missing(E_t)){
	E_t=J(j,R,1)
 	++mv
 }
 return(E_t)
}




real matrix partialDelta(w_t,E_t,X_S_t,t)
{
 //contructs the derivatives of the mean-utility wrt to heterogeneity parameters

 external R,V,A,D,PI_ID,e_D,e_KS,mkt_rows_D
 real matrix S_hat_t,D_delta_s_t,D_A_delta,D_PI_s_t
 real vector e_J

 e_J=J(1,rows(w_t),1)
 S_hat_t=((w_t:*E_t):/(e_J*(w_t:*E_t):+1))			 //J X R matrix of individual probabilities 
 
 //derivatives
 _diag(D_delta_s_t=-((S_hat_t)*(S_hat_t)')*(1/R),diagonal((1:-(S_hat_t))*(S_hat_t)'*(1/R)))					//mean utility wrt shares

 D_A_s_t=(X_S_t:*((S_hat_t)*(*V[t]'))-(S_hat_t)*(((*V[t]):*(X_S_t'*(S_hat_t)))'))*(1/R)*A						//shares w.r.t. s.d. parameters
 
 if(missing(D)){	

 	D_A_delta=-(luinv(D_delta_s_t))*D_A_s_t			//full matrix of derivatives
 }
 else{

	panelsubview(D_t,D,t,mkt_rows_D)				//rows for the demographic draws of market t

	//derivatives
	D_PI_s_t=(((X_S_t#e_D'):*(S_hat_t*(e_KS#D_t')')-S_hat_t*((e_KS#D_t'):*(X_S_t#e_D')'S_hat_t)')*(1/R)):*(PI_ID')	//shares wrt demographic parameters
	
	D_PI_s_t=select(D_PI_s_t, PI_ID':~=0)			//select derivatives  where demographic variables are included
	
	D_A_delta=-(luinv(D_delta_s_t))*(D_A_s_t,D_PI_s_t)	//full matrix of derivatives		
 }
 return(D_A_delta)
}



real matrix optInst(X_exog,X_endog,X_optinst,X_S)
{
 //computes approximate Chamberlain optimal instruments: Zt*=E[-X_exog,-X_endog_hat,D_A_delta_hat]
 

 external mkt_rows,N,beta,T,V,R,K_2
 real matrix D_A_delta_hat,Z2,X,X_hat,X_S_hat
 real matrix X_S_hat_t,E_t
 real vector ST,FI,w_hat,w_hat_t
 real scalar t
 
 D_A_delta_hat=J(N,K_2,0)						//JT X K_2 matrix of derivatives of mean utility wrt heterogeneity parameters		
 ST=mkt_rows[,1]								//market start rows
 FI=mkt_rows[,2]								//market finish rows

 //compute estimate of E[X\Z] - same coefficients for all markets
 Z2=(X_exog,X_optinst) 							//exogenous variables and those appearing in endogenous variable equations
 X=(X_exog,X_endog)							//exogenous and endogenous variables
 Pz=Z2*invsym(Z2'Z2)*Z2'						//projector matrix
 X_hat=Pz*X									//optimal instruments from first stage regression. Note: X_exog = prediction
 X_S_hat=Pz*X_S								//variables with random parameters X_S. Must be a subset of X
 w_hat=exp(X_hat*beta)							//predicted exp(delta) for all markets
 
//construct optimal instruments for each market
 for(t=1;t<=T;t++){
 	X_S_hat_t=panelsubmatrix(X_S_hat,t,mkt_rows)		//mkt_rows define the set of products for each market	
	E_t=randomEffects(X_S_hat_t,t)				//individual draws
	w_hat_t=panelsubmatrix(w_hat,t,mkt_rows)				
	D_A_delta_hat[|ST[t],.\FI[t],.|]=partialDelta(w_hat_t,E_t,X_S_hat_t,t)	//optimal instruments for heterogeneity parameters. Sets unobservables to zero	
 }	

 return(-X_hat,D_A_delta_hat)

}



real matrix cov_moments(real matrix Z, real colvector u, real matrix mkt_rows)
{
 //estimator of the asymptotic variance matrix of sample moments: S=1/T*sum(Zt'ut*ut'Zt)

 external T
 real matrix S
 real scalar t

 S=J(cols(Z),cols(Z),0)
 for(t=1;t<=T;t++){
	panelsubview(u_t,u,t,mkt_rows)				//market residuals
	panelsubview(Z_t,Z,t,mkt_rows)				//market instruments (standard or optimal)		
	S=S+Z_t'*(u_t*u_t')*Z_t	
 }
 return(S)
}


real matrix cov_estimator(real matrix X,real matrix Z,real matrix W,real matrix S)
{
 //estimator of the asymptotic variance matrix of the GMM-estimator

 external F,D_A_delta
 real matrix VAR,G

 G=Z'(X,D_A_delta)							//matrix of derivatives of sample moments wrt parameters

 VAR=(invsym(G'W*G))*G'W*S*W*G*(invsym(G'W*G))			//estimated variance matrix
 return(F*VAR*F')								//apply delta method for var(theta)
}


void demo_data_in(string scalar demovars, string scalar markets)
{
 //reshapes and stores demographic draws D, and mkt_rows_D

 external D,mkt_rows_D

 D=st_data(., tokens(demovars))					//demographic data
 mkt_D=st_data(., markets)
 mkt_rows_D=panelsetup(mkt_D,1)
 st_matrix("uniq_D",uniqrows(mkt_rows_D[,2]-mkt_rows_D[,1]:+1)) 
}


void elast_mat(real vector s,
		   real matrix X,
		   real matrix X_S,
	         string scalar elast_x,
		   string scalar ts, 
		   string scalar elast_n,
	         string scalar stoch_vars,
               string vars,
               string scalar touse)
{
 //computes and labels the demand elasticities for a selected market and variable

 external A,beta,D,mkt_rows,R,V,PI_HAT,mkt_rows_D,mkt,T,w
 real matrix X_S_t,E_t,PED,Ratio_t
 real vector I_xs,I_x,s_t,x_t,e_J,b_x_i,w_t,nolabel
 real scalar j,sd_x,b_x


 t=select((1::T),uniqrows(mkt):==strtoreal(ts))			//rescale t to represent location in order 				 
 I_xs=strmatch(elast_x,tokens(stoch_vars))			//location of elasticity variable in variables with random parameters (stoch-vars)
 I_x=strmatch(elast_x,vars')						//location of elasticity variable in vars  
 X_S_t=panelsubmatrix(X_S,t,mkt_rows)				//random parameter variables for selected market	 
 s_t=panelsubmatrix(s,t,mkt_rows)					//shares for selected market
 x_t=select(X_S_t,I_xs)							//selected elasticity variable
 b_x=select(beta,I_x')							//constant in elasticity var coefficient equation 
 sd_x=select(diagonal(A),I_xs')					//standard deviation in elasticity var coefficient equation 

 //model excludes demographic variables
 if(missing(D)){
 	b_x_i=b_x:+select(*V[t],I_xs')*sd_x				//1xR draws of elasticity-variable coefficient
 }
 else{
	panelsubview(D_t,D,t,mkt_rows_D)		
	pi_x=select(PI_HAT,I_xs')	
	b_x_i=b_x:+select(*V[t],I_xs')*sd_x+(D_t*pi_x')'	//draws with demographic variables
 }

 j=rows(s_t)								//number of products in selected market
 e_J=J(1,j,1)
 E_t=randomEffects(X_S_t,t)						//individual draws
 w_t=panelsubmatrix(w,t,mkt_rows)									
 S_t=((w_t:*E_t):/(e_J*(w_t:*E_t):+1))				//J X R matrix of individual probabilities 					
 Ratio_t=(1:/s_t)*x_t'
 PED=-Ratio_t:*(S_t:*b_x_i)*S_t'*(1/R)			
 _diag(PED,diagonal(Ratio_t:*(S_t:*b_x_i)*(1:-S_t)'*(1/R)))					//full matrix of elasticities 

 //label matrix with product names & header with elasticity variable
 if(elast_n!=""){		
 	st_sview(names, .,elast_n,touse)								//product labels (strings)
	panelsubview(names_t,names,t,mkt_rows)							//labels for selected market
		
	rstripe=((("% change in")\J(j-1,1,"")),substr(names_t,1,30))			//row matrix stripes
	cstripe=((("1% rise in "+elast_x)\J(j-1,1,"")),substr(names_t,1,30))		//column matrix stripes
 }
 else{
 	nolabel=1::j											//no product labels
	rstripe=((("% change in")\J(j-1,1,"")),strofreal(nolabel))			
	cstripe=((("1% rise in "+elast_x)\J(j-1,1,"")),strofreal(nolabel))		 
 }

 st_matrix("elast",PED)							//store matrix
 st_matrixcolstripe("elast",cstripe)				//column matrix stripe
 st_matrixrowstripe("elast",rstripe)				//row matrix stripe

}


real matrix matorder(X,p)
{
 //order the elements in X[i,j] to correspond to p[i]p[j]

 real matrix Y
 real scalar i,j,J
 Y=X
 J=rows(X)
 for(i=1;i<=J;i++){
	for(j=1;j<=J;j++){
		Y[i,j]=X[p[i],p[j]]
	}
 }	
return(Y)
}



end
