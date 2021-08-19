/*
Parse the options that are specific to multivrs functionality and will not be
passed into the actual commands.
*/
program multivrs_parse_multivrs_options, rclass
	syntax [,  nSets(integer 0) sample(integer 100) ///
		size(numlist integer >=0 missingokay max=2 min=1) ///
		alpha(real .05) bs(string) pref(numlist max=2 min=2) weights(string) ]

	local opts_multivrs ""

	
	if `sample' < 1 | `sample' > 100 {
		di as err "Sample percent should be an integer 1-99."
		exit 198
	}
	local sample_pct = `sample'
	if `sample' == 100 local sample_option ""
	else local sample_option sample(`sample_pct')
	

	local size_opt_optput ""
	if "`size'" == "" {
		local sizemin = 1
		local sizemax = `nSets'
	}
	else {
		gettoken sizemin sizemax : size, parse(" ,")
		if trim("`sizemin'") == "."  local sizemin = 1
		if `sizemin' == 0 local sizemin = 1
		if trim("`sizemax'") == "."  local sizemax = `nSets'
		if "`sizemax'" == "" local sizemax = `sizemin'
		if `sizemax' > `nSets' local sizemax = `nSets'
		if (`sizemin' > `sizemax') | (`sizemin' >= `nSets') {
			di as err "invalid size option"
			exit 198
		}
		if `sizemin' == 1 & `sizemax' == 1 {
			di as err "invalid size option"
			exit 198
		}
		local size_opt_output size(`sizemin', `sizemax')
	}

	local alpha_opt_output ""
	if `alpha' < 0 | `alpha' >= 1 {
		di "note:  invalid alpha.  Default alpha = .05 will be used."
		local alpha = .05
	}
	else if `alpha' != .05 local alpha_opt_output alpha(`alpha')

	local bs_types_allowed par nonpar
	local bs_options_default nodots
	local bs_options_user ""
	local bs_type ""
	local bs_opts_all ""
	local bs_opt_output ""

	if "`bs'" != "" {
		gettoken bs_type bs_options_user : bs, parse(" ,")
		if `: list bs_type in bs_types_allowed' != 1 {
			di as err "Allowed bs types are " as result "par" as text " or " as result "nonpar."
			exit 198
		}
		if "`bs_type'" == "nonpar" {
			local bs_options_user `",`bs_options_user'"'
			if strmatch("`bs_options_user'", "saving(") {
				di as err "Bootstrap saving option not allowed."
				exit 198
			}
			local bs_opt_output "bs(`bs')"

			local bs_opts_all : list bs_options_user | bs_options_default
		}
		else if "`bs_options_user'" != "" {
				di as err "Bootstrap options not allowed with parametric bootstrap."
				exit 198
		}
		else local bs_opt_output "bs(`bs_type')"
	}

	if "`pref'" != "" {
		gettoken prefb prefse : pref
			if wordcount("`prefse'") != 1 {
			di as err "Invalid preferred option.  Please enter one coefficient estimate and one standard error estimate."
			exit 198
		}
	}

	if "`weights'" != "" {
		local weight_types_allowed "bic inf r2 no uniform"
		if `: list weights in weight_types_allowed' != 1 {
			di as err "Allowed weighting types are " as result "`weight_types_allowed'"
			exit 198
		}
	}

	return local sample_pct = `sample_pct'
	return local sizemin = `sizemin'
	return local sizemax = `sizemax'
	return local bs_type `"`bs_type'"'
	return local bs_options_user `"`bs_options_user'"'
	return local bs_opts_all `"`bs_opts_all'"'
	return local prefb `"`prefb'"'
	return local weights `"`weights'"'
	return local prefse `"`prefse'"'
	return local alpha = `alpha'
	local opts_multivrs `"`sample_option' `size_opt_output' `bs_opt_output' `alpha_opt_output'"'
	return local opts_multivrs : list retok opts_multivrs
end

//End program ParseMultivrsOptions
