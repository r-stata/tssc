*! version 1.3.0 18Nov2019 MLB
* replace(framename) 
* row and col allowed with by(,basline())
* format also used for saved variables
program define stdtable, rclass
	if c(version) >= 16 {
		version 16
	}
	else {
		version 11.2
	}
	
	syntax varlist(min=2 max=2) [if] [in] [aweight iweight fweight], ///
       [raw replace REPLACE2(string) by(string)                      ///
       BASERow(namelist min=1 max=1) BASECol(namelist min=1 max=1)   ///
       TOLerance(real 1e-6) ITERate(integer 16000) log        ///
       Format(string) row col * ]

	if "`weight'" != "" local wgt "[`weight'`exp']"

	if `tolerance' < 0 {
		di as err "negative numbers cannot be specified in tolerance()"
		exit 198
	}
	if `iterate' < 0 {
		di as err "negative numbers cannot be specified in iterate()"
		exit 198
	}
	if "`format'" == "" {
		local format "%9.3g"
	}
	else {
		capture display `format' 2
		if _rc error 120
	}
	if "`replace'" != "" & `"`replace2'"' != "" {
		di as err "{p}replace can only be specified once{p_end}"
		exit 198
	}
	if c(version) < 16 & `"`replace2'"' != "" {
		di as err "{p}frames can only be specified in the replace option in Stata >= 16{p_end}"
		exit 198
	}
 	
	if `"`replace2'"' != "" {
		Parseframe `replace2'
		if r(iscurrent) {
			local replace2 = ""
			local replace  = "replace"
		}
		else {
			local current       `r(current)' 
			local frame         `r(frame)'
			local framereplace  `r(framereplace)'
			frame copy `current' `frame', `framereplace'
			frame change `frame'
		}
	}
	
	
	marksample touse, strok
	gettoken by byopts : by, parse(",")
	gettoken comma byopts : byopts, parse(",")
	Parseby `by', touse(`touse') `byopts'
	local by "`r(by)'"
	local baseline "`r(baseline)'"

	if "`baserow'" != "" & "`basecol'" == "" {
		di as err "basecol() needs to be specified when specifying baserow()"
		exit 198
	}
	if "`baserow'" == "" & "`basecol'" != "" {
		di as err "baserow() needs to be specified when specifying basecol()"
		exit 198
	}
	if "`baserow'" != "" & "`baseline'" != "" {
		di as err "{p}baseline() cannot be specified when specifying baserow() and basecol(){p_end}"
		exit 198
	}
	if "`baserow'" != "" {
		confirm matrix `baserow' `basecol'
	}
	if "`row'" != "" & "`col'" != "" {
		di as err "the row and col options cannot be specified together"
		exit 198
	}


	tempvar mark tot basec baser freq muhat muhat_old marg reldifi reldifri
	tempname reldif reldifr
	preserve
    Contract_w `varlist' `by' `wgt' if `touse', zero nomiss freq(`freq')
	
    sum `freq', meanonly
	if r(sum) == 0 error 2000

	gettoken r c : varlist

	bys `r' : gen byte `mark' = _n == 1
	qui count if `mark'
	local kr = r(N)
	qui bys `c' : replace `mark' = _n == 1 
	qui count if `mark'
	local kc = r(N)	
	qui drop `mark'
		
	if "`baseline'" != "" {
		if `"`=substr("`: type `by''",1,3)'"' == "str"{
			local bybase `"(`by' == `"`baseline'"')"'
		}
		else {
			local bybase `"(`by' == `baseline')"'
		}
		sort `c'
		    by `c' : gen double `basec' = sum(`bybase' * `freq') 
		qui by `c' : replace    `basec' = `basec'[_N]
		sort `r'
		    by `r' : gen double `baser' = sum(`bybase' * `freq') 
		qui by `r' : replace    `baser' = `baser'[_N]
	}
	else if "`baserow'`basecol'" != "" {
		if rowsof(`baserow') != 1 {
			if colsof(`baserow') == 1 {
				matrix `baserow' = `baserow''
			}
			else {
				di as err "{p}the matrix specified in baserow() needs to be a vector{p_end}"
				exit 198
			}
		}
		if colsof(`baserow') != `kr' {
			di as err "{p}there are `kr' values in `r', so baserow() needs a 1 by `kr' matrix{p_end}"
			exit 198
		}
		tempname ones sumrow sumcol
		matrix `ones' = J(`kr',1,1)
		matrix `sumrow' = `baserow'*`ones'

		if rowsof(`basecol') != 1 {
			if colsof(`basecol') == 1 {
				matrix `basecol' = `basecol''
			}
			else {
				di as err "{p}the matrix specified in basecol() needs to be a vector{p_end}"
				exit 198
			}
		}
		if colsof(`basecol') != `kc' {
			di as err "{p}there are `kc' values in `c', so basecol() needs a 1 by `kc' matrix{p_end}"
			exit 198
		}
		matrix `ones' = J(`kc',1,1)
		matrix `sumcol' = `basecol'*`ones'
		capture assert mreldif(`sumcol', `sumrow') < `tolerance' 
		if _rc{
			di as error "{p}the sums of the matrices in basecol() and baserow() need to be equal{p_end}"
			exit 198
		}
		if `"`by'"' != "" local byby `"by `by' : "'
		quietly {
			tempvar id
			bys `by' `r' : gen        `id'    = _n==1
			`byby'         replace    `id'    = sum(`id')
						   gen double `baser' = `baserow'[1, `id']
			bys `by' `c' : replace    `id'    = _n==1
			`byby'         replace    `id'    = sum(`id')
						   gen double `basec' = `basecol'[1, `id']
		}
		drop `id'
	}
	else {
		if `kc' == `kr' & "`row'`col'" != "" {
			// the default is then to already show row and col percentages
			local row ""
			local col ""
		} 
		if `kc' != `kr' {
			gen double `basec' = 100/`kc'
			gen double `baser' = 100/`kr'
		}
		else {
			gen double `basec' = 100
			gen double `baser' = 100
		}
	}

	// estimate standardized counts
	gen double `muhat' = `freq'
	gen double `muhat_old' = 0
	qui gen double `marg' = .
	local i = 1

	qui gen double `reldifi' = reldif(`muhat',`muhat_old')
	sum `reldifi', meanonly
	scalar `reldif' = r(max)
	qui gen double `reldifri' = .
	scalar `reldifr' = .

	while (`reldif' > `tolerance' | `reldifr' > `tolerance' ) &  `i' < `iterate' {
		quietly {
			replace `muhat_old' = `muhat'	
			sort `by' `r'
			by `by' `r' : replace `marg' = sum(`muhat')
			by `by' `r' : replace `muhat' = `muhat' * `baser' / `marg'[_N]
			sort `by' `c'
			by `by' `c' : replace `marg' = sum(`muhat')
			by `by' `c' : replace `muhat' = `muhat' * `basec' / `marg'[_N]
			replace `reldifi' = reldif(`muhat',`muhat_old')
			sum `reldifi', meanonly
			scalar `reldif' = r(max)
			sort `by' `r'
			by `by' `r' : replace `marg' = sum(`muhat')
			by `by' `r' : replace `reldifri' = reldif(`marg'[_N],`baser')
			sum `reldifri', meanonly
			scalar `reldifr' = r(max)
		}
		if "`log'" != "" {
			di as txt "iteration :" as result `i' ///
               as txt " max rel change: " as result `reldif' ///
               as txt " max rel row diff: " as result `reldifr'
		}
		local i = `i' + 1
	}
	if `i' == `iterate' & ( `reldif' > `tolerance' | `reldifr' > `tolerance')  error 430

	quietly {
		// row totals
		bys `by' `r' : gen byte `mark' = (_n == 1) + 1
		expand `mark', gen(`tot')
		if `"`=substr("`: type `c''",1,3)'"' == "str" {
			replace `c' = "" if `tot' == 1 
		}
		else {
			replace `c' = . if `tot' == 1 
		}
		replace `muhat' = 0 if `tot' == 1
		bys `by' `r' (`c') : replace `tot' = sum(`muhat')
		bys `by' `r' (`tot') : replace `muhat' = `tot'[_N] if missing(`c')
		if "`raw'" != "" {
			replace `freq' = 0 if missing(`c')
			bys `by' `r' (`c') : replace `tot' = sum(`freq')
			bys `by' `r' (`tot') : replace `freq' = `tot'[_N] if missing(`c')
		}
		drop `tot'

		// column totals
		bys `by' `c' : replace `mark' = (_n == 1) + 1
		expand `mark' , gen(`tot')
		if `"`=substr("`: type `r''",1,3)'"' == "str" {
			replace `r' = "" if `tot' == 1
		}
		else {
			replace `r' = . if `tot' == 1
		}
		replace `muhat' = 0 if `tot' == 1
		bys `by' `c' (`r') : replace `tot' = sum(`muhat')
		bys `by' `c' (`tot') : replace `muhat' = `tot'[_N] if missing(`r')
		if "`raw'" != "" {
			replace `freq' = 0 if missing(`r')
			bys `by' `c' (`r') : replace `tot' = sum(`freq')
			bys `by' `c' (`tot') : replace `freq' = `tot'[_N] if missing(`r')
		}
	}

	if "`row'" != "" {
		qui bys `r' `by' (`c') : replace `muhat' = `muhat'/`muhat'[_N]*100 
		qui bys `r' `by' (`c') : replace `freq' = `freq'/`freq'[_N]*100 
	}
	if "`col'" != "" {
		qui bys `c' `by' (`r') : replace `muhat' = `muhat'/`muhat'[_N]*100 
		qui bys `c' `by' (`r') : replace `freq' = `freq'/`freq'[_N]*100 
	}


	// display the result
	if "`raw'" != "" {
		local freqopt "`freq'"
	}
	if "`by'" != "" {
		local byopt "by(`by')"
	}
	tabdisp `r' `c' , `byopt' cellvar(`muhat' `freqopt') totals format(`format') `options'

	// restore or replace original data
	if `"`replace'`replace2'"' == "" {
		restore
	}
	else {
		if "`raw'" != "" {
			qui gen double _freq = `freq'
			format _freq `format'
			if "`weight'" == "pweight" {
				label variable _freq "sum of weights"
			}
			else {
				label variable _freq "observed counts"
			}
		}
		qui gen double std = `muhat'
		label variable std "standardized counts"
		format std `format'
		restore, not
		if "`current'" != "" {
			frame change `current'
		}
	}
	return local rowvar "`r'"
	return local colvar "`c'"
	return local byvar  "`by'"
	return local kc = `kc'
	return local kr = `kr'
	if "`raw'" != "" return local raw "raw"	
	return local cmd "stdtable"
end

program define Parseby, rclass
	version 8
	syntax [varname(default=none) ] [if], touse(varname) [BASEline(string)]
	
	if "`varlist'" == "" & "`baseline'" != "" {
		di as err "{p}the baseline suboption can only be specified when specifying a variable in the main by() option{p_end}" 
		exit 198
	}
	if "`varlist'" == "" exit

	if "`baseline'" != "" {
		markout `touse' `varlist', strok
		capture confirm string variable `varlist'
		if _rc {
			qui count if `varlist' == `baseline' & `touse' == 1
			if r(N) == 0 {
				di as err "{p}the value `baseline' must occur in `varlist'{p_end}"
				exit 2000
			}
			return scalar baseline = `baseline'
		}
		else {
			qui count if `varlist' == `"`baseline'"' & `touse' == 1
			if r(N) == 0 {
				di as err "{p}the value `baseline' must occur in `varlist'{p_end}"
				exit 2000
			}
			return local baseline `"`baseline'"'
		}
		
	}
	return local by "`varlist'"
end

program define Parseframe, rclass
	version 16
	syntax name(name=frame), [replace]
	
	qui frames dir
	local frames = r(frames)
	if `: list frame in frames' & "`replace'" == "" {
		di as err "{p}frame `frame' already exists{p_end}"
		exit 110
	}
	qui frame
	local current = "`r(currentframe)'"
	if "`current'" == "`frame'" {
		di as txt "{p}(note: `frame' is the current frame){p_end}"
	}
	return local  current      "`current'"
	return scalar iscurrent =  "`current'" == "`frame'"
	return local  frame        "`frame'"
	return local  framereplace "`replace'"
end

* Based on contract version 1.2.4  17sep2004
program define Contract_w
        version 6.0, missing
        syntax varlist [if] [in] [iw aw fw] [, Freq(string) Zero noMISS]

        *Mark Observations* 
        if "`miss'"=="nomiss" { 
                marksample touse , strok 
        }
        else {                  
                marksample touse , strok novarlist 
        }

        * Check generated variables *
        if "`zero'" != "" {
                capture confirm new variable _fillin
                if _rc != 0 {
                        di as error "_fillin already defined"
                        exit 110
                }
        }

        if `"`freq'"' == "" {
                capture confirm new variable _freq
                if _rc == 0 {
                        local freq "_freq"
                }
                else {
                        di as error "_freq already defined: " /*
                        */ "use freq() option to specify frequency variable"
                        exit 110
                }
        }
        else {
                confirm new variable `freq'
        }
        
        *Create dataset*
        tempvar expvar
        if `"`exp'"' == "" { 
                local exp "= 1" 
        }
        qui gen double `expvar' `exp'

        preserve

        qui keep if `touse'
        if _N == 0 { 
                error 2000 
        }
        keep `varlist' `expvar'
        sort `varlist'

        qui by `varlist' : gen double `freq' = sum(`expvar')
		if "`weight'" == "iweight" | "`weight'" == "aweight" {
			label var `freq' "Sum(weight)"
		}
		else {
			label var `freq' "Frequency"
        }
		qui by `varlist' : keep if _n == _N

        if "`zero'" != "" {
                fillin `varlist'
                qui replace `freq' = 0 if `freq' >= .
                qui drop _fillin
        }
        
        restore, not
end

