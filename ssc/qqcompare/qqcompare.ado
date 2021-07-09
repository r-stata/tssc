/* 
Version 1; 06.12.2012
Author: Sunil Mitra Kumar
stuff.sunil@gmail.com
*/

program define qqcompare, rclass
version 9
syntax varlist (min=1) [, precision(integer 10) treatment(varname) ///
weight(varname) drawgraph indivoptions(string) overalloptions(string) ///
matchopts(string) unmatchopts(string) lineopts(string) ] 

tempname original

		cap which cquantile
		if (_rc) {
			di as error "You need to install package -cquantile-. Type -ssc install cquantile-"
			exit  198
		}


if `precision'<1 {
di as error "value specified in option precision() must be greater than 1"
exit 198
}

if "`treatment'"=="" local treatment _treated
if "`weight'"=="" local weight _weight 

* Expand dataset according to weights, but mark original as 1 and duplicates as 0
	preserve
*	keep `weight' `treatment' `varlist'
	qui replace `weight'=round(`precision'*`weight') if `weight'!=.
	qui expand `weight', gen(`original')
	qui replace `original'=!`original'

* Construct matrix of results
	matrix qqcompareres=J(1,5,.)
	local cnames  mean_dev per_reduct max_dev per_reduct mean_diff_sd_ratio
	local rnames blank


* table header
	di as text "{hline 12}{c TT}{hline 20}{c TT}{hline 9}{c TT}{hline 20}{c TT}{hline 10}{c TT}{hline 14}{c TT}{hline 16}"
	di as text " Variable   {c |}    Mean deviation  {c |} % reduct{c |}    Max deviation   {c |} % reduct {c |}Pass Cochran's{c |} Diff in means " 
	di as text "            {c |} of QQ from 45 deg  {c |}         {c |} of QQ from 45 deg  {c |}          {c |}rule of thumb?{c |} as propn of sd "  
	di as text "{hline 12}{c +}{hline 20}{c +}{hline 9}{c +}{hline 20}{c +}{hline 10}{c +}{hline 14}{c +}{hline 16}"

foreach qqvar of varlist `varlist' {
	tempname qut quc qmt qmc eq umean umax mmean mmax qmdiff qudiff umean umax mmean mmax meanimp maximp sd tm cm psd pass maxqut maxquc maxqmt maxqmc minqut minquc minqmt minqmc rangemax rangemin
	
* Calculate deviation from the 45 degree QQ plot line in terms of mean and max
	

	cquantile `qqvar' if `original', by(`treatment') gen(`qut' `quc')
	qui g `qudiff'=`qut'-`quc'
	qui su `qudiff'
	scalar `umean'=abs(r(mean))
	scalar `umax'=max(abs(r(max)),abs(r(min)))
	cquantile `qqvar' if `weight'!=., by(`treatment') gen(`qmt' `qmc')
	qui g `qmdiff'=`qmt'-`qmc'
	qui su `qmdiff'
	scalar `mmean'=abs(r(mean))
	scalar `mmax'=max(abs(r(max)),abs(r(min)))
	scalar `meanimp'=(`umean'-`mmean')*100/`umean'
	scalar `maximp'=(`umax'-`mmax')*100/`umax'
	
* See if matching balance satisfies Cochran's (1968) rule of thumb
	
	qui su `qqvar' if `weight'!=. 
	scalar `sd'=r(sd)
	qui su `qqvar' if `weight'!=. & `treatment'
	scalar `tm'=r(mean)
	qui su `qqvar' if `weight'!=. & !`treatment'
	scalar `cm'=r(mean)
	scalar `psd'=(abs(`cm'-`tm'))/`sd'
	if (abs(`cm'-`tm')<0.25*`sd') local pass="y"  
	if (abs(`cm'-`tm')>=0.25*`sd') local pass="n"  
	scalar `psd'=(abs(`cm'-`tm'))/`sd'   
	
	
* display results
	
	di as text %11s abbrev("`qqvar'",11) _s(1)"{c |}" _s(7)as result %06.0g `mmean' _s(7)as text "{c |}" _s(1) as result %06.0g `meanimp' _s(2) as text "{c |}" _s(7)as result %06.0g `mmax' _s(7)as text "{c |}" _s(3) as result %06.0g `maximp' _s(1)as text "{c |}" _s(7) as text "`pass'" _s(6)as text "{c |}" _s(4) as result %06.0g `psd'
	
* store the same values in the matrix qqcompareres
		mat qqcompareres=qqcompareres\[`mmean', `meanimp', `mmax', `maximp', `psd']
		local rnames `rnames' `qqvar'


* draw quantile-quantile plot
	if "`drawgraph'"!="" {
	
	* draw the 45 deg. line.
		qui gen `eq'=`quc'
		foreach smvar in `qut' `qmt' `qmc' {
		qui replace `eq'=`smvar' if `eq'==.
		}
	
	* make sure ranges for both axes match; also note minmax option in the graph; ref. Nick Cox.
	qui su `qut'
	local rangemax=r(max)
	local rangemin=r(min)	
	
	foreach qq of varlist `quc' `qmt' `qmc' {
	qui su `qq'
	local rangemax=max(`rangemax',r(max))
	local rangemin=min(`rangemin',r(min))
	}


	qui	tw (scatter `qut' `quc',  `unmatchopts' ) ///
			(scatter `qmt' `qmc', `matchopts' ) ///
			(line `eq' `eq', `lineopts'), ///
			yscale(range(`rangemin' `rangemax')) ///
			xscale(range(`rangemin' `rangemax')) ///
			xlabel(minmax) ylabel(minmax) ///
			aspect(1) legend(label(1 "Unmatched") label(2 "Matched") order(1 2)) ///
			nodraw title("`qqvar'", span size(medium)) name(q`qqvar', replace) `indivoptions'
	local graphlist `graphlist' q`qqvar'
	}
}

	if "`drawgraph'"!="" {
*	graph combine `graphlist'
	grc1leg `graphlist', `overalloptions'  com
	}

	mat rownames qqcompareres=`rnames'
	mat colnames qqcompareres=`cnames'
	mat qqcompareres=qqcompareres[2..., 1...]
	return mat qqcompare=qqcompareres

restore
end 
