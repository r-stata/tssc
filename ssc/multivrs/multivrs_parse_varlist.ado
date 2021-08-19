/*
Parse out the list of control terms.
The user can enter 2 layers of grouped variables including either/or options.
The outermost layer of grouped terms is called a Set.
ex. Set 1 = ( (x1 (x2 | x3 )) | (x4 x5 ) )
Sets are split up into SetX by the either/or symbol "|".
Only one SetX of each Set may appear in any given model.
ex. Set 1, SetX 1 = (x1 (x2 | x3 ))
    Set 1, SetX 2 =  (x4 x5 )
SetX are split up into Terms by parentheses.
Each SetX contains one or more Terms.  Given that a SetX appears in the model,
all of the terms of the SetX must appear in that model.
ex. Set 1, SetX1, Term 1 = x1
    Set 1, SetX1, Term 2 = x2 | x3
    Set 1, SetX2, Term 1 = x4 x5
Terms are split up into TermX by the either/or symbol "|".
Only one TermX of each Term may appear in any given model.
ex. Set 1, SetX1, Term 1, TermX 1 = x1
ex. Set 1, SetX1, Term 2, TermX 1 = x2
    Set 1, SetX1, Term 2, TermX 1 = x3
    Set 1, SetX2, Term 1, TermX 1 = x4 x5
ParseVarlist returns the following local macros:
s`i'NSX = number of SetX in Set i
s`i'sx`j'NT = number of Terms in Set i, SetX j
s`i'sx`j't`k'NTX = number of TermX in Set i, SetX j, Term k
s`i'sx`j't`k'tx`m' = the variable names that compose Set i, SetX j, Term k, TermX m
nSets = total number of Sets (including dependent var set (#1) and interest var set (#2))
n_var_combinations = total number of variable combinations meeting the
	user's grouping and either/or criteria
allvarnames = list of all of the variable names
allvarnames_clean = list of all the variable names,
	with dependent and interest variables preceded by "__" and rotated variable
	names preceded by "r_" any extraneous characters e.g. "." converted to "_"
always_in_varnames = list of all the always in variable names
b_always_in_clean = list of all the always in variable names precede by "b_"
	with any extraneous characters e.g. "." converted to "_"
intvarlist = variable(s) of interest name(s), separated by |
depvarlist = dependent variable(s) name(s), separated by |
If the display_only option is specified, ParseVarlist returns nothing.
*/
program multivrs_parse_varlist, rclass
return add
syntax anything (name = varlist_input) [ , display_only]
local nSets 0
local depvarlist ""
local intvarlist ""
local allvarnames ""
local allvarnames_clean ""
local always_in_varnames ""
local b_always_in_clean ""
mata:  multivrs_varnames = asarray_create()

while `"`:list retok varlist_input'"' != "" {
	//Isolate the first grouped set of the varlist
	gettoken set varlist_input : varlist_input, bind match(par)
	if "`par'" == "" {

		if !strmatch("`set'", "*.*") capture unab set : `set'		

		if `:word count `set'' != 1 {
			gettoken set rest : set
			local varlist_input `"`rest' `varlist_input'"'
		}
	}
	//Identify the components of this grouped set.  
	local ++nSets
	local nsx 1
	while `"`:list retok set'"' != "" {
		/*
		multivrs_expand_interxn_wrapper `set' 
		local set `r(expanded)' 
		*/
		//Build up setx by getting tokens until you reach | or the end of the set
		local setx ""
		gettoken setx0 set : set,  bind  parse(" |")
		while `"`setx0'"' != "|" & `"`setx0'"' != "" {
			local setx `"`setx' `setx0'"'
			gettoken setx0 set : set, bind  parse(" |")
		}
		local nt 0		
		while `"`:list retok setx'"' != "" {
			gettoken term setx : setx, bind match(par)
			local ++nt
			local ntx 1
			while `"`:list retok term'"' != "" {
				//There should be no more parentheses within the term so no need for bind option
				gettoken termx0 term : term, parse("|")
				if "`termx0'" == "|" {
					local ++ntx
				}
				else {
					local termx ""
					//Build up termx by getting tokens until the end of the term
					while `"`:list retok termx0'"' != "" {
						gettoken tk termx0 : termx0
						if !strmatch("`tk'", "*.*") capture unab tk : `tk'
						
						/*
						//here is where you expand a single interaction 
						if _rc != 0 {
							multivrs_expand_interxn `tk'
							local tk `r(expanded)'
						}
						*/
						local termx "`termx' `tk'"
					}
					//Build the depvarlist:  Set #1, every setx, Term #1, Word 1
					if `nSets' == 1 {
						ProcessKeyVariable `termx', nt(`nt') curr_varlist(`depvarlist')
						local depvarlist `r(new_varlist)'
					}
					//Build the intvarlist :  Set #2, every setx, Term #1, Word 1
					if `nSets' == 2 {
						ProcessKeyVariable `termx', nt(`nt') curr_varlist(`intvarlist') is_intvar
						local intvarlist `r(new_varlist)' 
					}					
					local s`nSets'sx`nsx't`nt'tx`ntx' `termx'
					local allvarnames "`allvarnames' `termx'"
					foreach varname of local termx {
						local varname_clean = strtoname("`varname'")
						if `nSets' == 2  {
							local always_in_varnames `"`always_in_varnames' `varname'"'
							local b_always_in_clean `"`b_always_in_clean' b_`varname_clean'"'
						}
						if `nSets' > 2 local varname_clean = `"r_`varname_clean'"'
						else local varname_clean `"__`varname_clean'"'
						local allvarnames_clean `"`allvarnames_clean' `varname_clean'"'
						mata:  asarray(multivrs_varnames, "`varname_clean'", "`varname'")
					 }
				}
			}
			//done parsing term:  Record # of termx
			local s`nSets'sx`nsx't`nt'NTX `ntx'
		}
		//done parsing setx:  Record # of term
		local s`nSets'sx`nsx'NT `nt'
		if "`setx0'" == "|" {
			local ++nsx
		}
	}
	//done parsing set:  Record # of setx
	local s`nSets'NSX `nsx'
}


if "`display_only'" != "display_only" {
forvalues is = 1/`nSets' {
	return local s`is'NSX = `s`is'NSX'
	forvalues isx = 1/`s`is'NSX' {
		return local s`is'sx`isx'NT = `s`is'sx`isx'NT'
		forvalues it = 1/`s`is'sx`isx'NT' {
			return local s`is'sx`isx't`it'NTX = `s`is'sx`isx't`it'NTX'
			forvalues itx = 1/`s`is'sx`isx't`it'NTX' {
				 return local s`is'sx`isx't`it'tx`itx' `"`s`is'sx`isx't`it'tx`itx''"'
				 //local TermX_varnames "`s`is'sx`isx't`it'tx`itx''"
				 //local allvarnames "`allvarnames' `TermX_varnames'"
			}
		}
	}
}

local allvarnames : list uniq allvarnames
local allvarnames_clean : list uniq allvarnames_clean
local b_always_in_clean : list uniq b_always_in_clean
local always_in_varnames : list uniq always_in_varnames

local n_var_combinations 1
local nmodels 1
forvalues is = 1/`nSets' {
	local n_combos_this_Set 0
	forvalues isx = 1/`s`is'NSX' {
		local n_combos_this_SetX 1
		forvalues nt = 1/`s`is'sx`isx'NT' {
			local n_combos_this_SetX = `n_combos_this_SetX' * `s`is'sx`isx't`nt'NTX'
		}
		local n_combos_this_Set = `n_combos_this_Set' + `n_combos_this_SetX'
	}
	if `is' > 2 local ++n_combos_this_Set
	local n_var_combinations = `n_var_combinations' * `n_combos_this_Set'
}

return local nSets `nSets'
return local n_var_combinations `n_var_combinations'
return local allvarnames `"`allvarnames'"'
return local allvarnames_clean `"`allvarnames_clean'"'
return local b_always_in_clean `"`b_always_in_clean'"'
return local always_in_varnames `"`always_in_varnames'"'
return local intvarlist `"`intvarlist'"'
return local depvarlist `"`depvarlist'"'
}
end
// End program ParseVarlist

/*
Check the input of time-series operators to determine whether the name indicates one or
more variables
*/
program CheckVarMeetsCriteria, rclass
	syntax , var(string) [is_depvar]
	return add
	
	if "`is_depvar'" == "is_depvar" local var_id "dependent variable"
	else local var_id "variable of interest"
	
	// If specified as a factor, check whether it's binary
	if strmatch("`var'", "i.*") {		
		if "`is_depvar'" == "is_depvar" {
			di as err "depvar may not be a factor variable"
			exit 198
		}
		local raw_var = regexr("`var'", "i.", "")
		qui sum `raw_var'
		if r(min) == 0 & r(max) == 1 {			
			qui  tab `raw_var'
			if r(r) == 2 {
			}
			else {
				di as err "To use a factor variable as the leading variable of interest, it must be binary and stored as 0/1." 
				exit 198
			}
		}
		else {
			di as err "To use a factor variable as the leading variable of interest, it must be binary and stored as 0/1." 
			exit 198
		}
	} 
	else {
		if strmatch("`var'", "*.*") & regexm("`var'","^([LlDdSsFf]+[0-9LlDdSsFf]*\.[^.]+)$") == 0 {
			di as err "`var_id' must be a single variable"
			exit 198
		}
	}	
end

// process the dependent and independent variables of interest
program ProcessKeyVariable, rclass
syntax anything(name = termx), nt(integer)  [curr_varlist(string) is_intvar]
	return add
	if "`is_intvar'" == "is_intvar" {
		local var_id "variable of interest"
		local is_depvar ""
	}
	else {
		local var_id "dependent variable"
		local is_depvar "is_depvar" 
	}
	
	if `nt' == 1 {
		local var0 : word 1 of `termx'
		CheckVarMeetsCriteria, var(`var0') `is_depvar'
		if  "`curr_varlist'" != "" local new_varlist "`curr_varlist' | `var0'"
		else local new_varlist `var0'
		}
		//Each setx of Set 1 should contain only 1 term = 1 dependent variable.
	else {
		if "`is_intvar'" == "" {
			di as err "`var_id' must be a single variable."
			exit 198
		}
		else local new_varlist `curr_varlist' 
	}	
	return local new_varlist `new_varlist'
end






