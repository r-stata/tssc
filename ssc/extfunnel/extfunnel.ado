*! version 1.0.2 03jul2012 MJC

/* 
History
MJC 03jul2012 version 1.0.2 - bug fix, extra touse passed to Mata when addplot() is specified; addplot passed to dummy plots to aid legend(order()) use
MJC 21sep2011 version 1.0.1 - bug fix: touse now passed to Mata correctly. Matrices of effect estimates, standard errors and status codes now returned in r(). 
							  Label option added to pass to metan. Scheme option added: grayscale and color allowed. legend(order(1 "" ...)) now synched.
MJC 21aug2011 version 1.0.0
*/

program define extfunnel, rclass
	version 11.0

	syntax varlist(min=2 max=2) [if] [in],  [										///
												FIXEDI								/// 	-Fixed effect MA using inverse-variance method-
												RANDOMI								///		-Random effect MA using inverse-variance method-
																					///
												CPoints(string)						///		-No. of points to evaluate contours; Defaults vary between fixed/random-
												NULL(real 0) 						///		-Value of null hypothesis-
												Isquared(numlist asc max=5) 		///		-I-squared contours-
												TAUsquared(numlist asc max=5)		///		-Tau-squared contours-
																					///
												MEASure(string)						///		-One of lci/uci/ciwidth-
												LOE(numlist asc min=2 max=2)		///		-Limits of equivalence-
												LOELine								///		-Display limits of clinical equivalence on the plot-
																					///
												NEWSTUDYTreatment(string)			///		-No. of patients in the treatment group of the new study-
												NEWSTUDYControl(string)				///		-No. of patients in the control group of the new study-
												OR									///		-generate log odds ratios when doing "peacock plot"
												RR									///		-generate log risk ratios when doing "peacock plot"
																					///
												XRANGE(numlist asc max=2) 			///		-Range of effect estimates to evaluate-
												YRANGE(numlist asc max=2) 			///		-Range of standard errors to evaluate-
												SUMD	 							///		-Suppress displaying summary diamond-
												SUMDPosition(real 0)				///		-Vertical position to put summary diamond-
												PREDiction							///		-Show prediction interval on twoway graph-
												NONULLline 							///		-Suppress displaying vertical line of no effect-
												NOPOOLEDline 						///		-Suppress displaying vertical line of pooled estimate-
												NOSHADing 							///		-Suppress displaying shaded regions-
												NOSCATter 							///		-Suppress displaying scatter of original meta-analysis-
												NOMETAN								///		-Suppress display of metan output-
												EFORM								///		-Exponentiate effect estimates from metan and in graph-
												ADDPlot(string)						///		-Add an additional twoway graph-
												Level(cilevel)	 					///		-Statistical significance level-
												LABel(string)						///		-To pass to metan-
												SCHEME(string)						///		-Graphical colour scheme: either grayscale or color-
																					///
												* 									///		-Twoway options-
											]

	
	tokenize `varlist'
	
	marksample touse
	global touse `touse'

	/*****************************************************************************************************************************************************/
	/* ERROR CHECKS AND DEFAULTS */
	
	capture which metan
	if _rc >0 {
		display in yellow "You need to install the command metan. This can be installed using,"
		display in yellow ". {stata ssc install metan}"
		exit  198
	}
			
	local nmethods : word count `fixedi' `randomi'
	if (`nmethods'>1) {
		di as error "Can only specify one of fixedi or randomi"
		exit 198
	}

	local nmethods2 : word count `or' `rr'
	if (`nmethods2'>1) {
		di as error "Can only specify one of or and rr"
		exit 198
	}
	
	if "`or'"=="" & "`rr'"=="" {
		local stat = "or"
	}
	else {
		local stat = "`or' `rr'"
	}
	
	if (`nmethods'==0) {
		local method "fixedi"
	}
	else {
		local method = trim("`fixedi' `randomi'")
	}
	
	if "`newstudytreatment'"=="" & "`newstudycontrol'"!="" {
		di as error "newstudytreatment must be specified as well as newstudycontrol"
		exit
	}
	
	if "`newstudytreatment'"!="" & "`newstudycontrol'"=="" {
		di as error "newstudycontrol must be specified as well as newstudytreatment"
		exit 198
	}	
	
	if "`measure'"!="" & "`loe'"!="" {
		di as error "Cannot specify both measure and loe"
		exit 198
	}
	
    if "`cpoints'" != "" {
		capture confirm integer number `cpoints'
		if _rc>0 {
			display in red "cpoints option must be an integer"
			exit 198
		}
	}
	
	if "`method'"=="fixedi" & "`cpoints'"=="" & "`measure'"=="" & "`loe'"=="" {
		local cpoints = 3500
	}

	if "`method'"=="randomi" | "`measure'"!="" | "`loe'"!="" {
		if "`cpoints'"=="" {
			local cpoints = 100
			scalar contpoints = 100
		}
		else {
			scalar contpoints = `cpoints'
		}
	}
	
	if "`loe'"!="" | "`measure'"!="" {
		if `cpoints'>500 {
			di as error "Maximum number of contour points is 500 when loe/measure is specified"
			exit 198			
		}
	}
	
	if "`method'"=="randomi"  & "`cpoints'"!="" & `cpoints'>500 {
		di as error "Maximum number of contour points is 500 when fixed/random/randomi method is specified"
		exit 198
	}
	
	qui su `2' if `touse'
	if (`r(min)'<0) {
		di as error "Variable `2' is assumed to contain standard errors - a negative value has been found"
		exit 198
	}
	
	if ("`isquared'"!="" & "`tausquared'"!="") {
		di as error "I-squared and Tau-squared contours cannot be specified together"
		exit 198
	}
	
	if ("`newstudytreatment'" != "" & "`newstudycontrol'" == "") | ("`newstudytreatment'" == "" & "`newstudycontrol'" != "") {
		di as error "Both newstudytreatment and newstudycontrol must be specified"
		exit 198
	}
	
	if "`newstudytreatment'" != "" & "`newstudycontrol'" != "" {
		capture confirm integer number `newstudytreatment'
		if _rc>0 {
			display as error "newstudytreatment option must be an integer"
			exit 198
		}
		capture confirm integer number `newstudycontrol'
		if _rc>0 {
			display as error "newstudycontrol option must be an integer"
			exit 198
		}
	}
	
	if "`measure'"!="" {
		if "`measure'"!="lci" & "`measure'"!="uci" & "`measure'"!="ciwidth" {
			di as error "measure must be one of lci, uci or ciwidth"
			exit 198
		}
	}	
	
	if "`loe'"!="" {
		local lind = 1
		foreach limit in `loe' {
			scalar loe`lind' = `limit'
			local `++lind'
		}
		if `null'<loe1 | `null'>loe2 {
			di as error "loe region must contain null"
			exit 198
		}			
	}
	
	if ("`tausquared'"!="" | "`isquared'"!="") & "`eform'"!="" {
		di as error "Cannot use eform option with tausquared or isquared contours"
		exit 198
	}
	
	if "`measure'"=="ciwidth" & `null'<=0 {
		di as error "Null when measure = ciwidth must be > 0"
		exit 198
	}
	
	if "`loeline'"!="" & "`loe'"=="" {
		di as error "loeline can only be specified with loe"
		exit 198
	}
	
	if "`noshading'"!="" & ("`measure'"!="" | "`loe'"!="" | "`newstudytreatment'"!="") {
		di as error "noshading option cannot be used"
		exit 198
	}

	/*****************************************************************************************************************************************************/
	/* Colour scheme */	
	
	if "`scheme'"=="" {
		local colscheme "grayscale"
	}
	else {
		local l = length("`scheme'")
		if substr("grayscale",1,max(1,`l')) == "`scheme'" {
			local colscheme "grayscale"
		}
		else if substr("color",1,max(1,`l')) == "`scheme'" {
			local colscheme "color"
		}
		else {
			di as error "Unknown scheme"
			exit 198		
		}
	}
	
	if "`loe'"=="" {
		if "`colscheme'"=="grayscale" {
			local col1 "gray*0.3"
			local col2 "gray*0.8"
			local col3 "gray*1.2"
		}
		else {
			local col1 "green"
			local col2 "blue"
			local col3 "red"		
		}
	}
	else {
		if "`colscheme'"=="grayscale" {
			local col1 "gray*0.1"
			local col2 "gray*0.4"
			local col3 "gray*0.7"
			local col4 "gray*1"
			local col5 "gray*1.3"
			local col6 "gray*1.6"
			local col7 "gray*1.9"
			local col8 "gray*2.2"
		}
		else {
			local col1 "green"
			local col2 "orange"
			local col3 "blue"
			local col4 "yellow"
			local col5 "blue*0.5"
			local col6 "green*0.5"
			local col7 "red"
			local col8 "purple"
		}	
	}

	
quietly {

	/*****************************************************************************************************************************************************/
	/* PRELIMINARY CALCULATIONS */

preserve	
	
	local xtitle "Effect Estimate"																			/* Default x-title */
	local ytitle "Standard Error"																			/* Default y-title */
	
	/* Summarise effect estimates and standard errors and extract: max, min, range and no. of studies */
	tokenize `varlist'
	su `1' if `touse', mean																							
	local N_SS = `r(N)'
	scalar nstudies=`r(N)'
	local minSS = `r(min)'
	local maxSS = `r(max)'
	local rangeSS = (`maxSS') - (`minSS')
	su `2' if `touse', mean
	local N_seSS = `r(N)'
	local minseSS = `r(min)'
	local maxseSS = `r(max)'
	local rangeseSS = (`maxseSS') - (`minseSS')
	local Nobs = _N
	local N_new = `Nobs'+1										

	local siglev = abs(invnormal((100-`level')/200))														/* Critical value */
	scalar siglev = `siglev'																				/* Need scalars for mata program */	
	scalar null = `null'
	
	/*** Conduct AD meta-analysis using metan ***/
	if "`nometan'"!=""{
		local show "quietly"
	}
}

	if "`label'"!="" {
		local metanlab "label(`label')"
	}
	
	`show' di as txt "Original meta-analysis results:"
	`show' metan `1' `2' if `touse', `method' nograph nokeep olevel(`level') `eform' `metanlab'

quietly {

	if "`eform'"=="" {
		local pooled_est = `r(ES)'																			/* Pooled estimate */
		local tau2= `r(tau2)'																				/* Estimat of tau2 */
		local se_pooled_est = `r(seES)'																		/* Pooled standard error */
	}
	else{
		local pooled_est = log(`r(ES)')																		/* Pooled estimate */
		local tau2= `r(tau2)'																				/* Estimat of tau2 */
		local se_pooled_est = `r(selogES)'																	/* Pooled standard error */
	}	
	
	/*** Define x/y min/max for area ranges, defaults are scatter plot plus a bit. ***/
	local xcount : word count `xrange'
	local ycount : word count `yrange'

	tempname xmin xmax ymin ymax																			
	if (`xcount' > 0){
		tokenize `xrange'
		scalar `xmin' =`1'
		scalar `xmax' =`2'
	}
	else {
		scalar `xmin' = `minSS' - (0.5*(`rangeSS'))									
		scalar `xmax' = `maxSS' + (0.5*(`rangeSS'))									
	}
	if (`ycount' > 0){
		tokenize `yrange'
		scalar `ymin' = 1.0E-06
		scalar `ymax' = `2'
	}
	else {
		scalar `ymin' = 1.0E-06														
		scalar `ymax' = `maxseSS' + 0.5*`rangeseSS'									
	}
	
	if (`ymin'<=0){
		scalar `ymin' = 1.0E-06
		di "Minimum of y must be > 0"
	}
	
	/*****************************************************************************************************************************************************/
	/* For mata */
	
	if "`measure'"=="lci" {
		scalar power = 1
	}
	else if "`measure'"=="uci" {
		scalar power = 2
	}
	else if "`measure'"=="ciwidth" {
		scalar power = 3
	}
	else if "`loe'"!="" {
		scalar power = 4
	}
	else {
		scalar power = 0
	}	
	
	if "`eform'"!="" {
		local explabel "xscale(log)"
	}
	scalar ymin = `ymin'
	scalar ymax = `ymax'
	scalar xmin = `xmin'
	scalar xmax = `xmax'
	
	/*****************************************************************************************************************************************************/
	/* Generate basis variables to input into formula */
	
	tempvar tempSS tempseSS
	range2 `tempSS' `xmin' `xmax' `cpoints'																/* range2 creates double formatted variables */
	range2 `tempseSS' `ymin' `ymax' `cpoints'
	local xwidth = `xmax' - `xmin'
	local ywidth = `ymax' - `ymin'
	
	if ("`method'" != "fixedi" | "`measure'"!="" | "`loe'"!="") {

		/* Return matrices of effect estimates and standard errors */
		tempname matSS matseSS
		mkmat `tempSS', matrix(`matSS') nomissing
		
		mkmat `tempseSS' , matrix(`matseSS') nomissing

		return matrix ESmat = `matSS'
		return matrix seESmat = `matseSS'
	
	}

	/*****************************************************************************************************************************************************/
	/* Dummy plots for legend */
	/* Begin twoway label index and label */
	local labnum 0		
	
	if "`noshading'"=="" & "`newstudytreatment'"=="" {

		*coords for full graph box shaded area
		tempvar x2 y2
		range `x2' `xmin' `xmax' 2
		if "`eform'"!="" {
			replace `x2' = exp(`x2')
		}
		gen `y2'=`ymax' in 1/2	
	
		*dummy plots for legend
		if (power==0) {
			local labnum `++labnum'
			local dumplots "(area `y2' `x2', col(`col1') fi(inten100))"
			local lab `"`lab' `labnum' "Non-sig. effect (`=100-`level''% level)""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col2') fi(inten100))"
			local lab `"`lab' `labnum' "Sig. effect > NULL (`=100-`level''% level)""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col3') fi(inten100))"
			local lab `"`lab' `labnum' "Sig. effect < NULL (`=100-`level''% level)""'
		}
		else if (power==1) {
			local labnum `++labnum'
			local dumplots "(area `y2' `x2', col(`col1') fi(inten100))"
			local lab `"`lab' `labnum' "Lower CI < `null'""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col3') fi(inten100))"
			local lab `"`lab' `labnum' "Lower CI >= `null'""'
		}
		else if (power==2) {
			local labnum `++labnum'
			local dumplots "(area `y2' `x2', col(`col1') fi(inten100))"
			local lab `"`lab' `labnum' "Upper CI < `null'""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col3') fi(inten100))"
			local lab `"`lab' `labnum' "Upper CI >= `null'""'
		}
		else if (power==3) {
			local labnum `++labnum'
			local dumplots "(area `y2' `x2', col(`col1') fi(inten100))"
			local lab `"`lab' `labnum' "CI width < `null'""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col3') fi(inten100))"
			local lab `"`lab' `labnum' "CI width >= `null'""'
		}
		else if (power==4) {
			local labnum `++labnum'
			local dumplots "(area `y2' `x2', col(`col1') fi(inten100))"
			local lab `"`lab' `labnum' "1. Insufficient evidence to" "confirm or exclude an" "important difference""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col2') fi(inten100))"
			local lab `"`lab' `labnum' "2. Stat. sig. benefit," "clinical benefit unclear""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col3') fi(inten100))"
			local lab `"`lab' `labnum' "3. Stat. sig. harm," "clinical harm unclear""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col4') fi(inten100))"
			local lab `"`lab' `labnum' "4. Stat. sig. benefit," "no clinical benefit""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col5') fi(inten100))"
			local lab `"`lab' `labnum' "5. Stat. sig. harm," "no clinical harm""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col6') fi(inten100))"
			local lab `"`lab' `labnum' "6. No evidence of" "an important difference""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col7') fi(inten100))"
			local lab `"`lab' `labnum' "7. Important benefit""'
			local labnum `++labnum'
			local dumplots "`dumplots'(area `y2' `x2', col(`col8') fi(inten100))"
			local lab `"`lab' `labnum' "8. Important harm""'
			local extraleg "pos(3) col(1) size(small)"
		}			
	
		if (power!=4) {
			local basearea "(area `y2' `x2', base(0) col(`col1') fi(inten100))"
		}
		else {
			local basearea "(area `y2' `x2', col(`col1') base(0) fi(inten100))"
		}	
	
	}
	
	/*****************************************************************************************************************************************************/
	/* I-SQUARED CONTOURS */
	
	if ("`isquared'"!="" & "`tausquared'"=="") {	
	
		tokenize `varlist'
		/*replace `1' = `pooled_est' in `=`N_SS'+1'
		replace `2' = 0.1 in `=`N_SS'+1'
		metan `1' `2', `method'i nograph nokeep level(`level')
		noisily di as txt " Minimum I-squared =" %8.4f `r(i_sq)'*/

		*prelim calcs
		tempvar eval1gen eval2gen eval3gen
		gen `eval1gen' = ((`1')^2)/((`2')^2)
		su `eval1gen' if `touse'
		local eval1 = `r(sum)'
		
		gen `eval2gen' = (`1')/((`2')^2)
		su `eval2gen' if `touse'
		local eval2 = `r(sum)'
		
		gen `eval3gen' = 1/((`2')^2)
		su `eval3gen' if `touse'
		local eval3 = `r(sum)'

		local Ni2 = wordcount("`isquared'")

		/* Line patterns */
		local lpat "shortdash longdash_dot dash_dot shortdash_dot dot" 
		local n 0
		foreach i in `lpat' {
				local lp`++n' `i'
		}
		
		*** Need to generate each contour as a variable, then replace as missing ones outside plot region.
		
		local pati 1
		tokenize `isquared'
		forvalues i2 =1/`Ni2' {
			if (``i2'' > 100) {
				di as error "I-squared must be between 0% and 100%"
				exit 198
			}
			tempvar isq`i2'1 isq`i2'2
			gen double `isq`i2'1' = (`eval2'/`eval3')+sqrt((((`eval3'+(1/((`tempseSS')^2)))/(`eval3'*(1/(`tempseSS'^2))))*(((`eval2')^2/(`eval3'+(1/((`tempseSS')^2))))+(`N_SS'/(1-(``i2''/100)))-`eval1'))+(`eval2'/`eval3')^2)
			count if inrange(`isq`i2'1',`xmin',`xmax')
			local ncont1 = r(N)
			gen double `isq`i2'2' = (`eval2'/`eval3')-sqrt((((`eval3'+(1/((`tempseSS')^2)))/(`eval3'*(1/(`tempseSS'^2))))*(((`eval2')^2/(`eval3'+(1/((`tempseSS')^2))))+(`N_SS'/(1-(``i2''/100)))-`eval1'))+(`eval2'/`eval3')^2)
			count if inrange(`isq`i2'2',`xmin',`xmax')
			local ncont2 = r(N)
			local percentshown = 100*(`ncont1'+`ncont2')/(`cpoints'*2)
			*noisily di as txt %8.4f `percentshown' "% of I-squared = ``i2'' is shown"
			local line "`line' (line `tempseSS' `isq`i2'1' if inrange(`isq`i2'1',`xmin',`xmax'),lpat(`lp`pati'') lcol(black))(line `tempseSS' `isq`i2'2' if inrange(`isq`i2'2',`xmin',`xmax'), lpat(`lp`pati'') lcol(black))"
			local dumplots "`dumplots' (line `tempseSS' `isq`i2'1' if inrange(`isq`i2'1',`xmin',`xmax'),lpat(`lp`pati'') lcol(black))"
			local `++labnum'
			local lab `"`lab' `labnum' "{it:I}-squared = ``i2''%""'
			local pati = `pati'+1
			/*if "`eform'"!="" {
				replace isq`i2'1 = exp(isq`i2'1)			
				replace isq`i2'2 = exp(isq`i2'2)			
			}*/
		}
	}

	/*****************************************************************************************************************************************************/
	/* TAU-SQUARED CONTOURS */
	
	if  ("`isquared'"=="" & "`tausquared'"!="") {	
		
		tokenize `varlist'
		/*replace `1' = `pooled_est' in `=`N_SS'+1'
		replace `2' = 0.1 in `=`N_SS'+1'
		metan `1' `2', `method'i nograph nokeep level(`level')
		noisily di as txt " Minimum tau-squared =" %8.4f `r(tau2)'*/
		
		*prelim calcs.
		tempvar ss2 sess2 evalv evalx evaly evalz
		gen `ss2' = `1'^2
		gen `sess2'=`2'^2
		
		gen `evalv' = (1/`sess2')^2
		su `evalv' if `touse', mean
		local evalvl = `r(sum)'
		
		gen `evalx' = `1'*(1/`sess2')
		su `evalx' if `touse', mean
		local evalxl = `r(sum)'

		gen `evaly' = 1/`sess2'
		su `evaly' if `touse', mean

		local evalyl = `r(sum)'
		
		gen `evalz' = (1/`sess2')*`ss2'
		su `evalz' if `touse', mean
		local evalzl = `r(sum)'

		local sstest1 = `evalxl'/`evalyl'

		local ntau2 = wordcount("`tausquared'")
		
		local lpat "shortdash longdash_dot dash_dot shortdash_dot dot" 
		local tt 0
		foreach i in `lpat' {
			local lp`++tt' `i'
		}

		local pati 1
		tokenize `tausquared'
		forvalues tau22 =1/`ntau2' {
			tempvar tau2`tau22'1 tau2`tau22'2
			gen double `tau2`tau22'1' = `sstest1' + sqrt(((`evalyl'+(1/(`tempseSS'^2)))/(`evalyl'*(1/(`tempseSS'^2))))* (`evalyl'+(1/(`tempseSS'^2))-((`evalvl'+(1/(`tempseSS'^2))^2)/(`evalyl'+(1/(`tempseSS'^2)))))*``tau22'' +((`sstest1')^2) - ((`evalyl'+(1/(`tempseSS'^2)))/(`evalyl'*(1/(`tempseSS'^2)))) * (`evalzl'-(((`evalxl')^2)/(`evalyl'+(1/(`tempseSS'^2))))-`N_SS'))
			count if inrange(`tau2`tau22'1',`xmin',`xmax')
			local ncont1 = r(N)			
			gen double `tau2`tau22'2' = `sstest1' - sqrt(((`evalyl'+(1/(`tempseSS'^2)))/(`evalyl'*(1/(`tempseSS'^2))))* (`evalyl'+(1/(`tempseSS'^2))-((`evalvl'+(1/(`tempseSS'^2))^2)/(`evalyl'+(1/(`tempseSS'^2)))))*``tau22'' +((`sstest1')^2) - ((`evalyl'+(1/(`tempseSS'^2)))/(`evalyl'*(1/(`tempseSS'^2)))) * (`evalzl'-(((`evalxl')^2)/(`evalyl'+(1/(`tempseSS'^2))))-`N_SS'))
			count if inrange(`tau2`tau22'2',`xmin',`xmax')
			local ncont2 = r(N)			
			local percentshown = 100*(`ncont1'+`ncont2')/(`cpoints'*2)
			*noisily di as txt %8.4f `percentshown' "% of Tau-squared = ``tau22'' is shown"
			local line "`line' (line `tempseSS' `tau2`tau22'1' if inrange(`tau2`tau22'1',`xmin',`xmax'),lpat(`lp`pati'') lcol(black))(line `tempseSS' `tau2`tau22'2' if inrange(`tau2`tau22'2',`xmin',`xmax'), lpat(`lp`pati'') lcol(black))"
			local dumplots "`dumplots' (line `tempseSS' `tau2`tau22'1' if inrange(`tau2`tau22'1',`xmin',`xmax'),lpat(`lp`pati'') lcol(black))"		
			local `++labnum'
			local lab `"`lab' `labnum' "{it:{&tau}} - squared = ``tau22''""'
			local pati = `pati'+1
			/*if "`eform'"!="" {
				replace tau2`tau22'1 = exp(tau2`tau22'1)			
				replace tau2`tau22'2 = exp(tau2`tau22'2)
			}*/
		}
	}
	
	/*****************************************************************************************************************************************************/
	/* SUMMARY PLOTS */
	
	tokenize `varlist'

	/* SEAGULL PLOT */

	if "`newstudytreatment'"!="" & "`newstudycontrol'"!="" {
		local newobs = `=`newstudytreatment'+1'*`=`newstudycontrol'+1'
		cap set obs `newobs'
		tempvar indnew logornew selogornew
		gen `indnew' = 0
		gen `logornew' = .
		gen `selogornew' = .
		local templogor "`1'"
		local tempselogor "`2'"
				
		local ii = 1
		forvalues i=1/`=`newstudytreatment'+1' {
			forvalues j=1/`=`newstudycontrol'+1' {

				local event_t = `i' - 1
				local noevent_t = `newstudytreatment' - `event_t'
				local event_c = `j' - 1
				local noevent_c = `newstudycontrol' - `event_c'
				
				if `event_t'==0 | `noevent_t'==0 | `event_c'==0 | `noevent_c'==0 {
					local event_t = `event_t' + 0.5
					local noevent_t = `noevent_t' + 0.5
					local event_c = `event_c' + 0.5
					local noevent_c = `noevent_c' + 0.5
				}						
		
				if "`stat'"!="rr" {
					local lor = log((`event_t'*`noevent_c')/(`noevent_t'*`event_c'))
					local selor = sqrt((1/`event_t') + (1/`noevent_t') + (1/`event_c') + (1/`noevent_c'))
				}
				else {
					local p1 = (`event_t'/(`noevent_t'+`event_t'))
					local p2 = (`event_c'/(`noevent_c'+`event_c'))
					local lor = log(`p1'/`p2')
					local selor = sqrt(((1-`p1')/(`p1'*(`noevent_t'+`event_t')))+((1-`p2')/(`p2'*(`noevent_c'+`event_c'))))
				}
				
				replace `logornew' = `lor' in `ii'
				replace `templogor' = `lor' in `N_new'
				replace `selogornew' = `selor' in `ii'		
				replace `tempselogor' = `selor' in `N_new'	
				
				metan `templogor' `tempselogor', `method' nograph notable level(`level')
			
				local logor = `r(ES)'
				local selogor = `r(seES)'

				local uci = `logor' + `siglev' * `selogor'
				local lci = `logor' - `siglev' * `selogor'
				if `lci'<0 & `uci'<0 {
					replace `indnew' = 1 in `ii'
				}
				else if `uci'>0 & `lci'>0 {
					replace `indnew' = 2 in `ii'
				}
				local `++ii'
			}
		}
		if "`eform'"!="" {
			replace `logornew' = exp(`logornew')
		}
		local seagull "(scatter `selogornew' `logornew' if `indnew'==0,ms(o) mcol(`col1'))(scatter `selogornew' `logornew' if `indnew'==1,ms(o) mcol(`col3'))(scatter `selogornew' `logornew' if `indnew'==2,ms(o) mcol(`col2') )"
		local dumplots "`dumplots' (scatter `selogornew' `logornew' if `indnew'==0,ms(o) mcol(`col1'))(scatter `selogornew' `logornew' if `indnew'==1,ms(o) mcol(`col3'))(scatter `selogornew' `logornew' if `indnew'==2,ms(o) mcol(`col2') )"
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Non-sig. effect (`=100-`level''% level)""'
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Sig. effect < NULL (`=100-`level''% level)""'
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Sig. effect > NULL (`=100-`level''% level)""'

		qui su `selogornew',mean
		if `r(max)'>`ymax' {
			scalar `ymax' = `r(max)'
		}	
	
		/* Prediction interval */
		if "`prediction'"!="" {
		
			local tstat = abs(invttail(`=`N_SS'-2',(100-`level')/200))
			tempvar p1 p2 sumdy
			gen `sumdy' = `sumdposition'
			gen `p1' = `pooled_est' + `tstat'*sqrt(`se_pooled_est'^2+`tau2')
			gen `p2' = `pooled_est' - `tstat'*sqrt(`se_pooled_est'^2+`tau2')
			local predplot "(rcap `p2' `p1' `sumdy' in 1, hor lcol(black))"
			local dumplots "`dumplots'(rcap `p2' `p1' `sumdy' in 1, hor lcol(black))"
			if "`eform'"!="" {
				replace `p1' = exp(`p1')
				replace `p2' = exp(`p2')
			}
			local labnum `++labnum'
			local lab `"`lab' `labnum' "Prediction interval""'
		}
	
		/* Show summary diamond on plot */
		if "`sumd'"!="" {
			tempvar sumdiam_x sumdiam_y
			gen `sumdiam_x' 		= `pooled_est' - `siglev'*`se_pooled_est' in 1
			replace `sumdiam_x' 	= `pooled_est' in 2
			replace `sumdiam_x' 	= `pooled_est'+`siglev'*`se_pooled_est' in 3
			replace `sumdiam_x' 	= `pooled_est' in 4
			gen `sumdiam_y' 		= `sumdposition' in 1
			replace `sumdiam_y'		= `sumdposition' - 0.04*`ywidth' in 2
			replace `sumdiam_y' 	= `sumdposition' in 3
			replace `sumdiam_y' 	= `sumdposition' + 0.04*`ywidth' in 4 
			if "`eform'"!="" {
				replace `sumdiam_x' = exp(`sumdiam_x')
			}
			local sumarea "(area `sumdiam_y' `sumdiam_x', nodropbase col(black) fi(inten100))"
			local dumplots "`dumplots'(area `sumdiam_y' `sumdiam_x', nodropbase col(black) fi(inten100))"
			local labnum `++labnum'
		}

		/* Display y-line at null hypothesis */
		if "`nonullline'"=="" & "`newstudytreatment'"!="" {
			tempvar y_null_line x_null_line
			range `y_null_line' `ymin' `ymax' 2
			gen `x_null_line' = `null' in 1/2
			if "`eform'"!="" {
				replace `x_null_line' = exp(`x_null_line')
			}
			local nullline "(line `y_null_line' `x_null_line', lpat(solid) lcol(black))"
			local dumplots "`dumplots'(line `y_null_line' `x_null_line', lpat(solid) lcol(black))"
			local labnum `++labnum'
			local lab `"`lab' `labnum' "Null effect""'
		}
		
		/* Display y-line at pooled estimate of original meta-analysis */
		if "`nopooledline'"=="" & "`newstudytreatment'"!="" {
			tempvar y_pooled_est x_pooled_est
			range `y_pooled_est' `ymin' `ymax' 2
			gen `x_pooled_est' = `pooled_est' in 1/2
			if "`eform'"!="" {
				replace `x_pooled_est' = exp(`x_pooled_est')
			}
			local pooledline "(line `y_pooled_est' `x_pooled_est', lpat(dash) lcol(black))"
			local dumplots "`dumplots'(line `y_pooled_est' `x_pooled_est', lpat(dash) lcol(black))"
			local labnum `++labnum'
			local lab `"`lab' `labnum' "Pooled effect""'
		}

	}	
	
	/* Prediction interval */
	if "`prediction'"!="" & "`newstudytreatment'"=="" {
	
		local tstat = abs(invttail(`=`N_SS'-2',(100-`level')/200))
		tempvar p1 p2 sumdy
		gen `sumdy' = `sumdposition'
		gen `p1' = `pooled_est' + `tstat'*sqrt(`se_pooled_est'^2+`tau2')
		gen `p2' = `pooled_est' - `tstat'*sqrt(`se_pooled_est'^2+`tau2')
		local predplot "(rcap `p2' `p1' `sumdy' in 1, hor lcol(black))"
		local dumplots "`dumplots'(rcap `p2' `p1' `sumdy' in 1, hor lcol(black))"
		if "`eform'"!="" {
			replace `p1' = exp(`p1')
			replace `p2' = exp(`p2')
		}
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Prediction interval""'
	}
	
	/* Show summary diamond on plot */
	if "`sumd'"!="" & "`newstudytreatment'"=="" {
		tempvar sumdiam_x sumdiam_y
		gen `sumdiam_x' 		= `pooled_est' - `siglev'*`se_pooled_est' in 1
		replace `sumdiam_x' 	= `pooled_est' in 2
		replace `sumdiam_x' 	= `pooled_est'+`siglev'*`se_pooled_est' in 3
		replace `sumdiam_x' 	= `pooled_est' in 4
		gen `sumdiam_y' 		= `sumdposition' in 1
		replace `sumdiam_y'		= `sumdposition' - 0.04*`ywidth' in 2
		replace `sumdiam_y' 	= `sumdposition' in 3
		replace `sumdiam_y' 	= `sumdposition' + 0.04*`ywidth' in 4 
		if "`eform'"!="" {
			replace `sumdiam_x' = exp(`sumdiam_x')
		}
		local sumarea "(area `sumdiam_y' `sumdiam_x', nodropbase col(black) fi(inten100))"
		local dumplots "`dumplots'(area `sumdiam_y' `sumdiam_x', nodropbase col(black) fi(inten100))"
		local labnum `++labnum'
	}
	
	/* Display y-line at null hypothesis */
	if "`nonullline'"=="" & "`newstudytreatment'"=="" & "`measure'"!="ciwidth"{
		tempvar y_null_line x_null_line
		range `y_null_line' `ymin' `ymax' 2
		gen `x_null_line' = `null' in 1/2
		if "`eform'"!="" {
			replace `x_null_line' = exp(`x_null_line')
		}
		local nullline "(line `y_null_line' `x_null_line', lpat(solid) lcol(black))"
		local dumplots "`dumplots'(line `y_null_line' `x_null_line', lpat(solid) lcol(black))"
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Null effect""'
	}
	
	/* Display y-line at pooled estimate of original meta-analysis */
	if "`nopooledline'"=="" & "`newstudytreatment'"=="" {
		tempvar y_pooled_est x_pooled_est
		range `y_pooled_est' `ymin' `ymax' 2
		gen `x_pooled_est' = `pooled_est' in 1/2
		if "`eform'"!="" {
			replace `x_pooled_est' = exp(`x_pooled_est')
		}
		local pooledline "(line `y_pooled_est' `x_pooled_est', lpat(dash) lcol(black))"
		local dumplots "`dumplots'(line `y_pooled_est' `x_pooled_est', lpat(dash) lcol(black))"
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Pooled effect""'
	}
	
	/* Show scatterplot of original study results on plot */
	if "`noscatter'"=="" {
		tokenize `varlist'
		if "`eform'"!="" {
			tempvar scat1
			gen `scat1' = exp(`1') if `touse'
			local scatterplot "(scatter `2' `scat1' if `touse', ms(o) mcol(black))"
			local dumplots "`dumplots'(scatter `2' `scat1' if `touse', ms(o) mcol(black))"
		}
		else {
			local scatterplot "(scatter `2' `1' if `touse', ms(o) mcol(black))"
			local dumplots "`dumplots'(scatter `2' `1' if `touse', ms(o) mcol(black))"
		}
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Study effects""'			
	}
	
	if "`loeline'"!="" {
		tempvar y_loe loe1 loe2
		range `y_loe' `ymin' `ymax' 2
		local loe11 : word 1 of `loe'
		gen `loe1' = `loe11' in 1/2
		local loe21 : word 2 of `loe'
		gen `loe2' = `loe21' in 1/2
		if "`eform'"!="" {
			replace `loe1' = exp(`loe1')
			replace `loe2' = exp(`loe2')
		}
		local loeline "(line `y_loe' `loe1', lpat(dot) lcol(black))"
		local dumplots "`dumplots'(line `y_loe' `loe1', lpat(dot) lcol(black))"
		local labnum `++labnum'
		local lab `"`lab' `labnum' "Limits of equivalence""'
		local loeline "`loeline' (line `y_loe' `loe2', lpat(dot) lcol(black))"
		local labnum `++labnum'
	}	
	

	/*****************************************************************************************************************************************************/
	/* CORE CONTOUR CALCULATIONS AND AREA GRAPH BUILDING */

	tokenize `varlist'																						/* re-tokenize varlist */

	noisily di 
	noisily di as txt "Building graph:"
	
	if "`noshading'"=="" & "`newstudytreatment'"=="" {

		if ("`method'"=="fixedi" & "`measure'"=="" & "`loe'"==""){												/* Fixed effects can probably be done better */
			
			*calculate weights
			tempvar weights weight_SS vwt c1SS c2SS
			gen double `weights' = 1/(`2'^2) if `touse'
			su `weights' if `touse', meanonly
			local sum_weights = `r(sum)'
			
			*Pre-calcs for formula
			gen double `weight_SS' = `weights'*`1' if `touse'
			su `weight_SS' if `touse', meanonly
			local sum_weights_SS = `r(sum)'
			gen double `vwt' = 1/(`tempseSS'^2)
			*Apply formulas
			gen double `c1SS' = (1/`vwt') * (`null' * (`sum_weights' + `vwt') - `sum_weights_SS' + `siglev'*(`sum_weights'+`vwt')^0.5)
			gen double `c2SS' = (1/`vwt') * (`null' * (`sum_weights' + `vwt') - `sum_weights_SS' - `siglev'*(`sum_weights'+`vwt')^0.5)
			
			********************************************************************************************************************
			*generate dummy repeat vectors for shaded areas (manipulation purposes)
			tempvar c1SS_2 c2SS_2 tempse1SS_2 tempse2SS_2
			gen double `c1SS_2' = `c1SS'
			gen double `c2SS_2' = `c2SS'
			gen double `tempse1SS_2' = `tempseSS'
			gen double `tempse2SS_2' = `tempseSS'
		
			********************************************************************************************************************
			***prepare c1SS_2 and c2SS_2 
			
				*append on end of c2SS_2 and tempse2SS_2 up to 4 coords.
				*(xmin,ymax) and (xmin,ymin)
			
					local N_1 	= _N
					local ext1 	= _N+1
					local ext2 	= _N+2
					local ext3 	= _N+3
					cap set obs `ext3'
					
					*Locals to find direction of contours
					local start_c1SS_2 	= `c1SS_2'[1]
					local end_c1SS_2 	= `c1SS_2'[`N_1']
					local start_c2SS_2 	= `c2SS_2'[1]
					local end_c2SS_2 	= `c2SS_2'[`N_1']
					
					*Right hand line swings right
					if (`end_c1SS_2' > `start_c1SS_2') {
									
						replace `c1SS_2'		= . if `c1SS_2'  < `xmin'
						replace `c1SS_2'		= . if `c1SS_2'	 > `xmax'
						replace `tempse1SS_2'	= . if `c1SS_2'	== .
						
						if (`tempse1SS_2'[`N_1']==`ymax') {
							replace `c1SS_2' 		= `xmax' in `ext1'
							replace `tempse1SS_2' 	= `ymax' in `ext1'
						}
						
						local area1 "(area `tempse1SS_2' `c1SS_2', col(`col2') fi(inten100))"
					
					}
					
					*Right hand swings left
					if (`end_c1SS_2' < `start_c1SS_2'){

						replace `c1SS_2'		=. if `c1SS_2' 	<  `xmin'
						replace `c1SS_2'		=. if `c1SS_2' 	>  `xmax'
						replace `tempse1SS_2'	=. if `c1SS_2'	== .

						if (`tempse1SS_2'[`N_1']==`ymax') {
							replace `c1SS_2' 		= `xmax' in `ext1'
							replace `tempse1SS_2' 	= `ymax' in `ext1'
						}
						else {
							replace `c1SS_2' 		= `xmin' in `ext1'
							replace `tempse1SS_2' 	= `ymax' in `ext1'
							replace `c1SS_2' 		= `xmax' in `ext2'
							replace `tempse1SS_2' 	= `ymax' in `ext2'
						}
						local area1 "(area `tempse1SS_2' `c1SS_2', col(`col2') fi(inten100))"

					}
					
					*Left hand line swings left 
					if (`end_c2SS_2' < `start_c2SS_2'){

						replace `c2SS_2'		= . if `c2SS_2'  < `xmin'
						replace `c2SS_2'		= . if `c2SS_2'  > `xmax'
						replace `tempse2SS_2'	= . if `c2SS_2' == .

						if (`tempse2SS_2'[`N_1']==`ymax'){
							replace `c2SS_2' = `xmin' in `ext1'
							replace `tempse2SS_2' = `ymax' in `ext1'
						}
						local area2 "(area `tempse2SS_2' `c2SS_2', col(`col3') fi(inten100))"

					}
					
					*Left hand swings right
					if (`end_c2SS_2' > `start_c2SS_2') {

						replace `c2SS_2'		=. if `c2SS_2'  < `xmin'
						replace `c2SS_2'		=. if `c2SS_2'  > `xmax'
						replace `tempse2SS_2'	=. if `c2SS_2' ==.

						if (`tempse2SS_2'[`N_1']==`ymax') {
							replace `c2SS_2' = `xmin' in `ext1'
							replace `tempse2SS_2' = `ymax' in `ext1'
						}
						else {
							replace `c2SS_2' 		= `xmax' in `ext1'
							replace `tempse2SS_2' 	= `ymax' in `ext1'
							replace `c2SS_2' 		= `xmin' in `ext2'
							replace `tempse2SS_2' 	= `ymax' in `ext2'						
						}
						local area2 "(area `tempse2SS_2' `c2SS_2', col(`col3') fi(inten100))"

					}
			if "`eform'"!="" {
				replace `c1SS_2' = exp(`c1SS_2')
				replace `c2SS_2' = exp(`c2SS_2')
			}		
		}
		else {
		
			*calculate weights
			tempvar weights
			gen `weights' = 1/((`2'^2)+`tau2') if `touse'
			
			local obs = (`cpoints'-1)*4
			cap set obs `obs'

			*re code into 4 coord format:
			tempvar newx newy mat_ind
			gen double `newx' 		= .
			gen double `newy' 		= .
			gen double `mat_ind' 	= 0

			*gen id variable, each id of length 4
			tempvar id tempind
			local obs1 = `cpoints'-1
			local obs2 = `obs1'-1
			
			gen `tempind' = _n<=`obs'
			egen double `id'=seq() if `tempind', from(1) to(`obs1') block(4)

			replace `newx' = `tempSS'[1] in 1/2
			replace `newx' = `tempSS'[2] in 3/4
			replace `newy' = `tempseSS'[1] in 1/4
			replace `newy' = `tempseSS'[2] in 2/3

			local add=4
			forvalues i = 1/`obs2' {

				local t1 = `i'+`add'
				local t2 = `i'+`add'+1
				local t3 = `i'+`add'+2
				local t4 = `i'+`add'+3

				local tt1=`i'+1
				local tt2=`i'+2
				replace `newx' = `tempSS'[`tt1'] in `t1'/`t4'
				replace `newx' = `tempSS'[`tt2'] in `t3'/`t4'
				replace `newy' = `tempseSS'[1] in `t1'/`t4'
				replace `newy' = `tempseSS'[2] in `t2'/`t3'

				local add =`add'+3
			}

			local varnames 

			forvalues j = 1/`obs1'{
				tempvar newy`j' matind`j'
				gen double `newy`j''=`tempseSS'[`j']
				gen `matind`j''		=.
				local j2 			= `j'+1
				replace `newy`j'' 	= `tempseSS'[`j2'] if `newy' == `tempseSS'[2]
				local varnames "`varnames' `matind`j''"													/* Variables to paste 0/1/... coding into */
			}
		
			if "`method'"=="randomi" | "`measure'"!="" | "`loe'"!="" {
				tokenize `varlist'
				replace `touse' = 0 if `1'==.
				replace `touse' = 0 if `2'==.
				mata: dl1mata("`1'","`2'","`method'","`touse'")													/* Execute mata program to conduct M-A's */
				if "`eform'"!="" {
					replace `newx' = exp(`newx')
				}
			}																							/* Returns matrix (as variables) of 0,1,2's to identify region */
			
			/*********** REFERENCE CODE **************/
			/*else {
				
				forvalues p=1/`obs1'{
					*first 2 and last 2
					local obs_minus1 = `obs'-1
					foreach s in 1 2 `obs_minus1' `obs' {
						qui replace `1' = `newx'[`s'] in `N_new'
						qui replace `2' = `newy`p''[`s'] in `N_new'
						
						metan `1' `2', `method' nograph notable
						
						local lci = `r(ES)'-`siglev'*`r(seES)'
						local uci = `r(ES)'+`siglev'*`r(seES)'
						if (`uci' < `null' & `lci' < `null') {
							replace `matind`p'' = 1 in `s'
						}
						* if stat. sig. > null
						else if (`lci' > `null' & `uci' > `null') {
							replace `matind`p'' = 2 in `s'
						}				
					}

					*remaining
					local tfinal = `obs'-5
					forvalues t = 3(4)`tfinal' {
						local tt2 = `t'+1
						local tt3 = `t'+2
						local tt4 = `t'+3
						qui replace `1' = `newx'[`t'] in `N_new'
						qui replace `2' = `newy`p''[`t'] in `N_new'
						
						metan `1' `2', `method' nograph notable
						
						local lci = `r(ES)'-`siglev'*`r(seES)'
						local uci = `r(ES)'+`siglev'*`r(seES)'
						if (`uci' < `null' & `lci' < `null') {
							replace `matind`p'' = 1 in `t'
							replace `matind`p'' = 1 in `tt4'
						}
						* if stat. sig. > null
						else if (`lci' > `null' & `uci' > `null') {
							replace `matind`p'' = 2 in `t'
							replace `matind`p'' = 2 in `tt4'
						}
						
						replace `1' = `newx'[`tt2'] in `N_new'
						replace `2' = `newy`p''[`tt2'] in `N_new'
						
						metan `1' `2', `method' nograph notable
						
						local lci = `r(ES)'-`siglev'*`r(seES)'
						local uci = `r(ES)'+`siglev'*`r(seES)'
						if (`uci' < `null' & `lci' < `null') {
							replace `matind`p'' = 1 in `tt2'/`tt3'
						}
						* if stat. sig. > null
						else if (`lci' > `null' & `uci' > `null') {
							replace `matind`p'' = 2  in `tt2'/`tt3'
						}
					}
				}	
			}*/
			
		/* Return matrices of effect estimates and standard errors */
		tempfile temp1
		save `temp1', replace
			tempvar tempind2 tempnew
			bys `id': gen `tempnew' = `matind`obs1''[2]
			local varnames "`varnames' `tempnew'"
			gen `tempind2' = _n==`obs'
			bys `id': keep if _n==1 | `tempind2'==1
			tempname indmat
			mkmat `varnames', matrix(`indmat') nomissing
			mat `indmat' = `indmat''
			return matrix status = `indmat'	
			
			
		use `temp1',clear
		
			*make four cells equal in matrix:	
			forvalues i=1/`obs1'{
				bys `id': replace `matind`i'' = `matind`i''[1] if (`matind`i''[1]!=`matind`i''[2] | `matind`i''[2]!=`matind`i''[3] | `matind`i''[3]!=`matind`i''[4] | `matind`i''[1]!=`matind`i''[2])
			}
			
			*Loop over newy's
			local area ""
			*replace matind1=1 if _n>4

			forvalues w=1/`obs1'{
	
				*w^th row: 1st colour section:
				local rowN = (`obs1'*4)
				local rowN2 = (`obs1'*4)-2
				local n1 = 1
				local n2 = 2
				local n3 = 3
				local ind1 = `matind`w''[1]
				local ind2 = `matind`w''[2]
				local i=3
				while `i'<`rowN2'{
					while `ind1'==`ind2' {
						local ind2	= `matind`w''[`i']
						local i		= `i'+1
														
						if (`i'==`rowN2') {
							continue, break
						}
					}
					continue, break
				}

				*First change in colour detected
				if (`i'!=`rowN2') {	
				
					***need to newy1 now, then do graph		
					*changes code at i-1
					local id1 = `i'-1 
					local id2 = `i'
					
					*index for replace with missing in first colour : 1+2 to new_start-3
					local miss_replace_end = `i'-4 
					local end = `i'-2
					
					if (`miss_replace_end'>3) {	/*If colour needs to change after first square*/				
						replace `newy`w'' = . in `n3'/`miss_replace_end'
					}
					
					*need to do graph colours as well
					
					if (power!=4) {
						if (`matind`w''[1]==1) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col3') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==2) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col2') fi(inten100))" /*first area*/
						}
					}
					else {
						if (`matind`w''[1]==2) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col2') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==3) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col3') fi(inten100))" /*first area*/
						}						
						else if (`matind`w''[1]==4) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col4') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==5) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col5') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==6) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col6') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==7) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col7') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==8) {
							local area "`area' (area `newy`w'' `newx' in 1/`end', nodropb col(`col8') fi(inten100))" /*first area*/
						}
					}
					
					**********************************************
					*w^th row: 2nd colour
					local ind1 = `matind`w''[`id1']
					local ind2 = `matind`w''[`id2']
					local n1 = `id1'
					local n2 = `id2'
					local n3 = `n2'+1
					
					local i = `n3'	
					while `i'<`rowN2' {
						while `ind1'==`ind2' {
							local ind2=`matind`w''[`i']
							local i=`i'+1
							if (`i'==`rowN2') {
								continue, break
							}
						}
						continue, break
					}
										
					while (`i'<`rowN2') {
						if (`i'!=`rowN2') {
							
							local id1 = `i'-1
							local id2 = `i'
							*2nd colour change detected
							*index rows to change to missing
							local missing_replace_end = `i'-4
							local end_new_section = `i'-2

							*edit newy`' if needed:
							if (`missing_replace_end'>`n3') {	
								replace `newy`w'' = . in `n3'/`missing_replace_end'
							}
							*exit							
							*colours
							if (power!=4) {
								if (`matind`w''[`n1']==1) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col3') fi(inten100))" /*second area*/
								}
								else if (`matind`w''[`n1']==2) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col2') fi(inten100))" /*second area*/
								}
							}
							else {
								if (`matind`w''[`n1']==2) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col2') fi(inten100))" /*first area*/
								}
								else if (`matind`w''[`n1']==3) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col3') fi(inten100))" /*first area*/
								}						
								else if (`matind`w''[`n1']==4) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col4') fi(inten100))" /*first area*/
								}
								else if (`matind`w''[`n1']==5) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col5') fi(inten100))" /*first area*/
								}
								else if (`matind`w''[`n1']==6) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col6') fi(inten100))" /*first area*/
								}
								else if (`matind`w''[`n1']==7) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col7') fi(inten100))" /*first area*/
								}
								else if (`matind`w''[`n1']==8) {
									local area "`area' (area `newy`w'' `newx' in `n1'/`end_new_section', nodropb col(`col8') fi(inten100))" /*first area*/
								}
							}
							
							**********************************************
							*w^th row: 3rd colour
							local ind1 = `matind`w''[`id1']
							local ind2 = `matind`w''[`id2']
							
							local n1 = `id1'
							local n2 = `n1'+1
							local n3 = `n2'+1

							local i = `n3'	
							while `i'<`rowN2'{
								while `ind1'==`ind2'{
									local ind2 	= `matind`w''[`i']
									local i		=`i'+1
									if (`i'==`rowN2'){
										continue, break
									}
								}
								continue, break
							}
						}
					}
					*colour is same for remainder of row
					if (`i'==`rowN2') {
						replace `newy`w'' = . in `n3'/`i'
						if (power!=4) {
							if (`matind`w''[`n1']==1) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col3') fi(inten100))"
							}
							else if (`matind`w''[`n1']==2) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col2') fi(inten100))"
							}
						}
						else {
							if (`matind`w''[`n1']==2) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col2') fi(inten100))"
							}
							else if (`matind`w''[`n1']==3) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col3') fi(inten100))" 
							}						
							else if (`matind`w''[`n1']==4) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col4') fi(inten100))" 
							}
							else if (`matind`w''[`n1']==5) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col5') fi(inten100))" 
							}
							else if (`matind`w''[`n1']==6) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col6') fi(inten100))"
							}
							else if (`matind`w''[`n1']==7) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col7') fi(inten100))"
							}
							else if (`matind`w''[`n1']==8) {
								local area "`area' (area `newy`w'' `newx' in `n1'/`obs', nodropb col(`col8') fi(inten100))"
							}
						}							
					}
				}
				*First colour is same for entire row:
				else {
					local miss_replace_end = `obs'-2
					replace `newy`w'' = . in 3/`i'
					if (power!=4) {
						if (`matind`w''[1]==1) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col3') fi(inten100))"
						}
						else if (`matind`w''[1]==2) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col2') fi(inten100))"
						}
					}
					else {
						if (`matind`w''[1]==2) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col2') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==3) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col3') fi(inten100))" /*first area*/
						}						
						else if (`matind`w''[1]==4) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col4') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==5) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col5') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==6) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col6') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==7) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col7') fi(inten100))" /*first area*/
						}
						else if (`matind`w''[1]==8) {
							local area "`area' (area `newy`w'' `newx' in 1/`obs', nodropb col(`col8') fi(inten100))" /*first area*/
						}
					}
				}

				/* BUG FIX - if colour change occurs in last square it is ignored above */
				local fix1 = `obs' - 4
				local fix2 = `obs' - 3
				if (`matind`w''[`fix1']!=`matind`w''[`fix2']) {
					tempvar n2ewy`w'
					gen `n2ewy`w'' 		= `newy`w''
					replace `n2ewy`w'' 	= `n2ewy`w''[`obs'] in `fix2'
					replace `n2ewy`w'' 	= `n2ewy`w''[`=`obs'-1'] in `=`fix2'+1'	
					if (power!=4) {
						if (`matind`w''[`obs']==1) {
							local area "`area' (area `n2ewy`w'' `newx' in `fix2'/`obs', nodropb col(`col3') fi(inten100))"
						}
						else if (`matind`w''[`obs']==2) {
							local area "`area' (area `n2ewy`w'' `newx' in `fix2'/`obs', nodropb col(`col2') fi(inten100))"
						}
						else {
							local area "`area' (area `n2ewy`w'' `newx' in `fix2'/`obs', nodropb col(`col1') fi(inten100))"
						}
					}
					else {
						if (`matind`w''[`obs']==2) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col2') fi(inten100))" 
						}
						else if (`matind`w''[`obs']==3) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col3') fi(inten100))"
						}						
						else if (`matind`w''[`obs']==4) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col4') fi(inten100))"
						}
						else if (`matind`w''[`obs']==5) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col5') fi(inten100))" 
						}
						else if (`matind`w''[`obs']==6) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col6') fi(inten100))" 
						}
						else if (`matind`w''[`obs']==7) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col7') fi(inten100))" 
						}
						else if (`matind`w''[`obs']==8) {
							local area "`area' (area `newy`w'' `newx' in `fix2'/`obs', nodropb col(`col8') fi(inten100))" 
						}
						else {
							local area "`area' (area `n2ewy`w'' `newx' in `fix2'/`obs', nodropb col(`col1') fi(inten100))"
						}
					}
				}
			}
		}
	}


	
	/*****************************************************************************************************************************************************/
	/* FINAL TWOWAY GRAPH */

	if ("`method'" == "fixedi" & "`measure'"=="" & "`loe'"==""){
		twoway `dumplots' (`addplot') `basearea' `area1' `area2' `line' `seagull' `predplot' `sumarea' ///	
		  `nullline' `pooledline' `scatterplot' (`addplot')	///
		, plotregion(margin(zero)) yscale(reverse) `explabel' xtitle(`xtitle') ytitle(`ytitle') ylabel(,angle(horizontal)) ///
		legend(order(`lab') symxsize(*0.6)) `xline' title("Contours for impact of a new study") ///
		`options'
	}
	else {
		twoway `dumplots' (`addplot') `basearea' `area' `line' `seagull' `predplot' `sumarea' ///
		   `nullline' `pooledline' `scatterplot' `loeline' (`addplot')	///
		, yscale(reverse) `explabel' plotregion(margin(zero)) xtitle(`xtitle') ytitle(`ytitle') ylabel(,angle(horizontal)) ///
		legend(order(`lab') symxsize(*0.6) `extraleg') `xline' title("Contours for impact of a new study") ///
		`options'
	}
	

restore
}
	
end

/* Stata command `range' + `double' in the generate statement */
program define range2 
        version 3.1
        if "`3'"=="" | "`5'"!="" { error 198 }
        confirm new var `1'
        if _N==0 { 
                if "`4'"=="" { error 198 } 
                set obs `4'
                local o "`4'"
        }
        else { 
                if "`4'"!="" { 
                        local o "`4'"
                        if `4' > _N { set obs `4' }
                }
                else    local o=_N
        }
        gen double `1'=(_n-1)/(`o'-1)*((`3')-(`2'))+(`2') in 1/`o'
end


/* Mata program to conduct random effects DerSimonian and Laird meta-analysis */
mata:
void dl1mata(string scalar ssvar, string scalar sevar, string scalar method, string scalar touse)
{

	nint = st_numscalar("contpoints")
	nintminus1 = nint:-1
	nint2 = nint:^2
	nstudies = st_numscalar("nstudies")
	siglevel = st_numscalar("siglev")
	null = st_numscalar("null")

	studies = st_data(.,ssvar,touse)'
	sterrors = st_data(.,sevar,touse)'

	origss_mat = J(nint2[1,1],1,studies)
	origse_mat = J(nint2[1,1],1,sterrors)

	setemp = rangen(st_numscalar("ymin"),st_numscalar("ymax"),nint)'		//row vectors
	sstemp = rangen(st_numscalar("xmin"),st_numscalar("xmax"),nint)'
	
	serep = J(nint,1,setemp')												//each y range repeated and put in column vector
	ssrep = J(1,cols(sstemp),sstemp[1,1])						
	for(i=2;i<=cols(setemp);i++){
		ssrep = ssrep,J(1,cols(sstemp),sstemp[1,i])
	}
	ssrep=ssrep'

	newss_mat = origss_mat,ssrep
	newse_mat = origse_mat,serep
	
	N=cols(newss_mat)														//no. of studies + new one
	weights = 1:/(newse_mat:^2)												//weights of each study
	sumweights = quadrowsum(weights)										//sum of weights for each M-A
	weights_times_ss = weights:*newss_mat
	sum_weights_times_ss = quadrowsum(weights_times_ss)						//sum of weights* ss
	fsum = sum_weights_times_ss:/sumweights
	ss_minus_fsum_2 = (newss_mat:-J(1,cols(newss_mat),fsum)):^2
	q = ss_minus_fsum_2:/(newse_mat:^2)
	Q = quadrowsum(q)
	df = N:-1
	weights2 = weights:^2
	sum_weights2 = quadrowsum(weights2)

	comp = (Q:-df):/(sumweights:-(sum_weights2:/sumweights))
	tau2 = J(nint2,1,0)

	for (i=1; i<=rows(comp); i++) {
		if (comp[i,1]>0){
			tau2[i,1]=comp[i,1]
		}
	}
	
	if (method=="fixedi") {
		wt = 1:/(newse_mat:^2)	
		v1 = wt:*wt:*(newse_mat:^2)
	}
	else {
		wt = 1:/((newse_mat:^2):+tau2)	
		v1 = wt:*wt:*((newse_mat:^2):+tau2)
	}
	
	wt_ss = wt:*newss_mat
	sum_wt_ss = rowsum(wt_ss)
	sum_wt = rowsum(wt)
	summ = sum_wt_ss:/sum_wt										//pooled estimate of each M-A
	sum_v1 = rowsum(v1)
	varsum = sum_v1:/(sum_wt:^2)									//variance of each M-A

	comb_ss_mat = J(nintminus1:*4,nintminus1,.)
	comb_var_mat = J(nintminus1:*4,nintminus1,.)

	//Build matrix of effect estimates

	index1 = 1
	index2 = nintminus1
	index3 = 2
	index4 = nint

	//first 2 rows:
	comb_ss_mat[1,(1::nintminus1)] = summ[(1::nintminus1),1]'
	comb_ss_mat[2,(1::nintminus1)] = summ[(2::nint),1]'
	comb_var_mat[1,(1::nintminus1)] = varsum[(1::nintminus1),1]'
	comb_var_mat[2,(1::nintminus1)] = varsum[(2::nint),1]'

	row1 = 3
	row2 = 4
	row3 = 5
	row4 = 6						//add 4
	sub1start = nint:+2				//12
	sub1end	  = nint:+nint			//20
	sub2start = nint:+1				//11
	sub2end   = nint:+nint:-1		//19
	
	for (i=1; i<=(nint:-2); i++) {
	
		comb_ss_mat[row1,(1::nintminus1)] = summ[(sub1start::sub1end),1]'
		comb_ss_mat[(row2::row3),(1::nintminus1)] = J(2,1,summ[(sub2start::sub2end),1]')
		comb_ss_mat[row4,(1::nintminus1)] = summ[(sub1start::sub1end),1]'

		comb_var_mat[row1,(1::nintminus1)] = varsum[(sub1start::sub1end),1]'
		comb_var_mat[(row2::row3),(1::nintminus1)] = J(2,1,varsum[(sub2start::sub2end),1]')
		comb_var_mat[row4,(1::nintminus1)] = varsum[(sub1start::sub1end),1]'

		row1 = row1:+4
		row2 = row2:+4
		row3 = row3:+4
		row4 = row4:+4
		
		sub1start = sub1start:+nint
		sub1end	  = sub1end:+nint
		sub2start = sub2start:+nint
		sub2end   = sub2end:+nint
	}
	//final 2 rows
	comb_ss_mat[row1,(1::nintminus1)] = summ[(sub1start::sub1end),1]'
	comb_ss_mat[row2,(1::nintminus1)] = summ[(sub2start::sub2end),1]'
	
	comb_var_mat[row1,(1::nintminus1)] = varsum[(sub1start::sub1end),1]'
	comb_var_mat[row2,(1::nintminus1)] = varsum[(sub2start::sub2end),1]'

	//indmat now contains effect estimates of all combinations of the coordinates.
	//need to do the same for the variance

	upp_ci_mat = comb_ss_mat:+J(nintminus1:*4,1,siglevel):*sqrt(comb_var_mat)
	low_ci_mat = comb_ss_mat:-J(nintminus1:*4,1,siglevel):*sqrt(comb_var_mat)
	mat012 = J(nintminus1:*4,nintminus1,0)
	
	pow = st_numscalar("power")
	
	if (pow==0) {
		for (i=1; i<=rows(comb_ss_mat); i++) {
			for (j=1; j<=cols(comb_ss_mat); j++) {
				if (upp_ci_mat[i,j]<null & low_ci_mat[i,j]<null) {
					mat012[i,j] = 1				
				}
				if (low_ci_mat[i,j]>null & upp_ci_mat[i,j]>null) {
					mat012[i,j] = 2
				}
			}
		}
	}
	else if (pow==1) {
		for (i=1; i<=rows(comb_ss_mat); i++) {
			for (j=1; j<=cols(comb_ss_mat); j++) {
				if (low_ci_mat[i,j]>=null) {
					mat012[i,j] = 1
				}
			}
		}	
	}
	else if (pow==2) {
		for (i=1; i<=rows(comb_ss_mat); i++) {
			for (j=1; j<=cols(comb_ss_mat); j++) {
				if (upp_ci_mat[i,j]>=null) {
					mat012[i,j] = 1
				}
			}
		}	
	}
	else if (pow==3) {
		ciwidths = upp_ci_mat :- low_ci_mat
		for (i=1; i<=rows(comb_ss_mat); i++) {
			for (j=1; j<=cols(comb_ss_mat); j++) {
				if (ciwidths[i,j]>=null) {
					mat012[i,j] = 1
				}
			}
		}
	}
	else if (pow==4) {
		loe1 = st_numscalar("loe1")
		loe2 = st_numscalar("loe2")	
		for (i=1; i<=rows(comb_ss_mat); i++) {
			for (j=1; j<=cols(comb_ss_mat); j++) {

				if (upp_ci_mat[i,j]>=null) {
					if (upp_ci_mat[i,j]<loe2) {
						if (low_ci_mat[i,j]<loe1) {
							mat012[i,j] = 1
						}					
					}
				}
				if (upp_ci_mat[i,j]>=loe2) {
					if (low_ci_mat[i,j]<loe1) {
						mat012[i,j] = 1
					}					
				}
				if (upp_ci_mat[i,j]>=loe2) {
					if (low_ci_mat[i,j]<null) {
						if (low_ci_mat[i,j]>=loe1) {
							mat012[i,j] = 1
						}					
					}
				}	
				
				if (upp_ci_mat[i,j]<null) {
					if (upp_ci_mat[i,j]>=loe1) {
						if (low_ci_mat[i,j]<loe1) {
							mat012[i,j] = 2
						}					
					}				
				}
				
				if (upp_ci_mat[i,j]>=loe2) {
					if (low_ci_mat[i,j]>=null) {
						if (low_ci_mat[i,j]<loe2) {
							mat012[i,j] = 3
						}					
					}				
				}				
				
				if (upp_ci_mat[i,j]<null) {
					if (low_ci_mat[i,j]>=loe1) {
						mat012[i,j] = 4
					}				
				}				
				
				if (low_ci_mat[i,j]>=null) {
					if (upp_ci_mat[i,j]<loe2) {
						mat012[i,j] = 5
					}				
				}				
				
				if (upp_ci_mat[i,j]>=null) {
					if (upp_ci_mat[i,j]<loe2) {
						if (low_ci_mat[i,j]>=loe1) {
							if (low_ci_mat[i,j]<null) {
								mat012[i,j] = 6
							}
						}					
					}				
				}			
				
				if (low_ci_mat[i,j]<loe1) {
					if (upp_ci_mat[i,j]<loe1) {
						mat012[i,j] = 7
					}				
				}				
				
				if (low_ci_mat[i,j]>=loe2) {
					if (upp_ci_mat[i,j]>=loe2) {
						mat012[i,j] = 8
					}				
				}				
				
			}
		}				
	}
	
	st_view(out=.,.,tokens(st_local("varnames")),st_local("tempind"))
	out[.,.] = mat012[.,.]

}

end




