/*
Parse the options that will be passed into the Stata command for every model
*/
program multivrs_parse_est_options, rclass
syntax anything(name = model_namelist_uniq) [, fe re be mle pa vce(string) ///
offset(passthru) exposure(passthru) irr absorb(varname) other(string)]
local opts_command ""
local xtreg_option "`fe' `re' `be' `mle' `pa'"
local xtreg_option : list retok xtreg_option
if "`xtreg_option'" != "" {
	if "`model_namelist_uniq'" != "xtreg" {
		di as err "Invalid `xtreg_option'.  `xtreg_option' only allowed with xtreg."
		exit 198
	}
}
local absorb_option ""
if "`model_namelist_uniq'" == "areg" {
	if ("`absorb'" == "") {
		di as err "option absorb() required"
		exit 198
	}
	else {
		local absorb_option "absorb(`absorb')"
	}
}
else if ("`absorb'" != "") {
	di as err "Invalid absorb option.  Absorb may only be used with areg."
	exit 198
}
local est_options irr exposure
local est_options_models_ok poisson nbreg 
foreach opt of local est_options {
	if "``opt''" != "" {
		if `: list model_namelist_uniq in est_options_models_ok' != 1 {
			di as err "Invalid `opt' option.  `opt' should only be used " ///
			"with poisson or negative binomial regression."
			exit 198
		}
		else if "`opt'" != "irr" local `opt'_option "`opt(``opt'')'"
		else local `opt'_option "`opt'"
	}
}

if "`offset'" != "" {
	local models_offset_ok poisson nbreg xtreg
	foreach m in `model_namelist_uniq' {
		if !(`: list m in models_offset_ok' == 1 | ("`m'" == "xtreg" & "`pa'" == "pa")) {
			di as err "Invalid offset option. Offset should only be used " ///
				"with poisson, nbreg, or xtreg, pa regression." 
			exit 198	
		}
	}
}


local vce_option ""
if ("`vce'" != "") {
	if !regexm("`vce'","robust|cluster*") {
		di as err "Invalid vce option.  Vce options are robust and cluster."
		exit 198
	}
	local rreg rreg
	if `: list rreg in model_namelist_uniq' == 1 {
		di as err "option vce() not allowed with rreg."
		exit 198
	}

	local vce_option "vce(`vce')"
}
local opts_command `xtreg_option' `absorb_option' `irr' `exposure' ///
	`offset' `vce_option' `other'
local opts_command : list retok opts_command
return local opts_command `"`opts_command'"'
end

//End program ParseEstimationOptions
