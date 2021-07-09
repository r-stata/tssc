*! chaidforest_pr - version 2.0 - 9/14/2015 - Joseph N. Luchman

program define chaidforest_pr																					//program history and notes at end of file

version 12.1

syntax anything, [pr mode ctpr ctmode useboot]

/*set-up for prediction*/
tempvar id touse temp_dv																						//temp variable declarations

quietly generate long `id' = _n																					//id variable made for future merging

quietly generate byte `touse' = e(sample)																		//restrict to estimation sample based on e(sample) which should be in memory still

if !strlen("`pr'`mode'") local rftype "pr"																		//if there is no option specified, make empirical probabilities the default for random forest predictions

else if (strlen("`pr'`mode'") == 6) {																			//...or if both are specitied, indicate problem...

	display "{err}Only one of {opt pr} and {opt mode} can be selected."
	
	exit 198

}

else local rftype "`pr'`mode'"																					//...otherwise user specified prediction for random forest predictions

if !strlen("`ctpr'`ctmode'") local cttype "ctpr"																//make empirical probabilities the default for individual trees

else if (strlen("`ctpr'`ctmode'") == 10) {																		//problem - conflicting options for individual trees

	display "{err}Only one of {opt ctpr} and {opt ctmode} can be selected."
	
	exit 198

}

else local cttype "`ctpr'`ctmode'"																				//otherwise user specified prediction for individual trees

quietly clonevar `temp_dv' = `e(depvar)'																		//generate temporary response variable to recode missings if needed

if `=e(validmiss)' {

	local missing "missing"																						//can missings be predicted?

	quietly replace `temp_dv' = . if missing(`temp_dv')															//recode any extended missings to "." - necessary to get right number of predicted probabilities
	
}	

quietly levelsof `temp_dv' if e(sample), local(levs) `missing'													//obtain levels of response variable

capture mata: length(results)																					//is the needed "results" chaidforest object in memory?

if _rc {

	display "{err}Chaidtree object {cmd:results} not found." _newline ///
	"{cmd:chaidforest} will have to be re-executed."
	
	exit 198

}

if ("`rftype'" == "pr") capture mata: stata("describe " + ///
invtokens(st_local("anything"):+strofreal((0..cols(tokens(st_local("levs")))-1))) ", varlist")					//are there already a set of variables in the dataset with the user-specified stem?

else capture describe `anything', varlist																		//is there already a variable in the dataset with the user-specified name?

if (!_rc & regexm("`r(varlist)'", "`anything'[1]")) {															//notify user of conflict

	display "{err}`anything' already defined."
	
	exit 110

}

if ("`rftype'" == "pr") local levels = `:list sizeof levs'														//if multiple variables will be constructed, note number of levels of response variable...

else local levels = 1																							//...otherwise, there's just 1 level/variable

mata: predict_cf(results, `=e(ntree)', "`rftype'", `=e(validmiss)', "`levs'", ///								//implement predicted value computation
"`temp_dv'", "`touse'", "`anything'", "`cttype'", "`e(depvar)'", strlen("`useboot'"), ///
strtrim(regexr("`e(wexp)'", "=", "")))	

end

/*Re-invoke object to use for prediction*/
version 12.1

mata:

class chaidtree {

	real colvector clusters																						//each tree retains clusters
	
	string matrix CHAID_rules																					//each tree retains if/then statements
	
	string scalar used_vars																						//each tree retains variables used
	
	real colvector bootstrap_weight																				//each tree retains frequency weights from bootstrap or e(sample)-like data from prop_oos

}
	
end

/*Predicted values function*/
version 12.1

mata:

mata set matastrict on

real matrix predict_cf(class chaidtree results, real scalar ntree, ///
string scalar type, real scalar missing, string scalar levs, string scalar dvname, ///
string scalar touse, string scalar predname, string scalar cttype, string scalar displayname, ///
real scalar bootstrap_use, string scalar weight_var) 
{
	
	/*declarations*/
	real matrix preds, predicted, matchup
	
	real colvector current_preds, dv, weights, rand_resolve, tlevs
	
	real scalar countup, varnum, x, y
	
	string colvector storednames
	
	/*begin set-up*/
	countup = -1																								//placeholder which is incremented when naming variables
	
	weights = 1																									//make default weight value 1
	
	if (sign(strlen(weight_var))) weights = st_data(., st_varindex(weight_var), st_varindex(touse))				//if there is an 'fweight', use it
	
	if (bootstrap_use) weights = results.bootstrap_weight														//if the user would prefer making the results depend on the bootstrapped results, replace weight with the bootstrapped weights
	
	tlevs = strtoreal(tokens(levs)')																			//tokenizes levels of response variable
	
	dv = st_data(., dvname, st_varindex(touse))																	//pull in the response variable from Stata
	
	if (missing) {																								//remove missings from levels of response variable - calls them -1's, pull them into frequncy computations
	
		levs = subinstr(levs, ".", "-1")
	
		tlevs = editmissing(tlevs, -1)																	
	
		dv = editmissing(dv, -1)
	
	}
	
	/*process individual trees - ready them for incorporation to individual-level predictions*/
	for (x = 1; x <= ntree; x++) {																				//for each tree in the chaidforest...
		
		if (cttype == "ctmode") {																				//if the desired predicted value per observation for this specific tree is the modal value...
		
			matchup = mm_collapse(dv, weights, results[x].clusters, &mode2())									//find the modal value of the response for this tree by cluster/node
			
			current_preds = rowsum((J(1, rows(matchup), ///
			results[x].clusters):==(matchup[., 1]')):*matchup[., 2]')											//"spread" the appropriate modal response variable value to members of the appropriate cluster/node
		
			current_preds = current_preds:*exp(ln(results[x].clusters:!=.))										//replace non-sampled values with missing
		
		}
		
		else {																									//...otherwise the desired prediction is the empirical proportion falling into each response category per observation for this specific tree
		
			for (y = 1; y <= rows(tlevs); y++) {																//for each level of the response variable...
		
				matchup = mm_collapse(dv:==tlevs[y], weights, ///												//obtain mean/proportion in focal level of response variable by cluster for this tree
				results[x].clusters)
				
				matchup = rowsum((J(1, rows(matchup), ///														//"spread" the appropriate proportion value to members of the appropriate cluster/node
				results[x].clusters):==(matchup[., 1]')):*matchup[., 2]')
				
				if (y == 1) current_preds = matchup:*exp(ln(results[x].clusters:!=.))							//if at the first level, make it the leading column vector, all non-sampled observations are assigned as missing...
				
				else current_preds = current_preds, matchup:*exp(ln(results[x].clusters:!=.))					//...otherwise, make the focal column vector follow the lead, all non-sampled observations are assigned as missing...
				
			}
		
		}
		
		if (x == 1) preds = current_preds																		//if at the first tree, make it the leading column vector for the forest's predictions...
		
		else preds = (preds, current_preds)																		//...otherwise, make the focal tree's predictions follow the lead
		
	}	

	/*process across trees to obtain individual-level predictions*/
	for (x = 1; x <= rows(preds); x++) {																		//loop over observations...
			
		if (x == 1) {																							//if at the first observation...
			
			if (cttype == "ctpr") predicted = ///																//if tree-level empirical probabilities asked for, average proportions in each level of the response across all trees in the forest for the focal individual...
			mm_collapse(preds[x, .]', 1, J(cols(preds)/rows(tlevs), 1, (1::rows(tlevs))))[., 2]'
			
			else if ((cttype == "ctmode") & (type == "pr")) predicted = ///										//...or if tree-level modal values were asked for, yet the predicted probabilities in each category across all trees are desired, find the proportion of all trees predicting each level of the response variable for the focal individual...
			(mm_freq(preds[x, .]', 1, tlevs)'):/sum(mm_freq(preds[x, .]', 1, tlevs)')
			
			else predicted = mode(preds[x, .]', levs, 1)														//...otherwise, find the modal value across all trees in the forest given the modal values at each individual tree
			
		}
		
		else {																									//...otherwise, for all other observations
		
			if (cttype == "ctpr") predicted = ///																//if tree-level empirical probabilities asked for, average proportions in each level of the response across all trees in the forest for the focal individual...
			predicted \ mm_collapse(preds[x, .]', 1, J(cols(preds)/rows(tlevs), 1, (1::rows(tlevs))))[., 2]'
					
		
			else if ((cttype == "ctmode") & (type == "pr")) predicted = (predicted \ ///						//...or if tree-level modal values were asked for, yet the predicted probabilities in each category across all trees are desired, find the proportion of all trees predicting each level of the response variable for the focal individual...
			(mm_freq(preds[x, .]', 1, tlevs)'):/sum(mm_freq(preds[x, .]', 1, tlevs)'))
			
			else predicted = (predicted \ mode(preds[x, .]', levs, 1))											//...otherwise, find the modal value across all trees in the forest given the modal values at each individual tree
			
		}

	}
	
	/*finalize predictions*/
	if ((cttype == "ctpr") & (type == "mode")) { 																//if tree-level empirical probabilities asked for, yet the user wants modal/most likely values based on those averaged probabilities...
	
		matchup = predicted:==rowmax(predicted)																	//first, identify which row has the highest probability for each observation
		
		if (sum(matchup):>1 != rows(matchup)) {																	//in the case there are ties...
		
			rand_resolve = ///																					//randomly resolve which is predicted
			((rowsum(matchup):>1):*runiform(rows(matchup), rows(tlevs))):*matchup				
			
			matchup = matchup:+((rand_resolve:==rowmax(rand_resolve)):*(rowsum(matchup):>1))					//merge the randomly chosen values in to replace the ties
			
		}
		
		predicted = rowsum(matchup:*tlevs'):*editvalue((rowmax(predicted):!=.), 0, .)							//apply the levels to the binaries indiciating column associated with each level - basically, this assigns the predicted value and ensures missings persist
	
	}
	
	if (missing) predicted = editvalue(predicted, -1, .p)														//if there are missings, replace -1's with "predicted missings" or ".p"
	
	if (type == "mode") {																						//if a modal value only is desired...
	
		varnum = st_addvar("double", predname)																	//generate a double with the desired name
		
		mata: st_varlabel(varnum, "Modal value: " + displayname)												//give the new variable an appropriate label
		
		storednames = predname																					//storednames is more flexible than predname here, just use storednames (shortens syntax)
		
	}
		
	else {																										//...otherwise the user asked for empirical probabilities
	
		for (y = 1; y <= cols(tokens(levs)); y++) {																//for each level of the response...
		
			varnum = st_addvar("double", predname + strofreal(++countup))										//generate a double as the predict function would
			
			if (tokens(levs)[y] == "-1") ///																	//if the value of the level is -1, replace it with ".p" - give the variable a label...
			st_varlabel(varnum, "Pr(" + displayname + "==.p)")
						
			else st_varlabel(varnum, "Pr(" + displayname + "==" + tokens(levs)[y] + ")")						//otherwise give the variable a label as predict would
			
			if (y == 1) storednames = st_varname(varnum)														//if the first level lead the names...
			
			else storednames = (storednames, st_varname(varnum))												//...otherwise follow the leader
		
		}
	
	}
	
	st_store(., storednames, st_varindex(touse), predicted)														//put the predictions into Stata as requested

}

end

/*Mata function to return a modal value across all trees in the forest (ties are randomly decided)*/
version 12.1

mata:

mata set matastrict on

function mode(real colvector data, string scalar levs, real scalar nouse) {
	
	real scalar rand_resolve
	
	transmorphic result

	result = mm_freq(data, 1, strtoreal(tokens(levs)'))															//get frequencies on focal variable
	
	if (!sum(result)) result = .																				//if frequencies are 0, assign missing
	
	else {
	
		result = strtoreal(select(tokens(levs)', result:==max(result)))											//retain the level(s) associated with the highest frequency
	
		if (rows(result) > 1) {																					//if there's a tie...
	
			rand_resolve = mm_sample(1, rows(result))															//randomly sample a value from "result"
	
			result = result[rand_resolve, 1]																	//assign the randomly sampled value to "result"
		
		}
		
	}	
	
	return(result)																								//return the modal value

}

end

/*Mata function to return a modal value by cluster within a tree (ties are randomly decided)*/
version 12.1

mata:

mata set matastrict on

function mode2(real colvector data, real scalar nouse) {

	real matrix result, rand_resolve

	result = mm_freq(data, 1, uniqrows(data))																	//get frequencies on focal variable
	
	result = select(uniqrows(data), result:==max(result))														//retain the level(s) associated with the highest frequency
	
	if (rows(result) > 1) {																						//if there's a tie..
	
		rand_resolve = runiform(rows(result), 1)																//obtain random numbers
	
		result = select(result, rand_resolve:==max(rand_resolve))												//select the max of the random numbers ans assign it to "result"
		
	}
	
	return(result)																						//return the mode

}

end



/* programming notes and history

- chaidforest_pr version 1.0 - date - October 27, 2014

Basic version

-----

- chaidforest_pr version 2.0 - date - September 14, 2015

a] more prediction options (empirical probabilities at individual tree-level) - moves all prediction to this function
b] nixes lasting "predicted" matrix
c] allows user to "use" bootstrap weights to form predicted values (for fun!)
d] compatible with, and checks for, fweights
