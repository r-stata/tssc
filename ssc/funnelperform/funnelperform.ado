*! 1.1 25mar2010 rosa gini

// changelog from 1.0
// corrected bug in markupcolor and marklowcolor
// moved -twowayopts- at the end of the graph command, so that it might override any other default

*! 1.1 31oct2017 minor bug fixes from funnelcompar rosa gini, silvia forni (based on confunnel by tom palmer and on eclplot by roger newson)
*! 1.2 fixed [if] [in] & scatteroptsapplied to main scatter even if no markall opt
program funnelperform, rclass sortpreserve
version 9.1

/*set a maximum conditions for superimposing scatters and specifying colors and legends*/
local maxmarkcond=3
numlist "1(1)`maxmarkcond'"
foreach i in "" `r(numlist)' {
	local markcondi `markcondi' MARKCOND`i'(string asis)
	local colormarkcondi `colormarkcondi' COLORMARKCOND`i'(string asis)
	local legendmarkcondi `legendmarkcondi' LEGENDMARKCOND`i'(string asis)
	local optionsmarkcondi `optionsmarkcondi' OPTIONSMARKCOND`i'(string asis)
	local labelcondi `labelcondi' LABELCOND`i'
}
local defaultReal -1.7e+38
/*****************/
/** SYNTAX **/
/*****************/
syntax varlist(min=3 max=4) [if] [in] [iweight/], [BINOMial POISson CONTinuous GAMMA BETA SMR ///
		ext_stand(real `defaultReal') NOWEIght ext_sd(real `defaultReal') EXACt Contours(numlist) CONSTant(real 1) ///
		MARKCONtour(real `defaultReal') MARKUP MARKUPCOLor(string) MARKLOW MARKLOWCOLor(string) MARKUnits(string asis) LABELUnits(string asis) MARKAll MARKTEXTOPtions(string) ///
		MARKSCATTEROPTions(string) MARKCOLor(string) TRUNC0 ///
		`markcondi' `colormarkcondi' `legendmarkcondi' `optionsmarkcondi' `labelcondi' ///
		NODRAw VERTical SCATTERCOLor(string) ASPECTratio(string)  CONTCOLor(string) LEGENDCONTour UNITLABel(string) EXTRAplot(string) ///
		FUNCTIONLOWopts(string) FUNCTIONUPPopts(string) LEGENDMORe(string) LEGENDopts(string) ONEsided(string) ///
		SCATTERopts(string) SHADEDContours SOLIDContours N(integer 100) TWOWAYopts(string) YTITle(passthru) XTITle(passthru) TITle(passthru) LINECOLor(string) ///
		SAVing(string asis) DISPLAYcommand]

marksample touse,strok
tokenize `varlist'
local value `1'   
local disp `2'
local unit `3'
local sdvalue `4'
foreach v in ext_stand ext_sd markcontour{
	if (``v''==`defaultReal'){
		local `v' .
	}
}

/*
'value' contains proportions/rates/means -either crude or directly standardised- that are to be plotted; SMRs are considered as rates
'disp' contains the denominators of proportions/rates/means, or the expected number of events
'unit' contains the observation units whose values are to be compared
'sdvalue' contains the standard deviation of the variable 'value'; it is only admitted if value' arises from a continuous distribution and -ext_sd- is not specified
*/

/*OPTIONS*
-BINOMial POISson CONTinuous GAMMA- only one of those options are possible and at least one is mandatory: they specify whether the routine expect to process proportions, rates or means 
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
-MARKCONtour(real) MARKUP MARKUPCOLor(string) MARKLOW MARKLOWCOLor(string)- marks point upper/lower the contour at -markcontour- confidence level
// deprecated - mirror twoway function n option instead -STEP- set the granularity at which the contour lines are computed; a default is computed from the data
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
local namedistr = trim("`poisson' `binomial' `gamma' `continuous' `beta'")
if "`namedistr'"==""{
	di as error "You must specify -binomial- or -poisson- or -continuous- or -gamma- or -beta-." 
	di as error "If -binomial- is specified, then data are considered to be proportions arising from a binomial distribution" 
	di as error "If -poisson- is specified, then data are considered to be rates arising from a poisson distribution or SMR"
	di as error "If -continuous- is specified, then data considered to be means arising from a normal distribution"
	error 198
}
if (wordcount("`namedistr'")>1){
	di as error "Only one option between -binomial-, -poisson-, -gamma-, -beta- and -continuous- may be specified"
	error 198
}
if "`sdvalue'"!="" &"`continuous'"==""{
	di as error "The fourth variable of the command '`sdvalue'' should only be specified when -continuous- option is also specified"
	di as error "In this case '`sdvalue'' is assumed to contain the standard errors of the means contained in '`value''"
	di as error "Recall that -continuous- must specified if data contained in '`value'' are means arising from a normal distribution"
	error 198
}
if "`smr'"!="" & !inlist("`namedistr'","poisson","gamma","beta"){
	di as error "Option -smr- implies that distribution -poisson-, -gamma- or -beta- must be specified "
	error 198
}
if `ext_stand'==. &"`noweight'"!=""{
	di as error "Option -ext_stand- is incompatible with -noweight- option,"
	di as error "since -ext_stand- assumes that the data are to be compared against and external standard "
	di as error "whereas -noweight- assumes that the data are to be compared against the internal noweighted mean"
	error 198
}
if `ext_sd'!=. & "`continuous'"=="" {
	di as error "Option -ext_sd- only might be specified if the -continuous- option is specified,"
	di as error "and only in case the data are considered to be means arising from a normal distribution "
	di as error "and one wants to compare them against a standand mean with external standard deviation -ext_sd-"
	error 198
}
if "`sdvalue'"=="" & `ext_sd'==. & "`continuous'"!=""{
	di as error "When the -continuous- option is specified either a fourth variable or the external standard deviation -ext_sd- option should be specified"
	di as error "in order to let the program decide which reference standard deviation should be assumed"
	error 198
}
if "`sdvalue'"!="" & `ext_sd'!=.{
	di as error "You specified both variable '`sdvalue'' and the external standard deviation -ext_sd- option"
	di as error "You should decide whether the reference standard deviation should be computed from the data contained in '`sdvalue''"
	di as error "or the program should assume the number `ext_sd' as reference standard deviation"
	error 198
}
if "`smr'"!="" & (`ext_stand'!=. |"`noweight'"!="") {
	di as error "Option 'smr' only might be specified in case of indirectly standardised rates "
	di as error "and in this case neither 'ext_stand' nor 'noweight' might be specified"
	di as error "since the external standard is fixed to the expected rate"
	error 198
}
if inlist("`namedistr'","gamma") & "`smr'"==""{
	di as error "Currently the gamma (incomplete gamma (ratio)) option can only be apply to standardised (observed/expected) rates. Please specify SMR"
	error 198
}
if "`gamma'"!="" & !inlist(`ext_stand',.,1){
	di as error "The external standard must be 1 if the gamma option is specified"
	error 198
}
if "`beta'"=="" & "`weight'"!="" {
	di as error "an iweight can only be applied if the beta option is specified"
	error 198
}
if "`beta'"!="" & (("`weight'"=="") != ("`smr'"=="")) {
	di as error "if using beta option, either SMR & iweight options must both be supplied, or both must be missing"
	error 198
}
if "`weight'"!="" {
	confirm numeric variable `exp'
	capture assert `exp' > `disp' if `touse'
	if _rc != 0 {
		di as error "the iweight (population at risk) must be greater than the expected number of events"
		error 198
	}
}
if "`exact'"!="" & !inlist("`namedistr'","poisson","binomial"){
	di as error "Option 'exact' can only be applied to the poisson and binomial distributions"
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
	local contours "95.45 99.73"
}
if (`"`markup'"'!=""|`"`marklow'"'!="") & `markcontour'!=.{ //checks that `markcontour' is one of the contours	
	if !inlist(`markcontour',`=subinstr("`contours'"," ",",",.)'){
		di as error `"Option -markcontour- contains the value "`markcontour'" which is not one of the contours `contours' that you asked to compute"'
		error 198
	}	
}

confirm numeric variable `value'  
confirm numeric variable `disp'
if ("`sdvalue'"!=""){
	confirm numeric variable `sdvalue'
}

/*****************/
/** DEFAULTS **/
/*****************/

if (inlist("`namedistr'","gamma","beta")){
	if ("`smr'"!="") {
		local ext_stand 1
	}
}

if ("`beta'" != ""){ //a bit of a 'hack - uses similar loggic to the exact methods, even though it is not one
	local exact exact
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
if (`"`markup'"'!=""|`"`marklow'"'!="") & `markcontour'==.{ //default for contour whose external should be marked
	local markcontour:word 1 of `contours'
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
local j 0
foreach lp in `linepatt' {
	local lp`++j' `lp'
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
	local linecolor red
}
if `"`markup'"'!="" & "`markupcolor'"==""{ //default for marking points upper the contour
	local markupcolor orange
}
if `"`marklow'"'!="" & "`marklowcolor'"==""{ //default for marking points lower the contour
	local marklowcolor blue
}
if "`markcolor'"==""{
	local markcolor black
}
if ("`colormarkcond'"=="") {
	local colormarkcond red
}

/*AUXILIARY LOCAL MACROS*/
local plusub +
local pluslb -
/*****************/
/** ANALYSIS **/
/*****************/
/*set the value of the standard according to the options*/
local obs=_N
/*generate the dataset of the reference curves*/
tempvar _funnel `y'var
gen byte `_funnel'=`touse'==1
capture noisily{
	qui{
		if `ext_stand'==.{
			if "`smr'"!=""{
				local ext_stand 1
			}
			else{
				if "`noweight'"==""{
					qui su `value' [fw= `disp'] if  `touse',meanonly
				}
				else{
					qui su `value' if  `touse',meanonly
				}
				local ext_stand=r(mean)
			}
		}
		if "`binomial'"!=""{
			local ext_sd=sqrt(`ext_stand'*(1-`ext_stand'))
		}
		if "`poisson'"!=""{
			local ext_sd=sqrt(`ext_stand')
		}
		if `ext_sd'==. & "`continuous'"!=""{
			tempvar variance
			gen float `variance'=`sdvalue'^2
			if "`noweight'"==""{
				qui su `variance' [fw= `disp'] if `touse',meanonly
			}
			else{
				qui su `variance' if `touse',meanonly
			}
			local ext_sd=sqrt(r(mean))
		}

		if "`exact'"==""{
			foreach c in `contours' {
				tempvar ub`c' lb`c'
				if ("`gamma'"!=""){
					gen float `ub`c''= invgammap(`disp'+1,(100+`number`c'')/200)/`disp' if `touse' 
					gen float `lb`c''= invgammap(`disp',(100-`number`c'')/200)/`disp' if `touse'
				}
				else {
					local z = invnorm((100+`number`c'')/200)
					gen float `ub`c''=`ext_stand' + `z'*`ext_sd'/sqrt(`disp') if `touse' 
					gen float `lb`c''=`ext_stand' - `z'*`ext_sd'/sqrt(`disp') if `touse'
				}
			}
		}
		else{
			if ("`beta'"=="" | "`weight'"==""){
				su `disp' if `touse', meanonly
				local ymin `r(min)'
				local ymax `r(max)'
				local steps = `ymax'-`ymin' + 1 
				local step = ceil(`steps'/`n')
				local n = ceil(`steps'/`step')

				set obs `=`obs' + `n''
				replace `touse' = 1 in `=`obs'+1'/l
				replace `disp'=(_n-`obs')*`step'+`ymin' in `=`obs'+1'/l 
				replace `_funnel'=2 in `=`obs'+1'/l 
				
				if ("`beta'" != "") {
					tempvar estd_rpt
					gen float `estd_rpt' = `ext_stand'
				}
			}
			else {
				tempvar proportion
				gen float `proportion' = .
			} 
			sort `disp'
			foreach c in `contours' {
				tempvar ub`c' lb`c'
				gen float `lb`c'' = . 
				gen float `ub`c'' = .
				if "`binomial'"!=""{
					mata: getInvbinom2("`disp'","`touse'", "`lb`c''", "`ub`c''", `ext_stand',`number`c'')
				}
				else if "`poisson'"!=""{
					mata: getInvpoisson2("`disp'","`touse'", "`lb`c''", "`ub`c''", `ext_stand',`number`c'')
				}
				else if ("`beta'"!=""){
					if ("`weight'"!="") {
						replace `proportion' = `disp'/`exp' if `touse'
						mata: getBeta2("`exp'","`proportion'","`touse'", "`lb`c''", "`ub`c''", `number`c'')
						replace `lb`c'' = `lb`c''/`disp'
						replace `ub`c'' = `ub`c''/`disp'
					}
					else {
						mata: getBeta2("`disp'","`estd_rpt'","`touse'", "`lb`c''", "`ub`c''", `number`c'')
						replace `lb`c'' = `lb`c''/`disp'
						replace `ub`c'' = `ub`c''/`disp'
					}
				}
				foreach lim in ub lb{
					replace ``lim'`c''= ``lim'`c''*`constant' 
					label variable ``lim'`c'' `"`lim' for variable `value' at confidence level `lev' assuming `namedistr' distribution"'
				}
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
			label variable `_funnel' "Instruction for funnel"
			label define funnel_label 0 "Not to use" 1 "Points for scatter" 2 "Points for curves"
			label values `_funnel' funnel_label
			local target_val `ext_stand'
			local target_sd `ext_sd'
			foreach char in namedistr target_val target_sd methodcurves{
				char define _dta[`char'] `"``char''"'
			}
			save `namefile',replace
			noi di in ye `"File for funnel plot generation was saved in `namefile'"'
			restore
		}
		/**********************/
		/** GRAPH GENERATION **/
		/**********************/
		noi di in ye "Starting plotting the graph"
		
		local val_label:variable label `value'
		if ("`val_label'"=="") {
			local val_label `value'
		}

		if (`constant'!=1){
			tempvar scaled
			gen float `scaled'=`value'*`constant'
			//what to do with format - could copy format from value, but depending on scale may not be relevant
			local value `scaled'
		}
		//arguments in the correct order according to graph to be plotted vertical or horizontal
		local scatterargs=cond("`vertical'"!="","`disp' `value'","`value' `disp' " )

		//CONTOURS
		// legend for contours
		local i 1 

		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			if "`onesided'" == "lower" {
				local lub`c' lc(none)
				local llb`c' lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts'
				local contourlabels`c' `"`=2*`h' - 1' "Sign. `number`c''%""'
			}
			else if "`onesided'" == "upper" {
				local lub`c' lc(`lc`h'') lp(`lp`h'') lw(thin) `functionupopts'
				local llb`c' lc(none)
				local contourlabels`c' `"`=2*`h' - 1' "Sign. `number`c''%""'
			}
			else{
				local lub`c' lc(`lc`h'') lp(`lp`h'') lw(thin) `functionupopts'
				local llb`c' lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts'
				local contourlabels`c' `"`=2*`h'' "Sign. `number`c''%""'
			}
		}
		//command for contours
		sum `disp' if `touse', meanonly
		local range `r(min)' `r(max)'
		foreach c in `contours'{
			local invnorm = invnorm((100+`number`c'')/200)
			foreach lim in ub lb{
				if "`exact'"==""{
					local functionArgs range(`range') n(`n') `l`lim'`c'' `contourargs' 
					if ("`gamma'" == ""){
						local contourargs=cond("`vertical'"!=""," horizontal","")
						local singlecontour `constant'*(`ext_stand'`plus`lim''`invnorm'*`ext_sd'/sqrt(x))
						if ("`trunc0'"!="" && "`lim'"=="lb"){
							local singlecontour max(`singlecontour',0)
						}
						local function `function' function `singlecontour', `functionArgs' ||
					}
					else if ("`lim'"=="ub") {
						local function `function' function `constant'*invgammap(x+1,(100+`number`c'')/200)/x, `functionArgs' || function `constant'*invgammap(x,(100-`number`c'')/200)/x, `functionArgs' ||
					}
				}
				else{
					local contourargs=cond("`vertical'"!="","`disp' ``lim'`c''","``lim'`c'' `disp'" )
					local function `function' line `contourargs', `l`lim'`c'' || 
				}
			}
			local contourlabels `"`contourlabels' `contourlabels`c''"'
		}
		
		//POINTS
		//marks units specified in -markunits- or -markall- options
		tempvar marker 
		gen byte `marker' = 1 
		
		if (`"`labelunits'"'!="") {
			local labelwords:word count `labelunits'
			capture confirm numeric variable `unit'
			if (_rc==0) {
				local unitvallabel:value label `unit'
				tempname newunitlabel
				if ("`unitvallabel'"==""){
					label define `newunitlabel' `labelunits'
				}
				else {
					label copy `unitvallabel' `newunitlabel'
					label define `newunitlabel' `labelunits', modify
				}
				label values `unit' `newunitlabel'
				forvalues i=1(2)`labelwords'{
					local v:word `i' of `labelunits'
					local markunits `markunits' `v'
				}
			}
			else {
				tempvar unitclone
				gen `unitclone' = `unit'
				forvalues i=1(2)`labelwords'{
					local v:word `i' of `labelunits'
					local r:word `=`i'+1' of `labelunits'
					replace `unitclone' = `"`r'"' if `unitclone' == "`v'"
					local markunits "`markunits'" "`r'"
				}
				local markunits `""`markunits'""'
				local unit `unitclone'
			}
		}
		if (`"`markunits'"'!="") {
			capture confirm numeric variable `unit'
			//some of what follows would be far better managed with a regex, but as far as I am awatre the regex functions onlty replace the FIRST instance
			
			if (_rc==0) {
				//newer regex replace all command
				capture local markunits = ustrregexra("`markunits'", " +", ",")
				if (_rc!=0) {
					while (regexm("`markunits'", " +")){
					   local markunits = regexr("`markunits'", " +", ",")
					}
				}
			}
			else {
				//if version>=14 ustrregexra(`"`markunits'"', `"" +""', `"",""')
				capture local markunits = ustrregexra(`"`markunits'"', `"" +""', `"",""')
				if (_rc!=0) {
					while (regexm(`"`markunits'"', `"" +""')){
						local markunits = regexr(`"`markunits'"', `"" +""', `"",""')
					}
				}
			}
			local ++maxmarkcond
			local markcond`maxmarkcond' inlist(`unit',`markunits')
			local labelcond`maxmarkcond' 1
		}
		if("`markall'"!="") {
			local mainscatteropts mlabel(`unit')
		}
		local mainscatteropts `mainscatteropts' `scatteropts'
		numlist "1(1)`maxmarkcond'"
		foreach i in "" `r(numlist)' {
			if `"`markcond`i''"'!=""{
				if "`optionsmarkcond`i''"==""{
					local optionsmarkcond`i' `"`scatteropts' `optionsmarkcond'"'
				}
				if ("`colormarkcond`i''"==""){
					local colormarkcond`i' `colormarkcond'
				}
				local markval = `i' +4
				replace `marker' = `markval' if `_funnel'==1 & `markcond`i''
				local markconditions `markconditions' scatter `scatterargs' if `marker' == `markval' & `touse', mc(`colormarkcond`i'') `optionsmarkcond`i''
				if ("`labelcond`i''"!="") {
					local markconditions `markconditions' mlabel(`unit') mlabcolor(`colormarkcond`i'')
				}
				local markconditions `markconditions' ||
			}
		}
		
		//marks units upper and/or lower the contour
		foreach lev in up low{
			if `"`mark`lev''"'!=""{
				if ("`lev'"=="up"){
					replace `marker' = 2 if `_funnel'==1 & `value' > `ub`markcontour'' * `constant'
					local ifstate `marker' == 2
				} 
				else {
					replace `marker' = 3 if `_funnel'==1 & `value' < `lb`markcontour'' * `constant'
					local ifstate `marker' == 3
				}
				if "`markscatter`lev'options'"==""{
					local markscatter`lev'options `scatteropts'
				}
				local mark`lev'scatter `mark`lev'scatter' scatter `scatterargs' if `ifstate' & `touse', mc(`mark`lev'color') `markscatter`lev'options' mlabel(`unit') mlabcolor(`mark`lev'color') ||
			}
		}
	}
	//end qui

	// LEGEND
	if "`legendopts'" != "off" {
		// position and other options
		if "`legendopts'" == "" { // default legend options
			local legendopts "ring(0) pos(2) size(small) symxsize(*.4) cols(1)"
		}
		//legend of units
		local legendtot `"order( 1 `"`unitlabel'"' "'
		//legend of conditions
		forv i1=0(1)`=`maxmarkcond'-1' {
			local i=cond(`i1'==0,"","`i1'")
			local ip=`i1'+1
			if `"`markcond`i''"'!="" &`"`legendmarkcond`i''"'!=""{
				local legendtot `"`legendtot' `=2*`ncontours' +1+`ip'' `"`legendmarkcond`i''"' "'
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
	local graph_command `"twoway scatter `scatterargs' if `marker'==1 & `touse' , mc(`scattercolor') `mainscatteropts' || `function' `markupscatter' `marklowscatter' `markconditions' `extraplot' , `x'line(`=`ext_stand'*`constant'',lcolor(`linecolor') ) ytitle(`"`val_label'"') `aspectratio' `y'scale(`reverse') ylabel(, angle(horizontal)) `xtitle' `ytitle' `title' legend(`legendtot') `marktext' `markuptext' `marklowtext' `twowayopts'"'
	if "`displaycommand'"!=""{
		di in ye `"`graph_command'"'
	}
	if "`nodraw'"==""{
		`graph_command'
	}
}
//end capture
//clean up
qui drop if `_funnel'==2
if ("`newunitlabel'"!=""){
	if ("`unitvallabel'"!=""){
		label values `unit' `unitvallabel'
	}
	else {
		label values `unit' .
	}
	label drop `newunitlabel'
}
if _rc!=0 {
	qui error _rc
}

// RETURNED RESULTS
return local target_val "`ext_stand'"
return local target_sd "`ext_sd'"
return local graph_command `"`graph_command'"'

end

/***************************/
/*MATA AUXILIARY FUNCTIONS */
/***************************/

mata:
mata set matastrict on

class interpolResult {
	public real matrix counts, weights
}

class interpolResult stepSearch(real scalar theta, real scalar ci, real colvector pop, pointer(real scalar function) delegate){
real scalar x,n,len,F,found,target,priorF,i;
class interpolResult scalar returnVar;
	len = rows(pop);
	returnVar.counts=J(len,2,.);
	returnVar.weights=J(len,2,.);
	target = (100-ci)/200;
	x=0;
	//find lower bounds of first part of graph
	for(i=1;i<=2;i++) {
		if(i==2){ 
			x = returnVar.counts[1,1];
			target = 1-target;
		}
		for(n=1;n<=len;n++){
			priorF=.;
			found=0;
			do {
				F = (*delegate)(pop[n], x,theta);
				if (F>=target){
					if (x==0){
						returnVar.counts[n,i] = x = 0;
						returnVar.weights[n,i] = 1;
					} 
					else {
						returnVar.counts[n,i]= x;
						if (priorF==.){
							priorF = (*delegate)(pop[n], x-1,theta);
						}
						returnVar.weights[n,i] = (F-target)/(F-priorF);
					}
					found=-1;
				}
				else {
					x++;
					priorF=F;
				}
			} while (!found)
		}
	}
	return(returnVar);
}
//for smr 1-ibetatail(x+1,n-x, p)
//& ub (x,n-x+1, p)
real scalar mybinomial(n,x,theta){
	return(binomial(n,x,theta));
}

void getInvbinom2(string scalar popVar, string scalar touse, string scalar lb, string scalar ub, real scalar theta, | real scalar ci){
real colvector popView;
real matrix transformed;
class interpolResult scalar result;
	if (args() < 6){
		ci = 95;
	}
	st_view(popView,.,popVar,touse);
	result = stepSearch(theta, ci, popView, &mybinomial());
	transformed = (result.counts:-result.weights):/popView;
	st_store(.,(lb,ub), touse, transformed);
}

real scalar mypoisson(n,x,theta){
	return(poisson(n*theta,x));
}

void getInvpoisson2(string scalar popVar, string scalar touse, string scalar lb, string scalar ub, real scalar theta, | real scalar ci){
real colvector popView;
real matrix transformed;
class interpolResult scalar result;
	if (args() < 6){
		ci = 95;
	}
	st_view(popView,.,popVar,touse);
	result = stepSearch(theta, ci, popView, &mypoisson());
	transformed = (result.counts:-result.weights):/popView;
	st_store(.,(lb,ub), touse, transformed);
}


class interpolResult invpoisson2(real scalar theta, real colvector pop){
	expected=theta*n;
	i=0;
	do {
		F = poisson(expected,i)
		if  (F >= p) {
			st_numscalar("r(rp)", i)
			return(i)
		}
		i++
	} while (st_isnumfmt("r(rp)")<1)
}

void getBeta2(string scalar popVar,string scalar thetaVar, string scalar touse, string scalar lb, string scalar ub, | real scalar ci){
real colvector popView, thetaView;
real matrix result;
	if (args() < 6){
		ci = 95;
	}
	st_view(popView,.,popVar,touse);
	st_view(thetaView,.,thetaVar,touse);
	result = GetBetaCis(thetaView, popView, ci);
	st_store(.,(lb,ub), touse, result);
}

class searchArgs {
	public real scalar x,n,p
	public void toString()
}

void searchArgs::toString(){
	printf("x:%f,n:%f,p:%f\n",this.x,this.n,this.p);
}

real scalar BinarySearch(
	real scalar target,
	real scalar minStart,
	real scalar maxStart,
	class searchArgs scalar sa,
	pointer(real scalar function) delegate,
	| real scalar approx,
	real scalar maxIts)
{
	real scalar k, val, argLen, min, max;
	argLen = args();
	if (argLen<6){
		approx = 0.00005;
	}
	if (argLen < 7){
		maxIts = 200;
	}
	min = minStart;
	max = maxStart;
	for(k=0;k<maxIts;k++){
		sa.x = (min+max)/2;
		val = (*delegate)(sa);
		if (val >= .) {
		  return(.);
		}
		if ((abs(val-target)<=approx)){
		  return(sa.x)
		}
		if (val<target) {
		  min = sa.x;
		} else {
		  max = sa.x;
		}
	} 
	return(.);
}

real scalar LbBeta(class searchArgs sa){
    return(ibetatail(sa.x+1,sa.n-sa.x, sa.p))
}
  
real scalar UbBeta(class searchArgs sa){
    return(1-ibetatail(sa.x,sa.n-sa.x+1, sa.p))
}
real matrix GetBetaCis(
	real colvector thetaVector,
	real colvector popVector,
	| real scalar ci)
{
real scalar len, i, lastLb,lastUb
real matrix returnVar
class searchArgs scalar sa
	
	if (args()<2){ci=95;}
	target = (100-ci)/200;
	len = rows(popVector);

	returnVar = J(len, 2, .);

	lastLb=0;
	lastUb=0;

	for (i = 1;i<=len;i++)
	{
		sa.n=popVector[i];
		sa.p=thetaVector[i];
		sa.x=0;
		if (LbBeta(sa)<target) {
		  lastLb=BinarySearch(target, 0, sa.n*sa.p, sa, &LbBeta());
		  returnVar[i,1]=lastLb;
		}else{
		  returnVar[i,1]= 0;
		  lastLb=0;
		}
		sa.x=sa.n;
		if (UbBeta(sa)<target){
		  lastUb=BinarySearch(target, sa.n, sa.n*sa.p, sa, &UbBeta());
		  returnVar[i,2] = lastUb;
		} else {
		  lastUb=returnVar[i,2]=sa.n;
		}
	}
	return(returnVar);
}

end
