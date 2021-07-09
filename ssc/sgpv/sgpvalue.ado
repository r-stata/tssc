*!Second Generation P-Values Calculations
*!Based on the R-code for sgpvalue.R from the sgpv-package from https://github.com/weltybiostat/sgpv
*!Version 1.02 06.04.2020 : Added another check to prevent using more than one null interval with variables or large matrices as input estlo and esthi, added two more input error checks -> some non-sensical input is still possible. 
*Version 1.01 28.03.2020 : Fixed the nodeltagap-optin -> now it works in all scenarios, previously it was missing in the Mata version and ignored in the variable version of the computing algorithm.	
*Version 1.00 : Initial SSC release, no changes compared to the last Github version.
*Version 0.98a: Fixed an incorrect comparison -> now the correct version of the SGPV algorithm should be chosen if c(matsize) is smaller than the input matrix; added more examples from the original R-code to the help-file.
*				Fixed a bug with the nodeltagap-option.
*				Added more examples from the R-code (as a do-file).
*Version 0.98 : Implement initial handling of infinite values (one sided intervals) -> not 100% correct yet -> treatment of missing values in variables is questionable and might need further thought and changes
*Version 0.95a: Fixed some issues in the documentation.
*Version 0.95 : Added support for using variables as inputs for options esthi() and estlo(); Added Mata function for SGPV calculations in case c(matsize) is smaller than the input vectors; 
*				Added alternative approach to use variables for the calculations instead if variables are the input -> Mata is relatively slow compared to using only variables for calculations.
*Version 0.90  : Initial release to Github 
*Handling of infinite values depends on whether variables or "vectors" are used as input. But it should not matter for calculations.  
*Still missing: Some Input error checks (which ones are missing?)
*To-do: 	At some point rewrite the code to use only Mata for a more compact code -> currently three different versions of the same algorithm are used.
*			Add an option to format the output	



capture program drop sgpvalue
program define sgpvalue, rclass
version 12.0 
syntax,  estlo(string) esthi(string)  nulllo(string) nullhi(string) [nowarnings INFcorrection(real 1e-5) nodeltagap nomata noshow replace ] 

*Parse the input : 
*Check that the inputs are variables -> For the moment only allowed if both esthi and estlo are variables
	if `:word count `esthi''==1{
		capture confirm numeric variable `esthi'
		if !_rc{
			local var_esthi 1
		}
	}

	if `:word count `estlo''==1{
		capture confirm numeric variable `estlo'
		if !_rc{
			local var_estlo 1
		}
	}
	
	if "`var_esthi'" == "1" & "`var_estlo'" =="1"{
		local varsfound 1
	}
	else if "`var_esthi'"!="`var_estlo'" {
		disp as error "Either `esthi' or `estlo' is not a numeric variable. Both options need to be numeric variables if you want to use variables as inputs."
		exit 198
	}
	else if "`var_esthi'"=="" & "`var_estlo'"==""{
		local varsfound 0
	}


**Potential Errors
* Not covered yet -> nullhi and nulllo are equal but less than esthi and estlo -> not sure how to handle it
* Not all non-sensical inputs covered yet -> number of esthi less than nullhi;
if `:word count `nullhi'' != `: word count `nulllo''{
	disp as error `" Options "nullhi" and "nulllo" do not contain the same number of arguments."'
	exit 198
}

if `:word count `esthi'' != `: word count `estlo''{
	disp as error `" Options "esthi" and "estlo" do not contain the same number of arguments. "'
	exit 198
}

if wordcount("`nulllo'") < wordcount("`estlo'") & wordcount("`nulllo'")>1{
	disp as error "Options 'nulllo' and 'nullhi' must only have one argument or exactly as many arguments as options 'esthi' and 'estlo' "
	disp as error "Options 'nulllo' and 'nullhi miss " `=wordcount("`esthi'")-wordcount("`nullhi'")' " number of arguments."
	exit 198
}

if wordcount("`nulllo'") > wordcount("`estlo'"){
	stop "Options 'nulllo' and 'nullhi' cannot have more arguments than options 'esthi' and 'estlo'. "
}

  if `:word count `nulllo''==1 {
   local nulllo = "`nulllo' " * `: word count `estlo''  
   local nullhi = "`nullhi' " * `: word count `esthi'' 
  }

	if `varsfound'{
		local estint =_N
	}
	else{
		local estint : word count `esthi'
	}

*Check if estint is larger than the current matsize
if `estint'>c(matsize){ //Assuming here that this condition is only true if variables used as inputs -> The maximum length of the esthi() and estlo() should not be as large as c(matsize).
	*An alternative based on variables if inputs are variables.
	local nodeltagap `deltagap'
	if "`mata'"=="nomata" & `varsfound'==1{
		local nulllo = real(trim("`nulllo'"))
		local nullhi = real(trim("`nullhi'"))
		if wordcount("`nulllo'") >1 | wordcount("`nullhi'") > 1{
			stop "Only one null interval can be used when using variables as input. Provide only one value in options nulllo() and nullhi()."
		}
		
		sgpv_var ,esthi(`esthi') estlo(`estlo') nulllo(`nulllo') nullhi(`nullhi') `replace' `nodeltagap' infcorrection(`infcorrection')
	}
	else if "`mata'"==""{
		if wordcount("`nulllo'") >1 | wordcount("`nullhi'") > 1{
			stop "Only one null interval can be used when using variables or matrices larger than c(matsize) as input. Provide only one value in options nulllo() and nullhi()."
		}
		mata: sgpv("`estlo' `esthi'", "results", `nulllo', `nullhi', `infcorrection' , "`nodeltagap'") // Only one null interval allowed.
		*The same return as before but this time for the Mata function -> not the best solution yet.

		if `=colsof(results)'==2 mat colnames results = "SGPV" "Delta-Gap"
		if `=colsof(results)'==1 mat colnames results = "SGPV"
		
		if "`show'"!="noshow" matlist results ,names(columns) title(Second Generation P-Values)
		return matrix results = results
		*exit
	}
}
else{	// Run if rows less than matsize -> the "original" approach
	tempname results 
	mat `results' = J(`estint',2,0)	
	mat colnames `results' = "SGPV" "Delta-Gap"
	***Iterate over all intervalls to implement a parallel max and min function as in the R-code
	forvalues i=1/`estint'{
		*Parse interval -> Not the best names yet
		local null_lo = `: word `i' of `nulllo''
			isValid `null_lo'
			isInfinite `null_lo'
			if (`r(infinite)' == `=c(maxdouble)'){
			 local null_lo = `=c(mindouble)'
			} 
		
		local null_hi = `: word `i' of `nullhi''
			isValid `null_hi'
			isInfinite `null_hi'
			local null_hi = `r(infinite)'
		*Only required if no variables as input
		if `varsfound'==0{
		local est_lo = `: word `i' of `estlo''	
			isValid `est_lo'
			isInfinite `est_lo'
			if (`r(infinite)' == `=c(maxdouble)'){
			local est_lo = `=c(mindouble)'
			}
			

		local est_hi = `: word `i' of `esthi''
			isValid `est_hi'
			isInfinite `est_hi'
			local est_hi =`r(infinite)'
		}
		else{
			local est_lo = `estlo'[`i']
			local est_hi = `esthi'[`i']
		}
		*Compute Interval Lengths 
		local est_len = `est_hi' - `est_lo'
		if "`est_len'"==".z_" local est_len = c(maxdouble) // the difference between two infinite is the largest missing value of Stata .z_
		
		local null_len = `null_hi' -`null_lo'
		if "`null_len'" ==".z_" local null_len = c(maxdouble)
		*Warnings -> Make warning messages more descriptive
			if "`warnings'"!="nowarnings"{
				if (`est_len'<0  ) & (`null_len'<0){
					disp "The `i'th interval length is negative. Upper and lower bound of the interval might be switched." 
				}
				*if isinfinite(abs(`est_len')+abs(`null_len')){ disp as error "The `i' th interval has infinite length"} // Not sure how to implement the is.infinite function from R
				if (`est_len'==`=c(maxdouble)') | (`null_len'==`=c(maxdouble)'){ // Needs further corrections for everything close to but not exactly c(maxdouble)
					disp "The `i'th interval has infinite length."
				}
				
				if (`est_len'==0 | `null_len'==0 ) {
					disp "The `i'th interval has a zero length. Consider using an interval hypothesis instead of a point hypothesis."
				}
		}
		
		*SGPV computation--------------------------------------------------
		*Esthi and estlo are vectors
		
			local overlap = min(`est_hi',`null_hi') - max(`est_lo',`null_lo')
			local overlap = max(`overlap',0)
			local bottom =	min(2*`null_len',`est_len')
			local pdelta = `overlap'/`bottom'
		
		
		***** Zero-length & Infinite-length intervals **** 
		** Overwrite NA and NaN due to bottom = Inf
		if `overlap'==0 {
			local pdelta 0
		}
		
		/** Overlap finite & non-zero but bottom = Inf*/
		if `overlap'!=0 & `overlap'!=c(maxdouble) & `bottom'>=(c(maxdouble)/2){
		local pdelta `infcorrection'
		}
	
		** Interval estimate is a point (overlap=zero) but can be in null or equal null pt
		if `est_len'==0 & `null_len'>=0 & `est_lo'>=`null_lo' & `est_hi'<=`null_hi' {
			local pdelta 1
		}
	
		** One-sided intervals with overlap; overlap == Inf & bottom==Inf -> Not correct yet -> works only if overlap and bottom are exact c(maxdouble) -> need a way for slightly smaller values -> used half of c(maxdouble) as the limit
		if `overlap'>=(c(maxdouble)/2) & `bottom'>=(c(maxdouble)/2) &(`est_lo'>=`null_lo' | `est_hi'<=`null_hi'){
			local pdelta 1
		 }
		 
		if `overlap'>=(c(maxdouble)/2) & `bottom'>=(c(maxdouble)/2) &  (`est_lo'<`null_lo' | `est_hi'>`null_hi'){
			local pdelta = 1-`infcorrection'
		 }
		** Interval estimate is entire real line and null interval is NOT entire real line
		if `est_lo'<=-c(maxdouble)/2 & `est_hi'>=c(maxdouble)/2{
			local pdelta 0.5
			}

		** Null interval is entire real line
		if `null_lo'>=-c(maxdouble)/2 & `null_hi'==c(maxdouble)/2{
			local pdelta .
		}
	
		** Null interval is a point (overlap=zero) but is in interval estimate
		if `est_len'>0 & `null_len'==0 & `est_lo'<=`null_lo' & `est_hi'>=`null_hi' {
			local pdelta 0.5
		}

		
		** Return Missing value for nonsense intervals
		if `est_lo'>`est_hi' | `null_lo'>`null_hi'{
			local pdelta .
			if "`warnings'"!="nowarnings" disp "The `i'th interval limits are likely reversed."
		}
		
		
		** Calculate delta-gap
		if "`deltagap'"!="nodeltagap"{
			local gap = max(`est_lo', `null_lo') - min(`null_hi', `est_hi')
			local delta = `null_len'/2
			* Report unscaled delta-gap if null has infinite length
			if `null_len' ==0{
				local delta 1
			}
			
			if `pdelta'==0 {
				local dg = `gap'/`delta' 
			}
			else{
				local dg .
			}
		}
		*Write results
		mat `results'[`i',1] = `pdelta'
		if "`deltagap'"!="nodeltagap" mat `results'[`i',2] = `dg'
		
	}
		*Process nodelta-option
	if "`deltagap'"=="nodeltagap"{
	mat `results'=`results'[1...,1]
	} 
	matlist `results' ,names(columns) title(Second Generation P-Values)
	return matrix results = `results'
}	 
end 


*Additional commands ----------------------------------------------------------------------------------------------
*Check if the input is valid
program define isValid
args valid
if `valid'!=.  & real("`valid'")==.{
	disp as error "`valid'  is not a number nor . (missing value) nor empty."
	exit 198
		}
		
end

*Check if input is infinite
program define isInfinite, rclass
args infinite
	if `infinite'==.{
		return local infinite = c(maxdouble) // Using c(maxdouble) as a proxy for a true infinite value
	}
	else{
		return local infinite = `infinite'
	}
end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end

*Use new variables to store and calculate the SGPVs
program define sgpv_var, rclass
 syntax ,esthi(varname) estlo(varname) nullhi(string) nulllo(string) [replace nodeltagap infcorrection(real 1e-5)]
 if "`replace'"=="replace"{
	capture drop pdelta
	capture drop dg
 }
 else{
	capture confirm variable pdelta dg
		if !_rc{
			disp as error "Specifiy the replace option: variables pdelta and dg already exist."
			exit 198
		}
 }
 
 tempvar estlen nulllen overlap bottom null_hi null_lo gap delta gapmax gapmin overlapmin overlapmax
 local type : type `esthi' // Assuming that both input variables have the same type -> will add an additional check if this assumption turns out to be wrong in too many cases and if the results change to a degree that it matters.
 quietly{ //Set variable type to the same precision as input variables -> cannot deal yet with missing values correctly 
		gen `type'	`null_hi' 	 = real("`nullhi'")
		gen `type' `null_lo' 	 = real("`nulllo'")			
 		gen `type' `estlen' 	 = `esthi' - `estlo'
		gen `type' `nulllen' 	 = `null_hi' -`null_lo'
		egen `type' `overlapmin' = rowmin(`esthi' `null_hi') 
		egen `type' `overlapmax' = rowmax(`estlo' `null_lo')
		gen `type' `overlap' 	 = `overlapmin' - `overlapmax'
		replace `overlap' 		 = max(`overlap',0)
		gen `type' `bottom' 	 =	min(2*`nulllen',`estlen')
		gen `type' pdelta		 = `overlap'/`bottom'
		
		replace pdelta = 0 if `overlap'==0 
		replace pdelta = `infcorrection' if `overlap'!=0 & `overlap'!=. & `bottom'==.	
		replace pdelta = 1 if (`estlen'==0 & `nulllen'>=0 & `estlo'>=`null_lo' & `esthi'<=`null_hi')
		replace pdelta = 1 if `overlap'==. & `bottom'==. & (`estlo'>=`null_lo' | `esthi'<=`null_hi')
		replace pdelta = 1-`infcorrection' if `overlap'==. & `bottom'==. &  (`estlo'<`null_lo' | `esthi'>`null_hi')
		replace pdelta = 0.5 if `estlo'==. & `esthi'==.
		replace pdelta = . if `null_lo'==. & `null_hi'==.
		replace pdelta = 0.5 if (`estlen'>0 & `nulllen'==0 & `estlo'<=`null_lo' & `esthi'>=`null_hi')
		replace pdelta =. if (`estlo'>`esthi' | `null_lo'>`null_hi')
		/* Calculate delta-gap*/
		egen `type'	`gapmax' = rowmax(`estlo' `null_lo') 
		egen `type' `gapmin' = rowmin(`null_hi' `esthi')
		gen `type'	`gap' = `gapmax' - `gapmin'
		 
		 if "`deltagap'"!="nodeltagap"{
			 gen `type' `delta' = `nulllen'/2
			 replace `delta' = 1 if `nulllen'==0
			 gen `type' dg = .
			 replace dg = `gap'/`delta'  if (pdelta==0 & pdelta!=.)
			 label variable dg "Delta-Gap"
		}
		*Label variables
		label variable pdelta "SGPV"
		
		}
 
 exit 
end

***Mata function(s)
mata:
version 12.0
void function sgpv(string varlist, string scalar sgpvmat, real scalar nulllo, real scalar nullhi, real scalar infcorrection ,| string scalar nodeltagap){ 
// void function sgpv(string varlist, string scalar sgpvmat, real rowvector nulllo, real scalar rowvector, real scalar infcorrection ,| string scalar nodeltagap){ 

/*Allow only one null interval for now*/
/*Calculate the SGPVs and Delta-Gaps if the desired matrix size is too large for Stata
Might have to change the way missing values are handled -> For now they are treated as meaning infinite.
*/
	real matrix Sgpv
	V = st_varindex(tokens(varlist))
    Data = J(1,1,0)
    st_view(Data,.,V)
	Sgpv = J(rows(Data),2,.)	
	null_len = nullhi - nulllo
	n = rows(Data) // new for optimisation
	//for(i=1; i<=rows(Data);i++) {
	for(i=1; i<=n;i++) {
		 est_lo = Data[i,1]
		 est_hi = Data[i,2]
		 est_len = est_hi - est_lo
		 overlap = min_s(est_hi,nullhi) - max_s(est_lo,nulllo) 
		 overlap = max_s(overlap,0) 
		 bottom = min_s(2*null_len, est_len) 
		 pdelta = overlap/bottom
		 if (overlap==0) {
			pdelta = 0
			}
			
		if (overlap!=0 & overlap!=. & bottom==.){
		 pdelta = infcorrection
		}	
		
		if (est_len==0 & null_len>=0 & est_lo>=nulllo & est_hi<=nullhi) {
			 pdelta = 1
		}
		if (overlap==. & bottom==. & (est_lo>=nulllo | est_hi<=nullhi)){
			 pdelta = 1
		 }
		 if (overlap==. & bottom==. &  (est_lo<nulllo | est_hi>nullhi)){
			 pdelta = 1-infcorrection
		 }
		if (est_lo==. & est_hi==.){
			 pdelta = 0.5
			}

		if (nulllo==. & nullhi==.){
			 pdelta = .
		}
		 
		if (est_len>0 & null_len==0 & est_lo<=nulllo & est_hi>=nullhi) {
			 pdelta = 0.5
		}
		if (est_lo>est_hi | nulllo>nullhi){
			pdelta = .			
		}
		/*Delta-Gap*/
		if (nodeltagap!="nodeltagap"){
			 gap = max_s(est_lo,nulllo) - min_s(nullhi,est_hi) 
			 delta = null_len/2
			if (null_len ==0){
				 delta = 1
			}
			if (pdelta==0 & pdelta!=.){
				 dg = gap/delta 
			}
			else{
				 dg = .
			}
			Sgpv[i,2] = dg
		}
		
		 Sgpv[i,1] = pdelta
		 
	}	
	st_matrix(sgpvmat,Sgpv)
}

//Two convenience functions to make reading the code easier: Function names chosen to not conflict with internal Mata functions
real scalar function min_s(real scalar x, real scalar y){
	return(x > y ? y :x)
}

real scalar function max_s(real scalar x, real scalar y){
	return(x>y?x:y)
}

end
