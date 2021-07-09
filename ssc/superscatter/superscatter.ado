*! Beta version of Version 2.4 17Feb2019 Enhanced scatter plots	by Mead Over
*
* Implementation of combined scatter plot with bordered histograms in
*	as described in -help graph combine, Advanced-
*	See -help superscatter- for description of other enhancements, except...
*	. Option "box" added but undocumented.
*	. See bottom of this file for current status.
*
program define superscatter, rclass
version 11
syntax varlist(min=2 max=2 numeric) [if] [in] ///
	[, ///
	/* Combine: title  options */ TItle(passthru) SUBtitle(passthru) note(string asis) CAPtion(passthru) T1title(passthru) T2title(passthru) B1title(passthru) B2title(passthru) L1title(passthru) L2title(passthru) R1title(passthru) R2title(passthru) ///
	/* Combine: region options */ YSIZe(passthru) XSIZe(passthru) PLOTRegion(passthru) ///
	/* Combine: other options  */ iscale(passthru) altshrink COMmonscheme SCHeme(passthru) nodraw name(passthru) saving(passthru) ///
	/* Histogram type */ DENsity FRACtion FREQuency percent ///
	/* Histogram: barlook options */ COLor(passthru) FColor(passthru) FIntensity(passthru) LColor(passthru) LWidth(passthru) LPattern(passthru) LSTYle(passthru) BSTYle(passthru) PSTYle(passthru) ///
	/* Y-axis */ YSCale(string) YLABel(string asis) YTICk(passthru) YMLABel(passthru) YMTIck(passthru) YTItle(passthru) ///
	/* X-axis */ XSCale(string) XLABel(string asis) XTICk(passthru) XMLABel(passthru) XMTIck(passthru) XTItle(passthru) ///
	/* kdensity options */ KDENSity  KDXOPTions(string) KDYOPTions(string) ///
	/* line & tabulate options */ MEDians  MEANs TERciles QUARtiles DETail TABulate(string) TABFORmat(passthru) MATName(name) textplace(passthru) textsize(passthru) /// textplace = c,w,e,n,s
	* /// options passed to second syntax command
	]

//	Set aside the macros harvested by the syntax command before the options
local vlsttmp `varlist'
local iftmp `if'
local intmp `in'
	
local 0 , `options'

*	Don't need the following scatter options on the syntax command, 
*	because all unspecified options are passed through to the scatter plot.
*	/* Scatter symbol options */  MSymbol(passthru) MColor(passthru)  ///

syntax  /// 
	[,  ///
	/* scatter sampling options */ SAMPle(real 100)  ///
	/* fit type options */  FITType(string) FITOptions(string asis) ///
	/* ellipse options */  ELLipse  ESTAt(string) ELEVel(real 50) EPATtern(string) EColor(string) EWidth(string)  ///
	/* box-&-whisker options UNDOCUMENTED */  box  ///
	/* transformation options  */  sqrt log10plusone  log10pluszero ///
	/* superimpose a 45-degree line  */ LINE45 OPT45(string) TOLerance(real 0)  ///
	/* hilite options */ HILite(string asis) HILITEOptions(string) HIDe(string asis) ///
	* /// options passed to scatter command 
	]

//	Restore the macros harvested by the syntax command before the options
local varlist `vlsttmp'
local  if `iftmp'
local in `intmp'

*	Begin stacking the notes
if `"`note'"'~=""  {
	_parse comma lhs rhs : note
	if "`rhs'"=="" {
		local note1 `note'
	}
	else {
		local note1 `lhs'
		local noteops = substr(`"`rhs'"',2,.)
	}
}
	
* Set up program
tokenize `varlist'

* Histogram option
if "`histogram'" == "" local histogram "percent" // the default
else if (("`histogram'"!="density") | ("`histogram'"!="fraction") | ("`histogram'"!="frequency") | ("`histogram'"!="percent")) {
	di as error "hist(.) option is invalid. Choose hist({density | fraction | frequency | percent})"
	exit
	}

* Parse the {x|y}label options
foreach xy in x y {
	macro drop temp temp2 `xy'label_opt `xy'label_subopt
	local xylabel = `"``xy'label'"'
	gettoken (local) `xy'label_opt (local) temp : (local) xylabel , parse(",") quotes
	if `"``xy'label_opt'"'==","  { // No label options, only suboptions
		local `xy'label_opt
		local `xy'label_subopt `temp'
	}
	else if `"`temp'"' !="" {  // `xy'label_opt contains label options, now parse the suboptions
		gettoken (local) comma (local) temp2 : (local) temp , parse(",")
*		local `xy'label_subopt = substr("`temp2'",1,length("`temp2'")-1) // Removing last character chops off right parenthesis
		local `xy'label_subopt `temp2'
	}
}

*	Define the sample before the data transformations.
marksample touse 

*	Transform the axis scales using the sqrt or log10 transformations
*	(For the ln transformation, instead use the options -xscale(log)- and -xscale(log)-.)
if "`sqrt'`log10plusone'`log10pluszero'"~="" {
	if length("`sqrt'`logplusone'`logpluszero'")>10 {
		di as err "User may specify only one of the three options: sqrt, log10plusone or log10pluszero"
		di as err "Here the user has specified: " as res "`sqrt'"  "`log10plusone'"  "`log10pluszero'"
		exit 198
	}
	tempvar new1 new2
	qui clonevar `new1' = `1'
		local newlbl1 : var label `1'
		if `"`newlbl1'"'=="" label var `new1' "`1'"
	qui clonevar `new2' = `2'
		local newlbl2 : var label `2'
		if `"`newlbl2'"'=="" label var `new2' "`2'"
	if "`sqrt'"~="" {
		di _n as txt "Option -" as res "sqrt" as txt"- computes and plots the square roots of -" as res "`1'" as txt "- and of -" as res "`2'" as txt "-."  ///
			_n as txt "Any negative values are transformed to missing values and omitted from the graph."
		qui replace `new1' = sqrt(`1')  `if'  `in'
		qui replace `new2' = sqrt(`2')  `if'  `in'

		foreach xy in x y {
			local newvar = cond("`xy'"=="y","`new1'","`new2'")
			if `"``xy'label_opt'"'=="" {
				sum `newvar' if `touse' , meanonly 
				local rmin = floor(`r(min)')
				local rmax = ceil(`r(max)')
				local nintrvls = cond((`rmax'-`rmin')<2,2,min(5,ceil(`rmax'-`rmin'))) 
				local intrvl = floor((`rmax'-`rmin')/`nintrvls')
				local sqrtmax = `nintrvls'*`intrvl' + `rmin'
				foreach tick of numlist `rmin'(`intrvl')`sqrtmax'  {
					local sqrdtick = `tick'^2
					local sqrdtick : di %9.0fc `sqrdtick'
					local sqrdtick = strtrim("`sqrdtick'")
					local `xy'label_opt ``xy'label_opt' `tick' "`sqrdtick'"			
				}
				if length("`sqrdtick'")>6 & strpos("``xy'label_subopt'","labs")==0  {
					local `xy'label_subopt ``xy'label_subopt' labsize(small)
				}
				local `xy'label     `xy'label(``xy'label_opt',``xy'label_subopt')
			}
		}
	}
	if "`log10pluszero'"~="" | "`log10plusone'"~=""  {
		if "`log10plusone'"~="" {
			local plusone " + 1"
			local minusone " - 1"
			local note3 "To include zero values, 1.0 is added to both variables and subtracted from axis labels."
		}
		di _n as txt "Option -" as res "`log10plusone'`log10pluszero'" as txt "- computes and plots the logs of " as res "`1'`plusone'" as txt " and of " as res "`2'`plusone'" as txt " ."  ///
			_n as txt "Any non-positive values are transformed to missing values and omitted from the graph."
		qui replace `new1' = log10(`1' `plusone')  `if'  `in'
		qui replace `new2' = log10(`2' `plusone')  `if'  `in'
		foreach xy in x y {
			local newvar = cond("`xy'"=="y","`new1'","`new2'")
			if `"``xy'label_opt'"'=="" {
				sum `newvar' if `touse', meanonly
				local min = `r(min)'
				local rmin = floor(`r(min)')
				local rmax = ceil(`r(max)')
				local nintrvls = cond((`rmax'-`rmin')<2,2,min(5,ceil(`rmax'-`rmin'))) 
				local intrvl = floor((`rmax'-`rmin')/`nintrvls')
				local logmax = `nintrvls'*`intrvl' + `rmin'
				
				//	Accommodate values < 0 and > -1
				local negval				
				local negdis
				local neglbl
				if "`log10plusone'"~="" & 10^`rmin' - 1 <= 0 {
					local negval = log10(10^`min')
					local negdis = 10^`min' - 1
					local negdis : di %9.1fc `negdis'
					local negdis = strtrim("`negdis'")
					local neglbl  `negval' "`negdis'"
					local `xy'label_opt `negval' "`negdis'"
				}

				foreach pwr of numlist `rmin'(`intrvl')`logmax'  {
				

*					local pwrplot = cond("`log10plusone'"~="" & `pwr'==0, 0, log10(10^`pwr' `plusone'))
*					local ten2pwr = cond("`log10plusone'"~="" & `pwr'==0, 0, 10^`pwr')

					local pwrplot = log10(10^`pwr' `plusone')
					local ten2pwr = 10^`pwr'
					local digits  = cond(`ten2pwr'<1, 1, 0)
					local ten2pwr : di %9.`digits'fc `ten2pwr'
					local ten2pwr = strtrim("`ten2pwr'")
					local `xy'label_opt ``xy'label_opt' `pwrplot' "`ten2pwr'"			
				}
				if length("`ten2pwr'")>6 & strpos("``xy'label_subopt'","labs")==0  {
					local `xy'label_subopt ``xy'label_subopt' labsize(small)
				}
				local `xy'label `xy'label(``xy'label_opt', ``xy'label_subopt')
			}
		}
	}
	local 1 `new1'
	local 2 `new2'
	local varlist `1' `2'

	//	Define the sample after any data transformations.
	tempvar firsttouse 
	clonevar `firsttouse' = `touse'
		lab var `firsttouse' "Sample prior to transformations"
	capture label drop touse
	markout `touse' `varlist' 
		lab var `touse' "Sample used to construct scatter plot"
		lab define touse 0 "Not used" 1 "Used"
		lab values `firsttouse' touse
		lab values `touse' touse
		
	capture assert `firsttouse' == `touse'
	if _rc ==0 {
		di _n as txt "The " as res "`sqrt'`log10plusone'`log10pluszero'" as txt " transformation of both variables has not changed the sample used in the scatter plot."
	}
	else {
		di _n as txt "The " as res "`sqrt'`log10plusone'`log10pluszero'" as txt " transformation of both variables has altered the sample used in the scatter plot as follows."
	}
	tab `firsttouse' `touse', mi
}
	

* Add a fitted line with or w/o a confidence interval to the scatter plot
if "`fittype'"~="" {
	local fitplot `fittype' `varlist' if `touse' , `fitoptions' ||
	if strpos("`fittype'","ci")>0 {
		local eorder 4
	}
	else {
		local eorder 3
	}
}

* Add a 45 degree line to the scatter plot
if "`line45'"~="" {
	sum `1' if `touse', meanonly
		local min1 `r(min)'
		local max1 `r(max)'
		local mean1 `r(mean)'
	sum `2' if `touse', meanonly
		local min2 `r(min)'
		local max2 `r(max)'
		local mean2 `r(mean)'
	local min45 = 1.01*max(`min1', `min2')
	local max45 = 0.99*min(`max1', `max2')
	local line45plot line `2' `2' if `touse' & `2'>`min45' & `2'<`max45', `opt45' ||
/*
*	The -function- graph type doesn't work unless its y-axis is matched to other graphs
	local min45 = 1.01*min(`min1', `min2')
	local max45 = 0.99*max(`max1', `max2')
	local line45plot function y=x, range(`min45' `max45') `opt45' ||
*/
	
	if `tolerance' > 0  {  // Default value is zero
		local meanofmeans = (`mean1' + `mean2')/2
		local tolaspct = `tolerance' * `meanofmeans'
			local toltxt : di %8.5f `tolaspct'
		local degree = ustrunescape("\u00B0")  // The unicode string for "degree"
		tempvar diffrom45
		qui gen double `diffrom45' = `1' - `2'
			qui count if `diffrom45' >=.
				local nmsng = `r(N)'  // Number missing
			qui count if abs(`diffrom45') > `tolaspct' & `diffrom45' < .
				local ngttol = `r(N)'  // Number of obs with distance at least the tolerance
			qui count if abs(`diffrom45') <= `tolaspct' & `diffrom45' < .
				local nletol = `r(N)'  // Number of obs with distance less than or equal to  the tolerance
			local totobs   = `ngttol' + `nletol' + `nmsng'
			local totnmsng = `ngttol' + `nletol'
			
		di as txt "Of the " as res "`totnmsng'" as txt " observations on which neither variable is missing"  ///
			_n as res "`nletol'" as txt " observations are closer to the 45`degree' line than the tolerance of " as res `tolaspct' /// 
			_n as txt "and " as res "`ngttol'" as txt " are farther from the line than the tolerance."  ///
			_n as txt "The tolernce is computed as " as res "`tolerance'" as txt " multiplied times the average of the means of the two variables"
				

		local note2 "`ngttol' of the `totnmsng' joint observations are farther than `toltxt' units from the 45`degree' line"

	}
}

* Hilite a subset of the points defined by the condition in hilite option
if "`hilite'"~="" {
	if "`hiliteoptions'"=="" {
		local hiliteoptions msym(X) msize(vlarge)
	}
	local hiliteplot scatter `1' `2' if `touse' & `hilite', `hiliteoptions' ||
}
* Hide a subset of the points defined by the condition in hide option
if "`hide'"~="" {
	local hide & ~( `hide' )
}

* Locals to save graphs temporarily
tempname gxy ghy ghx

*	
if "`matname'"~="" {
	local matnameoption matname(`matname')
}

*	Implement -detail- option
*	(It is documented in scatter_hist.sthlp, but not implemented in scatter_hist.ado)
if "`detail'"~="" {
	local shhh
}
else {
	local shhh quietly
}

* For the ellipse, compute the means, sds and r of x and y
if "`ellipse'"~="" {
	local xy y   // First of two variables is y, 2nd is x
	foreach var of varlist `varlist' {
		qui summ `var' if `touse' 
		local m_`xy' = r(mean)
		local s_`xy' = sqrt(r(Var))
		local xy x   // First of two variables is y, 2nd is x
		local xvar `var'
	}
	qui corr `varlist' if `touse' 
	local rho = r(rho)

	if "`epattern'"=="" {
		local epattern solid
	}
	if "`ecolor'"=="" {
		local elcolor
	}
	else {
		local elcolor lcolor(`ecolor')
	}
	if "`ewidth'"=="" {
		local elwidth
	}
	else {
		local elwidth lwidth(`ewidth')
	}
	if "`estat'"=="" {
		local estat Fstat
	}
	*	Numerator degrees of freedom
	local ndf = 2
	*	Denominator degrees of freedom
	qui count if `touse'
	local N = r(N)
	local ddf = `N' - 2
	if `elevel'>=100 | `elevel' <=0  {
		di as err "Option elevel must be between zero and 100" ///
			_n "Here it is: " as res "`elevel'"
		exit 198
	}
	local siglevel = (100 - `elevel')/100

	if substr(lower("`estat'"),1,3)=="chi" {
		local critval = invchi2tail(`ndf',`siglevel')
	}
	else {
		if substr(lower("`estat'"),1,1)=="f" {
			local critval = invFtail(`ndf',`ddf',`siglevel')
		}
		else {
			di as err "The option estat must be either " as res "Chi2" as err " or " as res "F"  ///
				_n "Here it is: " as res "`estat'"
			exit 198
		}
	}
	
	if "`legend'"=="" | "`legend'"=="off" {
		if "`eorder'"=="" {
			local eorder 1
		}
		local elegend legend(order(`eorder' "`elevel'% Confidence ellipse") ring(0) cols(1) pos(5)) 
	}

	local ellipseplot ///
		function y = ///
			`s_y'*sqrt((1 - `rho'^2))* sqrt((`critval' - ((x - `m_x')/`s_x')^2)) ///
			+ (x - `m_x')/`s_x'*`rho'*`s_y' + `m_y'  ,  ///
			range(`xvar') n(10000)  `elcolor' `elwidth' lstyle(`epattern') ||  ///
		function y = ///
			- `s_y'*sqrt((1 - `rho'^2))* sqrt((`critval' - ((x - `m_x')/`s_x')^2)) ///
			+ (x - `m_x')/`s_x'*`rho'*`s_y' + `m_y'  ,  ///
			range(`xvar')  n(10000) `elcolor' `elwidth' lstyle(`epattern') `elegend' ||
}

* Compute the centiles of x and y
if "`medians'`means'`terciles'`quartiles'"~="" {
	if "`tabulate'"~="" {
		tempname catlbl catlbl2 catlbl3 catlbl4
		label define `catlbl' 0 "Below average" 1 "Above average" 
		label define `catlbl2' 0 "1st 50%" 1 "2nd 50%" 
		label define `catlbl3' 0 "1st Tercile" 1 "2nd Tercile" 2 "3rd Tercile" 
		label define `catlbl4' 0 "1st Quartile" 1 "2nd Quartile" 2 "3rd Quartile" 3 "4th Quartile"
	}
	local xy y   // First of two variables is y, 2nd is x
	foreach var of varlist `varlist' {
		tempvar `xy'cat `xy'cat2 `xy'cat4
		if "`terciles'"~="" {
			tempvar `xy'cat3 
		}
		local `xy'linesopt `xy'lines(
		local vlbl : variable label `var'
		`shhh' di _n as txt "Summary statistics on the variable: " as res "`vlbl'"
		`shhh' sum `var' if `touse', detail
		local `xy'_min = r(min)
		local `xy'_mean = r(mean)
		local `xy'_1quart = r(p25)
		local `xy'_2quart = r(p50)
		local `xy'_3quart = r(p75)
		local `xy'_max = r(max)
		if "`terciles'" ~="" {
			`shhh' di _n as txt "Tercile boundaries on the variable: " as res "`vlbl'"
			`shhh' centile `var' if `touse', c(33.3333 66.6667)  
			local `xy'_1ter = r(c_1)
			local `xy'_1ter_opt `xy'_1ter(``xy'_1ter') 
			local `xy'_2ter = r(c_2)
			local `xy'_2ter_opt `xy'_2ter(``xy'_2ter') 
		}
		if "`tabulate'"~="" {  // V. 1.6: From end of -irecode()-, replace ",.)" with if `touse'
			qui gen byte ``xy'cat' = irecode(`var',``xy'_mean') if `touse'
				label var ``xy'cat'  `"`var' <= or > mean"'
				label values ``xy'cat' `catlbl'
			qui gen byte ``xy'cat2' = irecode(`var',``xy'_2quart') if `touse'
				label var ``xy'cat2'  `"`var' <= or > median"'
				label values ``xy'cat2' `catlbl2'
			qui gen byte ``xy'cat4' = irecode(`var',``xy'_1quart',``xy'_2quart',``xy'_3quart') if `touse'
				label var ``xy'cat4'  `"`var' by quartile"'
				label values ``xy'cat4' `catlbl4'
			if "`terciles'" ~="" {
				qui gen byte ``xy'cat3' = irecode(`var',``xy'_1ter',``xy'_2ter = r(c_2)') if `touse'
					label var ``xy'cat3'  `"`var' by tercile"'
					label values ``xy'cat3' `catlbl3'
			}
		}

		if "`means'"~="" {
			local `xy'linesopt ``xy'linesopt' ``xy'_mean'
		}
		if "`medians'"~="" {
			local `xy'linesopt ``xy'linesopt' ``xy'_2quart'
		}
		if "`terciles'" ~="" {
			local `xy'linesopt ``xy'linesopt' ``xy'_1ter'
			local `xy'linesopt ``xy'linesopt' ``xy'_2ter'
		}
		if "`quartiles'"~="" {
			local `xy'linesopt ``xy'linesopt' ``xy'_1quart'
			local `xy'linesopt ``xy'linesopt' ``xy'_2quart'
			local `xy'linesopt ``xy'linesopt' ``xy'_3quart'
		}
		
		local `xy'linesopt ``xy'linesopt' )
		local xy x   // First of two variables is y, 2nd is x
	}

	if "`tabulate'"~="" {
		_scattertab `ycat' `xcat' `ycat2' `xcat2' `ycat3' `xcat3' `ycat4' `xcat4'  if `touse',  ///
			`medians' `means' `terciles' `quartiles' tabulate(`tabulate')  `tabformat' `shhh'  ///
			y_min(`y_min') y_mean(`y_mean')  y_1quart(`y_1quart') y_2quart(`y_2quart') y_3quart(`y_3quart') y_max(`y_max')  ///
			x_min(`x_min') x_mean(`x_mean')  x_1quart(`x_1quart') x_2quart(`x_2quart') x_3quart(`x_3quart') x_max(`x_max')  ///
			`y_1ter_opt' `y_2ter_opt' `x_1ter_opt' `x_2ter_opt' `textplace' `textsize' `matnameoption'

		if "`matname'"~="" {
			mat define `matname' = r(`matname')
		}
		local cells2text `r(cells2text)'
		qui count if `touse'
		if "`tabulate'"=="count" {
			local note4 "Cell counts add to the total number of observations: N = `r(N)'"
		}
		if "`tabulate'"=="row" {
			local note4 "Percentages add to 100% across each row of cells defined by `means'`medians'`terciles'`quartiles'"
		}
		if "`tabulate'"=="col" {
			local note4 "Percentages add to 100% down each column defined by `means'`medians'`terciles'`quartiles'"
		}
		if "`tabulate'"=="cell" {
			local note4 "Percentages add to 100% of the N = `r(N)' observations over all cells defined by `means'`medians'`terciles'`quartiles'"
		}
	}
}
else {   //  "`means'`medians'`terciles'`quartiles'"==""
	if "`detail'" ~="" {
		foreach var of varlist `varlist' {
			sum `var' if `touse', detail
		}
	}
	if "`tabulate'"~=""{
		di as err _n "The -tabulate()- option requires specifying one of the following grid options:" ///
			_n "    means, medians, terciles or quartiles."
		error 198
	}
}

* Enable substitution of a kernel density for a histogram
if "`kdensity'`box'"=="" {
	local densgph histogram
	if `"`kdxoptions'`kdyoptions'"'~="" {
		di _n as err "The options: " as res `"`kdxoptions'"' as txt " and " as res `"`kdyoptions'"'  ///
			_n as err "are ignored because the option - kdensity - is not specified."  ///
			_n "Execution continuing with histograms on the borders of the scatter plot." _n
		local kdxoptions
		local kdyoptions
	}
}
if "`kdensity'"~="" {
	local densgph kdensity
	if strpos(`"`kdyoptions'"',"xti")==0 {
		local kdeny_xtitle xtitle("Density")
	}
	if strpos(`"`kdyoptions'"',"yti")==0 {
		local ylbl : variable label `1'
		if trim("`ylbl'")~="" {
			local kdeny_ytitle ytitle(`"`ylbl'"')
		}
		else {
			local kdeny_ytitle ytitle(`"`1'"')
		}
	}
	if strpos(`"`kdxoptions'"',"yti")==0 {
		local kdenx_ytitle ytitle("Density")
	}
	if strpos(`"`kdxoptions'"',"xti")==0 {
		local xlbl : variable label `2'
		if trim("`xlbl'")~="" {
			local kdenx_xtitle xtitle(`"`xlbl'"')
		}
		else {
			local kdenx_xtitle xtitle(`"`2'"')
		}
	}
	if "`lwidth'"=="" {
		local lwidth lwidth(thick)
	}
}

*	Plot only a random sample of points on scatter plot
if `sample'>100 | `sample'<0 {
	di as err _n "The option -sample()- must be a percenatge between zero and 100."
	error 198
}
if `sample'<100 {
	local note5 "Scatter plot displays `sample'% of observations"
	di as txt _n "Scatter plot displays a random sample of "  ///
		as res "`sample'" as txt " percentage of the observations"
	local sample = `sample'/100
	
	tempvar tousesmpl
	qui gen byte `tousesmpl' = uniform()<= `sample'  if `touse'
	local touseplus & `tousesmpl'
	if "`yscale'"=="" {
		sum `1' if `touse', meanonly
		local yscale range(`r(min)' `r(max)')
	}
	if "`xscale'"=="" {
		sum `2' if `touse', meanonly
		local xscale range(`r(min)' `r(max)')
	}
}

*	Add x- and y-titles 
if `"`ytitle'"'=="" {
	local ylblorig : variable label `1'
	if `"`ylblorig'"'~="" {
		local ytitle ytitle("`ylblorig'")
	}
	else {
		local ytitle ytitle("`1'")
	}
}
if `"`xtitle'"'=="" {
	local xlblorig : variable label `2'
	if `"`xlblorig'"'~="" {
		local xtitle xtitle(`"`xlblorig'"')
	}
	else {
		local xtitle xtitle(`"`2'"')
	}
}

* Scatter Plot
graph twoway `hiliteplot' `line45plot' `fitplot' `ellipseplot' ///
		scatter `1' `2' if `touse' `touseplus' `hide', `mcolor' `msymbol' `options' ///
		yscale(alt `yscale') ylabel( `ylabel_opt', `ylabel_subopt' )          `ytick' `ymlabel' `ymtick' `ytitle'  ///
		xscale(alt `xscale') xlabel( `xlabel_opt', `xlabel_subopt' grid gmax) `xtick' `xmlabel' `xmtick' `xtitle'  ///
		name(`gxy') nodraw `xlinesopt' `ylinesopt' `xrange' `yrange' `cells2text' plotregion(lcolor(black))

* X-axis histogram or kernel density
if "`box'"==""{
	twoway `densgph' `2' if `touse', ///
			`density' `fraction' `frequency' `percent' `color' `fcolor' `fintensity'  ///
			`lcolor' `lwidth' `lpattern' `lstyle' `bstyle' `pstyle' ///	
			ylabel(#3,nogrid `ylabel_subopt') yscale(alt reverse) ///
			xlabel( `xlabel_opt', `xlabel_subopt' grid gmax) xsca(`xscale') `xtick' `xmlabel' `xmtick' `xtitle' ///
			fysize(20) name(`ghx') nodraw `xlinesopt' `kdenx_ytitle' `kdenx_xtitle' `kdxoptions' plotregion(lcolor(black))
}
else {
	//  In Stata, the horizontal axis of "gr hbox" is the "y axis".
	//	Therefore, with the box option, the x-axis options must be transformed to y-axis options
	foreach opt in xlinesopt xtick xmlabel xmtick xtitle {
		if `"``opt''"'~="" {
			local `opt' = subinstr(`"``opt''"',"x","y",1)
		}
	}
	gr hbox `2' if `touse', ///  
			`color' `fcolor' `fintensity'  ///
			`lcolor' `lwidth' `lpattern' `lstyle' `bstyle' `pstyle' ///	
			ylabel( `xlabel_opt', `xlabel_subopt' grid gmax) ysca(`xscale') `xtick' `xmlabel' `xmtick' `xtitle' /// (box has no x-axis)
			fysize(20) fxsize(68) name(`ghx') nodraw `xlinesopt'   ///
			graphregion(margin(l=0 r=1 t=1 b=1)) r1title("Box") plotregion(lcolor(black))

}

* Y-axis histogram or kernel density 
if "`box'"==""{
	twoway `densgph' `1' if `touse', ///
			`density' `fraction' `frequency' `percent' horiz `color' `fcolor' `fintensity'  ///
			`lcolor' `lwidth' `lpattern' `lstyle' `bstyle' `pstyle' ///
			xlabel(#3,nogrid `xlabel_subopt') xscale(alt reverse)   ///
			ylabel( `ylabel_opt', `ylabel_subopt') yscale(`yscale') `ytick' `ymlabel' `ymtick' `ytitle' /// 
			fxsize(20) name(`ghy') nodraw `ylinesopt' `kdeny_xtitle' `kdeny_ytitle' `kdyoptions' plotregion(lcolor(black))
}
else {
	gr box `1' if `touse',  ///
			`color' `fcolor' `fintensity'  ///
			`lcolor' `lwidth' `lpattern' `lstyle' `bstyle' `pstyle' ///	
			`ylabel' yscale(`yscale') `ytick' `ymlabel' `ymtick' `ytitle' ///
			fxsize(20) fysize(68) name(`ghy') nodraw `ylinesopt'  ///
			graphregion(margin(l=1 r=1 t=1 b=0)) t1title("Box") plotregion(lcolor(black))
}

*	Stack the notes
foreach i of numlist 1/6 {
	if `"`note`i''"'~="" {
		local note`i' `""`note`i'' ""'
	}
}

* Combined graphs
graph combine `ghy' `gxy' `ghx', hole(3) col(2)  /// 
		imargin(0 0 0 0) graphregion(margin(l=22 r=22))  ///
		note(`note1' `note2' `note3' `note4' `note5' `note6', `noteops'	)  ///
		`iscale' `altshrink' `commonscheme' `scheme' `nodraw' `name' `saving' ///
		`title' `subtitle' `caption' `t1title' `t2title' `b1title'  ///
		`b2title' `l1title' `l2title' `r1title' `r2title' ///
		`ysize' `xsize'  `plotregion'
 
 * Store and return some results
	return local cells2text `cells2text'
	if "`matname'"~="" {
		return matrix `matname' = `matname'
	}
	if "`ellipse'"~="" {
		return scalar  critval = `critval'
		return scalar  elevel = `elevel'
		return local  estat " `estat'"
		return scalar  rho = `rho'
		return scalar  y_mean = `m_y'
		return scalar  y_sd = `s_y'
		return scalar  x_mean = `m_x'
		return scalar  x_sd = `s_x'
		return scalar  ndf = `ndf'
		return scalar  ddf = `ddf'
		return scalar  N = `N'
	}
end  //  End of program superscatter

program define _scattertab, rclass
	version 11.0
		syntax varlist (min=6 max=8 numeric) [if] , tabulate(string)   ///
			y_min(real) y_mean(real)  y_1quart(real) y_2quart(real) y_3quart(real) y_max(real) ///
			x_min(real) x_mean(real)  x_1quart(real) x_2quart(real) x_3quart(real) x_max(real) ///
			[medians means terciles quartiles  matname(name) quietly tabformat(string) textplace(string) textsize(string)  ///
			y_1ter(real -99999) y_2ter(real -99999) x_1ter(real -99999) x_2ter(real -99999) ]

		marksample touse

		if "`means'`medians'`terciles'`quartiles'"==""{
			di as err _n "The -tabulate()- option requires specifying one of the following grid options:" ///
				_n "    means, medians, terciles or quartiles."
			error 198
		}
		else {
			di as txt _n "Tabulate option selected with categories defined by "  ///
				as res "`medians'`means'`terciles'`quartiles'"
		}
		if "`matname'"~="" {
			di as txt _n "Cell contents stored in the matrix: " as res "`matname'"
		}
		if "`tabulate'"~="row" & "`tabulate'"~="col" & "`tabulate'"~="cell" & "`tabulate'"~="count" {
			di as err _n "The -tabulate()- option must specify one of the following types of cell content:" ///
				_n "    row, col, cell or count.  Here the option contains the string: " as res "`tabulate'"
			error 198
		}
		if "`tabulate'"=="count" {
			local tabopt
			local calcopt count
*			local dfltfrmt %9.1gc  // ver. 2.3
			local dfltfrmt %~15s   // commas desireable?
			di as txt _n "Tabulate option " as res "-count-" ///
				as txt " specifies each grid cell in the scatter plot contain its observation count"
		}
		else {
			local tabopt `tabulate'
			local calcopt `tabulate'
*			local dfltfrmt %5.1f  // ver. 2.3
			local dfltfrmt %4.1f
			di as txt _n "Tabulate option -" as res "`tabulate'" ///
				as txt "- specifies each grid cell in the scatter plot contain its `tabulate' percentage"
		}
		if "`textplace'"~="" {
			local textplace placement(`textplace')
		}
		if "`textsize'"~="" {
			local textsize size(`textsize')
		}
		
		local nstatopt = wordcount(`" `means' `medians' `terciles' `quartiles' "')
		if `nstatopt' > 1 {
			di as err _n "Only one of the options means, medians, terciles or quartiles can be specified"
			error 1003
		}
		if "`terciles'"~="" {
			tempname       ycat xcat ycat2 xcat2 ycat3 xcat3 ycat4 xcat4 tmpmatname
			local namelist ycat xcat ycat2 xcat2 ycat3 xcat3 ycat4 xcat4
		}
		else {
			tempname       ycat xcat ycat2 xcat2 ycat4 xcat4 tmpmatname
			local namelist ycat xcat ycat2 xcat2 ycat4 xcat4
		}
		local i = 1
		foreach var of varlist `varlist' {
			local newname : word `i' of `namelist'
			rename `var' ``newname''
			local i = `i' + 1
		}
		if "`matname'"=="" {
			local cellcontents `tmpmatname'
		}
		else {
			local cellcontents `matname'
		}
		if "`tabformat'"=="" {
			local tabformat `dfltfrmt'
		}
		if "`means'"~="" {
			`quietly' tab `ycat' `xcat' if `touse', `tabopt' matcell(`cellcontents')
			_calcsub , matname(`cellcontents') tabopt(`calcopt') total(`r(N)') nrows(`r(r)')
			local pctsign `r(pctsign)'
			mat define `cellcontents' = r(cellcontents)
			local steps min mean max
			foreach i of numlist 1/2 {
				local start : word `i' of `steps'
				local ip1 = `i' + 1
				local end : word `ip1' of `steps'
				local ymidpt = `y_`start'' + (`y_`end'' - `y_`start'')/2
				local ymidpts `ymidpts' `ymidpt'
				local xmidpt = `x_`start'' + (`x_`end'' - `x_`start'')/2
				local xmidpts `xmidpts' `xmidpt'
			}
			local cells2text
			foreach i of numlist 1/2 {
				foreach j of numlist 1/2 {
					local ycoord : word `i' of `ymidpts'
					local xcoord : word `j' of `xmidpts'
					local number = string(`cellcontents'[`i',`j'])
					local number: display `tabformat' `number'
					local cells2text `cells2text' text(`ycoord' `xcoord' "`number'`pctsign'", `textplace' `textsize')
				}
			}
		}
		if "`medians'"~="" {
			`quietly' tab `ycat2' `xcat2' if `touse', `tabopt' matcell(`cellcontents')
			_calcsub , matname(`cellcontents') tabopt(`calcopt') total(`r(N)') nrows(`r(r)')
			local pctsign `r(pctsign)'
			mat define `cellcontents' = r(cellcontents)
			local steps min 2quart max
			foreach i of numlist 1/2 {
				local start : word `i' of `steps'
				local ip1 = `i' + 1
				local end : word `ip1' of `steps'
				local ymidpt = `y_`start'' + (`y_`end'' - `y_`start'')/2
				local ymidpts `ymidpts' `ymidpt'
				local xmidpt = `x_`start'' + (`x_`end'' - `x_`start'')/2
				local xmidpts `xmidpts' `xmidpt'
			}
			local cells2text
			foreach i of numlist 1/2 {
				foreach j of numlist 1/2 {
					local ycoord : word `i' of `ymidpts'
					local xcoord : word `j' of `xmidpts'
					local number = string(`cellcontents'[`i',`j'])
					local number: display `tabformat' `number'
					local cells2text `cells2text' text(`ycoord' `xcoord' "`number'`pctsign'", `textplace' `textsize')
				}
			}
		}
		if "`terciles'"~="" {
			`quietly' tab `ycat3' `xcat3' if `touse', `tabopt' matcell(`cellcontents')
			_calcsub , matname(`cellcontents') tabopt(`calcopt') total(`r(N)') nrows(`r(r)')
			local pctsign `r(pctsign)'
			mat define `cellcontents' = r(cellcontents)
			local steps min 1ter 2ter max
			foreach i of numlist 1/3 {
				local start : word `i' of `steps'
				local ip1 = `i' + 1
				local end : word `ip1' of `steps'
				local ymidpt = `y_`start'' + (`y_`end'' - `y_`start'')/2
				local ymidpts `ymidpts' `ymidpt'
				local xmidpt = `x_`start'' + (`x_`end'' - `x_`start'')/2
				local xmidpts `xmidpts' `xmidpt'
			}
			local cells2text
			foreach i of numlist 1/3 {
				foreach j of numlist 1/3 {
					local ycoord : word `i' of `ymidpts'
					local xcoord : word `j' of `xmidpts'
					local number = string(`cellcontents'[`i',`j'])
					local number: display `tabformat' `number'
					local cells2text `cells2text' text(`ycoord' `xcoord' "`number'`pctsign'", `textplace' `textsize')
				}
			}
			
		}
		if "`quartiles'"~="" {
			`quietly' tab `ycat4' `xcat4' if `touse', `tabopt' matcell(`cellcontents')
			_calcsub , matname(`cellcontents') tabopt(`calcopt') total(`r(N)') nrows(`r(r)')
			local pctsign `r(pctsign)'
			mat define `cellcontents' = r(cellcontents)
			local steps min 1quart 2quart 3quart max
			foreach i of numlist 1/4 {
				local start : word `i' of `steps'
				local ip1 = `i' + 1
				local end : word `ip1' of `steps'
				local ymidpt = `y_`start'' + (`y_`end'' - `y_`start'')/2
				local ymidpts `ymidpts' `ymidpt'
				local xmidpt = `x_`start'' + (`x_`end'' - `x_`start'')/2
				local xmidpts `xmidpts' `xmidpt'
			}
			local cells2text
			foreach i of numlist 1/4 {
				foreach j of numlist 1/4 {
					local ycoord : word `i' of `ymidpts'
					local xcoord : word `j' of `xmidpts'
					local number = string(`cellcontents'[`i',`j'])
					local number: display `tabformat' `number'
					local cells2text `cells2text' text(`ycoord' `xcoord' "`number'`pctsign'", `textplace' `textsize')
				}
			}
			
		}
*		di "Mid points for y are: " as res "`ymidpts'"
*		di "Mid points for x are: " as res "`xmidpts'"
		
		if "`matname'"~="" {
			return matrix `matname' = `cellcontents'
		}
		return local cells2text `cells2text'
end  //  End of subroutine _scattertab

program define _calcsub, rclass
	syntax , matname(name) tabopt(string) total(real) nrows(real)
	if "`tabopt'"=="count" {
		// Do nothing
	}
	if "`tabopt'"=="cell" {
		mat define `matname' = 100*`matname'/`total'
		local pctsign `"%"'
	}
	if "`tabopt'"=="row" {
		foreach i of numlist 1/`nrows'  {
			local rowsum`i' = 0
			foreach j of numlist 1/`nrows'  {
				local rowsum`i' = `rowsum`i'' + `matname'[`i',`j']
			}
			foreach j of numlist 1/`nrows'  {
				mat def `matname'[`i',`j'] = 100*`matname'[`i',`j']/`rowsum`i''
			}
		}
		local pctsign `"%"'
	}
	if "`tabopt'"=="col" {
		foreach j of numlist 1/`nrows'  {
			local colsum`j' = 0
			foreach i of numlist 1/`nrows'  {
				local colsum`j' = `colsum`j'' + `matname'[`i',`j']
			}
			foreach i of numlist 1/`nrows'  {
				mat def `matname'[`i',`j'] = 100*`matname'[`i',`j']/`colsum`j''
			}
		}
		local pctsign `"%"'
	}
	return matrix cellcontents `matname'
	return local pctsign `pctsign' 
end  //  End of subroutine _calcsub

*	Enhanced version of "scatter_hist.ado", by Keith Kranker <keith.kranker@gmail.com> on 2012/01/07 18:15:06 (revision ef3e55439b13
*	Version 1.0	5/15/2015.  The -gridsample(real 100)- option has not been implemented.
*		The idea for it is that the given percentage of observations would be randomly slected 
*		for display within each cell of the grid defined by one of the lines options.
*	Version 1.1	5/16/2015.  Add the -fittype()- option
*	Version 1.2	5/17/2015.  Distinguish kdxoptions from kdyoptions, 
*		reduce # labels on marginal distributions to #3
*	Version 1.3 8/10/2015 adds an ellipse option AND AN undocumented box-and-whisker option
*		The box and whisker option is unsatisfactory because I can't figure out how to align the
*		bottom axis of the box plot on the y axis (or the left axis of the box plot on the x-axis)
*		with the bottom (or left) axis of the scatter plot.  However, a combined graph
*		constructed using this program with the box option could be "fixed"
*		after the fact with Stata's graph editor.  
*	Version 1.4	10/17/2015.  Change "return local name =" to "return scalar name ="
*		Also add options to control the color of the ellipse.
*	Version 1.5	10/23/2015.  Change the -estyle- option to -epattern-
*	Version 1.6	15jun2017.  Add options to take the square root or log10 
*		of both variables before proceeding with the scatter plot.
*		Correct omission of -if `touse'- in tabulate commands in _scattertab
*		Add -line45- option. Automate the axis labels for sqrt, log10 options.
*	Version 1.7	29jun2017.  Add a note for the -log10plusone- option.  
*		Stack the notes and allow for note options.
*		Suppress output of replace and gen commands.
*		Enable xlabel options, especially -labsize(small)-
*		Fix ylabel option to work the same as xlabel option
*		Fix bug in -fitoptions-
*	Version 1.8	18Jul2017.  Add hilite option.  
*		Try to fix bug when ylabel option is -ylabel(0 1 2 3 4 5 6,labsize(huge)-
*	Version 1.9	3Apr2018.  Put double quotes around xtitle and ytitle options
*	Version 2.0 11Apr2018. Add count of points within tolerance of the line45.
*		Use _parse comma to pull the note options from the note option.
*	Version 2.1 18Apr2018. Replace the -markout- command after the log transform to the mark 
*		command so that the tabulation of observations used before and after
*		the log transformation is correct.
*	Version 2.2 19Jun2018. Change label on temporary categrical `xy'cat and `xy'cat2 
*		to specify that values exactly equal to the mean|median are classified as below it.
*	Version 2.3 10Jan2019. Add option -plotregion(lcolor(black))- to show axis lines
*	Version 2.4 17Feb2019. Change -dfltfrmt- formats. Add option -terciles- 
