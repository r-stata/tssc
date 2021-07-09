*! version 0.1.0, Brent McSharry, 12july2013
*  1. boxpanel
*  2. iterate_marker
program boxpanel, sortpreserve
version 10.1
syntax varlist(min=2 max=2 numeric) [if] [in][, TRACKby(varname) JOINmedian barw(real 0)]
/*
Nick Cox Stata journal article http://www.stata-journal.com/sjpdf.html?articlenum=gr0039
correction acknowledged http://www.stata.com/statalist/archive/2013-03/msg00917.html
*/
marksample touse
local yvar:word 1 of `varlist'
local timeCat:word 2 of `varlist'
tempvar median upq loq iqr upper lower
qui {
	egen `median' = median(`yvar') if `touse', by(`timeCat')
	egen `upq' = pctile(`yvar') if `touse', p(75) by(`timeCat')
	egen `loq' = pctile(`yvar') if `touse', p(25)  by(`timeCat')
	gen `iqr' = `upq' - `loq'
	egen `upper' = max(`yvar' / (`yvar' < `upq' + 1.5 * `iqr')) if `touse', by(`timeCat')
	egen `lower' = min(`yvar' / (`yvar' > `loq' - 1.5 * `iqr')) if `touse', by(`timeCat')
	if ("`trackby'"!="") {
		tempvar outlierGroup outlier
		tempname outlierLab
		egen int `outlier'=group(`trackby') if `touse' & !inrange(`yvar', `lower', `upper'), lname(`outlierLab')
		/*
		This code extends the line to the observation before and after the outlier:
		bysort `trackby' (`timeCat'):replace `outlier'=`outlier'[_n+1] if _n!=_N & missing(`outlier') & !missing(`outlier'[_n+1])
		gsort +`trackby' -`timeCat'
		by `trackby':replace `outlier'=`outlier'[_n+1] if _n!=0 & missing(`outlier') & !missing(`outlier'[_n+1])
		*/
		sum `outlier',meanonly
		if (r(N)>0) {
			local outlierMax `r(max)'
			gen `outlierGroup'=.
			bysort `trackby' (`timeCat'):replace `outlierGroup' = sum(!mi(`outlier') & (_n==_N | !mi(`outlier'[_n+1])) & (_n==0 | mi(`outlier'[_n-1])))
			replace `outlierGroup'=. if mi(`outlier') | (_n==_N | mi(`outlier'[_n+1]) & (_n==0 | mi(`outlier'[_n-1])))
			// noi li `trackby' `yvar' `timeCat' `outlier' `outlierGroup'
			forvalues i=1(1)`outlierMax' {
				iterate_marker `i'
				local outlierPlot `outlierPlot' ( scatter `yvar' `timeCat' if `outlier'==`i' & !inrange(`yvar', `lower', `upper'), mfcolor(`r(mfcolor)') mlcolor(`r(mlcolor)') mlwidth(medthick)  ms(O)) 
				local lcolor `r(mlcolor)'
				local lpattern `r(lpattern)'
				local ilab:label `outlierLab' `i'
				local legendOpt `legendOpt' label(`i' `ilab')
				local legendOrder `legendOrder' `i'
				sum `outlierGroup' if `outlier'==`i', meanonly
				if (r(N) > 0){
					forvalues grp = 1(1)`r(max)' {
						local outlierLine `outlierLine' ( line `yvar' `timeCat' if `outlier'==`i' & `outlierGroup'==`grp', lcolor(`lcolor') lpattern(`lpattern') lwidth(vvthin) )
					}
				}
				local ++i
			}
		}
		local legendOpt `legendOpt' order(`legendOrder') pos(3) cols(1)
		sort `timeCat'
		label drop `outlierLab' 
	} 
	else {
		local outlierPlot ( scatter `yvar' `timeCat' if !inrange(`yvar', `lower', `upper'), ms(Oh) )
		local legendOpt off
	}
}
if ("`joinmedian'" != "") {
	local medianLine ( line `median' `timeCat' )
}
if (`barw' == 0) {
	minimum_gap `timeCat'
	local barw = 0.5 * `r(min)'
}
twoway `outlierPlot' /*
	*/ ( rbar `median' `upq' `timeCat', pstyle(p1) blc(gs15) bfc(gs8) barw(`barw') ) /*
	*/ ( rbar `median' `loq' `timeCat', pstyle(p1) blc(gs15) bfc(gs8) barw(`barw') ) /*
	*/  `medianLine' /*
	*/ ( rspike `upq' `upper' `timeCat', pstyle(p1) ) /*
	*/ ( rspike `loq' `lower' `timeCat', pstyle(p1) ) /*
	*/ ( rcap `upper' `upper' `timeCat', pstyle(p1) msize(*2) ) /*
	*/ ( rcap `lower' `lower' `timeCat', pstyle(p1) msize(*2) ) /*
	*/ `outlierLine' /*
	*/, legend(`legendOpt') 
	
end

*! version 0.1.0, Brent McSharry, 12july2013
*create different appearing markers and lines
program define iterate_marker, rclass
version 10.1
args iterator
confirm integer number `iterator'
/* http://www.ats.ucla.edu/STAT/stata/faq/showmark.htm */
local colors gs6 navy maroon forest_green dkorange teal cranberry lavender khaki sienna emidblue emerald brown erose gold bluishgray
local patterns solid dash longdash dot longdash_dot dash_dot shortdash shortdash_dot
local colorCount 16 //:word count `colors'
local patternCount 8 // wordcount("`patterns'")
local linep 128 // = `colorCount' * `patternCount'
local colorp 256 // = `colorCount' * `colorCount'
if (`iterator'>`colorp') {
	di as text "Warning: exceeded maximum number of color combinations - markers will not be unique."
	local iterator = mod(`iterator', `colorp')
	if (`iterator' == 0) {
		local `iterator' `colorCount'
	}
}
if (`iterator' > `linep'){
	di as text "Warning: exceeded maximum number of line pattern/color combinations - lines will not be unique."
	local lpi = mod(`iterator', `linep')
	if (`lpi' == 0) {
		local `lpi' `patternCount'
	}
}
else {
	local lpi `iterator'
}
local mfi = floor(`iterator'/`colorCount')
local mli = `iterator' - (`mfi' * `colorCount')
local ++mfi
local lpi = floor(`lpi'/`colorCount') + 1
return local mfcolor = word("`colors'", `mfi')
return local mlcolor = word("`colors'", `mli')
return local lpattern = word("`patterns'", `lpi')
end

*! version 0.1.0, Brent McSharry, 12july2013
*work out the minimum difference between a numeric ordered variable
program define minimum_gap, rclass
version 10.1
syntax varname(numeric)
qui {
	levelsof `varlist', local(cats)
	local min .
	foreach l of local cats {
		if ("`lastval'"!="") {
		local gap = `l' - `lastval'
			if (`min' > `gap') {
				local min `gap'
			}
		}
		local lastval `l'
	}
	return scalar min = `min'
}
end
