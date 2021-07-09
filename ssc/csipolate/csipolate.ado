*! NJC 1.0.1 6 April 2011 
*! NJC 1.0.0 19 Feb 2009 
* cipolate NJC 1.0.0 4 July 2002 
* ipolate 1.3.1  14jun2000
program csipolate, byable(onecall) sort
	version 9
	syntax varlist(min=2 max=2) [if] [in], Generate(string) [ BY(varlist) ]
	
	if _by() {
		if "`by'" != "" {
			di as err ///
			"option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	confirm new var `generate'
	tokenize `varlist'
	args usery x 

	if "`by'" == "" { 
		tempvar by 
		gen byte `by' = 1
	} 

	tempvar group y z guse zmiss 
	
	quietly {
		// don't mark out missing y: that's the whole point! 
		marksample touse, novarlist 
		markout `touse' `x' 

		// average multiple y for repeated x 
		bysort `touse' `by' `x': ///
		gen `y' = sum(`usery') / sum(`usery' < .) if `touse'
		by `touse' `by' `x': replace `y' = `y'[_N]

		// only use one of any repeated x 
		by `touse' `by' `x': gen byte `guse' = `touse' & (_n == 1)

		sort `guse' `by' `x' 
		egen `group' = group(`by') if `guse' 
		su `group', meanonly 
		local ng = r(max) 
		gen `z' = `y' if `touse'
		gen byte `zmiss' = 0 

		forval g = 1/`ng' { 
			replace `guse' = `group' == `g' 
			replace `zmiss' = `guse' & missing(`z') 
			count if `zmiss' 
			if r(N) > 1 { 
	mata : csipolate("`y'", "`x'", "`guse'", "`z'", "`zmiss'") 
			}
		} 
	
		// copy interpolated y to repeated x 	
		bysort `touse' `by' `x' (`z') : ///
			replace `z' = `z'[1] if `touse' & `z' == .  

		rename `z' `generate'
		count if `generate' == .
	}
	
	if r(N) > 0 {
		if r(N) != 1 local pl "s" 
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end

mata: 

void csipolate(string scalar yvarname, 
               string scalar xvarname, 
	       string scalar tousename, 
	       string scalar zvarname, 
	       string scalar zmissname
	) { 

real matrix xyvar    
real colvector x, y, where 

st_view(xyvar, ., (xvarname, yvarname), tousename) 
x = select(xyvar[,1], (xyvar[,2] :< .)) 
where = select(xyvar[,1], (xyvar[,2] :== .)) 
y = select(xyvar[,2], (xyvar[,2] :< .)) 
st_store(., zvarname, zmissname, spline3eval(spline3(x, y), where))   

}

end 
        	
