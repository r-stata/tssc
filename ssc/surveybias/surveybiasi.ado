/* surveybiasi.ado --- 
 * 
 * Filename: surveybiasi.ado
*! Author: Kai Arzheimer & Jocelyn Evans
 * URL: 
 * Keywords: 
 * Compatibility: 
 * 
 */

/* Commentary: 
 * 
 * 
 * 
 */

/* Change log:
 * 
 * 
 */

/* Code: */

*! 1.4 Aug 07 2015
*! Immediate estimation of survey bias measures

program define surveybiasi, eclass
version 11
* replay() does not work for immediate commands
* No arguments at all - replay
	if "`1'" == "" {
		ereturn display
		exit		
		}

* Options may follow comma immediately or w spaces
	tokenize "`*'" , parse(",")
* Options are now in `2'
	tokenize "`2'"

* If there is no option (just ,), or if level is the first option and there are no other options
* we're in replay state
	if ("level(" == substr("`1'", 1,6) & "`2'" == "") |  ("`1'" == "" ) {
		syntax [, Level(cilevel)] [prop] [NUMerical]
		ereturn display, level(`level')
		exit		
		}
	
* Not replay!	
	else {
		syntax , POPvalues(numlist min=2 max=12 ) SAMPLEvalues(numlist min=2 max=12 ) n(numlist min=1 max=1 >1) [Level(cilevel)]  [prop] [NUMerical]
		local commandline   "surveybiasd `*'"
		local poplength : word count `popvalues'
		local samplength : word count `samplevalues'
		local commandline   "surveybiasi `0'"
		if `poplength' != `samplength' {
			display as error "Number of population values must equal number of sample values" _newline
			error 121
			}
* Test for values in numlist not >0
		local allvalues : list popvalues | samplevalues
		foreach value of local allvalues  {
			if `value'  <=0 {
				display as error "All proportions must be strictly positive."
				display as error "If a category is not at all observed in the sample, "
				display as error "try entering it as a small positive fraction (e.g. 10^-6)" _newline
				error 125
				}
			
			
			}

* Normalise information on sample to proportions

* Calculate sum
		local samplevalsum = subinstr("`samplevalues'"," "," + ",.)
* Force evaluation of sum	
		local samplevalsum = `samplevalsum'
* Normalise
		local normsamplevalues = ""
		foreach v of local samplevalues {
			local normedval =  `v' / `samplevalsum'
			local normsamplevalues `normsamplevalues' `normedval'
			}
* Clear e() to get rid of e(sample) if set
		ereturn clear
		
* Preserve data and clear
		preserve
		clear
* Build data
		qui set obs `samplength'

* Create partyvar
		qui gen catvar = _n
* Create multiplier
		qui gen number = .
		forvalues line = 1 / `samplength' {
			local thisnormedvalue : word `line' of `normsamplevalues'
			qui replace number = `thisnormedvalue' * `n' in `line'
			}

* Call surveybias command
		capture surveybias catvar [iweight=number], popvalues(`popvalues')  level(`level') `prop' `numerical'
		if _rc != 0 {
			di as error "An internal function call has failed, probably due to convergence" _newline
			di as error "problems. This is embarrasing." _newline
			di as error "Please contact kai.arzheimer@gmail.com,"
			di as error "preferably attaching a copy of your data/logfile." _newline
			error 499
			}
* Capture suppresses all output from surveybias, so we must re-display the results
		ereturn display, level(`level')
		display as text " "
		display as text _col(5) "Ho: no bias"
		
		display as text _continue _col(5) "Degrees of freedom: "
		display as result  _col(25) e(df)

		display as text _continue _col(5) "Chi-square (Pearson) = "
		display as result  _col(26) e(chi2p)
		display as text _continue _col(5) "Pr (Pearson) = "
		display as result _col(18) e(pp)

		display as text _continue _col(5) "Chi-square (LR) = "
		display as result   _col(20) e(chi2lr)
		display as text _continue _col(5) "Pr (LR) = "
		display as result _col(13) e(plr)

* Small sample size?

		if e(N) < 100 {
			display _n "Warning: The effective sample size is very small (n=`cases')."
			display "Chi square values may be unrealiable."
			display "Consider using mgof (ssc describe mgof) for exact tests."
			}


* Set commandline/command
		ereturn local cmdline `commandline'
		ereturn local cmd "surveybiasi"
		ereturn local depvar ""
		}

	
end


/* surveybiasi.ado ends here */
