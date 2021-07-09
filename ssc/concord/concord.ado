*! 3.0.7  9aug2007  TJS & NJC fixed Stata 10 bug by adding missing -version- 
*  3.0.6 14may2006  TJS & NJC fixed Stata 9 bug with -by()- 
// 3.0.5 22aug2005  Stata 8 - fixed legend(off)
// 3.0.4 27jan2005  TJS & NJC rewrite for Stata 8 + more for graphs
// 3.0.3  6oct2004  TJS & NJC rewrite for Stata 8
// 3.0.2  6oct2004  TJS & NJC rewrite for Stata 8
// 3.0.1  4oct2004  TJS & NJC rewrite for Stata 8 + fixes + noref
// 3.0.0 27jul2004  TJS & NJC rewrite for Stata 8
// 3.0.0 19jul2004  TJS & NJC rewrite for Stata 8
// 2.2.9 14jan2003  TJS & NJC handling of [ ] within connect()
// 2.2.8  2jan2003  TJS & NJC handling of [ ] within symbol()
// 2.2.7 30jan2002  TJS & NJC rho_se corrected  (SJ2-2: st0015)
// 2.2.6 10dec2001  TJS & NJC bug fixes (labels, diag line)
// 2.2.5 23apr2001  TJS & NJC sortpreserve
// 2.2.4 24jan2001  TJS & NJC l1title for loa
// 2.2.3  8sep2000  TJS & NJC bug fixes & mods  (STB-58: sg84.3)
// 2.2.0 16dec1999  TJS & NJC version 6 changes (STB-54: sg84.2)
// 2.1.6 18jun1998  TJS & NJC STB-45 sg84.1
// 2.0.2  6mar1998  TJS & NJC STB-43 sg84
//
// syntax:	concord vary varx [fw] [if] [in] [,
//			BY(varname) Summary LEvel(real `c(level)')
//			CCC(str) LOA(str) QNORMD(str) ]

program concord, rclass sortpreserve
// Syntax help
	if "`1'" == "" {
		di "{p}{txt}Syntax is: {inp:concord} "						///
		"{it:vary varx} [{it:weight}] "								///
		"[{inp:if} {it:exp}] [{inp:in} {it:range}] "				///
		"[, {inp:by(}{it:byvar}{inp:)} "							///
		"{inp:summary level(}{it:#}{inp:)} "						///
		"{inp:ccc}[{inp:(noref} {it:ccc_options}{inp:)}] "			///
		"{inp:loa}[{inp:(noref regline} {it:loa_options}{inp:)}] "	///
		"{inp:qnormd}[{inp:(}{it:qnormd_options}{inp:)}] {p_end}"
		exit 0
	}

// Setup
	version 8 
	syntax varlist(numeric min=2 max=2)	///
	[fw]								///
	[if] [in]							///
	[ , BY(varname)						///
	Summary								///
	LEvel(real `c(level)')				///
	ccc(str asis)						///
	CCC2								///
	loa(str asis)						///
	LOA2								///
	qnormd(str asis)					///
	QNORMD2 * ]

	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000

	tokenize `varlist'

// Set temporary names
	tempvar d d2 db dll dul m byg kk bylabel
	tempname dsd zv k xb yb sx2 sy2 r rp sxy p u sep z zp
	tempname t set ll ul llt ult rdm Fdm zt ztp sd1 sd2 sl

// Set up wgt
	if "`weight'" != "" local wgt "[`weight'`exp']"

// Generate CI z-value and label from Level()
	if `level' < 1 local level = `level' * 100
	scalar `zv' = -1 * invnorm((1 - `level' / 100) / 2)
	local rl = `level'
	local level : di %7.0g `level'
	local level = ltrim("`level'")

// Generate BY groups
	qui {
		bysort `touse' `by' : gen byte `byg' = _n == 1 if `touse'
		if "`by'" != "" gen `kk' = _n if `byg' == 1
		replace `byg' = sum(`byg')
		local byn = `byg'[_N]

// Generate `by' labels -- if required
		if "`by'" != "" {
			capture decode `by', gen(`bylabel')
			if _rc != 0 {
				local type : type `by'
				gen `type' `bylabel' = `by'
			}
		}
	}

// Print title
	di
	di as txt "Concordance correlation coefficient (Lin, 1989, 2000):"

// Do calculations
	forval j = 1/`byn' {  /* start of loop for each `by' group */
		di
		if "`by'" != "" {
			sort `kk'
			di as txt "{hline}"
			di as txt "-> `by' = " `bylabel'[`j'] _n
			local byl : di "`by' = " `bylabel'[`j']
		}

// LOA (Bland & Altman) calculations
		qui {
			gen `d' = `1' - `2'
			gen `d2' = `d'^2
			su `d' if `byg' == `j' `wgt'
			gen `db' = r(mean)
			scalar `dsd' = r(sd)
			gen `dll' = `db' - `zv' * `dsd'
			gen `dul' = `db' + `zv' * `dsd'
			gen `m' = (`1' + `2') / 2
		}

// Concordance calculations
		qui su `1' if `byg' == `j' `wgt'
		scalar `k'   = r(N)
		scalar `yb'  = r(mean)
		scalar `sy2' = r(Var) * (`k' - 1) / `k'
		scalar `sd1' = r(sd)

		qui su `2' if `byg' == `j' `wgt'
		scalar `xb'  = r(mean)
		scalar `sx2' = r(Var) * (`k' - 1) / `k'
		scalar `sd2' = r(sd)

		qui corr `1' `2' if `byg' == `j' `wgt'
		scalar `r'  = r(rho)
		scalar `sl' = sign(`r') * `sd1' / `sd2'

		scalar `rp'  = min(tprob(r(N) - 2, r(rho) * sqrt(r(N) -  2) ///
		               / sqrt(1 - r(rho)^2)) ,1)
		scalar `sxy' = `r' * sqrt(`sx2' * `sy2')
		scalar `p'   = 2 * `sxy' / (`sx2' + `sy2' + (`yb' - `xb')^2)
		scalar `u'   = (`yb' - `xb') / (`sx2' * `sy2')^.25

// --- variance, test, and CI for asymptotic normal approximation
		//   scalar `sep' = sqrt(((1 - ((`r')^2)) * (`p')^2 * (1 -
		//     ((`p')^2)) / (`r')^2 + (4 * (`p')^3 * (1 - `p') * (`u')^2
		//     / `r') - 2 * (`p')^4 * (`u')^4 / (`r')^2 ) / (`k' - 2))
// Corrected se: per Lin (March 2000) Biometrics 56:325-5.
		#delimit ;
		scalar `sep' = sqrt(((1 - ((`r')^2)) * (`p')^2 * (1 -
		  ((`p')^2)) / (`r')^2 + (2 * (`p')^3 * (1 - `p') * (`u')^2
		  / `r') - .5 * (`p')^4 * (`u')^4 / (`r')^2 ) / (`k' - 2));
		#delimit cr
		scalar `z'  = `p' / `sep'
		scalar `zp' = 2 * (1 - normprob(abs(`z')))
		scalar `ll' = `p' - `zv' * `sep'
		scalar `ul' = `p' + `zv' * `sep'

// --- statistic, variance, test, and CI for inverse hyperbolic
//      tangent transform to improve asymptotic normality
		scalar `t'   = ln((1 + `p') / (1 - `p')) / 2
		scalar `set' = `sep' / (1 - ((`p')^2))
		scalar `zt'  = `t' / `set'
		scalar `ztp' = 2 * (1 - normprob(abs(`zt')))
		scalar `llt' = `t' - `zv' * `set'
		scalar `ult' = `t' + `zv' * `set'
		scalar `llt' = (exp(2 * `llt') - 1) / (exp(2 * `llt') + 1)
		scalar `ult' = (exp(2 * `ult') - 1) / (exp(2 * `ult') + 1)

// Print output
		di as txt " rho_c   SE(rho_c)   Obs    [" _c
		if index("`level'",".") {
			di as txt %6.1f `level' "% CI  ]     P        CI type"
		}
		else di as txt "   `level'% CI   ]     P        CI type"

		di as txt "{hline 63}"
		di as res %6.3f `p' %10.3f `sep' %8.0f `k' %10.3f `ll' _c
		di as res %7.3f `ul' %9.3f `zp' as txt "   asymptotic"
		di as res _dup(24) " " %10.3f `llt' %7.3f `ult' %9.3f `ztp' _c
		di as txt "  z-transform"

		di _n as txt "Pearson's r =" as res %7.3f `r' _c
		di    as txt "  Pr(r = 0) =" as res %6.3f `rp' _c
		di    as txt "  C_b = rho_c/r =" as res %7.3f `p' / `r'
		di    as txt "Reduced major axis:   Slope = " as res %9.3f `sl' _c
		di    as txt "   Intercept = " as res %9.3f `yb'-`xb'*`sl'
		di _n as txt "Difference = `1' - `2'"
		di _n as txt "        Difference" _c
		if index("`level'", ".") {
		     di _col(33) as txt %6.1f `level' "% Limits Of Agreement"
		}
		else di _col(33) as txt     "   `level'% Limits Of Agreement"
		di as txt "   Average     Std Dev.             (Bland & Altman, 1986)"
		di as txt "{hline 63}"
		di as res %10.3f `db' %12.3f `dsd' _c
		di as res "            " %11.3f `dll' %11.3f `dul'

		qui corr `d' `m' if `byg' == `j' `wgt'
		scalar `rdm' = r(rho)
		di _n as txt "Correlation between difference and mean =" _c
		local fmt = cond(r(rho) < 0, "%7.3f", "%6.3f")
		di as res `fmt' r(rho)

		su `d2' if `byg' == `j' `wgt', meanonly
		local sumd2 = r(sum)
		qui reg `d' `m' if `byg' == `j' `wgt'
		scalar `Fdm' = ((`sumd2' - e(rss)) / 2) / (e(rss) / e(df_r))
		di _n as txt "Bradley-Blackwood F = " ///
		      as res %4.3f `Fdm' ///
		      as txt " (P = " %6.5f ///
		      as res 1 - F(2, e(df_r), `Fdm') ///
		      as txt ")"

		if "`summary'" != "" su `1' `2' if `byg' == `j' `wgt'

// setup local options for passing to graph routines
		if "`byl'"   != "" local byls byl("`byl'")
		if "`level'" != "" local levs level(`level')

// set more if needed		
		if (`"`loa'`loa2'"' != "" & `"`qnormd'`qnormd2'"' != "") |    ///
		   (`"`loa'`loa2'"' != "" & `"`ccc'`ccc2'"'       != "") |    ///
		   (`"`ccc'`ccc2'"' != "" & `"`qnormd'`qnormd2'"' != "")   {
		   
		   local moreflag "more"
		}
		    
// loa graph
		if `"`loa'`loa2'"' != "" {
			gphloa `2' `1' `dll' `db' `dul' `d' `m' `byg' ///
			`wgt', j(`j') byn(`byn') `byls' `levs' `loa' `options'
			
            `moreflag'
		}

// qnormd graph
		if `"`qnormd'`qnormd2'"' != "" {
			gphqnormd `2' `1' `d' `byg' ///
			`wgt', j(`j') byn(`byn') `byls' `levs' `qnormd' `options'
			
            `moreflag'
		}

// ccc graph
		if `"`ccc'`ccc2'"' != "" {
			local sll = `sl'
			local xbl = `xb'
			local ybl = `yb'
			gphccc `1' `2' `byg' `wgt', j(`j') ///
			xb(`xbl') yb(`ybl') sl(`sll') byn(`byn') `byls' `ccc' `options'
		}

		if `byn' > 1 {
			capture drop `d' 
			capture drop `d2' 
			capture drop `db' 
			capture drop `dll' 
			capture drop `dul'
			capture drop `m'
		}	

	} /* end of loop for each `by' group */

// save globals
	if `byn' == 1 {
		return scalar        N = `k'
		return scalar    rho_c = `p'
		return scalar se_rho_c = `sep'
		return scalar  asym_ll = `ll'
		return scalar  asym_ul = `ul'
		return scalar  z_tr_ll = `llt'
		return scalar  z_tr_ul = `ult'
		return scalar      C_b = `p' / `r'
		return scalar     diff = `db'
		return scalar  sd_diff = `dsd'
		return scalar   LOA_ll = `dll'
		return scalar   LOA_ul = `dul'
		return scalar      rdm = `rdm'
		return scalar      Fdm = `Fdm'

// double save globals
// now undocumented as of 3.0.0
		global S_1  = `k'
		global S_2  = `p'
		global S_3  = `sep'
		global S_4  = `ll'
		global S_5  = `ul'
		global S_6  = `llt'
		global S_7  = `ult'
		global S_8  = `p' / `r'
		global S_9  = `db'
		global S_10 = `dsd'
		global S_11 = `dll'
		global S_12 = `dul'
	}
end

program gphloa
// loa graph
	version 8
	syntax varlist(numeric min=2) [fw]								///
	[ , J(int 1) BYN(int 1) BYL(str) REGline LEvel(real `c(level)')	///
	plot(str asis) noREF * ]

	tokenize `varlist'
	args two one dll db dul d m byg
	if "`weight'" != "" local wgt "[`weight'`exp']"

	if `"`byl'"' != "" local t2title `"t2title(`byl')"'

	local name2 : variable label `2'
	local name1 : variable label `1'
	local lnth = length(`"`name2'"') + length(`"`name1'"')
	if `"`name2'"' == `""' | `lnth' > 50 local name2 "`2'"
	if `"`name1'"' == `""' | `lnth' > 50 local name1 "`1'"

	qui if "`regline'" != "" {
		tempvar fit
		regress `d' `m' if `byg' == `j' `wgt'
		predict `fit'
	}

	if "`ref'" == "" {
	   local ord 2 3
	   if "`regline'" != "" local ord 2 3 4
	   local zero yli(0, lstyle(refline)) yscale(range(0)) ylabel(0, add)	///
	   legend(on order(`ord') label(2 observed average agreement)			///
	   label(3 `"`level'% limits of agreement"') label(4 regression line))	///
	   caption("y=0 is line of perfect average agreement")
	}
    	
	graph twoway line `dll' `db' `dul' `fit' `m' if `byg' == `j',		///
		clcolor(red purple red green) sort								///
		|| scatter `d' `m' if `byg' == `j'								///
		, ms(oh) `t2title'												///
		yti(`"Difference of `name2' and `name1'"')						///
		xti(`"Mean of `name2' and `name1'"')							///
		caption("`level'% Limits Of Agreement") legend(off) `zero'      ///
		`options' ///
	|| `plot'

	if `byn' > 1 more
end

program gphqnormd, sort
// normal prob plot
// note: logic pilfered from qnorm
	version 8
	syntax varlist(numeric min=2) [fw]							///
	[ , J(int 1) BYN(int 1) BYL(str) LEvel(real `c(level)')		///
	plot(str asis) * ]

	args two one d byg
	if "`weight'" != "" local wgt "[`weight'`exp']"
	else local exp 1

	local name2 : variable label `2'
	local name1 : variable label `1'
	local lnth = length(`"`name2'"') + length(`"`name1'"')
	if `"`name2'"' == `""' | `lnth' > 50 local name2 "`2'"
	if `"`name1'"' == `""' | `lnth' > 50 local name1 "`1'"

	tempvar Z Psubi touse2
	mark `touse2' if `byg' == `j'
	qui {
		gsort -`touse2' `d'
		gen `Psubi' = sum(`touse2' * `exp')
		replace `Psubi' = cond(`touse2' == 0, ., `Psubi'/(`Psubi'[_N] + 1))
		su `d' if `touse2' == 1 `wgt'
		gen float `Z' = invnorm(`Psubi') * r(sd) + r(mean)
		label var `Z' "Inverse Normal"
		local xttl : var label `Z'
		local yttl `"Difference of `name2' and `name1'"'
	}

	if `"`byl'"' != "" local t2title `"t2title(`byl')"'

	graph twoway						///
		(scatter `d' `Z',				///
			sort						///
			ytitle(`"`yttl'"')			///
			xtitle(`"`xttl'"')			///
			`t2title'					///
			`options'					///
		)								///
		(function y=x,					///
			range(`Z')					///
			n(2)						///
			clstyle(refline)			///
			yvarlabel("Reference")		///
			yvarformat(`fmt')			///
		)								///
		, legend(off)					///
	|| `plot'

	if `byn' > 1 more
end

program gphccc
	version 8
//-----------------------------------------------------
// ccc graph
// ----------------------------------------------------
	syntax varlist(numeric min=2) [fw] [ , J(int 1) XB(real 0) noREF ///
	YB(real 0) SL(real 0) BYN(int 1) BYL(str) plot(str asis) LEGEND(str) * ]

	tokenize `varlist'
	tempvar byg rmaxis
	local byg `3'
	if "`weight'" != "" local wgt "[`weight'`exp']"

	local yttl : variable label `1'
	if `"`yttl'"' == "" local yttl "`1'"
	local xttl : variable label `2'
	if `"`xttl'"' == "" local xttl "`2'"

    if "`ref'" == "" local lopc || function y = x, ra(`2') clstyle(refline) ///
      legend(on order(2 "reduced major axis" 3 "line of perfect concordance"))

    if "`legend'" != "" {
      local legnd "legend(`legend')"
    }
          
// Graph concordance plot
	qui gen `rmaxis' = `sl' * (`2' - `xb') + `yb'

	graph twoway scatter `1' `rmaxis' `2'						///
		if `byg' == `j' `wgt',									///
		sort connect(none line) ms(oh none)						///
		yti(`"`yttl'"') xti(`"`xttl'"') legend(off) `lopc'      ///
		`options'	///
	|| `plot'

	if `byn' > 1 more
end

