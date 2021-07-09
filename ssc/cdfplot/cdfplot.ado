*! Date    : 10 July 2008
*! Version : 1.04
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-hnr.cam.ac.uk

*! ADAPTED from version 1.0.1 David Clayton/Michael Hills Oct-95    STB-49 gr37

/*
29/03/07 version 1.03 - Remove a describe at the end of the program
10/07/08 version 1.04 - Add an option to stop the cdf being plotted
*/

program define cdfplot
version 9.0
syntax varname [aweight fweight iweight pweight] [if] [in] [,BY(varname) opt1(string) opt2(string) NOCDF NORMal SAMEsd XLOG * ]
local goptions `"`options'"'

/* Check options */
if "`nocdf'"~="" & "`normal'"=="" {
  di "{err}WARNING the nocdf option can only be used when the normal option is specified"
  exit(198)
}

preserve

local yv "`varlist'"
local yvlab : variable label `yv'

/* Log-transformation -- need for change?*/
tempvar yvar w touse
if "`xlog'"=="" {
  qui gen `yvar' = `yv'
  lab var `yvar' "`yvlab'"
}
else {
  qui gen `yvar' = log(`yv')
  lab var `yvar' "Log `yvlab'"
  local yvlab "Log `yvlab'"
}

/* All the weights required.. */
if "`weight'"=="" qui gen `w' = 1
else qui gen `w' `exp'

/* The missing data steps */
qui egen int `touse' = rmiss(`varlist' `w') `if' `in' 
qui drop if `touse'>0 
qui replace `touse'= 0
qui replace `touse'=1 `if' `in'
keep if `touse'
keep `yv' `yvar' `w' `by'
tempvar cw ccw grp sy ssy

/* now calculations... */

if "`by'"=="" {

  /* cw is the cumulative probabilities  sy is the normalised version */

  sort `yvar'
  qui gen `cw' = sum(`w')
  if "`normal'"~="" {
    qui gen `sy' = sum(`w'*`yvar')
    qui replace `sy' = `yvar' - `sy'[_N]/`cw'[_N]
    qui gen `ssy' = sum(`w'*(`sy'^2))
    if "`weight'"=="" | "`weight'"=="`fweight'" qui replace `sy' = `sy'/sqrt(`ssy'[_N]/(`cw'[_N]-1))
    else qui replace `sy' = `sy'/sqrt(`ssy'[_N]/`cw'[_N])
    qui replace `sy' = normprob(`sy')
    qui replace `cw' = `cw'/`cw'[_N]

    lab var `sy' "Normal c.d.f."
    lab var `cw' "c.d.f."

    local vlist "`cw'"
    local nlist "`sy'"
  }
  else {
    qui replace `cw' = `cw'/`cw'[_N]
    local vlist "`cw'"
  }

}

else {
  qui levelsof `by'
  local bylevs "`r(levels)'"

  sort `by' `yvar'
  qui by `by': gen `cw' = sum(`w')
  qui by `by': gen `grp' = (_n==1)
  qui replace `grp' = sum(`grp')

  if "`normal'"~="" {
    qui by `by': gen `sy' = sum(`w'*`yvar')
    qui by `by': replace `sy' = `yvar' - `sy'[_N]/`cw'[_N]
    if "`samesd'"=="" {
      qui by `by': gen `ssy' = sum(`w'*(`sy'^2))
	if "`weight'"=="`fweight'"|"`weight'"=="" qui by `by':replace `sy'=`sy'/sqrt(`ssy'[_N]/(`cw'[_N]-1))
      else qui by `by':replace `sy'=`sy'/sqrt(`ssy'[_N]/`cw'[_N])
    }
    else {
      qui gen `ccw' = sum(`w')
      qui gen `ssy' = sum(`w'*(`sy'^2))
      if "`weight'"=="`fweight'"|"`weight'"=="" qui replace `sy'=`sy'/sqrt(`ssy'[_N]/(`ccw'[_N]-`grp'[_N]))
      else qui replace `sy'=`sy'/sqrt(`ssy'[_N]/`ccw'[_N])
    }
  }
  qui by `by': replace `cw' = `cw'/`cw'[_N]
	
  /* now the loop by the different groups */

  local group 1
  while `group' <= `grp'[_N] {
    tempvar gsc
    qui gen `gsc' = `cw' if `group'==`grp'

    /* Check whether the variable has a value label and then label accordingly */
    local test: value label `by'
    local bylevval: word `group' of `bylevs'
    if "`test'"~="" local bylevname: label (`by') `bylevval'
    else local bylevname `"`bylevval'"'    
    lab var `gsc' "c.d.f. of  `bylevname' "

    if "`normal'"=="" {		
	local vlist "`vlist' `gsc'"
	local group = `group'+1
    }
    else {
	tempvar gsd 
	qui gen `gsd' = normprob(`sy') if `group'==`grp'
      lab var `gsd' "Normal c.d.f. for `bylevname' "
	local vlist "`vlist' `gsc' "
	local nlist "`nlist' `gsd' "
	local group = `group'+1
    }
  }


}
qui replace `yv' = .  if _n<_N & `yvar'[_n]==`yvar'[_n+1]

local n: list sizeof vlist
local connect: di _dup(`n') "J "

local plot1 `" (line `vlist' `yv', c(`connect') cmissing(y) `opt1') "'
if "`normal'"~="" local plot2 "|| (line `nlist' `yv', `opt2')"

if "`nocdf'"~="" & "`normal'"~="" cap twoway  `plot2', ylabel(, angle(0)) ytitle(Cumulative Probability) `goptions'
else cap twoway `plot1' `plot2', ylabel(, angle(0)) ytitle(Cumulative Probability) `goptions'

if _rc~=0 {
  di as error "WARNING: problem with the twoway command "
  twoway `plot1' `plot2', ylabel(, angle(0)) ytitle(Cumulative Probability) `goptions'
}

end
