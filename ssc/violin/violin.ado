*! version 1.4.1  TJS  31jan01  touched for version 7.0
program define violin, rclass
version 6
*  version 1.4.0  TJS  13jun00
*  version 1.3.0  TJS   3nov99
*  version 1.2.4  TJS  31aug98
*! syntax: violin varlist [fw aw] [if] [in] [, N(#) Width(#) TRUncat(str)
*!         BIweight COSine EPan GAUss RECtangle PARzen TRIangle
*!         BY(varname) Gap(#) ROund(#) SAving(str) graph_options]
	syntax varlist(numeric min=1) [fw aw] [if] [in]                    /*
		*/ [ , N(int 50) Width(real 0.0) TRUncat(str) B2title(str) /*
		*/   BIweight COSine EPan GAUss RECtangle PARzen TRIangle  /*
		*/   BY(varname) Gap(integer 0) ROund(real 0.0) SAving(str) * ]
	marksample use
	tokenize `varlist'
* v7 fix
	global caller = _caller() 

* trap bad options
	if index("`options'","tr") > 0 {
		di in re "tr ambiguous abbreviation, " _c
		error 111
	}
	if index("`options'","sc") > 0 {
		di in re "scale is not a valid option, " _c
		error 198
	}
	if "`b2title'" != "" {
		di in bl "b2title not allowed; option ignored."
	}

* -> Kernel Density code stolen from kdensity.ado
	local kflag = ( ("`epan'"  != "")   + ("`biweigh'" != "") + /*
		     */ ("`triangl'" != "") + ("`gauss'"   != "") + /*
		     */ ("`rectang'" != "") + ("`parzen'"  != "") )
	if `kflag' > 1 {
		di in red "specify only one kernel, " _c
		error 198
	}

	if "`biweigh'"       != "" { local kernel = "Biweight"     }
	else if "`cosine'"   != "" { local kernel = "Cosine"       }
	else if "`triangl'"  != "" { local kernel = "Triangle"     }
	else if "`gauss'"    != "" { local kernel = "Gaussian"     }
	else if "`rectang'"  != "" { local kernel = "Rectangular"  }
	else if "`parzen'"   != "" { local kernel = "Parzen"       }
	else                       { local kernel = "Epanechnikov" }

	qui count if `use'
	if r(N) == 0 { error 2000 }                        /* count */

	cap if "`if'" != "" {ifexp "`if'"}   /* display expanded if */
	if _rc == 0 & "`if'" != "" { di in bl _n "$S_1" }

	preserve                       /* Note: data preserved here */

*	keep `by' `varlist' `use'  <-- note: next 2 lines fix missing weight var
	if "`exp'" != "" { local wtvar = substr("`exp'",2,.) }
	keep `by' `varlist' `use' `wtvar'
	local n1 = `n' + 1
	local n2 = `n' * 2 + 1
	if `n2' > _N { qui set obs `n2' }

* Generate BY groups
	tempvar kk byg bylabel
	sort `use' `by'
	qui by `use' `by': gen byte `byg' = _n == 1 if `use'
	if "`by'" != "" { qui gen `kk' = _n if `byg' == 1 }
	qui replace `byg' = sum(`byg')

	if "`by'" != "" {
		local byn = `byg'[_N]
		sort `kk'
		if `use'[`byn'] == . { local byn = `byn' - 1}
	}
	else { local byn = 1 }

* Generate `by' labels -- if required
	if "`by'" != "" {
		capture decode `by', gen(`bylabel')
		if _rc != 0 {
			local type : type `by'
			qui gen `type' `bylabel' = `by'
		}
	}

	tempname t2flg b1flg A S
	global t2flg = 0
	global b1flg = 0

* Do calculations

* get # of vars
	local nvars : word count `varlist'
	if `nvars' > 1 & "`by'" != "" {
		di in red "multi-variable varlist: " _c
		error 190
	}

* Note: `k' loops over multiple individual variables
*       `j' loops over the levels of a -by- variable

	local k 1
 while "``k''" != "" {
	local ix "``k''"
	local ixl: variable label ``k''
	if "`ixl'" == "" | `nvars' > 1 { local ixl "``k''" }

	local j = 1
 while `j' <= `byn' {  /* start of loop for each `by' group */
	if "`by'" != "" {
		sort `kk'
		local byl : di "`by': " `bylabel'[`j']
		local bl = "`bylabel'[`j']"
	}

* boxplot stats
	qui centile `ix' if `use' & `byg' == `j', c(25 50 75)
	local q25 = r(c_1)
	local q50 = r(c_2)
	local q75 = r(c_3)
* compute additional boxplot info
* v7 fixs
*	tempvar xi
	local uav = `q75' + 1.5 * (`q75' - `q25')
*	qui egen `xi' = max(`ix') /*
*		*/ if `ix' <= `uav' & `use' & `byg' == `j'
*	local uav = `xi'
*	drop `xi'
	qui sum `ix' if `ix' <= `uav' & `use' & `byg' == `j',meanonly
	local uav = r(max)

	local lav = `q25' - 1.5 * (`q75' - `q25')
*	qui egen `xi' = min(`ix') /*
*		*/ if `ix' >= `lav' & `use' & `byg' == `j'
*	local lav = `xi'
*	drop `xi'
	qui sum `ix' if `ix' >= `lav' & `use' & `byg' == `j',meanonly
	local lav = r(min)

	if `j' == 1 {
		quietly summ `ix' [`weight'`exp'] if `use', detail
		local ismin = r(min)          /* min        */
		local ismax = r(max)          /* max        */
		if "`by'" != "" {
			local isn  = r(N)     /* no. obs.   */
			local ismn = r(min)   /* min        */
			local ismx = r(max)   /* max        */
			local ism  = r(p50)   /* median     */
			local is25 = r(p25)   /* 25th %tile */
			local is75 = r(p75)   /* 75th %tile */
			local iss  = 0
			local isw  = 0
		}
	}

	if `j' == 1 & "`by'" != "" {
		if `width' <= 0 {
			tempname wwidth
			local ismin = `ism'
			local ismax = `ism'
			local jj 1
			while `jj' <= `byn' {
				quietly summ `ix' [`weight'`exp'] /*
					*/ if `use' & `byg' == `jj', detail
				scalar `wwidth' = 0.9 * min(sqrt(r(Var)), /*
					*/ (r(p75) - r(p25)) / 1.349) / (r(N)^.2)
				local ismin = min(`ismin', r(min) - `wwidth')
				local ismax = max(`ismax', r(max) + `wwidth')
				local jj = `jj' + 1
			}
		}
		else {
			local ismin = `ismn' - `width'
			local ismax = `ismx' + `width'
		}
	}

	quietly summ `ix' [`weight'`exp'] if `use' & `byg' == `j', detail
	local ixmin = r(min)
	local ixmax = r(max)
	local ixn   = r(N)
	if `gap' == 0 { local gp = 1 + max( /*
		*/ length(string(round(`ixmin',    `round'))), /*
		*/ length(string(round(r(p50),`round'))),      /*
		*/ length(string(round(`ixmax',    `round')))) }
	else { local gp = `gap' }

	tempname wwidth
	scalar `wwidth' = `width'
	if `wwidth' <= 0.0 {
		scalar `wwidth' = 0.9 * min(sqrt(r(Var)),  /*
			*/ (r(p75) - r(p25)) / 1.349) / (r(N)^.2)
	}
	local ww = `wwidth'

	tempvar d m
	qui gen double `d' = .
	qui gen double `m' = .

	kd `ix' `d' `m' `use' `byg' [`weight'`exp'], n(`n')     /*
		*/  ww(`ww') j(`j') `biweight' `cosine' `epan'  /*
		*/ `gauss' `rectangle' `parzen' `triangle'
	
	label var `d' "density"
	label var `m' "`ixl'"

* truncat option
	if "`truncat'" != "" {
		if "`truncat'" == "*" {
			local tn = `ixmin'
			local tx = `ixmax'
		}
		else {
			quietly summ `m' [`weight'`exp'] if `use', detail
			local ismn = r(min)
			local ismx = r(max)
			local nc 1
			while `nc' > 0 {
				local nc = index("`truncat'",",")
				if `nc' > 0 { local truncat = substr("`truncat'",1, /*
					*/ `nc' - 1) + " " + substr("`truncat'",`nc' + 1,.) }
			}
			local tn: word 1 of `truncat'
			local tx: word 2 of `truncat'
			local tn = real("`tn'")
			local tx = real("`tx'")
			if `tn' > `ismn' { local tn = min(`tn',`ixmin') }
			if `tx' < `ismx' { local tx = max(`tx',`ixmax') }
		}
		qui replace `m' = . if `m' < `tn' | `m' > `tx'
	}
	qui summ `d' in 1/`n', meanonly
	local scale = 1 / (`n' * r(mean))
	qui replace `d' = `d' * `scale' in 1/`n'

	local n21 = `n' * 2 + 1
	qui replace `d' = -`d'[`n21' - _n] in `n1'/`n2'
	qui replace `m' =  `m'[`n21' - _n] in `n1'/`n2'
	qui replace `d' =  `d'[1] in `n2'
	qui replace `m' =  `m'[1] in `n2'

	if "`truncate'" != "" {
		tempvar tm1 tm2
		qui gen `tm2' = _n
		qui gen `tm1' = sign(`d')
		gsort -`tm1' `m'
		local tm = `m'[1]
		local td = `d'[1]
		sort `tm2'
		qui replace `d' = `td' in `n2'
		qui replace `m' = `tm' in `n2'
	}
	if `scale' == . { qui replace `m' = `q50' + .0001 in 25/25 }
	if `scale' == . { qui replace `m' = `q50' - .0001 in 24/24 }
	if `scale' == . { qui replace `d' =  0 in 25/25 }
	if `scale' == . { qui replace `d' =  0 in 24/24 }
	if "`by'" != "" {
		local iss = `iss' + `scale'
		local isw = `isw' + `wwidth'
	}

* saving option
	if `j' * `k' == 1 & "`saving'" != "" {
		local c  = index("`saving'",",")
		local cs " "
		if index("`saving'",", ") { local cs "" }
		if `c' { local saving = substr("`saving'",1,`c' - 1) /*
			*/  + "`cs'" + substr("`saving'",`c' + 1, .) }
		local savfile : word 1 of `saving'
		local replace : word 2 of `saving'
		if "`replace'" == "replace" { capture erase "`savfile'.gph" }
		capture confirm new file "`savfile'.gph"
		if _rc == 0 { local saving ", saving(`savfile')" }
		else {
			local rc = _rc
			di in re "  file `savfile'.gph exists."
			di in bl "use another filename or add 'replace' option."
			exit `rc'
		}
	}

	if "`byl'" != "" { local bylbyl byl("`byl'") }

	tempname ixlixl
	global ixlixl "`ixl'"

* do plot
	if `j' * `k' == 1 { gph open `saving' }
	viogph `d' `m', j(`j') k(`k') byn(`byn') ixmin(`ixmin')          /*
	*/	ixmax(`ixmax') q50(`q50') ismin(`ismin') ismax(`ismax')  /*
	*/	nvars(`nvars') gp(`gp') `bylbyl' uav(`uav') lav(`lav')   /*
	*/	q75(`q75') q25(`q25') rou(`round') `options'
	if `j' >= `byn' & `k' >= `nvars' { gph close }

	if `byn' > 1 { local ixl = `bl' }
*	          di "`n'\ `wwidth'\ `scale'\ `ixmin'\ `lav'\ `q25'\ `q50'\ `q75'\ `uav'\ `ixmax'\ `ixn'"
	matrix `A' = (`n'\ `wwidth'\ `scale'\ `ixmin'\ `lav'\ `q25'\ `q50'\ `q75'\ `uav'\ `ixmax'\ `ixn')
	local nam = trim(substr("`ixl'",1,8))
	while index("`nam'", " ") {
		local b = index("`nam'", " ")
		local nam = substr("`nam'", 1, `b'-1) + "_" + substr("`nam'", `b'+1, .)
	}
	matrix colnames `A' = `nam'

	if `k' * `j' == 1 { 
		matrix `S' = `A' 
		matrix rownames `S' = estN Width Scale Min LAV Q25 Median Q75 UAV Max n
	}
	else { matrix `S' = `S',`A' }
	local j = `j' + 1

 }       /* end of loop for each `by' group */

	if "`by'" != "" {
		di _n in gr "Statistics (all groups combined): "
		di    in gr "  Min: " in ye `ismn' _c
		di    in gr "  Max: " in ye `ismx' _c
		di    in gr "  n: " in ye `isn'
		local scale  = `iss' / `byn'
		local wwidth = `isw' / `byn'
		local ixmin  = `ismn'
		local lav    = .
		local q25    = `is25'
		local q50    = `ism'
		local q75    = `is75'
		local uav    = .
		local ixmax  = `ismx'
		local ixn    = `isn'
	}
	local k = `k' + 1
 }       /* end of loop for each varname */

* display stats
	if `byn' == 1 { local kstop = `nvars' }
	else          { local kstop = `byn' }
	local k 1
	if `byn' > 1 { sort `kk' }
	while `k' <= `kstop' {
		di _n in gr "Statistics for " _c
		if `byn' == 1 { di in ye "``k''" in gr ":" }
  		else          { di in gr "group " in ye `bylabel'[`k'] in gr ":" }
		di in gr "  LAV: " in ye `S'[5,`k'] _c
		di in gr "  Q25: " in ye `S'[6,`k'] _c
		di in gr "  Q75: " in ye `S'[8,`k'] _c
		di in gr "  UAV: " in ye `S'[9,`k']
		di in gr "  Min: " in ye `S'[4,`k'] _c
		di in gr "  Median: " in ye `S'[7,`k'] _c
		di in gr "  Max: " in ye `S'[10,`k'] _c
		di in gr "  n: " in ye `S'[11,`k']
		di in gr "Density computed using:"
		di in gr "  Kernel: " in ye "`kernel'" _c
		di in gr "  N: " in ye `S'[1,`k'] _c
		di in gr "  Scale: " in ye %6.2f `S'[3,`k'] _c
		di in gr "  Width: " in ye %6.2f `S'[2,`k']
		local k = `k' + 1
	}

* save globals
	return scalar      N = `ixn'
	return scalar    max = `ixmax'
	return scalar    uav = `uav'
	return scalar    q75 = `q75'
	return scalar median = `q50'
	return scalar    q25 = `q25'
	return scalar    lav = `lav'
	return scalar    min = `ixmin'
	return scalar  scale = `scale'
	return scalar  width = `wwidth'
	return scalar  est_N = `n'
	return local  kernel   "`kernel'"


* double save globals
	global S_12 = `ixn'
	global S_11 = `ixmax'
	global S_10 = `uav'
	global S_9  = `q75'
	global S_8  = `q50'
	global S_7  = `q25'
	global S_6  = `lav'
	global S_5  = `ixmin'
	global S_4  = `scale'
	global S_3  = `wwidth'
	global S_2  = `n'
	global S_1    "`kernel'"

	macro drop ixlixl b1flg t2flg
	matrix S = `S'
end


program define viogph
	version 6
	syntax varlist(numeric min=2 max=2)                                /*
		*/ [ , J(int 1) K(int 1) BYN(int 1) TItle(str)             /*
		*/	B1title(str) IXMIN(real 0.0) IXMAX(real 0.0)       /*
		*/	Q50(real 0.0) ISMIN(real 0.0) ISMAX(real 0.0)      /*
		*/	NVARS(int 0) GP(int 3) BYL(str) UAV(real 0.0)      /*
		*/	LAV(real 0.0) Q75(real 0.0) Q25(real 0.0) Pen(str) /*
		*/	Symbol(str) Connect(str) T1title(str) T2title(str) /*
		*/	L1title(str) L2title(str) R1title(str) R2title(str)/*
		*/	YLAbel(str) YSCale(str) ROUnd(real 0.0) * ]
	tokenize `varlist'

	local d "`1'"
	local m `2'

	local t2t2 = $t2flg
	local b1b1 = $b1flg
	local ixl = "$ixlixl"

* set up the plot

	if "`pen'"     == "" { local pen "2" }
	if "`symbol'"  == "" { local symbol "i" }
	if "`connect'" == "" { local connect "l" }

	if `j' == 1 & `k' == 1 {
		if "`t1title'" == "." { local t1title t1t(" ") }
		else if "`t1title'" == "" { local t1title t1t(Violin Plot) }
		else { local t1title t1t("`t1title'") }
		if `byn' > 1 { local t1title t1t("`ixl'") }
	}
	if `j' > 1 | `k' > 1 { local t1title t1t(" ") }

	if `j' == 1 & `k' == 1 {
		if "`t2title'" != "" {
			local t2title t2t("`t2title'")
			local t2t2 1
		}
	}
	else if `t2t2' == 1 { local t2title t2t(" ") }

	if "`title'" == "" { local title "`b1title'" }
	if "`title'" != "" {
		local b1title b1t(" ")
		local b1b1 1
	}

	if "`ylabel'" == "" { local yl = "yla(" /*
		*/  + string(round(`ixmin',`round')) + "," /*
		*/  + string(round(`q50',`round'))   + "," /*
		*/  + string(round(`ixmax',`round')) + ")" }
	else { local yl yla(`ylabel') }
	if index("`options'","yla") > 0 { local yl "" }

	if "`yscale'" == "" { local ys ysc(`ismin',`ismax') }
	else { local ys ysc(`yscale') }

*  set up for left and right titles
	local lts 0
	if "`l1title'" != "" { local lts = `lts' + 1 }
	if "`l2title'" != "" { local lts = `lts' + 1 }
	local rts 0
	if "`r1title'" != "" { local rts = `rts' + 1 }
	if "`r2title'" != "" { local rts = `rts' + 1 }
	local q1 = `lts' * 900
	local q2 = `rts' * 900 + 200
	local q  = 32000
	if `byn' * `nvars' >= 3 { local q  = `q' - `q1' - `q2' }

* do plot

*  draw density traces
	local pw = min(.33, 1 / (`byn' * `nvars') )
	local pw = `q' * `pw'
	local p1 = `q1' + (`j' * `k' - 1) * `pw'
	local p2 = `p1' + `pw'
	local pc = (`q1' + `q2' + `pw' * `byn' * `nvars') / 2
	#delimit ;
	graph `m' `d', bbox(0,`p1',23063,`p2',923,444,0) s(`symbol')
	  c(`connect') pe(`pen') `t1title' `yl' gap(`gp') `ys' `t2title'
	  `b1title' b2t(" ") `options' ;
	#delimit cr
	tempname ysca yloc xloc
	scalar `ysca'  = r(ay)
	scalar `yloc'  = r(by)
	scalar `xloc'  = r(bx)
*  draw label
	local r1 = 20700
	local r2 = 21700
	local c1 = 21500
	if `b1b1' == 1 {
		local r1 = `r1' - 1000
		local r2 = `r2' - 1000
		local c1 = `c1' - 1000
	}
	gph clear `r1' `p1' `r2' `p2'
	gph pen 1
	local xlo = `xloc'
	if `byn' == 1 { gph text `c1' `xlo' 0 0 `ixl' }
	else { gph text `c1' `xlo' 0 0 `byl' }
*  draw title
	if "`title'" != "" { gph text 22100 `pc' 0 0 `title' }
*  draw left title(s)
	if `j' == 1 & `k' == 1 {
		gph font 300 600
		if "`l1title'" != "" { gph text 11500 900  1 0 `l1title' }
		if "`l2title'" != "" { gph text 11500 `q1' 1 0 `l2title' }
		gph font 570 290
	}
*  draw adjacent values line
	local r1 = `uav' * `ysca' + `yloc'
	local r2 = `lav' * `ysca' + `yloc'
	local c1 = `xloc'
	local c2 = `c1'
	gph pen `pen'
	gph line `r1' `c1' `r2' `c2'
*  draw quartile box (shaded)
	local r1 = `q75' * `ysca' + `yloc'
	local r2 = `q25' * `ysca' + `yloc'
	local c1 = -250 + `xloc'
	local c2 =  250 + `xloc'
* v 7 fix
*	gph box `r1' `c1' `r2' `c2' 1
	if $caller < 7 { gph box `r1' `c1' `r2' `c2' 1 }
	else           { gph box `r1' `c1' `r2' `c2' 4 }
*  draw median
	local r1 = `q50' * `ysca' + `yloc' + 100
	local r2 = `q50' * `ysca' + `yloc' - 100
	local c1 = -500 + `xloc'
	local c2 =  500 + `xloc'
	gph box `r1' `c1' `r2' `c2' 0
*  draw right title(s)
	if `j' == `byn' & `k' == `nvars' {
		gph font 300 600
		gph pen 1
		local qq = `p2' + 900
		if "`r1title'" != "" { gph text 11500 `qq' 1 0 `r1title' }
		local qq = `p2' + 900 * `rts'
		if "`r2title'" != "" { gph text 11500 `qq' 1 0 `r2title' }
	}
	global t2flg = `t2t2'
	global b1flg = `b1b1'
end


program define kd

* -> Kernel Density code stolen from kdensity.ado

	version 6
	syntax varlist(numeric min=1 max=5) [fw aw]                    /*
		*/ [ , N(int 50) WW(real 0.0) J(int 1)                 /*
		*/   BIweight COSine EPan GAUss RECtangle PARzen TRIangle ]
	tokenize `varlist'

	local ix  "`1'"
	local d   "`2'"
	local m   "`3'"
	local use "`4'"
	local byg "`5'"

	tempvar y z
	qui gen double `y' = .
	qui gen double `z' = .

	tempname delta wid wwidth
	scalar `wwidth' = `ww'
	scalar `delta'  = (r(max) - r(min) + 2 * `wwidth') / (`n' - 1)
	scalar `wid'    = r(N) * `wwidth'
	qui replace `m' = r(min) - `wwidth' + (_n - 1) * `delta' in 1/`n'

	local i 1
	if "`biweigh'" != "" {
		local con1 = .9375
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = `con1' * (1 - (`z')^2)^2 /*
				*/ if abs(round(`z',1e-8)) < 1
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else if "`cosine'" != "" {
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = 1 + cos(2 * _pi * `z') /*
				*/ if abs(round(`z',1e-8)) < 0.5
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else if "`triangl'" != "" {
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = 1 - abs(`z') if abs(round(`z',1e-8)) < 1
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else if "`parzen'" != "" {
		local con1 = 4 / 3
		local con2 = 2 * `con1'
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = `con1' - 8 * (`z')^2 + 8 * abs(`z')^3 /*
				*/ if abs(round(`z',1e-8)) <= .5
			qui replace `y' = `con2' * (1 - abs(`z'))^3 /*
				*/ if abs(round(`z',1e-8)) > .5 /*
				*/  & abs(round(`z',1e-8)) < 1
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else if "`gauss'" != "" {
		local con1 = sqrt(2 * _pi)
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = exp(-0.5 * ((`z')^2)) / `con1'
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else if "`rectang'" != "" {
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = 0.5 if abs(round(`z',1e-8)) < 1
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
	else {
		local con1 = 3 / (4 * sqrt(5))
		local con2 = sqrt(5)
		while `i' <= `n' {
			qui replace `z' = (`ix' - `m'[`i']) / (`wwidth') /*
				*/ if `use' & `byg' == `j'
			qui replace `y' = `con1' * (1 - ((`z')^2 / 5)) /*
				*/  if abs(round(`z',1e-8)) <= `con2'
			qui summ `y' [`weight'`exp'], meanonly
			qui replace `d' = r(sum) / `wid' in `i'
			qui replace `y' = .
			local i = `i' + 1
		}
		qui replace `d' = 0 if `d' == . in 1/`n'
	}
end
