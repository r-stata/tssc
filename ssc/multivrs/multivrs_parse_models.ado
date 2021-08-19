/*
ParseModels function takes in the user's list of estimation commands
and returns the following local macros:
sig_only_models ("sig_only" if the user has specified two or more model types
whose coefficient magnitudes are not directly comparable, "" else)
nmodeltypes (number of different estimation commands specified)
model_namelist (list of estimation commands)
model_namelist_uniq (list of unique estimation commands)
model_idlist (list of estimation commands, with repeated commands numbered)
for each model in the user's input list:
model`i'_name, model`i'_opts,model`i'_id
*/
program multivrs_parse_models, rclass
syntax anything(name = model_list_input)

//local model_list_input = subinstr("`model_list_input'", "[", "(" , .)
//local model_list_input = subinstr("`model_list_input'", "]", ")" , .)
local model_list_input : subinstr local model_list_input "[" "(", all
local model_list_input : subinstr local model_list_input "]" ")", all
local sig_only_list logit logistic probit nbreg poisson
local allowed regress logit logistic probit poisson nbreg areg rreg xtreg
local model_list_to_return ""
//i counts the number of distinct model types
local i 0
while `"`:list retok model_list_input'"' != "" {
	gettoken model_name model_list_input : model_list_input , bind parse(" |()")
	unabcmd `model_name'
	local model_name `r(cmd)'
	if !inlist("`model_name'","|","(",")") {
		//if "`model_name'" == "regress" local model_name reg
		if `:list model_name in allowed' != 1 {
			di as err "Invalid model type.  Model options are regress, logit, logistic, probit, poisson, nbreg, areg, rreg, xtreg."
			exit 198
		}
		if `:list model_name in sig_only_list' == 1 {
			local sig_only sig_only
		}
		local ++i
		local model`i'_name `model_name'
		local model_list_to_return `model_list_to_return' `model_name'
		gettoken opts model_list_input : model_list_input, bind match(par) parse(" |")
		if "`par'" == "" {
			local model_list_input "`options' `model_list_input'"
		}
		else local model`i'_opts `opts'
	}
}
local model_list_to_return : list retok model_list_to_return
local dups_model_namelist : list dups model_list_to_return
foreach d of local dups_model_namelist {
	local n_repeats_`d' 0
}
local model_idlist ""
forvalues j = 1/`i' {
	local name `model`j'_name'
	if `:list name in dups_model_namelist' == 1 {
		local ++ n_repeats_`name'
		local model`j'_id `name'_`n_repeats_`name''
	}
	else local model`j'_id `name'
	local model_idlist `"`model_idlist' `model`j'_id'"'
}
if `i' == 1 local sig_only ""
return local sig_only_models "`sig_only'"
return local nmodeltypes = `i'
return local model_namelist_uniq : list uniq model_list_to_return
return local model_idlist `model_idlist'
return local model_namelist `model_list_to_return'
forvalues j = 1/`i' {
	return local model`j'_name `model`j'_name'
	return local model`j'_opts `model`j'_opts'
	return local model`j'_id `model`j'_id'
}
end
// End program ParseModels
