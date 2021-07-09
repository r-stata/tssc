/* mcib.ado

Paul A. Jargowsky, Rutgers University - Camden
Version 2.0 - includes Theil Index 
Version 3.0 - Includes Gini Coeficient
version 4.0 - inclues option of twopoint alpha if mean not available, 
	also adds percentiles 5, 10, 20, 25, 30, 40, 50, etc.
version 5.0 -- Two major changes
 1) includes safeguards to prevent linear densities
	from dipping below zero and resets slope to zero 
	for local maxima and minima
 2) option to use Pareto distribution in top two brackets 
	or brackets above median
version 5.1 -- Bug fixes, removed uniform(closed) option 
June 14, 2019


Pleae report errors, comments, or suggestions to paul.jargowsky@rutgers.edu.

Syntax is:
mcib <count> <lower> <upper>, mean(<mean>)|twopoint [if] [<options>]
	One of these must be specified
		Mean(varname) -- Mean of distribution. If you have it, use it!
		TWOPoint -- Use two point method for alpha, calculate top mean from alpha
	Options
		UNIform(first|none|belowmed)
		-- which brackets get uniform distributions.  You can specify:
			first -- first bracket only (the default)
			none -- not recommended
			belowmed -- all below median
			PAReto(top|toptwo|abovemed)
		Saving(<filename>) -- file to store standard deviation to 
		REPLACE -- replace existing file
		BY(<id>) -- ID variable of units to analyze separately 
		Parts(integer) -- number of parts to use for gini bracket expansion
		KEEP -- keep the results, discarding starting data
		List -- Show the results on screen, default if not saving or keeping
		MINAlpha -- minimum alpha, default is 2

(capitalization gives minimum abbreviation)

Type "help mcib" for more infomration.
*/

capture program drop mcib 
program define mcib
	version 14.2
	display
	display as text "****** Begin MCIB, version 5.1 ******"
	display 
	
	syntax varlist (min=3 max=3 numeric) [if] ///
		, [Mean(varname numeric) TWOPoint PARTs(integer 5) /// 
		UNIform(string) PAREto(string) MINAlpha(real 2) ///
		Saving(string asis) REPLACE BY(varname) KEEP List] 
	
	
	preserve
	
	if "`if'"!="" keep `if'
	tokenize `varlist'
	local nb `1'
	local L `2'
	local U `3'
	local G `mean'
			
	* check to see which strategy to use for mean
		if ("`G'"=="") & ("`twopoint'"=="") {
			display as error "Either mean() or twopoint option is required."
			display as error "Provide a variable for the mean if available;"
			display as error "otherwise, specify option <twopoint> to estimate"
			display as error "alpha and the top bracket mean from the data."
			exit
			}
		if ("`G'"!="") & ("`twopoint'"=="twopoint"){
			display as text "Mean provided; twopoint option ignored."
			}
		if ("`G'"=="") & ("`twopoint'"=="twopoint"){
			display as text "Grand Mean not available. Alpha will be calculated"
			display as text "using two-point method; top bracket mean will be"
			display as text "calculated from alpha."
			}
				
	* check for a by variable; if none, create a fake one
		if "`by'" == "" {
			tempvar id
			gen `id' = 1
			}
		else local id `by'
		
	* consistency checks on mean, if mean was provided
		if ("`G'"!="") {
			capture assert `G'>0 
			if _rc {
				display as error "Mean (`G') should always be positive."
				exit 
				}
			capture assert `G'<. 
			if _rc {
				display as error "Mean (`G') should never be missing."
				exit 
				}
			tempvar sdmean
			egen `sdmean' = sd(`mean'), by(`id')
			capture assert abs(`sdmean')<.000001
			if _rc {
				display 
				display as error "Mean (`G') should be constant within `id'."
				exit
				}
			}
			
	* check value of minalpha
	if `minalpha'<1 {
		display
		display as text "Minimum alpha less than 1 makes no sense,"
		display as text "but let's run this and see what happens."
		display
		}
	
	* check for valid file name for saving results
		if `"`saving'"' != ""{
			capture confirm new file `saving'.dta
			local error = _rc
			if `error' == 603 {
				display as error "File specified could not be opened."
				exit _rc 
				}
			else if `error' == 7 {
				display as error "Invalid filename specfied."
				exit _rc
				}
			else if `error' == 602 {
				if "`replace'" != "replace" {
					display as error "File exists. Option replace must be specified"
					exit `error'
					}
				}
			display as text "Results will be saved to specified file."
			}
		
	* check the options to use uniform and Pareto densities
	* uniform must be one of none, first (the default), or belowmed
	* pareto must be one of top (the default), toptwo, or abovemed
		if "`uniform'"=="" {
			display as text "A uniform distribution will be used in the first bracket."
			local uniform first
			}	
		if "`pareto'"=="" {
			display as text "A Pareto distribution will be used in the top bracket only"
			local pareto top
			}
		if ("`uniform'"!="first") & ("`uniform'"!="belowmed") ///
			& ("`uniform'"!="none") {
			display as error "Error in Uniform() argument."
			display as error "Valid options are none, first, belowmed."
			exit 
			}
		if ("`pareto'"!="top") & ("`pareto'"!="toptwo") & ("`pareto'"!="abovemed") {
			display as error "Error in Pareto argument."
			display as error "Valid options are top, toptwo, abovemed."
			exit
			}
		
	* preparations
		tempvar bin N
		sort `id' `L'
		by `id': gen byte `bin'=_n
		quietly tab `bin' 
		local top = r(r)
		sort `bin' 
		tempvar dists
		by `bin': gen `dists' = _N
		quietly sum `dists'
		capture assert r(sd)==0
		if _rc {
			display as error "Number of brackets not consistent across ID variable."
			exit 498
			}
		local dists = `dists'[1]
		sort `id' `bin'
		egen double `N' = total(`nb'), by(`id')
		
	*check bin consistency	
		* the bottom of each bin should be higher than previous
		capture assert `L'>`L'[_n-1] if `bin'>1
		if _rc {
			display as error "Bins improperly specified, each should be higher than previous."
			exit 498
			}
		* the bottom of each bin should = top of previous bin
		capture assert `L'==`U'[_n-1] if `bin'>1
		if _rc {
			display as error "Bins improperly specfied, bottom of each should = top of last."
			exit 498
			}
		capture assert `U'==. if `bin'==`top' 
		if _rc {
			display as error "Top bin should always be missing (open-ended)"
			exit 498
			}
	
	********* Ready to begin the MCIB calculations *************
	* STEP ONE: CALCULATE THE SLOPES AND INTERCEPTS FOR CLOSED BINS
	* Calculate the bracket percents and cumulative percent by metro area
	
	quietly {
		* cumulative observations
			tempvar pctnb cumnb cumpctnb belowmed median abovemed
			gen double `pctnb' = `nb'/`N'
			by `id': gen double `cumnb' = sum(`nb')
			gen double `cumpctnb' = 100*`cumnb'/`N'
			gen byte `belowmed' = `cumpctnb'<50
			gen byte `abovemed' = `cumpctnb'[_n-1]>50 & `bin'>1
			gen byte `median' = 1 - `belowmed' - `abovemed'
			
		* encode instructions for bin densities
			tempvar type
			gen str `type' = "linear"
			replace `type' = "uniform" if (`bin'==1)       & ("`uniform'"=="first")
			replace `type' = "uniform" if (`belowmed'==1)  & ("`uniform'"=="belowmed")
			replace `type' = "pareto"  if (`abovemed'==1)  & ("`pareto'"=="abovemed")
			replace `type' = "pareto"  if (`bin'==`top'-1) & ("`pareto'"=="toptwo")
			replace `type' = "pareto"  if (`bin'==`top')
		}

	display
	display "There are `dists' income distributions to be analyzed."
	display
	display "There are `top' income brackets (based on first unit):"
	display
	list `bin' `L' `U' `mid' `type' in 1/`top', clean noobs noheader
	display
	display as text "Step 1: Computing closed bracket density functions."
	display
	
	quietly {
		* Compute relative frequencies, slopes (m) from bracket counts		
			tempvar f m mid slope1 slope2 c
			gen `mid' = (`L'+`U')/2
			format `L' `U' `nb' `mid' %9.0fc
			gen double `f' = `nb'/(`U'-`L')
			gen double `slope1'=.
			gen double `slope2'=.
			sort `id' `bin'
			by `id': replace `slope1' = (`f'-`f'[_n-1])/(`mid'-`mid'[_n-1])
			by `id': replace `slope2' = (`f'[_n+1]-`f')/(`mid'[_n+1]-`mid')
			egen double `m' = rowmean(`slope1' `slope2')
		
		* safeguards to prevent linear density from cutting below zero
			replace `m' = min(`m',(`f'-0)/(`mid'-`L')) 
			replace `m' = max(`m',(0-`f')/(`U'-`mid')) 
		
		* flat line bins that are local maxima or local minima
			replace `f'=0 if `bin'==`top' // just to avoid missing values problem below
			replace `m' = 0 if (`f'>`f'[_n-1]) & (`f'>`f'[_n+1]) & (`bin'>1) & (`bin'<`top')
			replace `m' = 0 if (`f'<`f'[_n-1]) & (`f'<`f'[_n+1]) & (`bin'>1) & (`bin'<`top')
			replace `f'=. if `bin'==`top'
			
		* recode brackets to m = 0, per specified uniform density option
			replace `m' = 0 if `type'=="uniform"
			
		* calculate intercept (c) to force line through rf midpoint
		* f = mx + c --> c = f - mx 	
			gen double `c' = `f' - `m'*`mid' 
			
		}
		
	* STEP 2: CALCULATE TOP BRACKET MEANS AND PARETO PARAMETERS
	* starting here, integratation over the bins to get various quantitites
		display 
		display as text "Step 2: Calculate bracket means, top mean, and alpha"
		quietly {	
			tempvar agy sumagy linmean brktmean topmean alpha 
			
			* integral for aggregate income, use to calculate bracket mean
			* will be missing in top becuase U=. in top bin
			gen double `brktmean' = (1/`nb') * ///
				((`m'*(`U'^3)/3+`c'*(`U'^2)/2) - (`m'*(`L'^3)/3+`c'*(`L'^2)/2))
			gen double `linmean' = `brktmean'
			format `brktmean' `linmean' %12.0fc
			
			* twopoint alpha calculated for each bracket, top uses B-1
			gen double `alpha' = ///
				(ln(`nb'[_n]+`nb'[_n+1])-ln(`nb'[_n+1])) ///
				/ (ln(`L'[_n+1])-ln(`L'[_n])) if (`abovemed'==1) & (`bin'<`top')
			replace `alpha' = `alpha'[_n-1] if `bin'==`top'
			replace `alpha' = max(`alpha', `minalpha') 
			
			* bracket means for Pareto Brackets (except top)
			replace `brktmean' = ///
				(`alpha'*(`U'^(1-`alpha')-`L'^(1-`alpha'))) /// 
				/ ((`alpha'-1)*(`U'^(-`alpha')-`L'^(-`alpha'))) ///
				if (`type'=="pareto") & (`bin'<`top')
			
			* aggregate income per bracket (will be missing in top)
			gen double `agy' = `nb'*`brktmean' 
						
			* calculate top bracket mean/alpha by selected method
			if "`twopoint'"=="twopoint" {
				noisily display as text "Using Two Point Alpha for Top Bracket"
				replace `brktmean' = `L'*(`alpha')/(`alpha'-1) if `bin'==`top'
				replace `agy' = `brktmean'*`nb' if `bin'==`top'
				egen `sumagy' = total(`agy'), by(`id')
				tempvar G
				gen double `G' = `sumagy'/`N'
				}
			else {
				* mean-constrained alpha
				noisily display as text "Using mean provided by user, `G'"
				egen `sumagy' = total(`agy'), by(`id')  // below top only
				replace `brktmean' = (`G'*`N'-`sumagy')/`nb' if `bin'==`top'
				replace `agy' = `brktmean'*`nb' if `bin'==`top'
				drop `sumagy'
				egen `sumagy' = total(`agy'), by(`id') // includes all
				* calculate mean-constrained value for alpha from top bracket mean
				replace `alpha' = `brktmean'/(`brktmean'-`L') if `bin'==`top'
				replace `alpha' = max(`alpha', `minalpha') if `bin'==`top'
				}
			
			* Nudge alpha away from being exactly 1 or 2
			* Otherwise certain integrals below are undefined
			replace `alpha' = 2.01 if (`alpha'>1.99) & (`alpha'<2.01)
			gen `topmean'=`brktmean' if `bin'==`top'
			}
			
	* STEP 3a: Calculate variance	
	* integral for bracket squared deviations (SSD)
	* affects lower bins only since m==. in top bin
	display 
	display as text "Step 3a: Compute integrals for the Variance"
	quietly {
		tempvar var parprob
		* integral for variance component in lower brackets
		gen double `var' =  (1/`N') *  ( ///
			(`m'*`U'^4/4 + ///
			(`c'-2*`G'*`m')*`U'^3/3 + ///
			(`G'^2*`m'-2*`G'*`c')*`U'^2/2 + ///
			`G'^2*`c'*`U') ///
			- ///
			(`m'*`L'^4/4 + ///
			(`c'-2*`G'*`m')*`L'^3/3 + ///
			(`G'^2*`m'-2*`G'*`c')*`L'^2/2 + ///
			`G'^2*`c'*`L') ///
			)
		
		* Use integral of Pareto to estimate variance component 
		* need to set the arbitrary upper limit for the top bracket integral
		* use cutoff to incoroporate 99.5% of Pareto density
		replace `U' = exp(ln(`L')-ln(1-0.995)/`alpha') if `bin'==`top'
		gen double `parprob' = 1-`L'^`alpha'/`U'^`alpha' if `type'=="pareto"
		* list `L' `U' `parprob' in 1/`top', noobs clean noheader
		replace `var' = (`nb'/`N')*`alpha'*(`L'^`alpha') * ///
			( ///
				( 	(`U'^(2-`alpha'))/(2-`alpha') - ///
					(2*`G'*`U'^(1-`alpha'))/(1-`alpha') + ///
					(`G'^2*`U'^(-`alpha'))/(-`alpha') ///
				) ///
			- ///
				( 	(`L'^(2-`alpha'))/(2-`alpha') ///
					-(2*`G'*`L'^(1-`alpha'))/(1-`alpha') ///
					+(`G'^2*`L'^(-`alpha'))/(-`alpha') ///
				) ///
			) /`parprob' if `type'=="pareto"
		}
	
	* STEP 3b: Calculate Theil Index	
	display as text "Step 3b: Compute integrals for the Theil Statistic."
	quietly {
		tempvar theil
		* Theil can't log 0 in the first bracket
		replace `L' = 1 if `L'==0
		gen double `theil' =  1/(`G'*`N') * ( ///
			((`m'*`U'^3/3+`c'*`U'^2/2)*ln(`U'/`G') - `m'*`U'^3/9 - `c'*`U'^2/4) ///
			- ///
			((`m'*`L'^3/3+`c'*`L'^2/2)*ln(`L'/`G') - `m'*`L'^3/9 - `c'*`L'^2/4) ///
			 /// 
			)
		* leave things as you found them
		replace `L' = 0 if `L'==1
		
		* pareto brackets, makes use of U top computed above
		replace `theil' = -(`alpha'*`L'^`alpha'*`nb')/((`alpha'-1)^2*`G'*`N') * ( ///
			((`alpha'-1)*ln(`U'/`G')+1)/`U'^(`alpha'-1) ///
			- ///
			((`alpha'-1)*ln(`L'/`G')+1)/`L'^(`alpha'-1) ///
			) / `parprob' if `type'=="pareto"		
		}
	
	* STEP 3c: Compute Gini Coefficient from the Lorenz curve
	* save results from above, break up brackets into parts (5 or user specified)
	display as text "Step 3c: Compute Gini Coefficient from the Lorenz Curve"
	display as text "using `parts' parts per bracket"
	display
	quietly {
		tempfile hold
		save `hold'
		tempvar part Lbin seg prob cumprob 
		gen `Lbin' = `L' if `type'=="pareto"
		replace `U'=. if `bin'==`top'
		replace `parprob' = 1 if `bin'==`top'
		gen `part' = (`U'-`L')/`parts'
		expand `parts'
		sort `id' `bin'
		by `id' `bin': gen `seg' = _n
		* lower bins are divided into `parts' equal-width segments
			replace `L' = `L'+(`seg'-1)*`part' if `bin'<`top'
			replace `U' = `L'+ `part' if `bin'<`top'
		* top bin is divided into five equal probability segments based on Pareto
			gen double `prob' = 1/`parts' if `bin'==`top'
			by `id': gen double `cumprob' = sum(`prob')
			replace `U' = exp((ln(`Lbin')-ln(1-`cumprob')/`alpha')) if `bin'==`top'
			replace `L' = `U'[_n-1] if (`bin'==`top') & (`seg'>1)
		* recalculate households and income for new lower/upper limits
			tempvar nbx agyx 
			gen double `nbx' = (`m'*`U'^2/2+`c'*`U')-(`m'*`L'^2/2+`c'*`L') 
			gen double `agyx' = (`m'*`U'^3/3+`c'*`U'^2/2)-(`m'*`L'^3/3+`c'*`L'^2/2)
			replace `brktmean' = `agyx'/`nbx'
			replace    `nbx' = `nb'*(-`Lbin'^`alpha') * ///
				(1/(`U'^`alpha')-1/(`L'^`alpha')) / `parprob' if `type'=="pareto"
			replace    `nbx' = `nb'/`parts' if `bin'==`top'
			replace `brktmean' = (`alpha'*(`U'^(1-`alpha')-`L'^(1-`alpha'))) ///
				/ ((`alpha'-1)*(`U'^(-`alpha')-`L'^(-`alpha'))) if `type'=="pareto"
			replace `brktmean' = `L'*`alpha'/(`alpha'-1) if (`bin'==`top') & (`seg'==`parts')
			replace `agyx' = `brktmean'*`nbx' if `type'=="pareto"
			* list `bin' `seg' `L' `U' `mid' `nb' `nbx' `brktmean' ///
				in 1/80, noobs noheader sepby(`bin')
		* create Lorenz curve variables
			* cumulative x axis
				tempvar pctnbx cumnbx cumpctnbx
				gen double `pctnbx' = `nbx'/`N'
				by `id': gen double `cumnbx' = sum(`nbx')
				gen double `cumpctnbx' = `cumnbx'/`N'
			* cumulative y axis
				tempvar pctagyx cumagyx cumpctagyx
				by `id': gen double `cumagyx' = sum(`agyx') if _n<_N
				by `id': replace `agyx' = `sumagy'-`cumagyx'[_N-1] if _n==_N
				by `id': replace `cumagyx' = `agyx'+`cumagyx'[_N-1] if _n==_N
				gen double `pctagyx' = `agyx'/`sumagy'
				gen double `cumpctagyx' = `cumagyx'/`sumagy'
		
		* create dummy bin zero so calculations of Lorenz area 
		* start at the origin (Bronfenbrenner 1971)
		sort `id' `bin'
		expand 2 if `L' ==0
		sort `id' `bin' `L'
		by `id': replace `bin' = 0 if _n==1
		by `id': replace `pctnbx' = 0 if _n==1
		by `id': replace `pctagyx' = 0 if _n==1
		by `id': replace `cumpctagyx' = 0 if _n==1
		
		* geometry: calculate area of triangles and rectangles under Lorenz curve
		tempvar lorenz
		sort `id' `bin' `lower'
		by `id': gen double `lorenz' = `cumpctagyx'[_n-1]*`pctnbx' + `pctnbx'*`pctagyx'/2

		* add the Gini components from the parts back to bracket level
		collapse (sum) `lorenz', by(`id' `bin')
		* drop dummmy 0th bracket 
		drop if `bin'==0

		* bring back the previous results (one obs per bracket)
		merge 1:1 `id' `bin' using `hold'
		drop _merge
	}

	* Step 4: Calculate percentiles
		display "Calculating percentiles of the distribution(s)."
		quietly {
			* quadratic equation coefficients
			* Ay^2 + By + C = Q
				tempvar A B C r1 r2 Q 
				gen `A' = `m'/(2*`N')
				gen `B' = `c'/`N'
				gen `C' = -(`m'*`L'^2/(2*`N') + `c'*`L'/`N')
			* set up variables to be used below
				gen `Q'=.
				gen `r1'=.
				gen `r2'=.
			* now calculate the percentiles
			foreach p in 5 10 20 25 30 40 50 60 70 75 80 90 95 {
				tempvar b`p' p`p'
				* mark the bins containing the percentiles
					gen `b`p'' = `bin' * (((`cumpctnb'[_n-1]<=`p')|(`bin'==1)) & (`cumpctnb'>`p')) 
				* calculate probability into the bin where the ptile is located
				* Q is prob needed above L, below U to get ptile
					replace `Q'  = (`p'/100) 					if (`bin'==1) & (`b`p'')
					replace `Q'  = (`p'-`cumpctnb'[_n-1])/100 	if (`bin'>1) & (`b`p'')
				* Linear brackets; solve quadratic equation for the two quadratic roots
				* solve Ay^2 + By + (C-Q)=0 for y  
					gen `p`p''=.
					replace `r1' = (-(`B')+sqrt((`B')^2-4*(`A')*(`C'-`Q')))/(2*(`A')) if `b`p''
					replace `r2' = (-(`B')-sqrt((`B')^2-4*(`A')*(`C'-`Q')))/(2*(`A')) if `b`p''
				* it's always the root with +sqrt(), but I don't know why, so I test both
					replace `p`p'' = `r1' if (`r1'>=`L') & (`r1'<`U') & (`b`p'')
					replace `p`p'' = `r2' if (`r2'>=`L') & (`r2'<`U') & (`b`p'')
				* Uniform bracket: replace with uniform linear version if uniform distribution (slope==0)
					replace `p`p'' = `N'*`Q'/`c' + `L' if (`m'==0) & (`b`p'')
				* Pareto bracket: replace with Pareto version if Pareto bracket
					replace `p`p'' = exp(ln(`L')-ln(1-`Q'/(`nb'/(`N'*`parprob')))/`alpha') if (`b`p'') & (`type'=="pareto")
				* fill in the missing values in other bins with percentile values
					tempvar i`p' 
					egen `i`p'' = total(`b`p''), by(`id')
					by `id': replace `p`p''=`p`p''[`i`p'']
				}
			* list `cumpctnb' `L' `U' `p5' `p20' `p40' `p60' `p80' `p95' `type' in 1/`top', clean noobs noheader
			}
	
	* Cumulative Income Shares by Quintiles
	* recalculates aggregate income up to quintile limits
	* after aggregation, shares are computed at `id' level
	display "Computing shares of income by quintiles."
	quietly {
		foreach Q of numlist 20 40 60 80 {
			local q = `Q'/20
			tempvar LQ UQ q`q'y
			gen `LQ'=min(`L', `p`Q'')
			gen `UQ'=min(`U', `p`Q'')
			gen double `q`q'y' = (`m'*`UQ'^3/3+`c'*`UQ'^2/2) ///
				- (`m'*`LQ'^3/3+`c'*`LQ'^2/2) 
			replace `q`q'y' = `nb' * (`alpha'*`LQ'^`alpha'*(1/(1-`alpha'))) * ///
				(`UQ'^(1-`alpha')-`LQ'^(1-`alpha')) /`parprob'  if `type'=="pareto"
			* list `bin' `LQ' `UQ' `p`Q'' `q`q'y' `agy' `type' in 1/`top'
			}
		}
			
	* Finish: aggregate to id level
		display
		display "Finishing up"
		
		* keep only top bracket alpha
		replace `alpha' = . if `bin'<`top'
		
		quietly {
			collapse 	(mean) 	topmean = `topmean' alpha = `alpha' mean=`G' ///
								p5=`p5' p10=`p10' p20=`p20' p25=`p25' p30=`p30' ///
								p40=`p40' p50=`p50' p60=`p60' p70=`p70' ///
								p75=`p75' p80=`p80' p90=`p90' p95=`p95' ///
						(sum) 	var = `var' theil = `theil' N=`nb' `lorenz' ///
								q1y=`q1y' q2y=`q2y' q3y=`q3y' q4y=`q4y'  ///
				, by(`id')
			
			* If no ID variable, create a pseudo ID
			if "`by'"=="" {
				gen ID = `id'
				local id ID
				}
			
			* Gini is 1 - 2 times the area under the Lorenz curve
			gen gini = 1-2*(`lorenz')
			drop `lorenz'
			
			* variance based measures
			gen sd = sqrt(var)
			gen cov = sd/mean
			gen iqr = p75-p25
			gen rat9010 = p90/p10
			
			* shares
			gen shrq1 = 100*q1y/(mean*N)
			gen shrq2 = 100*(q2y-q1y)/(mean*N)
			gen shrq3 = 100*(q3y-q2y)/(mean*N)
			gen shrq4 = 100*(q4y-q3y)/(mean*N)
			gen shrq5 = 100*(1-q4y/(mean*N))
			drop q?y
			
			format N mean sd p? p?? %12.0fc
			format alpha theil cov gini rat9010 shr* %7.3f
			format var %9.3e
			order `id' N mean var sd cov theil alpha topmean
			if "`by'"=="" rename `id' ID
			
			if "`twopoint'"=="twopoint" {
				label var alpha "Two Point Alpha"
				label var mean  "Mean (estimated)"
				}
			else {
				label var alpha "Mean-constrained Alpha"
				label var mean  "User-provided (`G')"
				}
			label var N "Total count (`nb')"
			label var topmean "Top Bracket Mean"
			label var gini "Gini Coefficient"
			label var theil "Theil Index"
			label var var "Variance"
			label var sd "Standard Deviation" 
			label var cov "Coefficient of Variation"
			label var iqr "InterQuartile Ratio"
			label var rat9010 "90/10 p'tile ratio "
			foreach n in 5 10 20 25 30 40 50 60 70 75 80 90 95 {
				label var p`n' "`n'th Percentile"
				}
			foreach n in 1 2 3 4 5 {
				label var shrq`n' "Income Share of Quintile `n'"
				}
			}
			
		* list output on screen if requested or if not being saved in memory or file
		if ("`list'"=="list") | (("`saving'"=="")&("`keep'"=="")) {
			display 
			display "Basic Descriptives"
			list `id' N mean var sd , clean noobs
			display 
			display "Important Percentiles"
			list `id' p5 p25 p50 p75 p95, clean noobs
			display 
			display "Deciles"
			list `id' p10 p20 p30 p40 p60 p70 p80 p90, clean noobs
			display
			display "Inequality Measures"
			list `id' cov gini theil rat9010 iqr, clean noobs
			display
			display "Income shares by quintiles"
			list `id' shrq1 shrq2 shrq3 shrq4 shrq5, clean noobs
			}
		
		* save file if requested
		if `"`saving'"' != "" save `saving', `replace'
		
		* do not restore the original data if keep was specified
		if "`keep'"=="keep" restore, not
	
	display
	display "***** End of MCIB *****"
	display
	* END OF MCIB
	end

	
