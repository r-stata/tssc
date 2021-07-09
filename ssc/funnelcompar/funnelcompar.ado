*! 1.1 25mar2010 rosa gini

// changelog from 1.0
// corrected bug in markupcolor and marklowcolor
// moved -twowayopts- at the end of the graph command, so that it might override any other default



*! 1.0 17sep2009 rosa gini, silvia forni (based on confunnel by tom palmer and on eclplot by roger newson)
 
program funnelcompar, rclass
version 8.2

/*set a maximum of 5+1 conditions for superimposing scatters and specifying colors and legends*/
local maxmarkcond=5
local markcondi ""
local colormarkcondi ""
local legendmarkcondi ""
local optionsmarkcondi ""
forv i1=1(1)`maxmarkcond' {
	local markcondi `"`markcondi' MARKCOND`i1'(string asis)"'
	local colormarkcondi `"`colormarkcondi' COLORMARKCOND`i1'(string asis)"'
	local legendmarkcondi `"`legendmarkcondi' LEGENDMARKCOND`i1'(string asis)"'
	local optionsmarkcondi `"`optionsmarkcondi' OPTIONSMARKCOND`i1'(string asis)"'
	}
/*****************/
/** SYNTAX **/
/*****************/
syntax varlist(min=3 max=4) [if] [in], [BINOMial POISson CONTinuous smr ///
		ext_stand(string) NOWEIght ext_sd(string) EXACt Contours(numlist) CONSTant(string) ///
		MARKCONtour(string) MARKUP MARKUPCOLor(string) MARKLOW MARKLOWCOLor(string) MARKUnits(string asis) MARKAll MARKTEXTOPtions(string) MARKSCATTEROPTions(string) MARKCOLor(string)  MARKCOND(string asis) COLORMARKcond(string asis) LEGENDMARKCOND(string asis) OPTIONSMARKCOND(string asis) `markcondi' `colormarkcondi' `legendmarkcondi' `optionsmarkcondi' ///
		NODRAw VERTical SCATTERCOLor(string) ASPECTratio(string)  CONTCOLor(string) LEGENDCONTour UNITLABel(string) EXTRAplot(string) ///
		FUNCTIONLOWopts(string) FUNCTIONUPPopts(string) ///
		LEGENDMORe(string) LEGENDopts(string) ///
		ONEsided(string) ///
		SCATTERopts(string) SHADEDContours SOLIDContours STEP TWOWAYopts(string) YTITle(string) XTITle(string) TITle(string) LINECOLor(string) SAVing(string asis) DISPLAYcommand ///
		EXPORT_instr(string)]

if "`exact'"!=""{
	version 10.0
	}
		
marksample touse,strok
tokenize `varlist'
local value `1'   
local disp `2'
local unit `3'
local sdvalue `4'

/*
'value' contains proportions/rates/means -either crude or directly standardised- that are to be plotted; SMRs are considered as rates
'disp' contains the denominators of proportions/rates/means, or the expected number of events
'unit' contains the observation units whose values are to be compared
'sdvalue' contains the standard deviation of the variable 'value'; it is only admitted if value' arises from a continuous distribution and -ext_sd- is not specified
*/

/*OPTIONS*
-BINOMial POISson CONTinuous- only one of those options are possible and at least one is mandatory: they specify whether the routine expect to process proportions, rates or means 
-ext_stand(string) ext_sd(string)- specify external references; if they are not specified references are computed from the data 
-smr- specifies that rates are to be considered as indirectly standardised
-NOWEIght- if references are computed form the data, noweiht tells not to weight the data before computing reference values
-CONSTant(string)- contains the multiplicative constant for proportions or rates (eg 100 for percentages)
-exact- specifies that the reference curves must be computed with exact methods instead of the defauild normal approximation (only for poisson or binomial)
-nodraw- causes the command to generate the data and the command for plotting the funnel plot, but *not* to plot it
-VERTical- specifies that the funnel must be vertical (horizontal is the default)
-SCATTERCOLor(string)- specifies the color of the scatter points
-Contours(string)- specifies significance levels (in percentage) of test 'measure'='ext_stand' at which contours should be plotted; default is .2 and 5
-LEGENDCONTour- puts the significance levels of the contours in the legend 
-MARKUnits(string asis) MARKTEXTOPtions MARKCOLor(string) MARKSCATTEROPTions()- allows to mark specific points listed in -MARKUnits- with specified color, possible labels and scatter options
-MARKAll - marks all points with their labels or values
-MARKCOND(string asis) COLORMARKCOND(string asis) LEGENDMARKCOND(string asis)- marks points accoprding to some conditions on data (up to 6 conditions are available of the form markcond(), markcond1(), markcond2()... )
-MARKCONtour(string) MARKUP MARKUPCOLor(string) MARKLOW MARKLOWCOLor(string)- marks point upper/lower the contour at -markcontour- confidence level
-STEP- set the granularity at which the contour lines are computed; a default is computed from the data
-SAVing(string asis)- saves the dataset that generates the curves
-DISPLAYcommand- makes the routine display the command that generates the graph
-LINECOLor(string)- is the color of the reference line

-graph options-
SCATTERopts(string) ASPECTratio(string)  CONTCOLor(string) UNITLABel(string) EXTRAplot(string) FUNCTIONLOWopts(string) FUNCTIONUPPopts(string) LEGENDMORe(string) LEGENDopts(string) ONEsided(string) SHADEDContours SOLIDContours  YTITle(string) XTITle(string) TITle(string) TWOWAYopts(string)
the option must be inserted in compound double quotes `"..."'
in particular the string in -twowayopts- is placed at the end of the graph command, so that it might override any previous option
*/

/*****************/
/** ERRORS **/
/*****************/

if "`binomial'"=="" & "`poisson'"=="" & "`continuous'"==""{
	di as error "You must specify -binomial- or -poisson- or -continuous-." 
	di as error "If -binomial- is specified, then data are considered to be proportions arising from a binomial distribution" 
	di as error "If -poisson- is specified, then data are considered to be rates arising from a poisson distribution or SMR"
	di as error "If -continuous- is specified, then data considered to be means arising from a normal distribution"
	error 198
	}
local options "binomial poisson continuous"
foreach opt of local options{ 
	if "``opt''"!=""{
		foreach othopt of local options{
			if "``othopt''"!="" & "`opt'"!="`othopt'" {
				di as error "Only one option between -binomial-, -poisson- and -continuous- might be specified, while you specified both -`opt'- and -`othopt'-"
				error 198
				}
			}
		}
	}
if "`sdvalue'"!="" &"`continuous'"==""{
	di as error "The fourth variable of the command '`sdvalue'' should only be specified when -continuous- option is also specified"
	di as error "In this case '`sdvalue'' is assumed to contain the standard errors of the means contained in '`value''"
	di as error "Recall that -continuous- must specified if data contained in '`value'' are means arising from a normal distribution"
	error 198
	}

if "`smr'"!="" &"`poisson'"==""{
	di as error "Option -smr- implies that option -poisson- must be specified "
	error 198
	}
if "`ext_stand'"!="" &"`noweight'"!=""{
	di as error "Option -ext_stand- is incompatible with -noweight- option,"
	di as error "since -ext_stand- assumes that the data are to be compared against and external standard "
	di as error "whereas -noweight- assumes that the data are to be compared against the internal noweighted mean"
	error 198
	}
if "`ext_sd'"!="" & "`continuous'"=="" {
	di as error "Option -ext_sd- only might be specified if the -continuous- option is specified,"
	di as error "and only in case the data are considered to be means arising from a normal distribution "
	di as error "and one wants to compare them against a standand mean with external standard deviation -ext_sd-"
	error 198
	}
if "`sdvalue'"=="" & "`ext_sd'"==""&"`continuous'"!=""{
	di as error "When the -continuous- option is specified either a fourth variable or the external standard deviation -ext_sd- option should be specified"
	di as error "in order to let the program decide which reference standard deviation should be assumed"
	error 198
	}
if "`sdvalue'"!="" & "`ext_sd'"!=""{
	di as error "You specified both variable '`sdvalue'' and the external standard deviation -ext_sd- option"
	di as error "You should decide whether the reference standard deviation should be computed from the data contained in '`sdvalue''"
	di as error "or the program should assume the number `ext_sd' as reference standard deviation"
	error 198
	}
if "`smr'"!="" & ("`ext_stand'"!="" |"`noweight'"!="") {
	di as error "Option 'smr' only might be specified in case of indirectly standardised rates "
	di as error "and in this case neither 'ext_stand' nor 'noweight' might be specified"
	di as error "since the external standard is fixed to the expected rate"
	error 198
	}
if "`exact'"!="" & "`continuous'"!=""{
	di as error "Option 'exact' does not apply to the 'continuous' case"
	error 198
	}

if "`onesided'" != "" & "`onesided'" != "lower" & "`onesided'" != "upper" {
	di as error "onesided() must be unspecified, lower or upper"
	error 198
}
if (`"`markunits'"'!=""&"`markall'"!=""){
	di as error "only one option between -markunits- and -markall- must be specified"
	di as error "-markunits- lists the units that must be labelled""
	di as error "-markall- specifies that all units must be labelled with their value labels (or with their values if no label is available)"
	error 198
	}
if (`"`markunits'"'==""&"`markscatteroptions'"!=""){
	di as error "-markscatteroptions- can only be specified if -markunits- is specified"
	di as error "-markunits- lists the units that must be labelled"
	di as error "-markscatteroptions- specifies that they should be also marked with some option"
	error 198
	}
forv i1=0(1)`maxmarkcond' {
	local i=cond(`i1'==0,"","`i1'")
	if `"`markcond`i''"'!=""{
		capture count if `markcond`i''
		if _rc!=0{
			di as error `"Option -markcond`i'- contains the string "`markcond`i''" which is not a valid condition on the dataset"'
			error 198
			}
		}
	}
if "`contours'" == "" { // default significance contours
	local contours "5 .2"
	}
if (`"`markup'"'!=""|`"`marklow'"'!="") & "`markcontour'"!=""{ //checks that `markcontour' is one of the contours	
	local nmarkcont = wordcount("`markcontour'")
	if `nmarkcont'>1{
		di as error `"Option -markcontour- should contain a single value chosen among the contours `contours' that you asked to plot"'
		error 198
		}
	if subinword("`contours'","`markcontour'","",1)=="`contours'"{
		di as error `"Option -markcontour- contains the string "`markcontour'" which is not one of the contours `contours' that you asked to compute"'
		error 198
		}
	}
/*****************/
/** DEFAULTS **/
/*****************/

local namedistr=cond("`binomial'"!="","binomial",cond("`poisson'"!="","Poisson","normal"))
if "`constant'"==""{
	local constant "1"
	}
if "`unitlabel'"==""{
	local labelunit:variable label `unit'
	if "`labelunit'"!=""{
		local unitlabel "`labelunit'"
		}
	else{
		local unitlabel "Units"
		}
	}
if "`scattercolor'" == "" { // default significance contours
	local scattercolor "black"
}

local ncontours = wordcount("`contours'")
if (`"`markup'"'!=""|`"`marklow'"'!="") & "`markcontour'"==""{ //default for contour whose external should be marked
	local markcontour=word(`"`contours'"',1)
	}
/*a string with a dot cannot be the name of a local macro; hence in the names `c' of the confidence levels dots are substituted by the string -dot-, and the corresponding numbers are stored in local macros number`c'*/
local contours: subinstr local contours "." "_",all
local markcontour: subinstr local markcontour "." "_",all
foreach c of local contours{
	local number`c' : subinstr local c "_" ".",all
	}
if "`vertical'"!=""{ //reverse x and y axis if vertical is not specified (the default is horizontal)
	local x "x"
	local y "y"
	}
else{
	local x "y"
	local y "x"
	}

if "`solidcontours'" == "solidcontours" { // use dashed or solid contours
	forvalues m = 1/`ncontours' {
		local linepatt `"`linepatt' solid"'
	}
}
else if "`solidcontours'" == "" {
	local linepatt "longdash dash shortdash dot shortdash_dot dash_dot longdash_dot" // line pattern styles for the contours
}
local n 0
foreach lp in `linepatt' {
	local lp`++n' `lp'
}

forvalues j = 1/`ncontours' { // shades for shaded contours
	if "`contcolor'" == "" {
		local shadedcontcol black
	}
	else {
		local shadedcontcol `contcolor'
	}
	if "`shadedcontours'" == "shadedcontours" { 
		local lc`j' "`shadedcontcol'*`=1 - `j'/(`ncontours'*1.25)'"
	}
	else if "`shadedcontours'" == "" & "`contcolor'" == "" {
		local lc`j' "gs8"
	}
	else if "`shadedcontours'" == "" & "`contcolor'" != "" {
		local lc`j' "`contcolor'"
	}
}

if "`aspectratio'" != "" { // default aspectratio
	local aspectratio "aspectratio(`aspectratio')"
	}
if "`linecolor'" == "" { // default color for reference line
	local linecolor "red" 
	}

if `"`markup'"'!="" & "`markupcolor'"==""{ //default for marking points upper the contour
	local markupcolor "orange"
	}
if `"`marklow'"'!="" & "`marklowcolor'"==""{ //default for marking points lower the contour
	local marklowcolor "blue"
	}

/*AUXILIARY LOCAL MACROS*/
local plusu="+"
local plusl="-"
	
/*****************/
/** ANALYSIS **/
/*****************/
/*set the value of the standard according to the options*/
if "`ext_stand'"==""{
	if "`smr'"!=""{
		local ext_stand="`constant'"
		}
	else{
		if "`noweight'"==""{
			qui su `value' [fw= `disp'] if  `touse',meanonly
			}
		else{
			qui su `value' if  `touse',meanonly
			}
		local ext_stand=string(r(mean))
		}
	}
if "`binomial'"!=""{
	local ext_sd=string(sqrt(`ext_stand'*(`constant'-`ext_stand')))
	}
if "`poisson'"!=""{
	local ext_sd=string(sqrt(`ext_stand')*sqrt(`constant'))
	}
if "`ext_sd'"=="" & "`continuous'"!=""{
	tempvar variance
	gen `variance'=`sdvalue'^2
	if "`noweight'"==""{
		qui su `variance' [fw= `disp'] if `touse',meanonly
		}
	else{
		qui su `variance' if `touse',meanonly
		}
	local ext_sd=string(sqrt(r(mean)))
	}

/*generate the dataset of the reference curves*/
local `y'var "_`y'var"
qui gen ``y'var' = `disp'
// tempvar funnel
qui gen byte _funnel=`touse'==1
tempfile dataset
save `dataset'
if "`exact'"==""{
	foreach c in `contours' {
		local lev=100-`number`c''
		qui gen _ub`c'=`ext_stand' + invnorm(1-`number`c''/(2*100))*`ext_sd'/sqrt(``y'var') if  `touse' 
		qui gen _lb`c'=`ext_stand' - invnorm(1-`number`c''/(2*100))*`ext_sd'/sqrt(``y'var') if  `touse' 
		}
	}
else{
	qui su ``y'var' if `touse', meanonly
	if "`step'"==""{
		local step=max(round(ceil((r(max)-r(min))/10),10),1)
		}
	local `y'max = ceil(r(max)+`step'/10)
	local `y'min =max(1,floor(r(min)-`step'/10))
	local obs=ceil((``y'max'-``y'min'+1)/`step')+1
	clear
	qui set obs `obs'
	qui gen ``y'var'=(_n-1)*`step'+``y'min' 
	qui drop if ``y'var'<2
	append using `dataset'
	qui replace _funnel=2 if mi(_funnel)
	foreach c in `contours' {
		local lev=100-`number`c''
		preserve
		contract ``y'var'
		drop _freq
// 		qui gen _obs1=int(`ext_stand'* ``y'var'/`constant')
		if "`binomial'"!=""{
			foreach lim in u l{
				local theta=`ext_stand'/`constant'
				local lev`lim'=cond("`lim'"=="l",`number`c''/(2*100),1-`number`c''/(2*100))
				
				qui gen rp`lim' = .
				mata: x = .
				mata: st_view(x, ., ("``y'var'"))
				local obs=_N
				forvalues i = 1(1)`obs'{
					scalar scalar_i = `i'
					mata: i = st_numscalar("scalar_i")
					qui mata: invbinom2(x[i], `theta',`lev`lim'' )
					qui replace rp`lim' = r(rp) in `i'
					}
				qui gen rp`lim'm1=rp`lim'-1
				qui gen _`lim'b`c'=``y'var'^(-1)*(rp`lim'-((binomial(``y'var',rp`lim',`theta')-`lev`lim'')/(binomial(``y'var',rp`lim',`theta')-binomial(``y'var',rp`lim'm1,`theta'))))
				qui gen _`lim'b`c'app=`theta' `plus`lim'' invnorm(1-`number`c''/(2*100))*sqrt(``y'var'^(-1)*((`theta'*(1-`theta'))))
				foreach var of varlist _`lim'b`c' _`lim'b`c'app {
					qui replace `var'=0 if `var'<0
					qui replace `var'=1 if `var'>1
					}
				}
			}
		if "`poisson'"!=""{
			foreach lim in u l{
				local theta=`ext_stand'/`constant'
				local lev`lim'=cond("`lim'"=="l",`number`c''/(2*100),1-`number`c''/(2*100))
				
				qui gen rp`lim' = .
				mata: x = .
				mata: st_view(x, ., ("``y'var'"))
				local obs=_N
				forvalues i = 1(1)`obs'{
					scalar scalar_i = `i'
					mata: i = st_numscalar("scalar_i")
					qui mata: invpoisson2(x[i], `theta',`lev`lim'' )
					qui replace rp`lim' = r(rp) in `i'
					}
				qui gen rp`lim'm1=rp`lim'-1
				qui gen _`lim'b`c'=``y'var'^(-1)*(rp`lim'-((poisson(`theta'*``y'var',rp`lim')-`lev`lim'')/(poisson(`theta'*``y'var',rp`lim')-poisson(`theta'*``y'var',rp`lim'm1))))
				qui gen _`lim'b`c'app=`theta' `plus`lim'' invnorm(1-`number`c''/(2*100))*sqrt(``y'var'^(-1)*(`theta'))
				foreach var of varlist _`lim'b`c' _`lim'b`c'app {
					qui replace `var'=0 if `var'<0
					}
				}
			}
		foreach lim in u l{
			foreach var of varlist _`lim'b`c' _`lim'b`c'app {
				qui replace `var'= `var'*`constant' 
				}
			label variable _`lim'b`c' `"`lim'b for variable `value' at confidence level `lev' assuming `namedistr' distribution"'
			}
		keep ``y'var' _u* _l*
		sort ``y'var'
		tempfile `c'file
		qui save ``c'file'
		restore
		sort ``y'var'
		qui merge ``y'var' using ``c'file', update
		drop _merge
		}
	}
if `"`saving'"'!=""{
	preserve
	local namefile=cond(strmatch(`"`saving'"',"*.dta")==1,`"`saving'"',`"`saving'.dta"')
	if ("`binomial'"!=""| "`poisson'"!=""){
		local methodcurves=cond("`exact'"=="","normal approximation","exact method")
		}
	else{
		local methodcurves ""
		}
	label data "Dataset for funnel plot (see characheristics with -char list-)"
	label variable _funnel "Instruction for funnel"
	label define funnel_label 0 "Not to use" 1 "Points for scatter" 2 "Points for curves"
	label values _funnel funnel_label
	local target_val `"`ext_stand'"'
	local target_sd `"`ext_sd'"'
	foreach char in namedistr target_val target_sd methodcurves{
		char define _dta[`char'] `"``char''"'
		}
	qui save `namefile',replace
	di in ye `"File for funnel plot generation was saved in `namefile'"'
	restore
	}
// export instructions (non documented)
if "`export_instr'"!=""{
	di in ye "export_instr"
	use `namefile',clear
	qui count if _funnel==2
	if `r(N)'==0{
		qui su ``y'var' if `touse', meanonly
		if "`step'"==""{
			local step=max(round(ceil((r(max)-r(min))/10),10),1)
			}
		local `y'max = ceil(r(max)+`step'/10)
		local `y'min =max(1,floor(r(min)-`step'/10))
		local obs=ceil((``y'max'-``y'min'+1)/`step')+1
		clear
		qui set obs `obs'
		qui gen ``y'var'=(_n-1)*`step'+``y'min' 
		qui drop if ``y'var'<2
		append using `namefile'
		qui replace _funnel=2 if mi(_funnel)
		foreach c in `contours' {
			local lev=100-`number`c''
			qui replace _ub`c'=`ext_stand' + invnorm(1-`number`c''/(2*100))*`ext_sd'/sqrt(``y'var') if  `touse' |_funnel==2
			qui replace _lb`c'=`ext_stand' - invnorm(1-`number`c''/(2*100))*`ext_sd'/sqrt(``y'var') if  `touse' |_funnel==2
			}
		}
	qui gen group=""
	qui gen symbol=""
	qui gen color="black"
	forv i1=0(1)`maxmarkcond' {
		local i=cond(`i1'==0,"","`i1'")
		if `"`markcond`i''"'!=""{
			qui replace group="`i1'" if `markcond`i'' & _funnel==1
			foreach symbol in circle diamond triangle square plus x{
				qui replace symbol="`symbol'" if  strmatch("`optionsmarkcond`i''","*`symbol'*") & group=="`i1'" 
				}
			if `"`colormarkcond`i''"'!=""{
				qui replace color="`colormarkcond`i''" if group=="`i1'" 
				}
			}
		} 
	tempfile scatterpoints
	preserve
	qui keep if _funnel==1
	save `scatterpoints'
	restore 
	
	qui keep if _funnel==2
	keep  ``y'var'  _*
	foreach c in `contours' {
		rename _ub`c' `value'ub`c'
		rename _lb`c' `value'lb`c'
		}
	qui gen `value'ref=`ext_stand'
	qui reshape long `value',i(``y'var' _funnel) j(id_curve)  string
	append using `scatterpoints'
	rename ``y'var' x
	rename `value' y
	keep x y `unit' _funnel id_curve color symbol
	order x y `unit' _funnel id_curve color symbol
	qui save `export_instr',replace
	use `namefile',clear
	}

/**********************/
/** GRAPH GENERATION **/
/**********************/
di in ye "Starting plotting the graph"
//arguments in the correct order according to graph to be plotted vertical or horizontal
local args=cond("`vertical'"!="","``y'var' `value'","`value' ``y'var' " )

//CONTOURS
// legend for contours
local i 1 
foreach c in `contours' {
	local i = `i' + 1
	local h = `i' - 1
	if "`onesided'" == "lower" {
		local lub`c' "lc(none)"
		local llb`c' "lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts'"
		local contourlabels`c' `"`=2*`h' - 1' "Sign. `number`c''%""'
		}
	else if "`onesided'" == "upper" {
		local lub`c' "lc(`lc`h'') lp(`lp`h'') lw(thin) `functionupopts'"
		local llb`c' "lc(none)"
		local contourlabels`c' `"`=2*`h' - 1' "Sign. `number`c''%""'
		}
	else{
		local lub`c' "lc(`lc`h'') lp(`lp`h'') lw(thin) `functionupopts'"
		local llb`c' "lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts'"
		local contourlabels`c' `"`=2*`h'' "Sign. `number`c''%""'
		}
	}
//command for contours
foreach c in `contours'{
	foreach lim in u l{
		if "`exact'"==""{
			qui sum ``y'var' if `touse'
			local range "`r(min)' `r(max)'"
			local invnorm=invnorm(1-`number`c''/(2*100))
			local args`lim'=cond("`vertical'"!=""," horizontal","" )
			local function `"`function' function `ext_stand'`plus`lim''`invnorm'*`ext_sd'/sqrt(x) , range(`range') `l`lim'b`c'' `args`lim''  || "'
			}
		else{
			local args`lim'=cond("`vertical'"!="","``y'var' _`lim'b`c'","_`lim'b`c' ``y'var' " )
			local function `"`function' line `args`lim'' , sort `l`lim'b`c'' || "'
			}
		}
	local contourlabels `"`contourlabels' `contourlabels`c''"'
	}
	
//POINTS
//marks units specified in -markunits- or -markall- options
if (`"`markunits'"'!=""|"`markall'"!=""){
	if `"`markunits'"'!=""{
		local tokens `"`markunits'"'
		local j=1
		gettoken `j' tokens: tokens,quotes
		local k=1
		while (`"``j''"'!=""){
			if strmatch(`"``j''"',`"`"*"'"')==0{
				local val`k' `"``j''"'
				local k=`k'+1
				}
			else{
				local km=`k'-1
				if `"`lab`km''"'==""{
					local lab`km' ``j''
					}
				}
			local j=`j'+1
			gettoken `j' tokens: tokens,quotes
			}
		local maxval=`k'-1
		if "`markcolor'"==""{
			local markcolor "red"
			}
		}
	else{
		qui levelsof `unit' ,local(unitvalues) clean
		local maxval: word count `unitvalues'
		tokenize `unitvalues'
		forvalues k=1/`maxval'{
			local val`k' `"``k''"'
			}
		if "`markcolor'"==""{
			local markcolor "`scattercolor'"
			}
		}
	capture confirm string variable `unit'
		if _rc==0{
			local unitstring "1"
			}
	if "`markcolor'"!= `"`scattercolor'"'| "`markscatteroptions'"!=""{
		local markscatter ""
		forvalues k=1/`maxval'{
			local ifunit=cond("`unitstring'"=="1",`"`unit'=="`val`k''""',`"`unit'==`val`k''"')
			if "`markscatteroptions'"==""{
				local markscatteroptions `"`scatteropts'"'
				}
			qui count if `touse' & `ifunit'
			if `r(N)'>0{
				local markscatter `"`markscatter' scatter `args' if `ifunit',mc(`markcolor') `markscatteroptions' ||"'
				}
			}
		}
	local marktext ""
	forvalues k=1/`maxval'{
		local ifunit=cond("`unitstring'"=="1" ,`"`unit'=="`val`k''""',`"`unit'==`val`k''"')
		qui count if `ifunit' & `touse'
		if `r(N)'==0{
			di as err `"no observations satisfy condition `ifunit'"'
			}
		else{
			local xvar= word("`args'",2)
			local yvar= word("`args'",1)
			foreach coord in x y {
				qui levelsof ``coord'var' if `ifunit' & `touse',local(`coord'`k') clean
				}
			if `"`lab`k''"'==""{
				if "`unitstring'"=="1"{
					local lab`k': label  (`unit') `val`k''
					}
				else{
					local lab`k' `"`val`k''"'
					}
				}
			if `"`marktextoptions'"'==""{
				local marktextoptions `"placement(ne)"'
				}
			local marktext `"`marktext' text(`y`k'' `x`k''  `"`lab`k''"', color(`markcolor') `marktextoptions')"'
			}
		}
	}
//marks units upper and/or lower the contour
foreach lev in up low{
	if `"`mark`lev''"'!=""{
		local if`lev'=cond("`lev'"=="up", `"`value'>_ub`markcontour' & `touse'"',`"`value'<_lb`markcontour' & `touse'"' )
		qui levelsof `unit' if `if`lev'' & `touse' ,local(unitvalues`lev') clean
		local maxval`lev': word count `unitvalues`lev''
		tokenize `unitvalues`lev''
		forvalues k=1/`maxval`lev''{
			local val`k' `"``k''"'
			}
		capture confirm string variable `unit'
			if _rc==0{
				local unitstring=1
				}
		if "`mark`lev'color'"!= `"`scattercolor'"'!{
			local mark`lev'scatter ""
			if "`markscatter`lev'options'"==""{
				local markscatter`lev'options `"`scatteropts'"'
				}
			local mark`lev'scatter `"`mark`lev'scatter' scatter `args' if `if`lev'',mc(`mark`lev'color') `markscatter`lev'options' ||"'
			}
		local mark`lev'text ""
		forvalues k=1/`maxval`lev''{
			local ifunit=cond("`unitstring'"=="1" ,`"`unit'=="`val`k''""',`"`unit'==`val`k''"')
			local xvar= word("`args'",2)
			local yvar= word("`args'",1)
			foreach coord in x y {
				qui levelsof ``coord'var' if `ifunit' & `touse' ,local(`coord'`k') clean
				}
			if `"`lab`k''"'==""{
				if "`unitstring'"!="1"{
					local lab`lev'`k': label  (`unit') `val`k''
					}
				else{
					local lab`lev'`k' `"`val`k''"'
					}
				}
			if `"`marktextoptions`lev''"'==""{
				local marktextoptions`lev' `"placement(ne)"'
				}
			local mark`lev'text `"`mark`lev'text' text(`y`k'' `x`k''  `"`lab`lev'`k''"', color(`mark`lev'color') `marktextoptions`lev'')"'
			}
		}
	}
//mark conditions specified in the -markcond`i'- options
local markconditions ""
forv i1=0(1)`maxmarkcond' {
	local i=cond(`i1'==0,"","`i1'")
	if `"`markcond`i''"'!=""{
		if "`optionsmarkcond`i''"==""{
			local optionsmarkcond`i' `"`scatteropts'"'
			}
		local markconditions `"`markconditions' scatter `args' if `touse' & `markcond`i'',mc(`colormarkcond`i'') `optionsmarkcond`i'' ||"'
		}
	}
// LEGEND
if "`legendopts'" != "off" {
	// position and other options
	if "`legendopts'" == "" { // default legend options
		local legendopts "ring(0) pos(2) size(small) symxsize(*.4) cols(1)"
		}
	//legend of units
	local legendtot `"order( `=2*`ncontours' + 1' `"`unitlabel'"' "'
	//legend of conditions
	forv i1=0(1)`maxmarkcond' {
		local i=cond(`i1'==0,"","`i1'")
		local ip=`i1'+1
		if `"`markcond`i''"'!=""{
			if `"`legendmarkcond`i''"'!=""{
				local legendtot `"`legendtot' `=2*`ncontours' +1+`ip'' `"`legendmarkcond`i''"' "'
				}
			}
		}
	//legend of contours
	if "`legendcontour'"!=""{
		local legendtot `"`legendtot'  `contourlabels' "'
		}
	local legendtot `"`legendtot' `legendmore') `legendopts'"'
	}
else{
	local legendtot `"off"'
	}
	
// ACTUAL GENERATION OF GRAPH
local graph_command `"twoway  `function' scatter `args' if `touse' & _funnel==1, mc(`scattercolor') `scatteropts' || `markconditions' `markscatter'  `markupscatter' `marklowscatter' `extraplot' , `x'line(`ext_stand',lcolor(`linecolor') ) `aspectratio' `y'scale(`reverse') ylabel(, angle(horizontal))  xtitle(`"`xtitle'"') ytitle(`"`ytitle'"') title(`"`title'"')    legend(`legendtot')  `marktext' `markuptext' `marklowtext' `twowayopts'"'
if "`displaycommand'"!=""{
	di in ye `"`graph_command'"'
	}
if "`nodraw'"==""{
	`graph_command'
	}
use `dataset',clear
drop _funnel ``y'var'

// RETURNED RESULTS
return local target_val `"`ext_stand'"'
return local target_sd `"`ext_sd'"'
return local graph_command `"`graph_command'"'

end

/***************************/
/*MATA AUXILIARY FUNCTIONS */
/***************************/

mata:
function invbinom2(n, theta, p){
        i=0
        do {
            F = binomial(n, i,theta)
            if  (F >= p) {
            st_numscalar("r(rp)", i)
                return(i)
            }
            i++
        } while (i<=n)
	}
end

mata:
function invpoisson2(n,theta, p){
		expected=theta*n
        i=0
        do {
            F = poisson(expected,i)
            if  (F >= p) {
            	st_numscalar("r(rp)", i)
                return(i)
            	}
			i++
        } while (st_isnumfmt("r(rp)")<1)
	}


end


