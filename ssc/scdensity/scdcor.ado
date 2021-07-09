*! scdcor version 1.0.1 JL 4April2012

cap program drop scdcor
program define scdcor

	version 9.2
	
	syntax varname(numeric) [if] [in] [ , 	///
		ADDkde(string)						///
		bw(string) 							///
		n(integer 0) 						///
		Range(string) 						///
		EXpand								///
		gtd									///
		TOLerance(real 1e-4)				///
		INItial(real 1)						///
		INTERval(real 1) 					///
		CLINE1opts(string) 					///
		CLINE2opts(string) 					///
		CLINE3opts(string) * ]
		
	marksample touse
	
	tempvar den cden grid
	
	scdensity `varlist' if `touse', 			///
	nogr n(`n') range(`range') 					///
	g(`den' `grid') `expand'
	
	scdensity `varlist' if `touse', 			///
	nogr corr `gtd' n(`n') range(`range')		///
	tol(`tolerance') ini(`initial')				///
	inter(`interval') g(`cden') `expand'
	
	loc m=r(n_points)
	
	qui sum `grid', meanonly
	loc min=r(min)
	loc max=r(max)

	qui cou if `touse'
	local N=r(N)
		
	if "`addkde'"!="" {
		tempvar kde kdeg
		qui kdens `varlist' if `touse', kernel(`addkde') 	///
		bw(`bw') g(`kde' `kdeg') n(`m') n2(`m') 		///
		range(`min' `max') nogr
		di("{txt}{hline 30}")
		di as txt "Kernel density estimate:"
		di("{txt}{hline 30}")
		di as text 	"Kernel: " as res "`r(kernel)'"
		di as text 	"Bandwidth: " as res `r(width)'
		di as txt 	"# of grid points: " as res `r(n)'
		di("{txt}{hline 30}")
		loc bandw=trim("`: di %10.3f r(width)'")
		loc k="line `kde' `kdeg'"
		loc leg1=3
		loc leg2="Kernel density"
		loc note2="Kernel density: kernel = `r(kernel)', bandwidth = `bandw', estimator = `r(estimator)'"
	}
	
	_get_gropts , graphopts(`options') gettwoway
	
	loc note1="Note: number of grid points = `m', N = `N'"
	local lab : var label `varlist'
	if "`lab'"=="" local lab="`varlist'"
	
	line `den'  `grid', `cline1opts' ||							///
	line `cden' `grid', `cline2opts' || `k' , 					///
	`cline3opts'												///
	legend(order(	1 "Original estimate" 						///
					2 "Corrected estimate"						///
					`leg1' "`leg2'"))							///
	xtitle("`lab'") ytitle("Density")							///
	title("Self-consistent density estimation", box bexpand) 	///
	note("`note1'" "`note2'", pos(6))							///
	`s(twowayopts)'
		
end
