program define clustergram
*! 1.0.0 1 August 2002 Matthias Schonlau 
	version 7 
	syntax varlist [if] [in], CLuster(varlist) [ fill FRaction(real 0.2) /* 
*/ XLAbel(numlist) YLAbel(numlist sort) COnnect(str) Symbol(str)  Gap(int 5) * ]

	* trap -connect()-, -symbol()- 
	foreach opt in connect symbol {
		if "``opt''" != "" { 
			di as err "`opt'() not supported: please see help" 
			exit 198 
		}	
	} 

	* observations to use 
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 { error 2000 } 

	* check whether jth variable defines j clusters 
	local nc = 0
	foreach v of var `cluster' {
		local nc = `nc' + 1
		tab `v' if `touse', nofreq
		if `nc' != `r(r)' {
			di as txt "Warning: `v' does not define `nc' clusters"
		}
	}

	preserve 
	qui keep if `touse' 

	tempvar id clustery clmean clmeanlag width clus_nlag 
	gen long `id'  = _n 
	local N = _N
	
	* stack the y variables into one variable clustery.
	tempname clustery  
	local k : word count `varlist' 
	tokenize `varlist' 
	forval i = 1 / `k' { 
		rename ``i'' `clustery'`i' 
	}
	qui reshape long `clustery', i(`id')   

	local max : word count `cluster' 
	
	* for each obs replace the cluster number with the cluster mean
	quietly foreach v of var `cluster' { 
		tempvar clmean
		bysort `v' : egen `clmean' = mean(`clustery')
		local clmeans "`clmeans' `clmean'" 
	} 	

	* data now contain (#id's * #y's) observations 
	* the cluster mean is the same across all y's, can collapse
	* (mean) clustery is not used 
	collapse (mean) `clustery', by(`id' `clmeans')
	
	* data now contain (#id's) observations and variables: 
	* id, the clmeans, clustery

	* clus_n is the index of clmean
	foreach v of varlist `clmeans' { 
		local args "`args' `v' `id'" 
	}
	stack `args', into(`clmean' `id') clear  
	local clus_n "_stack"
	qui { 
		bysort `id' (`clus_n') : gen `clmeanlag' = `clmean'[_n+1] 
		drop if `clmeanlag' == .
	} 	
	
	* clus_n is important in case there are the same means at 
	* different cluster sizes  
	contract `clmean' `clmeanlag' `clus_n' 
	
	* preparation of graph 
	label var `clus_n' "Number of clusters"
	label var `clmean' "Cluster mean"

	* create -ylabel()- -xlabel()- if none provided 
	* set `range' and use it to standardize `width'
	if "`ylabel'" == "" {
		summarize `clmeanlag', meanonly 
		local round = 1
		local miny = round(r(min),`round')
		local maxy = round(r(max),`round' )
		local midy = round(r(mean),`round')
		local ylabel "`miny' `midy' `maxy'"
		local range = r(max) - r(min)
	}
	else {
	* if `ylabel' supplied, reset `range' to depend on the range of `ylabel'
	* this causes different clustering algorithms with the same `ylabel'
	* to be standardized in the same way w.r.t width 
		local ylamin : word 1 of `ylabel' 
		local ylan : word count `ylabel' 
		local ylamax : word `ylan' of `ylabel' 
		local range = `ylamax' -`ylamin'
	}

	gen `width' =_freq / `N' * `range' * `fraction'

	if "`xlabel'" == "" { local xlabel "1 `max'" } 

	graph `clmean' `clus_n' , /* 
	*/ s(.) ylab(`ylabel') xlab(`xlabel')  gap(`gap') `options'

	* user typed -fill- or not => fill is 0 or 1 
	local fill = "`fill'" != ""
	* note the following line requires that the clusters increase one 
	* at a time
	gen `clus_nlag' = `clus_n' + 1
	Graphbox `clus_n' `clus_nlag' `clmean' `clmeanlag' `width' `fill' `range'
end

program define Graphbox
* draw a parallelogram (graph must exist already)
* xstart xend ystart yend 	(vectors)
*	start and end of the line segments for the center of the parallelogram
* width 	width of the parallelogram
* fill 	(scalar) if fill>0 then the parallelogram is filled with lines 
* to make it appear solid
	args xstart xend ystart yend width fill range
	tempvar x1 x2 y1 y2 y3 y4 
	gph open
	graph
	local ay = r(ay)
	local by = r(by)
	local ax = r(ax)
	local bx = r(bx)
	gen `x1' = `ax' * `xstart' + `bx'
	gen `x2' = `ax' * `xend' + `bx'

	* graph clockwise , starting at top left
	gen `y1' = `ay' * (`ystart' + `width' / 2) + `by'
	gen `y2' = `ay' * (`yend'   + `width' / 2) + `by'
	gen `y3' = `ay' * (`yend'   - `width' / 2) + `by'
	gen `y4' = `ay' * (`ystart' - `width' / 2) + `by'
	gph vpoly `y1' `x1' `y2' `x2' `y3' `x2' `y4' `x1' `y1' `x1' 

	* summarize `yend', meanonly 
	* local range = r(max) - r(min)
	if `fill' {
		* increment determines how densely each box is plotted
		local increment = .001 * `range'
		local N = _N

		forval i = 1 / `N' {
	   		local add = 0
   			while (`add' < `width'[`i']) {
				local y5 = /* 
*/ `ay' * (`ystart'[`i'] - `width'[`i'] / 2 + `add') + `by'
				local y6 = /* 
*/ `ay' * (`yend'[`i'] - `width'[`i'] / 2 + `add') + `by'
				local startx1 = `x1'[`i'] 
				local endx1 = `x2'[`i']
				gph line `y5' `startx1' `y6' `endx1'
				local add = `add' + `increment'
   			}
		}
	}
	gph close
end 

