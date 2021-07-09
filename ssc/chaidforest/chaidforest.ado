*! chaidforest - version 2.0 - 9/28/2015 - Joseph N. Luchman

program define chaidforest, eclass																//CHAID-based random forest - program history and notes at end of file

version 12.1

syntax varlist [fw] [if] [in], [NTree(integer 100) NVuse(integer -1) ORDered(varlist) ///
UNOrdered(varlist) DVOrdered Alpha(real .5) MINSplit(integer 0) MINNode(integer 0) ///
NOIsily PROos(real -1) XTile(string) noSamp MISSing]

local full_cmdline "`0'"																		//save the contents of the cmdline for ereturn-ing later

/*exit and warning conditions*/
if (`:list sizeof unordered' == 0) & (`:list sizeof ordered' == 0) & ///
(`:list sizeof xtile' == 0) {																	//exit if no splitting variables are entered

	display "{err}No splitting variables entered."
	
	exit 111
	
}

if `minsplit' < `minnode' {																		//exit if you tell chaidforest that the minimum node/cluster size is larger than the minimum sample size to make a split - which is an infeasible situation for clustering

	display "{err}{opt minsplit()} cannot be smaller than {opt minnode()}."

	exit 198
	
}

if (`alpha' <= 0) | (`alpha' >= 1) {															//ensure that the alpha probabilities are in the possible range of 0-1

	display "{err}{opt alpha()} must range betweeen (but not include) 0 and 1."
	
	exit 198

} 

if `minnode' < 0  {																				//ensure that minimum node/cluster size is a non-negative integer (i.e., a possible sample size)

	display "{err}{opt minnode()} must be a non-negative integer value."
	
	exit 198

}

capture which lmoremata.mlib																	//is moremata present? - chaidforest needs moremata

if _rc != 0 {																					//if moremata cannot be found, tell user to install it

	display "{err}Module {cmd:moremata} not found.  Install {cmd:moremata} here " ///
	"{stata ssc install moremata}."
	
	exit 198

}

/*begin data processing*/
tempvar keep touse stop cluster useob 															//tempvar declarations - begin using "touse"; add "keep" markout variables in unordered() and ordered()

tempname cellcount fit nvars N_tree obs															//tempname declaration for matrices

quietly generate byte `keep' = 1 `if' `in'														//allows keeping of missings as valid category, but still adjusting estimation sample for "if"s and "in"s

if strlen("`xtile'") {																			//parse and check xtile

	gettoken xtile xtile_opt: xtile, parse(",")													//separate out the "to xtile" varlist from the options to pass to xtile

	quietly summarize `xtile'																	//summarize the xtile varlist - if it can't be summarized, then its not a variable
		
}	
		
mark `touse'																					//mark estimation sample

if strlen("`missing'") markout `touse' `keep'													//if missing invoked only markout "if" and "in"...

else markout `touse' `varlist' `unordered' `ordered' `keep' `xtile'								//...otherwise markout "if", "in", and missing values

if strlen("`xtile'") {																			//implement convenience option for creating binned continuous predictors in chaidforest and adding to "ordered" list

	foreach var of varlist `xtile' {															//loop through all the variables in the xtile list...								

		capture inspect xt`var'																	//...see if a variable with the name "xt`varname'" already exists...
	
		if !_rc quietly drop xt`var'															//...if it does, drop the variable "xt`varname'" - users are warned of this behavior in the help file

		quietly xtile xt`var' = `var' if `touse' [`weight'`exp'] `xtile_opt'					//conduct the xtile with options as applicable - with estimation sample
							
		local ordered "`ordered' xt`var'"														//add the xtile'd variable to the ordered list

	}
	
}

quietly inspect `varlist'																		//inspect response variable to obtain values that are 0 and positive (if they don't equal the total - something's negative and that's not allowed)
	
if r(N) != (r(N_0) + r(N_posint)) {																//chaidforest doesn't work with non-negarive integers - disallow them using the results from the "inspect" command
	
	display "{err}Levels of response variable must be non-negative integer valued."
		
	exit 198
	
}

quietly levelsof `varlist' if `touse', local(dvlevs) `missing'									//obtain levels of response variable

if regexm("`dvlevs'", "\.") mata: st_local("dvlevs_count", ///									//removes multiple missings from consideration in the levels count for response
invtokens((select(tokens(st_local("dvlevs")), ///
editmissing(strtoreal(tokens(st_local("dvlevs"))), .):!=.), ".")))

if `:list sizeof dvlevs_count' > 20 {															//if there are too many levels of the response variable...
	
	display "{err}Number of distinct values in {cmd:`varlist'} is larger than allowed. " ///
	_newline "Consider collapsing across similar categories for unordered or using " ///
	_newline "{opt xtile()} option/command for ordered variables to reduce the number of " ///
	"levels."
		
		exit 198
	
}
		
local dvlist "`varlist'"																		//produce a local macro that is updated with tempvar names for use in Mata

local dvdisp "`varlist'"																		//produce a local macro that is updated with displayed names of response variable
	
local type "`type' d"																			//note type of variable for response variable - type is "d" for "dependent"

if `:list sizeof unordered' > 0 {																//process unordered splitting variables when present just as was done with the response variable above...

	foreach var of varlist `unordered' {														//macros created for parsing and different puropses - unordered

		quietly inspect `var'																	//inspect unordered splitting variable to obtain values that are 0 and positive (if they don't equal the total - something's negative and that's not allowed)
	
		if r(N) != (r(N_0) + r(N_posint)) {														//chaidforest doesn't work with non-negarive integers - disallow them using the results from the "inspect" command
	
			display "{err}Levels of each splitting variable must be non-negative integer " ///
			"valued.  Variable {cmd:`var'} has non-negative integer values."
		
			exit 198
	
		}
	
		quietly levelsof `var' if `touse', local(`var'levs) `missing'							//obtain levels of unordered splitting variable
		
		if regexm("``var'levs'", "\.") mata: st_local("`var'levs_count", ///					//removes multiple missings from consideration in the levels count for unordered splitting variable
		invtokens((select(tokens(st_local("`var'levs")), ///
		editmissing(strtoreal(tokens(st_local("`var'levs"))), .):!=.), ".")))
		
		if `:list sizeof `var'levs_count' > 20 {
	
			display "{err}Number of distinct values in {cmd:`var'} is larger than " ///
			"allowed." _newline "Consider collapsing across similar categories for " ///
			"unordered or using " _newline "{opt xtile()} option/command for ordered " ///
			"variables to reduce the number of levels."
		
			exit 198
	
		}
		
		foreach val of numlist ``var'levs' {													//for each level of splitters, register binary variable...
		
			if `:list posof "`val'" in `var'levs' == 1 {										//leading text for locals to be fed to chaidforest()...				
			
				local type "`type' ("													
				
				local unorddisp "`unorddisp' ("
				
				local unorderedlist "`unorderedlist' ("
			
			}
		
			if !missing(`val') {																//...if not a missing value...
			
				tempvar `var'`val'																//create tempvars with name of level of unordered, binary variable
				
				quietly generate byte ``var'`val'' = `var' == `val'								//generate binaries for each level of unordered variable
	
				local unorderedlist "`unorderedlist' ``var'`val''"								//include name of unordered binary variable in list of tempvar names
			
				local unorddisp "`unorddisp' `var'_`val'"										//include displayed name of unordered binary variable in list of tempvar names
			
				local type "`type' u"															//include variable type in type macro
	
			} 

			else {																				//...if any kind of missing value...
			
				mata: st_local("miss_name", strofreal(st_isname("``var'ms'")))					//determine if the missing binary variable is already present
				
				if !`miss_name' {																//if the missing binary variable is not found...
				
					tempvar `var'ms																//create tempvar for unordered varible indicating missing
				
					quietly generate byte ``var'ms' = `var' == `val'							//generate indicator for missing category
							
					local unorderedlist "`unorderedlist' ``var'ms'"								//include missing tempvar name in unordered list
			
					local unorddisp "`unorddisp' `var'_ms"										//include missing display name in unordered display list
				
					local type "`type' u"														//include type still as unordered"
					
				}
				
				else quietly replace ``var'ms' = ``var'ms' + (`var' == `val')					//...else add in the other missing code... only valid with multiple missing codes (., .a, .b, etc.)
					
			}
			
			if (`: list posof "`val'" in `var'levs' == `: list sizeof `var'levs') {				//trailing text for all the locals to be fed to chaidforest()...
			
				local type "`type')"
				
				local unorddisp "`unorddisp')"
				
				local unorderedlist "`unorderedlist')"
			
			}
				
		}
			
	}
			
}
	
if `:list sizeof ordered' > 0 {																	//process ordered splitting variables when present just as was done with the response/unordered variable above...

	foreach var of varlist `ordered' {															//macros created for parsing and different puropses - ordered
		
		quietly inspect `var'																	//inspect ordered splitting variable to obtain values that are 0 and positive (if they don't equal the total - something's negative and that's not allowed)
	
		if r(N) != (r(N_0) + r(N_posint)) {														//chaidforest doesn't work with non-negarive integers - disallow them using the results from the "inspect" command
	
			display "{err}Levels of each splitting variable must be non-negative integer " ///
			"valued.  Variable {cmd:`var'} has non-negative integer values."
		
			exit 198
	
		}
		
		quietly levelsof `var' if `touse', local(`var'levs) `missing'							//put levels of ordered splitting variable into local macro
		
		if regexm("``var'levs'", "\.") mata: st_local("`var'levs_count", ///					//removes multiple missings from consideration in the levels count for ordered splitting variable
		invtokens((select(tokens(st_local("`var'levs")), ///
		editmissing(strtoreal(tokens(st_local("`var'levs"))), .):!=.), ".")))
		
		if `:list sizeof `var'levs_count' > 20 {
	
			display "{err}Number of distinct values in {cmd:`var'} is larger than " ///
			"allowed." _newline "Consider collapsing across similar categories for " ///
			"unordered or using " _newline "{opt xtile()} option/command for ordered " ///
			"variables to reduce the number of levels."
		
			exit 198
	
		}

		foreach val of numlist ``var'levs' {													//for each level of splitters, register binary variable...
		
			if `: list posof "`val'" in `var'levs' == 1 {										//leading text for locals to be fed to chaidforest()...				
			
				local type "`type' ("
				
				local orddisp "`orddisp' ("
				
				local orderedlist "`orderedlist' ("
			
			}
		
			if !missing(`val') {																//...if not a missing value...
			
				tempvar `var'`val'																//declare tempvar for each value of ordered variable
				
				quietly generate byte ``var'`val'' = `var' == `val'								//generate binary for each level of ordered variable
			
				local orderedlist "`orderedlist' ``var'`val''"									//include ordered tempvar in orderedlist 
			
				local orddisp "`orddisp' `var'_`val'"											//include display name of variable in ordered display macro
			
				local type "`type' o"															//include variable type in type macro
				
			}
	
			else {																				//...if any kind of missing value...
			
				mata: st_local("miss_name", strofreal(st_isname("``var'ms'")))					//determine if the missing binary variable is already present
				
				if !`miss_name' {																//if the missing binary variable is not found...
				
					tempvar `var'ms																//create tempvar for ordered varible indicating missing
				
					quietly generate byte ``var'ms' = `var' == `val'							//generate indicator for missing category
							
					local orderedlist "`orderedlist' ``var'ms'"									//include missing tempvar name in ordered list
			
					local orddisp "`orddisp' `var'_ms"											//include missing display name in ordered display list
				
					local type "`type' f"														//include type as floating"
					
				}
				
				else quietly replace ``var'ms' = ``var'ms' + (`var' == `val')					//...else add in the other missing code... only valid with multiple missing codes (., .a, .b, etc.)
					
			}
			
			if (`: list posof "`val'" in `var'levs' == `: list sizeof `var'levs') {				//trailing text for all the locals to be fed to chaidforest()...
			
				local type "`type')"
				
				local orddisp "`orddisp')"
				
				local orderedlist "`orderedlist')"
			
			}
					
		}
		
	}

}

/*Process number of variables to select in random forest*/
if `nvuse' <= -1 scalar `nvars' = ///															//by default use rounded square root of number of splitting variables...
round(sqrt(`=`:list sizeof ordered' + `:list sizeof unordered''))

else if (`nvuse' > `=`:list sizeof ordered' + `:list sizeof unordered'') & (`nvuse' > 0) {		//...exit if too many splitting variables indicated in macro nvuse...
	
	display "{err}{opt nvuse()} must be less than or equal to the number of splitting " ///
	"variables" _newline "included in options {opt xtile()}, {opt ordered()} and/or " ///
	"{opt unordered()}"
		
	exit 198
	
}

else scalar `nvars' = `nvuse'																	//...otherwise use user-specified number of splitting variables per tree

if strlen("`weight'") local chaid_exp = subinstr("`exp'", "=", "", 1)							//if there is a frequency weight, parse the "exp" to obtain only the weight variable

if strlen("`weight'") {																			//obtain number of obsevations with frequency weights...
	
	quietly summarize `chaid_exp' if `touse', meanonly
		
	scalar `obs' = r(sum)
	
}
	
else {																							//...otherwise obtain number of observations without frequency weights
	
	quietly count if `touse'
		
	scalar `obs' = r(N)
		
}

if `minsplit' == 0 local minsplit = `=ceil(`obs'*.01)'											//default minsplit is 1% of sample size
	
if `minnode' == 0 local minnode = `=ceil(`obs'*.005)'											//default minnode is .5% of sample size

/*Pull data into Mata for processing*/
mata: results = chaidforest(`ntree', `=`nvars'', "`type'", ///									//run chaidforest() function in Mata - returns "results" object
"`varlist' `unorderedlist' `orderedlist'", ///
"`varlist' `unordered' `ordered'", `alpha', `minsplit', `minnode', ///
"`touse'", "`dvordered'", "`varlist' `unorddisp' `orddisp'", "`noisily'", ///
"`samp'", `proos', "`chaid_exp'") 

if `proos' > -1 scalar `N_tree' = `=round(`obs'*(1 - `proos'))'									//obtain observations per tree if proos() used...

else scalar `N_tree' = `obs'																	//...otherwise observations per tree is equivalent to total number of observations (i.e., sample size due to bootstrapping)

/*Return basic results*/
ereturn post , depname(`varlist') esample(`touse')

ereturn scalar ntree = `ntree'

ereturn scalar nvuse = `nvars'

ereturn scalar N_tree = `N_tree'

ereturn scalar minsplit = `minsplit'

ereturn scalar minnode = `minnode'

ereturn local splitvars = "`unordered' `ordered'"

ereturn local predict = "chaidforest_pr"

if strlen("`weight'") {

	ereturn local wtype = "fweight"
	
	ereturn local wexp "`exp'"
	
}

ereturn local estat_cmd = "chaidforest_estat"

ereturn local title = "CHAID-based Random Forest"

ereturn local cmd = "chaidforest"

ereturn local cmdline = "chaidforest `full_cmdline'"

if strlen("`missing'") ereturn hidden scalar validmiss = 1

else ereturn hidden scalar validmiss = 0

if strlen("`dvordered'") ereturn hidden scalar dvorder = 1

else ereturn hidden scalar dvorder = 0

if `proos' == -1 ereturn hidden scalar w_o_replace = 0

else ereturn hidden scalar w_o_replace = 1

end


/*Object for chaidforest's results storage*/
version 12.1

mata:

mata set matastrict on

class chaidtree {

	real colvector clusters																		//each tree retains clusters
	
	string matrix CHAID_rules																	//each tree retains if/then statements
	
	string scalar used_vars																		//each tree retains variables used
	
	real colvector bootstrap_weight																//each tree retains frequency weights from bootstrap or e(sample)-like data from prop_oos

}
	
end


/*Mata-version of CHAID based on Goodman association models*/
version 12.1

mata:

mata set matastrict on

function chaid_g(real matrix usedata, string rowvector type, ///
string rowvector names, string rowvector vars, real scalar alpha, ///
real scalar minimum_2_split, real scalar minimum_node_size, string scalar ordered_response, ///
string scalar noisily, real colvector weight)
{
	/*declarations*/
	class chaidtree scalar current_tree

	real matrix select2variables, check_table, compare_table, data4analysis, ///
	data4merging
	
	real rowvector result, merger_pvalues, select_merge_categories, randomly_resolve, ///
	branches, merger_r2s
	
	real colvector proceed, cluster, use_obs, select_obs, comare_var1, comare_var2, ///
	wgt4analysis
	
	real scalar category, split, token, position, moresplit, compare_pvalue, ///
	current_pvalue, more_merge, cluster_count, current_cluster, num_combos, ///
	possible_combos, floating, compare_aic, current_aic
	
	string matrix splits, CHAID_splits
	
	string rowvector select_type, collapse_variables, select_names, compare_names, ///
	select2names, select2vars
	
	transmorphic cvp_setup, cvp_template	
	
	/*set-up and notification; CHAID is a noisy program to find bugs primarily*/
	if (strlen(noisily)) "CHAID Begins Execution"	//
																																							
	if (strlen(noisily)) vars	//
	
	position = 2																				//updatable position of focal splitting variable; begins at 2 because response is variable 1
	
	moresplit = 1																				//scalar used to by chaid_g() to indicate "please continue splitting"; when this turns 0, chaid_g() is finished looking for any and all splits in the data
	
	compare_pvalue = 1																			//used as the "comparison" lowest p-value; if the current p-value from an analysis is smaller/larger, variable is split/merged
	
	compare_aic = .																				//used as the "comparison" lowest AIC value; only used for splitting purposes - if the current AIC from an analysis is larger, variable is split
	
	cluster_count = 1																			//the number of clusters to this point - starts at 1 indicating that everyone is in the same cluster (i.e., cluster #1)
	
	current_cluster = 1																			//the cluster currently being processed to find more splits - starts at cluster #1
	
	compare_names = ("")																		//holds the variable names of the associated with the variables splits currently best (as chosen by p-values or AIC); changes when another splitting variable is chosen as best
	
	branches = (0)																				//the number of branches the current tree has by cluster/node - starts at 0; is updated as more splits are found
	
	splits = ("")																				//the current data implemented/chosen partitions/splits associated with the current chaid_g() run
	
	result = J(1, 5, .)																			//Goodman model results - chi-square, DF, log-likelihood, and number of parameters
	
	if (strlen(noisily)) names	//

	if (strlen(noisily)) type	//
	
	proceed = J(rows(usedata), 1, 1)															//vector to use to indicate continue splitting on these observations; ; a kind of updatable "touse" that focuses on whether clustering has been attempted and failed to find further clusters
	
	cluster = J(rows(usedata), 1, 1)															//cluster number associated with each observation; starts at cluster #1 for all
	
	use_obs = J(rows(usedata), 1, 0)															//vector to indicate use the set of observations for splitting in current splitting run; a kind of updatable "touse" which accounts for "proceed" above as well as the combination of "current_cluster" and "cluster"
	
	CHAID_splits = ("Splits")																	//matrix to use to return partitioning rules and splits
	
	/*begin looking for splits in the data*/
	while (moresplit) {																			//do following process at least once - continue if between-variable splitting process is to continue (i.e., moresplit == 1)

		use_obs = (use_obs:*0):+((proceed:+(cluster:==current_cluster)):==2)					//update observations to use - ones that can be "proceed"ed on and that are in the current cluster
		
		select_names = names[position]															//pull out names for first splitting variable 												
		
		if (strlen(noisily)) select_names	//
		
		select_type = type[position]															//pull out types for first splitting variable using same procedure as above												
		
		if (strlen(noisily)) select_type	//
		
		more_merge = 1																			//updatable scalar to indicate continute merging levels of a splitting variable - here merging always proceeds until only 2 levels remain
		
		data4analysis = select(usedata, use_obs)												//subset data to the relevent set of observations
		
		wgt4analysis = select(weight, use_obs)													//subset weights to the relevant set of observations
		
		check_table = mm_freq(data4analysis[., 1], wgt4analysis)								//determine frequency of values on response variable
		
		if (strlen(noisily)) check_table	//
																										
		if (!sum(proceed)) {																	//if proceeds are all 0, and thus there are no observations to proceed on...														
		
			moresplit = 0																		//don't split anymore - chaid is done
			
			more_merge = 0																		//don't merge anymore either
			
		}
		
		else if ((rows(check_table) == 1) | (colsum(check_table) < minimum_2_split)) {			//...or if there is only one response value left in a cluster (i.e., it's pure)/the remaining sample size is below the minimum for continuing looking for splits...
			
			more_merge = 0																		//stop merging on this variable

			proceed = proceed:-use_obs															//stop clustering on these observations; use_obs subtracts 1 from proceed thus making previously "proceed"ed observations, no longer "proceed"able
			
			current_cluster++																	//increment current cluster - start using the next cluster up and look for splits there; so long as there is another cluster
			
			position = 2																		//restart "position" used in merging at 2 for the new cluster
			
		}
																										
		else {																					//...otherwise the response variable looks good - begin splitting variable category merging
			
			check_table = colsum(select(data4analysis, ///										//how many levels of the splitting variable remain?
			colsum(J(cols(tokens(select_names)), 1, ///
			tokens(invtokens(names))):==(tokens(select_names)'))))
		
			if (strlen(noisily)) check_table	//
		
			select_names = select(tokens(select_names), sign(check_table))						//separate out the binary variables associted with the focal splitting variable
		
			if (strlen(noisily)) select_names	//
			
			select_type = select(tokens(select_type), sign(check_table))						//separate out the types associated with the splitting variable
			
			data4merging = select(data4analysis, colsum(J(cols(select_names), ///				//only keep the focal splitting variable and response variable
			1, tokens(invtokens(names))):==(select_names')))
		
			while (more_merge == 1) {															//so long as this is indicated, keep merging levels...
		
				collapse_variables = ("")														//replace/generate collapse_variables including names of variables to be collapsed into single variable
			
				merger_pvalues = (.)															//vector of p-values to search through to determine which categories should be merged
				
				merger_r2s = (.)																//vector of pseudo-R2 values to search through to determine which categories should be merged
				
				floating = 0																	//does this splitting variable have a floating missing? (i.e., missing with an splitting ordered variable)
			
				if (cols(select_names) > 2)  {													//if there are more than 2 categories of the splitting variable remaining?  If yes, attempt mergers
		
					if (select_type[1] == "u") {												//if the variable is unordered...
							
						cvp_template = (J(2, 1, 1) \ J(cols(select_names) - 2, 1, 0))			//setup vector for use in cvpermute() to select all sets of 2 variables

						if (strlen(noisily)) cvp_template	//
						
						cvp_setup = cvpermutesetup(cvp_template)								//register "cvp_template" vector with cvpermute()
				
						possible_combos = comb(cols(select_names), 2)							//number of possible combinations - unordered
				
					}
					
					else if (																	//... or if the variable is "floating"...
					(select_type[cols(select_type)] == "f") & ///
					(colsum(regexm(select_names[cols(select_names)], "ms$")) == 1) & ///
					(colsum(cols(tokens(select_names[cols(select_names)]))) == 1)) {
					
						possible_combos = (cols(select_names) - 1)*2 - 1						//number of possible combinations - floating
						
						floating = 1															//indicate that there's a floating variable
						
						cvp_template = (J(1, 1, 1) \ J(cols(select_names) - 2, 1, 0))			//setup vector for use in cvpermute() to select all sets of 2 variables
						
						if (strlen(noisily)) cvp_template	//
						
						cvp_setup = cvpermutesetup(cvp_template)								//register "cvp_template" vector with cvpermute()						
					
					}
					
					else possible_combos = cols(select_names) - 1								//...otherwise the other possibility is ordered...
						
					num_combos = 1																//scalar to keep track of how many combinations have been looped through to this point...
				
					while (num_combos <= possible_combos) {										//go through all different combinations of predictor levels to find best levels to collapse
				
						if (select_type[1] == "u") select2variables = cvpermute(cvp_setup)'		//invoke instance of cvpermute() for selector vector - unordered
				
						else if (((select_type[1] == "o") & (floating == 0)) | ///
						((floating == 1) & (sign(num_combos*2 - possible_combos) != 1))) ///	//invoke instance of cvpermute() for selector vector - ordered or floating when the floating category has been merged into another category
						select2variables = (J(num_combos - 1, 1, 0) \ J(2, 1, 1) \ ///
						J(cols(select_names) - num_combos - 1, 1, 0))'
						
						else if ((floating == 1) & ///											//invoke instance of cvpermute() for selector vector - floating, when the floating category has not been merged yet
						(sign(num_combos*2 - possible_combos) == 1)) ///	
						select2variables = (cvpermute(cvp_setup)', 1)
				
						if (strlen(noisily)) select2variables	//
				
						collapse_variables = (collapse_variables, ///							//create string vector indicating position of category, binary variables to obtain a chi-square on among all the categories representing the focal splitting variable
						invtokens(strofreal(select2variables)))		
				
						if (strlen(noisily)) collapse_variables	//
				
						select2names = select(select_names, select2variables)					//proceed to select 2 columns of splitting variable to evaluate for potentially collapsing
				
						if (strlen(noisily)) select2names	//
					
						if (strlen(noisily)) select2names[1]	//
					
						select2vars = tokens(select2names[1])									//separate out binary variables represeing a category (sometimes will already have been collapsed - this step is necessary to ensure previously collapsed binaries are appropriately used) - category 1
						
						comare_var1 = rowsum(select(data4merging, ///							//implement the previously collapsed binaries into single category - category 1
						colsum(J(cols(select2vars), 1, ///	
						tokens(invtokens(select_names))):==(select2vars)')))
						
						if (strlen(noisily)) sum(comare_var1)	//
					
						if (strlen(noisily)) select2names[2]	//
					
						select2vars = tokens(select2names[2])									//separate out binary variables represeing a category (sometimes will already have been collapsed - again, this step is necessary to ensure previously collapsed binaries are appropriately used) - category 2
						
						comare_var2 = rowsum(select(data4merging, ///							//implement the previously collapsed binaries into single category - category 2
						colsum(J(cols(select2vars), 1, ///		
						tokens(invtokens(select_names))):==(select2vars)')))
						
						if (strlen(noisily)) sum(comare_var2)	//
					
						if (strlen(noisily)) mean((comare_var1, comare_var2))	//					
						
						if (rows(uniqrows(select(data4analysis[., 1], ///						//invoke Goodman association model - only runs so long as 0's and 1's exist for both categories 1 and 2 of the splitting variable given the previous mergers - contingency tables need 4 cells!
						(comare_var1:+comare_var2)))) > 1) ///	
						result = goodman(select((data4analysis[., 1], comare_var1), ///
						(comare_var1:+comare_var2)), sign(strlen(ordered_response)), ///
						sign(strlen(noisily)), select(wgt4analysis, ///
						(comare_var1:+comare_var2)))
						
						else result = J(1, 5, .)												//if goodman() doesn't run due to too few categories, ensure this result is merged (or likely to be merged)
						
						if (strlen(noisily)) result	//
						
						if (result[1] != .) {													//if all went well...
						
							merger_pvalues = ///
							(merger_pvalues, chi2tail(result[2], result[1]))					//record p-value
							
							merger_r2s = ///
							(merger_r2s, 1 - (result[3]/result[5]))								//record pseudo-r2
							
						}
						
						else {																	//...otherwise, something's wrong
						
							merger_pvalues = (merger_pvalues, 1)								//bad comparison, probably merge them; pvalue
						
							merger_r2s = (merger_r2s, 0)										//bad comparison, probably merge them; r2
						
						}
						
						num_combos++															//increment num_combos - make the next comaprison
					
						if (strlen(noisily)) num_combos	//
				
				
					}
			
					merger_pvalues = strmatch(strofreal(merger_pvalues), ///					//find the position of the largest p-value criterion
					strofreal(max(merger_pvalues)))		
				
					if (strlen(noisily)) merger_pvalues	//
					
					if (rowsum(merger_pvalues) > 1) {											//if there are multiple, identical, large p-values pick one using r2 (pvalues might just be too big...) AIC is invalid given the change in N per merger comparison...
							
						merger_pvalues = strmatch(strofreal(merger_r2s), ///					//find the position of the smallest r2
						strofreal(min(merger_r2s)))	
						
						if (strlen(noisily)) merger_pvalues	//
						
						if (rowsum(merger_pvalues) > 1) {										//if there are multiple, identical, small r2's pick one randomly - chaid_g() can't tell the difference...
						 
							randomly_resolve = runiform(1, cols(merger_pvalues))				//random number with a number of columns equal to the number of identical p-values
					
							merger_pvalues = strmatch(strofreal(merger_pvalues), ///			//find the p-values that match - again
							strofreal(max(merger_pvalues)))	
						
							merger_pvalues = randomly_resolve:*merger_pvalues					//keep only the random numbers which are associated with the matching p-values
						
							merger_pvalues = strmatch(strofreal(merger_pvalues), ///			//select the biggest random p-value
							strofreal(max(merger_pvalues)))	
								
							if (strlen(noisily)) merger_pvalues	//
							
						}
					
					}
				
					select_merge_categories = strtoreal(tokens(select(collapse_variables, ///	//pull out binary variables associated with largest p-value
					merger_pvalues)))			
						
					if (strlen(noisily)) select_merge_categories	//
						
					if (select_type[1] == "u") select_names = ///								//merge together chaid_g() identified categories associated with unordered - stick the newly merged category on the end
					(invtokens(select(select_names, select_merge_categories)), ///
					select(select_names, abs(select_merge_categories:-1)))
						
					else if (select_type[1] == "o") {											//merge together chaid_g() identified categories associated with ordered - order matters now, requires more syntax
						
						num_combos = (strpos(invtokens(strofreal(select_merge_categories)), ///	//use num_combos as indicator of "where" the merger needs to occur in the vector of category names
						"1") + 1)/2	
							
						if (strlen(noisily)) num_combos	//
							
						if (select_merge_categories[num_combos] == ///
						select_merge_categories[num_combos + 1]) { 								//when the merged categories are next to one another/most circumstances...
						
							if (num_combos == 1) select_names = ///								//if the merger is at the beginning of the vector/list...
							(invtokens(select(select_names, select_merge_categories)), ///
							select(select_names[num_combos + ///
							2..cols(select_merge_categories)], ///
							abs(select_merge_categories[num_combos + ///
							2..cols(select_merge_categories)]:-1)))
							
							else if (num_combos == cols(select_merge_categories) - 1) ///		//...or if the merger is at the middle of the vector/list...
							select_names = ///	
							(select(select_names[1..num_combos - 1], ///
							abs(select_merge_categories[1..num_combos - 1]:-1)), ///
							invtokens(select(select_names, select_merge_categories)))
							
							else select_names = ///
							(select(select_names[1..num_combos - 1], ///						//...otherwise the merger is at the end of the vector/list
							abs(select_merge_categories[1..num_combos - 1]:-1)), ///
							invtokens(select(select_names, select_merge_categories)), ///
							select(select_names[num_combos + ///
							2..cols(select_merge_categories)], ///
							abs(select_merge_categories[num_combos + ///
							2..cols(select_merge_categories)]:-1)))
							
						}
							
						else {																	//...otherwise it's a floating category which will be considered a member of the ordered list now
							
							if (num_combos == 1) select_names = ///								//if the merger is at the beginning of the vector/list...
							(invtokens(select(select_names, select_merge_categories)), ///
							select(select_names[num_combos + ///
							1..cols(select_merge_categories) - 1], ///
							abs(select_merge_categories[num_combos + ///
							1..cols(select_merge_categories) - 1]:-1)))
							
							else if (num_combos == cols(select_merge_categories) - 1) ///		//...or if the merger is at the middle of the vector/list...
							select_names = ///	
							(select(select_names[1..num_combos - 1], ///
							abs(select_merge_categories[1..num_combos - 1]:-1)), ///
							invtokens(select(select_names, select_merge_categories)))
							
							else select_names = ///
							(select(select_names[1..num_combos - 1], ///						//...otherwise the merger is at the end of the vector/list
							abs(select_merge_categories[1..num_combos - 1]:-1)), ///
							invtokens(select(select_names, select_merge_categories)), ///
							select(select_names[num_combos + ///
							1..cols(select_merge_categories) - 1], ///
							abs(select_merge_categories[num_combos + ///
							1..cols(select_merge_categories) - 1]:-1)))
							
						}
						
					}
					
					if (strlen(noisily)) select_names	//
				
				}
			
				else more_merge = 0																//if only 2 categories of splitting variable remain - stop merging
						
				if (strlen(noisily)) "Completed One Merging Session"	//
			
			}
			
			data4merging = data4analysis[., 1]													//refresh data to use - set it up for goodman() to decide on splitting - start by just using the response variable
			
			if (select_type[1] == "o") data4merging = ///
			(data4merging, J(rows(data4merging), 1, 0))											//when the focal splitting variable is ordered, add a variable which can be used to sum the binaries into - goodman() requires ordered splitting variables to be a single variable, not multiple
			
			for (category = 1; category <= cols(select_names); category++) {					//for all the categories of the splitting variable that are optimally merged...  though, there should only be 2, which makes the below unnecessary - relic of allowing > 2 categories previously, now disallowed
			
				select2vars = tokens(select_names[category])									//pull out all specific merged categories to turn into single binary
				
				if (strlen(noisily)) select2vars	//
				
				if (select_type[1] == "u") data4merging = ///									//if unordered, just put each merged category-variable in as its own dummy code
				(data4merging, rowsum(select(data4analysis, colsum(J(cols(select2vars), 1, ///
				tokens(invtokens(names))):==(select2vars')))))
				
				else if (select_type[1] == "o") data4merging[., 2] = data4merging[., 2] + ///	//... or if ordered, make that merged category-variable have it's own "category" that's summed into the vector of 0's constructed above - preserves ordering
				rowsum(category:*select(data4analysis, colsum(J(cols(select2vars), 1, ///
				tokens(invtokens(names))):==(select2vars'))))
				
			} 
			
			if (select_type[1] == "u") check_table = ///										//if unordered how many levels of the splitting variable remain?...
			mm_freq(rowsum(data4merging[., ///
			2..cols(data4merging)]:*(1..cols(data4merging)-1)), ///
			wgt4analysis)
			
			else if (select_type[1] == "o") check_table = ///									//...otherwise ordered - how many levels of the splitting variable remain?
			mm_freq(data4merging[., 2], ///			
			wgt4analysis)				
		
			if (strlen(noisily)) check_table	//
			
			if (rows(check_table) > 1) {														//so long as there is > 1 category of the splitting variable remaining (wouldn't necessarily be caught previously)
			
				result = goodman(data4merging, sign(strlen(ordered_response)), ///				//invoke goodman() to check on split-ability of the splitting variable as merged
				sign(strlen(noisily)), wgt4analysis)	
						
				if (strlen(noisily)) result	//
			
				if (result[1] != .) {															//if all went well - record p-value & AIC...
				
					current_pvalue = chi2tail(result[2], result[1])								//compute p-value
					
					current_aic = -2*result[3] + 2*result[4]									//compute AIC
					
				}
			
				else {																			//...otherwise, something's wrong - probably shouldn't split on this variable
				
					current_pvalue = 1															//assign p-value of 1; assures no splitting
					
					current_aic = .																//won't split but for completeness, AIC is missing
					
				}
				
			}
			
			else {																				//...otherwise, no splitting possible - only single category on splitting variable
			
				current_pvalue = 1																//assign p-value of 1; assures no splitting
				
				current_aic = .																	//won't split but for completeness, AIC is missing
			
			}
				
			if (strlen(noisily)) {
			
				current_pvalue	//
		
				compare_pvalue	//
				
				current_aic	//
				
				compare_aic	//
			
			}
		
			if (current_pvalue < compare_pvalue) {												//this splitting variable did better than the previous! - record its p-value and AIC
		
				if (strlen(noisily)) "better!"	//
		
				compare_pvalue = current_pvalue													//update lowest p-value
		
				if (strlen(noisily)) compare_pvalue	//
			
				compare_names = select_names 													//record merged categories of splitting variable
			
				if (strlen(noisily)) compare_names	//
				
				compare_table = check_table														//record number of people in each cell of splitting variable (ensure that they're not too small)
				
				if (strlen(noisily)) compare_table	//
				
				compare_aic = current_aic														//update AIC
			
			}
		
			else if (current_pvalue == compare_pvalue) {										//identical p-values - decide based on AIC
		
				if (current_aic < compare_aic) {												//this splitting variable did better than the previous! - record its p-value and AIC
				
					if (strlen(noisily)) "better!"	//
		
					compare_aic = current_aic													//update lowest AIC-value
		
					if (strlen(noisily)) compare_aic	//
			
					compare_names = select_names 												//record merged categories  of splitting variable
			
					if (strlen(noisily)) compare_names	//
				
					compare_table = check_table													//record number of people in each cell of splitting variable (ensure that they're not too small)
				
					if (strlen(noisily)) compare_table	//
					
					compare_pvalue = current_pvalue												//update p-value
					
				}
				
				else if (current_aic == compare_aic) {											//identical AIC-values - randomly decide who gets kept
				
					randomly_resolve = runiform(1, 2)											//generate random uniform matrix size 2
			
					if (randomly_resolve[1] < randomly_resolve[2]) {							//resolve the improvement in association randomly
		
						if (strlen(noisily)) "better!"	//
		
						compare_pvalue = current_pvalue											//update p-value
		
						if (strlen(noisily)) compare_pvalue	//
			
						compare_names = select_names 											//record merged categories of splitting variable
			
						if (strlen(noisily)) compare_names	//
						
						compare_table = check_table												//record number of people in each cell of splitting variable (ensure that they're not too small)
						
						if (strlen(noisily)) compare_table	//
						
						compare_aic = current_aic												//update AIC-value
						
					}
						
				}
		
			}
		
			position =  position + 1															//increment position - try next splitting variable
		
			if (strlen(noisily)) position	//
		
			if (strlen(noisily)) "Completed Merging Run"	//
		
			if (strlen(noisily)) compare_names	//             
	
			if (position == cols(vars) + 1) {													//if all splitting variables have been attempted...
		
				if ((compare_pvalue < alpha) & (min(compare_table) >= minimum_node_size)) {		//if the best p-value meets alpha p-value criterion, and smallest cluster produced is above minimum cluster/node size restriction
		
					if (strlen(noisily)) "split!"	//
					
					branches[current_cluster] = branches[current_cluster] + 1					//Another branch is grown for the focal cluster - add it to the number currently
					
					if (strlen(noisily)) branches //
					
					select_names = (" ")														//reset select_names for use in creating a path for the focal cluster
					
					for (split = 1; split <= cols(compare_names); split++) {					//generate the "split" to put in the splits row of the CHAID_splits matrix
					
						if (strlen(noisily)) compare_names[split]	// 
					
						select_names = (select_names, compare_names[split], ",")				//separate the different merged categories of the splitting variable with commas
					
					}
					
					if (strlen(noisily)) select_names	//
					
					if (branches[current_cluster] > cols(splits)) splits = ///					//make a new row in splits matrix if needed to represent the new cluster's "path"
					(splits, J(rows(splits), 1, ""))
					
					splits[current_cluster, branches[current_cluster]] = compare_names[1]		//names of the binaries (varname with catrgories) of first category of optimally merged variable into first row in the cluster's "path"
					
					if (strlen(noisily)) splits	//
					
					CHAID_splits = (CHAID_splits, invtokens(select_names))						//add the new split rules to the rules matrix - forms the first row
					
					for (split = 2; split <= cols(compare_names); split++) {					//for the remaining levels of the optimally merged splitting variable...
					
						cluster_count++															//increment cluster_count as there's another cluster obtained
						
						if (strlen(noisily)) cluster_count	//
						
						branches = (branches, branches[current_cluster])						//update branches for the next cluster - adding in that cluster too
						
						if (strlen(noisily)) branches	//
						
						splits = (splits \ splits[current_cluster, .])							//add row to splits matrix representing that clusters path - all elements before the current one in the path will be the same as the first split and will be copied
						
						splits[cluster_count, branches[cluster_count]] = compare_names[split]	//add specific, new split information into the cluster's path
						
						if (strlen(noisily)) splits	//
																		
						select_names = tokens(compare_names[split])								//tokenize the elements associated with the binaries so that the cluster numbers can be updated in the data
					
						for (token = 1; token <= cols(select_names); token++) {					//for each element just tokenized above...
							
							select_obs = (use_obs:+select(usedata, ///							//find where cluster number needs updating in the observations
							tokens(invtokens(names)):==select_names[token])):==2
							
							cluster = ///
							(cluster:*abs(select_obs:-1)):+(select_obs:*cluster_count)			//change cluster number on the observations that need updating
							
							if (strlen(noisily)) mm_freq(cluster, weight)	//
							
						}
					
					}
					
					position = 2																//restart position at the first splitting variable now that there's been a partition
					
					compare_names = ("")														//restart best split so far
					
					compare_pvalue = 1															//restart best p-value so far
					
					compare_aic = .																//restart best AIC so far
				
				}
				
				else {																			//...otherwise, don't meet splitting criteria were not met
				
					position = 2																//restart splitting variable search

					proceed = proceed:*(cluster:!=current_cluster)								//make these observations "stop" splitting - removed from the "touse"-like vector
					
					current_cluster++															//increment cluster - the current cluster cannot be split anymore; look for splits in others
				
					if (max(cluster) < current_cluster) moresplit = 0							//if this is the last cluster (i.e., current cluster just incremented past where the current max is) - chaid ends/turn of moresplit
				
					if (strlen(noisily)) current_cluster	//
				
					compare_pvalue = 1															//reset best p-value so far
					
					compare_aic = .																//reset best AIC so far
					
					compare_names = ("")														//reset best splits so far
						
				}
		
			}
		
		}
	
	}
	
	for (split = 1; split <= rows(splits); split++) {											//for all the rows in the splits matrix...
	
		if (cols(CHAID_splits) > 1) CHAID_splits = ///											//add data to "rules" matrix - specifically, the splits
		(CHAID_splits \ ("path" + strofreal(split), ///
		splits[split, .], J(1, cols(CHAID_splits)-cols(splits)-1, "")))
	
	}
	
	if (strlen(noisily)) "CHAID Finished Execution"	//
	
	current_tree.clusters = cluster																//add clusters to object to be returned
	
	current_tree.CHAID_rules = CHAID_splits														//add rules to object to be returned
	
	return(current_tree)																		//return a chaidtree object

}  

end

/*Mata function to implement the CHAID-based random forest algorithm*/
version 12.1

mata:

mata set matastrict on

function chaidforest(real scalar number_o_trees, real scalar num_vars_used, ///
string scalar type, string scalar names, string scalar vars, real scalar alpha, ///
real scalar minimum_2_split, real scalar minimum_node_size, string scalar touse, ///
string scalar ordered_response, string rowvector displays, string scalar noisily, ///
string scalar sampling, real scalar prop_oos, string scalar weight_name) {
	
	/*declarations*/
	class chaidtree vector current_tree
	
	real matrix data, usedata, chaid_weight
	
	real colvector clusters, weight
	
	real rowvector rowsel, varsel
	
	real scalar tree
	
	string rowvector select_names, select_type, select_vars, names_list, type_list, ///
	displayvec
	
	string scalar wchars, pchars, qchars
	
	transmorphic token_setup
	
	/*begin processing input from Stata*/
	current_tree = chaidtree(number_o_trees)													//produce vector of chaidtree objects - its length will be the number of trees; efficient way to store tree information
	
	if (strlen(noisily)) names	//
	
	token_setup = tokeninit(wchars = (" "), pchars = (" "), qchars = ("()"))					//set up the tempvar binary names for parsing
		
	tokenset(token_setup, names)																//apply the above rules to tempvar binary names
	
	names_list = subinstr(subinstr(tokengetall(token_setup), ")", ""), "(", "")					//obtain all tokens of tempvar binary names, remove binding parentheses
	
	if (strlen(noisily)) names_list	//
	
	token_setup = tokeninit(wchars = (" "), pchars = (" "), qchars = ("()"))					//set up the types for parsing
			
	tokenset(token_setup, type)																	//apply the above rules to types
	
	type_list = subinstr(subinstr(tokengetall(token_setup), ")", ""), "(", "")					//obtain all tokens of types, remove binding parentheses
	
	if (strlen(noisily)) type_list	//
	
	token_setup = tokeninit(wchars = (" "), pchars = (" "), qchars = ("()"))					//set up the binary display names for parsing
			
	tokenset(token_setup, displays)																//apply the above rules to binary display names
	
	displayvec = subinstr(subinstr(tokengetall(token_setup), ")", ""), "(", "")					//obtain all tokens of binary display names, remove binding parentheses
	
	if (strlen(noisily)) displayvec	//
	
	data = ///																					//pull data out of Stata; specifically, the tempvar binaries and the response - removing the binding parentheses and filtering by e(sample)/touse
	st_data(., st_varindex(tokens(subinstr(subinstr(names, ")", ""), "(", ""))), ///
	st_varindex(touse))
	
	data = editmissing(data, .)																	//change all missing values to "." - really only applies to the response
	 
	if (strlen(weight_name)) weight = st_data(., weight_name, st_varindex(touse))				//if fweight-ed, pull the weight into Mata...
	
	else weight = J(rows(data), 1, 1)															//...otherwise, no fweight and thus equal weights - all obs in sample get a 1

	if (number_o_trees > 19) {																	//keep track of progress - header/display
	
		printf("\n{txt}Progress in growing all " + ///
		"{res}%10.0g {txt}CHAID trees\n{res}0%%{txt}" + ///
		"{hline 6}{res}50%%{txt}{hline 6}{res}100%%\n", number_o_trees)
		
		printf("{txt}.")
		
		displayflush()
		
	}
	
	/*grow and store the chaidforest*/
	for (tree = 1; tree <= number_o_trees; tree++) {											//for the number of desired trees...
		
		if (number_o_trees > 19) {																//keep track of progress - dots
	
			if (sum(strmatch(strofreal(tree), ///
			strofreal(floor(mm_quantile(1::number_o_trees, 1, (1::20):/20)))))) {				//only want ~ 20 dots... this ensures there will only be ~ 20
			
				printf("{txt}.")
				
				displayflush()	
				
			}
		}

		if (strlen(sampling)) rowsel = mm_expand(1::rows(data), weight, 0)						//if no bootstrap "bagging" is desired expand the observations using weight for collapsing later...
		
		else if (prop_oos > -1) ///																//...or if sampling without replacement is desired, use 1-prop_oos as proportion sampled...
		rowsel = mm_sample(round(sum(weight)*(1-prop_oos)), rows(data), ., weight, 1, 0)	
		
		else rowsel = mm_sample(sum(weight), rows(data), ., weight, 0, 0)						//...otherwise default to select observations with replacement as a bootstrap sample
		
		varsel = mm_sample(num_vars_used, cols(tokens(vars))-1, ., ., 1, 1)						//selection vector for splitting variables obtained without replacement - need to obtain their dummy codes and types too
		
		if (strlen(noisily)) varsel	//
		
		select_vars = (tokens(vars)[1], select(tokens(vars)[2..cols(tokens(vars))], varsel'))	//implement the selection of splitting variables to include	by overall variable name (i.e., not by associated binaries)
		
		if (strlen(noisily)) select_vars	//
		
		select_names = (displayvec[1], select(displayvec[2..cols(names_list)], varsel'))		//pull binary indicators associated with splitting variables selected
			
		if (strlen(noisily)) select_names	//
		
		select_type = (type_list[1], select(type_list[2..cols(type_list)], varsel'))			//pull types associated with splitting variables selected
		
		if (strlen(noisily)) select_type	//
		
		usedata = select(data[rowsel, .], ///													//select observations and splitting variables from the overall dataset to pass to chaid_g()
		colsum(J(rows(tokens(invtokens(select_names))'), 1, ///
		tokens(subinstr(subinstr(displays, ")", ""), ///
		"(", ""))):==(tokens(invtokens(select_names))')))	
		
		usedata = mm_collapse(usedata, 1, rowsel)												//collapse dataset on bootstrapped observations
		
		chaid_weight = mm_collapse(J(rows(rowsel), 1, 1), 1, rowsel, &dosum())					//collapse boostrapped observations into a frequency weight chaid_g() can use
		
		current_tree[tree] = ///																//pass arguments and data to chaid_g(), the goodman association model-based chaid learner
		chaid_g(usedata[., 2..cols(usedata)], select_type, select_names, select_vars, ///				
		alpha, minimum_2_split, minimum_node_size, ordered_response, noisily, ///
		chaid_weight[., 2])
		
		if (strlen(noisily)) current_tree[tree].CHAID_rules	//
		
		clusters = exp(ln(rowsum((J(1, rows(chaid_weight), ///									//this "merge"s in clusters to the data in a form that's conformable to how its represented in the Stata dataset - non-sampled observations get missing value
		1::rows(data)):==(chaid_weight[., 1]')):*current_tree[tree].clusters')))
		
		current_tree[tree].clusters = clusters													//update chaidtree clusters entry
		
		current_tree[tree].used_vars = select_vars												//update chaidtree used variables entry
		
		current_tree[tree].bootstrap_weight = mm_freq(rowsel, 1, (1::rows(data)))				//update chaidtree bootstrap frequency weights entry
		
	}
	
	return(current_tree)																		//return vector of chaidtrees to Mata

}

end

/*Goodman association model based on loglinear/Poisson regression*/
version 12.1

mata:

mata set matastrict on

real rowvector goodman(real matrix data, real scalar ordered_response, ///
real scalar noisily, real colvector weight) {

	/*declarations*/
	real matrix IVs, DV
	
	real colvector observed_count, expected_count, combined_row_col
	
	real rowvector b, rescaled_b, xb

	real scalar converged, categories_IV, chi2, df, mean_count, responses_missing, ///
	ll, number_of_estimates, base_ll
	
	transmorphic row, col, estimation_object

	/*process inputs to goodman to estimate as poisson/loglinear model*/
	if (noisily) "Goodman/loglinear modeling Begins"	//
	
	if (sum(rowmissing(uniqrows(data[., 1])))) {												//are there missing values on response? Change them to -1's and activate "responses_missing"
	
		data[., 1] = ///																		//changes all missings to -1's
		editmissing(data[., 1], -1)
		
		responses_missing = 1																	//responses_missing is activated
		
	}
	
	else responses_missing = 0																	//otherwise deactivate responses_missing
	
	row = rowsum((J(1, rows(uniqrows(data[., 1])), ///
	data[., 1]):==(uniqrows(data[., 1])')):*(1..rows(uniqrows(data[., 1]))))					//set up response into column vector
	
	col = data[., 2]:*100																		//set up binary splitting variable/IV into column vector that can be "added to" response
	
	combined_row_col = (row + col)																//combines unique row/column cross-tab combinations in a vector
	
	if (noisily) uniqrows(combined_row_col)'	//
	
	observed_count = mm_freq(combined_row_col, weight, J(rows(uniqrows(col)), 1, ///			//obtain observed counts for all unique combinations in the cross-tabulation
	uniqrows(row)):+(uniqrows(col)#J(rows(uniqrows(row)), 1, 1)))
	
	if (noisily) observed_count	//	
	
	/*row and/or column Goodman model - needs ml estimation*/
	if ((ordered_response) & (rows(observed_count) > 3)) {										//if there is a ordered response variable and there is a contingency table worth of data (at least 4 rows)...
	
		col = uniqrows(data[., 2])#J(rows(uniqrows(data[., 1])), 1, 1)							//set up columns of the cross-tabulation approproately for analysis (i.e., spread them across levels of the response as binary dummies - kind of irrelevant as only binaries are ever applied in chaidforest...)
			
		categories_IV = rows(uniqrows(data[., 2]))												//how many unique splitting variable levels are there?
			
		row = J(categories_IV, 1, uniqrows(data[., 1]))											//ordered response - treat row variable as ordered IV "predicing" counts as a loglinear model
				
		if (responses_missing) row = (editvalue(row, -1, 1), row:==min(row))					//when there is an ordered response, separate out the floating missing category into its own dummy (missing effect) but make it equal to the smallest value to reduce collinearity in the ordered variable
		
		if (noisily) row	//
		
		if (noisily) col	//
	
		estimation_object = moptimize_init()													//initalize ml estimation object
		
		//obtain starting values - based on poisson.ado's routine
		mean_count = mean(observed_count)														//obtains a mean of the counts as an imput to starting values													
	
		IVs = cross((row, col), 1 , (row, col), 1)												//cross-products of IV's (for a linear regression)
	
		DV = cross((row, col), 1 , observed_count:-mean_count, 0)								//cross-products of IV's with DV (for a linear regression)
	
		b  = invsym(IVs)*DV																		//linear regression estimation by least squares
	
		rescaled_b = b:/mean_count																//rescale all estimates by mean number of observations which are used as initial/start values for poisson model
		
		/*set up ml estimation*/
		moptimize_init_evaluator(estimation_object, &loglin())									//tell ml evaluator what function to optimize
	
		moptimize_init_evaluatortype(estimation_object, "lf2")									//tell ml evaluator the optimization scheme (likelihood function with known 1st and 2nd derivatives of likelihood)
	
		moptimize_init_depvar(estimation_object, 1, observed_count)								//tell ml evaluator what is the dependent variable is
	
		moptimize_init_eq_indepvars(estimation_object, 1, (row, col))							//tell ml evaluator what is the independent variables are
		
		moptimize_init_search_rescale(estimation_object, "off") 								//tell ml evaluator not to spend time rescaling estimates to improve estimation - takes time to do
	
		moptimize_init_search(estimation_object, "off")											//tell ml evaluator not to spend time searching for better start values to improve estimation - takes time to do
	
		moptimize_init_eq_coefs(estimation_object, 1, rescaled_b')								//tell ml evaluator what the starting values of the parameters are
		
		moptimize_init_conv_maxiter(estimation_object, 20)										//tell ml evaluator to stop after 20 iterations - really should converge or have pretty reasonable values by then; keeps speed managable
		
		if (noisily) moptimize_init_tracelevel(estimation_object, "value")						//tell ml evaluator to show iterations if "noisily" is asked for by user...
		
		else moptimize_init_tracelevel(estimation_object, "none") 								//...otherwise show nothing
		
		moptimize_init_conv_warning(estimation_object, "off")									//tell ml evaluator not to warn when convergence is not reached
	
		moptimize(estimation_object)															//tell ml evaluator to proceed with estimation
	
		xb = moptimize_result_coefs(estimation_object)											//pull estimates from results
	
		if (noisily) xb	//
		
		converged = moptimize_result_converged(estimation_object)								//is everyting well?  That is, did estimation converge?
		
		if (sum(rowmissing(xb)) == 0) converged = 1												//keep estimates if they're usable in computation, even if convergence wasn't reached - we're data mining here
	
		expected_count = exp((row, col, J(rows(observed_count), 1, 1))*xb')						//compute expected frequencies
	
		if (noisily) expected_count	//
	
		df = (rows(uniqrows(data[., 2])))*(rows(uniqrows(data[., 1]))) - cols(xb)				//obtain DF
		
		number_of_estimates = cols(xb)															//obtain number of parameters estimated
	
	}
	
	/*unstructured model - traditional contingency table/product of margins approach*/
	else if (rows(observed_count) > 3) {														//if a contingency table can be made...
	
		row = mm_freq(data[., 1], weight)														//row/response variable margins
		
		if (noisily) row	//
		
		col = mm_freq(rowsum(data[., 2..cols(data)]:*(1..cols(data)-1)), weight)				//column/splitting variable margins
		
		if (noisily) col	//
		
		expected_count = (col#row):/sum(row)													//compute expected frequencies
		
		if (noisily) expected_count	//
	
		df = (rows(uniqrows(data[., 2])) - 1)*(rows(uniqrows(data[., 1])) - 1)					//obtain DF
		
		number_of_estimates = (rows(uniqrows(data[., 2])))*(rows(uniqrows(data[., 1]))) - ///
		(rows(uniqrows(data[., 2])) - 1)*(rows(uniqrows(data[., 1])) - 1)
		
		converged = 1																			//is everything well? (answer is always yes here)
	
	}
	
	else converged = 0																			//...otherwise, no contingency table - all's not well...
	
	if (converged) {																			//if all's well...
		
		chi2 = sum(((observed_count - expected_count):^2):/expected_count)						//obtain chi-square value
		
		row = mm_freq(data[., 1], weight)														//row/response variable margins to infer the ll from the lr test stat
		
		expected_count = select(expected_count, observed_count:>0)								//remove expected counts that will affect a sum
		
		observed_count = select(observed_count, observed_count:>0)								//remove 0's that will affect a sum
		
		ll = sum(observed_count:*ln(observed_count:/expected_count)) + ///						//take the liklihood ratio chi-square and use the constant-only multinomial distribution to obtain model log-likelihood by working backward
		sum((ln((row:/sum(row)))):*row)							
		
		base_ll = sum((ln((row:/sum(row)))):*row)												//baseline/constant-only log-likilihood
		
	}
	
	else {																						//...otherwise return nothing
	
		chi2 = .			
		
		ll = .
		
	}
	
	return((chi2, df, ll, number_of_estimates, base_ll))										//chaid needs the chi-square, degrees of freedom, base and model log-likelihood, and number of estimates - pass it to chaid

}

end

/*Loglinear model for moptimize()*/
version 12.1

mata:

mata set matastrict on

function loglin(transmorphic estimation_object, todo, real rowvector b, ll, S, H) {

	real rowvector inter, y, xb
	
	y = moptimize_util_depvar(estimation_object, 1)
	
	xb  = moptimize_util_xb(estimation_object, b, 1)
	
	ll = -exp(xb) + xb:*y - lngamma(y:+1)
	
	S = -exp(xb) + y
	
	inter = -exp(xb)
	
	H = moptimize_util_matsum(estimation_object, 1, 1, inter, moptimize_util_sum(estimation_object, ll))
	
}

end


/*sum function for mm_collapse()*/
version 12.1

mata: 

mata set matastrict on

function dosum(real colvector data, real scalar nouse) {
	
	real scalar result

	result = sum(data)
	
	return(result)

}

end

/* programming notes and history

- chaidforest version 1.0 - date - October 27, 2014

Basic version

-----

- chaidforest version 2.0 - date - September 28, 2015

a] added version #'s to Stata and Mata commands/functions
b] checked all declarations in Mata to ensure functionality
c] if/in added to syntax to allow conditional - chaidforest - runs
d] fixed inaccurate unordered splitter chi-square computations with goodman() (row and column frequencies reversed - added more random element)
e] predicted values moved to predict command postestimation
f] fixed progress dots that extend beyond 100% w/ small # of trees
g] collapsing (by bootstrap weight) to improve run-time speed in internal chaid_g() function
h] incorporate weights into chaid by default to speed run time/fixed fweight incorporation
i] splitting AIC; merging McFadden's pseudo-R2
j] saves variables used and bootstrap data in chaidtree object, nixes predictions
k] fixed extended missing value compatability with - missing - option - ensure extended missings follow through to predict and estat
