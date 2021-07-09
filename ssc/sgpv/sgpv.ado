*! A wrapper program for calculating the Second-Generation P-Values and their associated diagnosis based on Blume et al. 2018,2019
*!Author: Sven-Kristjan Bormann
*!Version 1.03a 17.05.2020 : Made the title of the displayed matrix adapt to the type of null-hypothesis; fixed a wrong file name in the sgpv-leukemia-example.do -> should now load the dataset; minor improvements in the example section of the help file ; added a new example showing how to apply a different null-hypothesis for each coefficient; added an example how to export results by using estout from Ben Jann
*!Version 1.03 14.05.2020 : added better visible warnings against using the default point 0 null-hypothesis after the displayed results -> warnings can be disabled by an option; added some more warnings in the description of the options 
*!				Fixed: the Fdr's are now displayed when using the bonus-option with the values "fdrisk" or "all"
*Version 1.02 03.05.2020 : Changed name of option 'perm' to 'permanent' to be inline with Standard Stata names of options; ///
				removed some inconsistencies between help file and command file (missing abbreviation of pi0-option, format-option was already documented); ///
				removed old dead code; enforced and fixed the exclusivity of 'matrix', 'estimate' and prefix-command -> take precedence over replaying ; ///
				shortened subcommand menuInstall to menu;  ///
				added parsing of subcommands as a convenience feature ///
				allow now more flexible parsing of coefficient names -> make it easier to select coefficients for the same variable across different equations -> only the coefficient name is now required not the equation name anymore -> implemented what is "promised" by the dialog box text ///
				changed the default behaviour of the bonus option from nobonus to bonus -> bonus statistics only shown when requested		
*Version 1.00 : Initial SSC release, no changes compared to the last Github version.
*Version 0.99 : Removed automatic calculation of Fcr -> setting the correct interval boundaries of option altspace() not possible automatically
*Version 0.98a: Displays now the full name of a variable in case of multi equation commands. Shortened the displayed result and added a format option -> get s overriden by the same named option of matlistopt(); Do not calculate any more results for coefficients in r(table) with missing p-value -> previously only checked for missing standard error which is sometimes not enough, e.g. in case of heckman estimation. 
*Version 0.98 : Added a subcommand to install the dialog boxes to the User's menubar. Fixed an incorrect references to the leukemia example in the help file.
*Version 0.97 : Further sanity checks of the input to avoid conflict between different options, added possibility to install dialog box into the User menubar.
*Version 0.96 : Added an example how to calculate all statistics for the leukemia dataset; minor fixes in the documentation of all commands and better handling of the matrix option.
*Version 0.95 : Fixed minor mistakes in the documentation, added more information about SGPVs and more example use cases; minor bugfixes; changed the way the results are presented
*Version 0.90 : Initial Github release

/*
To-Do(Things that I wish to implement at some point or that I think that might be interesting to have:)
	Internal changes (Mostly re-organising the code for shorter and easier maintained code):
	- Shorten parts of the code by using the cond()-function instead if ... else if ... constructs.
	- Change input type of options nulllo and nullhi from 'real' to 'string' to allow the same flexibility like the other commands -> allow a different null-hypothesis for each coefficient -> requires changes for the fdrisk option-parsing/generation & additional checks to avoid non-sensical input.
	- Write a certification script which checks all possible errors (help cscript)
	- change the help file generation from makehlp to markdoc for more control over the layout of the help files -> currently requires a lot of manual tuning to get desired results.
	
	External changes (Mostly more features):
	- Add support for multiple null-hypotheses -> allow a different null-hypothesis for each coefficient
	- Consider dropping the default value for the null-hypothesis and require an explicit setting to the null-hypothesis
	- Make error messages more descriptive and give hints how to resolve the problems. (somewhat done hopefully)
	- support for more commands which do not report their results in a matrix named "r(table)". (Which would be the relevant commands?)
	- Make matrix parsing more flexible and rely on the names of the rows for identifiying the necessary numbers; allow calculations for more than one stored estimate
	- Return more infos (Which infos are needed for further processing?)
	- Allow plotting of the resulting SGPVs against the normal p-values directly after the calculations -> use user-provided command plotmatrix instead?	
	- improve the speed of fdrisk.ado -> the integration part takes too long. -> switch over to Mata integration functions provided by moremata-package
	- add an immidiate version of sgpvalue similar like ttesti-command; allow two sample t-test equivalent -> currently the required numbers need be calculated or extracted from these commands.
*/

capture program drop sgpv
program define sgpv, rclass
version 12.0
*Parse the initial input 
capture  _on_colon_parse `0'


*Check if anything to calculate is given
if _rc & "`e(cmd)'"=="" & (!ustrregexm(`"`0'"',"matrix\(\w+\)") & !ustrregexm(`"`0'"',"m\(\w+\)") ) & (!ustrregexm(`"`0'"',"estimate\(\w+\)") & !ustrregexm(`"`0'"',"e\(\w+\)") ) & !inlist("`: word 1 of `0''","value","power","fdrisk","plot", "menu" ) { // If the command was not prefixed and no previous estimation exists. -> There should be a more elegant solution to this problem 
	disp as error "No last estimate or matrix, saved estimate for calculating SGPV found."
	disp as error "No subcommand found either."
	disp as error "Make sure that the matrix option is correctly specified as 'matrix(matrixname)' or 'm(matrixname)' . "
	disp as error "Make sure that the estimate option is correctly specified as 'estimate(stored estimate name)' or 'e(stored estimate name)' . "
	disp as error "The currently available subcommands are 'value', 'power', 'fdrisk', 'plot' and 'menu'."
	exit 198
}


if !_rc{
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"' 
} 

***Parsing of subcommands -> A convenience feature to use only one command for SGPV calculation -> no further input checks of acceptable options
* Potential subcommands: value, power, fdrisk, plot, menu
local old_0 `0'
gettoken subcmd 0:0, parse(" ,:")
if inlist("`subcmd'","value","power","fdrisk","plot", "menu" ){ // Change the code to allow shorter subcommand names? Look at the code for estpost.ado for one way how to do it
	*if !inlist("`subcmd'","value","power","fdrisk","plot", "menu" ) stop "Unknown subcommand `subcmd'. Allowed subcommands are value, power, fdrisk, plot and menu."
	if "`cmd'"!="" stop "Subcommands cannot be used when prefixing an estimation command."

	if ("`subcmd'"=="value"){
		local subcmd : subinstr local subcmd "`=substr("`subcmd'",1,1)'" "sgpv"
	} 
	if ("`subcmd'"=="power"){
		local subcmd : subinstr local subcmd "`=substr("`subcmd'",1,1)'" "sgp"
	} 
	if ("`subcmd'"=="plot"){
		local subcmd `subcmd'sgpv
	} 
	`subcmd' `0'
	exit	
	
}
else{
	local 0 `old_0'
}


**Define here options
syntax [anything(name=subcmd)] [,   Estimate(name)  Matrix(name)  Coefficient(string asis) /// input-options
 Quietly MATListopt(string asis) Bonus(string) FORmat(str) NONULLwarnings   /// display-options
 nulllo(real 0) nullhi(real 0) /// null-hypotheses
 ALTWeights(string) ALTSpace(string asis) NULLSpace(string asis) NULLWeights(string) INTLevel(string) INTType(string) Pi0(real 0.5) /// fdrisk-options
    debug  /*Display additional debug messages: undocumented*/  ] 


***Option parsing
if "`cmd'"!="" & ("`estimate'"!="" | "`matrix'"!=""){
	disp as error "Options 'matrix' and 'estimate' cannot be used in combination with a new estimation command."
	exit 198
} 
else if "`estimate'"!="" & "`matrix'"!=""{
	stop "Setting both options 'estimate' and 'matrix' is not allowed."
} 

	*Saved Estimation
	if "`estimate'"!=""{
		qui estimates dir
		if regexm("`r(names)'","`estimate'"){
		qui estimates restore `estimate'
		}
		else{
			disp as error "No saved estimation result with the name `estimate' found."
			exit 198
		}
	}


	*Arbitrary matrix 
	if "`matrix'"!=""{
		capture confirm matrix `matrix'
		if _rc{
			disp as error "Matrix `matrix' does not exist."
			exit 198
		}
		else{ 
		  //Initial check if rows are correctly named as a crude check that the rows contain the expected numbers
		   local matrown : rownames `matrix'
			if "`:word 1 of `matrown''"!="b" | "`:word 2 of `matrown''"!="se" | "`:word 4 of `matrown''"!="pvalue" | "`:word 5 of `matrown''"!="ll" | "`:word 6 of `matrown''" !="ul"{
			stop "The matrix `matrix' does not have the required format. See the {help sgpv##matrix_opt:help file} for the required format and make sure that the rows of the matrix are labelled correctly."
			}
			local inputmatrix `matrix'
	  }
	}
	*Add here code to catch input errors when allowing multiple null-hypotheses

	
	**Process fdrisk options -> needs changes to allow multiple null intervals
	if `nulllo' ==. stop "No missing value for option 'nulllo' allowed. One-sided intervals are not yet supported."
	if `nullhi' ==. stop "No missing value for option 'nullhi' allowed. One-sided intervals are not yet supported."
	
	*Nullspace option
	if "`nullspace'"!=""{
		local nullspace `nullspace'
	}
	else if "`nullhi'"!= "`nulllo'"{
		local nullspace `nulllo' `nullhi'
	}
	else if "`nullhi'"== "`nulllo'"{
		local nullspace `nulllo'
	}
	*Intlevel
	if "`intlevel'"!=""{
		local intlevel = `intlevel'
	}
	else{
		local intlevel 0.05
	}
	
	*Inttype
	if "`inttype'"!="" & inlist("`inttype'", "confidence","likelihood"){
		local inttype `inttype'
	}
	else if "`inttype'"!="" & !inlist("`inttype'", "confidence","likelihood"){
		stop "Parameter intervaltype must be one of the following: confidence or likelihood "
	}
	else{
		local inttype "confidence"
	}

	*Nullweights
	if "`nullweights'"!=""  {
		local nullweights `nullweights'
	}
	else if  "`nullweights'"=="" & "`nullspace'"=="`nulllo'"{
		local nullweights "Point"
	}
	else if "`nullweights'"=="" & `:word count `nullspace''==2{ //Assuming that Uniform is good default nullweights for a nullspace with two values -> TruncNormal will be chosen only if explicitly set.
		local nullweights "Uniform" 
	} 
	
	*Altweights
	if "`altweights'"!="" & inlist("`altweights'", "Uniform", "TruncNormal"){
		local altweights `altweights'
	}
	else{
		local altweights "Uniform"
	}
	
	*Pi0
	if !(`pi0'>0 & `pi0'<1){
		stop "Values for pi0 need to lie within the exclusive 0 - 1 interval. A prior probability outside of this interval is not sensible. The default value assumes that both hypotheses are equally likely."
	}
	
	
**Parse bonus option
*Changed the default behaviour so that the option is now a bit confusing
if !inlist("`bonus'","deltagap","fdrisk","all","none",""){
	stop `"bonus option incorrectly specified. It takes only values `"none"', `"deltagap"', `"fdrisk"' or `"all"'. "'
}
if "`bonus'"=="" | "`bonus'"=="none"{ 	
	local nodeltagap nodeltagap
	local fdrisk_stat 
}

if "`bonus'"=="deltagap"{
	local nodeltagap 
	}
	
if "`bonus'"=="fdrisk"{
	local fdrisk_stat fdrisk
}

if "`bonus'"=="all"{
	local fdrisk_stat fdrisk
	local nodeltagap 
}

*Assuming that any estimation command will report a matrix named "r(table)" and a macro named "e(cmd)"
if "`cmd'"!=""{
 `quietly'	`cmd'
}
else if "`e(cmd)'"!=""{ // Replay previous estimation
 `quietly'	`e(cmd)'
}
 
 
 
* disp "Start calculating SGPV"
 *Create input vectors
  tempname input  input_new sgpv pval comp rest fdrisk 
 
 *Set the required input matrix
 if "`matrix'"==""{
  capture confirm matrix r(table) //Check if required matrix was returned by estimation command
	 if _rc{
		disp as error "`e(cmd)' did not return required matrix r(table)."
		exit 198
	 }
	local inputmatrix r(table)
 }
 
 ***Input processing
 mat `input' = `inputmatrix'
 return add // save existing returned results 
 
 *Coefficient selection 
 ParseCoef `input', coefficient(`coefficient')
 mat `input' = r(coef_mat)
 local coln =colsof(`input')

* Hard coded values for the rows from which necessary numbers are extracted
*The rows could be addressed by name, but then at least Stata 14 returns a matrix
* which requires additional steps to come to the same results as with hardcoded row numbers. Unless some one complains, I won't change this restriction.
*The macros for esthi and estlo could be become too large, will fix/rewrite the logic if needed 
*Removing not estimated coefficients from the input matrix
 forvalues i=1/`coln'{
	 if !mi(`:disp `input'[2,`i']') & !mi(`:disp `input'[4,`i']') { // Check here if the standard error or the p-value is missing and treat it is as indication for a variable to omit.
		local esthi `esthi' `:disp `input'[6,`i']'
		local estlo `estlo' `:disp `input'[5,`i']'
		mat `pval' =(nullmat(`pval')\\`input'[4,`i'])
		mat `input_new' = (nullmat(`input_new'), `input'[1..6,`i']) //Get new input matrix with only the elements for which results will be calculated

	 }
 }
  local rownames : colfullnames `input_new' //Save the variable names for later display

*Needs modifications to allow multiple null-hypotheses 
*Add here code to match coefficients with their assigned null-hypothesis in case of multiple null-hypotheses
qui sgpvalue, esthi(`esthi') estlo(`estlo') nullhi(`nullhi') nulllo(`nulllo') nowarnings `nodeltagap' 
if "`debug'"=="debug" disp "Finished SGPV calculations. Starting now bonus Fdr calculations."


mat `comp'=r(results)
return add
 mat colnames `pval' = "P-Value"


if "`fdrisk_stat'"=="fdrisk"{
*False discovery risks 	-> needs changes to allow multiple null intervals
	mat `fdrisk' = J(`:word count `rownames'',1,.)
	mat colnames  `fdrisk' = Fdr
	forvalues i=1/`:word count `rownames''{
		if `=`comp'[`i',1]'==0{
			qui fdrisk, nullhi(`nullhi') nulllo(`nulllo') stderr(`=`input_new'[2,`i']') inttype(`inttype') intlevel(`intlevel') nullspace(`nullspace') 	nullweights(`nullweights') altspace(`=`input_new'[5,`i']' `=`input_new'[6,`i']') altweights(`altweights') sgpval(`=`comp'[`i',1]') pi0(`pi0')
			*qui fdrisk, nullhi(`=word("`nullhi'",`i')') nulllo(`=word("`nulllo'",`i')') stderr(`=`input_new'[2,`i']') inttype(`inttype') intlevel(`intlevel') nullspace(`=word("`nulllo'",`i')' `=word("`nullhi'",`i')') 	nullweights(`nullweights') altspace(`=`input_new'[5,`i']' `=`input_new'[6,`i']') altweights(`altweights') sgpval(`=`comp'[`i',1]') pi0(`pi0') 
			
			
			capture confirm scalar r(fdr)
			if !_rc mat `fdrisk'[`i',1] = r(fdr)
				
		}
	}
}

*Final matrix composition before displaying results
if "`fdrisk_stat'"=="fdrisk"{
	mat `comp'= `pval',`comp' , `fdrisk'
}
else{
	mat `comp'= `pval',`comp'
}
 mat rownames `comp' = `rownames'

*Change the format of the displayed matrix
FormatDisplay `comp', format(`format')
*Display the results and adjust the title based on the null-hypothesis
local interval_name = cond(`nullhi'==`nulllo',"point","interval")
local null_interval = cond(`nullhi'==`nulllo',"`nullhi'","{`nulllo',`nullhi'}")
 matlist r(display_mat) , title(`"Comparison of ordinary P-Values and Second Generation P-Values for a`=cond(substr("`interval_name'",1,1)=="p","","n")'  `interval_name' Null-Hypothesis of `null_interval' "') rowtitle(Variables) `matlistopt'

if "`nonullwarnings'"=="" & (`nulllo'==0 & `nullhi'==0){
	disp _n "Warning:"
	disp "You used the default point 0 null-hypothesis for calculating the SGPVs."
	disp "This is allowed but you are strongly encouraged to set a more reasonable interval null-hypothesis."
	disp "The default point 0 null-hypothesis will result in having SGPVs of either 0 or 0.5."	
}

return add
*Return results
return matrix comparison =  `comp'

end


*Additional helper commands--------------------------------------------------------------
*Re-format the input matrix and return a new matrix to circumvent the limitations set by matlist -> using the cspec and rspec options of matlist requires more code to get these options automatically correct -> for now probably not worth the effort.
*Use round-function instead? Should result in easier and shorter code
program define FormatDisplay, rclass
syntax name(name=matrix) [, format(string)]
	if `"`format'"'==""{
		local format %5.4f
		} 
	else {
			capture local junk : display `format' 1
			if _rc {
					dis as err "Invalid %format `format'"
					dis in smcl as err "See the help file for {help format} for more information."
					exit 120
			}
		}
tempname display_mat
local display_mat_coln : colfullnames `matrix'
local display_mat_rown : rowfullnames `matrix'
mat `display_mat'=J(`=rowsof(`matrix')',`=colsof(`matrix')',.)
forvalues i=1/`=rowsof(`matrix')'{
	forvalues j=1/`=colsof(`matrix')'{
		mat `display_mat'[`i',`j']= `: display `format' `matrix'[`i',`j']'
	}

}
mat colnames `display_mat' = `display_mat_coln'
mat rownames `display_mat' = `display_mat_rown'

return matrix display_mat = `display_mat' 

end


*Parse the content of the coefficient-option
program define ParseCoef, rclass
	syntax name(name=matrix) [, coefficient(string asis)]
	if "`coefficient'"==""{
		return matrix coef_mat = `matrix'
		exit
	}
	
 /* Distinguish three cases:	1. variable name only
								2. equation name only
								3. equation and variable name together
 
 */
 * No mixtures of cases allowed yet
 foreach coef of local coefficient{
	*Case 1
	if !ustrregexm("`coef'",":") & !ustrregexm("`coef'",":$"){
		local coefspec `coefspec' `coef'	
	}
	*Case 2
	if ustrregexm("`coef'",":$"){
		local eqspec `eqspec' `coef'	
	} 
	*Case 3
	if ustrregexm("`coef'",":") & !ustrregexm("`coef'",":$"){	
		local eqcoefspec `eqcoefspec' `coef'		
	}
 }
 
 if (wordcount("`eqcoefspec'")>0 & wordcount("`eqspec'")>0) | (wordcount("`eqcoefspec'")>0 & wordcount("`coefspec'")>0) | (wordcount("`eqspec'")>0 & wordcount("`coefspec'")>0){ 
	stop "You can only specify equation-specific ('XX:YYY'), equations ('XX:') or general coefficients('YYY') in option 'coefficient' at the same time."
 }
 if (wordcount("`eqcoefspec'")>0 | wordcount("`eqspec'")>0) local coleqnumb 0
 

	if wordcount("`coefficient'")==wordcount("`coefspec'"){ // looking for the equations only needed if case 1
		local coleq : coleq `matrix'
		local coleq : list uniq coleq
		if "`coleq'"=="_" local coleqnumb 0
		else local coleqnumb = wordcount("`coleq'")
	}
	
	local coefnumb : word count `coefficient'
	tempname coef_mat
	if `coleqnumb'==0{ // No equations found or only fully specified coefficient names given (eq:var) Case 3 & Case 2 (eq:)
		forvalues i=1/`coefnumb'{
			capture mat `coef_mat' = (nullmat(`coef_mat'), `matrix'[1...,"`: word `i' of `coefficient''"])
			if _rc{
				stop "Coefficient `:word `i' of `coefficient'' not found or incorrectly written."
			}
		}
	}
	else if `coleqnumb'>0{ // Separate equations found and only general variables given Case 1
		forvalues j=1/`coleqnumb'{
			forvalues i=1/`coefnumb'{
			capture mat `coef_mat' = (nullmat(`coef_mat'), `matrix'[1...,"`:word `j' of `coleq'':`: word `i' of `coefficient''"])
				if _rc{
					stop "Coefficient `:word `i' of `coefficient'' not found or incorrectly written."
				}
			}
		}
	
	}
	
	return mat coef_mat=`coef_mat'
	
end

*Simulate the behaviour of the R-function with the same name 
program define stop
 args text 
 disp as error `"`text'"'
 exit 198
end

*Make the dialog boxes accessible from the User-menu
program define menu
 syntax [, PERMament] 
 if "`permament'"=="permament"{
		capture findfile profile.do, path(STATA;.)
		if _rc{
			local replace replace
			disp "profile.do not found."
			disp "profile.do will be created in the current folder."
			local profile profile.do
		}
		else{
			local replace append
			local profile `"`r(fn)'"'
			disp "Append your existing profile.do"
		}
	 
	 tempname fh
	 file open `fh' using `profile' , write text `replace'
	 
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV (Main Command) (&sgpv)" "db sgpv" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Value Calculations (&sgpvalue)" "db sgpvalue" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Power Calculations (&sgpower)" "db sgpower" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" "' _n
	 file write `fh' `"  window menu append item "stUserStatistics" "SGPV Plot Interval Estimates (&plotsgpv)" "db plotsgpv" "' _n
	 file write `fh' `" window menu refresh "' _n
	 file close `fh'

 
 }
	window menu clear // Assuming that no one else installs dialog boxes into the menubar. If this assumption is wrong then the code will be changed.
	window menu append submenu "stUserStatistics"  "SGPV"
	window menu append item "SGPV" "SGPV (Main command) (&sgpv)" "db sgpv" 
	window menu append item "SGPV" "SGPV Value Calculations (sgp&value)" "db sgpvalue"
	window menu append item "SGPV" "SGPV Power Calculations (sg&power)" "db sgpower" 
	window menu append item "SGPV" "False Confirmation/Discovery Risk (&fdrisk)" "db fdrisk" 
	window menu append item "SGPV" "SGPV Plot Interval Estimates (p&lotsgpv)" "db plotsgpv"

	window menu refresh
	
end
