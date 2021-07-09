*! version 1.5.0 MLB 12Jul2011
* version 1.0.1 MLB 28May2010
// based on offical Stata's -twoway__histogram_gen- version 1.1.14  02aug2006
// generate heights and bin centers for a histogram
program hangr_histgen, rclass sortpreserve
        version 8.0

        syntax varname(numeric) [fw] [if] [in]  ///
        [,                                      ///
                DISCrete                        ///
                BIN(numlist max=1 >0 integer)   /// number of bins
                Width(numlist max=1 >0)         /// width of bins
                START(numlist max=1)            /// first bin position
				TMAX(numlist max=1)              /// theoretical max (to make sure that bins of two groups are alligned)
                DENsity FRACtion FREQuency      /// height type
                PERCENT                         ///
                RETurn                          /// save results in r()
                GENerate(string asis)           /// generate(y x [, replace])
                display                         /// display a note
				xwx(string)                     /// extra x-variable for after models with covariates
				ninter(integer 5)               /// number of points between bin-mids
				inflate(numlist integer max=2 ascending)  /// taking care of the inflation part of zip, zinb, and zoib
        ]

        CheckGenOpt `generate'
        local generate `s(varlist)'
        if `"`generate'"' != "" & `"`s(replace)'"' == "" {
                confirm new var `generate'
        }
		if "`xwx'" != "" {
			confirm new var `xwx'
		}

        // note: options discrete and bin() are mutually exclusive

        if `"`discrete'"' != "" & `"`bin'"' != "" {
                di as error "options discrete and bin() may not be combined"
                exit 198
        }

        // note: bin() and width() are mutually exclusive

        if `"`bin'"' != "" & `"`width'"' != "" {
                di as err "options bin() and width() may not be combined"
                exit 198
        }

        // note: options density, fraction, frequency, and percent are
        // mutually exclusive

        local type `density' `fraction' `frequency' `percent'
        local k : word count `type'
        if `k' > 1 {
                local type : list retok type
                di as err "options `type' may not be combined"
                exit 198
        }
        else if `k' == 0 {
                local type density
        }
        if "`display'" != "" {
                local return return
        }

        // only check the syntax
        if ("`generate'`return'" == "") exit

        marksample touse
        local v `varlist'

		tempvar tousei
		gen byte `tousei' = `touse'
		if "`inflate'" != "" {
			tokenize `inflate'
			qui replace `tousei' = 0 if `v' == `1'
			local infl1 = `1'
			if "`2'" != "" {
				qui replace `tousei' = 0 if `v' == `2'
				local infl2 = `2'
			}
		}

        tempname                ///
                h               /// bin width
                min             /// minimum value
                max             /// maximum value
                nobs            /// number of obs (including fw)
				nobsi           /// number of obs (excluding inflate)
                // blank

        if `"`weight'"' != "" {
                local wgt [`weight'`exp']
        }
        // get the range of values
        sum `v' `wgt' if `tousei' , meanonly 
        if r(N) == 0 {
                if "`generate'" != "" {
                        DropGenVars `generate'
                        gettoken y x : generate
                        quietly gen `y' = .
                        local Type = upper(substr("`type'",1,1))        ///
                                +substr("`type'",2,.)
                        label var `y' "`Type'"
                        quietly gen `x' = .
                }
                return scalar area = 0
                return scalar max = 0
                return scalar min = 0
                return scalar start = 0
                return scalar width = 0
                return scalar bin = 1
                return scalar N = 1
                return local type `type'
                return scalar n_x = 1
                exit
        }
        scalar `min'  = r(min)
		if "`tmax'" == "" {
			scalar `max'  = r(max)
		}
		else {
			if `tmax' < r(max) & reldif(`tmax',`r(max)') > 1e-4{
				di as err "value specified in tmax must be larger than the maximum value of `varlist'"
				exit 198
			}
			scalar `max' = `tmax'
		}
        if `min' == `max' & `"`width'"' == "" {
                local width 1
        }
		scalar `nobsi' = r(N)
        if `"`start'"' != "" {
                if `min' < `start' & reldif(`min',`start') > 1e-5 {
                        di as err ///
                        "option start() may not be larger than minimum of `v'"
                        exit 198
                }
                local user_start yes
                scalar `min' = `start'
        }
        else {
                tempname start
                scalar `start' = `min'
        }
		// number of observations including the inflate part, i.e. touse instead of tousei
		sum `v' if `touse' `wgt', meanonly
        scalar `nobs' = r(N)


        // calculate number of bins and bin widths
		if `"`discrete'"' == "" {
                if `"`width'"' == "" {
                        if `"`bin'"' == "" {
                            local bin = int(                    ///
                                    min(                        ///
                                        sqrt(`nobsi'),           ///
                                        10*log(`nobsi')/log(10)  ///
                                    )                           ///
                            )
                            local bin = max(1,`bin')
                        }
                        scalar `h' = (`max'-`min')/`bin'
                }
                else {  // width() specified
                        scalar `h' = `width'
                        local bin = ceil((`max'-`min')/`h')
                        local bin = max(1,`bin')
                }
                if `"`display'"' != "" {
                        display as txt "(bin=" as res `bin'             ///
                                as txt ", start=" as res `start'        ///
                                as txt ", width=" as res `h'            ///
                                as txt ")"
                }
        }
        else {
                if `"`width'"' == "" {
                        tempvar diff v2 io
                        qui gen `io' = _n       // restore sort order later
                        sort `tousei' `v', stable
                        qui gen `v2' = `v' if `tousei'
                        qui gen `diff' = `v2'-`v2'[_n-1] if `tousei'
                        sum `diff' if `diff'>0, meanonly
                        scalar `h' = cond(missing(r(min)), 1, r(min))
                        sort `io', stable
                        drop `io'
                }
                else    scalar `h' = `width'
                if `"`display'"' != "" {
						display as txt "(start=" as res `start' ///
                                as txt ", width=" as res `h'    ///
                                as txt ")"
                }
                scalar `min' = `min'-`h'/2
                local bin = int((`max'-`min')/`h' + .5)
        }
	
        // Saved results
        // area of the combined bars in a histogram
        if `"`type'"' == "frequency" {
                return scalar area = `nobs'*`h'
        }
        else if `"`type'"' == "fraction" {
                return scalar area = `h'
        }
        else if `"`type'"' == "percent" {
                return scalar area = `h'*100
        }
        else    return scalar area = 1
        // min and max are the range for the x-axis
		return scalar max = `min'+`h'*`bin'
		return scalar min = `min'
		return scalar start = `start'
        return scalar width = `h'
        return scalar bin = `=`bin'+`:word count `inflate'''
        return scalar N = `nobs'
        return local type `type'

        // parsing is finished, so exit if no variables to generate

        if `"`generate'"' == "" {
                exit
        }

quietly {

        // generate bin centers
        tempvar                 ///
                midbin          /// midpoint of the bin
                height          /// height of the bin
                // blank
        gen `midbin' = floor((`v'-`min')/`h') if `tousei' 
        // fix edge problems between -float- and -double- precision
        replace `midbin' = 0 if `tousei' & `midbin' < 0
        replace `midbin' = `bin'-1 if `tousei' & `midbin' == `bin'
		
        // frequency of observations (non-inflate part)
        tempname x ht
        capture tabulate `midbin' `wgt', matcell(`ht') matrow(`x')
        if _rc {
                di as err "too many bins"
                exit _rc
        }
		if `= `bin' + `: word count `inflate'' ' >= c(matsize) {
			di as err "too many bins"
			exit 198
		}
        local obins = r(r)
		if `obins' < `bin'  {
			tempname htt
			if el(`x',1,1) == 0 {
				matrix `htt' = `ht'[1,1]
			}
			else{
				matrix `htt' = 0
			}
			local j = 2
			forvalues i = 2/`bin' {
				if el(`x',`j',1) == `i' - 1 {
					matrix `htt' = `htt' \ `ht'[`j',1]
					local `j++'
				}
				else {
					matrix `htt' = `htt' \ 0
				}
			}
			matrix `ht' = `htt'
			matrix drop `htt'
		}

		// add observations in case more bins than observations
		if _N < `= `bin'+`:word count `inflate''+1' {
			qui set obs `=`bin'+`:word count `inflate''+1'
		}
        replace `midbin' = `min' + `h'/2 + `h'*(_n - 1) in 1/`bin'
		if "`inflate'" == "" {
			replace `midbin' = . in `=`bin'+1'/l
		}
		else {
			replace `midbin' = `: word 1 of `inflate'' in `=`bin'+1'
			if `: word count `inflate'' == 2 {
				replace `midbin' = `: word 2 of `inflate'' in `=`bin'+2'
				replace `midbin' = . in `=`bin'+3'/l
			}
			else {
				replace `midbin' = . in `=`bin'+2'/l
			}
		}
        gen `height' = `ht'[_n,1] in 1/`bin'
		if "`infl1'" != "" {
			sum `varlist' if `varlist' == `infl1' & `touse' `wgt', meanonly
			replace `height' = r(N) in `=`bin'+1'
		}
		if "`infl2'" != "" {
			sum `varlist' if `varlist' == `infl2' & `touse' `wgt', meanonly
			replace `height' = r(N) in `=`bin'+2'
		}
        matrix drop `x'
        matrix drop `ht'

        format `:format `v'' `midbin'
        _crcslbl `midbin' `v'

        if `"`type'"' == "density" {
                replace `height' = `height'/(`nobs'*`h')
        }
        else if `"`type'"' == "fraction" {
                replace `height' = `height'/`nobs'
        }
        else if `"`type'"' == "percent" {
                replace `height' = 100*`height'/`nobs'
        }

} // quietly

        // we wouldn't be here if `generate' was empty
        DropGenVars `generate'
        tokenize `generate'
        gettoken y x : generate
        rename `height' `y'
        local Type = upper(substr("`type'",1,1))+substr("`type'",2,.)
        label var `y' "`Type'"
        rename `midbin' `x'
        // number of nonmissing values in `x'
        return scalar n_x = `obins' 
		
		// extra x-axis for after estimation commands with covariates
		if "`xwx'" != ""  {
			if _N < `bin' * (`ninter' + 1) + `ninter' {
				qui set obs `=`bin' * (`ninter' + 1) + `ninter''
			}
			qui gen `xwx' = `x'
		
			local k = 1
			forvalues j = `ninter'(-1)1 {
				qui replace `xwx' = `x'[1] - 0.5*`j'/(`ninter' + 1) *`h' in `=`bin' + `k++' + `:word count `inflate'''
			}
			forvalues i = 2/`bin'{
				forvalues j = `ninter'(-1)1 {
					qui replace `xwx' = `x'[`i'] - `j'/(`ninter' + 1)*`h' in `=`bin' + `k++' + `:word count `inflate'''
				}
			}
			forvalues j = `ninter'(-1)1 {
				qui replace `xwx' = `x'[`bin'] + 0.5*`j'/(`ninter' + 1) *`h' in `=`bin' + `k++' + `:word count `inflate'''
			}
		}
	
end

program DropGenVars
        foreach var of local 0 {
                capture confirm var `var'
                if !_rc {
                        unab vv : `var'
                        if "`vv'" == "`var'" {
                                drop `var'
                        }
                }
        }
end

/* parse the contents of the -generate- option:
 * generate(y x [, replace])
 */

program CheckGenOpt, sclass
        syntax [namelist] [, replace ]

        if `"`replace'`namelist'"' != "" {
                if 0`:word count `namelist'' != 2 {
                        di as err "option generate() incorrectly specified"
                        exit 198
                }
        }
        sreturn clear
        sreturn local varlist `namelist'
        sreturn local replace `replace'
end


exit


