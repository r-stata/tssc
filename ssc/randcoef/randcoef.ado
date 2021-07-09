*********************************************************************************
* 	randcoef                                                      			    *
*	v 14.0  15April2020	by	Oscar Barriga Cabanillas	- obarriga@ucdavis.edu	*
*							Aleks Michuda               - amichuda@ucdavis.edu	*
*********************************************************************************

*! Added error message if multicollinearity stops the optimization
*! Added error message choice and endogenopus variables are not dummies
*! Added  set matastrict off to avoid conflicts with recent Mata updates

pause on
cap program drop randcoef
program define randcoef , eclass

tempname mat_aux
tempname mat_aux10
tempname mat_aux20
tempname mat_aux30
tempname mat_var
tempname mat_var10
tempname mat_var20
tempname v_1
tempname varcov
tempname restrict
tempname d
tempname V

version 13.0

	syntax varlist(min = 2 max = 5)					///
		[if]	 ,									///
		CHOICE(varlist min = 2 max = 5)				///
		[											///
		CONTROLS(varlist min = 1)					///
		METhod(string)								///
		MATrix(string)								///
		SHOWREG										///		
		ENDOgenous(varlist min = 2 max = 5)			///
		WEIGHTing(string)                           ///
		KEEP										///
		]


*1) Identifying method

loc method = upper("`method'")
loc weighting = upper("`weighting'")
		
if ("`method'" == "" | "`method'" == "CRE" | "`method'" == "CRC" )  {
	if ("`method'" == "" | "`method'" == "CRE") {
		loc meth = "default method: CRE"
		
		loc meth_safe = "CRE"   // To guarantee that this method is actually used
	
	}
	if ("`method'" == "CRC") {
		loc meth = "method: CRC"
		loc meth_safe = "CRC"
	}
}
else {
	di in red "method selected is not allowed"
	error
}

* 2) If method is not CRC, endogenous and weighting cannot be used		

if "`meth_safe'" == "CRE" {

	if "`endogenous'" != "" {
		di in red "Adding extra endogenous variables is only possible in the CRC model"
		error	
	}
	
	if "`weighting'" != "" {
		di in red "Different Weighting Matrices are only possible in the CRC model"
		error
	}
	
}
* 2.1) An error for not specifying the weighting matrices correctly

if "`meth_safe'" == "CRC" {
	
	if ("`weighting'" == "EWMD" | "`weighting'" == "DWMD" ) {
		noi di in yellow "{title: RUNNING MODEL WITH `weighting' WEIGHTING MATRIX}"
	}
	else if ("`weighting'" == "OMD" | "`weighting'" == "") {
		noi di in yellow "{title: RUNNING MODEL WITH OMD WEIGHTING MATRIX}"
	}
	else {
		noi di in red "{title: WEIGHTING MATRIX NOT CORRECTLY SPECIFIED}"
		error
	}
}	

* 3) Check that both the variables in the choice option are dummies 

* 3.1) For the choice variables

foreach var of varlist `choice' {
	
	* Get values. Note that missing values are not taken into account
	qui: levelsof `var' , loc(levels)
	
	if wordcount("`levels'") != 2 {
		noi di in red "The choice variable `var' is not a dummy variable. This is requiered construction"
		error
	}
	
}



/* 	Organizes the equation to be estimated by SUREG, taking as inputs information on the 
	outcome, choice and control options, and from the endogenous option if necessary*/

*0) Define locals that will contain info

* Coming from the command: It is the same for CRC and CRE
loc regression_y = "`varlist'"	

* Will Differ from  CRC and CRE
loc regression_x = ""


*1) We need to create the interactions: They are NOT necessary for the CRE model

if "`meth_safe'" == "CRE" {
	
	loc regression_x = "`choice' `controls'"	
}
if "`meth_safe'" == "CRC" {

	* If not additional endogenous variables, the combination is simple
			
	* The number of combinations is 2^n - 1
	loc number_choice = wordcount("`choice'")
	loc number_interactions = (2^`number_choice')-1
	
	/* We proceed to create the variables in order. Tuples create them in the opposite
	order we need to reorganize the choice local, that is we reorganize them */

	loc choice_ordered = ""
	
	forvalues j = 1(1)`number_choice' {
		
		loc aux = word("`choice'" , `j')
		loc choice_ordered = "`aux' `choice_ordered' "
	}
	
	cap tuples `choice_ordered'
	
	* In the case the command tuples is not installed an error message shows up
	if _rc == 199 {
	
		noi di in red "Please install the command tuples by using SSC"
		error
	}
	
	
	* Now ve create the variables
	
	forvalues j = 1(1)`number_interactions' {
			
		* if it is not a variable that results from an interaction, no action is needed
		
		if wordcount("`tuple`j''") == 1 {
		
			* The vector will be:
			// independent variables
			loc regression_x = "`regression_x' `tuple`j''"
			
		}
	
		if wordcount("`tuple`j''") != 1 {
		
			* replace spaces by * so the interaction can be created
			*loc name_`j' = subinstr("`tuple`j''" , " " , "_", .)
			loc name_`j' = `j'
			*loc name_`j' = substr("`name_`j''",1,27)
			
			
			loc tuple`j' = subinstr("`tuple`j''" , " " , "*", .)
			
			tempvar int_`name_`j'' 
			gen `int_`name_`j''' = `tuple`j''
			
			
			* The vector will be:
			// independent variables
			loc regression_x = "`regression_x' `int_`name_`j'''"
			
			* if option keep is used, we make a variable and not a tempvar
			if "`keep'" != "" {
				
				gen int_`name_`j'' = `int_`name_`j''' 
			}		
		}
	}	
		
	*** In the case endogenous variables were included, they must also be added to the independent
	***	variables: Added to the local regression_x
	
	if "`endogenous'" != "" {
			
		/* The order must be
		i)		Choices as in the regular CRC with their interactions
		ii)		Endogenous
		iii) 	Each Endogenous interacted with i)
		*/
		
		// i) is already done local regression_x
		
		// I proceed to add ii)
		loc regression_x_endo = "`regression_x' `endogenous'"
		

		// Now iii) that is a bit more difficult
		
		*  For each variable in the endogenous local, we interact it with each element already in regression_x
		loc num = wordcount("`endogenous'")
		forvalues j = 1(1)`num' {
		
			loc aux = word("`endogenous'" , `j')
			
			* Each var in regression_x
			loc num2 = wordcount("`regression_x'")
			forvalues q = 1(1)`num2' {
				
				loc aux2 = word("`regression_x'" , `q')
				
				tempvar int_endo`j'_choice`q'
				gen `int_endo`j'_choice`q'' = `aux'*`aux2'
				
				loc regression_x_endo = "`regression_x_endo' `int_endo`j'_choice`q''"
				
				* if option keep is used, we make a variable and not a tempvar
				if "`keep'" != "" {
					
					gen int_endo`j'_choice`q' = `int_endo`j'_choice`q''
				}				
				
			}
		}
	
	* local with all the interactions from steps i) ii ) iii)	
	loc regression_x = "`regression_x_endo'"		
		
	}
	* Leave the old local for hmean later
	loc hmean_loc = "`regression_x'"
	
	* Add extra controls.
	loc regression_x = "`regression_x' `controls'"

}


*2) observations to be used are marked down

tempvar touse		

if  "`if'" == "" {

	mark `touse' 
}
else {

	mark `touse'  `if'
}

*3) We verify what matrix is used in the derivation: Automatic or not

*** Restriction matrix CAN be provided in the CRE model, but the default is automatically created matrices

if "`meth_safe'" == "CRE" {
	
	* If matrix not provided
	if "`matrix'" == "" {
		noi disp in red  _n "{title: Restriction matrix not defined; deriving it automatically}"
		loc meth_type = "CREauto"
	}
	else {
		noi disp in red  _n "{title: Restriction matrix provided by the user}"
		loc meth_type= "CREman" 	// if a restriction matrix was provided
	}
}

*4) The number of Variables of interest

/* In the CRE model, the number of coefficients that are taken from the regression,
that is, structural parameters equals the number of years	
Note that the regression_y is used to indicate the number of periods we are dealing with.
It is important, especially in the CRC model, since it determines the number og structural 
parameters
*/
if "`meth_safe'" == "CRE" {

	loc intvar = wordcount("`regression_y'")
}

/* CRC model requires to subtract a subset of the independent variables from the regression_x.
How many depends on the model that is been run. Specifically, the number of years (T) available 
in the panel, as well as the number of endogenous regressors. The local  intvar  indicates the number.
Note that in the CRC, the number of structural parameters is more complex than in the CRE model, nut
still is a function of wordcount("`regression_y'"), that is the  number of periods, as well as the
number of endogenous variables we deal with.

The local endogenous tells the command how many endogenous variables the user wants to use. The default
is no extra endogenous variable.
*/

loc endo_number = wordcount("`endogenous'")

if "`meth_safe'" == "CRC" {
	
	** If no extra endogenous variable was used:
	// CRC model uses (2^T)-1 to account for the interactions
	if `endo_number' == 0  {
		loc intvar = (2^wordcount("`regression_y'"))-1
	}
	
	** When extra endogenous variables are included:
	// CRC model uses [(2^T)-1]+[T*2^T] to account for the interactions
	*NEEDS TO BE ADAPTED AS MORE YEARS ARE PROGRAMMED ********************************************************************************************!!!!!!
	if `endo_number' != 0  {
		loc intvar = ((2^wordcount("`regression_y'"))-1)+wordcount("`regression_y'")*(2^wordcount("`regression_y'"))
	}
/*
	// NOT YET PROGRAM
	if inrange(`endo_number',0,3) != 1  {
		di in red "go home"
		error
	}	
	*NEEDS TO BE ADAPTED AS MORE YEARS ARE PROGRAMMED ********************************************************************************************!!!!!!
*/
}
*

* 5)  This loop identifies the model used, allowing the user to verify it
loc total_vars = ""
* 5.1) Gets information to display the exact model that is being estimated

local crlf "`=char(10)'`=char(13)'"
tempname sc
scalar `sc' = ""

loc label_v = 1

// First loop is to get the labels several times, not only for the first elements
// If we do not do it, the tabdisp will only show labels for the first `intvar' elements

loc loop_count = wordcount("`regression_y'")

forvalues j = 1(1)`loop_count' {

	forvalues i = 1(1)`intvar' {	

		local var = word("`regression_x'" , `i')
						
		local total_vars  = "`total_vars'  `var' "
			
		// 2) Gets information to display the exact model that is being estimated
		label define var_loc `label_v' "`var'" , add modify 

		loc ++label_v
		
		scalar  `sc' =  `sc' + `"`crlf' `var'"'
		///	
	}
}
	
* 6) Summarizes what is being estimated: Showreg determines if the user wants to see the regression outputs
if "`showreg'" == "" {
		
	noi disp in red  _n "{title:Equations used in sureg:}" 	///
	_column(1) in y "`regression_y' = `regression_x' " 		///
	_n ""													///
	_n in red  _n "{title:The model used is :}" 			///
	_column(1)  in y "  `meth'" 							///
	_n ""													///
	_n in red   "{title:The variables of interest are :}" 	///
	_column(1)  in y "`regression_x'"						///		
	
	* Regression 
	qui sureg (`regression_y' = `regression_x') if `touse'
	
}	
else {

	noi disp in red  _n "{title:The variables of interest are :}" 	///
	_column(1)  in y " `regression_x'"								///			
	_n in red  "{title:The model used is :}" 						///
	_column(1)  in y "  `meth'" 									///
	_n ""			

	* Regression 
	sureg (`regression_y' = `regression_x') if `touse'	
}

* 6.1) Saving important results from Sureg 
tempname bsu
tempname Sigmasu
tempname Vsu

local Nsu= e(N)
mat `bsu' = e(b)
mat `Sigmasu' = e(Sigma)
mat `Vsu' = e(V)



*************************************
*7) Obtaining the betas
*************************************

/* 	First build the parameter vector, which should be [`intvar',1]
*/

* 7.1)  identify elements in first equations
loc count = wordcount("`regression_x'")

* Loop that extracts the info from the matrices taking into account how many 
* equations are estimated in the sureg

matrix `mat_aux' = e(b)

matrix `mat_aux10' = `mat_aux'[1,1..`intvar']

* Counting local
loc count_reg = wordcount("`regression_y'")

forvalues c = 2(1)`count_reg' {
	
	loc count2 = `count'+2
	loc count3 = `count2'+`intvar'-1
	
	capture {
		matrix `mat_aux10' = nullmat(`mat_aux10') , `mat_aux'[1,`count2'..`count3']
	}
	if _rc==503 {
		di in red "There's a conformability error; did you add all the variables?"
		exit 503
	}
	
	// the plus 1 accounts for the presence of the constant, that is not counted in wordcount("`regression_x'")
	loc count = `count' + wordcount("`regression_x'") + 1
}
*

matrix `mat_aux10'  = `mat_aux10''

* 7.2)  Building the variance-covariance matrix: It should be [`intvar'^2,`intvar'^2s]

* identify elements in first equations
loc count = wordcount("`regression_x'")

matrix `mat_var' = e(V)

matrix `v_1' = `mat_var'[1..`intvar',1..`intvar']

// Initiates the varcov matrix
mat `varcov'  =  `v_1'  


forvalues c = 2(1)`count_reg' { 
	
	tempname v_`c'
	
	loc count2 = `count'+2
	loc count3 = `count2'+`intvar'-1
	
	matrix `v_`c'' = `mat_var'[`count2'..`count3',`count2'..`count3']
	// mat_capp only allows for adding one matrix at the time
	mat_capp `varcov' : `varcov' `v_`c'' , miss(0)

	loc count = `count' + wordcount("`regression_x'") +1
}
*


* 7.3) Clear the eclass memory to get rid of extra coefficients 

ereturn clear
 
******************************************************************************************************************************

*************************************
* 8)  Now, it estimates the structural parameters using optimal minimum distance
*************************************

* Save for later display as tabdisp
tempname output1
tempname output2

**********************************************
* 8.1)  Implementation of the CRE model
**********************************************
	
if "`meth_safe'" == "CRE" {
	
	**** If the restriction matrix was provided
	if "`meth_type'" == "CREman" {

		//------------------------	
		*Third build the restriction matrix 
		matrix `restrict' = `matrix'
		//------------------------
		
		* getting matrices from Stata
			
		mata:	H = st_matrix("`restrict'")
	
	}
	
	**** If the restriction matrix is going to be estimated by the program
	
	if "`meth_type'" == "CREauto" {
	
		mata: HOld= I(`intvar')
		mata: for (j=2; j<=`intvar'; j++) HOld = HOld\I(`intvar')
		mata: betamat= betamatfunc(1,`intvar')						
		mata: for (i= 2; i<=`intvar'; i++) betamat = betamat\betamatfunc(i, `intvar')
		mata: H = betamat, HOld
		
		** get matrix to stata
		
		mata:  st_matrix( "`restrict'" ,H )
	}
	
	//-------------------------------------------------------------

	*8.1.2) Estimates the model using the matrix from either option above

	mata:	p = st_matrix("`mat_aux10'")
	mata:	varcov = st_matrix("`varcov'")
	
	mata:	V =  cholinv(varcov)
	mata:	Vard = cholinv(H'*V*H)
	mata:	d = Vard*H'*V*p
		
	mata:	st_matrix("Vard", Vard)
	mata:	st_matrix("d", d)
	
	mata: 	se = diagonal(Vard):^0.5
	mata: 	st_matrix("se", se)
	mata: 	st_matrix("se", se)
	
	
	mata:  st_matrix( "`d'" ,d )
	mata:  st_matrix( "`V'" ,V )
	
	*8.1.3) Getting the chi test
	
	tempname dist_aux
	mat `dist_aux' = (`mat_aux10'-`restrict'*`d')'*`V'*(`mat_aux10'-`restrict'*`d') 
	
	* Get the chi2 value
	loc dist = `Nsu'*`dist_aux'[1,1]

	** For the chi-square test
	loc q_t = rowsof(`restrict')


	*8.1.4) Save for later display as tabdisp
	mat `output1' = d
	mat `output2' = se
		
	ereturn matrix coeff  = d 
	ereturn matrix se = se
	ereturn matrix varcov = Vard
}
	
**********************************************
* 8.2) Implementation of the CRC model if CRC is selected	
**********************************************

if "`meth_safe'" == "CRC" {
	// Transfer stata variables to Mata, and then get a vector of means from
	// them.
	
	mata: st_view(hlist = . , . , "`hmean_loc'" , "`touse'")
	mata: hmean = mean(hlist)
	// Getting parameters and matrices from the results	
	mata:	param =  st_matrix("`mat_aux10'")

	mata:	varcov = st_matrix("`varcov'")
	
	**** Determine the Weighting Matrix for CRC; default is the inverse 
	**** of the reduced form variance-covariance matrix

	if "`weighting'" == "" {
		mata:	V =  cholinv(varcov)
	}

	if "`weighting'" == "OMD" {
		mata:	V =  cholinv(varcov)
	}
	
	if "`weighting'" == "DWMD" {
		mata:   V =  cholinv(varcov)
		mata:   V =  diag(V)
	}
	
	if "`weighting'" == "EWMD" {
		local y_count = wordcount("`regression_y'")*`intvar'
		mata:   V =  I(`y_count')
	}
		//// Starts optimization program

	noi disp in red  _n "{title:Minimun Distance Estimator is being calculated}" 	///
	_n ""																			///
	
	
	//----- Defines the functions that need to be used depending on the 
	//------ number of years
	
	** Years programed so far
	loc year_programmed = "2 , 3 , 4 , 5"
	loc y_chosen = wordcount("`regression_y'") 
	
	if inlist(wordcount("`regression_y'") ,`year_programmed' ) != 1 {
		di in red "The optimization process for `y_chosen' years has not been programmed"
		error

	}
	
	if `endo_number' == 0 {
	
	
		if `y_chosen' == 2 {
			// number of colums
			mata: n_col = 5
		
			** For the chi-square test
			loc q_t = 6
		
		}
		if `y_chosen' == 3 {
			mata: n_col=9
		
			** For the chi-square test
			loc q_t = 21		
		}
		
		if `y_chosen' == 4 {
			mata: n_col=17
			loc q_t = 60
		}
		
		if `y_chosen' == 5 {
			mata: n_col=33
			loc q_t = 155
		}
	}
	
	if `endo_number' != 0 {
	
		if `y_chosen'== 2 {
			//number of columns
			mata: n_col = 14
			
			loc q_t = 22
		}
		
		if `y_chosen' == 3 {
			//number of columns
			mata: n_col = 34
			
			loc q_t = 93
		}
		
		if `y_chosen' == 4 {
			mata: n_col=82
			loc q_t = 316
		}
		
		if `y_chosen' == 5 {
			mata: n_col=194
			loc q_t = 955
		}
			

	}
	
	///----------------------------------------------------------------
	
	//---------------------------------------------------------------
	//------- Starts optimization process 
	
	/// -optimize()- requires that 'gtheta' is a rowvector

	//Begins the optimization problem.
	//Store the returned result in a variable
	//name of your choosing; we have used S in this documentation
	//You pass S as the first argument to
	//the other optimize*() functions.

	mata: S = optimize_init()
	
	/// Depending on the options, a different mata function must be invoked.
	
	/// No additional endogenous variable


	if `endo_number' == 0 {
	
		mata: optimize_init_evaluator(S,&myeval`y_chosen'())
	
	}


	/// One additional endogenous variable: Fertilizer
	if `endo_number' != 0 {
	
		mata: optimize_init_evaluator(S, &myeval`y_chosen'endo())

	}
	
	mata: optimize_init_evaluatortype(S,"d0")
	
	/// intial parameters: Depends on the numer of restrictions

	mata: theta_0 = J(1,n_col,1)

	mata: optimize_init_params(S, theta_0)
	mata: optimize_init_which(S, "min")
	mata: optimize_init_argument(S, 1, param )
	mata: optimize_init_argument(S, 2 , V )

	// Vector with the results from the maximization
	capture noisily {
		mata: thetahat = optimize(S)
	}
	
	if _rc==1400 {
		di in red "It seems that the optimization crashed because there weren't" 
		di in red "feasible values for optimization. Do you have multicollinear" 
		di in red "variables? You can check if that is the case with the"
		di in red "showreg option to see the sureg results"
		exit 1400
	}


	
	
	//---------------------------------------------------------------
	
	
	//---------------------------------------------------------------
	//------- Starts process to get standard errors
	
	mata: D = deriv_init()
	if `endo_number' == 0 {

		//  function used
		mata: mata: deriv_init_evaluator(D, &derivat33`y_chosen'())
	}
	
	if `endo_number' != 0 {

			mata: mata: deriv_init_evaluator(D, &derivat33`y_chosen'endo())

	}	
	
	
	
	mata: deriv_init_evaluatortype(D, "t")

	mata: deriv_init_params(D, thetahat)

	mata: grad = deriv(D, 1)
	//---------------------------------------------------------------

	/*************************************************************************************/
	/*  Calculate the Var-Cov matrix of the OMD Estimates                                */ 
	/*  (use full sandwich formula to easily accommodate EWMD and DWMD weight matrices)  */
	/*************************************************************************************/
	
	mata: omega = (invsym(grad'*(V)*grad))*(grad'*(V)*(varcov)*(V)*grad)*(invsym(grad'*(V)*grad))
	*mata: omega = (cholinv(grad'*(V)*grad))*(grad'*(V)*(varcov)*(V)*grad)*(cholinv(grad'*(V)*grad))
		
	mata: se = diagonal(omega):^0.5
	mata: results = (thetahat \  se')
	
	
	mata: st_matrix("thetahat", thetahat)
	mata: st_matrix("se", se)
	mata: st_matrix("omega", omega)


	
	* Save for later display as tabdisp
	mat `output1' = thetahat'
	mat `output2' = se
	
	**************************************************************
	*** Get chi2 
	**************************************************************
	if `endo_number' == 0 {
	
	
		mata: gtheta=J(1,`q_t',.)
		mata: derivat33`y_chosen'( thetahat, gtheta )	
	
	}
	
	if `endo_number' != 0 {
		
		mata: gtheta=J(1,`q_t',.)
		mata: derivat33`y_chosen'endo( thetahat, gtheta )
	}
		
	* for comformability of mat dist
	
	mata: gtheta_aux = gtheta'
		
	mata: dist = (param-gtheta_aux)'*V*(param-gtheta_aux)
	mata: st_matrix("dist", dist)
	
	* Get the chi2 value
	loc dist = `Nsu'*dist[1,1]
	
	mat drop dist
	**************************************************************	

	ereturn matrix coeff  =  `output1'
	ereturn matrix se = se
	ereturn matrix varcov = omega

	//-------------------------------------------------------------	

}

//-------------------------------------------------------------
* 9)  OUTPUT display

tempvar n1
tempvar parameters

qui: svmat double  `output2' , names(`n1')
qui: gen `parameters' = _n if `n1' != .

* counting number of parameters

qui: su  `parameters' 
loc max = r(max)


** Creating names for the variables so we can display them
** In the CRE case
if "`meth_safe'" == "CRE" {
	loc name_m = "b"
	forvalues i = 1(1)`=`max'-1' {

		loc name_m = "`name_m' l`i'"

	}
}

if "`meth_safe'" == "CRC" {
	loc name_m = ""
	
	if `endo_number' == 0 {
		forvalues i = 1(1)`=`max'-2' {
			* names the lambdas
			loc name_m = "`name_m' l`i'"
		}
		* name the last parameters
		loc name_m = "`name_m' b phi"
	}
	if `endo_number' != 0 {
	
		forvalues i = 1(1)`=`max'-3' {
			* names the lambdas
			loc name_m = "`name_m' l`i'"
		}
		
		* names the lambdas: rho b phi come at the end
		loc name_m = "`name_m' rho b phi"
	}
}

*************
* Getting chi-square test for over id

loc p_value_chi = chi2tail(`=`q_t'-`max'' , `dist')
loc chi_value = `dist'

*************			
noi disp in red  _n "{title: With corresponding Parameters matrix:}" 	


matrix  b = e(coeff)'
matrix  V = e(varcov)

matname b "`name_m'", columns(.) explicit
matname V "`name_m'" , explicit

** loading things to be returned

ereturn post b V
ereturn scalar N = `Nsu'
ereturn matrix bsu = `bsu' 
ereturn matrix Sigmasu = `Sigmasu'
ereturn matrix Vsu = `Vsu'

ereturn scalar chi2 = `chi_value'
ereturn scalar p_chi2 = `p_value_chi'

ereturn display 
	

end 

// -------------------------------- Mata code ------------------------

mata: 
	mata set matalnum off
	mata set mataoptimize on
	mata set matafavor speed
	mata set matastrict off



// --- Program betamatfunc

	function betamatfunc(j,rank) {
		real matrix a
		a= J(rank,1,0)	
		a[j]=1
		return(a)
	}


		
//---------------- Two Year ----------------------------------------------------

// ------------------------ CRC ------------------------------------------------
	
	void myeval2(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,6,1)
		beta=theta[4]
		phi=theta[5]
		lambda0= -theta[1..3]*hmean'
		
		gtheta[1] = theta[1]*(1+theta[5])+theta[4]+theta[5]*lambda0
		gtheta[2] = theta[2]
		gtheta[3] = theta[3]*(1+theta[5])+(theta[5]*theta[2])
		gtheta[4] = theta[1]
		gtheta[5] = theta[2]*(1+theta[5])+theta[4]+theta[5]*lambda0
		gtheta[6] = theta[3]*(1+theta[5])+(theta[5]*theta[1])
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat332( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,6,1)
		beta=theta[4]
		phi=theta[5]
		lambda0= -theta[1..3]*hmean'
		// (-hmean[1]*theta[1]-hmean[2]*theta[2]-hmean[3]*theta[3])
		
		gtheta[1] = theta[1]*(1+theta[5])+theta[4]+theta[5]*lambda0
		gtheta[2] = theta[2]
		gtheta[3] = theta[3]*(1+theta[5])+(theta[5]*theta[2])
		gtheta[4] = theta[1]
		gtheta[5] = theta[2]*(1+theta[5])+theta[4]+theta[5]*lambda0
		gtheta[6] = theta[3]*(1+theta[5])+(theta[5]*theta[1])
		
	}
	
// ----------------------------- CRC Endogenous --------------------------------

	void myeval2endo(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,22,1)
		
		rho= theta[12]
		beta= theta[13]
		phi= theta[14]
		lambda0= -theta[1..11]*hmean'

		gtheta[1]  = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]  = theta[2]
		gtheta[3]  = phi*theta[2] + theta[3]*(1 + phi)
		gtheta[4]  = rho + theta[4]
		gtheta[5]  = theta[5]
		gtheta[6]  = phi*theta[4] + theta[6]*(1 + phi)
		gtheta[7]  = theta[7]
		gtheta[8]  = phi*theta[7] + theta[8]*(1 + phi)
		gtheta[9]  = phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10] = theta[10]
		gtheta[11] = phi*theta[10] + theta[11]*(1 + phi)
		gtheta[12] = theta[1]
		gtheta[13] = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[14] = phi*theta[1] + theta[3]*(1 + phi)
		gtheta[15] = theta[4]
		gtheta[16] = rho + theta[5]
		gtheta[17] = theta[6]
		gtheta[18] = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[19] = phi*theta[6] + theta[8]*(1 + phi)
		gtheta[20] = theta[9]
		gtheta[21] = phi*theta[5] + theta[10]*(1 + phi)
		gtheta[22] = phi*theta[9] + theta[11]*(1 + phi)
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat332endo( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,22,1)
		
		rho= theta[12]
		beta= theta[13]
		phi= theta[14]
		lambda0= -theta[1..11]*hmean'

		gtheta[1]  = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]  = theta[2]
		gtheta[3]  = phi*theta[2] + theta[3]*(1 + phi)
		gtheta[4]  = rho + theta[4]
		gtheta[5]  = theta[5]
		gtheta[6]  = phi*theta[4] + theta[6]*(1 + phi)
		gtheta[7]  = theta[7]
		gtheta[8]  = phi*theta[7] + theta[8]*(1 + phi)
		gtheta[9]  = phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10] = theta[10]
		gtheta[11] = phi*theta[10] + theta[11]*(1 + phi)
		gtheta[12] = theta[1]
		gtheta[13] = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[14] = phi*theta[1] + theta[3]*(1 + phi)
		gtheta[15] = theta[4]
		gtheta[16] = rho + theta[5]
		gtheta[17] = theta[6]
		gtheta[18] = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[19] = phi*theta[6] + theta[8]*(1 + phi)
		gtheta[20] = theta[9]
		gtheta[21] = phi*theta[5] + theta[10]*(1 + phi)
		gtheta[22] = phi*theta[9] + theta[11]*(1 + phi)
		
	}
	
// ------------------------ End Two Year ---------------------------------------	


// --------------------------- Three Year --------------------------------------

// ----------------------------------- CRC -------------------------------------
	
	void myeval3(todo, theta , param , V,  omd , S , H)	{
	
		real colvector  diff

		gtheta=J(1,21,1)
		external real rowvector hmean
		lambda0= -theta[1..7]*hmean'

		 //lambda0= (-hmean[1]*theta[1]-hmean[2] *theta[2]-hmean[3]*theta[3]-hmean[4]*theta[4]-hmean[5]*theta[5]-hmean[6]*theta[6]-hmean[7]*theta[7])+theta[1]*(1+theta[9])
		gtheta[1]  = theta[8]+theta[9]*lambda0+(theta[1]*(1+theta[9]))
        gtheta[2]  = theta[2]
        gtheta[3]  = theta[3]
        gtheta[4]  = theta[9]*theta[2]+theta[4]*(1+theta[9])
        gtheta[5]  = theta[9]*theta[3]+theta[5]*(1+theta[9])
        gtheta[6]  = theta[6]
        gtheta[7]  = theta[9]*theta[6]+theta[7]*(1+theta[9])
        gtheta[8]  = theta[1]
        gtheta[9]  = theta[8]+theta[9]*lambda0+(theta[2]*(1+theta[9]))
        gtheta[10] = theta[3]
        gtheta[11] = theta[9]*theta[1]+theta[4]*(1+theta[9])
        gtheta[12] = theta[5]
        gtheta[13] = theta[9]*theta[3]+theta[6]*(1+theta[9])
        gtheta[14] = theta[9]*theta[5]+theta[7]*(1+theta[9])
        gtheta[15] = theta[1]
        gtheta[16] = theta[2]
        gtheta[17] = theta[8]+theta[9]*lambda0+(theta[3]*(1+theta[9]))
        gtheta[18] = theta[4]
        gtheta[19] = theta[9]*theta[1]+theta[5]*(1+theta[9])
        gtheta[20] = theta[9]*theta[2]+theta[6]*(1+theta[9])
        gtheta[21] = theta[9]*theta[4]+theta[7]*(1+theta[9])
		
		diff = param-gtheta'
		
		omd= (diff)'*V*(diff)		
	}

	// Defines the function to take derivatives from with 3 year data. 
	
	void derivat333( theta , gtheta )
	{
		gtheta = J(1,21,.)
		external real rowvector hmean
		lambda0= -theta[1..7]*hmean'
		//lambda0= (-hmean[1]*theta[1]-hmean[2] *theta[2]-hmean[3]*theta[3]-hmean[4]*theta[4]-hmean[5]*theta[5]-hmean[6]*theta[6]-hmean[7]*theta[7])+theta[1]*(1+theta[9])
		
		gtheta[1]  = theta[8]+theta[9]*lambda0+(theta[1]*(1+theta[9]))
        gtheta[2]  = theta[2]
        gtheta[3]  = theta[3]
        gtheta[4]  = theta[9]*theta[2]+theta[4]*(1+theta[9])
        gtheta[5]  = theta[9]*theta[3]+theta[5]*(1+theta[9])
        gtheta[6]  = theta[6]
        gtheta[7]  = theta[9]*theta[6]+theta[7]*(1+theta[9])
        gtheta[8]  = theta[1]
        gtheta[9]  = theta[8]+theta[9]*lambda0+(theta[2]*(1+theta[9]))
        gtheta[10] = theta[3]
        gtheta[11] = theta[9]*theta[1]+theta[4]*(1+theta[9])
        gtheta[12] = theta[5]
        gtheta[13] = theta[9]*theta[3]+theta[6]*(1+theta[9])
        gtheta[14] = theta[9]*theta[5]+theta[7]*(1+theta[9])
        gtheta[15] = theta[1]
        gtheta[16] = theta[2]
        gtheta[17] = theta[8]+theta[9]*lambda0+(theta[3]*(1+theta[9]))
        gtheta[18] = theta[4]
        gtheta[19] = theta[9]*theta[1]+theta[5]*(1+theta[9])
        gtheta[20] = theta[9]*theta[2]+theta[6]*(1+theta[9])
        gtheta[21] = theta[9]*theta[4]+theta[7]*(1+theta[9])		
	}
	
	
// ---------------------------------------- CRC Endogenous ---------------------
	
	void myeval3endo(todo, theta , param , V,  omd , S , H)
	{
		real colvector  diff

		gtheta=J(1,93,1)
		external real rowvector hmean
		lambda0= -theta[1..31]*hmean'
		//lambda0= -hmean[1]*theta[1]-hmean[2]*theta[2]-hmean[3]*theta[3]-hmean[4]*theta[4]-hmean[5]*theta[5]-hmean[6]*theta[6]-hmean[7]*theta[7]-hmean[8]*theta[8]-hmean[9]*theta[9]-hmean[10]*theta[10]-hmean[11]*theta[11]-hmean[12]*theta[12]-hmean[13]*theta[13]-hmean[14]*theta[14]-hmean[15]*theta[15]-hmean[16]*theta[16]-hmean[17]*theta[17]-hmean[18]*theta[18]-hmean[19]*theta[19]-hmean[20]*theta[20]-hmean[21]*theta[21]-hmean[22]*theta[22]-hmean[23]*theta[23]-hmean[24]*theta[24]-hmean[25]*theta[25]-hmean[26]*theta[26]-hmean[27]*theta[27]-hmean[28]*theta[28]-hmean[29]*theta[29]-hmean[30]*theta[30]-hmean[31]*theta[31]
		//theta[32]=rho, theta[33]=beta, theta[34]=phi 
		
		gtheta[1]  = theta[1]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[2]  = theta[2]
		gtheta[3]  = theta[3]
		gtheta[4]  = theta[34]*theta[2] + theta[4]*(1 + theta[34])
		gtheta[5]  = theta[34]*theta[3] + theta[5]*(1 + theta[34])
		gtheta[6]  = theta[6]
		gtheta[7]  = theta[34]*theta[6] + theta[7]*(1 + theta[34])
		gtheta[8]  = theta[32] + theta[8]
		gtheta[9]  = theta[9]
		gtheta[10] = theta[10]
		gtheta[11] = theta[34]*theta[8] + theta[11]*(1 + theta[34])
		gtheta[12] = theta[12]
		gtheta[13] = theta[13]
		gtheta[14] = theta[34]*theta[12] + theta[14]*(1 + theta[34])
		gtheta[15] = theta[34]*theta[13] + theta[15]*(1 + theta[34])
		gtheta[16] = theta[16]
		gtheta[17] = theta[34]*theta[16] + theta[17]*(1 + theta[34])
		gtheta[18] = theta[34]*theta[9] + theta[18]*(1 + theta[34])
		gtheta[19] = theta[19]
		gtheta[20] = theta[20]
		gtheta[21] = theta[34]*theta[19] + theta[21]*(1 + theta[34])
		gtheta[22] = theta[34]*theta[20] + theta[22]*(1 + theta[34])
		gtheta[23] = theta[23]
		gtheta[24] = theta[34]*theta[23] + theta[24]*(1 + theta[34])
		gtheta[25] = theta[34]*theta[10] + theta[25]*(1 + theta[34])
		gtheta[26] = theta[26]
		gtheta[27] = theta[27]
		gtheta[28] = theta[34]*theta[26] + theta[28]*(1 + theta[34])
		gtheta[29] = theta[34]*theta[27] + theta[29]*(1 + theta[34])
		gtheta[30] = theta[30]
		gtheta[31] = theta[34]*theta[30] + theta[31]*(1 + theta[34])
		gtheta[32] = theta[1]
		gtheta[33] = theta[2]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[34] = theta[3]
		gtheta[35] = theta[34]*theta[1] + theta[4]*(1 + theta[34])
		gtheta[36] = theta[5]
		gtheta[37] = theta[34]*theta[3] + theta[6]*(1 + theta[34])
		gtheta[38] = theta[34]*theta[5] + theta[7]*(1 + theta[34])
		gtheta[39] = theta[8]
		gtheta[40] = theta[32] + theta[9]
		gtheta[41] = theta[10]
		gtheta[42] = theta[11]
		gtheta[43] = theta[34]*theta[8] + theta[12]*(1 + theta[34])
		gtheta[44] = theta[13]
		gtheta[45] = theta[34]*theta[11] + theta[14]*(1 + theta[34])
		gtheta[46] = theta[15]
		gtheta[47] = theta[34]*theta[13] + theta[16]*(1 + theta[34])
		gtheta[48] = theta[34]*theta[15] + theta[17]*(1 + theta[34])
		gtheta[49] = theta[18]
		gtheta[50] = theta[34]*theta[9] + theta[19]*(1 + theta[34])
		gtheta[51] = theta[20]
		gtheta[52] = theta[34]*theta[18] + theta[21]*(1 + theta[34])
		gtheta[53] = theta[22]
		gtheta[54] = theta[34]*theta[20] + theta[23]*(1 + theta[34])
		gtheta[55] = theta[34]*theta[22] + theta[24]*(1 + theta[34])
		gtheta[56] = theta[25]
		gtheta[57] = theta[34]*theta[10] + theta[26]*(1 + theta[34])
		gtheta[58] = theta[27]
		gtheta[59] = theta[34]*theta[25] + theta[28]*(1 + theta[34])
		gtheta[60] = theta[29]
		gtheta[61] = theta[34]*theta[27] + theta[30]*(1 + theta[34])
		gtheta[62] = theta[34]*theta[29] + theta[31]*(1 + theta[34])
		gtheta[63] = theta[1]
		gtheta[64] = theta[2]
		gtheta[65] = theta[3]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[66] = theta[4]
		gtheta[67] = theta[34]*theta[1] + theta[5]*(1 + theta[34])
		gtheta[68] = theta[34]*theta[2] + theta[6]*(1 + theta[34])
		gtheta[69] = theta[34]*theta[4] + theta[7]*(1 + theta[34])
		gtheta[70] = theta[8]
		gtheta[71] = theta[9]
		gtheta[72] = theta[32] + theta[10]
		gtheta[73] = theta[11]
		gtheta[74] = theta[12]
		gtheta[75] = theta[34]*theta[8] + theta[13]*(1 + theta[34])
		gtheta[76] = theta[14]
		gtheta[77] = theta[34]*theta[11] + theta[15]*(1 + theta[34])
		gtheta[78] = theta[34]*theta[12] + theta[16]*(1 + theta[34])
		gtheta[79] = theta[34]*theta[14] + theta[17]*(1 + theta[34])
		gtheta[80] = theta[18]
		gtheta[81] = theta[19]
		gtheta[82] = theta[34]*theta[9] + theta[20]*(1 + theta[34])
		gtheta[83] = theta[21]
		gtheta[84] = theta[34]*theta[18] + theta[22]*(1 + theta[34])
		gtheta[85] = theta[34]*theta[19] + theta[23]*(1 + theta[34])
		gtheta[86] = theta[34]*theta[21] + theta[24]*(1 + theta[34])
		gtheta[87] = theta[25]
		gtheta[88] = theta[26]
		gtheta[89] = theta[34]*theta[10] + theta[27]*(1 + theta[34])
		gtheta[90] = theta[28]
		gtheta[91] = theta[34]*theta[25] + theta[29]*(1 + theta[34])
		gtheta[92] = theta[34]*theta[26] + theta[30]*(1 + theta[34])
		gtheta[93] = theta[34]*theta[28] + theta[31]*(1 + theta[34])
		
		
		diff = param-gtheta'
		
		omd= (diff)'*V*(diff)		
	}

	// Defines the function to take derivatives from with 3 year data. 
	
	void derivat333endo( theta , gtheta )
	{
		gtheta = J(1,93,.)
		external real rowvector hmean
		
		lambda0= -theta[1..31]*hmean'
		//lambda0= -hmean[1]*theta[1]-hmean[2]*theta[2]-hmean[3]*theta[3]-hmean[4]*theta[4]-hmean[5]*theta[5]-hmean[6]*theta[6]-hmean[7]*theta[7]-hmean[8]*theta[8]-hmean[9]*theta[9]-hmean[10]*theta[10]-hmean[11]*theta[11]-hmean[12]*theta[12]-hmean[13]*theta[13]-hmean[14]*theta[14]-hmean[15]*theta[15]-hmean[16]*theta[16]-hmean[17]*theta[17]-hmean[18]*theta[18]-hmean[19]*theta[19]-hmean[20]*theta[20]-hmean[21]*theta[21]-hmean[22]*theta[22]-hmean[23]*theta[23]-hmean[24]*theta[24]-hmean[25]*theta[25]-hmean[26]*theta[26]-hmean[27]*theta[27]-hmean[28]*theta[28]-hmean[29]*theta[29]-hmean[30]*theta[30]-hmean[31]*theta[31]

		// theta[32]=rho, theta[33]=beta, theta[34]=phi 
		
		gtheta[1]  = theta[1]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[2]  = theta[2]
		gtheta[3]  = theta[3]
		gtheta[4]  = theta[34]*theta[2] + theta[4]*(1 + theta[34])
		gtheta[5]  = theta[34]*theta[3] + theta[5]*(1 + theta[34])
		gtheta[6]  = theta[6]
		gtheta[7]  = theta[34]*theta[6] + theta[7]*(1 + theta[34])
		gtheta[8]  = theta[32] + theta[8]
		gtheta[9]  = theta[9]
		gtheta[10] = theta[10]
		gtheta[11] = theta[34]*theta[8] + theta[11]*(1 + theta[34])
		gtheta[12] = theta[12]
		gtheta[13] = theta[13]
		gtheta[14] = theta[34]*theta[12] + theta[14]*(1 + theta[34])
		gtheta[15] = theta[34]*theta[13] + theta[15]*(1 + theta[34])
		gtheta[16] = theta[16]
		gtheta[17] = theta[34]*theta[16] + theta[17]*(1 + theta[34])
		gtheta[18] = theta[34]*theta[9] + theta[18]*(1 + theta[34])
		gtheta[19] = theta[19]
		gtheta[20] = theta[20]
		gtheta[21] = theta[34]*theta[19] + theta[21]*(1 + theta[34])
		gtheta[22] = theta[34]*theta[20] + theta[22]*(1 + theta[34])
		gtheta[23] = theta[23]
		gtheta[24] = theta[34]*theta[23] + theta[24]*(1 + theta[34])
		gtheta[25] = theta[34]*theta[10] + theta[25]*(1 + theta[34])
		gtheta[26] = theta[26]
		gtheta[27] = theta[27]
		gtheta[28] = theta[34]*theta[26] + theta[28]*(1 + theta[34])
		gtheta[29] = theta[34]*theta[27] + theta[29]*(1 + theta[34])
		gtheta[30] = theta[30]
		gtheta[31] = theta[34]*theta[30] + theta[31]*(1 + theta[34])
		gtheta[32] = theta[1]
		gtheta[33] = theta[2]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[34] = theta[3]
		gtheta[35] = theta[34]*theta[1] + theta[4]*(1 + theta[34])
		gtheta[36] = theta[5]
		gtheta[37] = theta[34]*theta[3] + theta[6]*(1 + theta[34])
		gtheta[38] = theta[34]*theta[5] + theta[7]*(1 + theta[34])
		gtheta[39] = theta[8]
		gtheta[40] = theta[32] + theta[9]
		gtheta[41] = theta[10]
		gtheta[42] = theta[11]
		gtheta[43] = theta[34]*theta[8] + theta[12]*(1 + theta[34])
		gtheta[44] = theta[13]
		gtheta[45] = theta[34]*theta[11] + theta[14]*(1 + theta[34])
		gtheta[46] = theta[15]
		gtheta[47] = theta[34]*theta[13] + theta[16]*(1 + theta[34])
		gtheta[48] = theta[34]*theta[15] + theta[17]*(1 + theta[34])
		gtheta[49] = theta[18]
		gtheta[50] = theta[34]*theta[9] + theta[19]*(1 + theta[34])
		gtheta[51] = theta[20]
		gtheta[52] = theta[34]*theta[18] + theta[21]*(1 + theta[34])
		gtheta[53] = theta[22]
		gtheta[54] = theta[34]*theta[20] + theta[23]*(1 + theta[34])
		gtheta[55] = theta[34]*theta[22] + theta[24]*(1 + theta[34])
		gtheta[56] = theta[25]
		gtheta[57] = theta[34]*theta[10] + theta[26]*(1 + theta[34])
		gtheta[58] = theta[27]
		gtheta[59] = theta[34]*theta[25] + theta[28]*(1 + theta[34])
		gtheta[60] = theta[29]
		gtheta[61] = theta[34]*theta[27] + theta[30]*(1 + theta[34])
		gtheta[62] = theta[34]*theta[29] + theta[31]*(1 + theta[34])
		gtheta[63] = theta[1]
		gtheta[64] = theta[2]
		gtheta[65] = theta[3]*(1 + theta[34]) + theta[33] + theta[34]*lambda0
		gtheta[66] = theta[4]
		gtheta[67] = theta[34]*theta[1] + theta[5]*(1 + theta[34])
		gtheta[68] = theta[34]*theta[2] + theta[6]*(1 + theta[34])
		gtheta[69] = theta[34]*theta[4] + theta[7]*(1 + theta[34])
		gtheta[70] = theta[8]
		gtheta[71] = theta[9]
		gtheta[72] = theta[32] + theta[10]
		gtheta[73] = theta[11]
		gtheta[74] = theta[12]
		gtheta[75] = theta[34]*theta[8] + theta[13]*(1 + theta[34])
		gtheta[76] = theta[14]
		gtheta[77] = theta[34]*theta[11] + theta[15]*(1 + theta[34])
		gtheta[78] = theta[34]*theta[12] + theta[16]*(1 + theta[34])
		gtheta[79] = theta[34]*theta[14] + theta[17]*(1 + theta[34])
		gtheta[80] = theta[18]
		gtheta[81] = theta[19]
		gtheta[82] = theta[34]*theta[9] + theta[20]*(1 + theta[34])
		gtheta[83] = theta[21]
		gtheta[84] = theta[34]*theta[18] + theta[22]*(1 + theta[34])
		gtheta[85] = theta[34]*theta[19] + theta[23]*(1 + theta[34])
		gtheta[86] = theta[34]*theta[21] + theta[24]*(1 + theta[34])
		gtheta[87] = theta[25]
		gtheta[88] = theta[26]
		gtheta[89] = theta[34]*theta[10] + theta[27]*(1 + theta[34])
		gtheta[90] = theta[28]
		gtheta[91] = theta[34]*theta[25] + theta[29]*(1 + theta[34])
		gtheta[92] = theta[34]*theta[26] + theta[30]*(1 + theta[34])
		gtheta[93] = theta[34]*theta[28] + theta[31]*(1 + theta[34])	
	}
	
	
// ----------------------- End Three Year --------------------------------------

// ---------------------------- Four Year --------------------------------------

// -------------------------------- CRC ----------------------------------------

	void myeval4(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,60,1)
		lambda0= -theta[1..15]*hmean'

		
		beta=theta[16]
		phi=theta[17]

		gtheta[1]   = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]   = theta[2]
		gtheta[3]   = theta[3]
		gtheta[4]   = theta[4]
		gtheta[5]   = phi*theta[2] + theta[5]*(1 + phi)
		gtheta[6]   = phi*theta[3] + theta[6]*(1 + phi)
		gtheta[7]   = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[8]   = theta[8]
		gtheta[9]   = theta[9]
		gtheta[10]  = theta[10]
		gtheta[11]  = phi*theta[8] + theta[11]*(1 + phi)
		gtheta[12]  = phi*theta[9] + theta[12]*(1 + phi)
		gtheta[13]  = phi*theta[10] + theta[13]*(1 + phi)
		gtheta[14]  = theta[14]
		gtheta[15]  = phi*theta[14] + theta[15]*(1 + phi)
		gtheta[16]  = theta[1]
		gtheta[17]  = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[18]  = theta[3]
		gtheta[19]  = theta[4]
		gtheta[20]  = phi*theta[1] + theta[5]*(1 + phi)
		gtheta[21]  = theta[6]
		gtheta[22]  = theta[7]
		gtheta[23]  = phi*theta[3] + theta[8]*(1 + phi)
		gtheta[24]  = phi*theta[4] + theta[9]*(1 + phi)
		gtheta[25]  = theta[10]
		gtheta[26]  = phi*theta[6] + theta[11]*(1 + phi)
		gtheta[27]  = phi*theta[7] + theta[12]*(1 + phi)
		gtheta[28]  = theta[13]
		gtheta[29]  = phi*theta[10] + theta[14]*(1 + phi)
		gtheta[30]  = phi*theta[13] + theta[15]*(1 + phi)
		gtheta[31]  = theta[1]
		gtheta[32]  = theta[2]
		gtheta[33]  = theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[34]  = theta[4]
		gtheta[35]  = theta[5]
		gtheta[36]  = phi*theta[1] + theta[6]*(1 + phi)
		gtheta[37]  = theta[7]
		gtheta[38]  = phi*theta[2] + theta[8]*(1 + phi)
		gtheta[39]  = theta[9]
		gtheta[40]  = phi*theta[4] + theta[10]*(1 + phi)
		gtheta[41]  = phi*theta[5] + theta[11]*(1 + phi)
		gtheta[42]  = theta[12]
		gtheta[43]  = phi*theta[7] + theta[13]*(1 + phi)
		gtheta[44]  = phi*theta[9] + theta[14]*(1 + phi)
		gtheta[45]  = phi*theta[12] + theta[15]*(1 + phi)
		gtheta[46]  = theta[1]
		gtheta[47]  = theta[2]
		gtheta[48]  = theta[3]
		gtheta[49]  = theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[50]  = theta[5]
		gtheta[51]  = theta[6]
		gtheta[52]  = phi*theta[1] + theta[7]*(1 + phi)
		gtheta[53]  = theta[8]
		gtheta[54]  = phi*theta[2] + theta[9]*(1 + phi)
		gtheta[55]  = phi*theta[3] + theta[10]*(1 + phi)
		gtheta[56]  = theta[11]
		gtheta[57]  = phi*theta[5] + theta[12]*(1 + phi)
		gtheta[58]  = phi*theta[6] + theta[13]*(1 + phi)
		gtheta[59]  = phi*theta[8] + theta[14]*(1 + phi)
		gtheta[60]  = phi*theta[11] + theta[15]*(1 + phi)
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat334( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,60,1)
		lambda0= -theta[1..15]*hmean'

		
		beta=theta[16]
		phi=theta[17]

		gtheta[1]   = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]   = theta[2]
		gtheta[3]   = theta[3]
		gtheta[4]   = theta[4]
		gtheta[5]   = phi*theta[2] + theta[5]*(1 + phi)
		gtheta[6]   = phi*theta[3] + theta[6]*(1 + phi)
		gtheta[7]   = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[8]   = theta[8]
		gtheta[9]   = theta[9]
		gtheta[10]  = theta[10]
		gtheta[11]  = phi*theta[8] + theta[11]*(1 + phi)
		gtheta[12]  = phi*theta[9] + theta[12]*(1 + phi)
		gtheta[13]  = phi*theta[10] + theta[13]*(1 + phi)
		gtheta[14]  = theta[14]
		gtheta[15]  = phi*theta[14] + theta[15]*(1 + phi)
		gtheta[16]  = theta[1]
		gtheta[17]  = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[18]  = theta[3]
		gtheta[19]  = theta[4]
		gtheta[20]  = phi*theta[1] + theta[5]*(1 + phi)
		gtheta[21]  = theta[6]
		gtheta[22]  = theta[7]
		gtheta[23]  = phi*theta[3] + theta[8]*(1 + phi)
		gtheta[24]  = phi*theta[4] + theta[9]*(1 + phi)
		gtheta[25]  = theta[10]
		gtheta[26]  = phi*theta[6] + theta[11]*(1 + phi)
		gtheta[27]  = phi*theta[7] + theta[12]*(1 + phi)
		gtheta[28]  = theta[13]
		gtheta[29]  = phi*theta[10] + theta[14]*(1 + phi)
		gtheta[30]  = phi*theta[13] + theta[15]*(1 + phi)
		gtheta[31]  = theta[1]
		gtheta[32]  = theta[2]
		gtheta[33]  = theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[34]  = theta[4]
		gtheta[35]  = theta[5]
		gtheta[36]  = phi*theta[1] + theta[6]*(1 + phi)
		gtheta[37]  = theta[7]
		gtheta[38]  = phi*theta[2] + theta[8]*(1 + phi)
		gtheta[39]  = theta[9]
		gtheta[40]  = phi*theta[4] + theta[10]*(1 + phi)
		gtheta[41]  = phi*theta[5] + theta[11]*(1 + phi)
		gtheta[42]  = theta[12]
		gtheta[43]  = phi*theta[7] + theta[13]*(1 + phi)
		gtheta[44]  = phi*theta[9] + theta[14]*(1 + phi)
		gtheta[45]  = phi*theta[12] + theta[15]*(1 + phi)
		gtheta[46]  = theta[1]
		gtheta[47]  = theta[2]
		gtheta[48]  = theta[3]
		gtheta[49]  = theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[50]  = theta[5]
		gtheta[51]  = theta[6]
		gtheta[52]  = phi*theta[1] + theta[7]*(1 + phi)
		gtheta[53]  = theta[8]
		gtheta[54]  = phi*theta[2] + theta[9]*(1 + phi)
		gtheta[55]  = phi*theta[3] + theta[10]*(1 + phi)
		gtheta[56]  = theta[11]
		gtheta[57]  = phi*theta[5] + theta[12]*(1 + phi)
		gtheta[58]  = phi*theta[6] + theta[13]*(1 + phi)
		gtheta[59]  = phi*theta[8] + theta[14]*(1 + phi)
		gtheta[60]  = phi*theta[11] + theta[15]*(1 + phi)
		
	}
	
	
// --------------------------------- CRC ENDOGENOUS ----------------------------

	void myeval4endo(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,316,1)
		lambda0= -theta[1..79]*hmean'

		rho=theta[80]
		beta=theta[81]
		phi=theta[82]
		
		gtheta[1]   = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]   = theta[2]
		gtheta[3]   = theta[3]
		gtheta[4]   = theta[4]
		gtheta[5]   = phi*theta[2] + theta[5]*(1 + phi)
		gtheta[6]   = phi*theta[3] + theta[6]*(1 + phi)
		gtheta[7]   = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[8]   = theta[8]
		gtheta[9]   = theta[9]
		gtheta[10]  = theta[10]
		gtheta[11]  = phi*theta[8] + theta[11]*(1 + phi)
		gtheta[12]  = phi*theta[9] + theta[12]*(1 + phi)
		gtheta[13]  = phi*theta[10] + theta[13]*(1 + phi)
		gtheta[14]  = theta[14]
		gtheta[15]  = phi*theta[14] + theta[15]*(1 + phi)
		gtheta[16]  = rho + theta[16]
		gtheta[17]  = theta[17]
		gtheta[18]  = theta[18]
		gtheta[19]  = theta[19]
		gtheta[20]  = phi*theta[16] + theta[20]*(1 + phi)
		gtheta[21]  = theta[21]
		gtheta[22]  = theta[22]
		gtheta[23]  = theta[23]
		gtheta[24]  = phi*theta[21] + theta[24]*(1 + phi)
		gtheta[25]  = phi*theta[22] + theta[25]*(1 + phi)
		gtheta[26]  = phi*theta[23] + theta[26]*(1 + phi)
		gtheta[27]  = theta[27]
		gtheta[28]  = theta[28]
		gtheta[29]  = theta[29]
		gtheta[30]  = phi*theta[27] + theta[30]*(1 + phi)
		gtheta[31]  = phi*theta[28] + theta[31]*(1 + phi)
		gtheta[32]  = phi*theta[29] + theta[32]*(1 + phi)
		gtheta[33]  = theta[33]
		gtheta[34]  = phi*theta[33] + theta[34]*(1 + phi)
		gtheta[35]  = phi*theta[17] + theta[35]*(1 + phi)
		gtheta[36]  = theta[36]
		gtheta[37]  = theta[37]
		gtheta[38]  = theta[38]
		gtheta[39]  = phi*theta[36] + theta[39]*(1 + phi)
		gtheta[40]  = phi*theta[37] + theta[40]*(1 + phi)
		gtheta[41]  = phi*theta[38] + theta[41]*(1 + phi)
		gtheta[42]  = theta[42]
		gtheta[43]  = theta[43]
		gtheta[44]  = theta[44]
		gtheta[45]  = phi*theta[42] + theta[45]*(1 + phi)
		gtheta[46]  = phi*theta[43] + theta[46]*(1 + phi)
		gtheta[47]  = phi*theta[44] + theta[47]*(1 + phi)
		gtheta[48]  = theta[48]
		gtheta[49]  = phi*theta[48] + theta[49]*(1 + phi)
		gtheta[50]  = phi*theta[18] + theta[50]*(1 + phi)
		gtheta[51]  = theta[51]
		gtheta[52]  = theta[52]
		gtheta[53]  = theta[53]
		gtheta[54]  = phi*theta[51] + theta[54]*(1 + phi)
		gtheta[55]  = phi*theta[52] + theta[55]*(1 + phi)
		gtheta[56]  = phi*theta[53] + theta[56]*(1 + phi)
		gtheta[57]  = theta[57]
		gtheta[58]  = theta[58]
		gtheta[59]  = theta[59]
		gtheta[60]  = phi*theta[57] + theta[60]*(1 + phi)
		gtheta[61]  = phi*theta[58] + theta[61]*(1 + phi)
		gtheta[62]  = phi*theta[59] + theta[62]*(1 + phi)
		gtheta[63]  = theta[63]
		gtheta[64]  = phi*theta[63] + theta[64]*(1 + phi)
		gtheta[65]  = phi*theta[19] + theta[65]*(1 + phi)
		gtheta[66]  = theta[66]
		gtheta[67]  = theta[67]
		gtheta[68]  = theta[68]
		gtheta[69]  = phi*theta[66] + theta[69]*(1 + phi)
		gtheta[70]  = phi*theta[67] + theta[70]*(1 + phi)
		gtheta[71]  = phi*theta[68] + theta[71]*(1 + phi)
		gtheta[72]  = theta[72]
		gtheta[73]  = theta[73]
		gtheta[74]  = theta[74]
		gtheta[75]  = phi*theta[72] + theta[75]*(1 + phi)
		gtheta[76]  = phi*theta[73] + theta[76]*(1 + phi)
		gtheta[77]  = phi*theta[74] + theta[77]*(1 + phi)
		gtheta[78]  = theta[78]
		gtheta[79]  = phi*theta[78] + theta[79]*(1 + phi)
		gtheta[80]  = theta[1]
		gtheta[81]  = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[82]  = theta[3]
		gtheta[83]  = theta[4]
		gtheta[84]  = phi*theta[1] + theta[5]*(1 + phi)
		gtheta[85]  = theta[6]
		gtheta[86]  = theta[7]
		gtheta[87]  = phi*theta[3] + theta[8]*(1 + phi)
		gtheta[88]  = phi*theta[4] + theta[9]*(1 + phi)
		gtheta[89]  = theta[10]
		gtheta[90]  = phi*theta[6] + theta[11]*(1 + phi)
		gtheta[91]  = phi*theta[7] + theta[12]*(1 + phi)
		gtheta[92]  = theta[13]
		gtheta[93]  = phi*theta[10] + theta[14]*(1 + phi)
		gtheta[94]  = phi*theta[13] + theta[15]*(1 + phi)
		gtheta[95]  = theta[16]
		gtheta[96]  = rho + theta[17]
		gtheta[97]  = theta[18]
		gtheta[98]  = theta[19]
		gtheta[99]  = theta[20]
		gtheta[100] = phi*theta[16] + theta[21]*(1 + phi)
		gtheta[101] = theta[22]
		gtheta[102] = theta[23]
		gtheta[103] = phi*theta[20] + theta[24]*(1 + phi)
		gtheta[104] = theta[25]
		gtheta[105] = theta[26]
		gtheta[106] = phi*theta[22] + theta[27]*(1 + phi)
		gtheta[107] = phi*theta[23] + theta[28]*(1 + phi)
		gtheta[108] = theta[29]
		gtheta[109] = phi*theta[25] + theta[30]*(1 + phi)
		gtheta[110] = phi*theta[26] + theta[31]*(1 + phi)
		gtheta[111] = theta[32]
		gtheta[112] = phi*theta[29] + theta[33]*(1 + phi)
		gtheta[113] = phi*theta[32] + theta[34]*(1 + phi)
		gtheta[114] = theta[35]
		gtheta[115] = phi*theta[17] + theta[36]*(1 + phi)
		gtheta[116] = theta[37]
		gtheta[117] = theta[38]
		gtheta[118] = phi*theta[35] + theta[39]*(1 + phi)
		gtheta[119] = theta[40]
		gtheta[120] = theta[41]
		gtheta[121] = phi*theta[37] + theta[42]*(1 + phi)
		gtheta[122] = phi*theta[38] + theta[43]*(1 + phi)
		gtheta[123] = theta[44]
		gtheta[124] = phi*theta[40] + theta[45]*(1 + phi)
		gtheta[125] = phi*theta[41] + theta[46]*(1 + phi)
		gtheta[126] = theta[47]
		gtheta[127] = phi*theta[44] + theta[48]*(1 + phi)
		gtheta[128] = phi*theta[47] + theta[49]*(1 + phi)
		gtheta[129] = theta[50]
		gtheta[130] = phi*theta[18] + theta[51]*(1 + phi)
		gtheta[131] = theta[52]
		gtheta[132] = theta[53]
		gtheta[133] = phi*theta[50] + theta[54]*(1 + phi)
		gtheta[134] = theta[55]
		gtheta[135] = theta[56]
		gtheta[136] = phi*theta[52] + theta[57]*(1 + phi)
		gtheta[137] = phi*theta[53] + theta[58]*(1 + phi)
		gtheta[138] = theta[59]
		gtheta[139] = phi*theta[55] + theta[60]*(1 + phi)
		gtheta[140] = phi*theta[56] + theta[61]*(1 + phi)
		gtheta[141] = theta[62]
		gtheta[142] = phi*theta[59] + theta[63]*(1 + phi)
		gtheta[143] = phi*theta[62] + theta[64]*(1 + phi)
		gtheta[144] = theta[65]
		gtheta[145] = phi*theta[19] + theta[66]*(1 + phi)
		gtheta[146] = theta[67]
		gtheta[147] = theta[68]
		gtheta[148] = phi*theta[65] + theta[69]*(1 + phi)
		gtheta[149] = theta[70]
		gtheta[150] = theta[71]
		gtheta[151] = phi*theta[67] + theta[72]*(1 + phi)
		gtheta[152] = phi*theta[68] + theta[73]*(1 + phi)
		gtheta[153] = theta[74]
		gtheta[154] = phi*theta[70] + theta[75]*(1 + phi)
		gtheta[155] = phi*theta[71] + theta[76]*(1 + phi)
		gtheta[156] = theta[77]
		gtheta[157] = phi*theta[74] + theta[78]*(1 + phi)
		gtheta[158] = phi*theta[77] + theta[79]*(1 + phi)
		gtheta[159] = theta[1]
		gtheta[160] = theta[2]
		gtheta[161] = theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[162] = theta[4]
		gtheta[163] = theta[5]
		gtheta[164] = phi*theta[1] + theta[6]*(1 + phi)
		gtheta[165] = theta[7]
		gtheta[166] = phi*theta[2] + theta[8]*(1 + phi)
		gtheta[167] = theta[9]
		gtheta[168] = phi*theta[4] + theta[10]*(1 + phi)
		gtheta[169] = phi*theta[5] + theta[11]*(1 + phi)
		gtheta[170] = theta[12]
		gtheta[171] = phi*theta[7] + theta[13]*(1 + phi)
		gtheta[172] = phi*theta[9] + theta[14]*(1 + phi)
		gtheta[173] = phi*theta[12] + theta[15]*(1 + phi)
		gtheta[174] = theta[16]
		gtheta[175] = theta[17]
		gtheta[176] = rho + theta[18]
		gtheta[177] = theta[19]
		gtheta[178] = theta[20]
		gtheta[179] = theta[21]
		gtheta[180] = phi*theta[16] + theta[22]*(1 + phi)
		gtheta[181] = theta[23]
		gtheta[182] = theta[24]
		gtheta[183] = phi*theta[20] + theta[25]*(1 + phi)
		gtheta[184] = theta[26]
		gtheta[185] = phi*theta[21] + theta[27]*(1 + phi)
		gtheta[186] = theta[28]
		gtheta[187] = phi*theta[23] + theta[29]*(1 + phi)
		gtheta[188] = phi*theta[24] + theta[30]*(1 + phi)
		gtheta[189] = theta[31]
		gtheta[190] = phi*theta[26] + theta[32]*(1 + phi)
		gtheta[191] = phi*theta[28] + theta[33]*(1 + phi)
		gtheta[192] = phi*theta[31] + theta[34]*(1 + phi)
		gtheta[193] = theta[35]
		gtheta[194] = theta[36]
		gtheta[195] = phi*theta[17] + theta[37]*(1 + phi)
		gtheta[196] = theta[38]
		gtheta[197] = theta[39]
		gtheta[198] = phi*theta[35] + theta[40]*(1 + phi)
		gtheta[199] = theta[41]
		gtheta[200] = phi*theta[36] + theta[42]*(1 + phi)
		gtheta[201] = theta[43]
		gtheta[202] = phi*theta[38] + theta[44]*(1 + phi)
		gtheta[203] = phi*theta[39] + theta[45]*(1 + phi)
		gtheta[204] = theta[46]
		gtheta[205] = phi*theta[41] + theta[47]*(1 + phi)
		gtheta[206] = phi*theta[43] + theta[48]*(1 + phi)
		gtheta[207] = phi*theta[46] + theta[49]*(1 + phi)
		gtheta[208] = theta[50]
		gtheta[209] = theta[51]
		gtheta[210] = phi*theta[18] + theta[52]*(1 + phi)
		gtheta[211] = theta[53]
		gtheta[212] = theta[54]
		gtheta[213] = phi*theta[50] + theta[55]*(1 + phi)
		gtheta[214] = theta[56]
		gtheta[215] = phi*theta[51] + theta[57]*(1 + phi)
		gtheta[216] = theta[58]
		gtheta[217] = phi*theta[53] + theta[59]*(1 + phi)
		gtheta[218] = phi*theta[54] + theta[60]*(1 + phi)
		gtheta[219] = theta[61]
		gtheta[220] = phi*theta[56] + theta[62]*(1 + phi)
		gtheta[221] = phi*theta[58] + theta[63]*(1 + phi)
		gtheta[222] = phi*theta[61] + theta[64]*(1 + phi)
		gtheta[223] = theta[65]
		gtheta[224] = theta[66]
		gtheta[225] = phi*theta[19] + theta[67]*(1 + phi)
		gtheta[226] = theta[68]
		gtheta[227] = theta[69]
		gtheta[228] = phi*theta[65] + theta[70]*(1 + phi)
		gtheta[229] = theta[71]
		gtheta[230] = phi*theta[66] + theta[72]*(1 + phi)
		gtheta[231] = theta[73]
		gtheta[232] = phi*theta[68] + theta[74]*(1 + phi)
		gtheta[233] = phi*theta[69] + theta[75]*(1 + phi)
		gtheta[234] = theta[76]
		gtheta[235] = phi*theta[71] + theta[77]*(1 + phi)
		gtheta[236] = phi*theta[73] + theta[78]*(1 + phi)
		gtheta[237] = phi*theta[76] + theta[79]*(1 + phi)
		gtheta[238] = theta[1]
		gtheta[239] = theta[2]
		gtheta[240] = theta[3]
		gtheta[241] = theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[242] = theta[5]
		gtheta[243] = theta[6]
		gtheta[244] = phi*theta[1] + theta[7]*(1 + phi)
		gtheta[245] = theta[8]
		gtheta[246] = phi*theta[2] + theta[9]*(1 + phi)
		gtheta[247] = phi*theta[3] + theta[10]*(1 + phi)
		gtheta[248] = theta[11]
		gtheta[249] = phi*theta[5] + theta[12]*(1 + phi)
		gtheta[250] = phi*theta[6] + theta[13]*(1 + phi)
		gtheta[251] = phi*theta[8] + theta[14]*(1 + phi)
		gtheta[252] = phi*theta[11] + theta[15]*(1 + phi)
		gtheta[253] = theta[16]
		gtheta[254] = theta[17]
		gtheta[255] = theta[18]
		gtheta[256] = rho + theta[19]
		gtheta[257] = theta[20]
		gtheta[258] = theta[21]
		gtheta[259] = theta[22]
		gtheta[260] = phi*theta[16] + theta[23]*(1 + phi)
		gtheta[261] = theta[24]
		gtheta[262] = theta[25]
		gtheta[263] = phi*theta[20] + theta[26]*(1 + phi)
		gtheta[264] = theta[27]
		gtheta[265] = phi*theta[21] + theta[28]*(1 + phi)
		gtheta[266] = phi*theta[22] + theta[29]*(1 + phi)
		gtheta[267] = theta[30]
		gtheta[268] = phi*theta[24] + theta[31]*(1 + phi)
		gtheta[269] = phi*theta[25] + theta[32]*(1 + phi)
		gtheta[270] = phi*theta[27] + theta[33]*(1 + phi)
		gtheta[271] = phi*theta[30] + theta[34]*(1 + phi)
		gtheta[272] = theta[35]
		gtheta[273] = theta[36]
		gtheta[274] = theta[37]
		gtheta[275] = phi*theta[17] + theta[38]*(1 + phi)
		gtheta[276] = theta[39]
		gtheta[277] = theta[40]
		gtheta[278] = phi*theta[35] + theta[41]*(1 + phi)
		gtheta[279] = theta[42]
		gtheta[280] = phi*theta[36] + theta[43]*(1 + phi)
		gtheta[281] = phi*theta[37] + theta[44]*(1 + phi)
		gtheta[282] = theta[45]
		gtheta[283] = phi*theta[39] + theta[46]*(1 + phi)
		gtheta[284] = phi*theta[40] + theta[47]*(1 + phi)
		gtheta[285] = phi*theta[42] + theta[48]*(1 + phi)
		gtheta[286] = phi*theta[45] + theta[49]*(1 + phi)
		gtheta[287] = theta[50]
		gtheta[288] = theta[51]
		gtheta[289] = theta[52]
		gtheta[290] = phi*theta[18] + theta[53]*(1 + phi)
		gtheta[291] = theta[54]
		gtheta[292] = theta[55]
		gtheta[293] = phi*theta[50] + theta[56]*(1 + phi)
		gtheta[294] = theta[57]
		gtheta[295] = phi*theta[51] + theta[58]*(1 + phi)
		gtheta[296] = phi*theta[52] + theta[59]*(1 + phi)
		gtheta[297] = theta[60]
		gtheta[298] = phi*theta[54] + theta[61]*(1 + phi)
		gtheta[299] = phi*theta[55] + theta[62]*(1 + phi)
		gtheta[300] = phi*theta[57] + theta[63]*(1 + phi)
		gtheta[301] = phi*theta[60] + theta[64]*(1 + phi)
		gtheta[302] = theta[65]
		gtheta[303] = theta[66]
		gtheta[304] = theta[67]
		gtheta[305] = phi*theta[19] + theta[68]*(1 + phi)
		gtheta[306] = theta[69]
		gtheta[307] = theta[70]
		gtheta[308] = phi*theta[65] + theta[71]*(1 + phi)
		gtheta[309] = theta[72]
		gtheta[310] = phi*theta[66] + theta[73]*(1 + phi)
		gtheta[311] = phi*theta[67] + theta[74]*(1 + phi)
		gtheta[312] = theta[75]
		gtheta[313] = phi*theta[69] + theta[76]*(1 + phi)
		gtheta[314] = phi*theta[70] + theta[77]*(1 + phi)
		gtheta[315] = phi*theta[72] + theta[78]*(1 + phi)
		gtheta[316] = phi*theta[75] + theta[79]*(1 + phi)
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat334endo( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,316,1)
		lambda0= -theta[1..79]*hmean'

		rho=theta[80]
		beta=theta[81]
		phi=theta[82]
		
		gtheta[1]   = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]   = theta[2]
		gtheta[3]   = theta[3]
		gtheta[4]   = theta[4]
		gtheta[5]   = phi*theta[2] + theta[5]*(1 + phi)
		gtheta[6]   = phi*theta[3] + theta[6]*(1 + phi)
		gtheta[7]   = phi*theta[4] + theta[7]*(1 + phi)
		gtheta[8]   = theta[8]
		gtheta[9]   = theta[9]
		gtheta[10]  = theta[10]
		gtheta[11]  = phi*theta[8] + theta[11]*(1 + phi)
		gtheta[12]  = phi*theta[9] + theta[12]*(1 + phi)
		gtheta[13]  = phi*theta[10] + theta[13]*(1 + phi)
		gtheta[14]  = theta[14]
		gtheta[15]  = phi*theta[14] + theta[15]*(1 + phi)
		gtheta[16]  = rho + theta[16]
		gtheta[17]  = theta[17]
		gtheta[18]  = theta[18]
		gtheta[19]  = theta[19]
		gtheta[20]  = phi*theta[16] + theta[20]*(1 + phi)
		gtheta[21]  = theta[21]
		gtheta[22]  = theta[22]
		gtheta[23]  = theta[23]
		gtheta[24]  = phi*theta[21] + theta[24]*(1 + phi)
		gtheta[25]  = phi*theta[22] + theta[25]*(1 + phi)
		gtheta[26]  = phi*theta[23] + theta[26]*(1 + phi)
		gtheta[27]  = theta[27]
		gtheta[28]  = theta[28]
		gtheta[29]  = theta[29]
		gtheta[30]  = phi*theta[27] + theta[30]*(1 + phi)
		gtheta[31]  = phi*theta[28] + theta[31]*(1 + phi)
		gtheta[32]  = phi*theta[29] + theta[32]*(1 + phi)
		gtheta[33]  = theta[33]
		gtheta[34]  = phi*theta[33] + theta[34]*(1 + phi)
		gtheta[35]  = phi*theta[17] + theta[35]*(1 + phi)
		gtheta[36]  = theta[36]
		gtheta[37]  = theta[37]
		gtheta[38]  = theta[38]
		gtheta[39]  = phi*theta[36] + theta[39]*(1 + phi)
		gtheta[40]  = phi*theta[37] + theta[40]*(1 + phi)
		gtheta[41]  = phi*theta[38] + theta[41]*(1 + phi)
		gtheta[42]  = theta[42]
		gtheta[43]  = theta[43]
		gtheta[44]  = theta[44]
		gtheta[45]  = phi*theta[42] + theta[45]*(1 + phi)
		gtheta[46]  = phi*theta[43] + theta[46]*(1 + phi)
		gtheta[47]  = phi*theta[44] + theta[47]*(1 + phi)
		gtheta[48]  = theta[48]
		gtheta[49]  = phi*theta[48] + theta[49]*(1 + phi)
		gtheta[50]  = phi*theta[18] + theta[50]*(1 + phi)
		gtheta[51]  = theta[51]
		gtheta[52]  = theta[52]
		gtheta[53]  = theta[53]
		gtheta[54]  = phi*theta[51] + theta[54]*(1 + phi)
		gtheta[55]  = phi*theta[52] + theta[55]*(1 + phi)
		gtheta[56]  = phi*theta[53] + theta[56]*(1 + phi)
		gtheta[57]  = theta[57]
		gtheta[58]  = theta[58]
		gtheta[59]  = theta[59]
		gtheta[60]  = phi*theta[57] + theta[60]*(1 + phi)
		gtheta[61]  = phi*theta[58] + theta[61]*(1 + phi)
		gtheta[62]  = phi*theta[59] + theta[62]*(1 + phi)
		gtheta[63]  = theta[63]
		gtheta[64]  = phi*theta[63] + theta[64]*(1 + phi)
		gtheta[65]  = phi*theta[19] + theta[65]*(1 + phi)
		gtheta[66]  = theta[66]
		gtheta[67]  = theta[67]
		gtheta[68]  = theta[68]
		gtheta[69]  = phi*theta[66] + theta[69]*(1 + phi)
		gtheta[70]  = phi*theta[67] + theta[70]*(1 + phi)
		gtheta[71]  = phi*theta[68] + theta[71]*(1 + phi)
		gtheta[72]  = theta[72]
		gtheta[73]  = theta[73]
		gtheta[74]  = theta[74]
		gtheta[75]  = phi*theta[72] + theta[75]*(1 + phi)
		gtheta[76]  = phi*theta[73] + theta[76]*(1 + phi)
		gtheta[77]  = phi*theta[74] + theta[77]*(1 + phi)
		gtheta[78]  = theta[78]
		gtheta[79]  = phi*theta[78] + theta[79]*(1 + phi)
		gtheta[80]  = theta[1]
		gtheta[81]  = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[82]  = theta[3]
		gtheta[83]  = theta[4]
		gtheta[84]  = phi*theta[1] + theta[5]*(1 + phi)
		gtheta[85]  = theta[6]
		gtheta[86]  = theta[7]
		gtheta[87]  = phi*theta[3] + theta[8]*(1 + phi)
		gtheta[88]  = phi*theta[4] + theta[9]*(1 + phi)
		gtheta[89]  = theta[10]
		gtheta[90]  = phi*theta[6] + theta[11]*(1 + phi)
		gtheta[91]  = phi*theta[7] + theta[12]*(1 + phi)
		gtheta[92]  = theta[13]
		gtheta[93]  = phi*theta[10] + theta[14]*(1 + phi)
		gtheta[94]  = phi*theta[13] + theta[15]*(1 + phi)
		gtheta[95]  = theta[16]
		gtheta[96]  = rho + theta[17]
		gtheta[97]  = theta[18]
		gtheta[98]  = theta[19]
		gtheta[99]  = theta[20]
		gtheta[100] = phi*theta[16] + theta[21]*(1 + phi)
		gtheta[101] = theta[22]
		gtheta[102] = theta[23]
		gtheta[103] = phi*theta[20] + theta[24]*(1 + phi)
		gtheta[104] = theta[25]
		gtheta[105] = theta[26]
		gtheta[106] = phi*theta[22] + theta[27]*(1 + phi)
		gtheta[107] = phi*theta[23] + theta[28]*(1 + phi)
		gtheta[108] = theta[29]
		gtheta[109] = phi*theta[25] + theta[30]*(1 + phi)
		gtheta[110] = phi*theta[26] + theta[31]*(1 + phi)
		gtheta[111] = theta[32]
		gtheta[112] = phi*theta[29] + theta[33]*(1 + phi)
		gtheta[113] = phi*theta[32] + theta[34]*(1 + phi)
		gtheta[114] = theta[35]
		gtheta[115] = phi*theta[17] + theta[36]*(1 + phi)
		gtheta[116] = theta[37]
		gtheta[117] = theta[38]
		gtheta[118] = phi*theta[35] + theta[39]*(1 + phi)
		gtheta[119] = theta[40]
		gtheta[120] = theta[41]
		gtheta[121] = phi*theta[37] + theta[42]*(1 + phi)
		gtheta[122] = phi*theta[38] + theta[43]*(1 + phi)
		gtheta[123] = theta[44]
		gtheta[124] = phi*theta[40] + theta[45]*(1 + phi)
		gtheta[125] = phi*theta[41] + theta[46]*(1 + phi)
		gtheta[126] = theta[47]
		gtheta[127] = phi*theta[44] + theta[48]*(1 + phi)
		gtheta[128] = phi*theta[47] + theta[49]*(1 + phi)
		gtheta[129] = theta[50]
		gtheta[130] = phi*theta[18] + theta[51]*(1 + phi)
		gtheta[131] = theta[52]
		gtheta[132] = theta[53]
		gtheta[133] = phi*theta[50] + theta[54]*(1 + phi)
		gtheta[134] = theta[55]
		gtheta[135] = theta[56]
		gtheta[136] = phi*theta[52] + theta[57]*(1 + phi)
		gtheta[137] = phi*theta[53] + theta[58]*(1 + phi)
		gtheta[138] = theta[59]
		gtheta[139] = phi*theta[55] + theta[60]*(1 + phi)
		gtheta[140] = phi*theta[56] + theta[61]*(1 + phi)
		gtheta[141] = theta[62]
		gtheta[142] = phi*theta[59] + theta[63]*(1 + phi)
		gtheta[143] = phi*theta[62] + theta[64]*(1 + phi)
		gtheta[144] = theta[65]
		gtheta[145] = phi*theta[19] + theta[66]*(1 + phi)
		gtheta[146] = theta[67]
		gtheta[147] = theta[68]
		gtheta[148] = phi*theta[65] + theta[69]*(1 + phi)
		gtheta[149] = theta[70]
		gtheta[150] = theta[71]
		gtheta[151] = phi*theta[67] + theta[72]*(1 + phi)
		gtheta[152] = phi*theta[68] + theta[73]*(1 + phi)
		gtheta[153] = theta[74]
		gtheta[154] = phi*theta[70] + theta[75]*(1 + phi)
		gtheta[155] = phi*theta[71] + theta[76]*(1 + phi)
		gtheta[156] = theta[77]
		gtheta[157] = phi*theta[74] + theta[78]*(1 + phi)
		gtheta[158] = phi*theta[77] + theta[79]*(1 + phi)
		gtheta[159] = theta[1]
		gtheta[160] = theta[2]
		gtheta[161] = theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[162] = theta[4]
		gtheta[163] = theta[5]
		gtheta[164] = phi*theta[1] + theta[6]*(1 + phi)
		gtheta[165] = theta[7]
		gtheta[166] = phi*theta[2] + theta[8]*(1 + phi)
		gtheta[167] = theta[9]
		gtheta[168] = phi*theta[4] + theta[10]*(1 + phi)
		gtheta[169] = phi*theta[5] + theta[11]*(1 + phi)
		gtheta[170] = theta[12]
		gtheta[171] = phi*theta[7] + theta[13]*(1 + phi)
		gtheta[172] = phi*theta[9] + theta[14]*(1 + phi)
		gtheta[173] = phi*theta[12] + theta[15]*(1 + phi)
		gtheta[174] = theta[16]
		gtheta[175] = theta[17]
		gtheta[176] = rho + theta[18]
		gtheta[177] = theta[19]
		gtheta[178] = theta[20]
		gtheta[179] = theta[21]
		gtheta[180] = phi*theta[16] + theta[22]*(1 + phi)
		gtheta[181] = theta[23]
		gtheta[182] = theta[24]
		gtheta[183] = phi*theta[20] + theta[25]*(1 + phi)
		gtheta[184] = theta[26]
		gtheta[185] = phi*theta[21] + theta[27]*(1 + phi)
		gtheta[186] = theta[28]
		gtheta[187] = phi*theta[23] + theta[29]*(1 + phi)
		gtheta[188] = phi*theta[24] + theta[30]*(1 + phi)
		gtheta[189] = theta[31]
		gtheta[190] = phi*theta[26] + theta[32]*(1 + phi)
		gtheta[191] = phi*theta[28] + theta[33]*(1 + phi)
		gtheta[192] = phi*theta[31] + theta[34]*(1 + phi)
		gtheta[193] = theta[35]
		gtheta[194] = theta[36]
		gtheta[195] = phi*theta[17] + theta[37]*(1 + phi)
		gtheta[196] = theta[38]
		gtheta[197] = theta[39]
		gtheta[198] = phi*theta[35] + theta[40]*(1 + phi)
		gtheta[199] = theta[41]
		gtheta[200] = phi*theta[36] + theta[42]*(1 + phi)
		gtheta[201] = theta[43]
		gtheta[202] = phi*theta[38] + theta[44]*(1 + phi)
		gtheta[203] = phi*theta[39] + theta[45]*(1 + phi)
		gtheta[204] = theta[46]
		gtheta[205] = phi*theta[41] + theta[47]*(1 + phi)
		gtheta[206] = phi*theta[43] + theta[48]*(1 + phi)
		gtheta[207] = phi*theta[46] + theta[49]*(1 + phi)
		gtheta[208] = theta[50]
		gtheta[209] = theta[51]
		gtheta[210] = phi*theta[18] + theta[52]*(1 + phi)
		gtheta[211] = theta[53]
		gtheta[212] = theta[54]
		gtheta[213] = phi*theta[50] + theta[55]*(1 + phi)
		gtheta[214] = theta[56]
		gtheta[215] = phi*theta[51] + theta[57]*(1 + phi)
		gtheta[216] = theta[58]
		gtheta[217] = phi*theta[53] + theta[59]*(1 + phi)
		gtheta[218] = phi*theta[54] + theta[60]*(1 + phi)
		gtheta[219] = theta[61]
		gtheta[220] = phi*theta[56] + theta[62]*(1 + phi)
		gtheta[221] = phi*theta[58] + theta[63]*(1 + phi)
		gtheta[222] = phi*theta[61] + theta[64]*(1 + phi)
		gtheta[223] = theta[65]
		gtheta[224] = theta[66]
		gtheta[225] = phi*theta[19] + theta[67]*(1 + phi)
		gtheta[226] = theta[68]
		gtheta[227] = theta[69]
		gtheta[228] = phi*theta[65] + theta[70]*(1 + phi)
		gtheta[229] = theta[71]
		gtheta[230] = phi*theta[66] + theta[72]*(1 + phi)
		gtheta[231] = theta[73]
		gtheta[232] = phi*theta[68] + theta[74]*(1 + phi)
		gtheta[233] = phi*theta[69] + theta[75]*(1 + phi)
		gtheta[234] = theta[76]
		gtheta[235] = phi*theta[71] + theta[77]*(1 + phi)
		gtheta[236] = phi*theta[73] + theta[78]*(1 + phi)
		gtheta[237] = phi*theta[76] + theta[79]*(1 + phi)
		gtheta[238] = theta[1]
		gtheta[239] = theta[2]
		gtheta[240] = theta[3]
		gtheta[241] = theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[242] = theta[5]
		gtheta[243] = theta[6]
		gtheta[244] = phi*theta[1] + theta[7]*(1 + phi)
		gtheta[245] = theta[8]
		gtheta[246] = phi*theta[2] + theta[9]*(1 + phi)
		gtheta[247] = phi*theta[3] + theta[10]*(1 + phi)
		gtheta[248] = theta[11]
		gtheta[249] = phi*theta[5] + theta[12]*(1 + phi)
		gtheta[250] = phi*theta[6] + theta[13]*(1 + phi)
		gtheta[251] = phi*theta[8] + theta[14]*(1 + phi)
		gtheta[252] = phi*theta[11] + theta[15]*(1 + phi)
		gtheta[253] = theta[16]
		gtheta[254] = theta[17]
		gtheta[255] = theta[18]
		gtheta[256] = rho + theta[19]
		gtheta[257] = theta[20]
		gtheta[258] = theta[21]
		gtheta[259] = theta[22]
		gtheta[260] = phi*theta[16] + theta[23]*(1 + phi)
		gtheta[261] = theta[24]
		gtheta[262] = theta[25]
		gtheta[263] = phi*theta[20] + theta[26]*(1 + phi)
		gtheta[264] = theta[27]
		gtheta[265] = phi*theta[21] + theta[28]*(1 + phi)
		gtheta[266] = phi*theta[22] + theta[29]*(1 + phi)
		gtheta[267] = theta[30]
		gtheta[268] = phi*theta[24] + theta[31]*(1 + phi)
		gtheta[269] = phi*theta[25] + theta[32]*(1 + phi)
		gtheta[270] = phi*theta[27] + theta[33]*(1 + phi)
		gtheta[271] = phi*theta[30] + theta[34]*(1 + phi)
		gtheta[272] = theta[35]
		gtheta[273] = theta[36]
		gtheta[274] = theta[37]
		gtheta[275] = phi*theta[17] + theta[38]*(1 + phi)
		gtheta[276] = theta[39]
		gtheta[277] = theta[40]
		gtheta[278] = phi*theta[35] + theta[41]*(1 + phi)
		gtheta[279] = theta[42]
		gtheta[280] = phi*theta[36] + theta[43]*(1 + phi)
		gtheta[281] = phi*theta[37] + theta[44]*(1 + phi)
		gtheta[282] = theta[45]
		gtheta[283] = phi*theta[39] + theta[46]*(1 + phi)
		gtheta[284] = phi*theta[40] + theta[47]*(1 + phi)
		gtheta[285] = phi*theta[42] + theta[48]*(1 + phi)
		gtheta[286] = phi*theta[45] + theta[49]*(1 + phi)
		gtheta[287] = theta[50]
		gtheta[288] = theta[51]
		gtheta[289] = theta[52]
		gtheta[290] = phi*theta[18] + theta[53]*(1 + phi)
		gtheta[291] = theta[54]
		gtheta[292] = theta[55]
		gtheta[293] = phi*theta[50] + theta[56]*(1 + phi)
		gtheta[294] = theta[57]
		gtheta[295] = phi*theta[51] + theta[58]*(1 + phi)
		gtheta[296] = phi*theta[52] + theta[59]*(1 + phi)
		gtheta[297] = theta[60]
		gtheta[298] = phi*theta[54] + theta[61]*(1 + phi)
		gtheta[299] = phi*theta[55] + theta[62]*(1 + phi)
		gtheta[300] = phi*theta[57] + theta[63]*(1 + phi)
		gtheta[301] = phi*theta[60] + theta[64]*(1 + phi)
		gtheta[302] = theta[65]
		gtheta[303] = theta[66]
		gtheta[304] = theta[67]
		gtheta[305] = phi*theta[19] + theta[68]*(1 + phi)
		gtheta[306] = theta[69]
		gtheta[307] = theta[70]
		gtheta[308] = phi*theta[65] + theta[71]*(1 + phi)
		gtheta[309] = theta[72]
		gtheta[310] = phi*theta[66] + theta[73]*(1 + phi)
		gtheta[311] = phi*theta[67] + theta[74]*(1 + phi)
		gtheta[312] = theta[75]
		gtheta[313] = phi*theta[69] + theta[76]*(1 + phi)
		gtheta[314] = phi*theta[70] + theta[77]*(1 + phi)
		gtheta[315] = phi*theta[72] + theta[78]*(1 + phi)
		gtheta[316] = phi*theta[75] + theta[79]*(1 + phi)
		
	}


// ------------------------- END 4 YEAR ----------------------------------------

// -------------------------- 5 YEARS ------------------------------------------

// ---------------------------------- CRC --------------------------------------

	void myeval5(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,155,1)
		beta=theta[32]
		phi=theta[33]
		lambda0= -theta[1..31]*hmean'
		
		
		gtheta[1] =theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2] =theta[2]
		gtheta[3] =theta[3]
		gtheta[4] =theta[4]
		gtheta[5] =theta[5]
		gtheta[6] =phi*theta[2] + theta[6]*(1 + phi)
		gtheta[7] =phi*theta[3] + theta[7]*(1 + phi)
		gtheta[8] =phi*theta[4] + theta[8]*(1 + phi)
		gtheta[9] =phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10] =theta[10]
		gtheta[11] =theta[11]
		gtheta[12] =theta[12]
		gtheta[13] =theta[13]
		gtheta[14] =theta[14]
		gtheta[15] =theta[15]
		gtheta[16] =phi*theta[10] + theta[16]*(1 + phi)
		gtheta[17] =phi*theta[11] + theta[17]*(1 + phi)
		gtheta[18] =phi*theta[12] + theta[18]*(1 + phi)
		gtheta[19] =phi*theta[13] + theta[19]*(1 + phi)
		gtheta[20] =phi*theta[14] + theta[20]*(1 + phi)
		gtheta[21] =phi*theta[15] + theta[21]*(1 + phi)
		gtheta[22] =theta[22]
		gtheta[23] =theta[23]
		gtheta[24] =theta[24]
		gtheta[25] =theta[25]
		gtheta[26] =phi*theta[22] + theta[26]*(1 + phi)
		gtheta[27] =phi*theta[23] + theta[27]*(1 + phi)
		gtheta[28] =phi*theta[24] + theta[28]*(1 + phi)
		gtheta[29] =phi*theta[25] + theta[29]*(1 + phi)
		gtheta[30] =theta[30]
		gtheta[31] =phi*theta[30] + theta[31]*(1 + phi)
		gtheta[32] =theta[1]
		gtheta[33] =theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[34] =theta[3]
		gtheta[35] =theta[4]
		gtheta[36] =theta[5]
		gtheta[37] =phi*theta[1] + theta[6]*(1 + phi)
		gtheta[38] =theta[7]
		gtheta[39] =theta[8]
		gtheta[40] =theta[9]
		gtheta[41] =phi*theta[3] + theta[10]*(1 + phi)
		gtheta[42] =phi*theta[4] + theta[11]*(1 + phi)
		gtheta[43] =phi*theta[5] + theta[12]*(1 + phi)
		gtheta[44] =theta[13]
		gtheta[45] =theta[14]
		gtheta[46] =theta[15]
		gtheta[47] =phi*theta[7] + theta[16]*(1 + phi)
		gtheta[48] =phi*theta[8] + theta[17]*(1 + phi)
		gtheta[49] =phi*theta[9] + theta[18]*(1 + phi)
		gtheta[50] =theta[19]
		gtheta[51] =theta[20]
		gtheta[52] =theta[21]
		gtheta[53] =phi*theta[13] + theta[22]*(1 + phi)
		gtheta[54] =phi*theta[14] + theta[23]*(1 + phi)
		gtheta[55] =phi*theta[15] + theta[24]*(1 + phi)
		gtheta[56] =theta[25]
		gtheta[57] =phi*theta[19] + theta[26]*(1 + phi)
		gtheta[58] =phi*theta[20] + theta[27]*(1 + phi)
		gtheta[59] =phi*theta[21] + theta[28]*(1 + phi)
		gtheta[60] =theta[29]
		gtheta[61] =phi*theta[25] + theta[30]*(1 + phi)
		gtheta[62] =phi*theta[29] + theta[31]*(1 + phi)
		gtheta[63] =theta[1]
		gtheta[64] =theta[2]
		gtheta[65] =theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[66] =theta[4]
		gtheta[67] =theta[5]
		gtheta[68] =theta[6]
		gtheta[69] =phi*theta[1] + theta[7]*(1 + phi)
		gtheta[70] =theta[8]
		gtheta[71] =theta[9]
		gtheta[72] =phi*theta[2] + theta[10]*(1 + phi)
		gtheta[73] =theta[11]
		gtheta[74] =theta[12]
		gtheta[75] =phi*theta[4] + theta[13]*(1 + phi)
		gtheta[76] =phi*theta[5] + theta[14]*(1 + phi)
		gtheta[77] =theta[15]
		gtheta[78] =phi*theta[6] + theta[16]*(1 + phi)
		gtheta[79] =theta[17]
		gtheta[80] =theta[18]
		gtheta[81] =phi*theta[8] + theta[19]*(1 + phi)
		gtheta[82] =phi*theta[9] + theta[20]*(1 + phi)
		gtheta[83] =theta[21]
		gtheta[84] =phi*theta[11] + theta[22]*(1 + phi)
		gtheta[85] =phi*theta[12] + theta[23]*(1 + phi)
		gtheta[86] =theta[24]
		gtheta[87] =phi*theta[15] + theta[25]*(1 + phi)
		gtheta[88] =phi*theta[17] + theta[26]*(1 + phi)
		gtheta[89] =phi*theta[18] + theta[27]*(1 + phi)
		gtheta[90] =theta[28]
		gtheta[91] =phi*theta[21] + theta[29]*(1 + phi)
		gtheta[92] =phi*theta[24] + theta[30]*(1 + phi)
		gtheta[93] =phi*theta[28] + theta[31]*(1 + phi)
		gtheta[94] =theta[1]
		gtheta[95] =theta[2]
		gtheta[96] =theta[3]
		gtheta[97] =theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[98] =theta[5]
		gtheta[99] =theta[6]
		gtheta[100] =theta[7]
		gtheta[101] =phi*theta[1] + theta[8]*(1 + phi)
		gtheta[102] =theta[9]
		gtheta[103] =theta[10]
		gtheta[104] =phi*theta[2] + theta[11]*(1 + phi)
		gtheta[105] =theta[12]
		gtheta[106] =phi*theta[3] + theta[13]*(1 + phi)
		gtheta[107] =theta[14]
		gtheta[108] =phi*theta[5] + theta[15]*(1 + phi)
		gtheta[109] =theta[16]
		gtheta[110] =phi*theta[6] + theta[17]*(1 + phi)
		gtheta[111] =theta[18]
		gtheta[112] =phi*theta[7] + theta[19]*(1 + phi)
		gtheta[113] =theta[20]
		gtheta[114] =phi*theta[9] + theta[21]*(1 + phi)
		gtheta[115] =phi*theta[10] + theta[22]*(1 + phi)
		gtheta[116] =theta[23]
		gtheta[117] =phi*theta[12] + theta[24]*(1 + phi)
		gtheta[118] =phi*theta[14] + theta[25]*(1 + phi)
		gtheta[119] =phi*theta[16] + theta[26]*(1 + phi)
		gtheta[120] =theta[27]
		gtheta[121] =phi*theta[18] + theta[28]*(1 + phi)
		gtheta[122] =phi*theta[20] + theta[29]*(1 + phi)
		gtheta[123] =phi*theta[23] + theta[30]*(1 + phi)
		gtheta[124] =phi*theta[27] + theta[31]*(1 + phi)
		gtheta[125] =theta[1]
		gtheta[126] =theta[2]
		gtheta[127] =theta[3]
		gtheta[128] =theta[4]
		gtheta[129] =theta[5]*(1 + phi) + beta + phi*lambda0
		gtheta[130] =theta[6]
		gtheta[131] =theta[7]
		gtheta[132] =theta[8]
		gtheta[133] =phi*theta[1] + theta[9]*(1 + phi)
		gtheta[134] =theta[10]
		gtheta[135] =theta[11]
		gtheta[136] =phi*theta[2] + theta[12]*(1 + phi)
		gtheta[137] =theta[13]
		gtheta[138] =phi*theta[3] + theta[14]*(1 + phi)
		gtheta[139] =phi*theta[4] + theta[15]*(1 + phi)
		gtheta[140] =theta[16]
		gtheta[141] =theta[17]
		gtheta[142] =phi*theta[6] + theta[18]*(1 + phi)
		gtheta[143] =theta[19]
		gtheta[144] =phi*theta[7] + theta[20]*(1 + phi)
		gtheta[145] =phi*theta[8] + theta[21]*(1 + phi)
		gtheta[146] =theta[22]
		gtheta[147] =phi*theta[10] + theta[23]*(1 + phi)
		gtheta[148] =phi*theta[11] + theta[24]*(1 + phi)
		gtheta[149] =phi*theta[13] + theta[25]*(1 + phi)
		gtheta[150] =theta[26]
		gtheta[151] =phi*theta[16] + theta[27]*(1 + phi)
		gtheta[152] =phi*theta[17] + theta[28]*(1 + phi)
		gtheta[153] =phi*theta[19] + theta[29]*(1 + phi)
		gtheta[154] =phi*theta[22] + theta[30]*(1 + phi)
		gtheta[155] =phi*theta[26] + theta[31]*(1 + phi)
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat335( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,155,1)
		beta=theta[32]
		phi=theta[33]
		lambda0= -theta[1..31]*hmean'
		
		
		gtheta[1] =theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2] =theta[2]
		gtheta[3] =theta[3]
		gtheta[4] =theta[4]
		gtheta[5] =theta[5]
		gtheta[6] =phi*theta[2] + theta[6]*(1 + phi)
		gtheta[7] =phi*theta[3] + theta[7]*(1 + phi)
		gtheta[8] =phi*theta[4] + theta[8]*(1 + phi)
		gtheta[9] =phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10] =theta[10]
		gtheta[11] =theta[11]
		gtheta[12] =theta[12]
		gtheta[13] =theta[13]
		gtheta[14] =theta[14]
		gtheta[15] =theta[15]
		gtheta[16] =phi*theta[10] + theta[16]*(1 + phi)
		gtheta[17] =phi*theta[11] + theta[17]*(1 + phi)
		gtheta[18] =phi*theta[12] + theta[18]*(1 + phi)
		gtheta[19] =phi*theta[13] + theta[19]*(1 + phi)
		gtheta[20] =phi*theta[14] + theta[20]*(1 + phi)
		gtheta[21] =phi*theta[15] + theta[21]*(1 + phi)
		gtheta[22] =theta[22]
		gtheta[23] =theta[23]
		gtheta[24] =theta[24]
		gtheta[25] =theta[25]
		gtheta[26] =phi*theta[22] + theta[26]*(1 + phi)
		gtheta[27] =phi*theta[23] + theta[27]*(1 + phi)
		gtheta[28] =phi*theta[24] + theta[28]*(1 + phi)
		gtheta[29] =phi*theta[25] + theta[29]*(1 + phi)
		gtheta[30] =theta[30]
		gtheta[31] =phi*theta[30] + theta[31]*(1 + phi)
		gtheta[32] =theta[1]
		gtheta[33] =theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[34] =theta[3]
		gtheta[35] =theta[4]
		gtheta[36] =theta[5]
		gtheta[37] =phi*theta[1] + theta[6]*(1 + phi)
		gtheta[38] =theta[7]
		gtheta[39] =theta[8]
		gtheta[40] =theta[9]
		gtheta[41] =phi*theta[3] + theta[10]*(1 + phi)
		gtheta[42] =phi*theta[4] + theta[11]*(1 + phi)
		gtheta[43] =phi*theta[5] + theta[12]*(1 + phi)
		gtheta[44] =theta[13]
		gtheta[45] =theta[14]
		gtheta[46] =theta[15]
		gtheta[47] =phi*theta[7] + theta[16]*(1 + phi)
		gtheta[48] =phi*theta[8] + theta[17]*(1 + phi)
		gtheta[49] =phi*theta[9] + theta[18]*(1 + phi)
		gtheta[50] =theta[19]
		gtheta[51] =theta[20]
		gtheta[52] =theta[21]
		gtheta[53] =phi*theta[13] + theta[22]*(1 + phi)
		gtheta[54] =phi*theta[14] + theta[23]*(1 + phi)
		gtheta[55] =phi*theta[15] + theta[24]*(1 + phi)
		gtheta[56] =theta[25]
		gtheta[57] =phi*theta[19] + theta[26]*(1 + phi)
		gtheta[58] =phi*theta[20] + theta[27]*(1 + phi)
		gtheta[59] =phi*theta[21] + theta[28]*(1 + phi)
		gtheta[60] =theta[29]
		gtheta[61] =phi*theta[25] + theta[30]*(1 + phi)
		gtheta[62] =phi*theta[29] + theta[31]*(1 + phi)
		gtheta[63] =theta[1]
		gtheta[64] =theta[2]
		gtheta[65] =theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[66] =theta[4]
		gtheta[67] =theta[5]
		gtheta[68] =theta[6]
		gtheta[69] =phi*theta[1] + theta[7]*(1 + phi)
		gtheta[70] =theta[8]
		gtheta[71] =theta[9]
		gtheta[72] =phi*theta[2] + theta[10]*(1 + phi)
		gtheta[73] =theta[11]
		gtheta[74] =theta[12]
		gtheta[75] =phi*theta[4] + theta[13]*(1 + phi)
		gtheta[76] =phi*theta[5] + theta[14]*(1 + phi)
		gtheta[77] =theta[15]
		gtheta[78] =phi*theta[6] + theta[16]*(1 + phi)
		gtheta[79] =theta[17]
		gtheta[80] =theta[18]
		gtheta[81] =phi*theta[8] + theta[19]*(1 + phi)
		gtheta[82] =phi*theta[9] + theta[20]*(1 + phi)
		gtheta[83] =theta[21]
		gtheta[84] =phi*theta[11] + theta[22]*(1 + phi)
		gtheta[85] =phi*theta[12] + theta[23]*(1 + phi)
		gtheta[86] =theta[24]
		gtheta[87] =phi*theta[15] + theta[25]*(1 + phi)
		gtheta[88] =phi*theta[17] + theta[26]*(1 + phi)
		gtheta[89] =phi*theta[18] + theta[27]*(1 + phi)
		gtheta[90] =theta[28]
		gtheta[91] =phi*theta[21] + theta[29]*(1 + phi)
		gtheta[92] =phi*theta[24] + theta[30]*(1 + phi)
		gtheta[93] =phi*theta[28] + theta[31]*(1 + phi)
		gtheta[94] =theta[1]
		gtheta[95] =theta[2]
		gtheta[96] =theta[3]
		gtheta[97] =theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[98] =theta[5]
		gtheta[99] =theta[6]
		gtheta[100] =theta[7]
		gtheta[101] =phi*theta[1] + theta[8]*(1 + phi)
		gtheta[102] =theta[9]
		gtheta[103] =theta[10]
		gtheta[104] =phi*theta[2] + theta[11]*(1 + phi)
		gtheta[105] =theta[12]
		gtheta[106] =phi*theta[3] + theta[13]*(1 + phi)
		gtheta[107] =theta[14]
		gtheta[108] =phi*theta[5] + theta[15]*(1 + phi)
		gtheta[109] =theta[16]
		gtheta[110] =phi*theta[6] + theta[17]*(1 + phi)
		gtheta[111] =theta[18]
		gtheta[112] =phi*theta[7] + theta[19]*(1 + phi)
		gtheta[113] =theta[20]
		gtheta[114] =phi*theta[9] + theta[21]*(1 + phi)
		gtheta[115] =phi*theta[10] + theta[22]*(1 + phi)
		gtheta[116] =theta[23]
		gtheta[117] =phi*theta[12] + theta[24]*(1 + phi)
		gtheta[118] =phi*theta[14] + theta[25]*(1 + phi)
		gtheta[119] =phi*theta[16] + theta[26]*(1 + phi)
		gtheta[120] =theta[27]
		gtheta[121] =phi*theta[18] + theta[28]*(1 + phi)
		gtheta[122] =phi*theta[20] + theta[29]*(1 + phi)
		gtheta[123] =phi*theta[23] + theta[30]*(1 + phi)
		gtheta[124] =phi*theta[27] + theta[31]*(1 + phi)
		gtheta[125] =theta[1]
		gtheta[126] =theta[2]
		gtheta[127] =theta[3]
		gtheta[128] =theta[4]
		gtheta[129] =theta[5]*(1 + phi) + beta + phi*lambda0
		gtheta[130] =theta[6]
		gtheta[131] =theta[7]
		gtheta[132] =theta[8]
		gtheta[133] =phi*theta[1] + theta[9]*(1 + phi)
		gtheta[134] =theta[10]
		gtheta[135] =theta[11]
		gtheta[136] =phi*theta[2] + theta[12]*(1 + phi)
		gtheta[137] =theta[13]
		gtheta[138] =phi*theta[3] + theta[14]*(1 + phi)
		gtheta[139] =phi*theta[4] + theta[15]*(1 + phi)
		gtheta[140] =theta[16]
		gtheta[141] =theta[17]
		gtheta[142] =phi*theta[6] + theta[18]*(1 + phi)
		gtheta[143] =theta[19]
		gtheta[144] =phi*theta[7] + theta[20]*(1 + phi)
		gtheta[145] =phi*theta[8] + theta[21]*(1 + phi)
		gtheta[146] =theta[22]
		gtheta[147] =phi*theta[10] + theta[23]*(1 + phi)
		gtheta[148] =phi*theta[11] + theta[24]*(1 + phi)
		gtheta[149] =phi*theta[13] + theta[25]*(1 + phi)
		gtheta[150] =theta[26]
		gtheta[151] =phi*theta[16] + theta[27]*(1 + phi)
		gtheta[152] =phi*theta[17] + theta[28]*(1 + phi)
		gtheta[153] =phi*theta[19] + theta[29]*(1 + phi)
		gtheta[154] =phi*theta[22] + theta[30]*(1 + phi)
		gtheta[155] =phi*theta[26] + theta[31]*(1 + phi)
		
	}


	
// ------------------------- CRC ENDOGENOUS ------------------------------------

		void myeval5endo(todo, theta , param , V,  omd , S , H) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,955,1)
		lambda0= -theta[1..191]*hmean'

		rho=theta[192]
		beta=theta[193]
		phi=theta[194]
		
		
		gtheta[1] =theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2] =theta[2]
		gtheta[3] =theta[3]
		gtheta[4] =theta[4]
		gtheta[5] =theta[5]
		gtheta[6] =phi*theta[2] + theta[6]*(1 + phi)
		gtheta[7] =phi*theta[3] + theta[7]*(1 + phi)
		gtheta[8] =phi*theta[4] + theta[8]*(1 + phi)
		gtheta[9] =phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10] =theta[10]
		gtheta[11] =theta[11]
		gtheta[12] =theta[12]
		gtheta[13] =theta[13]
		gtheta[14] =theta[14]
		gtheta[15] =theta[15]
		gtheta[16] =phi*theta[10] + theta[16]*(1 + phi)
		gtheta[17] =phi*theta[11] + theta[17]*(1 + phi)
		gtheta[18] =phi*theta[12] + theta[18]*(1 + phi)
		gtheta[19] =phi*theta[13] + theta[19]*(1 + phi)
		gtheta[20] =phi*theta[14] + theta[20]*(1 + phi)
		gtheta[21] =phi*theta[15] + theta[21]*(1 + phi)
		gtheta[22] =theta[22]
		gtheta[23] =theta[23]
		gtheta[24] =theta[24]
		gtheta[25] =theta[25]
		gtheta[26] =phi*theta[22] + theta[26]*(1 + phi)
		gtheta[27] =phi*theta[23] + theta[27]*(1 + phi)
		gtheta[28] =phi*theta[24] + theta[28]*(1 + phi)
		gtheta[29] =phi*theta[25] + theta[29]*(1 + phi)
		gtheta[30] =theta[30]
		gtheta[31] =phi*theta[30] + theta[31]*(1 + phi)
		gtheta[32] =rho + theta[32]
		gtheta[33] =theta[33]
		gtheta[34] =theta[34]
		gtheta[35] =theta[35]
		gtheta[36] =theta[36]
		gtheta[37] =phi*theta[32] + theta[37]*(1 + phi)
		gtheta[38] =theta[38]
		gtheta[39] =theta[39]
		gtheta[40] =theta[40]
		gtheta[41] =theta[41]
		gtheta[42] =phi*theta[38] + theta[42]*(1 + phi)
		gtheta[43] =phi*theta[39] + theta[43]*(1 + phi)
		gtheta[44] =phi*theta[40] + theta[44]*(1 + phi)
		gtheta[45] =phi*theta[41] + theta[45]*(1 + phi)
		gtheta[46] =theta[46]
		gtheta[47] =theta[47]
		gtheta[48] =theta[48]
		gtheta[49] =theta[49]
		gtheta[50] =theta[50]
		gtheta[51] =theta[51]
		gtheta[52] =phi*theta[46] + theta[52]*(1 + phi)
		gtheta[53] =phi*theta[47] + theta[53]*(1 + phi)
		gtheta[54] =phi*theta[48] + theta[54]*(1 + phi)
		gtheta[55] =phi*theta[49] + theta[55]*(1 + phi)
		gtheta[56] =phi*theta[50] + theta[56]*(1 + phi)
		gtheta[57] =phi*theta[51] + theta[57]*(1 + phi)
		gtheta[58] =theta[58]
		gtheta[59] =theta[59]
		gtheta[60] =theta[60]
		gtheta[61] =theta[61]
		gtheta[62] =phi*theta[58] + theta[62]*(1 + phi)
		gtheta[63] =phi*theta[59] + theta[63]*(1 + phi)
		gtheta[64] =phi*theta[60] + theta[64]*(1 + phi)
		gtheta[65] =phi*theta[61] + theta[65]*(1 + phi)
		gtheta[66] =theta[66]
		gtheta[67] =phi*theta[66] + theta[67]*(1 + phi)
		gtheta[68] =phi*theta[33] + theta[68]*(1 + phi)
		gtheta[69] =theta[69]
		gtheta[70] =theta[70]
		gtheta[71] =theta[71]
		gtheta[72] =theta[72]
		gtheta[73] =phi*theta[69] + theta[73]*(1 + phi)
		gtheta[74] =phi*theta[70] + theta[74]*(1 + phi)
		gtheta[75] =phi*theta[71] + theta[75]*(1 + phi)
		gtheta[76] =phi*theta[72] + theta[76]*(1 + phi)
		gtheta[77] =theta[77]
		gtheta[78] =theta[78]
		gtheta[79] =theta[79]
		gtheta[80] =theta[80]
		gtheta[81] =theta[81]
		gtheta[82] =theta[82]
		gtheta[83] =phi*theta[77] + theta[83]*(1 + phi)
		gtheta[84] =phi*theta[78] + theta[84]*(1 + phi)
		gtheta[85] =phi*theta[79] + theta[85]*(1 + phi)
		gtheta[86] =phi*theta[80] + theta[86]*(1 + phi)
		gtheta[87] =phi*theta[81] + theta[87]*(1 + phi)
		gtheta[88] =phi*theta[82] + theta[88]*(1 + phi)
		gtheta[89] =theta[89]
		gtheta[90] =theta[90]
		gtheta[91] =theta[91]
		gtheta[92] =theta[92]
		gtheta[93] =phi*theta[89] + theta[93]*(1 + phi)
		gtheta[94] =phi*theta[90] + theta[94]*(1 + phi)
		gtheta[95] =phi*theta[91] + theta[95]*(1 + phi)
		gtheta[96] =phi*theta[92] + theta[96]*(1 + phi)
		gtheta[97] =theta[97]
		gtheta[98] =phi*theta[97] + theta[98]*(1 + phi)
		gtheta[99] =phi*theta[34] + theta[99]*(1 + phi)
		gtheta[100] =theta[100]
		gtheta[101] =theta[101]
		gtheta[102] =theta[102]
		gtheta[103] =theta[103]
		gtheta[104] =phi*theta[100] + theta[104]*(1 + phi)
		gtheta[105] =phi*theta[101] + theta[105]*(1 + phi)
		gtheta[106] =phi*theta[102] + theta[106]*(1 + phi)
		gtheta[107] =phi*theta[103] + theta[107]*(1 + phi)
		gtheta[108] =theta[108]
		gtheta[109] =theta[109]
		gtheta[110] =theta[110]
		gtheta[111] =theta[111]
		gtheta[112] =theta[112]
		gtheta[113] =theta[113]
		gtheta[114] =phi*theta[108] + theta[114]*(1 + phi)
		gtheta[115] =phi*theta[109] + theta[115]*(1 + phi)
		gtheta[116] =phi*theta[110] + theta[116]*(1 + phi)
		gtheta[117] =phi*theta[111] + theta[117]*(1 + phi)
		gtheta[118] =phi*theta[112] + theta[118]*(1 + phi)
		gtheta[119] =phi*theta[113] + theta[119]*(1 + phi)
		gtheta[120] =theta[120]
		gtheta[121] =theta[121]
		gtheta[122] =theta[122]
		gtheta[123] =theta[123]
		gtheta[124] =phi*theta[120] + theta[124]*(1 + phi)
		gtheta[125] =phi*theta[121] + theta[125]*(1 + phi)
		gtheta[126] =phi*theta[122] + theta[126]*(1 + phi)
		gtheta[127] =phi*theta[123] + theta[127]*(1 + phi)
		gtheta[128] =theta[128]
		gtheta[129] =phi*theta[128] + theta[129]*(1 + phi)
		gtheta[130] =phi*theta[35] + theta[130]*(1 + phi)
		gtheta[131] =theta[131]
		gtheta[132] =theta[132]
		gtheta[133] =theta[133]
		gtheta[134] =theta[134]
		gtheta[135] =phi*theta[131] + theta[135]*(1 + phi)
		gtheta[136] =phi*theta[132] + theta[136]*(1 + phi)
		gtheta[137] =phi*theta[133] + theta[137]*(1 + phi)
		gtheta[138] =phi*theta[134] + theta[138]*(1 + phi)
		gtheta[139] =theta[139]
		gtheta[140] =theta[140]
		gtheta[141] =theta[141]
		gtheta[142] =theta[142]
		gtheta[143] =theta[143]
		gtheta[144] =theta[144]
		gtheta[145] =phi*theta[139] + theta[145]*(1 + phi)
		gtheta[146] =phi*theta[140] + theta[146]*(1 + phi)
		gtheta[147] =phi*theta[141] + theta[147]*(1 + phi)
		gtheta[148] =phi*theta[142] + theta[148]*(1 + phi)
		gtheta[149] =phi*theta[143] + theta[149]*(1 + phi)
		gtheta[150] =phi*theta[144] + theta[150]*(1 + phi)
		gtheta[151] =theta[151]
		gtheta[152] =theta[152]
		gtheta[153] =theta[153]
		gtheta[154] =theta[154]
		gtheta[155] =phi*theta[151] + theta[155]*(1 + phi)
		gtheta[156] =phi*theta[152] + theta[156]*(1 + phi)
		gtheta[157] =phi*theta[153] + theta[157]*(1 + phi)
		gtheta[158] =phi*theta[154] + theta[158]*(1 + phi)
		gtheta[159] =theta[159]
		gtheta[160] =phi*theta[159] + theta[160]*(1 + phi)
		gtheta[161] =phi*theta[36] + theta[161]*(1 + phi)
		gtheta[162] =theta[162]
		gtheta[163] =theta[163]
		gtheta[164] =theta[164]
		gtheta[165] =theta[165]
		gtheta[166] =phi*theta[162] + theta[166]*(1 + phi)
		gtheta[167] =phi*theta[163] + theta[167]*(1 + phi)
		gtheta[168] =phi*theta[164] + theta[168]*(1 + phi)
		gtheta[169] =phi*theta[165] + theta[169]*(1 + phi)
		gtheta[170] =theta[170]
		gtheta[171] =theta[171]
		gtheta[172] =theta[172]
		gtheta[173] =theta[173]
		gtheta[174] =theta[174]
		gtheta[175] =theta[175]
		gtheta[176] =phi*theta[170] + theta[176]*(1 + phi)
		gtheta[177] =phi*theta[171] + theta[177]*(1 + phi)
		gtheta[178] =phi*theta[172] + theta[178]*(1 + phi)
		gtheta[179] =phi*theta[173] + theta[179]*(1 + phi)
		gtheta[180] =phi*theta[174] + theta[180]*(1 + phi)
		gtheta[181] =phi*theta[175] + theta[181]*(1 + phi)
		gtheta[182] =theta[182]
		gtheta[183] =theta[183]
		gtheta[184] =theta[184]
		gtheta[185] =theta[185]
		gtheta[186] =phi*theta[182] + theta[186]*(1 + phi)
		gtheta[187] =phi*theta[183] + theta[187]*(1 + phi)
		gtheta[188] =phi*theta[184] + theta[188]*(1 + phi)
		gtheta[189] =phi*theta[185] + theta[189]*(1 + phi)
		gtheta[190] =theta[190]
		gtheta[191] =phi*theta[190] + theta[191]*(1 + phi)
		gtheta[192] =theta[1]
		gtheta[193] =theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[194] =theta[3]
		gtheta[195] =theta[4]
		gtheta[196] =theta[5]
		gtheta[197] =phi*theta[1] + theta[6]*(1 + phi)
		gtheta[198] =theta[7]
		gtheta[199] =theta[8]
		gtheta[200] =theta[9]
		gtheta[201] =phi*theta[3] + theta[10]*(1 + phi)
		gtheta[202] =phi*theta[4] + theta[11]*(1 + phi)
		gtheta[203] =phi*theta[5] + theta[12]*(1 + phi)
		gtheta[204] =theta[13]
		gtheta[205] =theta[14]
		gtheta[206] =theta[15]
		gtheta[207] =phi*theta[7] + theta[16]*(1 + phi)
		gtheta[208] =phi*theta[8] + theta[17]*(1 + phi)
		gtheta[209] =phi*theta[9] + theta[18]*(1 + phi)
		gtheta[210] =theta[19]
		gtheta[211] =theta[20]
		gtheta[212] =theta[21]
		gtheta[213] =phi*theta[13] + theta[22]*(1 + phi)
		gtheta[214] =phi*theta[14] + theta[23]*(1 + phi)
		gtheta[215] =phi*theta[15] + theta[24]*(1 + phi)
		gtheta[216] =theta[25]
		gtheta[217] =phi*theta[19] + theta[26]*(1 + phi)
		gtheta[218] =phi*theta[20] + theta[27]*(1 + phi)
		gtheta[219] =phi*theta[21] + theta[28]*(1 + phi)
		gtheta[220] =theta[29]
		gtheta[221] =phi*theta[25] + theta[30]*(1 + phi)
		gtheta[222] =phi*theta[29] + theta[31]*(1 + phi)
		gtheta[223] =theta[32]
		gtheta[224] =rho + theta[33]
		gtheta[225] =theta[34]
		gtheta[226] =theta[35]
		gtheta[227] =theta[36]
		gtheta[228] =theta[37]
		gtheta[229] =phi*theta[32] + theta[38]*(1 + phi)
		gtheta[230] =theta[39]
		gtheta[231] =theta[40]
		gtheta[232] =theta[41]
		gtheta[233] =phi*theta[37] + theta[42]*(1 + phi)
		gtheta[234] =theta[43]
		gtheta[235] =theta[44]
		gtheta[236] =theta[45]
		gtheta[237] =phi*theta[39] + theta[46]*(1 + phi)
		gtheta[238] =phi*theta[40] + theta[47]*(1 + phi)
		gtheta[239] =phi*theta[41] + theta[48]*(1 + phi)
		gtheta[240] =theta[49]
		gtheta[241] =theta[50]
		gtheta[242] =theta[51]
		gtheta[243] =phi*theta[43] + theta[52]*(1 + phi)
		gtheta[244] =phi*theta[44] + theta[53]*(1 + phi)
		gtheta[245] =phi*theta[45] + theta[54]*(1 + phi)
		gtheta[246] =theta[55]
		gtheta[247] =theta[56]
		gtheta[248] =theta[57]
		gtheta[249] =phi*theta[49] + theta[58]*(1 + phi)
		gtheta[250] =phi*theta[50] + theta[59]*(1 + phi)
		gtheta[251] =phi*theta[51] + theta[60]*(1 + phi)
		gtheta[252] =theta[61]
		gtheta[253] =phi*theta[55] + theta[62]*(1 + phi)
		gtheta[254] =phi*theta[56] + theta[63]*(1 + phi)
		gtheta[255] =phi*theta[57] + theta[64]*(1 + phi)
		gtheta[256] =theta[65]
		gtheta[257] =phi*theta[61] + theta[66]*(1 + phi)
		gtheta[258] =phi*theta[65] + theta[67]*(1 + phi)
		gtheta[259] =theta[68]
		gtheta[260] =phi*theta[33] + theta[69]*(1 + phi)
		gtheta[261] =theta[70]
		gtheta[262] =theta[71]
		gtheta[263] =theta[72]
		gtheta[264] =phi*theta[68] + theta[73]*(1 + phi)
		gtheta[265] =theta[74]
		gtheta[266] =theta[75]
		gtheta[267] =theta[76]
		gtheta[268] =phi*theta[70] + theta[77]*(1 + phi)
		gtheta[269] =phi*theta[71] + theta[78]*(1 + phi)
		gtheta[270] =phi*theta[72] + theta[79]*(1 + phi)
		gtheta[271] =theta[80]
		gtheta[272] =theta[81]
		gtheta[273] =theta[82]
		gtheta[274] =phi*theta[74] + theta[83]*(1 + phi)
		gtheta[275] =phi*theta[75] + theta[84]*(1 + phi)
		gtheta[276] =phi*theta[76] + theta[85]*(1 + phi)
		gtheta[277] =theta[86]
		gtheta[278] =theta[87]
		gtheta[279] =theta[88]
		gtheta[280] =phi*theta[80] + theta[89]*(1 + phi)
		gtheta[281] =phi*theta[81] + theta[90]*(1 + phi)
		gtheta[282] =phi*theta[82] + theta[91]*(1 + phi)
		gtheta[283] =theta[92]
		gtheta[284] =phi*theta[86] + theta[93]*(1 + phi)
		gtheta[285] =phi*theta[87] + theta[94]*(1 + phi)
		gtheta[286] =phi*theta[88] + theta[95]*(1 + phi)
		gtheta[287] =theta[96]
		gtheta[288] =phi*theta[92] + theta[97]*(1 + phi)
		gtheta[289] =phi*theta[96] + theta[98]*(1 + phi)
		gtheta[290] =theta[99]
		gtheta[291] =phi*theta[34] + theta[100]*(1 + phi)
		gtheta[292] =theta[101]
		gtheta[293] =theta[102]
		gtheta[294] =theta[103]
		gtheta[295] =phi*theta[99] + theta[104]*(1 + phi)
		gtheta[296] =theta[105]
		gtheta[297] =theta[106]
		gtheta[298] =theta[107]
		gtheta[299] =phi*theta[101] + theta[108]*(1 + phi)
		gtheta[300] =phi*theta[102] + theta[109]*(1 + phi)
		gtheta[301] =phi*theta[103] + theta[110]*(1 + phi)
		gtheta[302] =theta[111]
		gtheta[303] =theta[112]
		gtheta[304] =theta[113]
		gtheta[305] =phi*theta[105] + theta[114]*(1 + phi)
		gtheta[306] =phi*theta[106] + theta[115]*(1 + phi)
		gtheta[307] =phi*theta[107] + theta[116]*(1 + phi)
		gtheta[308] =theta[117]
		gtheta[309] =theta[118]
		gtheta[310] =theta[119]
		gtheta[311] =phi*theta[111] + theta[120]*(1 + phi)
		gtheta[312] =phi*theta[112] + theta[121]*(1 + phi)
		gtheta[313] =phi*theta[113] + theta[122]*(1 + phi)
		gtheta[314] =theta[123]
		gtheta[315] =phi*theta[117] + theta[124]*(1 + phi)
		gtheta[316] =phi*theta[118] + theta[125]*(1 + phi)
		gtheta[317] =phi*theta[119] + theta[126]*(1 + phi)
		gtheta[318] =theta[127]
		gtheta[319] =phi*theta[123] + theta[128]*(1 + phi)
		gtheta[320] =phi*theta[127] + theta[129]*(1 + phi)
		gtheta[321] =theta[130]
		gtheta[322] =phi*theta[35] + theta[131]*(1 + phi)
		gtheta[323] =theta[132]
		gtheta[324] =theta[133]
		gtheta[325] =theta[134]
		gtheta[326] =phi*theta[130] + theta[135]*(1 + phi)
		gtheta[327] =theta[136]
		gtheta[328] =theta[137]
		gtheta[329] =theta[138]
		gtheta[330] =phi*theta[132] + theta[139]*(1 + phi)
		gtheta[331] =phi*theta[133] + theta[140]*(1 + phi)
		gtheta[332] =phi*theta[134] + theta[141]*(1 + phi)
		gtheta[333] =theta[142]
		gtheta[334] =theta[143]
		gtheta[335] =theta[144]
		gtheta[336] =phi*theta[136] + theta[145]*(1 + phi)
		gtheta[337] =phi*theta[137] + theta[146]*(1 + phi)
		gtheta[338] =phi*theta[138] + theta[147]*(1 + phi)
		gtheta[339] =theta[148]
		gtheta[340] =theta[149]
		gtheta[341] =theta[150]
		gtheta[342] =phi*theta[142] + theta[151]*(1 + phi)
		gtheta[343] =phi*theta[143] + theta[152]*(1 + phi)
		gtheta[344] =phi*theta[144] + theta[153]*(1 + phi)
		gtheta[345] =theta[154]
		gtheta[346] =phi*theta[148] + theta[155]*(1 + phi)
		gtheta[347] =phi*theta[149] + theta[156]*(1 + phi)
		gtheta[348] =phi*theta[150] + theta[157]*(1 + phi)
		gtheta[349] =theta[158]
		gtheta[350] =phi*theta[154] + theta[159]*(1 + phi)
		gtheta[351] =phi*theta[158] + theta[160]*(1 + phi)
		gtheta[352] =theta[161]
		gtheta[353] =phi*theta[36] + theta[162]*(1 + phi)
		gtheta[354] =theta[163]
		gtheta[355] =theta[164]
		gtheta[356] =theta[165]
		gtheta[357] =phi*theta[161] + theta[166]*(1 + phi)
		gtheta[358] =theta[167]
		gtheta[359] =theta[168]
		gtheta[360] =theta[169]
		gtheta[361] =phi*theta[163] + theta[170]*(1 + phi)
		gtheta[362] =phi*theta[164] + theta[171]*(1 + phi)
		gtheta[363] =phi*theta[165] + theta[172]*(1 + phi)
		gtheta[364] =theta[173]
		gtheta[365] =theta[174]
		gtheta[366] =theta[175]
		gtheta[367] =phi*theta[167] + theta[176]*(1 + phi)
		gtheta[368] =phi*theta[168] + theta[177]*(1 + phi)
		gtheta[369] =phi*theta[169] + theta[178]*(1 + phi)
		gtheta[370] =theta[179]
		gtheta[371] =theta[180]
		gtheta[372] =theta[181]
		gtheta[373] =phi*theta[173] + theta[182]*(1 + phi)
		gtheta[374] =phi*theta[174] + theta[183]*(1 + phi)
		gtheta[375] =phi*theta[175] + theta[184]*(1 + phi)
		gtheta[376] =theta[185]
		gtheta[377] =phi*theta[179] + theta[186]*(1 + phi)
		gtheta[378] =phi*theta[180] + theta[187]*(1 + phi)
		gtheta[379] =phi*theta[181] + theta[188]*(1 + phi)
		gtheta[380] =theta[189]
		gtheta[381] =phi*theta[185] + theta[190]*(1 + phi)
		gtheta[382] =phi*theta[189] + theta[191]*(1 + phi)
		gtheta[383] =theta[1]
		gtheta[384] =theta[2]
		gtheta[385] =theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[386] =theta[4]
		gtheta[387] =theta[5]
		gtheta[388] =theta[6]
		gtheta[389] =phi*theta[1] + theta[7]*(1 + phi)
		gtheta[390] =theta[8]
		gtheta[391] =theta[9]
		gtheta[392] =phi*theta[2] + theta[10]*(1 + phi)
		gtheta[393] =theta[11]
		gtheta[394] =theta[12]
		gtheta[395] =phi*theta[4] + theta[13]*(1 + phi)
		gtheta[396] =phi*theta[5] + theta[14]*(1 + phi)
		gtheta[397] =theta[15]
		gtheta[398] =phi*theta[6] + theta[16]*(1 + phi)
		gtheta[399] =theta[17]
		gtheta[400] =theta[18]
		gtheta[401] =phi*theta[8] + theta[19]*(1 + phi)
		gtheta[402] =phi*theta[9] + theta[20]*(1 + phi)
		gtheta[403] =theta[21]
		gtheta[404] =phi*theta[11] + theta[22]*(1 + phi)
		gtheta[405] =phi*theta[12] + theta[23]*(1 + phi)
		gtheta[406] =theta[24]
		gtheta[407] =phi*theta[15] + theta[25]*(1 + phi)
		gtheta[408] =phi*theta[17] + theta[26]*(1 + phi)
		gtheta[409] =phi*theta[18] + theta[27]*(1 + phi)
		gtheta[410] =theta[28]
		gtheta[411] =phi*theta[21] + theta[29]*(1 + phi)
		gtheta[412] =phi*theta[24] + theta[30]*(1 + phi)
		gtheta[413] =phi*theta[28] + theta[31]*(1 + phi)
		gtheta[414] =theta[32]
		gtheta[415] =theta[33]
		gtheta[416] =rho + theta[34]
		gtheta[417] =theta[35]
		gtheta[418] =theta[36]
		gtheta[419] =theta[37]
		gtheta[420] =theta[38]
		gtheta[421] =phi*theta[32] + theta[39]*(1 + phi)
		gtheta[422] =theta[40]
		gtheta[423] =theta[41]
		gtheta[424] =theta[42]
		gtheta[425] =phi*theta[37] + theta[43]*(1 + phi)
		gtheta[426] =theta[44]
		gtheta[427] =theta[45]
		gtheta[428] =phi*theta[38] + theta[46]*(1 + phi)
		gtheta[429] =theta[47]
		gtheta[430] =theta[48]
		gtheta[431] =phi*theta[40] + theta[49]*(1 + phi)
		gtheta[432] =phi*theta[41] + theta[50]*(1 + phi)
		gtheta[433] =theta[51]
		gtheta[434] =phi*theta[42] + theta[52]*(1 + phi)
		gtheta[435] =theta[53]
		gtheta[436] =theta[54]
		gtheta[437] =phi*theta[44] + theta[55]*(1 + phi)
		gtheta[438] =phi*theta[45] + theta[56]*(1 + phi)
		gtheta[439] =theta[57]
		gtheta[440] =phi*theta[47] + theta[58]*(1 + phi)
		gtheta[441] =phi*theta[48] + theta[59]*(1 + phi)
		gtheta[442] =theta[60]
		gtheta[443] =phi*theta[51] + theta[61]*(1 + phi)
		gtheta[444] =phi*theta[53] + theta[62]*(1 + phi)
		gtheta[445] =phi*theta[54] + theta[63]*(1 + phi)
		gtheta[446] =theta[64]
		gtheta[447] =phi*theta[57] + theta[65]*(1 + phi)
		gtheta[448] =phi*theta[60] + theta[66]*(1 + phi)
		gtheta[449] =phi*theta[64] + theta[67]*(1 + phi)
		gtheta[450] =theta[68]
		gtheta[451] =theta[69]
		gtheta[452] =phi*theta[33] + theta[70]*(1 + phi)
		gtheta[453] =theta[71]
		gtheta[454] =theta[72]
		gtheta[455] =theta[73]
		gtheta[456] =phi*theta[68] + theta[74]*(1 + phi)
		gtheta[457] =theta[75]
		gtheta[458] =theta[76]
		gtheta[459] =phi*theta[69] + theta[77]*(1 + phi)
		gtheta[460] =theta[78]
		gtheta[461] =theta[79]
		gtheta[462] =phi*theta[71] + theta[80]*(1 + phi)
		gtheta[463] =phi*theta[72] + theta[81]*(1 + phi)
		gtheta[464] =theta[82]
		gtheta[465] =phi*theta[73] + theta[83]*(1 + phi)
		gtheta[466] =theta[84]
		gtheta[467] =theta[85]
		gtheta[468] =phi*theta[75] + theta[86]*(1 + phi)
		gtheta[469] =phi*theta[76] + theta[87]*(1 + phi)
		gtheta[470] =theta[88]
		gtheta[471] =phi*theta[78] + theta[89]*(1 + phi)
		gtheta[472] =phi*theta[79] + theta[90]*(1 + phi)
		gtheta[473] =theta[91]
		gtheta[474] =phi*theta[82] + theta[92]*(1 + phi)
		gtheta[475] =phi*theta[84] + theta[93]*(1 + phi)
		gtheta[476] =phi*theta[85] + theta[94]*(1 + phi)
		gtheta[477] =theta[95]
		gtheta[478] =phi*theta[88] + theta[96]*(1 + phi)
		gtheta[479] =phi*theta[91] + theta[97]*(1 + phi)
		gtheta[480] =phi*theta[95] + theta[98]*(1 + phi)
		gtheta[481] =theta[99]
		gtheta[482] =theta[100]
		gtheta[483] =phi*theta[34] + theta[101]*(1 + phi)
		gtheta[484] =theta[102]
		gtheta[485] =theta[103]
		gtheta[486] =theta[104]
		gtheta[487] =phi*theta[99] + theta[105]*(1 + phi)
		gtheta[488] =theta[106]
		gtheta[489] =theta[107]
		gtheta[490] =phi*theta[100] + theta[108]*(1 + phi)
		gtheta[491] =theta[109]
		gtheta[492] =theta[110]
		gtheta[493] =phi*theta[102] + theta[111]*(1 + phi)
		gtheta[494] =phi*theta[103] + theta[112]*(1 + phi)
		gtheta[495] =theta[113]
		gtheta[496] =phi*theta[104] + theta[114]*(1 + phi)
		gtheta[497] =theta[115]
		gtheta[498] =theta[116]
		gtheta[499] =phi*theta[106] + theta[117]*(1 + phi)
		gtheta[500] =phi*theta[107] + theta[118]*(1 + phi)
		gtheta[501] =theta[119]
		gtheta[502] =phi*theta[109] + theta[120]*(1 + phi)
		gtheta[503] =phi*theta[110] + theta[121]*(1 + phi)
		gtheta[504] =theta[122]
		gtheta[505] =phi*theta[113] + theta[123]*(1 + phi)
		gtheta[506] =phi*theta[115] + theta[124]*(1 + phi)
		gtheta[507] =phi*theta[116] + theta[125]*(1 + phi)
		gtheta[508] =theta[126]
		gtheta[509] =phi*theta[119] + theta[127]*(1 + phi)
		gtheta[510] =phi*theta[122] + theta[128]*(1 + phi)
		gtheta[511] =phi*theta[126] + theta[129]*(1 + phi)
		gtheta[512] =theta[130]
		gtheta[513] =theta[131]
		gtheta[514] =phi*theta[35] + theta[132]*(1 + phi)
		gtheta[515] =theta[133]
		gtheta[516] =theta[134]
		gtheta[517] =theta[135]
		gtheta[518] =phi*theta[130] + theta[136]*(1 + phi)
		gtheta[519] =theta[137]
		gtheta[520] =theta[138]
		gtheta[521] =phi*theta[131] + theta[139]*(1 + phi)
		gtheta[522] =theta[140]
		gtheta[523] =theta[141]
		gtheta[524] =phi*theta[133] + theta[142]*(1 + phi)
		gtheta[525] =phi*theta[134] + theta[143]*(1 + phi)
		gtheta[526] =theta[144]
		gtheta[527] =phi*theta[135] + theta[145]*(1 + phi)
		gtheta[528] =theta[146]
		gtheta[529] =theta[147]
		gtheta[530] =phi*theta[137] + theta[148]*(1 + phi)
		gtheta[531] =phi*theta[138] + theta[149]*(1 + phi)
		gtheta[532] =theta[150]
		gtheta[533] =phi*theta[140] + theta[151]*(1 + phi)
		gtheta[534] =phi*theta[141] + theta[152]*(1 + phi)
		gtheta[535] =theta[153]
		gtheta[536] =phi*theta[144] + theta[154]*(1 + phi)
		gtheta[537] =phi*theta[146] + theta[155]*(1 + phi)
		gtheta[538] =phi*theta[147] + theta[156]*(1 + phi)
		gtheta[539] =theta[157]
		gtheta[540] =phi*theta[150] + theta[158]*(1 + phi)
		gtheta[541] =phi*theta[153] + theta[159]*(1 + phi)
		gtheta[542] =phi*theta[157] + theta[160]*(1 + phi)
		gtheta[543] =theta[161]
		gtheta[544] =theta[162]
		gtheta[545] =phi*theta[36] + theta[163]*(1 + phi)
		gtheta[546] =theta[164]
		gtheta[547] =theta[165]
		gtheta[548] =theta[166]
		gtheta[549] =phi*theta[161] + theta[167]*(1 + phi)
		gtheta[550] =theta[168]
		gtheta[551] =theta[169]
		gtheta[552] =phi*theta[162] + theta[170]*(1 + phi)
		gtheta[553] =theta[171]
		gtheta[554] =theta[172]
		gtheta[555] =phi*theta[164] + theta[173]*(1 + phi)
		gtheta[556] =phi*theta[165] + theta[174]*(1 + phi)
		gtheta[557] =theta[175]
		gtheta[558] =phi*theta[166] + theta[176]*(1 + phi)
		gtheta[559] =theta[177]
		gtheta[560] =theta[178]
		gtheta[561] =phi*theta[168] + theta[179]*(1 + phi)
		gtheta[562] =phi*theta[169] + theta[180]*(1 + phi)
		gtheta[563] =theta[181]
		gtheta[564] =phi*theta[171] + theta[182]*(1 + phi)
		gtheta[565] =phi*theta[172] + theta[183]*(1 + phi)
		gtheta[566] =theta[184]
		gtheta[567] =phi*theta[175] + theta[185]*(1 + phi)
		gtheta[568] =phi*theta[177] + theta[186]*(1 + phi)
		gtheta[569] =phi*theta[178] + theta[187]*(1 + phi)
		gtheta[570] =theta[188]
		gtheta[571] =phi*theta[181] + theta[189]*(1 + phi)
		gtheta[572] =phi*theta[184] + theta[190]*(1 + phi)
		gtheta[573] =phi*theta[188] + theta[191]*(1 + phi)
		gtheta[574] =theta[1]
		gtheta[575] =theta[2]
		gtheta[576] =theta[3]
		gtheta[577] =theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[578] =theta[5]
		gtheta[579] =theta[6]
		gtheta[580] =theta[7]
		gtheta[581] =phi*theta[1] + theta[8]*(1 + phi)
		gtheta[582] =theta[9]
		gtheta[583] =theta[10]
		gtheta[584] =phi*theta[2] + theta[11]*(1 + phi)
		gtheta[585] =theta[12]
		gtheta[586] =phi*theta[3] + theta[13]*(1 + phi)
		gtheta[587] =theta[14]
		gtheta[588] =phi*theta[5] + theta[15]*(1 + phi)
		gtheta[589] =theta[16]
		gtheta[590] =phi*theta[6] + theta[17]*(1 + phi)
		gtheta[591] =theta[18]
		gtheta[592] =phi*theta[7] + theta[19]*(1 + phi)
		gtheta[593] =theta[20]
		gtheta[594] =phi*theta[9] + theta[21]*(1 + phi)
		gtheta[595] =phi*theta[10] + theta[22]*(1 + phi)
		gtheta[596] =theta[23]
		gtheta[597] =phi*theta[12] + theta[24]*(1 + phi)
		gtheta[598] =phi*theta[14] + theta[25]*(1 + phi)
		gtheta[599] =phi*theta[16] + theta[26]*(1 + phi)
		gtheta[600] =theta[27]
		gtheta[601] =phi*theta[18] + theta[28]*(1 + phi)
		gtheta[602] =phi*theta[20] + theta[29]*(1 + phi)
		gtheta[603] =phi*theta[23] + theta[30]*(1 + phi)
		gtheta[604] =phi*theta[27] + theta[31]*(1 + phi)
		gtheta[605] =theta[32]
		gtheta[606] =theta[33]
		gtheta[607] =theta[34]
		gtheta[608] =rho + theta[35]
		gtheta[609] =theta[36]
		gtheta[610] =theta[37]
		gtheta[611] =theta[38]
		gtheta[612] =theta[39]
		gtheta[613] =phi*theta[32] + theta[40]*(1 + phi)
		gtheta[614] =theta[41]
		gtheta[615] =theta[42]
		gtheta[616] =theta[43]
		gtheta[617] =phi*theta[37] + theta[44]*(1 + phi)
		gtheta[618] =theta[45]
		gtheta[619] =theta[46]
		gtheta[620] =phi*theta[38] + theta[47]*(1 + phi)
		gtheta[621] =theta[48]
		gtheta[622] =phi*theta[39] + theta[49]*(1 + phi)
		gtheta[623] =theta[50]
		gtheta[624] =phi*theta[41] + theta[51]*(1 + phi)
		gtheta[625] =theta[52]
		gtheta[626] =phi*theta[42] + theta[53]*(1 + phi)
		gtheta[627] =theta[54]
		gtheta[628] =phi*theta[43] + theta[55]*(1 + phi)
		gtheta[629] =theta[56]
		gtheta[630] =phi*theta[45] + theta[57]*(1 + phi)
		gtheta[631] =phi*theta[46] + theta[58]*(1 + phi)
		gtheta[632] =theta[59]
		gtheta[633] =phi*theta[48] + theta[60]*(1 + phi)
		gtheta[634] =phi*theta[50] + theta[61]*(1 + phi)
		gtheta[635] =phi*theta[52] + theta[62]*(1 + phi)
		gtheta[636] =theta[63]
		gtheta[637] =phi*theta[54] + theta[64]*(1 + phi)
		gtheta[638] =phi*theta[56] + theta[65]*(1 + phi)
		gtheta[639] =phi*theta[59] + theta[66]*(1 + phi)
		gtheta[640] =phi*theta[63] + theta[67]*(1 + phi)
		gtheta[641] =theta[68]
		gtheta[642] =theta[69]
		gtheta[643] =theta[70]
		gtheta[644] =phi*theta[33] + theta[71]*(1 + phi)
		gtheta[645] =theta[72]
		gtheta[646] =theta[73]
		gtheta[647] =theta[74]
		gtheta[648] =phi*theta[68] + theta[75]*(1 + phi)
		gtheta[649] =theta[76]
		gtheta[650] =theta[77]
		gtheta[651] =phi*theta[69] + theta[78]*(1 + phi)
		gtheta[652] =theta[79]
		gtheta[653] =phi*theta[70] + theta[80]*(1 + phi)
		gtheta[654] =theta[81]
		gtheta[655] =phi*theta[72] + theta[82]*(1 + phi)
		gtheta[656] =theta[83]
		gtheta[657] =phi*theta[73] + theta[84]*(1 + phi)
		gtheta[658] =theta[85]
		gtheta[659] =phi*theta[74] + theta[86]*(1 + phi)
		gtheta[660] =theta[87]
		gtheta[661] =phi*theta[76] + theta[88]*(1 + phi)
		gtheta[662] =phi*theta[77] + theta[89]*(1 + phi)
		gtheta[663] =theta[90]
		gtheta[664] =phi*theta[79] + theta[91]*(1 + phi)
		gtheta[665] =phi*theta[81] + theta[92]*(1 + phi)
		gtheta[666] =phi*theta[83] + theta[93]*(1 + phi)
		gtheta[667] =theta[94]
		gtheta[668] =phi*theta[85] + theta[95]*(1 + phi)
		gtheta[669] =phi*theta[87] + theta[96]*(1 + phi)
		gtheta[670] =phi*theta[90] + theta[97]*(1 + phi)
		gtheta[671] =phi*theta[94] + theta[98]*(1 + phi)
		gtheta[672] =theta[99]
		gtheta[673] =theta[100]
		gtheta[674] =theta[101]
		gtheta[675] =phi*theta[34] + theta[102]*(1 + phi)
		gtheta[676] =theta[103]
		gtheta[677] =theta[104]
		gtheta[678] =theta[105]
		gtheta[679] =phi*theta[99] + theta[106]*(1 + phi)
		gtheta[680] =theta[107]
		gtheta[681] =theta[108]
		gtheta[682] =phi*theta[100] + theta[109]*(1 + phi)
		gtheta[683] =theta[110]
		gtheta[684] =phi*theta[101] + theta[111]*(1 + phi)
		gtheta[685] =theta[112]
		gtheta[686] =phi*theta[103] + theta[113]*(1 + phi)
		gtheta[687] =theta[114]
		gtheta[688] =phi*theta[104] + theta[115]*(1 + phi)
		gtheta[689] =theta[116]
		gtheta[690] =phi*theta[105] + theta[117]*(1 + phi)
		gtheta[691] =theta[118]
		gtheta[692] =phi*theta[107] + theta[119]*(1 + phi)
		gtheta[693] =phi*theta[108] + theta[120]*(1 + phi)
		gtheta[694] =theta[121]
		gtheta[695] =phi*theta[110] + theta[122]*(1 + phi)
		gtheta[696] =phi*theta[112] + theta[123]*(1 + phi)
		gtheta[697] =phi*theta[114] + theta[124]*(1 + phi)
		gtheta[698] =theta[125]
		gtheta[699] =phi*theta[116] + theta[126]*(1 + phi)
		gtheta[700] =phi*theta[118] + theta[127]*(1 + phi)
		gtheta[701] =phi*theta[121] + theta[128]*(1 + phi)
		gtheta[702] =phi*theta[125] + theta[129]*(1 + phi)
		gtheta[703] =theta[130]
		gtheta[704] =theta[131]
		gtheta[705] =theta[132]
		gtheta[706] =phi*theta[35] + theta[133]*(1 + phi)
		gtheta[707] =theta[134]
		gtheta[708] =theta[135]
		gtheta[709] =theta[136]
		gtheta[710] =phi*theta[130] + theta[137]*(1 + phi)
		gtheta[711] =theta[138]
		gtheta[712] =theta[139]
		gtheta[713] =phi*theta[131] + theta[140]*(1 + phi)
		gtheta[714] =theta[141]
		gtheta[715] =phi*theta[132] + theta[142]*(1 + phi)
		gtheta[716] =theta[143]
		gtheta[717] =phi*theta[134] + theta[144]*(1 + phi)
		gtheta[718] =theta[145]
		gtheta[719] =phi*theta[135] + theta[146]*(1 + phi)
		gtheta[720] =theta[147]
		gtheta[721] =phi*theta[136] + theta[148]*(1 + phi)
		gtheta[722] =theta[149]
		gtheta[723] =phi*theta[138] + theta[150]*(1 + phi)
		gtheta[724] =phi*theta[139] + theta[151]*(1 + phi)
		gtheta[725] =theta[152]
		gtheta[726] =phi*theta[141] + theta[153]*(1 + phi)
		gtheta[727] =phi*theta[143] + theta[154]*(1 + phi)
		gtheta[728] =phi*theta[145] + theta[155]*(1 + phi)
		gtheta[729] =theta[156]
		gtheta[730] =phi*theta[147] + theta[157]*(1 + phi)
		gtheta[731] =phi*theta[149] + theta[158]*(1 + phi)
		gtheta[732] =phi*theta[152] + theta[159]*(1 + phi)
		gtheta[733] =phi*theta[156] + theta[160]*(1 + phi)
		gtheta[734] =theta[161]
		gtheta[735] =theta[162]
		gtheta[736] =theta[163]
		gtheta[737] =phi*theta[36] + theta[164]*(1 + phi)
		gtheta[738] =theta[165]
		gtheta[739] =theta[166]
		gtheta[740] =theta[167]
		gtheta[741] =phi*theta[161] + theta[168]*(1 + phi)
		gtheta[742] =theta[169]
		gtheta[743] =theta[170]
		gtheta[744] =phi*theta[162] + theta[171]*(1 + phi)
		gtheta[745] =theta[172]
		gtheta[746] =phi*theta[163] + theta[173]*(1 + phi)
		gtheta[747] =theta[174]
		gtheta[748] =phi*theta[165] + theta[175]*(1 + phi)
		gtheta[749] =theta[176]
		gtheta[750] =phi*theta[166] + theta[177]*(1 + phi)
		gtheta[751] =theta[178]
		gtheta[752] =phi*theta[167] + theta[179]*(1 + phi)
		gtheta[753] =theta[180]
		gtheta[754] =phi*theta[169] + theta[181]*(1 + phi)
		gtheta[755] =phi*theta[170] + theta[182]*(1 + phi)
		gtheta[756] =theta[183]
		gtheta[757] =phi*theta[172] + theta[184]*(1 + phi)
		gtheta[758] =phi*theta[174] + theta[185]*(1 + phi)
		gtheta[759] =phi*theta[176] + theta[186]*(1 + phi)
		gtheta[760] =theta[187]
		gtheta[761] =phi*theta[178] + theta[188]*(1 + phi)
		gtheta[762] =phi*theta[180] + theta[189]*(1 + phi)
		gtheta[763] =phi*theta[183] + theta[190]*(1 + phi)
		gtheta[764] =phi*theta[187] + theta[191]*(1 + phi)
		gtheta[765] =theta[1]
		gtheta[766] =theta[2]
		gtheta[767] =theta[3]
		gtheta[768] =theta[4]
		gtheta[769] =theta[5]*(1 + phi) + beta + phi*lambda0
		gtheta[770] =theta[6]
		gtheta[771] =theta[7]
		gtheta[772] =theta[8]
		gtheta[773] =phi*theta[1] + theta[9]*(1 + phi)
		gtheta[774] =theta[10]
		gtheta[775] =theta[11]
		gtheta[776] =phi*theta[2] + theta[12]*(1 + phi)
		gtheta[777] =theta[13]
		gtheta[778] =phi*theta[3] + theta[14]*(1 + phi)
		gtheta[779] =phi*theta[4] + theta[15]*(1 + phi)
		gtheta[780] =theta[16]
		gtheta[781] =theta[17]
		gtheta[782] =phi*theta[6] + theta[18]*(1 + phi)
		gtheta[783] =theta[19]
		gtheta[784] =phi*theta[7] + theta[20]*(1 + phi)
		gtheta[785] =phi*theta[8] + theta[21]*(1 + phi)
		gtheta[786] =theta[22]
		gtheta[787] =phi*theta[10] + theta[23]*(1 + phi)
		gtheta[788] =phi*theta[11] + theta[24]*(1 + phi)
		gtheta[789] =phi*theta[13] + theta[25]*(1 + phi)
		gtheta[790] =theta[26]
		gtheta[791] =phi*theta[16] + theta[27]*(1 + phi)
		gtheta[792] =phi*theta[17] + theta[28]*(1 + phi)
		gtheta[793] =phi*theta[19] + theta[29]*(1 + phi)
		gtheta[794] =phi*theta[22] + theta[30]*(1 + phi)
		gtheta[795] =phi*theta[26] + theta[31]*(1 + phi)
		gtheta[796] =theta[32]
		gtheta[797] =theta[33]
		gtheta[798] =theta[34]
		gtheta[799] =theta[35]
		gtheta[800] =rho + theta[36]
		gtheta[801] =theta[37]
		gtheta[802] =theta[38]
		gtheta[803] =theta[39]
		gtheta[804] =theta[40]
		gtheta[805] =phi*theta[32] + theta[41]*(1 + phi)
		gtheta[806] =theta[42]
		gtheta[807] =theta[43]
		gtheta[808] =theta[44]
		gtheta[809] =phi*theta[37] + theta[45]*(1 + phi)
		gtheta[810] =theta[46]
		gtheta[811] =theta[47]
		gtheta[812] =phi*theta[38] + theta[48]*(1 + phi)
		gtheta[813] =theta[49]
		gtheta[814] =phi*theta[39] + theta[50]*(1 + phi)
		gtheta[815] =phi*theta[40] + theta[51]*(1 + phi)
		gtheta[816] =theta[52]
		gtheta[817] =theta[53]
		gtheta[818] =phi*theta[42] + theta[54]*(1 + phi)
		gtheta[819] =theta[55]
		gtheta[820] =phi*theta[43] + theta[56]*(1 + phi)
		gtheta[821] =phi*theta[44] + theta[57]*(1 + phi)
		gtheta[822] =theta[58]
		gtheta[823] =phi*theta[46] + theta[59]*(1 + phi)
		gtheta[824] =phi*theta[47] + theta[60]*(1 + phi)
		gtheta[825] =phi*theta[49] + theta[61]*(1 + phi)
		gtheta[826] =theta[62]
		gtheta[827] =phi*theta[52] + theta[63]*(1 + phi)
		gtheta[828] =phi*theta[53] + theta[64]*(1 + phi)
		gtheta[829] =phi*theta[55] + theta[65]*(1 + phi)
		gtheta[830] =phi*theta[58] + theta[66]*(1 + phi)
		gtheta[831] =phi*theta[62] + theta[67]*(1 + phi)
		gtheta[832] =theta[68]
		gtheta[833] =theta[69]
		gtheta[834] =theta[70]
		gtheta[835] =theta[71]
		gtheta[836] =phi*theta[33] + theta[72]*(1 + phi)
		gtheta[837] =theta[73]
		gtheta[838] =theta[74]
		gtheta[839] =theta[75]
		gtheta[840] =phi*theta[68] + theta[76]*(1 + phi)
		gtheta[841] =theta[77]
		gtheta[842] =theta[78]
		gtheta[843] =phi*theta[69] + theta[79]*(1 + phi)
		gtheta[844] =theta[80]
		gtheta[845] =phi*theta[70] + theta[81]*(1 + phi)
		gtheta[846] =phi*theta[71] + theta[82]*(1 + phi)
		gtheta[847] =theta[83]
		gtheta[848] =theta[84]
		gtheta[849] =phi*theta[73] + theta[85]*(1 + phi)
		gtheta[850] =theta[86]
		gtheta[851] =phi*theta[74] + theta[87]*(1 + phi)
		gtheta[852] =phi*theta[75] + theta[88]*(1 + phi)
		gtheta[853] =theta[89]
		gtheta[854] =phi*theta[77] + theta[90]*(1 + phi)
		gtheta[855] =phi*theta[78] + theta[91]*(1 + phi)
		gtheta[856] =phi*theta[80] + theta[92]*(1 + phi)
		gtheta[857] =theta[93]
		gtheta[858] =phi*theta[83] + theta[94]*(1 + phi)
		gtheta[859] =phi*theta[84] + theta[95]*(1 + phi)
		gtheta[860] =phi*theta[86] + theta[96]*(1 + phi)
		gtheta[861] =phi*theta[89] + theta[97]*(1 + phi)
		gtheta[862] =phi*theta[93] + theta[98]*(1 + phi)
		gtheta[863] =theta[99]
		gtheta[864] =theta[100]
		gtheta[865] =theta[101]
		gtheta[866] =theta[102]
		gtheta[867] =phi*theta[34] + theta[103]*(1 + phi)
		gtheta[868] =theta[104]
		gtheta[869] =theta[105]
		gtheta[870] =theta[106]
		gtheta[871] =phi*theta[99] + theta[107]*(1 + phi)
		gtheta[872] =theta[108]
		gtheta[873] =theta[109]
		gtheta[874] =phi*theta[100] + theta[110]*(1 + phi)
		gtheta[875] =theta[111]
		gtheta[876] =phi*theta[101] + theta[112]*(1 + phi)
		gtheta[877] =phi*theta[102] + theta[113]*(1 + phi)
		gtheta[878] =theta[114]
		gtheta[879] =theta[115]
		gtheta[880] =phi*theta[104] + theta[116]*(1 + phi)
		gtheta[881] =theta[117]
		gtheta[882] =phi*theta[105] + theta[118]*(1 + phi)
		gtheta[883] =phi*theta[106] + theta[119]*(1 + phi)
		gtheta[884] =theta[120]
		gtheta[885] =phi*theta[108] + theta[121]*(1 + phi)
		gtheta[886] =phi*theta[109] + theta[122]*(1 + phi)
		gtheta[887] =phi*theta[111] + theta[123]*(1 + phi)
		gtheta[888] =theta[124]
		gtheta[889] =phi*theta[114] + theta[125]*(1 + phi)
		gtheta[890] =phi*theta[115] + theta[126]*(1 + phi)
		gtheta[891] =phi*theta[117] + theta[127]*(1 + phi)
		gtheta[892] =phi*theta[120] + theta[128]*(1 + phi)
		gtheta[893] =phi*theta[124] + theta[129]*(1 + phi)
		gtheta[894] =theta[130]
		gtheta[895] =theta[131]
		gtheta[896] =theta[132]
		gtheta[897] =theta[133]
		gtheta[898] =phi*theta[35] + theta[134]*(1 + phi)
		gtheta[899] =theta[135]
		gtheta[900] =theta[136]
		gtheta[901] =theta[137]
		gtheta[902] =phi*theta[130] + theta[138]*(1 + phi)
		gtheta[903] =theta[139]
		gtheta[904] =theta[140]
		gtheta[905] =phi*theta[131] + theta[141]*(1 + phi)
		gtheta[906] =theta[142]
		gtheta[907] =phi*theta[132] + theta[143]*(1 + phi)
		gtheta[908] =phi*theta[133] + theta[144]*(1 + phi)
		gtheta[909] =theta[145]
		gtheta[910] =theta[146]
		gtheta[911] =phi*theta[135] + theta[147]*(1 + phi)
		gtheta[912] =theta[148]
		gtheta[913] =phi*theta[136] + theta[149]*(1 + phi)
		gtheta[914] =phi*theta[137] + theta[150]*(1 + phi)
		gtheta[915] =theta[151]
		gtheta[916] =phi*theta[139] + theta[152]*(1 + phi)
		gtheta[917] =phi*theta[140] + theta[153]*(1 + phi)
		gtheta[918] =phi*theta[142] + theta[154]*(1 + phi)
		gtheta[919] =theta[155]
		gtheta[920] =phi*theta[145] + theta[156]*(1 + phi)
		gtheta[921] =phi*theta[146] + theta[157]*(1 + phi)
		gtheta[922] =phi*theta[148] + theta[158]*(1 + phi)
		gtheta[923] =phi*theta[151] + theta[159]*(1 + phi)
		gtheta[924] =phi*theta[155] + theta[160]*(1 + phi)
		gtheta[925] =theta[161]
		gtheta[926] =theta[162]
		gtheta[927] =theta[163]
		gtheta[928] =theta[164]
		gtheta[929] =phi*theta[36] + theta[165]*(1 + phi)
		gtheta[930] =theta[166]
		gtheta[931] =theta[167]
		gtheta[932] =theta[168]
		gtheta[933] =phi*theta[161] + theta[169]*(1 + phi)
		gtheta[934] =theta[170]
		gtheta[935] =theta[171]
		gtheta[936] =phi*theta[162] + theta[172]*(1 + phi)
		gtheta[937] =theta[173]
		gtheta[938] =phi*theta[163] + theta[174]*(1 + phi)
		gtheta[939] =phi*theta[164] + theta[175]*(1 + phi)
		gtheta[940] =theta[176]
		gtheta[941] =theta[177]
		gtheta[942] =phi*theta[166] + theta[178]*(1 + phi)
		gtheta[943] =theta[179]
		gtheta[944] =phi*theta[167] + theta[180]*(1 + phi)
		gtheta[945] =phi*theta[168] + theta[181]*(1 + phi)
		gtheta[946] =theta[182]
		gtheta[947] =phi*theta[170] + theta[183]*(1 + phi)
		gtheta[948] =phi*theta[171] + theta[184]*(1 + phi)
		gtheta[949] =phi*theta[173] + theta[185]*(1 + phi)
		gtheta[950] =theta[186]
		gtheta[951] =phi*theta[176] + theta[187]*(1 + phi)
		gtheta[952] =phi*theta[177] + theta[188]*(1 + phi)
		gtheta[953] =phi*theta[179] + theta[189]*(1 + phi)
		gtheta[954] =phi*theta[182] + theta[190]*(1 + phi)
		gtheta[955] =phi*theta[186] + theta[191]*(1 + phi)
		
		diff = param-gtheta'
		
		omd = (diff)'*V*(diff)		
		test = omd
	
	}
// Defines the function to take derivatives from for 2 year data. 
	
	
	void derivat335endo( theta , gtheta ) {
		
		real colvector  diff
		external real rowvector hmean

		gtheta=J(1,955,1)
		lambda0= -theta[1..191]*hmean'
		
		rho=theta[192]
		beta=theta[193]
		phi=theta[194]
		
		gtheta[1]   = theta[1]*(1 + phi) + beta + phi*lambda0
		gtheta[2]   = theta[2]
		gtheta[3]   = theta[3]
		gtheta[4]   = theta[4]
		gtheta[5]   = theta[5]
		gtheta[6]   = phi*theta[2] + theta[6]*(1 + phi)
		gtheta[7]   = phi*theta[3] + theta[7]*(1 + phi)
		gtheta[8]   = phi*theta[4] + theta[8]*(1 + phi)
		gtheta[9]   = phi*theta[5] + theta[9]*(1 + phi)
		gtheta[10]  = theta[10]
		gtheta[11]  = theta[11]
		gtheta[12]  = theta[12]
		gtheta[13]  = theta[13]
		gtheta[14]  = theta[14]
		gtheta[15]  = theta[15]
		gtheta[16]  = phi*theta[10] + theta[16]*(1 + phi)
		gtheta[17]  = phi*theta[11] + theta[17]*(1 + phi)
		gtheta[18]  = phi*theta[12] + theta[18]*(1 + phi)
		gtheta[19]  = phi*theta[13] + theta[19]*(1 + phi)
		gtheta[20]  = phi*theta[14] + theta[20]*(1 + phi)
		gtheta[21]  = phi*theta[15] + theta[21]*(1 + phi)
		gtheta[22]  = theta[22]
		gtheta[23]  = theta[23]
		gtheta[24]  = theta[24]
		gtheta[25]  = theta[25]
		gtheta[26]  = phi*theta[22] + theta[26]*(1 + phi)
		gtheta[27]  = phi*theta[23] + theta[27]*(1 + phi)
		gtheta[28]  = phi*theta[24] + theta[28]*(1 + phi)
		gtheta[29]  = phi*theta[25] + theta[29]*(1 + phi)
		gtheta[30]  = theta[30]
		gtheta[31]  = phi*theta[30] + theta[31]*(1 + phi)
		gtheta[32]  = rho + theta[32]
		gtheta[33]  = theta[33]
		gtheta[34]  = theta[34]
		gtheta[35]  = theta[35]
		gtheta[36]  = theta[36]
		gtheta[37]  = phi*theta[32] + theta[37]*(1 + phi)
		gtheta[38]  = theta[38]
		gtheta[39]  = theta[39]
		gtheta[40]  = theta[40]
		gtheta[41]  = theta[41]
		gtheta[42]  = phi*theta[38] + theta[42]*(1 + phi)
		gtheta[43]  = phi*theta[39] + theta[43]*(1 + phi)
		gtheta[44]  = phi*theta[40] + theta[44]*(1 + phi)
		gtheta[45]  = phi*theta[41] + theta[45]*(1 + phi)
		gtheta[46]  = theta[46]
		gtheta[47]  = theta[47]
		gtheta[48]  = theta[48]
		gtheta[49]  = theta[49]
		gtheta[50]  = theta[50]
		gtheta[51]  = theta[51]
		gtheta[52]  = phi*theta[46] + theta[52]*(1 + phi)
		gtheta[53]  = phi*theta[47] + theta[53]*(1 + phi)
		gtheta[54]  = phi*theta[48] + theta[54]*(1 + phi)
		gtheta[55]  = phi*theta[49] + theta[55]*(1 + phi)
		gtheta[56]  = phi*theta[50] + theta[56]*(1 + phi)
		gtheta[57]  = phi*theta[51] + theta[57]*(1 + phi)
		gtheta[58]  = theta[58]
		gtheta[59]  = theta[59]
		gtheta[60]  = theta[60]
		gtheta[61]  = theta[61]
		gtheta[62]  = phi*theta[58] + theta[62]*(1 + phi)
		gtheta[63]  = phi*theta[59] + theta[63]*(1 + phi)
		gtheta[64]  = phi*theta[60] + theta[64]*(1 + phi)
		gtheta[65]  = phi*theta[61] + theta[65]*(1 + phi)
		gtheta[66]  = theta[66]
		gtheta[67]  = phi*theta[66] + theta[67]*(1 + phi)
		gtheta[68]  = phi*theta[33] + theta[68]*(1 + phi)
		gtheta[69]  = theta[69]
		gtheta[70]  = theta[70]
		gtheta[71]  = theta[71]
		gtheta[72]  = theta[72]
		gtheta[73]  = phi*theta[69] + theta[73]*(1 + phi)
		gtheta[74]  = phi*theta[70] + theta[74]*(1 + phi)
		gtheta[75]  = phi*theta[71] + theta[75]*(1 + phi)
		gtheta[76]  = phi*theta[72] + theta[76]*(1 + phi)
		gtheta[77]  = theta[77]
		gtheta[78]  = theta[78]
		gtheta[79]  = theta[79]
		gtheta[80]  = theta[80]
		gtheta[81]  = theta[81]
		gtheta[82]  = theta[82]
		gtheta[83]  = phi*theta[77] + theta[83]*(1 + phi)
		gtheta[84]  = phi*theta[78] + theta[84]*(1 + phi)
		gtheta[85]  = phi*theta[79] + theta[85]*(1 + phi)
		gtheta[86]  = phi*theta[80] + theta[86]*(1 + phi)
		gtheta[87]  = phi*theta[81] + theta[87]*(1 + phi)
		gtheta[88]  = phi*theta[82] + theta[88]*(1 + phi)
		gtheta[89]  = theta[89]
		gtheta[90]  = theta[90]
		gtheta[91]  = theta[91]
		gtheta[92]  = theta[92]
		gtheta[93]  = phi*theta[89] + theta[93]*(1 + phi)
		gtheta[94]  = phi*theta[90] + theta[94]*(1 + phi)
		gtheta[95]  = phi*theta[91] + theta[95]*(1 + phi)
		gtheta[96]  = phi*theta[92] + theta[96]*(1 + phi)
		gtheta[97]  = theta[97]
		gtheta[98]  = phi*theta[97] + theta[98]*(1 + phi)
		gtheta[99]  = phi*theta[34] + theta[99]*(1 + phi)
		gtheta[100] = theta[100]
		gtheta[101] = theta[101]
		gtheta[102] = theta[102]
		gtheta[103] = theta[103]
		gtheta[104] = phi*theta[100] + theta[104]*(1 + phi)
		gtheta[105] = phi*theta[101] + theta[105]*(1 + phi)
		gtheta[106] = phi*theta[102] + theta[106]*(1 + phi)
		gtheta[107] = phi*theta[103] + theta[107]*(1 + phi)
		gtheta[108] = theta[108]
		gtheta[109] = theta[109]
		gtheta[110] = theta[110]
		gtheta[111] = theta[111]
		gtheta[112] = theta[112]
		gtheta[113] = theta[113]
		gtheta[114] = phi*theta[108] + theta[114]*(1 + phi)
		gtheta[115] = phi*theta[109] + theta[115]*(1 + phi)
		gtheta[116] = phi*theta[110] + theta[116]*(1 + phi)
		gtheta[117] = phi*theta[111] + theta[117]*(1 + phi)
		gtheta[118] = phi*theta[112] + theta[118]*(1 + phi)
		gtheta[119] = phi*theta[113] + theta[119]*(1 + phi)
		gtheta[120] = theta[120]
		gtheta[121] = theta[121]
		gtheta[122] = theta[122]
		gtheta[123] = theta[123]
		gtheta[124] = phi*theta[120] + theta[124]*(1 + phi)
		gtheta[125] = phi*theta[121] + theta[125]*(1 + phi)
		gtheta[126] = phi*theta[122] + theta[126]*(1 + phi)
		gtheta[127] = phi*theta[123] + theta[127]*(1 + phi)
		gtheta[128] = theta[128]
		gtheta[129] = phi*theta[128] + theta[129]*(1 + phi)
		gtheta[130] = phi*theta[35] + theta[130]*(1 + phi)
		gtheta[131] = theta[131]
		gtheta[132] = theta[132]
		gtheta[133] = theta[133]
		gtheta[134] = theta[134]
		gtheta[135] = phi*theta[131] + theta[135]*(1 + phi)
		gtheta[136] = phi*theta[132] + theta[136]*(1 + phi)
		gtheta[137] = phi*theta[133] + theta[137]*(1 + phi)
		gtheta[138] = phi*theta[134] + theta[138]*(1 + phi)
		gtheta[139] = theta[139]
		gtheta[140] = theta[140]
		gtheta[141] = theta[141]
		gtheta[142] = theta[142]
		gtheta[143] = theta[143]
		gtheta[144] = theta[144]
		gtheta[145] = phi*theta[139] + theta[145]*(1 + phi)
		gtheta[146] = phi*theta[140] + theta[146]*(1 + phi)
		gtheta[147] = phi*theta[141] + theta[147]*(1 + phi)
		gtheta[148] = phi*theta[142] + theta[148]*(1 + phi)
		gtheta[149] = phi*theta[143] + theta[149]*(1 + phi)
		gtheta[150] = phi*theta[144] + theta[150]*(1 + phi)
		gtheta[151] = theta[151]
		gtheta[152] = theta[152]
		gtheta[153] = theta[153]
		gtheta[154] = theta[154]
		gtheta[155] = phi*theta[151] + theta[155]*(1 + phi)
		gtheta[156] = phi*theta[152] + theta[156]*(1 + phi)
		gtheta[157] = phi*theta[153] + theta[157]*(1 + phi)
		gtheta[158] = phi*theta[154] + theta[158]*(1 + phi)
		gtheta[159] = theta[159]
		gtheta[160] = phi*theta[159] + theta[160]*(1 + phi)
		gtheta[161] = phi*theta[36] + theta[161]*(1 + phi)
		gtheta[162] = theta[162]
		gtheta[163] = theta[163]
		gtheta[164] = theta[164]
		gtheta[165] = theta[165]
		gtheta[166] = phi*theta[162] + theta[166]*(1 + phi)
		gtheta[167] = phi*theta[163] + theta[167]*(1 + phi)
		gtheta[168] = phi*theta[164] + theta[168]*(1 + phi)
		gtheta[169] = phi*theta[165] + theta[169]*(1 + phi)
		gtheta[170] = theta[170]
		gtheta[171] = theta[171]
		gtheta[172] = theta[172]
		gtheta[173] = theta[173]
		gtheta[174] = theta[174]
		gtheta[175] = theta[175]
		gtheta[176] = phi*theta[170] + theta[176]*(1 + phi)
		gtheta[177] = phi*theta[171] + theta[177]*(1 + phi)
		gtheta[178] = phi*theta[172] + theta[178]*(1 + phi)
		gtheta[179] = phi*theta[173] + theta[179]*(1 + phi)
		gtheta[180] = phi*theta[174] + theta[180]*(1 + phi)
		gtheta[181] = phi*theta[175] + theta[181]*(1 + phi)
		gtheta[182] = theta[182]
		gtheta[183] = theta[183]
		gtheta[184] = theta[184]
		gtheta[185] = theta[185]
		gtheta[186] = phi*theta[182] + theta[186]*(1 + phi)
		gtheta[187] = phi*theta[183] + theta[187]*(1 + phi)
		gtheta[188] = phi*theta[184] + theta[188]*(1 + phi)
		gtheta[189] = phi*theta[185] + theta[189]*(1 + phi)
		gtheta[190] = theta[190]
		gtheta[191] = phi*theta[190] + theta[191]*(1 + phi)
		gtheta[192] = theta[1]
		gtheta[193] = theta[2]*(1 + phi) + beta + phi*lambda0
		gtheta[194] = theta[3]
		gtheta[195] = theta[4]
		gtheta[196] = theta[5]
		gtheta[197] = phi*theta[1] + theta[6]*(1 + phi)
		gtheta[198] = theta[7]
		gtheta[199] = theta[8]
		gtheta[200] = theta[9]
		gtheta[201] = phi*theta[3] + theta[10]*(1 + phi)
		gtheta[202] = phi*theta[4] + theta[11]*(1 + phi)
		gtheta[203] = phi*theta[5] + theta[12]*(1 + phi)
		gtheta[204] = theta[13]
		gtheta[205] = theta[14]
		gtheta[206] = theta[15]
		gtheta[207] = phi*theta[7] + theta[16]*(1 + phi)
		gtheta[208] = phi*theta[8] + theta[17]*(1 + phi)
		gtheta[209] = phi*theta[9] + theta[18]*(1 + phi)
		gtheta[210] = theta[19]
		gtheta[211] = theta[20]
		gtheta[212] = theta[21]
		gtheta[213] = phi*theta[13] + theta[22]*(1 + phi)
		gtheta[214] = phi*theta[14] + theta[23]*(1 + phi)
		gtheta[215] = phi*theta[15] + theta[24]*(1 + phi)
		gtheta[216] = theta[25]
		gtheta[217] = phi*theta[19] + theta[26]*(1 + phi)
		gtheta[218] = phi*theta[20] + theta[27]*(1 + phi)
		gtheta[219] = phi*theta[21] + theta[28]*(1 + phi)
		gtheta[220] = theta[29]
		gtheta[221] = phi*theta[25] + theta[30]*(1 + phi)
		gtheta[222] = phi*theta[29] + theta[31]*(1 + phi)
		gtheta[223] = theta[32]
		gtheta[224] = rho + theta[33]
		gtheta[225] = theta[34]
		gtheta[226] = theta[35]
		gtheta[227] = theta[36]
		gtheta[228] = theta[37]
		gtheta[229] = phi*theta[32] + theta[38]*(1 + phi)
		gtheta[230] = theta[39]
		gtheta[231] = theta[40]
		gtheta[232] = theta[41]
		gtheta[233] = phi*theta[37] + theta[42]*(1 + phi)
		gtheta[234] = theta[43]
		gtheta[235] = theta[44]
		gtheta[236] = theta[45]
		gtheta[237] = phi*theta[39] + theta[46]*(1 + phi)
		gtheta[238] = phi*theta[40] + theta[47]*(1 + phi)
		gtheta[239] = phi*theta[41] + theta[48]*(1 + phi)
		gtheta[240] = theta[49]
		gtheta[241] = theta[50]
		gtheta[242] = theta[51]
		gtheta[243] = phi*theta[43] + theta[52]*(1 + phi)
		gtheta[244] = phi*theta[44] + theta[53]*(1 + phi)
		gtheta[245] = phi*theta[45] + theta[54]*(1 + phi)
		gtheta[246] = theta[55]
		gtheta[247] = theta[56]
		gtheta[248] = theta[57]
		gtheta[249] = phi*theta[49] + theta[58]*(1 + phi)
		gtheta[250] = phi*theta[50] + theta[59]*(1 + phi)
		gtheta[251] = phi*theta[51] + theta[60]*(1 + phi)
		gtheta[252] = theta[61]
		gtheta[253] = phi*theta[55] + theta[62]*(1 + phi)
		gtheta[254] = phi*theta[56] + theta[63]*(1 + phi)
		gtheta[255] = phi*theta[57] + theta[64]*(1 + phi)
		gtheta[256] = theta[65]
		gtheta[257] = phi*theta[61] + theta[66]*(1 + phi)
		gtheta[258] = phi*theta[65] + theta[67]*(1 + phi)
		gtheta[259] = theta[68]
		gtheta[260] = phi*theta[33] + theta[69]*(1 + phi)
		gtheta[261] = theta[70]
		gtheta[262] = theta[71]
		gtheta[263] = theta[72]
		gtheta[264] = phi*theta[68] + theta[73]*(1 + phi)
		gtheta[265] = theta[74]
		gtheta[266] = theta[75]
		gtheta[267] = theta[76]
		gtheta[268] = phi*theta[70] + theta[77]*(1 + phi)
		gtheta[269] = phi*theta[71] + theta[78]*(1 + phi)
		gtheta[270] = phi*theta[72] + theta[79]*(1 + phi)
		gtheta[271] = theta[80]
		gtheta[272] = theta[81]
		gtheta[273] = theta[82]
		gtheta[274] = phi*theta[74] + theta[83]*(1 + phi)
		gtheta[275] = phi*theta[75] + theta[84]*(1 + phi)
		gtheta[276] = phi*theta[76] + theta[85]*(1 + phi)
		gtheta[277] = theta[86]
		gtheta[278] = theta[87]
		gtheta[279] = theta[88]
		gtheta[280] = phi*theta[80] + theta[89]*(1 + phi)
		gtheta[281] = phi*theta[81] + theta[90]*(1 + phi)
		gtheta[282] = phi*theta[82] + theta[91]*(1 + phi)
		gtheta[283] = theta[92]
		gtheta[284] = phi*theta[86] + theta[93]*(1 + phi)
		gtheta[285] = phi*theta[87] + theta[94]*(1 + phi)
		gtheta[286] = phi*theta[88] + theta[95]*(1 + phi)
		gtheta[287] = theta[96]
		gtheta[288] = phi*theta[92] + theta[97]*(1 + phi)
		gtheta[289] = phi*theta[96] + theta[98]*(1 + phi)
		gtheta[290] = theta[99]
		gtheta[291] = phi*theta[34] + theta[100]*(1 + phi)
		gtheta[292] = theta[101]
		gtheta[293] = theta[102]
		gtheta[294] = theta[103]
		gtheta[295] = phi*theta[99] + theta[104]*(1 + phi)
		gtheta[296] = theta[105]
		gtheta[297] = theta[106]
		gtheta[298] = theta[107]
		gtheta[299] = phi*theta[101] + theta[108]*(1 + phi)
		gtheta[300] = phi*theta[102] + theta[109]*(1 + phi)
		gtheta[301] = phi*theta[103] + theta[110]*(1 + phi)
		gtheta[302] = theta[111]
		gtheta[303] = theta[112]
		gtheta[304] = theta[113]
		gtheta[305] = phi*theta[105] + theta[114]*(1 + phi)
		gtheta[306] = phi*theta[106] + theta[115]*(1 + phi)
		gtheta[307] = phi*theta[107] + theta[116]*(1 + phi)
		gtheta[308] = theta[117]
		gtheta[309] = theta[118]
		gtheta[310] = theta[119]
		gtheta[311] = phi*theta[111] + theta[120]*(1 + phi)
		gtheta[312] = phi*theta[112] + theta[121]*(1 + phi)
		gtheta[313] = phi*theta[113] + theta[122]*(1 + phi)
		gtheta[314] = theta[123]
		gtheta[315] = phi*theta[117] + theta[124]*(1 + phi)
		gtheta[316] = phi*theta[118] + theta[125]*(1 + phi)
		gtheta[317] = phi*theta[119] + theta[126]*(1 + phi)
		gtheta[318] = theta[127]
		gtheta[319] = phi*theta[123] + theta[128]*(1 + phi)
		gtheta[320] = phi*theta[127] + theta[129]*(1 + phi)
		gtheta[321] = theta[130]
		gtheta[322] = phi*theta[35] + theta[131]*(1 + phi)
		gtheta[323] = theta[132]
		gtheta[324] = theta[133]
		gtheta[325] = theta[134]
		gtheta[326] = phi*theta[130] + theta[135]*(1 + phi)
		gtheta[327] = theta[136]
		gtheta[328] = theta[137]
		gtheta[329] = theta[138]
		gtheta[330] = phi*theta[132] + theta[139]*(1 + phi)
		gtheta[331] = phi*theta[133] + theta[140]*(1 + phi)
		gtheta[332] = phi*theta[134] + theta[141]*(1 + phi)
		gtheta[333] = theta[142]
		gtheta[334] = theta[143]
		gtheta[335] = theta[144]
		gtheta[336] = phi*theta[136] + theta[145]*(1 + phi)
		gtheta[337] = phi*theta[137] + theta[146]*(1 + phi)
		gtheta[338] = phi*theta[138] + theta[147]*(1 + phi)
		gtheta[339] = theta[148]
		gtheta[340] = theta[149]
		gtheta[341] = theta[150]
		gtheta[342] = phi*theta[142] + theta[151]*(1 + phi)
		gtheta[343] = phi*theta[143] + theta[152]*(1 + phi)
		gtheta[344] = phi*theta[144] + theta[153]*(1 + phi)
		gtheta[345] = theta[154]
		gtheta[346] = phi*theta[148] + theta[155]*(1 + phi)
		gtheta[347] = phi*theta[149] + theta[156]*(1 + phi)
		gtheta[348] = phi*theta[150] + theta[157]*(1 + phi)
		gtheta[349] = theta[158]
		gtheta[350] = phi*theta[154] + theta[159]*(1 + phi)
		gtheta[351] = phi*theta[158] + theta[160]*(1 + phi)
		gtheta[352] = theta[161]
		gtheta[353] = phi*theta[36] + theta[162]*(1 + phi)
		gtheta[354] = theta[163]
		gtheta[355] = theta[164]
		gtheta[356] = theta[165]
		gtheta[357] = phi*theta[161] + theta[166]*(1 + phi)
		gtheta[358] = theta[167]
		gtheta[359] = theta[168]
		gtheta[360] = theta[169]
		gtheta[361] = phi*theta[163] + theta[170]*(1 + phi)
		gtheta[362] = phi*theta[164] + theta[171]*(1 + phi)
		gtheta[363] = phi*theta[165] + theta[172]*(1 + phi)
		gtheta[364] = theta[173]
		gtheta[365] = theta[174]
		gtheta[366] = theta[175]
		gtheta[367] = phi*theta[167] + theta[176]*(1 + phi)
		gtheta[368] = phi*theta[168] + theta[177]*(1 + phi)
		gtheta[369] = phi*theta[169] + theta[178]*(1 + phi)
		gtheta[370] = theta[179]
		gtheta[371] = theta[180]
		gtheta[372] = theta[181]
		gtheta[373] = phi*theta[173] + theta[182]*(1 + phi)
		gtheta[374] = phi*theta[174] + theta[183]*(1 + phi)
		gtheta[375] = phi*theta[175] + theta[184]*(1 + phi)
		gtheta[376] = theta[185]
		gtheta[377] = phi*theta[179] + theta[186]*(1 + phi)
		gtheta[378] = phi*theta[180] + theta[187]*(1 + phi)
		gtheta[379] = phi*theta[181] + theta[188]*(1 + phi)
		gtheta[380] = theta[189]
		gtheta[381] = phi*theta[185] + theta[190]*(1 + phi)
		gtheta[382] = phi*theta[189] + theta[191]*(1 + phi)
		gtheta[383] = theta[1]
		gtheta[384] = theta[2]
		gtheta[385] = theta[3]*(1 + phi) + beta + phi*lambda0
		gtheta[386] = theta[4]
		gtheta[387] = theta[5]
		gtheta[388] = theta[6]
		gtheta[389] = phi*theta[1] + theta[7]*(1 + phi)
		gtheta[390] = theta[8]
		gtheta[391] = theta[9]
		gtheta[392] = phi*theta[2] + theta[10]*(1 + phi)
		gtheta[393] = theta[11]
		gtheta[394] = theta[12]
		gtheta[395] = phi*theta[4] + theta[13]*(1 + phi)
		gtheta[396] = phi*theta[5] + theta[14]*(1 + phi)
		gtheta[397] = theta[15]
		gtheta[398] = phi*theta[6] + theta[16]*(1 + phi)
		gtheta[399] = theta[17]
		gtheta[400] = theta[18]
		gtheta[401] = phi*theta[8] + theta[19]*(1 + phi)
		gtheta[402] = phi*theta[9] + theta[20]*(1 + phi)
		gtheta[403] = theta[21]
		gtheta[404] = phi*theta[11] + theta[22]*(1 + phi)
		gtheta[405] = phi*theta[12] + theta[23]*(1 + phi)
		gtheta[406] = theta[24]
		gtheta[407] = phi*theta[15] + theta[25]*(1 + phi)
		gtheta[408] = phi*theta[17] + theta[26]*(1 + phi)
		gtheta[409] = phi*theta[18] + theta[27]*(1 + phi)
		gtheta[410] = theta[28]
		gtheta[411] = phi*theta[21] + theta[29]*(1 + phi)
		gtheta[412] = phi*theta[24] + theta[30]*(1 + phi)
		gtheta[413] = phi*theta[28] + theta[31]*(1 + phi)
		gtheta[414] = theta[32]
		gtheta[415] = theta[33]
		gtheta[416] = rho + theta[34]
		gtheta[417] = theta[35]
		gtheta[418] = theta[36]
		gtheta[419] = theta[37]
		gtheta[420] = theta[38]
		gtheta[421] = phi*theta[32] + theta[39]*(1 + phi)
		gtheta[422] = theta[40]
		gtheta[423] = theta[41]
		gtheta[424] = theta[42]
		gtheta[425] = phi*theta[37] + theta[43]*(1 + phi)
		gtheta[426] = theta[44]
		gtheta[427] = theta[45]
		gtheta[428] = phi*theta[38] + theta[46]*(1 + phi)
		gtheta[429] = theta[47]
		gtheta[430] = theta[48]
		gtheta[431] = phi*theta[40] + theta[49]*(1 + phi)
		gtheta[432] = phi*theta[41] + theta[50]*(1 + phi)
		gtheta[433] = theta[51]
		gtheta[434] = phi*theta[42] + theta[52]*(1 + phi)
		gtheta[435] = theta[53]
		gtheta[436] = theta[54]
		gtheta[437] = phi*theta[44] + theta[55]*(1 + phi)
		gtheta[438] = phi*theta[45] + theta[56]*(1 + phi)
		gtheta[439] = theta[57]
		gtheta[440] = phi*theta[47] + theta[58]*(1 + phi)
		gtheta[441] = phi*theta[48] + theta[59]*(1 + phi)
		gtheta[442] = theta[60]
		gtheta[443] = phi*theta[51] + theta[61]*(1 + phi)
		gtheta[444] = phi*theta[53] + theta[62]*(1 + phi)
		gtheta[445] = phi*theta[54] + theta[63]*(1 + phi)
		gtheta[446] = theta[64]
		gtheta[447] = phi*theta[57] + theta[65]*(1 + phi)
		gtheta[448] = phi*theta[60] + theta[66]*(1 + phi)
		gtheta[449] = phi*theta[64] + theta[67]*(1 + phi)
		gtheta[450] = theta[68]
		gtheta[451] = theta[69]
		gtheta[452] = phi*theta[33] + theta[70]*(1 + phi)
		gtheta[453] = theta[71]
		gtheta[454] = theta[72]
		gtheta[455] = theta[73]
		gtheta[456] = phi*theta[68] + theta[74]*(1 + phi)
		gtheta[457] = theta[75]
		gtheta[458] = theta[76]
		gtheta[459] = phi*theta[69] + theta[77]*(1 + phi)
		gtheta[460] = theta[78]
		gtheta[461] = theta[79]
		gtheta[462] = phi*theta[71] + theta[80]*(1 + phi)
		gtheta[463] = phi*theta[72] + theta[81]*(1 + phi)
		gtheta[464] = theta[82]
		gtheta[465] = phi*theta[73] + theta[83]*(1 + phi)
		gtheta[466] = theta[84]
		gtheta[467] = theta[85]
		gtheta[468] = phi*theta[75] + theta[86]*(1 + phi)
		gtheta[469] = phi*theta[76] + theta[87]*(1 + phi)
		gtheta[470] = theta[88]
		gtheta[471] = phi*theta[78] + theta[89]*(1 + phi)
		gtheta[472] = phi*theta[79] + theta[90]*(1 + phi)
		gtheta[473] = theta[91]
		gtheta[474] = phi*theta[82] + theta[92]*(1 + phi)
		gtheta[475] = phi*theta[84] + theta[93]*(1 + phi)
		gtheta[476] = phi*theta[85] + theta[94]*(1 + phi)
		gtheta[477] = theta[95]
		gtheta[478] = phi*theta[88] + theta[96]*(1 + phi)
		gtheta[479] = phi*theta[91] + theta[97]*(1 + phi)
		gtheta[480] = phi*theta[95] + theta[98]*(1 + phi)
		gtheta[481] = theta[99]
		gtheta[482] = theta[100]
		gtheta[483] = phi*theta[34] + theta[101]*(1 + phi)
		gtheta[484] = theta[102]
		gtheta[485] = theta[103]
		gtheta[486] = theta[104]
		gtheta[487] = phi*theta[99] + theta[105]*(1 + phi)
		gtheta[488] = theta[106]
		gtheta[489] = theta[107]
		gtheta[490] = phi*theta[100] + theta[108]*(1 + phi)
		gtheta[491] = theta[109]
		gtheta[492] = theta[110]
		gtheta[493] = phi*theta[102] + theta[111]*(1 + phi)
		gtheta[494] = phi*theta[103] + theta[112]*(1 + phi)
		gtheta[495] = theta[113]
		gtheta[496] = phi*theta[104] + theta[114]*(1 + phi)
		gtheta[497] = theta[115]
		gtheta[498] = theta[116]
		gtheta[499] = phi*theta[106] + theta[117]*(1 + phi)
		gtheta[500] = phi*theta[107] + theta[118]*(1 + phi)
		gtheta[501] = theta[119]
		gtheta[502] = phi*theta[109] + theta[120]*(1 + phi)
		gtheta[503] = phi*theta[110] + theta[121]*(1 + phi)
		gtheta[504] = theta[122]
		gtheta[505] = phi*theta[113] + theta[123]*(1 + phi)
		gtheta[506] = phi*theta[115] + theta[124]*(1 + phi)
		gtheta[507] = phi*theta[116] + theta[125]*(1 + phi)
		gtheta[508] = theta[126]
		gtheta[509] = phi*theta[119] + theta[127]*(1 + phi)
		gtheta[510] = phi*theta[122] + theta[128]*(1 + phi)
		gtheta[511] = phi*theta[126] + theta[129]*(1 + phi)
		gtheta[512] = theta[130]
		gtheta[513] = theta[131]
		gtheta[514] = phi*theta[35] + theta[132]*(1 + phi)
		gtheta[515] = theta[133]
		gtheta[516] = theta[134]
		gtheta[517] = theta[135]
		gtheta[518] = phi*theta[130] + theta[136]*(1 + phi)
		gtheta[519] = theta[137]
		gtheta[520] = theta[138]
		gtheta[521] = phi*theta[131] + theta[139]*(1 + phi)
		gtheta[522] = theta[140]
		gtheta[523] = theta[141]
		gtheta[524] = phi*theta[133] + theta[142]*(1 + phi)
		gtheta[525] = phi*theta[134] + theta[143]*(1 + phi)
		gtheta[526] = theta[144]
		gtheta[527] = phi*theta[135] + theta[145]*(1 + phi)
		gtheta[528] = theta[146]
		gtheta[529] = theta[147]
		gtheta[530] = phi*theta[137] + theta[148]*(1 + phi)
		gtheta[531] = phi*theta[138] + theta[149]*(1 + phi)
		gtheta[532] = theta[150]
		gtheta[533] = phi*theta[140] + theta[151]*(1 + phi)
		gtheta[534] = phi*theta[141] + theta[152]*(1 + phi)
		gtheta[535] = theta[153]
		gtheta[536] = phi*theta[144] + theta[154]*(1 + phi)
		gtheta[537] = phi*theta[146] + theta[155]*(1 + phi)
		gtheta[538] = phi*theta[147] + theta[156]*(1 + phi)
		gtheta[539] = theta[157]
		gtheta[540] = phi*theta[150] + theta[158]*(1 + phi)
		gtheta[541] = phi*theta[153] + theta[159]*(1 + phi)
		gtheta[542] = phi*theta[157] + theta[160]*(1 + phi)
		gtheta[543] = theta[161]
		gtheta[544] = theta[162]
		gtheta[545] = phi*theta[36] + theta[163]*(1 + phi)
		gtheta[546] = theta[164]
		gtheta[547] = theta[165]
		gtheta[548] = theta[166]
		gtheta[549] = phi*theta[161] + theta[167]*(1 + phi)
		gtheta[550] = theta[168]
		gtheta[551] = theta[169]
		gtheta[552] = phi*theta[162] + theta[170]*(1 + phi)
		gtheta[553] = theta[171]
		gtheta[554] = theta[172]
		gtheta[555] = phi*theta[164] + theta[173]*(1 + phi)
		gtheta[556] = phi*theta[165] + theta[174]*(1 + phi)
		gtheta[557] = theta[175]
		gtheta[558] = phi*theta[166] + theta[176]*(1 + phi)
		gtheta[559] = theta[177]
		gtheta[560] = theta[178]
		gtheta[561] = phi*theta[168] + theta[179]*(1 + phi)
		gtheta[562] = phi*theta[169] + theta[180]*(1 + phi)
		gtheta[563] = theta[181]
		gtheta[564] = phi*theta[171] + theta[182]*(1 + phi)
		gtheta[565] = phi*theta[172] + theta[183]*(1 + phi)
		gtheta[566] = theta[184]
		gtheta[567] = phi*theta[175] + theta[185]*(1 + phi)
		gtheta[568] = phi*theta[177] + theta[186]*(1 + phi)
		gtheta[569] = phi*theta[178] + theta[187]*(1 + phi)
		gtheta[570] = theta[188]
		gtheta[571] = phi*theta[181] + theta[189]*(1 + phi)
		gtheta[572] = phi*theta[184] + theta[190]*(1 + phi)
		gtheta[573] = phi*theta[188] + theta[191]*(1 + phi)
		gtheta[574] = theta[1]
		gtheta[575] = theta[2]
		gtheta[576] = theta[3]
		gtheta[577] = theta[4]*(1 + phi) + beta + phi*lambda0
		gtheta[578] = theta[5]
		gtheta[579] = theta[6]
		gtheta[580] = theta[7]
		gtheta[581] = phi*theta[1] + theta[8]*(1 + phi)
		gtheta[582] = theta[9]
		gtheta[583] = theta[10]
		gtheta[584] = phi*theta[2] + theta[11]*(1 + phi)
		gtheta[585] = theta[12]
		gtheta[586] = phi*theta[3] + theta[13]*(1 + phi)
		gtheta[587] = theta[14]
		gtheta[588] = phi*theta[5] + theta[15]*(1 + phi)
		gtheta[589] = theta[16]
		gtheta[590] = phi*theta[6] + theta[17]*(1 + phi)
		gtheta[591] = theta[18]
		gtheta[592] = phi*theta[7] + theta[19]*(1 + phi)
		gtheta[593] = theta[20]
		gtheta[594] = phi*theta[9] + theta[21]*(1 + phi)
		gtheta[595] = phi*theta[10] + theta[22]*(1 + phi)
		gtheta[596] = theta[23]
		gtheta[597] = phi*theta[12] + theta[24]*(1 + phi)
		gtheta[598] = phi*theta[14] + theta[25]*(1 + phi)
		gtheta[599] = phi*theta[16] + theta[26]*(1 + phi)
		gtheta[600] = theta[27]
		gtheta[601] = phi*theta[18] + theta[28]*(1 + phi)
		gtheta[602] = phi*theta[20] + theta[29]*(1 + phi)
		gtheta[603] = phi*theta[23] + theta[30]*(1 + phi)
		gtheta[604] = phi*theta[27] + theta[31]*(1 + phi)
		gtheta[605] = theta[32]
		gtheta[606] = theta[33]
		gtheta[607] = theta[34]
		gtheta[608] = rho + theta[35]
		gtheta[609] = theta[36]
		gtheta[610] = theta[37]
		gtheta[611] = theta[38]
		gtheta[612] = theta[39]
		gtheta[613] = phi*theta[32] + theta[40]*(1 + phi)
		gtheta[614] = theta[41]
		gtheta[615] = theta[42]
		gtheta[616] = theta[43]
		gtheta[617] = phi*theta[37] + theta[44]*(1 + phi)
		gtheta[618] = theta[45]
		gtheta[619] = theta[46]
		gtheta[620] = phi*theta[38] + theta[47]*(1 + phi)
		gtheta[621] = theta[48]
		gtheta[622] = phi*theta[39] + theta[49]*(1 + phi)
		gtheta[623] = theta[50]
		gtheta[624] = phi*theta[41] + theta[51]*(1 + phi)
		gtheta[625] = theta[52]
		gtheta[626] = phi*theta[42] + theta[53]*(1 + phi)
		gtheta[627] = theta[54]
		gtheta[628] = phi*theta[43] + theta[55]*(1 + phi)
		gtheta[629] = theta[56]
		gtheta[630] = phi*theta[45] + theta[57]*(1 + phi)
		gtheta[631] = phi*theta[46] + theta[58]*(1 + phi)
		gtheta[632] = theta[59]
		gtheta[633] = phi*theta[48] + theta[60]*(1 + phi)
		gtheta[634] = phi*theta[50] + theta[61]*(1 + phi)
		gtheta[635] = phi*theta[52] + theta[62]*(1 + phi)
		gtheta[636] = theta[63]
		gtheta[637] = phi*theta[54] + theta[64]*(1 + phi)
		gtheta[638] = phi*theta[56] + theta[65]*(1 + phi)
		gtheta[639] = phi*theta[59] + theta[66]*(1 + phi)
		gtheta[640] = phi*theta[63] + theta[67]*(1 + phi)
		gtheta[641] = theta[68]
		gtheta[642] = theta[69]
		gtheta[643] = theta[70]
		gtheta[644] = phi*theta[33] + theta[71]*(1 + phi)
		gtheta[645] = theta[72]
		gtheta[646] = theta[73]
		gtheta[647] = theta[74]
		gtheta[648] = phi*theta[68] + theta[75]*(1 + phi)
		gtheta[649] = theta[76]
		gtheta[650] = theta[77]
		gtheta[651] = phi*theta[69] + theta[78]*(1 + phi)
		gtheta[652] = theta[79]
		gtheta[653] = phi*theta[70] + theta[80]*(1 + phi)
		gtheta[654] = theta[81]
		gtheta[655] = phi*theta[72] + theta[82]*(1 + phi)
		gtheta[656] = theta[83]
		gtheta[657] = phi*theta[73] + theta[84]*(1 + phi)
		gtheta[658] = theta[85]
		gtheta[659] = phi*theta[74] + theta[86]*(1 + phi)
		gtheta[660] = theta[87]
		gtheta[661] = phi*theta[76] + theta[88]*(1 + phi)
		gtheta[662] = phi*theta[77] + theta[89]*(1 + phi)
		gtheta[663] = theta[90]
		gtheta[664] = phi*theta[79] + theta[91]*(1 + phi)
		gtheta[665] = phi*theta[81] + theta[92]*(1 + phi)
		gtheta[666] = phi*theta[83] + theta[93]*(1 + phi)
		gtheta[667] = theta[94]
		gtheta[668] = phi*theta[85] + theta[95]*(1 + phi)
		gtheta[669] = phi*theta[87] + theta[96]*(1 + phi)
		gtheta[670] = phi*theta[90] + theta[97]*(1 + phi)
		gtheta[671] = phi*theta[94] + theta[98]*(1 + phi)
		gtheta[672] = theta[99]
		gtheta[673] = theta[100]
		gtheta[674] = theta[101]
		gtheta[675] = phi*theta[34] + theta[102]*(1 + phi)
		gtheta[676] = theta[103]
		gtheta[677] = theta[104]
		gtheta[678] = theta[105]
		gtheta[679] = phi*theta[99] + theta[106]*(1 + phi)
		gtheta[680] = theta[107]
		gtheta[681] = theta[108]
		gtheta[682] = phi*theta[100] + theta[109]*(1 + phi)
		gtheta[683] = theta[110]
		gtheta[684] = phi*theta[101] + theta[111]*(1 + phi)
		gtheta[685] = theta[112]
		gtheta[686] = phi*theta[103] + theta[113]*(1 + phi)
		gtheta[687] = theta[114]
		gtheta[688] = phi*theta[104] + theta[115]*(1 + phi)
		gtheta[689] = theta[116]
		gtheta[690] = phi*theta[105] + theta[117]*(1 + phi)
		gtheta[691] = theta[118]
		gtheta[692] = phi*theta[107] + theta[119]*(1 + phi)
		gtheta[693] = phi*theta[108] + theta[120]*(1 + phi)
		gtheta[694] = theta[121]
		gtheta[695] = phi*theta[110] + theta[122]*(1 + phi)
		gtheta[696] = phi*theta[112] + theta[123]*(1 + phi)
		gtheta[697] = phi*theta[114] + theta[124]*(1 + phi)
		gtheta[698] = theta[125]
		gtheta[699] = phi*theta[116] + theta[126]*(1 + phi)
		gtheta[700] = phi*theta[118] + theta[127]*(1 + phi)
		gtheta[701] = phi*theta[121] + theta[128]*(1 + phi)
		gtheta[702] = phi*theta[125] + theta[129]*(1 + phi)
		gtheta[703] = theta[130]
		gtheta[704] = theta[131]
		gtheta[705] = theta[132]
		gtheta[706] = phi*theta[35] + theta[133]*(1 + phi)
		gtheta[707] = theta[134]
		gtheta[708] = theta[135]
		gtheta[709] = theta[136]
		gtheta[710] = phi*theta[130] + theta[137]*(1 + phi)
		gtheta[711] = theta[138]
		gtheta[712] = theta[139]
		gtheta[713] = phi*theta[131] + theta[140]*(1 + phi)
		gtheta[714] = theta[141]
		gtheta[715] = phi*theta[132] + theta[142]*(1 + phi)
		gtheta[716] = theta[143]
		gtheta[717] = phi*theta[134] + theta[144]*(1 + phi)
		gtheta[718] = theta[145]
		gtheta[719] = phi*theta[135] + theta[146]*(1 + phi)
		gtheta[720] = theta[147]
		gtheta[721] = phi*theta[136] + theta[148]*(1 + phi)
		gtheta[722] = theta[149]
		gtheta[723] = phi*theta[138] + theta[150]*(1 + phi)
		gtheta[724] = phi*theta[139] + theta[151]*(1 + phi)
		gtheta[725] = theta[152]
		gtheta[726] = phi*theta[141] + theta[153]*(1 + phi)
		gtheta[727] = phi*theta[143] + theta[154]*(1 + phi)
		gtheta[728] = phi*theta[145] + theta[155]*(1 + phi)
		gtheta[729] = theta[156]
		gtheta[730] = phi*theta[147] + theta[157]*(1 + phi)
		gtheta[731] = phi*theta[149] + theta[158]*(1 + phi)
		gtheta[732] = phi*theta[152] + theta[159]*(1 + phi)
		gtheta[733] = phi*theta[156] + theta[160]*(1 + phi)
		gtheta[734] = theta[161]
		gtheta[735] = theta[162]
		gtheta[736] = theta[163]
		gtheta[737] = phi*theta[36] + theta[164]*(1 + phi)
		gtheta[738] = theta[165]
		gtheta[739] = theta[166]
		gtheta[740] = theta[167]
		gtheta[741] = phi*theta[161] + theta[168]*(1 + phi)
		gtheta[742] = theta[169]
		gtheta[743] = theta[170]
		gtheta[744] = phi*theta[162] + theta[171]*(1 + phi)
		gtheta[745] = theta[172]
		gtheta[746] = phi*theta[163] + theta[173]*(1 + phi)
		gtheta[747] = theta[174]
		gtheta[748] = phi*theta[165] + theta[175]*(1 + phi)
		gtheta[749] = theta[176]
		gtheta[750] = phi*theta[166] + theta[177]*(1 + phi)
		gtheta[751] = theta[178]
		gtheta[752] = phi*theta[167] + theta[179]*(1 + phi)
		gtheta[753] = theta[180]
		gtheta[754] = phi*theta[169] + theta[181]*(1 + phi)
		gtheta[755] = phi*theta[170] + theta[182]*(1 + phi)
		gtheta[756] = theta[183]
		gtheta[757] = phi*theta[172] + theta[184]*(1 + phi)
		gtheta[758] = phi*theta[174] + theta[185]*(1 + phi)
		gtheta[759] = phi*theta[176] + theta[186]*(1 + phi)
		gtheta[760] = theta[187]
		gtheta[761] = phi*theta[178] + theta[188]*(1 + phi)
		gtheta[762] = phi*theta[180] + theta[189]*(1 + phi)
		gtheta[763] = phi*theta[183] + theta[190]*(1 + phi)
		gtheta[764] = phi*theta[187] + theta[191]*(1 + phi)
		gtheta[765] = theta[1]
		gtheta[766] = theta[2]
		gtheta[767] = theta[3]
		gtheta[768] = theta[4]
		gtheta[769] = theta[5]*(1 + phi) + beta + phi*lambda0
		gtheta[770] = theta[6]
		gtheta[771] = theta[7]
		gtheta[772] = theta[8]
		gtheta[773] = phi*theta[1] + theta[9]*(1 + phi)
		gtheta[774] = theta[10]
		gtheta[775] = theta[11]
		gtheta[776] = phi*theta[2] + theta[12]*(1 + phi)
		gtheta[777] = theta[13]
		gtheta[778] = phi*theta[3] + theta[14]*(1 + phi)
		gtheta[779] = phi*theta[4] + theta[15]*(1 + phi)
		gtheta[780] = theta[16]
		gtheta[781] = theta[17]
		gtheta[782] = phi*theta[6] + theta[18]*(1 + phi)
		gtheta[783] = theta[19]
		gtheta[784] = phi*theta[7] + theta[20]*(1 + phi)
		gtheta[785] = phi*theta[8] + theta[21]*(1 + phi)
		gtheta[786] = theta[22]
		gtheta[787] = phi*theta[10] + theta[23]*(1 + phi)
		gtheta[788] = phi*theta[11] + theta[24]*(1 + phi)
		gtheta[789] = phi*theta[13] + theta[25]*(1 + phi)
		gtheta[790] = theta[26]
		gtheta[791] = phi*theta[16] + theta[27]*(1 + phi)
		gtheta[792] = phi*theta[17] + theta[28]*(1 + phi)
		gtheta[793] = phi*theta[19] + theta[29]*(1 + phi)
		gtheta[794] = phi*theta[22] + theta[30]*(1 + phi)
		gtheta[795] = phi*theta[26] + theta[31]*(1 + phi)
		gtheta[796] = theta[32]
		gtheta[797] = theta[33]
		gtheta[798] = theta[34]
		gtheta[799] = theta[35]
		gtheta[800] = rho + theta[36]
		gtheta[801] = theta[37]
		gtheta[802] = theta[38]
		gtheta[803] = theta[39]
		gtheta[804] = theta[40]
		gtheta[805] = phi*theta[32] + theta[41]*(1 + phi)
		gtheta[806] = theta[42]
		gtheta[807] = theta[43]
		gtheta[808] = theta[44]
		gtheta[809] = phi*theta[37] + theta[45]*(1 + phi)
		gtheta[810] = theta[46]
		gtheta[811] = theta[47]
		gtheta[812] = phi*theta[38] + theta[48]*(1 + phi)
		gtheta[813] = theta[49]
		gtheta[814] = phi*theta[39] + theta[50]*(1 + phi)
		gtheta[815] = phi*theta[40] + theta[51]*(1 + phi)
		gtheta[816] = theta[52]
		gtheta[817] = theta[53]
		gtheta[818] = phi*theta[42] + theta[54]*(1 + phi)
		gtheta[819] = theta[55]
		gtheta[820] = phi*theta[43] + theta[56]*(1 + phi)
		gtheta[821] = phi*theta[44] + theta[57]*(1 + phi)
		gtheta[822] = theta[58]
		gtheta[823] = phi*theta[46] + theta[59]*(1 + phi)
		gtheta[824] = phi*theta[47] + theta[60]*(1 + phi)
		gtheta[825] = phi*theta[49] + theta[61]*(1 + phi)
		gtheta[826] = theta[62]
		gtheta[827] = phi*theta[52] + theta[63]*(1 + phi)
		gtheta[828] = phi*theta[53] + theta[64]*(1 + phi)
		gtheta[829] = phi*theta[55] + theta[65]*(1 + phi)
		gtheta[830] = phi*theta[58] + theta[66]*(1 + phi)
		gtheta[831] = phi*theta[62] + theta[67]*(1 + phi)
		gtheta[832] = theta[68]
		gtheta[833] = theta[69]
		gtheta[834] = theta[70]
		gtheta[835] = theta[71]
		gtheta[836] = phi*theta[33] + theta[72]*(1 + phi)
		gtheta[837] = theta[73]
		gtheta[838] = theta[74]
		gtheta[839] = theta[75]
		gtheta[840] = phi*theta[68] + theta[76]*(1 + phi)
		gtheta[841] = theta[77]
		gtheta[842] = theta[78]
		gtheta[843] = phi*theta[69] + theta[79]*(1 + phi)
		gtheta[844] = theta[80]
		gtheta[845] = phi*theta[70] + theta[81]*(1 + phi)
		gtheta[846] = phi*theta[71] + theta[82]*(1 + phi)
		gtheta[847] = theta[83]
		gtheta[848] = theta[84]
		gtheta[849] = phi*theta[73] + theta[85]*(1 + phi)
		gtheta[850] = theta[86]
		gtheta[851] = phi*theta[74] + theta[87]*(1 + phi)
		gtheta[852] = phi*theta[75] + theta[88]*(1 + phi)
		gtheta[853] = theta[89]
		gtheta[854] = phi*theta[77] + theta[90]*(1 + phi)
		gtheta[855] = phi*theta[78] + theta[91]*(1 + phi)
		gtheta[856] = phi*theta[80] + theta[92]*(1 + phi)
		gtheta[857] = theta[93]
		gtheta[858] = phi*theta[83] + theta[94]*(1 + phi)
		gtheta[859] = phi*theta[84] + theta[95]*(1 + phi)
		gtheta[860] = phi*theta[86] + theta[96]*(1 + phi)
		gtheta[861] = phi*theta[89] + theta[97]*(1 + phi)
		gtheta[862] = phi*theta[93] + theta[98]*(1 + phi)
		gtheta[863] = theta[99]
		gtheta[864] = theta[100]
		gtheta[865] = theta[101]
		gtheta[866] = theta[102]
		gtheta[867] = phi*theta[34] + theta[103]*(1 + phi)
		gtheta[868] = theta[104]
		gtheta[869] = theta[105]
		gtheta[870] = theta[106]
		gtheta[871] = phi*theta[99] + theta[107]*(1 + phi)
		gtheta[872] = theta[108]
		gtheta[873] = theta[109]
		gtheta[874] = phi*theta[100] + theta[110]*(1 + phi)
		gtheta[875] = theta[111]
		gtheta[876] = phi*theta[101] + theta[112]*(1 + phi)
		gtheta[877] = phi*theta[102] + theta[113]*(1 + phi)
		gtheta[878] = theta[114]
		gtheta[879] = theta[115]
		gtheta[880] = phi*theta[104] + theta[116]*(1 + phi)
		gtheta[881] = theta[117]
		gtheta[882] = phi*theta[105] + theta[118]*(1 + phi)
		gtheta[883] = phi*theta[106] + theta[119]*(1 + phi)
		gtheta[884] = theta[120]
		gtheta[885] = phi*theta[108] + theta[121]*(1 + phi)
		gtheta[886] = phi*theta[109] + theta[122]*(1 + phi)
		gtheta[887] = phi*theta[111] + theta[123]*(1 + phi)
		gtheta[888] = theta[124]
		gtheta[889] = phi*theta[114] + theta[125]*(1 + phi)
		gtheta[890] = phi*theta[115] + theta[126]*(1 + phi)
		gtheta[891] = phi*theta[117] + theta[127]*(1 + phi)
		gtheta[892] = phi*theta[120] + theta[128]*(1 + phi)
		gtheta[893] = phi*theta[124] + theta[129]*(1 + phi)
		gtheta[894] = theta[130]
		gtheta[895] = theta[131]
		gtheta[896] = theta[132]
		gtheta[897] = theta[133]
		gtheta[898] = phi*theta[35] + theta[134]*(1 + phi)
		gtheta[899] = theta[135]
		gtheta[900] = theta[136]
		gtheta[901] = theta[137]
		gtheta[902] = phi*theta[130] + theta[138]*(1 + phi)
		gtheta[903] = theta[139]
		gtheta[904] = theta[140]
		gtheta[905] = phi*theta[131] + theta[141]*(1 + phi)
		gtheta[906] = theta[142]
		gtheta[907] = phi*theta[132] + theta[143]*(1 + phi)
		gtheta[908] = phi*theta[133] + theta[144]*(1 + phi)
		gtheta[909] = theta[145]
		gtheta[910] = theta[146]
		gtheta[911] = phi*theta[135] + theta[147]*(1 + phi)
		gtheta[912] = theta[148]
		gtheta[913] = phi*theta[136] + theta[149]*(1 + phi)
		gtheta[914] = phi*theta[137] + theta[150]*(1 + phi)
		gtheta[915] = theta[151]
		gtheta[916] = phi*theta[139] + theta[152]*(1 + phi)
		gtheta[917] = phi*theta[140] + theta[153]*(1 + phi)
		gtheta[918] = phi*theta[142] + theta[154]*(1 + phi)
		gtheta[919] = theta[155]
		gtheta[920] = phi*theta[145] + theta[156]*(1 + phi)
		gtheta[921] = phi*theta[146] + theta[157]*(1 + phi)
		gtheta[922] = phi*theta[148] + theta[158]*(1 + phi)
		gtheta[923] = phi*theta[151] + theta[159]*(1 + phi)
		gtheta[924] = phi*theta[155] + theta[160]*(1 + phi)
		gtheta[925] = theta[161]
		gtheta[926] = theta[162]
		gtheta[927] = theta[163]
		gtheta[928] = theta[164]
		gtheta[929] = phi*theta[36] + theta[165]*(1 + phi)
		gtheta[930] = theta[166]
		gtheta[931] = theta[167]
		gtheta[932] = theta[168]
		gtheta[933] = phi*theta[161] + theta[169]*(1 + phi)
		gtheta[934] = theta[170]
		gtheta[935] = theta[171]
		gtheta[936] = phi*theta[162] + theta[172]*(1 + phi)
		gtheta[937] = theta[173]
		gtheta[938] = phi*theta[163] + theta[174]*(1 + phi)
		gtheta[939] = phi*theta[164] + theta[175]*(1 + phi)
		gtheta[940] = theta[176]
		gtheta[941] = theta[177]
		gtheta[942] = phi*theta[166] + theta[178]*(1 + phi)
		gtheta[943] = theta[179]
		gtheta[944] = phi*theta[167] + theta[180]*(1 + phi)
		gtheta[945] = phi*theta[168] + theta[181]*(1 + phi)
		gtheta[946] = theta[182]
		gtheta[947] = phi*theta[170] + theta[183]*(1 + phi)
		gtheta[948] = phi*theta[171] + theta[184]*(1 + phi)
		gtheta[949] = phi*theta[173] + theta[185]*(1 + phi)
		gtheta[950] = theta[186]
		gtheta[951] = phi*theta[176] + theta[187]*(1 + phi)
		gtheta[952] = phi*theta[177] + theta[188]*(1 + phi)
		gtheta[953] = phi*theta[179] + theta[189]*(1 + phi)
		gtheta[954] = phi*theta[182] + theta[190]*(1 + phi)
		gtheta[955] = phi*theta[186] + theta[191]*(1 + phi)
		
	}
	
// --------------------------- END 5 YEAR --------------------------------------
	
//------------------------------------------------------------------------------------------------	
	

end
// ------------------------------------------------------------------

exit

	

