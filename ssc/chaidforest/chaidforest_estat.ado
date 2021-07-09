*! chaidforest_estat - version 1.0 - 10/12/2015 - Joseph N. Luchman

program chaidforest_estat, eclass																			//program history and notes at end of file

version 12.1

syntax anything [, TRee(integer -1) INSample GRaph mata NOIsily]

if ("`anything'" == "prox") {																				//if a proximity matrix is desired...

	if strlen("`mata'") {																					//if the matrix should be saved to Mata...
	
		mata: prox = proximity(results, `=e(ntree)', sign(strlen("`mata'")))								//conduct proximity computation, keep the matrix in Mata
		
		display "{txt}Matrix {cmd:prox} created in Mata" _newline ///
		"see {matacmd mata describe prox}"
		
	}
	
	else {																									//...otherwise if the matrix should be added to ereturned results
	
		quietly mata: proximity(results, `=e(ntree)', sign(strlen("`mata'")))											

		display "{txt}Matrix {cmd:e(prox)} added to estimation results" _newline ///
		"see {stata ereturn list}"
		
	}
		
}

else if ("`anything'" == "fit") {																			//...or if in or out of sample overall fit based on Cramer's V is desired...

	mata: V_fit(results, `=e(ntree)', "`e(depvar)' `e(splitvars)'", sign(strlen("`insample'")), ///			//conduct the fit computation in Mata
	`=e(dvorder)', "", sign(strlen("`noisily'")), `=e(validmiss)', ///
	strtrim(regexr("`e(wexp)'", "=", "")), `=e(w_o_replace)')
	
	ereturn scalar fit = r(fit)																				//V_fit() produces an "r(fit)" metric - "ereturn" it
	
	if strlen("`insample'") display "{txt}In-sample only fit: {res}{col 40}" %16.4f e(fit)					//if "in-sample" estimates are requested - note this is the nature of the metric...
	
	else display "{txt}Resample fit: {res}{col 40}" %16.4f e(fit)											//...otherwise "out-of-sample" estimates are requested - noted in the display
	
}

else if ("`anything'" == "import") {																		//...or if a permutation importance matrix is desired...

	mata: permute_import(results, `=e(ntree)', ///															//conduct the importance computations in Mata
	"`e(depvar)' `e(splitvars)'", sign(strlen("`insample'")), ///
	`=e(dvorder)', sign(strlen("`noisily'")), `=e(validmiss)', strtrim(regexr("`e(wexp)'", "=", "")), ///
	`=e(w_o_replace)')
	
	tempname import																							//define temporary matrix to pass on returned matrix to ereturn
	
	matrix `import' = r(import)																				//pass returned matrix to temp for further processing
	
	matrix colnames `import' = `e(splitvars)'																//provide the columns names of the variables
	
	matrix rownames `import' = rank raw																		//label the rows 
	
	ereturn matrix import = `import'																		//ereturn the importance matrix
	
	if strlen("`insample'") display "{txt}In-sample only importance:"										//if "in-sample" estimates are requested - note this is the nature of the metric...
	
	else display "{txt}Resample permutation importance:"													//...otherwise "out-of-sample" estimates are requested - noted in the display
	
	matrix list e(import), noheader																			//show the obtained matrix
	
}



else if ("`anything'" == "gettree")	{ 																		//...or if the results from a tree within the chaidforest is desired...

	if (`tree' > e(ntree)) | (`tree' <= 0) {																//must be a valid tree
	
		display "{err}Tree requested in {opt tree()} not valid."
		
		exit 198
	
	}
	
	capture summarize _CHAID_`tree' bwgt_`tree', meanonly													//see if _CHAID_ and bwgt_ variables corresponding to focal tree already exist
	
	if _rc == 0 drop _CHAID_`tree' bwgt_`tree'																//if _CHAID_ and bwgt_ variables exist, drop them

	mata: get_rules(results, `tree', "`e(depvar)' `e(splitvars)'", `=e(dvorder)', `=e(validmiss)', ///		//conduct the "rule generation" based on the stored information from the chaidtree object with a specific tree
	strtrim(regexr("`e(wexp)'", "=", "")), `=e(w_o_replace)')			

	label variable _CHAID_`tree' "CHAID-defined cluster for tree `tree'"
	
	label variable bwgt_`tree' "bootstrapped frequency weight for tree `tree'"
	
	if strlen("`graph'") Display, tree(`tree')																//if desired, generate a graph and results display as that from chaid
	
}

else { 																										//...othwerwise the estat command is unrecognized

	display "{err}{cmd:estat} command not recognized."
	
	exit 199
	
}

end

/*Program to allow returning r-class results*/
program return_local, rclass

version 12.1

syntax anything

gettoken one two: anything, bind																			//split the syntax into components to return it - bind parentheses; all components are intended to be parentheses bound

local one = strtrim(subinstr(subinstr("`one'", "(", "", .), ")", "", .))									//remove binding parentheses in syntax

gettoken three four: one																					//split components of parentheses bound syntax

return local `three' "`four'"																				//return given the name 'three' the string found in 'four' - basically always used to return 'rules'

while strlen("`two'") {																						//while there are other rules left...

	gettoken one two: two, bind																				//...again, split the syntax into components to return it - bind parentheses; all components are intended to be parentheses bound

	local one = strtrim(subinstr(subinstr("`one'", "(", "", .), ")", "", .))								//...again, remove binding parentheses in syntax

	gettoken three four: one																				//...again, split components of parentheses bound syntax

	return local `three' "`four'"																			//...again, return given the name 'three' the string found in 'four' - basically always used to return 'rules'

}

end

/*Re-invoke object for CHAID forests use*/
version 12.1

mata:

mata set matastrict on

class chaidtree {

	real colvector clusters																					//each tree retains clusters
	
	string matrix CHAID_rules																				//each tree retains if/then statements
	
	string scalar used_vars																					//each tree retains variables used
	
	real colvector bootstrap_weight																			//each tree retains frequency weights from bootstrap or e(sample)-like data from prop_oos

}
	
end

/*Mata function to process rules*/
version 12.1

mata:

mata set matastrict on

function get_rules(class chaidtree results, real scalar tree, string scalar fit_inputs, ///
real scalar dvordered, real scalar missing, string scalar weight_var, real scalar w_o_replace) {

	/*declarations*/
	real matrix variable_locations	
	
	real scalar path, variable
	
	string matrix rules, parsed_rules, variable_matrix, variable_levels, ///
	paths
	
	string rowvector variables, pass_locals, fullpath
	
	string scalar esample
	
	/*process resuls from specific tree in a way similar to base CHAID*/
	esample = st_tempname(1)																				//establish tempname for e(sample) for use by Mata
	
	stata("generate byte " + esample + " = e(sample)")														//generate variable that can be used by Mata

	rules = results[tree].CHAID_rules																		//pull the rules matrix from CHAIDtree object for the tree in question to parse and return
	
	variables = results[tree].used_vars																		//pull the variables used in focal CHAID tree from CHAIDtree object
	
	if (rows(rules) > 1) {																					//if there were any results, parse rules to pass...
	
		variable_matrix = ///																				//first, generate a block diagonal matrix "spreading" splitting variable names across blocks for matching
		I(cols(variables[2..cols(variables)]))#J(rows(rules[2..rows(rules), 2..cols(rules)]), ///			
		cols(rules[2..rows(rules), 2..cols(rules)]), 1):* ///
		vec(J(rows(rules[2..rows(rules), 2..cols(rules)]), 1, variables[2..cols(variables)]))
		
		parsed_rules = J(cols(variables[2..cols(variables)]), cols(variables[2..cols(variables)]), ///		//then generate a matrix conformable with the variable_matrix above with all rules contained repeated to allow for matching
		rules[2..rows(rules), 2..cols(rules)])
		
		parsed_rules = regexm(parsed_rules, variable_matrix):*variable_matrix								//make indicator matrix indicating matches of variable names in specific locations corresponding to the CHAID rules
		
		variable_locations = regexm(parsed_rules, variable_matrix):*I(cols( ///								//notes the locations of a 'match' from the variables_matrix in the parsed_rules matrix
		variables[2..cols(variables)]))#J(rows(rules[2..rows(rules), 2..cols(rules)]), ///
		cols(rules[2..rows(rules), 2..cols(rules)]), 1)
		
		variable_levels = subinstr(subinstr( ///															//cuts out the variable name and underscore from the rules to keep only the value levels (also changes 'ms' to '.')
		J(cols(variables[2..cols(variables)]), cols(variables[2..cols(variables)]), ///
		rules[2..rows(rules), 2..cols(rules)]), (parsed_rules:+"_"), "", .), "ms", ".")
		
		variable_levels = variable_levels:*variable_locations												//omit all entries in places where there are no valid rules in the paths
		
		paths = ((parsed_rules:+"@"):*variable_locations):+variable_levels									//pair up variable names with levels and add in '@' to complete the paths matrix
	
		for (path = 1; path <= rows(rules) - 1; path++) {													//for each row of the paths section of the rules matrix...
		
			for (variable = 1; variable <= cols(variables) - 1; variable++) { 								//...and for each column potentially containing a rule
			
				if (variable == 1) fullpath = paths[path, 1..cols(rules)-1]									//put components of paths matrix into single column to collapse cleanly - first column
				
				else fullpath = fullpath:+paths[path+(variable-1)*(rows(rules)-1), ///						//put components of paths matrix into single column to collapse cleanly - additional columns beyond the first
				(cols(rules)-1)*(variable-1)+1..(cols(rules)-1)*variable]					
				
			}
			
			if (path == 1) pass_locals = "(path1 " + ///													//enclose the entire entry in parentheses to parse and return by return_local - first path
			invtokens(stritrim(strtrim(subinword((fullpath:+";"), ";", "", .)))) + ")"
			
			else pass_locals = pass_locals, "(path" + strofreal(path)+ " " ///								//enclose the entire entry in parentheses to parse and return by return_local - additional paths beyond the first
			+ invtokens(stritrim(strtrim(subinword((fullpath:+";"), ";", "", .)))) + ")"
		
		}
		
		pass_locals = pass_locals, "(splitvars " + invtokens(variables[2..cols(variables)]) + ")"			//add in splitting variables to be returned by return_locals
	
	}
	
	/*return results*/
	else pass_locals = "(splitvars " + invtokens(variables[2..cols(variables)]) + ")"						//...otherwise return the splitvars as the only data to pass
	
	stata("return_local " + invtokens(pass_locals))															//invoke return local program with contents of pass_locals
	
	V_fit(results[tree], 1, fit_inputs, 1, dvordered, "", 0, missing, weight_var, w_o_replace)				//conduct the fit computation in Mata
		
	st_numscalar("r(N_clusters)", rows(rules) - 1)															//return number of clusters in focal CHAID tree
	
	if (rows(rules) > 1) {																					//if there are rules to return...
	
		st_matrix("r(sizes)", mm_freq(select(results[tree].clusters, results[tree].clusters:!=.))')			//return the sizes of each cluster - not weighted by bootstraps
	
		st_matrix("r(branches)", (rowsum(sign(strlen(rules[2..rows(rules), 2..cols(rules)]))))')			//return the number of branches made in each cluster
		
	}
	
	else {																									//...otherwise return the non-informative results
	
		st_matrix("r(sizes)", sum(sign(results[tree].clusters)))											//return number of non-0 weighted obs in first cluster
		
		st_matrix("r(branches)", 1)																			//only one branch
	
	}
	
	variable_locations = st_addvar(("float", "int"), (("_CHAID_" + strofreal(tree)), ///					//add 2 variables, bwgt_ and _CHAID - corresponding to the CHAID clusters as well as the bootstrapped frequency weight
	("bwgt_" + strofreal(tree))))
	
	st_store(., (("_CHAID_" + strofreal(tree)), ("bwgt_" + strofreal(tree))), ///							//store the _CHAID cluster and bootstrap weight data in the new variables
	st_varindex(esample), (results[tree].clusters, results[tree].bootstrap_weight))

}

end


/*Mata function to generate a proximity matrix between observations*/
version 12.1

mata:

mata set matastrict on

function proximity(class chaidtree results, real scalar number_of_trees, real scalar mata) {
	
	/*declarations*/
	real matrix clusters, proximity, valid_comparisons
	
	real scalar tree, obs
	
	string scalar matname
	
	/*set up for processing*/
	for (tree = 1; tree <= number_of_trees; tree++) {														//for each tree in the forest...
	
		if (tree == 1) clusters = results[1].clusters														//if the focal tree is first, make it the leader...
		
		else clusters = (clusters, results[tree].clusters)													//...otherwise, the focal tree follows the leader
		
	}
	
	proximity = valid_comparisons = J(rows(clusters), rows(clusters), 0)									//make a "dummy" proximity and valid_comparisons matrix of 0's
	
	clusters = clusters:*(clusters:!=.) + runiform(rows(clusters), cols(clusters)):*(clusters:==.)			//replace all missing values with random unformly distributed value in 0-1 range to (basically) ensure no matches on missings
	
	/*obtain matches*/
	for (obs = 2; obs <= rows(clusters) - 1; obs++) {														//foreach obervation...
		
		proximity[obs..rows(proximity), obs-1] = ///														//obtain number of matches with each other observation as it relates to cluster number - lower triangle
		rowsum((clusters[obs..rows(proximity), .]:==J(rows(clusters)-(obs-1), 1, clusters[obs-1, .])))
		
		valid_comparisons[obs..rows(valid_comparisons), obs-1] = ///										//obtain number of valid comparisons (i.e., in which both observations are non-missing - lower triangle
		rowsum(((clusters[obs..rows(valid_comparisons), .]:!=.):==J(rows(clusters)-(obs-1), 1, ///
		(clusters[obs-1, .]:!=.))))		
		
	}
	
	proximity = proximity + proximity'																		//addin the upper triangle to make symmetric - proximity
	
	valid_comparisons = valid_comparisons + valid_comparisons'												//addin the upper triangle to make symmetric - valid_comparisons
	
	proximity = (proximity + I(rows(clusters))):/(valid_comparisons + I(rows(clusters)))					//obtain proportion matching
	
	proximity = sqrt(1:-proximity)																			//Breiman suggests making a dissimilarity matrix by reflecting across 0 and square-rooting
	
	/*return results*/
	if (!mata) {																							//if a Stata matrix...
	
		matname = st_tempname(1)																			//get a tempname
	
		st_matrix(matname, proximity)																		//save the proximity matrix as tempname
	
		stata("ereturn matrix prox " + matname)																//add the proximity matrix to ereturned results
		
	}
	
	else return(proximity)																					//...otherwise return Mata proximity matrix - necessary for large numbers of observations
	
}
	
end

/*Mata function to estimate permuataion importance - calls V_fit()*/
version 12.1

mata:

mata set matastrict on

function permute_import(class chaidtree results, real scalar number_of_trees, ///
string scalar splitting_variables, real scalar insample, real scalar ordered_response, ///
real scalar display, real scalar missing, string scalar weight_var, real scalar w_o_replace) {
	
	/*declarations*/
	real colvector importance
	
	real scalar variable
	
	/*proceed through variables to obtain importance*/
	importance = J(1, cols(tokens(splitting_variables)) - 1, .)												//generate dummy vector for fit values

	for (variable = 1; variable <= cols(tokens(splitting_variables)) - 1; variable++) {						//for each variable in the chaidforest() run...
		
		if (display) tokens(splitting_variables)[variable]	/**/		
		
		V_fit(results, number_of_trees, splitting_variables, insample, ordered_response, ///				//proceed by feeding the data to V_fit() and choosing a permutation variable
		tokens(splitting_variables)[variable + 1], display, missing, weight_var, w_o_replace)		
		
		importance[variable] = st_numscalar("r(fit)")														//record the fit value as permuted
	
	}
	
	st_matrix("r(import)", (mm_ranks(importance')' \ importance))											//return the ranked and raw importance vectors

}

end

/*Postestimation function to obtain overall model fit in- or out-of-sample; based on Cramer's V*/
version 12.1

mata:

mata set matastrict on

function V_fit(class chaidtree results, real scalar number_of_trees, ///
string scalar splitting_variables, real scalar insample, ///
real scalar ordered_response, string scalar permute, real scalar display, real scalar missing, ///
string scalar weight_var, real scalar w_o_replace) {
	
	/*declarations*/
	real matrix data, data_permuted
	
	real colvector unused_ob, clusters_reproduced, build_rule, results_vec, weights, ///
	weights_permuted
	
	real scalar V, V_sum, reduce_sum, permute_proceed, splitting_var, tree, path, rule
	
	string matrix current_rules
	
	string colvector names, variable_list, variable_list_permuted
	
	string scalar esample
	
	/*set-up for fit computation*/
	esample = st_tempname(1)																				//establish tempname for e(sample) when used by Mata
	
	stata("generate byte " + esample + " = e(sample)")														//generate "touse" variable that can be referenced by Mata
	
	data = st_data(., tokens(splitting_variables), st_varindex(esample))									//pull data into Mata
	
	if (missing) data = editmissing(data, .)																//change extended missings to regular missing for all variables (response and splitters)
	
	if (strlen(weight_var)) weights = weights_permuted = ///												//if there is an 'fweight', use it...
	st_data(., st_varindex(weight_var), st_varindex(esample))				
	
	else weights = weights_permuted = J(rows(data), 1, 1)													//...otherwise assume equal weights
	
	names = tokens(splitting_variables)																		//split up variable names list
	
	variable_list = names[1]																				//start with response variable in actual names used list
	
	V_sum = reduce_sum = 0																					//make summed fit metric (to eventually average) and reduced sum (i.e., reduces denominator of average) variable start at 0
	
	for (splitting_var = 2; splitting_var <= cols(tokens(splitting_variables)); splitting_var++) {			//syntax to expand the imported data to a form usable by CHAID_rules - creates binary variables indicating levels of the splitting variable
	
		names[splitting_var] = ///																			//take name of splitting variable and "spread" it to all "levelsof" that variable separated by "_" as this is how they're registered in CHAID_rules
		invtokens((tokens(splitting_variables)[splitting_var]:+"_"):+strofreal(uniqrows(data[., ///						
		cols(data)+(splitting_var-cols(tokens(splitting_variables)))])'))
		
		variable_list = variable_list, tokens(names[splitting_var])											//add the newly created names to the names vector to be matched on later
	
		if (splitting_var < cols(tokens(splitting_variables))) ///											//if the end of the variable list has not been reached, expand the data into set of binaries reflecting levels of the splitting variable, must "fit" the binaries in where the variable was to match with the names created...
		data = data[., 1..cols(data)+(splitting_var-cols(tokens(splitting_variables)))-1], ///
		J(1, rows(uniqrows(data[., cols(data)+(splitting_var-cols(tokens(splitting_variables)))])), ///
		data[., cols(data)+(splitting_var-cols(tokens(splitting_variables)))]):==uniqrows(data[., ///
		cols(data)+(splitting_var-cols(tokens(splitting_variables)))])', ///
		data[., cols(data)+(splitting_var-cols(tokens(splitting_variables)))+1..cols(data)]
		
		else ///																							//...otherwise the end of the variable list has been reached, expand the data into set of binaries reflecting levels of the splitting variable which can be plugged in at the end
		data = data[., 1..cols(data)-1], ///
		J(1, rows(uniqrows(data[., cols(data)])), data[., cols(data)]):==uniqrows(data[., cols(data)])'
	
	}
	
	/*computing fit and executing permutations*/
	for (tree = 1; tree <= number_of_trees; tree++) {														//for each tree...
	
		if (sign(strlen(permute))) permute_proceed = sum(strmatch(results[tree].used_vars, permute))		//if this is a part of a call from "permute_import()," only proceed if the variable chosen is in "used_vars"... 
		
		else permute_proceed = 1																			//...otherwise this is a "regular" V_fit() call and just proceed
		
		if (permute_proceed) {																				//if the variable is present or this is a regular run...
		
			if (sign(strlen(permute))) {																	//again, if this is a part of a call from "permute_import()" ...															

				variable_list_permuted  = variable_list, ""													//add a dummy-space to the list of "levelsof"-d splitting variables
				
				data_permuted = data, J(rows(data), 1, .)													//add a column of missings to the data
				
				if (strlen(weight_var)) data_permuted = mm_expand(data_permuted, weights) 					//if there are frequency weights - expand the data to allow for an accurate permutation
				
				data_permuted = select(data_permuted, ///													//permute or jumble() the data associated with the variable to permute, put it at the end of the data
				!regexm(variable_list_permuted, permute + "_[0-9]+")), ///		
				select(data_permuted, regexm(variable_list_permuted, permute + ///
				"_[0-9]+"))[jumble(1::rows(data_permuted)), .]

				if (strlen(weight_var)) {								
				
					weights_permuted = mm_freq(rowsum(data_permuted:*(10:^(cols( ///						//if there are frequency weights, obtain the updated frequency weights based on the newly permuted data
					data_permuted)..1)):/10), 1, uniqrows(rowsum(data_permuted:*(10:^( ///
					cols(data_permuted)..1)):/10)))

					data_permuted = mm_collapse(data_permuted, 1, (rowsum(data_permuted:*( ///				//collapse data based on newly pemuted variables
					10:^(cols(data_permuted)..1)):/10)))[., 2..cols(data_permuted)+1] 
					
				}
				
				variable_list_permuted = select(variable_list_permuted, ///									//take the names associated with the permuted variable and put them at the end where the data are now
				!regexm(variable_list_permuted, permute + "_[0-9]+")), ///		
				select(variable_list_permuted, regexm(variable_list_permuted, permute + "_[0-9]+"))
						
			}
			
			else {																							//accomodate the possibility of permuted data
			
				variable_list_permuted = variable_list
				
				data_permuted = data
				
			}
			
			if ((insample) & !sign(strlen(permute))) unused_ob = results[tree].bootstrap_weight				//if in-sample and not permuted, just use boostrap weight...
			
			else if ((insample) & sign(strlen(permute))) unused_ob = weights_permuted						//...otherwise if in-sample and permuted, use the newly formed weights from above...
			
			else unused_ob = mm_sample(sum(weights_permuted), rows(weights_permuted), ., ///				//...otherwise out-of-sample, based on the weight vector - do a fresh resampling
			weights_permuted, w_o_replace, 1)					
					
			if ((insample) & !(sign(strlen(permute)))) clusters_reproduced = ///							//if in-sample fit is desired and this is not part of permute_import() run, use all the originally obtained clusters, changing all missing clusters to cluster "0"...
			editmissing(results[tree].clusters, 0)
		
			else {																							//...otherwise out-of-sample fit and/or a permute_import() run
		
				current_rules = results[tree].CHAID_rules													//pull in CHAID rules to apply to new observations

				clusters_reproduced = J(rows(data_permuted), 1, 0)											//start with clusters at "0" or, basically, missing
				
				for (path = 2; path <= rows(current_rules); path++) {										//for each row/path in CHAID rules...				
		
					build_rule = J(rows(data_permuted), 1, 1)												//refresh the rule "builder" - start with everyone in-cluster and let them drop out
				
					for (rule = 2; rule <= cols(current_rules); rule++) {									//for each specific rule in the rules that needs accounting for...
			
						if (cols(tokens(current_rules[path, rule])) > 0) ///								//There are variables to account for in the focal rule, multiply all the binaries from the applicable splitting variable levels (i.e., the ones that match the rules) with one another as well as the current state of build_rule - this is an "and" or intersection situation, must meet all the rules' criteria or the observation gets a 0...
						build_rule = build_rule:*sign(rowsum(select(data_permuted, ///
						colsum(J(cols(tokens(current_rules[path, rule])), 1, ///
						variable_list_permuted):==tokens(current_rules[path, rule])'))))			
						

					}
			
					clusters_reproduced = clusters_reproduced:+(sign(unused_ob):*(build_rule:*(path-1)))	//build the new cluster with the set of rules just obtained and its own unique number
			
					if (display) mm_freq(clusters_reproduced), uniqrows(clusters_reproduced)	//
				
				}
		
			}
		 
			if ((sum(clusters_reproduced) > 0) & (rows(uniqrows(select(clusters_reproduced, ///				//if there are any non-0 clusters, and the number of clusters and levels of the response is more than 1...
			sign(unused_ob)))) > 1) & (rows(uniqrows(select(data_permuted[., 1], sign(unused_ob)))) > 1)) {
				
				results_vec = goodman((data_permuted[., 1], clusters_reproduced), ///						//implement loglinear/poisson model to obtain expected counts
				ordered_response, display, unused_ob)
			
			
				V = sqrt((results_vec[1]/sum(unused_ob))/min( ///											//compute the chi-square
				(rows(uniqrows(data[., 1]))-1, rows(uniqrows(clusters_reproduced))-1)))
				
		
			}
		
			else {																							//...otherwise the variable is not included
		
				V = 0																						//don't add to the "fit" sum
			
				reduce_sum++																				//increment "reduce_sum" to adjust average for invalid comparison (not a "true" 0)
			
			}
			
		}
		
		else {																								//...otherwise the variable is not included
		
			V = 0																							//don't add to the "fit" sum
		
			reduce_sum++																					//increment "reduce_sum" to adjust average for invalid comparison (not a "true" 0)
		
		}
		
		if (display) V	//
		
		V_sum = V_sum + V																					//add the value in "V" to the "fit" sum
		
	}
	
	st_numscalar("r(fit)", V_sum/(number_of_trees - reduce_sum))											//average the fit sum by the valid number of V's and pass to Stata as r() scalar

}

end


/*replayable display - copied from chaid.ado*/
program Display

version 12.1

syntax, tree(integer)

display _newline "{res}Chi-Square Automated Interaction Detection (CHAID)" ///
" Tree Branching Results for Tree `tree'" _newline "{txt}{hline 80}" _newline

if (r(N_clusters) == 1) display "{res}No clusters uncovered.  Cluster #1 is null."

else {

	preserve
	
	clear
	
	mata: st_addobs(st_numscalar("r(N_clusters)"))
	
	quietly mata: labels = st_tempname(max(st_matrix("r(branches)")) + 1)
	
	quietly mata: st_addvar("str100", labels)
	
	forvalues x = 1/`=r(N_clusters)' {
		
		local parse "`r(path`x')'"
		
		gettoken first second: parse, parse(";")
		
		local count = 0
		
		while ("`second'" != "") {
		
			mata: st_local("labvar", labels[1, `++count'])
		
			quietly replace `labvar' = "`first'" in `x'
			
			gettoken first second: second, parse(";")
			
			gettoken first second: second, parse(";")
		
		}
		
		mata: st_local("labvar", labels[1, cols(labels)])
		
		quietly replace `labvar' = "Cluster #`x'" in `x'
	
	}
	
	mata: st_local("all", invtokens(labels))
	
	sort `all'
	
	quietly putmata namemat = (`all'), replace
	
	mata: namemat'
	
	mata: namemat =  namemat[., 1..cols(namemat)-1]'

	mata: namemat = (J(1, cols(namemat), "root") \ namemat)
	
	clear
	
	mata: count = 0
	
	mata: column = 1

	local column = 1

	mata: st_local("totcol", strofreal(cols(namemat)))
	
	quietly {

		generate long x = .
	
		generate long y = .

		generate int col = .

		generate byte down = .
	
		generate str100 label = ""

	}
	
	local justup = 0
	
	forvalues y = 1/`totcol' {

		mata: currentvec = namemat[., column]
	
		if (`y' == 1) {
	
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = 1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}
		
			quietly replace down = 1 if missing(down)
		
			mata: countback = st_data(2::count-1, (st_varindex("x"), st_varindex("y")))
		
			mata: countback = sort(((rows(countback)::1), countback), 1)
		
			mata: st_addobs(rows(countback))
		
			mata: st_store(count+1::count+rows(countback), (st_varindex("x"), st_varindex("y")), countback[., 2..cols(countback)])
		
			mata: count = count + rows(countback)
		
			quietly replace down = 0 if missing(down)
		
			quietly replace col = `y' if missing(col)
		
			mata: column++
	
		}
	
		else if (`y' == `totcol') {
	
			mata: prevvec = namemat[., column-1]
		
			mata: retrace1 = currentvec:==prevvec
		
			mata: retrace2 = currentvec:!=""
		
			mata: retrace = retrace1:*retrace2
		
			mata: obsvd = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: obsvd = select(obsvd[., (1..2,4)], obsvd[.,3]:==column-1)
		
			mata: obsvd = select(obsvd[., 1..2], obsvd[.,3]:==1)
		
			mata: obsvd = select((obsvd \ J(rows(retrace)-rows(obsvd), 2, .)), retrace)
		
			mata: st_addobs(rows(obsvd))
		
			mata: st_store(count+1::count+rows(obsvd), (st_varindex("x"), st_varindex("y")), obsvd)
		
			mata: count = count + rows(obsvd)
		
			mata: currentvec = select(currentvec, abs(retrace:-1))
		
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = rows(obsvd)+1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}	
		
			quietly replace col = `y' if missing(col)
		
			quietly replace down = 1 if missing(down)
	
		}
	
		else {
	
			mata: prevvec = namemat[., column-1]
		
			mata: retrace1 = currentvec:==prevvec
		
			mata: retrace2 = currentvec:!=""
		
			mata: retrace = retrace1:*retrace2
		
			mata: obsvd = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: obsvd = select(obsvd[., (1..2,4)], obsvd[.,3]:==column-1)
		
			mata: obsvd = select(obsvd[., 1..2], obsvd[.,3]:==1)
		
			mata: obsvd = select((obsvd \ J(rows(retrace)-rows(obsvd), 2, .)), retrace)
		
			mata: st_addobs(rows(obsvd))
		
			mata: st_store(count+1::count+rows(obsvd), (st_varindex("x"), st_varindex("y")), obsvd)
		
			mata: count = count + rows(obsvd)
		
			mata: currentvec = select(currentvec, abs(retrace:-1))
		
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = rows(obsvd)+1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}
		
			quietly replace col = `y' if missing(col)
		
			quietly replace down = 1 if missing(down)
		
			mata: countback = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: countback = select(countback[., (1..2,4)], countback[.,3]:==column)
		
			mata: countback = select(countback[., 1..2], countback[.,3]:==1)
		
			mata: countback = sort(((rows(countback)::1), countback), 1)
		
			mata: st_addobs(rows(countback))
		
			mata: st_store(count+1::count+rows(countback), (st_varindex("x"), st_varindex("y")), countback[., 2..cols(countback)])
		
			mata: count = count + rows(countback)
		
			quietly replace down = 0 if missing(down)
		
			quietly replace col = `y' if missing(col)
		
			mata: column++
	
		}
	
	}

	quietly summarize y

	quietly replace y = (y - r(min))*-1 + r(max)

	tempname max

	scalar `max' = r(max)

	quietly summarize x

	quietly replace x = `=r(max)/2+r(min)' if y == `max'

	quietly generate int group = .

	forvalues x = `=`max'-1'(-1)1 {

		quietly replace group = y == `x' & label != ""
	
		quietly replace group = group + group[_n-1] in 2/`=_N'
	
		quietly summarize group
	
		forvalues y = `=r(min)'/`=r(max)' {
	
			quietly summarize x if group == `y' & y <= `x'
		
			quietly replace x = `=r(max)/2+r(min)' if group == `y' & y == `x'
	
		}
	
		quietly replace group = .

	}
	
	graph twoway scatter y x, mlabel(lab) connect(direct)

	restore
	
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

function loglin(transmorphic M, todo, real rowvector b, ll, S, H) {

	real rowvector inter, y, xb
	
	y = moptimize_util_depvar(M, 1)
	
	xb  = moptimize_util_xb(M, b, 1)
	
	ll = -exp(xb) + xb:*y - lngamma(y:+1)
	
	S = -exp(xb) + y
	
	inter = -exp(xb)
	
	H = moptimize_util_matsum(M, 1, 1, inter, moptimize_util_sum(M, ll))
	
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

- chaidforest_estat version 1.0 - date - October 12, 2015

Basic version

-----
