*! version 3.2.5 17may2019 Richard Williams, rwilliam@nd.edu

* Specialized svy prefix for gologit2 - handles otherwise
* problematic options. Use this instead of svy:,
* at least when using autofit.
* gsvy and gologit2_svy are synonyms; either can be used.
* Special thanks to Jeff Pittblado, who wrote critical
* parts of this code!

* autofit, gamma & store options receive special handling.

program gologit2_svy
	// gsvy is a synonym for golgit2_svy; either can be used
	// Syntax: gsvy [, svy options] : gologit2 ...
        version 11.2


        // s(before) will have svy options, if any
        // s(after) will be the gologit2 command
        _on_colon_parse `0'
        local 0 `"`s(after)'"'
        local svypref svy `s(before)':



        // look for optional <prefix_cmd>
        capture _on_colon_parse `0'
        if !c(rc) {
                local prefix `"`s(before)' :"'
                local 0 `"`s(after)'"'
                gettoken pcmd : prefix
                local allowed nothingnow
                if !`:list pcmd in allowed' {
                        di as err "prefix command '`pcmd'' is not allowed"
                        exit 199
                }
        }
        local prefix `svypref' `prefix'

        gettoken cmd 0 : 0
        if "`cmd'" != "gologit2" {
                di as err "`cmd' not allowed"
                exit 199
        }


        // parse for display & model options
        syntax varlist(default=none fv ) [if] [in]  [,   ///
		Pl Pl2(passthru) NPl NPl2(passthru) 	/// parallel lines constraints
		AUTOfit AUTOfit2(string)		/// automated model fitting
                *]
                
                
	// Can only specify one of pl, pl(), npl, npl(), autofit, autofit()
	local pl_options = 0
	foreach opt in pl npl pl2 npl2 autofit autofit2 {
		if "``opt''"!="" local pl_options = `pl_options' + 1
	}
	// npl is the default if nothing specified.
	if `pl_options' == 0 {
		local npl "npl"
	}
	else if `pl_options' > 1 {
		di in red "only one of pl, pl(), npl, npl(), " ///
			"autofit, autofit() can be specified"
		exit 198
	}
	local modelspec `pl' `npl' `pl2' `npl2' `autofit' `autofit2'

	// make sure only one eform specified.  If so, it will
	// be local macro eform
        local eform `or' `irr' `rrr' `hr' `eform'
        if `:list sizeof eform' > 1 {
                opts_exclusive "`eform'"
        }

// Call autofit if it has been requested
	if "`autofit'"!="" | "`autofit2'"!="" {
		if "`autofit2'" != "" local autofit2 autofit2(`autofit2')
		gologit2_autofit `varlist' `if' `in', ///
			svyprefix(`prefix') `autofit' `autofit2' `options' gsvy
		gologit2, `options'
// Otherwise call gologit2 directly with the svy prefix and requested options
// Problematic options (gamma, store) are left off and dealt with later.
	}
	else {
		quietly `prefix'gologit2 `varlist' `if' `in' `wgt', ///
			`modelspec' `eform' `options'  gsvy
		gologit2, `options'
	}
	prediction_check
	// quiet replays insure r(table) is right
	quietly gologit2, `options'
end


************************
program prediction_check
	* check for negative predicted probabilities
	local M = e(k_cat)
	forval i = 1/`M' {
		local pvars `pvars' p`i'
	}
	tempvar `pvars' 
	local pvars2 `p1'
	local pvars3 `p1'
	forval i = 2/`M' {
		local pvars2 `pvars2' `p`i''
		local pvars3 `pvars3', `p`i''
	}
	quietly gologit2_p `pvars2' if e(sample) & `=e(subpop)'
	quietly count if min(`pvars3') < 0 & e(sample) & `=e(subpop)'
	if `=r(N)' {
		local cl `"{stata whelp gologit2:gologit2 help}"'
		display
		display as error "WARNING! " as yellow "`=r(N)' in-sample cases" as error " have an outcome with a predicted probability that is"
		display as error "less than 0. See the `cl' section on Warning Messages for more information."
	}
	quietly count if max(`pvars3') > 1 & e(sample) & `=e(subpop)'
	if `=r(N)' {
		display
		display as error "WARNING! " as yellow "`=r(N)' in-sample cases" as error " have an outcome with a predicted probability that is"
		display as error "greater than 1. See the `cl' section on Warning Messages for more information."
	}

end
	

