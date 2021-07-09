*! tablecol.ado -- adds row or column percentages to -table-
*! version 1.2 NJGW 25mar2010
program define tablecol
	version 6
	syntax varlist(max=3) [if] [in] [fw aw pw iw] [ , /*
			*/ colpct rowpct replace Name(string) Contents(string) BY(varlist) Overall noFreq row * ]


	if "`colpct'"!="" & "`rowpct'"!="" {
		di in red "May only specify one of -colpct- and -rowpct-"
		error 198
	}
	if "`colpct'"!="" {
		Col `0'
		exit
	}
	Row `0'

end


program define Col
	version 6.0

	syntax varlist(max=3) [if] [in] [fw aw pw iw] [ , /*
			*/ colpct replace Name(string) Contents(string) BY(varlist) Overall noFreq row * ]

	if "`content'"!="" & "`content'" != "freq" {
		di in red "Only works with contents(freq)"
		error 198
	}

	if "`by'" != "" {
		local byopt "by(`by')"
		if "`overall'"=="" {
			local bytot `by'
		}
	}

	if "`replace'"!="" {
		local norep "*"
	}
	if "`name'"=="" {
		local i 1
		local done 0 
		while !`done' {
			local done 1
			local name "__tc`i'"
			cap confirm new variable `name'1
			if _rc {
				if `i'>50 {
					di in red "__tc11 through __tc501 all exist"
					di in red "delete or specify name() option"
					error 198
				}
				local done 0
				local i=`i'+1
			}
		}
	}

	`norep' preserve
	quietly {
		table `varlist' `if' `in' [`weight'`exp'] , `row' `byopt' `options' replace name(`name')
	}
	tokenize `varlist'
	args rrow col supcol

	if "`colpct'"!="" {
		sort `bytot' `supcol' `col' `rrow'
		tempvar cpct
		qui gen `cpct'=.
		quietly {
			by `bytot' `supcol' `col': replace `cpct'= sum(`name'1)
			if "`row'"=="row" {
				replace `cpct'=`cpct'/2
			}
			by `bytot' `supcol' `col': /*
				*/  replace `cpct'=((`name'1)/(`cpct'[_N]))*100
		}
		format `cpct' %6.2f
	}

	if "`freq'"=="" {
		local fvar "`name'1"
	}

	tabdisp `rrow' `col' `supcol', c(`fvar' `cpct') total `byopt'

end



program define Row
	version 6.0

	syntax varlist(max=3) [if] [in] [fw aw pw iw] [ , /*
			*/ rowpct replace Name(string) Contents(string) BY(varlist) Overall noFreq row col scol * ]

	if "`content'"!="" & "`content'" != "freq" {
		di in red "Only works with contents(freq)"
		error 198
	}

	if "`by'" != "" {
		local byopt "by(`by')"
		if "`overall'"=="" {
			local bytot `by'
		}
	}

	if "`replace'"!="" {
		local norep "*"
	}
	if "`name'"=="" {
		local i 1
		local done 0 
		while !`done' {
			local done 1
			local name "__tc`i'"
			cap confirm new variable `name'1
			if _rc {
				if `i'>50 {
					di in red "__tc11 through __tc501 all exist"
					di in red "delete or specify name() option"
					error 198
				}
				local done 0
				local i=`i'+1
			}
		}
	}

	`norep' preserve
	quietly {
		table `varlist' `if' `in' [`weight'`exp'] , `row' `col' `scol' `byopt' `options' replace name(`name')
	}
	tokenize `varlist'
	args rrow ccol supcol

	if "`rowpct'"!="" {
		sort `bytot' `rrow' /*`supcol'*/ `ccol' 
		tempvar cpct
		qui gen `cpct'=.
		quietly {
			by `bytot' `rrow' /*`supcol'*/ : replace `cpct'= sum(`name'1)
*			if "`row'"=="row" {
*				replace `cpct'=`cpct'/2
*			}
			by `bytot' `rrow' /*`supcol'*/ : /*
				*/  replace `cpct'=((`name'1)/(`cpct'[_N]))*100
			if "`col'"!="" {
				replace `cpct' = `cpct'*2
			}
			if "`scol'"!="" {
				replace `cpct' = `cpct'*2
			}
		}
		format `cpct' %6.2f
	}

	if "`freq'"=="" {
		local fvar "`name'1"
	}

	tabdisp `rrow' `ccol' `supcol', c(`fvar' `cpct') total `byopt' 

end




*end&
