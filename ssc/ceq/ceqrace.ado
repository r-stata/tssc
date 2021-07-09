


*ADO FILE FOR CEQ ETHNO RACIAL WORKBOOK

*VERSION AND NOTES (changes between versions described under CHANGES)
*! v2.4 29oct2016 For use with December 3 2015 version of Ethno Racial Workbook
*! (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

*CHANGES
*...
*v2.1 Changes in F23: educational probability
*v2.2 Solved loading error
*v2.3 Changes in F21 (consistency between population attending= target pop)

*NOTES

*TO DO

************************
* PRELIMINARY PROGRAMS *
************************
#delimit cr

// BEGIN _theil 
// (code adapted from inequal7, Van Kerm 2001, revision of inequal, Whitehouse 1995)
capture program drop _theil
cap program define _theil, rclass sortpreserve
	syntax varname [if] [in] [pw fw aw iw]
	quietly {
		local var `varlist'
		preserve
		marksample touse
		qui keep if `touse'
		sort `var'
		qui count
		local N = r(N)
		if "`exp'"!="" {
			local aw [aw`exp']
			local pw [pw`exp']
		}
		else {
			local aw ""
			local pw ""
		}
		foreach x in temp_theil i tmptmp {
			tempvar `x'
			qui gen ``x''=.
		}
		local wt = word("`exp'",2) // (word 1 is "=")
		if "`wt'"=="" {
			qui replace `i' = _n
			local wt = 1
		}
		else {
			qui replace `tmptmp' = sum(`wt')
			qui replace `i' = ((2*`tmptmp')-`wt'+1)/2
		}
		qui summ `var' `aw' if `var'>0
		local mean = r(mean)
		local sumw = r(sum_w)
		// note that the following two lines from inequal7 were changed
		// by Azevedo in ainequal and the two differ in the 3rd dec place
		qui replace `temp_theil' = sum(`wt'*((`var'/`mean')*(log(`var'/`mean'))))
		local theil = `temp_theil'[`N']/`sumw'
		return scalar theil = `theil'
		restore
	} // end quietly
end // END _theil

* Program to compute Gini coefficient;* GINI USING COVARIANCE FORMULA
* Makes two adjustments relative to the "naive" approach:
*  first is to multiply by (N-1)/N to adjust for the fact that Stata uses sample covariance
*  second is to estimate F(y) using Lerman and Yitzhaki (1989); weighted fractional ranks would give biased estimate
* With these two adjustments, covgini gives same answer as Gini commands based on 
*  discrete formulas to 9 decimal places
*v1.0 5/18/2015 Sean Higgins, shiggins@tulane.edu

cap program drop covgini
program define covgini, rclass sortpreserve
	syntax varname [if] [in] [pw aw iw fw/]
	preserve
	marksample touse
	qui keep if `touse' // drops !`if', !`in', and any missing values of `varname'
	local 1 `varlist'
	sort `1' // sort in increasing order of incomes
	tempvar F wnorm wsum // F is adjusted fractional rank, wnorm normalized weights,
		// wsum sum of normalized weights for obs 1, ..., i-1
	if "`exp'"!="" { // with weights
		local 2 `exp'
		qui summ `2'
		qui gen `wnorm' = `2'/r(sum) // weights normalized to sum to 1
		qui gen double `wsum' = sum(`wnorm')
		qui gen double `F' = `wsum'[_n-1] + `wnorm'/2 // from Lerman and Yitzhaki (1989)
		qui replace `F' = `wnorm'/2 in 1
		qui corr `1' `F' [aw=`2'], cov
		local cov = r(cov_12)
		qui summ `1' [aw=`2'], meanonly 
		local mean = r(mean)
	}
	else { // no weights
		qui gen `F' = _n/_N // sorted so this works in unweighted case; 
			// cumul `1', gen(`F') would also work
		qui corr `1' `F', cov
		local cov = r(cov_12)
		qui summ `1', meanonly
		local mean = r(mean)
	}
	local gini = ((r(N)-1)/r(N))*(2/`mean')*`cov' // the (N-1)/N term adjusts for
		// the fact that Stata does sample cov
	return scalar gini = `gini'
	di as result "Gini: `gini'"
	restore
end

#delimit;
*******************
* ceqrace PROGRAM *
*******************;

cap program drop ceqrace ;




program  ceqrace;
version 13.0;
syntax   [if] [in] [using/] [pweight/] 
		[, table(string) 
		   Market(varname) 
		   race1(varname) 
		   race2(varname) 
		   race3(varname) 
		   race4(varname) 
		   race5(varname)
		   Original(varname)
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Consumable(varname)
		   Final(varname) 
		   PL125(string)				
			PL250(string)               
			PL400(string) 
		   NEXTreme(string)
		   NMODerate(string)
		   psu(varname)   
		   strata(varname) 
		   dtax(varname)
		   CONTributions(varname)
		   CONTPensions(varname)
		   CONYPensions(varname)
		   NONContributory(varname)
		   flagcct(varname)
		   OTRANsfers(varname)
		   ISUBsidies(varname)
		   itax(varname)
		   IKEducation(varname)
		   IKHealth(varname)
		   HUrban(varname)
		   age(varname) 
		   edpre(varname)
		   edpri(varname) 
		   edsec(varname) 
		   edter(varname)
		   redpre(varname)
		   redpri(varname) 
		   redsec(varname) 
		   redter(varname) 
		   attend(varname)
		   EDPUBlic(varname)
		   EDPRIVate(varname)
		   hhe(varname) 
		   hhid(varname)
		   CCT(varname)
		   SCHolarships(varname)
		   UNEMPloyben(varname)
		   FOODTransfers(varname)
		   HEALTH(varname)
		   PENSions(varname)
		   TARCCT(varname)
		   TARNCP(varname)
		   TARPENsions(varname)
		   water(varname)
		   electricity(varname)
		   walls(varname)
		   floors(varname)
		   roof(varname)
		   sewage(varname)
		   roads(varname)
		   gender(varname)
		   URban(varname)
           edpar(varname)
		   OPEN
			*
		   
		     ];

di "hi!";
	
*******General Options**************************************************************************;
* general programming locals;
	local dit display as text in smcl;
	local die display as error in smcl;
	local command ceqrace;
		local version 2.4;
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "(please report this information if reporting a bug to raranda@tulane.edu)";
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");
#delimit cr
	* income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local alllist m mp n g t d c f
	local origlist m mp n g d
	

	* make sure using is xls or xlsx
	cap putexcel clear
	if `"`using'"'!="" {
		local period = strpos("`using'",".")
		if `period'>0 { // i.e., if `"`using'"' contains .
			local ext = substr("`using'",`period',.)
			if "`ext'"!=".xls" & "`ext'"!=".xlsx" {
				`die' "File extension must be .xls or .xlsx to write to an existing CEQ Master Workbook (requires Stata 13 or newer)"
				exit 198
			}
		}
		else {
			local using `"`using'.xlsx"'
			qui di "
			`dit' "File extension of {bf:using} not specified; .xlsx assumed"
		}
		// give error if file doesn't exist:
		confirm file `"`using'"'
		qui di "
	}
	else { // if "`using'"==""
		`dit' "Warning: No file specified with {bf:using}; results not exported to Ethno Racial Tables"
	}
	if strpos(`"`using'"'," ")>0 & "`open'"!="" { // has spaces in filename
		qui di "
		`dit' `"Warning: `"`using'"' contains spaces; {bf:open} option will not be executed. File can be opened manually after dII runs."'
		local open "" // so that it won't try to open below
	}
	
	/*
	if "`table'"=="f5" | "`table'"=="f6" | "`table'"=="f7" | "`table'"=="f8" | "`table'"=="f9" | "`table'"=="f13" | "`table'"=="f16" | "`table'"=="f17" |	 "`table'"=="f18" | "`table'"=="f20" | "`table'"=="f21" | "`table'"=="f23" | "`table'"=="f24" {
 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	}
	*/
#delimit;	
local cc=0;
forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
};
if `cc'>3{;
display as error "Must specify at least two ethnic groups or races";
exit;
};

	#delimit;
		

forvalues tt=1/27{;//Run each particular program;
if "`table'"=="f`tt'"{;
f`tt'_race `0';
};
};

	
end;

*forvalues tt=1/27{;
*cap program drop f`tt'_race;
*};

*******TABLE F3: ETHNO-RACIAL POPULATIONS**************************************************************************;

program define f3_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN];
di "Populations `'";
local sheet="F3. Ethno-Racial Populations";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");


  *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
	
forvalues x=1/5{;
	if "`race`x''"==""{;
		local cc=`cc'+1;
		tempvar race`x';
		gen `race`x''=.;
		};
	};

	qui{;
		matrix f3_1=J(6,1,.);
		matrix f3_2=J(6,1,.);
		tempvar tot;
		gen `tot'=1;
		matrix colnames f3_1="Survey unweighted";
		matrix colnames f3_2="Survey weighted";
		matrix rownames f3_1=race1 race2 race3 race4 race5 tot;
		matrix rownames f3_2=race1 race2 race3 race4 race5 tot;
		forvalues x=1/5{;
			local c=`c'+1;
			summ `race`x'' ;
			matrix f3_1[`c',1]=r(sum);

			summ `race`x'' [w=`w'];
			matrix f3_2[`c',1]=r(sum);
		};
		summ `tot' ;
		matrix f3_1[6,1]=r(sum);

		summ `tot' [w=`w'];
		matrix f3_2[6,1]=r(sum);

		noisily di "Population totals Survey-unweighted";
		noisily matrix list f3_1;
		noisily di "Population totals Survey-weighted";
		noisily matrix list f3_2;
		putexcel C8=matrix(f3_1) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel D8=matrix(f3_2) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	};
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;

end;
*******TABLE F5: Composition**************************************************************************;

program define f5_race;
syntax  [if] [in]  [pweight/] [using/] [,table(string) Market(varname) Disposable(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN
			Original(varname)
			PL125(string)
			PL250(string)
			PL400(string)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			hhid(varname)];
di "Composition `'";
local sheet="F5. Composition";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	

   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		forvalues x=1/5{;
	if "`race`x''"==""{;
		local cc=`cc'+1;
		tempvar race`x';
		gen `race`x''=.;
		};
	};

	****Poverty variables****;
	if "`table'"=="f5"{;
		if "`original'"=="" {;
		display as error "Must specify Original(varname) option";
		exit;
		};
		if "`disposable'"=="" {;
		display as error "Must specify Disposable(varname) option";
		exit;
		};
		
		local listv original disposable;
		foreach x in `listv'{;
			tempvar `x'_ppp;
			 gen ``x'_ppp' = (``x''/`divideby')*(1/`ppp_calculated');
		};
		tempvar g_o;

	gen `g_o'=. ;
	replace `g_o'=1 if `original_ppp'<`cut1';
	replace `g_o'=2 if `original_ppp'>=`cut1' & `original_ppp'<`cut2';
	replace `g_o'=3 if `original_ppp'>=`cut2' & `original_ppp'<`cut3';
	replace `g_o'=4 if `original_ppp'>=`cut3' & `original_ppp'<`cut4';
	replace `g_o'=5 if `original_ppp'>=`cut4' & `original_ppp'<`cut5';
	replace `g_o'=6 if `original_ppp'>=`cut5' & `original_ppp'!=.;

*New comparable deciles;
tempvar memb;
tempvar hhs;
tempvar incdec;
tempvar d_1o;
tempvar d_o;
bys `hhid': gen `memb' = _n;
bys `hhid': gen `hhs' = _N;
gen `incdec'=`original_ppp' if `memb'==1;
qui quantiles `incdec' [aw=`w'*`hhs'], gen(`d_1o') n(10) stable;
egen `d_o' = mean(`d_1o'),by(`hhid');

	
	
		*qui quantiles `original_ppp' [aw=`w'], gen(`d_o') n(10) stable;
	
	tempvar g_d;
	gen `g_d'=. ;
	replace `g_d'=1 if `disposable_ppp'<`cut1';
	replace `g_d'=2 if `disposable_ppp'>=`cut1' & `disposable_ppp'<`cut2';
	replace `g_d'=3 if `disposable_ppp'>=`cut2' & `disposable_ppp'<`cut3';
	replace `g_d'=4 if `disposable_ppp'>=`cut3' & `disposable_ppp'<`cut4';
	replace `g_d'=5 if `disposable_ppp'>=`cut4' & `disposable_ppp'<`cut5';
	replace `g_d'=6 if `disposable_ppp'>=`cut5';

tempvar incdec2;
tempvar d_1d;
tempvar d_d;
gen `incdec2'=`disposable_ppp' if `memb'==1;
qui quantiles `incdec2' [aw=`w'*`hhs'], gen(`d_1d') n(10) stable;
egen `d_d' = mean(`d_1d'),by(`hhid');

*	tempvar d_d;
*		qui quantiles `disposable_ppp' [aw=`w'], gen(`d_d') n(10) stable;


	};
	qui{;
		matrix f5_1=J(10,5,.);
		matrix f5_2=J(6,5,.);
		matrix colnames f5_1=race1 race2 race3 race4 race5;
		matrix colnames f5_2=race1 race2 race3 race4 race5;
		matrix rownames f5_1=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10;
		matrix rownames f5_2=y125 y250 y4 y10 y50 ym50;
		
		matrix f5_3=J(10,5,.);
		matrix f5_4=J(6,5,.);
		matrix colnames f5_3=race1 race2 race3 race4 race5;
		matrix colnames f5_4=race1 race2 race3 race4 race5;
		matrix rownames f5_3=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10;
		matrix rownames f5_4=y125 y250 y4 y10 y50 ym50;

		forvalues x=1/5{;
			forvalues y=1/10{;

				summ `race`x'' [aw=`w'] if `d_o'==`y';
				matrix f5_1[`y',`x']=round(r(sum));
				summ `race`x'' [aw=`w'] if `d_d'==`y';
				matrix f5_3[`y',`x']=round(r(sum));
				};

			forvalues y=1/6{;

				summ `race`x'' [aw=`w'] if `g_o'==`y';
				matrix f5_2[`y',`x']=round(r(sum));
				summ `race`x'' [aw=`w'] if `g_d'==`y';
				matrix f5_4[`y',`x']=round(r(sum));
				};
			};
		noisily di "Population by decile (Original income)";
		noisily matrix list f5_1;
		noisily di "Population by socioeconomic group (Original income)";
		noisily matrix list f5_2;
		noisily di "Population by decile (Disposable income)";
		noisily matrix list f5_3;
		noisily di "Population by socioeconomic group (Disposable income)";
		noisily matrix list f5_4;
		putexcel C11=matrix(f5_1) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C27=matrix(f5_2) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C42=matrix(f5_3) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C58=matrix(f5_4) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;

*******TABLE F6: Distribution**************************************************************************;

program define f6_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Disposable(varname)  race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN
			Original(varname)
			PL125(string)
			PL250(string)
			PL400(string)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			hhid(varname)];
	di "Distribution `'";
	local sheet="F6. Distribution";
		local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
	forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
	};
****Poverty variables****;

		if "`original'"=="" {;
			display as error "Must specify Original(varname) option";
			exit;
		};
		if "`disposable'"=="" {;
			display as error "Must specify Disposable(varname) option";
			exit;
		};
		*if "`pl125'"=="" | "`pl250'"=="" | "`pl400'"=="" {;
		*	display as error "Must specify Poverty lines for 1.25, 2.50 and 4.00 PPP";
		*	exit;
		*};
		
		*local pl1000=`pl250'*4;
		*local pl5000=`pl250'*20;
	local listv original disposable;
		foreach x in `listv'{;
			tempvar `x'_ppp;
			 gen ``x'_ppp' = (``x''/`divideby')*(1/`ppp_calculated');
		};
		
	tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if `original_ppp'<`cut1';
	replace `g_o'=2 if `original_ppp'>=`cut1' & `original_ppp'<`cut2';
	replace `g_o'=3 if `original_ppp'>=`cut2' & `original_ppp'<`cut3';
	replace `g_o'=4 if `original_ppp'>=`cut3' & `original_ppp'<`cut4';
	replace `g_o'=5 if `original_ppp'>=`cut4' & `original_ppp'<`cut5';
	replace `g_o'=6 if `original_ppp'>=`cut5' & `original_ppp'!=.;

	tempvar memb;
	tempvar hhs;
	tempvar incdec;
	tempvar d_1o;
	tempvar d_o;
	bys `hhid': gen `memb' = _n;
	bys `hhid': gen `hhs' = _N;
	gen `incdec'=`original_ppp' if `memb'==1;
	qui quantiles `incdec' [aw=`w'*`hhs'], gen(`d_1o') n(10) stable;
	egen `d_o' = mean(`d_1o'),by(`hhid');
	*tempvar d_o;
	
	*	qui quantiles `original_ppp' [aw=`w'], gen(`d_o') n(10) stable;
	
	tempvar g_d;
	gen `g_d'=. ;
	replace `g_d'=1 if `disposable_ppp'<`cut1';
	replace `g_d'=2 if `disposable_ppp'>=`cut1' & `disposable_ppp'<`cut2';
	replace `g_d'=3 if `disposable_ppp'>=`cut2' & `disposable_ppp'<`cut3';
	replace `g_d'=4 if `disposable_ppp'>=`cut3' & `disposable_ppp'<`cut4';
	replace `g_d'=5 if `disposable_ppp'>=`cut4' & `disposable_ppp'<`cut5';
	replace `g_d'=6 if `disposable_ppp'>=`cut5';


	tempvar incdec2;
	tempvar d_1d;
	tempvar d_d;
	gen `incdec2'=`disposable_ppp' if `memb'==1;
	qui quantiles `incdec2' [aw=`w'*`hhs'], gen(`d_1d') n(10) stable;
	egen `d_d' = mean(`d_1d'),by(`hhid');

	*	tempvar d_d;
	*		qui quantiles `disposable_ppp' [aw=`w'], gen(`d_d') n(10) stable;


	
	qui{;
		matrix f6_1=J(10,5,.);
		matrix f6_2=J(6,5,.);
		matrix colnames f6_1=race1 race2 race3 race4 race5;
		matrix colnames f6_2=race1 race2 race3 race4 race5;
		matrix rownames f6_1=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10;
		matrix rownames f6_2=y125 y250 y4 y10 y50 ym50;

		matrix f6_3=J(10,5,.);
		matrix f6_4=J(6,5,.);
		matrix colnames f6_3=race1 race2 race3 race4 race5;
		matrix colnames f6_4=race1 race2 race3 race4 race5;
		matrix rownames f6_3=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10;
		matrix rownames f6_4=y125 y250 y4 y10 y50 ym50;
		
		forvalues x=1/5{;
			forvalues y=1/10{;

				summ `original' [aw=`w'] if `d_o'==`y' & `race`x''==1;
				matrix f6_1[`y',`x']=r(sum);
				
				summ `disposable' [aw=`w'] if `d_d'==`y' & `race`x''==1;
				matrix f6_3[`y',`x']=r(sum);

			};

			forvalues y=1/6{;

				summ `original' [aw=`w'] if `g_o'==`y' & `race`x''==1;
				matrix f6_2[`y',`x']=r(sum);

				summ `disposable' [aw=`w'] if `g_d'==`y' & `race`x''==1;
				matrix f6_4[`y',`x']=r(sum);
			
			};
		};
		noisily di "Income by decile (Original Income)";
		noisily matrix list f6_1;
		noisily di "Income by socioeconomic group (Original Income)";
		noisily matrix list f6_2;
		noisily di "Income by decile (Disposable Income)";
		noisily matrix list f6_3;
		noisily di "Income by socioeconomic group (Disposable Income)";
		noisily matrix list f6_4;
		
		putexcel C11=matrix(f6_1) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C27=matrix(f6_2) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C41=matrix(f6_3) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C57=matrix(f6_4) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;

*******TABLE F7: Poverty**************************************************************************;

program define f7_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) 
		   	PL250(string)
			PL400(string)
		   NEXTreme(string)
		   NMODerate(string)
		   PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
	di "Poverty `'";
	local sheet="F7. Poverty";
		local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
			if "`race`x''"==""{;
				local cc=`cc'+1;
				tempvar race`x';
				gen `race`x''=.;
			};
		};
****Poverty variables****;

	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};
if  "`nextreme'"==""  | "`nmoderate'"==""{;
			display as error "Must specify Poverty lines for national lines";
			exit;
		};
		
	qui{;	
	local p1=`cut2';
	local p2=`cut3';
   *local nextreme_ppp== (`nextreme'/`divideby')*(1/`ppp_calculated');
   *local nmoderate_ppp== (`nmoderate'/`divideby')*(1/`ppp_calculated');

	local p3="`nextreme'";
	local p4="`nmoderate'";

	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' ;
	local lines `p1' `p2' `p3' `p4';

	di `incomes';
	
		matrix f7_1=J(4,7,.);
		matrix f7_2=J(4,7,.);
		matrix f7_3=J(4,7,.);
		matrix f7_4=J(4,7,.);
		matrix colnames f7_1=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f7_2=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f7_3=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f7_4=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix rownames f7_1=indig white afro national;
		matrix rownames f7_2=indig white afro national;
		matrix rownames f7_3=indig white afro national;
		matrix rownames f7_4=indig white afro national;
		
		forvalues z=1/4{;//poverty lines;
			local c=0;
			
			foreach y in `incomes'{;
				local c=`c'+1;
				tempvar `y'_ppp;
			 gen ``y'_ppp' = (`y'/`divideby')*(1/`ppp_calculated');
			 
				tempvar pov`z'_`y';
				if `z'<3{;
					gen `pov`z'_`y''=cond(``y'_ppp'<`p`z'',1,0);
				};
				else{;
				gen `pov`z'_`y''=cond(`y'<`p`z'',1,0);
				};
				
					forvalues x=1/3{;
						summ `pov`z'_`y'' [w=`w'] if `race`x''==1;
						matrix f7_`z'[`x',`c']=r(mean);
					};
				*tempvar pov`z'_`y';
				*gen `pov`z'_`y''=cond( ``y'_ppp'<`p`z'',1,0);

				summ `pov`z'_`y'' [w=`w'];
				matrix f7_`z'[4,`c']=r(mean);

			};
		};
		noisily di "Extreme Poverty";
		noisily matrix list f7_1;
		noisily di "Moderate Poverty";
		noisily matrix list f7_2;
		noisily di "National Extreme Poverty";
		noisily matrix list f7_3;
		noisily di "National Moderate Poverty";
		noisily matrix list f7_4;

		putexcel C7=matrix(f7_1) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C21=matrix(f7_2) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C35=matrix(f7_3) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel C49=matrix(f7_4) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;
*******TABLE F8: Poverty Gap**************************************************************************;

program define f8_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) 
			PL250(string)
			PL400(string)
		   NEXTreme(string)
		   NMODerate(string)
		   PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
	di "Poverty Gap`'";
	local sheet="F8. Poverty Gap";
		local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
	forvalues x=1/5{;
		if "`race`x''"==""{;
		local cc=`cc'+1;
		tempvar race`x';
		gen `race`x''=.;
		};
	};

	****Poverty variables****;

	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};

	local p1=`cut2';
	local p2=`cut3';
	*   local nextreme_ppp== (`nextreme'/`divideby')*(1/`ppp_calculated');
   *local nmoderate_ppp== (`nmoderate'/`divideby')*(1/`ppp_calculated');

	local p3="`nextreme'";
	local p4="`nmoderate'";

	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' ;
	local lines `p1' `p2' `p3' `p4';

	di `incomes';

	qui{;
		matrix f8_1=J(4,7,.);
		matrix f8_2=J(4,7,.);
		matrix f8_3=J(4,7,.);
		matrix f8_4=J(4,7,.);
		matrix colnames f8_1=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f8_2=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f8_3=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f8_4=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix rownames f8_1=indig white afro national;
		matrix rownames f8_2=indig white afro national;
		matrix rownames f8_3=indig white afro national;
		matrix rownames f8_4=indig white afro national;
		forvalues z=1/4{;
			local c=0;
			
			foreach y in `incomes'{;
				local c=`c'+1;
				tempvar `y'_ppp;
			 gen ``y'_ppp' = (`y'/`divideby')*(1/`ppp_calculated');
				forvalues x=1/3{;
					tempvar gap`z'_`y';
					gen `gap`z'_`y''=0;
					if `z'<3{;
						replace `gap`z'_`y''=(`p`z''-``y'_ppp' )/`p`z'' if `race`x''==1 & ``y'_ppp'<`p`z'';
					};
					else{;
					replace `gap`z'_`y''=(`p`z''-`y' )/`p`z'' if `race`x''==1 & `y'<`p`z'';

					};
					summ `gap`z'_`y'' [w=`w'] if `race`x''==1;
					matrix f8_`z'[`x',`c']=r(mean);
				};
				tempvar gap`z'_`y';
				gen `gap`z'_`y''=0;
				if `z'<3{;
					replace `gap`z'_`y''=(`p`z''-``y'_ppp')/`p`z'' if ``y'_ppp'<`p`z'';
				};
				else{;
					replace `gap`z'_`y''=(`p`z''-`y')/`p`z'' if `y'<`p`z'';
				};
				summ `gap`z'_`y'' [w=`w'];
				matrix f8_`z'[4,`c']=r(mean);

			};
		};
		noisily di "Extreme Poverty Gap";
		noisily matrix list f8_1;
		noisily di "Moderate Poverty Gap";
		noisily matrix list f8_2;
		noisily di "National Extreme Poverty Gap";
		noisily matrix list f8_3;
		noisily di "National Moderate Poverty Gap";
		noisily matrix list f8_4;

		putexcel C7=matrix(f8_1) using `using',keepcellformat modify sheet("`sheet'") ;
		putexcel C21=matrix(f8_2) using `using',keepcellformat modify sheet("`sheet'");
		putexcel C35=matrix(f8_3) using `using',keepcellformat modify sheet("`sheet'");
		putexcel C49=matrix(f8_4) using `using',keepcellformat modify sheet("`sheet'");
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;

*******TABLE F9: Poverty Gap Squared**************************************************************************;

program define f9_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) 
		   	PL250(string)
			PL400(string)
		   NEXTreme(string)
		   NMODerate(string)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];

	di "Poverty Gap Squared `'";
	local sheet="F9. Poverty Gap Sq.";
		local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
	forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
	};
****Poverty variables****;

	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};

	local p1=`cut2';
	local p2=`cut3';
	local p3="`nextreme'";
	local p4="`nmoderate'";


	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' ;
	local lines `p1' `p2' `p3' `p4';

	di `incomes';

	qui{;
		matrix f9_1=J(4,7,.);
		matrix f9_2=J(4,7,.);
		matrix f9_3=J(4,7,.);
		matrix f9_4=J(4,7,.);
		matrix colnames f9_1=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f9_2=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f9_3=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix colnames f9_4=market mpluspensions netmarket gross taxable disposable consumable ;
		matrix rownames f9_1=indig white afro national;
		matrix rownames f9_2=indig white afro national;
		matrix rownames f9_3=indig white afro national;
		matrix rownames f9_4=indig white afro national;
			
		forvalues z=1/4{;
			local c=0;
			
			foreach y in `incomes'{;
				local c=`c'+1;
				tempvar `y'_ppp;
			 gen ``y'_ppp' = (`y'/`divideby')*(1/`ppp_calculated');
				forvalues x=1/3{;
					tempvar gap2`z'_`y';
					gen `gap2`z'_`y''=0;
					if `z'<3{;
						replace `gap2`z'_`y''=((`p`z''-``y'_ppp')/`p`z'')^2 if `race`x''==1 & ``y'_ppp'<`p`z'';
					};
					else{;
						replace `gap2`z'_`y''=((`p`z''-`y')/`p`z'')^2 if `race`x''==1 & `y'<`p`z'';
					};
					summ `gap2`z'_`y'' [w=`w'] if `race`x''==1;
					matrix f9_`z'[`x',`c']=r(mean);
				};
				tempvar gap2`z'_`y';
				gen `gap2`z'_`y''=0;
				if `z'<3{;
					replace `gap2`z'_`y''=((`p`z''-``y'_ppp')/`p`z'')^2 if ``y'_ppp'<`p`z'';
				};
				else{;
					replace `gap2`z'_`y''=((`p`z''-`y')/`p`z'')^2 if `y'<`p`z'';

				};
				summ `gap2`z'_`y'' [w=`w'];
				matrix f9_`z'[4,`c']=r(mean);

			};
		};
		noisily di "Extreme Poverty Gap";
		noisily matrix list f9_1;
		noisily di "Moderate Poverty Gap";
		noisily matrix list f9_2;
		noisily di "National Extreme Poverty Gap";
		noisily matrix list f9_3;
		noisily di "National Moderate Poverty Gap";
		noisily matrix list f9_4;

		putexcel C7=matrix(f9_1) using `using',keepcellformat modify sheet("`sheet'") ;
		putexcel C21=matrix(f9_2) using `using',keepcellformat modify sheet("`sheet'");
		putexcel C35=matrix(f9_3) using `using',keepcellformat modify sheet("`sheet'");
		putexcel C49=matrix(f9_4) using `using',keepcellformat modify sheet("`sheet'");
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;
*******TABLE F10: Inequality**************************************************************************;

program define f10_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		    Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname)  
		   psu(varname)   
		   strata(varname) 
		  ];
	di "Inequality `'";
	local sheet="F10. Inequality";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	
	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		
***Svy options;
	cap svydes;
	scalar no_svydes = (c(rc)!=0);
	qui svyset;
	if "`r(wvar)'"=="" & "`exp'"=="" {;
		di as text "WARNING: weights not specified in svydes or the ceqrace command";
		di as text "Hence, equal weights (simple random sample) assumed";
	};
	else if "`r(su1)'"=="" & "`psu'"=="" {;
		di as text "WARNING: primary sampling unit not specified in svydes or the ceqrace command's psu() option";
		di as text "P-values will be incorrect if sample was stratified";
	};
	if "`psu'"=="" & "`r(su1)'"!="" {;
		local psu `r(su1)';
	};
	if "`strata'"=="" & "`r(strata1)'"!="" {;
		local strata `r(strata1)';
	};
	if "`exp'"=="" & "`r(wvar)'"!="" {;
		local weight "pw";
		local exp "= `r(wvar)'";
	};
	if "`strata'"!="" {;
		local opt strata(`strata');
	};
	
	* now set it:;
	if "`exp'"!="" qui svyset `psu' `pw', `opt';
	else           qui svyset `psu', `opt';
		

	forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
			local id`x'=1;//local that tells us if variable has only missing values;
		};
		else{;
		local id`x'=0;
		};
	};

	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};


	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' `final';

	di `incomes';

	qui{;
	matrix f10_1=J(4,8,.);
	matrix f10_2=J(4,8,.);
	matrix f10_3=J(4,8,.);

	matrix colnames f10_1=market mpluspensions netmarket gross taxable disposable consumable final;
	matrix colnames f10_2=market mpluspensions netmarket gross taxable disposable consumable final;
	matrix colnames f10_3=market mpluspensions netmarket gross taxable disposable consumable final;
	matrix rownames f10_1=indig white afro national;
	matrix rownames f10_2=indig white afro national;
	matrix rownames f10_3=indig white afro national;
	
	forvalues z=1/3{;
		local c=0;
		
		foreach y in `incomes'{;
			local c=`c'+1;
			
			forvalues x=1/3{;
				if `z'==1 {;//gini;
					*digini `y' `market' ,cond1(`race`x'');
					*matrix d`x'`y'`z'=e(d1);
					*scalar r`x'`y'`z'=d`x'`y'`z'[1,1];
					if `id`x''==1{;
					matrix f10_`z'[`x',`c']=.;
					};
					else{;
						qui covgini `y' [w=`w'] if `race`x''==1;
						matrix f10_`z'[`x',`c']=r(gini);
					};
				};
				
				if `z'==2{;//theil;
					*dientropy `y' `market' , cond1(`race`x'') theta(1);
					*matrix d`x'`y'`z'=e(d1);
					*scalar r`x'`y'`z'=d`x'`y'`z'[1,1];
					if `id`x''==1{;
						matrix f10_`z'[`x',`c']=.;
					};
					else{;
						_theil `y' [w=`w'] if `race`x''==1;
						matrix f10_`z'[`x',`c']=r(theil);
					};
				};
				
				if `z'==3{;
					*dinineq `y' `market'  , p1(.9) p2(.1) cond1(`race`x'');
					*matrix d`x'`y'`z'=e(d1);
					*scalar r`x'`y'`z'=d`x'`y'`z'[1,1];
					*matrix f10_`z'[`x',`c']=r`x'`y'`z';
					if `id`x''==1{;
						matrix f10_`z'[`x',`c']=.;
					};
					else{;
					_pctile `y' [w=`w'] if `race`x''==1,n(100) ;
					matrix f10_`z'[`x',`c']= r(r90)/r(r10);
					};
				};
			};
				if `z'==1{;
					*digini `y' `market'  ;
					*matrix d`y'`z'=e(d1);
					*scalar r`y'`z'=d`y'`z'[1,1];
					*matrix f10_`z'[4,`c']=r`y'`z';
					
					
						qui covgini `y' [w=`w'];
						matrix f10_`z'[4,`c']=r(gini);
						
				};
				
				if `z'==2{;
					*dientropy `y' `market'  , theta(1);
					*matrix d`y'`z'=e(d1);
					*scalar r`y'`z'=d`y'`z'[1,1];
					_theil `y' [w=`w'] ;
					matrix f10_`z'[4,`c']=r(theil);
				};
				
				if `z'==3{;
					*dinineq `y' `market' , p1(.9) p2(.1);
					*matrix d`y'`z'=e(d1);
					*scalar r`y'`z'=d`y'`z'[1,1];
					*matrix f10_`z'[4,`c']=r`y'`z';
					_pctile `y' [w=`w'],n(100) ;
					matrix f10_`z'[4,`c']= r(r90)/r(r10);
				};


			};
		};
		
		noisily di "Gini";
		noisily matrix list f10_1;
		noisily di "Theil";
		noisily matrix list f10_2;
		noisily di "90/10 Ratio";
		noisily matrix list f10_3;

		putexcel C7=matrix(f10_1) using `using',keepcellformat modify sheet("`sheet'") ;
		putexcel C21=matrix(f10_2) using `using',keepcellformat modify sheet("`sheet'");
		putexcel C35=matrix(f10_3) using `using',keepcellformat modify sheet("`sheet'");
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;

*******TABLE F11: Mean income**************************************************************************;

program define f11_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) ];
	local sheet="F11. Mean Income";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	
	
	*if !_rc{
	*qui svyset // gets the results saved in return list
	*}
	
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		forvalues x=1/5{;
			if "`race`x''"==""{;
				local cc=`cc'+1;
				tempvar race`x';
				gen `race`x''=.;
			};
		};
****Income variables****;

	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};


	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' `final';
	*di `incomes';


	qui{;
		matrix f11_1=J(4,8,.);
		matrix colnames f11_1=market mpluspensions netmarket gross taxable disposable consumable final;
		matrix rownames f11_1=indig white afro national;
		
		
		
		local c=0;
		
		foreach y in `incomes'{;
			local c=`c'+1;
			
			forvalues x=1/3{;
					summ `y' [w=`w'] if `race`x''==1;
					matrix f11_1[`x',`c']=r(mean);
				};
				
					summ `y' [w=`w'];
					matrix f11_1[4,`c']=r(mean);
			};	
	
		noisily di "Mean income in LCU";
		noisily matrix list f11_1;
		
		putexcel C7=matrix(f11_1) using `using', modify sheet("`sheet'") keepcellformat;
		putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;	
	};
end;
*******TABLE F12: Incidence (decile)**************************************************************************;

program define f12_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Original(varname)
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) 
		   dtax(varname)
		   CONTributions(varname)
		   CONTPensions(varname)
		   CONYPensions(varname)
		   NONContributory(varname)
		   flagcct(varname)
		   OTRANsfers(varname)
		   ISUBsidies(varname)
		   itax(varname)
		   IKEducation(varname)
		   IKHealth(varname)
		   HUrban(varname)
		   hhid(varname)];
	di "Incidence (Decile) `'";
	local sheet="F12. Incidence (Decile)";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	
	qui{;
	
	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	/*if !_rc qui svyset // gets the results saved in return list
	*/
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
	
	forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
	}; 

	if "`original'"=="" {;
		display as error "Must specify Original(varname) option";
		exit;
	};



	local vlist1  `market' `contpensions' `conypensions';
	local vlist2  `dtax' `contributions' ;
	local vlist3  `netmarket' `noncontributory' `flagcct' `otransfers' ;
	local vlist4  `gross' `taxable' `disposable' `isubsidies' `itax'  ;
	local vlist5  `consumable' `ikeducation' `ikhealth' `hurban';
	local vlist6  `final'; 
	
		forvalues  x=1/6{;
		foreach y in `vlist`x''{;
		if "``y''"==""{;
			tempvar `y';
			gen ``y''=.;
		};
	};
	};
 
	
	qui{;
		forvalues x=1/6{;
			matrix f12_`x'_1=J(11,3,.);
			matrix colnames f12_`x'_1=market contpensions conypensions;
			matrix rownames f12_`x'_1=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;
			matrix f12_`x'_2=J(11,2,.);
			matrix colnames f12_`x'_2=dtax cont;
			matrix rownames f12_`x'_2=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;
			matrix f12_`x'_3=J(11,4,.);
			matrix colnames f12_`x'_3=netmarket nonc fcct otran;
			matrix rownames f12_`x'_3=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;

			matrix f12_`x'_4=J(11,5,.);
			matrix colnames f12_`x'_4=gross taxable disposable isub itax;
			matrix rownames f12_`x'_4=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;
			matrix f12_`x'_5=J(11,4,.);
			matrix colnames f12_`x'_5=consumable ike ikh hurban;
			matrix rownames f12_`x'_5=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;
			matrix f12_`x'_6=J(11,1,.);
			matrix colnames f12_`x'_6= final;
			matrix rownames f12_`x'_6=d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 t;
		};

		tempvar race6;
		gen `race6'=1;
		forvalues z=1/6{;
			sum `market' if `race`z''==1;
			
			if r(N)!=0{;
				tempvar memb;
				tempvar hhs;
				tempvar incdec;
				tempvar d_1o;
				tempvar d_o;
				bys `hhid': gen `memb' = _n;
				bys `hhid': gen `hhs' = _N;
				gen `incdec'=`original' if `memb'==1;
				qui quantiles `incdec' [aw=`w'*`hhs'], gen(`d_1o') n(10) stable;
				egen `d_o' = mean(`d_1o'),by(`hhid');

				*tempvar d_o;
				*	qui quantiles `original' [w=`w'], gen(`d_o') n(10); 
				};
			else{;
				tempvar d_o;
				gen `d_o'=.;
			};

			forvalues y=1/6{;
				local c=0;
					
					foreach x in `vlist`y''{;
						local c=`c'+1;
							
							forvalues r=1/10{;
								sum `x' [w=`w'] if `race`z''==1 & `d_o'==`r';
									matrix f12_`z'_`y'[`r',`c']=r(sum);

							};
							sum `x' [w=`w'] if `race`z''==1 ;
							matrix f12_`z'_`y'[11,`c']=r(sum);
			
			
			};
			};
			};
			};
			
		forvalues x=1/6{;
			noisily di "Incidence by decile `race`x''";
			noisily matrix list f12_`x'_1;
			noisily matrix list f12_`x'_2;
			noisily matrix list f12_`x'_3;
			noisily matrix list f12_`x'_4;
			noisily matrix list f12_`x'_5;
			noisily matrix list f12_`x'_6;
		};

	*National;
	putexcel D9=matrix(f12_6_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I9=matrix(f12_6_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L9=matrix(f12_6_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q9=matrix(f12_6_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W9=matrix(f12_6_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF9=matrix(f12_6_6) using `using',keepcellformat modify sheet("`sheet'") ;

	*Indigenous;
	putexcel D25=matrix(f12_1_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I25=matrix(f12_1_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L25=matrix(f12_1_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q25=matrix(f12_1_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W25=matrix(f12_1_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF25=matrix(f12_1_6) using `using',keepcellformat modify sheet("`sheet'") ;
		
	*White/Non-Ethnic;
	putexcel D41=matrix(f12_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I41=matrix(f12_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L41=matrix(f12_2_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q41=matrix(f12_2_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W41=matrix(f12_2_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF41=matrix(f12_2_6) using `using',keepcellformat modify sheet("`sheet'") ;

	*African Descendant;
	putexcel D57=matrix(f12_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I57=matrix(f12_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L57=matrix(f12_3_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q57=matrix(f12_3_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W57=matrix(f12_3_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF57=matrix(f12_3_6) using `using',keepcellformat modify sheet("`sheet'") ;

	
	*Others;
	putexcel D73=matrix(f12_4_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I73=matrix(f12_4_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L73=matrix(f12_4_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q73=matrix(f12_4_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W73=matrix(f12_4_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF73=matrix(f12_4_6) using `using',keepcellformat modify sheet("`sheet'") ;


	*Non-responses;
	putexcel D89=matrix(f12_5_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I89=matrix(f12_5_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L89=matrix(f12_5_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q89=matrix(f12_5_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W89=matrix(f12_5_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF89=matrix(f12_5_6) using `using',keepcellformat modify sheet("`sheet'") ;
	
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;


*******TABLE 10: Incidence (Income Groups)**************************************************************************;

program define f13_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		     Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname) 
		   dtax(varname)
		   CONTributions(varname)
		   CONTPensions(varname)
		   CONYPensions(varname)
		   NONContributory(varname)
		   flagcct(varname)
		   OTRANsfers(varname)
		   ISUBsidies(varname)
		   itax(varname)
		   IKEducation(varname)
		   IKHealth(varname)
		   HUrban(varname)
		   PL125(string)
			PL250(string)
			PL400(string)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			Original(varname)];
	di "Incidence (Income groups) `'";
	local sheet="F13. Incidence (Income groups)";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	qui{;
		 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		
		forvalues x=1/5{;
			if "`race`x''"==""{;
				local cc=`cc'+1;
				tempvar race`x';
				gen `race`x''=.;
			};
		}; 
		if "`original'"=="" {;
			display as error "Must specify Original(varname) option";
			exit;
		};

	foreach x in market contpensions conypensions dtax contributions  netmarket noncontributory  flagcct otransfers gross taxable disposable isubsidies itax consumable ikeducation ikhealth hurban final{;
			if "``x''"==""{;
				tempvar `x';
				gen ``x''=.;
			};
		};

		*	if "`pl125'"=="" | "`pl250'"=="" | "`pl400'"=="" {;
		*	display as error "Must specify Poverty lines for 1.25, 2.50 and 4.00 PPP";
		*	exit;
		*};
		
		*local pl1000=`pl250'*4;
		*local pl5000=`pl250'*20;
		
		local vlist1  `market' `contpensions' `conypensions';
		local vlist2  `dtax' `contributions' ;
		local vlist3  `netmarket' `noncontributory' `flagcct' `otransfers' ;
		local vlist4  `gross' `taxable' `disposable' `isubsidies' `itax'  ;
		local vlist5  `consumable' `ikeducation' `ikhealth' `hurban';
		local vlist6  `final'; 
		
			forvalues  x=1/6{;
		foreach y in `vlist`x''{;
		if "``y''"==""{;
			tempvar `y';
			gen ``y''=.;
		};
	};
	};
	
			tempvar `original'_ppp;
			 gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');
		
		tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;
		tempvar g_o11;
		gen `g_o11'=cond(`g_o'==5 | `g_o'==6,1,0);; 
		   
 
	qui{;
		forvalues x=1/6{;
			matrix f13_`x'_1=J(8,3,.);
			matrix colnames f13_`x'_1=market contpensions conypensions;
			matrix rownames f13_`x'_1=y125 y250 y4 y10 y50 ym50 t;
			matrix f13_`x'_2=J(8,2,.);
			matrix colnames f13_`x'_2=dtax cont;
			matrix rownames f13_`x'_2=y125 y250 y4 y10 y50 ym50 t;
			matrix f13_`x'_3=J(8,4,.);
			matrix colnames f13_`x'_3=netmarket nonc fcct otran;
			matrix rownames f13_`x'_3=y125 y250 y4 y10 y50 ym50 t;

			matrix f13_`x'_4=J(8,5,.);
			matrix colnames f13_`x'_4=gross taxable disposable isub itax;
			matrix rownames f13_`x'_4=y125 y250 y4 y10 y50 ym50 t;
			matrix f13_`x'_5=J(8,4,.);
			matrix colnames f13_`x'_5=consumable ike ikh hurban;
			matrix rownames f13_`x'_5=y125 y250 y4 y10 y50 ym50 t;
			matrix f13_`x'_6=J(8,1,.);
			matrix colnames f13_`x'_6= final;
			matrix rownames f13_`x'_6=y125 y250 y4 y10 y50 ym50 t;

		};

		tempvar race6;
		gen `race6'=1;
		
		forvalues z=1/6{;

			forvalues y=1/6{;
				local c=0;
				
				foreach x in `vlist`y''{;
					local c=`c'+1;
					
					forvalues r=1/6{;
						sum `x' [w=`w'] if `race`z''==1 & `g_o'==`r';
						matrix f13_`z'_`y'[`r',`c']=r(sum);

					};
					sum `x' [w=`w'] if `race`z''==1 & `g_o11'==1;
					matrix f13_`z'_`y'[7,`c']=r(sum);
					
					sum `x' [w=`w'] if `race`z''==1;
					matrix f13_`z'_`y'[8,`c']=r(sum);

};};};};

		forvalues x=1/6{;
			noisily di "Incidence by Socioeconomic Group `race`x''";
			noisily matrix list f13_`x'_1;
			noisily matrix list f13_`x'_2;
			noisily matrix list f13_`x'_3;
			noisily matrix list f13_`x'_4;
			noisily matrix list f13_`x'_5;
		};

*National;
	putexcel D10=matrix(f13_6_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I10=matrix(f13_6_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L10=matrix(f13_6_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q10=matrix(f13_6_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W10=matrix(f13_6_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF10=matrix(f13_6_6) using `using',keepcellformat modify sheet("`sheet'") ;

	*Indigenous;
	putexcel D24=matrix(f13_1_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I24=matrix(f13_1_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L24=matrix(f13_1_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q24=matrix(f13_1_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W24=matrix(f13_1_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF24=matrix(f13_1_6) using `using',keepcellformat modify sheet("`sheet'") ;
		
	*White/Non-Ethnic;
	putexcel D38=matrix(f13_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I38=matrix(f13_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L38=matrix(f13_2_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q38=matrix(f13_2_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W38=matrix(f13_2_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF38=matrix(f13_2_6) using `using',keepcellformat modify sheet("`sheet'") ;

	*African Descendant;
	putexcel D52=matrix(f13_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I52=matrix(f13_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L52=matrix(f13_3_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q52=matrix(f13_3_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W52=matrix(f13_3_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF52=matrix(f13_3_6) using `using',keepcellformat modify sheet("`sheet'") ;

	
	*Others;
	putexcel D66=matrix(f13_4_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I66=matrix(f13_4_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L66=matrix(f13_4_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q66=matrix(f13_4_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W66=matrix(f13_4_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF66=matrix(f13_4_6) using `using',keepcellformat modify sheet("`sheet'") ;

	*Non-responses;
	putexcel D80=matrix(f13_5_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I80=matrix(f13_5_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel L80=matrix(f13_5_3) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel Q80=matrix(f13_5_4) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W80=matrix(f13_5_5) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AF80=matrix(f13_5_6) using `using',keepcellformat modify sheet("`sheet'") ;
	
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
end;

*******TABLE F16: Fiscal Profile**************************************************************************;
program define f16_race;

syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Original(varname)
		   Disposable(varname) 
		   Consumable(varname)
		   Final(varname) 
		   age(varname)
		   PL125(string)				
			PL250(string)               
			PL400(string) 
			PENSions(varname)
			hhe(varname) 
		    hhid(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
	local sheet="F16. Fiscal Profile";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	qui{;
		 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		
		forvalues x=1/5{;
			if "`race`x''"==""{;
				local cc=`cc'+1;
				tempvar race`x';
				gen `race`x''=.;
			};
			};
			
		//national;
		tempvar race6;
		gen `race6'=1;
		
		if "`original'"=="" {;
			display as error "Must specify Original(varname) option";
			exit;
		};
if "``hhid'"=="" {;
			display as error "Must specify the household id.";
			exit;
		};

	//Poverty lines;
	local p1=`cut2';
	local p2=`cut3';
	local pl1000=`cut4';
	local pl5000=`cut5';
		
	
	forvalues x=1/6{;
		****Table for individuals;
		matrix f16_`x'_1_i=J(6,1,.);//number of individuals (sample);
		matrix colnames f16_`x'_1_i=indivs;
		matrix rownames f16_`x'_1_i=y125 y250 y4 y10 y50 ym50;
	
		matrix f16_`x'_2_i=J(6,1,.);//number of individuals (population);
		matrix colnames f16_`x'_2_i=indivp;
		matrix rownames f16_`x'_2_i=y125 y250 y4 y10 y50 ym50;
	
		matrix f16_`x'_3_i=J(6,4,.);//total incomes;
		matrix colnames f16_`x'_3_i=market disposable consumable final;
		matrix rownames f16_`x'_3_i=y125 y250 y4 y10 y50 ym50;
		
		matrix f16_`x'_4_i=J(6,4,.);//age pensions,etc;
		matrix colnames f16_`x'_4_i=age hsize pens agefive;
		matrix rownames f16_`x'_4_i=y125 y250 y4 y10 y50 ym50;
	
		****Table for households;
	
		matrix f16_`x'_1_h=J(6,1,.);//number of households (sample);
		matrix colnames f16_`x'_1_h=hhs;
		matrix rownames f16_`x'_1_h=y125 y250 y4 y10 y50 ym50;
	
		matrix f16_`x'_2_h=J(6,1,.);//number of individuals (sample);
		matrix colnames f16_`x'_2_h=indivs;
		matrix rownames f16_`x'_2_h=y125 y250 y4 y10 y50 ym50;
		
		matrix f16_`x'_3_h=J(6,1,.);//number of households (population);
		matrix colnames f16_`x'_3_h=hhp;
		matrix rownames f16_`x'_3_h=y125 y250 y4 y10 y50 ym50;
	
		matrix f16_`x'_4_h=J(6,1,.);//number of individuals (population);
		matrix colnames f16_`x'_4_h=indivp;
		matrix rownames f16_`x'_4_h=y125 y250 y4 y10 y50 ym50;	
		
		matrix f16_`x'_5_h=J(6,4,.);//total incomes;
		matrix colnames f16_`x'_5_h=market disposable consumable final;
		matrix rownames f16_`x'_5_h=y125 y250 y4 y10 y50 ym50;
		
		matrix f16_`x'_6_h=J(6,5,.);//age pensions,etc;
		matrix colnames f16_`x'_6_h=age hsize pens agefive mixrace;
		matrix rownames f16_`x'_6_h=y125 y250 y4 y10 y50 ym50;
	};
			
	*Poverty values;	
	tempvar `original'_ppp;
	gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');
	
		tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;


	
	*household size;
	tempvar hhsize;
	egen `hhsize'=sum(`race6'),by(`hhid');
	*Pensioners;
	tempvar id_pensioners;
	gen `id_pensioners'=cond(`pensions'>0 & `pensions'!=.,1,0);
	*Less than 5 years;
	tempvar less5;
	gen `less5'=cond(`age'<5,1,0);
	*Table for individuals;
	forvalues x=1/6{;//races;
		forvalues z=1/6{;//socioeconomic groups;
			*matrix 1;
			sum `race6' if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_1_i[`z',1]=r(sum);
			*matrix 2;
			sum `race6' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_2_i[`z',1]=r(sum);		
			*matrix 3;
			sum `original' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_3_i[`z',1]=r(sum);	
			sum `disposable' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_3_i[`z',2]=r(sum);
			sum `consumable' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_3_i[`z',3]=r(sum);
			sum `final' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_3_i[`z',4]=r(sum);
			sum `age' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_4_i[`z',1]=r(mean);
			sum `hhsize' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_4_i[`z',2]=r(mean);
			sum `id_pensioners' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_4_i[`z',3]=r(mean);
			sum `less5' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_4_i[`z',4]=r(mean);  
			
			
		};
	

	};
	*Put in excel;
	*Indigenous;
	putexcel C11=matrix(f16_1_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E11=matrix(f16_1_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G11=matrix(f16_1_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S11=matrix(f16_1_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	*White/Non-Ethnic;
	putexcel C18=matrix(f16_2_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E18=matrix(f16_2_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G18=matrix(f16_2_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S18=matrix(f16_2_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	*African Descendant;
	putexcel C25=matrix(f16_3_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E25=matrix(f16_3_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G25=matrix(f16_3_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S25=matrix(f16_3_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	*Other;
	putexcel C32=matrix(f16_4_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E32=matrix(f16_4_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G32=matrix(f16_4_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S32=matrix(f16_4_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	*Non-Responses;
	putexcel C39=matrix(f16_5_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E39=matrix(f16_5_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G39=matrix(f16_5_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S39=matrix(f16_5_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	*Total Population;
	putexcel C46=matrix(f16_6_1_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E46=matrix(f16_6_2_i) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G46=matrix(f16_6_3_i) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S46=matrix(f16_6_4_i) using `using',keepcellformat modify sheet("`sheet'") ;
	
	*Table for households;
	*Race of the household head;
	tempvar racehh1;
	gen `racehh1'=.;
	forvalues x=1/5{;
		replace `racehh1'= `x' if `race`x''==1 & `hhe'==1;
		};	
	tempvar racehh;
	*Race of the household;
	egen `racehh'=mean(`racehh1'),by(`hhid');
	
	tempvar age_hh;
	*Average age in HH;
	egen `age_hh'=mean(`age'),by(`hhid');
		*HH with Pensioners;
	tempvar pensioners_hh;
	egen `pensioners_hh'= sum(`id_pensioners'),by(`hhid'); 
	replace `pensioners_hh'=1 if `pensioners_hh'>0 & `pensioners_hh'!=.;
	*HH with Children under 5 years;
	tempvar less5_hh;
	egen `less5_hh'= sum(`less5'),by(`hhid'); 
	replace `less5_hh'=1 if `less5_hh'>0 & `less5_hh'!=.;
	*% of mixed race households;
	tempvar r_ind;
	gen `r_ind'=.;
	forvalues x=1/5{;
		replace `r_ind'= `x' if `race`x''==1;
	};
	tempvar r_mix;
	egen `r_mix'=mean(`r_ind'), by(`hhid'); //average categorical value';
	replace `r_mix'=0 if `r_mix'==1 | `r_mix'==2 | `r_mix'==3 | `r_mix'==4 | `r_mix'==5;//Households with same race;
	replace `r_mix'=1 if `r_mix'>0 & `r_mix'!=.;//Households with different race;
	
	
	forvalues x=1/6{;//races;
		forvalues z=1/6{;//socioeconomic groups;
			*matrix 2;
			sum `race6' if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_2_h[`z',1]=r(sum);
			*matrix 4;
			sum `race6' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_4_h[`z',1]=r(sum);		
			
			preserve;
			keep if `hhe'==1; //Only HH information;
			*matrix 1;
			sum `race6' if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_1_h[`z',1]=r(sum);
			*matrix 3;
			sum `race6' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_3_h[`z',1]=r(sum);		
			*matrix 5;
			sum `original' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_5_h[`z',1]=r(sum);	
			sum `disposable' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_5_h[`z',2]=r(sum);
			sum `consumable' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_5_h[`z',3]=r(sum);
			sum `final' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_5_h[`z',4]=r(sum);
			
			*matrix 6;
			sum `age_hh' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_6_h[`z',1]=r(mean);
			sum `hhsize' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_6_h[`z',2]=r(mean);
			sum `pensioners_hh' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_6_h[`z',3]=r(mean)*100;
			sum `less5_hh' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_6_h[`z',4]=r(mean);  
			sum `r_mix' [w=`w'] if `race`x''==1 & `g_o'==`z';
			matrix f16_`x'_6_h[`z',5]=r(mean); 
			restore;
			
	};
	
	};
	
	*Put in excel;
	*Indigenous;
	putexcel C59=matrix(f16_1_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E59=matrix(f16_1_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G59=matrix(f16_1_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I59=matrix(f16_1_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K59=matrix(f16_1_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W59=matrix(f16_1_6_h) using `using',keepcellformat modify sheet("`sheet'") ;

	*White/Non-Ethnic;
	putexcel C66=matrix(f16_2_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E66=matrix(f16_2_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G66=matrix(f16_2_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I66=matrix(f16_2_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K66=matrix(f16_2_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W66=matrix(f16_2_6_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	*African Descendant;
	putexcel C73=matrix(f16_3_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E73=matrix(f16_3_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G73=matrix(f16_3_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I73=matrix(f16_3_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K73=matrix(f16_3_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W73=matrix(f16_3_6_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	*Other;
	putexcel C80=matrix(f16_4_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E80=matrix(f16_4_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G80=matrix(f16_4_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I80=matrix(f16_4_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K80=matrix(f16_4_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W80=matrix(f16_4_6_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	*Non-Responses;
	putexcel C87=matrix(f16_5_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E87=matrix(f16_5_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G87=matrix(f16_5_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I87=matrix(f16_5_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K87=matrix(f16_5_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W87=matrix(f16_5_6_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	*Total Population;
	putexcel C94=matrix(f16_6_1_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel E94=matrix(f16_6_2_h) using `using',keepcellformat modify sheet("`sheet'") ;	
	putexcel G94=matrix(f16_6_3_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel I94=matrix(f16_6_4_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K94=matrix(f16_6_5_h) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel W94=matrix(f16_6_6_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	
};
noisily di as text "Results for Individuals";
	forvalues x=1/6{;//races;
		forvalues y=1/4{;//Matrices;
			noisily di "race `x', matrix `y'";
			noisily matrix list f16_`x'_`y'_i;

		};
	};
noisily di as text "Results for Households";
	forvalues x=1/6{;//races;
		forvalues y=1/6{;//Matrices;
			noisily di "race `x', matrix `y'";
			noisily matrix list f16_`x'_`y'_h;

		};
	};
	
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	end;

*******TABLE F16: Coverage (total)**************************************************************************;
program define f17_race;

syntax   [if] [in] [using/] [pweight/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN
		   PL125(string)
			PL250(string)
			PL400(string)
		   dtax(varname)
		   OTRANsfers(varname)
		   NONContributory(varname)
		   hhe(varname) 
		   hhid(varname)
		   CCT(varname)
		   SCHolarships(varname)
		   UNEMPloyben(varname)
		   FOODTransfers(varname)
		   HEALTH(varname)
		   PENSions(varname)
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
	di "Coverage (Total)";
	local sheet="F17. Coverage (Total)";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
  *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
		}; 
	tempvar race6;
	gen `race6'=1;
	


	if "`original'"=="" {;
		display as error "Must specify Original(varname) option";
	exit;
	};

	
	if "`hhe'"=="" | "`hhid'"==""{;
		display as error "Must specify who is the household head and the household ID";
		exit;
		};
				
	
	
	*Race of the household head;
	tempvar racehh1;
	gen `racehh1'=.;
	forvalues x=1/5{;
		replace `racehh1'= `x' if `race`x''==1 & `hhe'==1;
		};	
	tempvar racehh;
	*Race of the household;
	egen `racehh'=mean(`racehh1'),by(`hhid');
	
	local vlist  `cct' `scholarships' `noncontributory' `unemployben' `foodtransfers' `otransfers' `health' `pensions' `dtax';
	tempvar `original'_ppp;
	gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');
		
		tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;

	
	*Variables for total benefits;
	forvalues x=1/11{;
	tempvar g_o_`x';
	};
	
	
	gen `g_o_1'=cond(``original'_ppp'<`cut1',1,0);
	gen `g_o_2'=cond(``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2',1,0);
	gen `g_o_3'=cond(``original'_ppp'<`cut2',1,0);
	gen `g_o_4'=cond(``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3',1,0);
	gen `g_o_5'=cond(``original'_ppp'<`cut3',1,0);
	gen `g_o_6'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4',1,0);
	gen `g_o_7'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5',1,0);
	gen `g_o_8'=cond(``original'_ppp'>=`cut5' & ``original'_ppp'!=.,1,0);
	gen `g_o_9'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'!=.,1,0);
	gen `g_o_10'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'!=.,1,0);
	gen `g_o_11'=1;
	
	*Results for individuals;
	*Population;

	matrix f17_1_1=J(6,11,.);
	matrix rownames f17_1_1=national indig white african other nonresp;
	matrix colnames f17_1_1=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
	
	tempvar tot;
	gen `tot'=1;
	forvalues y=1/11{;*Sociodemographic group;
	summ `tot' [w=`w'] if `g_o_`y''==1;
	matrix f17_1_1[1,`y']=r(sum);
		local c=1;
	forvalues x=1/5{;*Race;
	summ `tot' [w=`w'] if `g_o_`y''==1 & `race`x''==1;
		local c=`c'+1;
	matrix f17_1_1[`c',`y']=r(sum);
	};
	};
	*National;
	putexcel D22=matrix(f17_1_1) using `using',keepcellformat modify sheet("`sheet'") ;
	

	*Results for Households;
	*Households;
	preserve;
	keep if `hhe'==1;//In this case we can do it because we are not linking programs yet;
	matrix f17_2_1=J(6,11,.);
	matrix rownames f17_2_1=national indig white african other nonresp;
	matrix colnames f17_2_1=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
				
	tempvar tot;
	gen `tot'=1;
	forvalues y=1/11{;*Sociodemographic group;
	summ `tot' [w=`w'] if `g_o_`y''==1;
	matrix f17_2_1[1,`y']=r(sum);
	 
	local c=1;
	forvalues x=1/5{;*Race;
	summ `tot' [w=`w'] if `g_o_`y''==1 & `race`x''==1;
		local c=`c'+1;
	matrix f17_2_1[`c',`y']=r(sum);
	};
	};
	*National;
	putexcel D28=matrix(f17_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
	
	restore;
	
	
	foreach z in `vlist'{;
	local nz=`nz'+1;
		if "`z'"==""{;
			tempvar "`z'";
			gen ``z''=.;
		};
		*Direct beneficiaries;
		tempvar d_b_`z';
		gen `d_b_`z''=cond(`z'>0 & `z'!=.,1,0);
		*Households;
		tempvar hh_b_`z'1;
		egen `hh_b_`z'1'=mean(`z'),by(`hhid');
		tempvar hh_b_`z';
		gen `hh_b_`z''=cond(`hh_b_`z'1'>0 & `hhe'==1,1,0);
		replace `hh_b_`z''=. if `hhe'!=1;
		*Direct and indirect beneficiaries;
		tempvar di_b_`z';
		gen `di_b_`z''=cond(`hh_b_`z'1'>0,1,0);
		
		
	*****Beneficiaries Matrices;
		*Direct;
		matrix f17_`z'_1=J(6,11,.);
		matrix colnames f17_`z'_1=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f17_`z'_1=national indig white african other nonresp ;
		matrix f17_`z'_2=J(6,11,.);
		matrix colnames f17_`z'_2=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f17_`z'_2=national indig white african other nonresp ;		
		matrix f17_`z'_3=J(6,11,.);
		matrix colnames f17_`z'_3=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f17_`z'_3=national indig white african other nonresp ;
	*****Total Benefits (in LCU) Matrices;
		matrix f17_`z'_tb=J(6,11,.);
		matrix colnames f17_`z'_tb=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f17_`z'_tb=national indig white african other nonresp ;
		
		*Total Benefits;
	
	 forvalues x=1/11{;//groups of income;
	 
		summ `z' [w=`w'] if `g_o_`x''==1;
		matrix f17_`z'_tb[1,`x']=r(sum);
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			summ `z' [w=`w'] if `g_o_`x''==1 & `race`y''==1;
			matrix f17_`z'_tb[`c',`x']=r(sum);
	};
	};	
	noisily di "Total benefits `z'";
	noisily matrix list f17_`z'_tb;
	if `nz'==1	putexcel C84=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==2	putexcel C156=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==3	putexcel C228=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==4	putexcel C300=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==5	putexcel C372=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==6	putexcel C444=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==7	putexcel C516=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==8	putexcel C588=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==9	putexcel C660=matrix(f17_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	
	
	*Beneficiaries;
	
	forvalues x=1/11{;//groups of income;
		*Direct beneficiaries;
		summ  `d_b_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f17_`z'_1[1,`x']=r(sum);
		
		*Households;
		summ  `hh_b_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f17_`z'_2[1,`x']=r(sum);
		
		*Direct and indirect beneficiaries;
		summ  `di_b_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f17_`z'_3[1,`x']=r(sum);
		
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			*Direct beneficiaries;
			summ  `d_b_`z'' [w=`w'] if `g_o_`x''==1 & `race`y''==1;
			matrix f17_`z'_1[`c',`x']=round(r(sum));
			
			*Households;
			summ  `hh_b_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y';
			matrix f17_`z'_2[`c',`x']=round(r(sum));
		
			*Direct and indirect beneficiaries;
			summ  `di_b_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y';
			matrix f17_`z'_3[`c',`x']=round(r(sum));
			
	};
	};	
	noisily di "Beneficiaries `z': Direct Beneficiaries";
	noisily matrix list f17_`z'_1;
	noisily di "Beneficiaries `z': Households";
	noisily matrix list f17_`z'_2;
	noisily di "Beneficiaries `z': Direct and Indirect Beneficiaries";
	noisily matrix list f17_`z'_3;
	
		if `nz'==1{;
	putexcel D40=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D46=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D52=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==2{;
	putexcel D112=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D118=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D124=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==3{;
	putexcel D184=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D190=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D196=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==4{;
	putexcel D256=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D262=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D268=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==5{;
	putexcel D328=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D334=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D340=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==6{;
	putexcel D400=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D406=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D412=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==7{;
	putexcel D472=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D478=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D484=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==8{;
	putexcel D544=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D550=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D556=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==9{;
	putexcel D616=matrix(f17_`z'_1) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D622=matrix(f17_`z'_2) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D628=matrix(f17_`z'_3) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	
};
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;

*******TABLE F18: Coverage (target)**************************************************************************;
program define f18_race;

syntax   [if] [in] [using/] [pweight/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN
		   PL125(string)
			PL250(string)
			PL400(string)
		    NONContributory(varname)
		   hhe(varname) 
		   hhid(varname)
		   CCT(varname)
		   PENSions(varname)
		   TARCCT(varname)
		   TARNCP(varname)
		   TARPENsions(varname)
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)		   ];
	di "Coverage (Target)";
	local sheet="F18. Coverage (Target)";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
		}; 
	tempvar race6;
	gen `race6'=1;
	


	if "`original'"=="" {;
		display as error "Must specify Original(varname) option";
	exit;
	};

	
	if "`hhe'"=="" | "`hhid'"==""{;
		display as error "Must specify who is the household head and the household ID";
		exit;
		};
				

	*Race of the household head;
	tempvar racehh1;
	gen `racehh1'=.;
	forvalues x=1/5{;
		replace `racehh1'= `x' if `race`x''==1 & `hhe'==1;
		};	
	tempvar racehh;
	*Race of the household;
	egen `racehh'=mean(`racehh1'),by(`hhid');
	
	local vlist  `cct' `noncontributory' `pensions';
	
	local cond_`cct'="`tarcct'";
	local cond_`noncontributory'= "`tarncp'";
	local cond_`pensions'="`tarpensions'";  
	
			tempvar `original'_ppp;
			 gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');
			 
		tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;


*total benefits;
	forvalues x=1/11{;
	tempvar g_o_`x';
	};
	gen `g_o_1'=cond(``original'_ppp'<`cut1',1,0);
	gen `g_o_2'=cond(``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2',1,0);
	gen `g_o_3'=cond(``original'_ppp'<`cut2',1,0);
	gen `g_o_4'=cond(``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3',1,0);
	gen `g_o_5'=cond(``original'_ppp'<`cut3',1,0);
	gen `g_o_6'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4',1,0);
	gen `g_o_7'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5',1,0);
	gen `g_o_8'=cond(``original'_ppp'>=`cut5' & ``original'_ppp'!=.,1,0);
	gen `g_o_9'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'!=.,1,0);
	gen `g_o_10'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'!=.,1,0);
	gen `g_o_11'=1;
	
		
	foreach z in `vlist'{;
	local nz=`nz'+1;
		if "`z'"==""{;
			tempvar "`z'";
			gen ``z''=.;
		};
		*Direct beneficiaries;
		tempvar d_b_`z';
		gen `d_b_`z''=cond(`z'>0 & `z'!=.,1,0);
		*Households;
		tempvar hh_b_`z'1;
		egen `hh_b_`z'1'=mean(`z'),by(`hhid');
		tempvar hh_b_`z';
		gen `hh_b_`z''=cond(`hh_b_`z'1'>0 & `hhe'==1,1,0);
		replace `hh_b_`z''=. if `hhe'!=1;
		*Direct and indirect beneficiaries;
		tempvar di_b_`z';
		gen `di_b_`z''=cond(`hh_b_`z'1'>0,1,0);
		
		
		
	*****Target Population;
		*Direct;
		matrix f18_`z'_1t=J(6,11,.);
		matrix colnames f18_`z'_1t=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_1t=national indig white african other nonresp;
		*Households;
		matrix f18_`z'_2t=J(6,11,.);
		matrix colnames f18_`z'_2t=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_2t=national indig white african other nonresp;		
		*Direct and indirect beneficiatries;
		matrix f18_`z'_3t=J(6,11,.);
		matrix colnames f18_`z'_3t=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_3t=national indig white african other nonresp;
	*****Beneficiaries Matrices;
		*Direct;
		matrix f18_`z'_1b=J(6,11,.);
		matrix colnames f18_`z'_1b=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_1b=national indig white african other nonresp;
		*Households;
		matrix f18_`z'_2b=J(6,11,.);
		matrix colnames f18_`z'_2b=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_2b=national indig white african other nonresp;		
		*Direct and indirect beneficiatries;
		matrix f18_`z'_3b=J(6,11,.);
		matrix colnames f18_`z'_3b=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_3b=national indig white african other nonresp;		
		
	
		*****Total Benefits (in LCU) Matrices;
		matrix f18_`z'_tb=J(6,11,.);
		matrix colnames f18_`z'_tb=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f18_`z'_tb=national indig white african other nonresp;
		
		*Total Benefits;
	
	 forvalues x=1/11{;//groups of income;
	 
		summ `z' [w=`w'] if `g_o_`x''==1 & `cond_`z''==1;
		matrix f18_`z'_tb[1,`x']=r(sum);
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			summ `z' [w=`w'] if `g_o_`x''==1 & `race`y''==1 & `cond_`z''==1;
			matrix f18_`z'_tb[`c',`x']=r(sum);
	};
	};	
	noisily di "Total benefits `z'";
	noisily matrix list f18_`z'_tb;
	if `nz'==1	putexcel C63=matrix(f18_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==2	putexcel C135=matrix(f18_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==3	putexcel C207=matrix(f18_`z'_tb) using `using',keepcellformat modify sheet("`sheet'") ;
		
	
	*Target Population;
	
	forvalues x=1/11{;//groups of income;
		*Direct beneficiaries;
		summ  `cond_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f18_`z'_1t[1,`x']=r(sum);
		
		*Households;
		summ  `cond_`z'' [w=`w'] if `g_o_`x''==1  & `hhe'==1;
		matrix f18_`z'_2t[1,`x']=r(sum);
		
		*Direct and indirect beneficiaries;
		tempvar cond_di_`z';
		egen `cond_di_`z''=sum(`cond_`z''),by(`hhid');
		replace `cond_di_`z''=1 if `cond_di_`z''>0 & `cond_di_`z''!=.;
		summ  `cond_di_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f18_`z'_3t[1,`x']=r(sum);
		
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			*Direct beneficiaries;
			summ  `cond_`z'' [w=`w'] if `g_o_`x''==1 & `race`y''==1;
			matrix f18_`z'_1t[`c',`x']=round(r(sum));
			
			*Households;
			summ  `cond_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y' & `hhe'==1;
			matrix f18_`z'_2t[`c',`x']=round(r(sum));
		
			*Direct and indirect beneficiaries;
			
			summ  `cond_di_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y' ;
			matrix f18_`z'_3t[`c',`x']=round(r(sum));
			
	};
	};	
	noisily di "Beneficiaries `z': Direct Beneficiaries";
	noisily matrix list f18_`z'_1t;
	noisily di "Beneficiaries `z': Households";
	noisily matrix list f18_`z'_2t;
	noisily di "Beneficiaries `z': Direct and Indirect Beneficiaries";
	noisily matrix list f18_`z'_3t;
	
		if `nz'==1{;
	putexcel D19=matrix(f18_`z'_1t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D25=matrix(f18_`z'_2t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D31=matrix(f18_`z'_3t) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==2{;
	putexcel D91=matrix(f18_`z'_1t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D97=matrix(f18_`z'_2t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D103=matrix(f18_`z'_3t) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==3{;
	putexcel D163=matrix(f18_`z'_1t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D169=matrix(f18_`z'_2t) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel D175=matrix(f18_`z'_3t) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	


	*Beneficiaries;

	forvalues x=1/11{;//groups of income;
		*Direct beneficiaries;
		summ  `d_b_`z'' [w=`w'] if `g_o_`x''==1 /*& `cond_`z''==1*/;
		matrix f18_`z'_1b[1,`x']=r(sum);
		
		*Households;
		summ  `hh_b_`z'' [w=`w'] if `g_o_`x''==1 /*& `cond_`z''==1*/ & `hhe'==1;
		matrix f18_`z'_2b[1,`x']=r(sum);
		
		*Direct and indirect beneficiaries;
		summ  `di_b_`z'' [w=`w'] if `g_o_`x''==1 /*& `cond_`z''==1*/;
		matrix f18_`z'_3b[1,`x']=r(sum);
		
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			*Direct beneficiaries;
			summ  `d_b_`z'' [w=`w'] if `g_o_`x''==1 & `race`y''==1 /*& `cond_`z''==1*/;
			matrix f18_`z'_1b[`c',`x']=round(r(sum));
			
			*Households;
			summ  `hh_b_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y' /*& `cond_`z''==1*/;
			matrix f18_`z'_2b[`c',`x']=round(r(sum));
		
			*Direct and indirect beneficiaries;
			summ  `di_b_`z'' [w=`w'] if `g_o_`x''==1 & `racehh'==`y' /*& `cond_`z''==1*/;
			matrix f18_`z'_3b[`c',`x']=round(r(sum));
			
	};
	};	
	noisily di "Beneficiaries `z': Direct Beneficiaries";
	noisily matrix list f18_`z'_1b;
	noisily di "Beneficiaries `z': Households";
	noisily matrix list f18_`z'_2b;
	noisily di "Beneficiaries `z': Direct and Indirect Beneficiaries";
	noisily matrix list f18_`z'_3b;
	
		if `nz'==1{;
	putexcel R19=matrix(f18_`z'_1b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R25=matrix(f18_`z'_2b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R31=matrix(f18_`z'_3b) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==2{;
	putexcel R91=matrix(f18_`z'_1b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R97=matrix(f18_`z'_2b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R103=matrix(f18_`z'_3b) using `using',keepcellformat modify sheet("`sheet'") ;
	};
		if `nz'==3{;
	putexcel R163=matrix(f18_`z'_1b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R169=matrix(f18_`z'_2b) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel R175=matrix(f18_`z'_3b) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	};		
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
	};
	
	
	
	
	
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	

end;



*******TABLE F20: Mobility**************************************************************************;

program define f20_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Disposable(varname) 
		   Consumable(varname)
		   Final(varname) 
		   PL125(string)
			PL250(string)
			PL400(string)
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
di "Mobility `'";
local sheet="F20. Mobility";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
  *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
}; 
tempvar race6;
gen `race6'=1;

if "`original'"=="" {;
display as error "Must specify Original(varname) option";
exit;
};


		
local vlist1  `original' `disposable' `consumable' `final' ;


foreach x in `vlist1'{;
tempvar `x'_ppp;
gen ``x'_ppp' = (`x'/`divideby')*(1/`ppp_calculated');
tempvar g_`x';
gen `g_`x''=. ;
replace `g_`x''=1 if ``x'_ppp'<`cut1';
replace `g_`x''=2 if ``x'_ppp'>=`cut1' & ``x'_ppp'<`cut2';
replace `g_`x''=3 if ``x'_ppp'>=`cut2' & ``x'_ppp'<`cut3';
replace `g_`x''=4 if ``x'_ppp'>=`cut3' & ``x'_ppp'<`cut4';
replace `g_`x''=5 if ``x'_ppp'>=`cut4' & ``x'_ppp'!=.;
};

		   
 local vlist2 `disposable' `consumable' `final';


forvalues x=1/6{;
foreach y in `vlist2'{;
matrix f20_`x'_`y'=J(5,5,.);
matrix colnames f20_`x'_`y'=yd_125 yd_250 yd_4 yd_10 yd_m10;
matrix rownames f20_`x'_`y'=ym_125 ym_250 ym_4 ym_10 ym_m10;
};
};


forvalues r=1/6{;
foreach x in `vlist2'{; *non market incomes;
forvalues y=1/5{;*market categories;
forvalues z=1/5{;*other income categories;
tempvar g_`x'_`y'_`z';
gen `g_`x'_`y'_`z''=cond(`g_`original''==`y' & `g_`x''==`z',1,0);
sum `g_`x'_`y'_`z'' [w=`w'] if `race`r''==1;
matrix f20_`r'_`x'[`y',`z']=round(r(sum));
};};};};

forvalues x=1/6{;
foreach y in `vlist2'{;
noisily di "Mobility by Socioeconomic Group `race`x''";
noisily matrix list f20_`x'_`y';
noisily matrix list f20_`x'_`y';
noisily matrix list f20_`x'_`y';
};
};
*National Disposable;
putexcel C101=matrix(f20_6_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*National Post-Fiscal; 
putexcel C109=matrix(f20_6_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*National Final;
putexcel C117=matrix(f20_6_`final') using `using',keepcellformat modify sheet("`sheet'") ;

*Indigenous Disposable;
putexcel C23=matrix(f20_1_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*Indigenous Post-Fiscal; 
putexcel C31=matrix(f20_1_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*Indigenous Final;
putexcel C39=matrix(f20_1_`final') using `using',keepcellformat modify sheet("`sheet'") ;

*White Disposable;
putexcel C49=matrix(f20_2_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*White Post-Fiscal; 
putexcel C57=matrix(f20_2_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*White Final;
putexcel C65=matrix(f20_2_`final') using `using',keepcellformat modify sheet("`sheet'") ;

*African Descendant Disposable;
putexcel C75=matrix(f20_3_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*African Descendant Post-Fiscal; 
putexcel C83=matrix(f20_3_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*African Descendant Final;
putexcel C91=matrix(f20_3_`final') using `using',keepcellformat modify sheet("`sheet'") ;

*Others Disposable;
putexcel C127=matrix(f20_4_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*Others Post-Fiscal; 
putexcel C135=matrix(f20_4_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*Others Final;
putexcel C143=matrix(f20_4_`final') using `using',keepcellformat modify sheet("`sheet'") ;

*Non-responses Disposable;
putexcel C153=matrix(f20_5_`disposable') using `using',keepcellformat modify sheet("`sheet'") ;
*Non-responses Post-Fiscal; 
putexcel C161=matrix(f20_5_`consumable') using `using',keepcellformat modify sheet("`sheet'") ;
*Non-responses Final;
putexcel C169=matrix(f20_5_`final') using `using',keepcellformat modify sheet("`sheet'") ;

putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;


*******TABLE F21: Education (populations)**************************************************************************;

program define f21_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   PL125(string)
			PL250(string)
			PL400(string)
		   edpre(varname) 
		   edpri(varname) 
		   edsec(varname) 
		   edter(varname) 
		   hhe(varname) 
		   hhid(varname)
		   attend(varname)
		   redpre(varname) 
		   redpri(varname) 
		   redsec(varname) 
		   redter(varname) 
		   EDPUBlic(varname)
		   EDPRIVate(varname)
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
di "Education (populations) `'";
local sheet="F21. Education (populations)";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
  *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
}; 
tempvar race6;
gen `race6'=1;

if "`original'"=="" {;
display as error "Must specify Original(varname) option";
exit;
};


		
**Age Ranges;
local vlist0  `edpre' `edpri' `edsec' `edter' ;
local vlist1  `redpre' `redpri' `redsec' `redter' ;
*foreach x in `vlist0'{;
*local t_`x'="`r`x''";
*	tempvar u_`x';
*	gen `u_`x''=cond(`x'==1 & (`t_`x''==1),1,0);
*};
tempvar u_`edpre';
gen `u_`edpre''=cond(`edpre'==1 & (`redpre'==1),1,0);

tempvar u_`edpri';
gen `u_`edpri''=cond(`edpri'==1 & (`redpri'==1),1,0);

tempvar u_`edsec';
gen `u_`edsec''=cond(`edsec'==1 & (`redsec'==1),1,0);

tempvar u_`edter';
gen `u_`edter''=cond(`edter'==1 & (`redter'==1),1,0);

		

tempvar `original'_ppp;
			 gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');
	
		tempvar g_o;
	gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;


forvalues x=1/11{;
	tempvar y_`x';
};

gen `y_1'=cond(`g_o'==1,1,0);
gen `y_2'=cond(`g_o'==2,1,0);
gen `y_3'=cond(`g_o'==1 | `g_o'==2,1,0);
gen `y_4'=cond(`g_o'==3,1,0);
gen `y_5'=cond(`g_o'==1 | `g_o'==2 | `g_o'==3,1,0);
gen `y_6'=cond(`g_o'==4,1,0);
gen `y_7'=cond(`g_o'==5,1,0);
gen `y_8'=cond(`g_o'==6,1,0);
gen `y_9'=cond(`g_o'==5 | `g_o'==6,1,0);
gen `y_10'=cond(`g_o'==4 | `g_o'==5 | `g_o'==6,1,0);
gen `y_11'=1;

*Target Population***;

forvalues x=1/6{;*race;
	matrix f21_`x'_1=J(4,11,.);
	matrix colnames f21_`x'_1=yd_125 yd_250 yl250 yd_4 yl4 yd_10 yd_50 yd_m10 ym_10 ym_4 yt;
	matrix rownames f21_`x'_1=pre primary secondary tertiary ;
	
};

forvalues r=1/6{;*race;
	local c=0;
	foreach x in `vlist1'{; *schooling;
		local c=`c'+1;
		forvalues y=1/11{;*income groups;
			sum `x' [w=`w'] if `race`r''==1 & `y_`y''==1;
			matrix f21_`r'_1[`c',`y']=round(r(sum));
		};
	};
};

forvalues x=1/6{;
	noisily di "Target Population `race`x''";
	noisily matrix list f21_`x'_1;
};


*Target Population;
putexcel D11=matrix(f21_6_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D18=matrix(f21_1_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D25=matrix(f21_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D31=matrix(f21_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D37=matrix(f21_4_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D43=matrix(f21_5_1) using `using',keepcellformat modify sheet("`sheet'") ;

********************************Total Population Attending School and Target Population Attending School*******************;
tempvar national;
gen `national'=1;
local opt `edpub' `edpriv' ;

forvalues x=1/6{;*race;
	forvalues y=1/2{;//schooling options;
		matrix f21_`x'_2_`y'=J(4,11,.);
		matrix colnames f21_`x'_2_`y'=yd_125 yd_250 yl250 yd_4 yl4 yd_10 yd_50 yd_m10 ym_4 yt;
		matrix rownames f21_`x'_2_`y'=pre primary secondary tertiary;
		matrix f21_`x'_3_`y'=J(4,11,.);
		matrix colnames f21_`x'_3_`y'=yd_125 yd_250 yl250 yd_4 yl4 yd_10 yd_50 yd_m10 ym_4 yt;
		matrix rownames f21_`x'_3_`y'=pre primary secondary tertiary;
	};
};
	
forvalues r=1/6{;*race;
	local c=0;
	foreach x in `vlist0'{; *schooling;
		local c=`c'+1;
		forvalues y=1/11{;*income groups;
			*Total Population;
			sum `x' [w=`w'] if `race`r''==1 & `y_`y''==1 & `attend'==1 & `edpublic'==1;
			matrix f21_`r'_2_1[`c',`y']=round(r(sum));
			sum `x' [w=`w'] if `race`r''==1 & `y_`y''==1 & `attend'==1 & `edprivate'==1;
			matrix f21_`r'_2_2[`c',`y']=round(r(sum));
			*Target Population;
			sum `u_`x'' [w=`w'] if `race`r''==1 & `y_`y''==1 & `attend'==1 & `edpublic'==1;
			matrix f21_`r'_3_1[`c',`y']=round(r(sum));
			sum `u_`x'' [w=`w'] if `race`r''==1 & `y_`y''==1 & `attend'==1 & `edprivate'==1;
			matrix f21_`r'_3_2[`c',`y']=round(r(sum));
					
		};
	};
};

	
forvalues x=1/6{;
	noisily di "Total Population Attending Public School `race`x'' ";
	noisily matrix list f21_`x'_2_1;
	noisily di "Total Population Attending Private School `race`x'' ";
	noisily matrix list f21_`x'_2_2;
	noisily di "Target Population Attending Public School `race`x'' ";
	noisily matrix list f21_`x'_3_1;
	noisily di "Target Population Attending Private School `race`x'' ";
	noisily matrix list f21_`x'_3_2;
	};
	



*Public School;
putexcel Q11=matrix(f21_6_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q33=matrix(f21_1_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q55=matrix(f21_2_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q77=matrix(f21_3_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q99=matrix(f21_4_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q121=matrix(f21_5_2_1) using `using',keepcellformat modify sheet("`sheet'") ;

*Private School;
putexcel Q18=matrix(f21_6_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q40=matrix(f21_1_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q62=matrix(f21_2_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q84=matrix(f21_3_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q106=matrix(f21_4_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel Q128=matrix(f21_5_2_2) using `using',keepcellformat modify sheet("`sheet'") ;


*Public School;
putexcel AE11=matrix(f21_6_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE33=matrix(f21_1_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE55=matrix(f21_2_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE77=matrix(f21_3_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE99=matrix(f21_4_3_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE121=matrix(f21_5_3_1) using `using',keepcellformat modify sheet("`sheet'") ;

*Private School;
putexcel AE18=matrix(f21_6_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE40=matrix(f21_1_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE62=matrix(f21_2_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE84=matrix(f21_3_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE106=matrix(f21_4_3_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel AE128=matrix(f21_5_3_2) using `using',keepcellformat modify sheet("`sheet'") ;


putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;
*******TABLE F23: Educational Probability**************************************************************************;

program define f23_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   PL125(string)
			PL250(string)
			PL400(string)
		   edpre(varname) 
		   edpri(varname) 
		   edsec(varname) 
		   edter(varname) 
   		   attend(varname)
		   hhe(varname) 
		   hhid(varname)
		   redpre(varname) 
		   redpri(varname) 
		   redsec(varname) 
		   redter(varname) 
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
di "Educational Probability `'";
local sheet="F23. Educational Probability";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
tempfile temp1;
   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
}; 
tempvar race6;
gen `race6'=1;

if "`original'"=="" {;
display as error "Must specify Original(varname) option";
exit;
};
if "`hhe'"=="" {;
display as error "Must specify HHEad(varname) option";
exit;
};

			tempvar `original'_ppp;
			 gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');



tempvar g_o;
gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;



forvalues x=1/11{;
	tempvar y_`x';
};

gen `y_1'=cond(`g_o'==1,1,0);
gen `y_2'=cond(`g_o'==2,1,0);
gen `y_3'=cond(`g_o'==1 | `g_o'==2,1,0);
gen `y_4'=cond(`g_o'==3,1,0);
gen `y_5'=cond(`g_o'==1 | `g_o'==2 | `g_o'==3,1,0);
gen `y_6'=cond(`g_o'==4,1,0);
gen `y_7'=cond(`g_o'==5,1,0);
gen `y_8'=cond(`g_o'==6,1,0);
gen `y_9'=cond(`g_o'==5 | `g_o'==6,1,0);
gen `y_10'=cond(`g_o'==4 | `g_o'==5 | `g_o'==6,1,0);
gen `y_11'=1;

local vlist0  `edpre' `edpri' `edsec' `edter' ;

*foreach x in `vlist0'{;
*local t_`x'="`r`x''";
*	tempvar u_`x';
	*gen `u_`x''=cond((`age'>=`r1_`x'' & `age'<=`r2_`x''),1,0);
*	gen `u_`x''=`t_`x'';
*};
/*
tempvar u_`edpre';
gen `u_`edpre''=cond(`edpre'==1 & (`redpre'==1),1,0);

tempvar u_`edpri';
gen `u_`edpri''=cond(`edpri'==1 & (`redpri'==1),1,0);

tempvar u_`edsec';
gen `u_`edsec''=cond(`edsec'==1 & (`redsec'==1),1,0);

tempvar u_`edter';
gen `u_`edter''=cond(`edter'==1 & (`redter'==1),1,0);
*/
tempvar u_`edpre';
gen `u_`edpre''=cond(`redpre'==1,1,0);

tempvar u_`edpri';
gen `u_`edpri''=cond(`redpri'==1,1,0);

tempvar u_`edsec';
gen `u_`edsec''=cond(`redsec'==1,1,0);

tempvar u_`edter';
gen `u_`edter''=cond(`redter'==1,1,0);


local c=0;
foreach x in `vlist0'{; //schooling;
	local c=`c'+1;
	*The Total Number of Children in the household within the target cohort;
	tempvar tot_id1_`x';
	egen `tot_id1_`x''=sum(`u_`x'') , by(`hhid');
	replace `tot_id1_`x''=0 if `tot_id1_`x''==.;
	*The Number of children in the household within the target age cohort attending school;
	tempvar id2_`x';
	gen `id2_`x''=cond(`u_`x''==1 & `x'==1 & `attend'==1,1,0);
	tempvar tot_id2_`x';
	egen `tot_id2_`x''=sum(`id2_`x'') , by(`hhid');
	replace `tot_id2_`x''=0 if `tot_id2_`x''==.;
	tempvar net_`x';
	gen `net_`x''=`tot_id2_`x''/`tot_id1_`x'';
	*replace `net_`x''=0 if `net_`x''==.;
};

preserve;
	keep if `hhe'==1;
	

********************************Net and Gross Educational Probability***************************;

forvalues x=1/6{;//race;
	matrix f23_`x'=J(4,11,.);
	matrix colnames f23_`x'=yd_125 yd_250 yl250 yd_4 yl4 yd_10 yd_50 yd_m10 ym_10 ym_4 yt;
	matrix rownames f23_`x'=pre primary secondary tertiary ;
};


forvalues r=1/6{;//race;
	local c=0;
	foreach x in `vlist0'{; //schooling;
		local c=`c'+1;
		forvalues y=1/11{;*income groups;
			sum `net_`x'' [w=`w'] if `race`r''==1 & `y_`y''==1;
			matrix f23_`r'[`c',`y']=r(mean);
		};
	};
};

forvalues x=1/6{;
	noisily di "Educational Probability `race`x''";
	noisily matrix list f23_`x';
};



*Net Educational Probability;
putexcel D11=matrix(f23_6) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D18=matrix(f23_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D25=matrix(f23_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D32=matrix(f23_3) using `using',keepcellformat modify sheet("`sheet'") ;

putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
restore;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;

*******TABLE F24: Infraestructure Access**************************************************************************;
program define f24_race;

syntax   [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN
		   PL125(string)
			PL250(string)
			PL400(string)
		   hhe(varname) 
		   hhid(varname)
		   water(varname)
		   electricity(varname)
		   walls(varname)
		   floors(varname)
		   roof(varname)
		   sewage(varname)
		   roads(varname)
		   Original(varname)
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)];
	di "F24. Infrastructure Access";
	local sheet="F24. Infrastructure Access";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
	
	#delimit;
		forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=.;
		};
		}; 
	tempvar race6;
	gen `race6'=1;
	


	if "`original'"=="" {;
		display as error "Must specify Original(varname) option";
	exit;
	};

		
	if "`hhe'"=="" | "`hhid'"==""{;
		display as error "Must specify who is the household head and the household ID";
		exit;
		};
				
	*Race of the household head;
	tempvar racehh1;
	gen `racehh1'=.;
	forvalues x=1/5{;
		replace `racehh1'= `x' if `race`x''==1 & `hhe'==1;
		};	
	tempvar racehh;
	*Race of the household;
	egen `racehh'=mean(`racehh1'),by(`hhid');
	
	local vlist  `water' `electricity' `walls' `floors' `roof' `sewage' `roads';
	local vlist1  water electricity walls floors roof sewage roads;
	
	foreach x in `vlist1'{;//make sure variable exists;
		if "``x''"==""{;
			tempvar `x';
			gen ``x''=.;
		};
	};
	
	
			tempvar `original'_ppp;
			 gen ``original'_ppp' = (`original'/`divideby')*(1/`ppp_calculated');



tempvar g_o;
gen `g_o'=. ;
	replace `g_o'=1 if ``original'_ppp'<`cut1';
	replace `g_o'=2 if ``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2';
	replace `g_o'=3 if ``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3';
	replace `g_o'=4 if ``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4';
	replace `g_o'=5 if ``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5';
	replace `g_o'=6 if ``original'_ppp'>=`cut5' & ``original'_ppp'!=.;


	*Variables for total benefits;
	forvalues x=1/11{;
		tempvar g_o_`x';
	};
	gen `g_o_1'=cond(``original'_ppp'<`cut1',1,0);
	gen `g_o_2'=cond(``original'_ppp'>=`cut1' & ``original'_ppp'<`cut2',1,0);
	gen `g_o_3'=cond(``original'_ppp'<`cut2',1,0);
	gen `g_o_4'=cond(``original'_ppp'>=`cut2' & ``original'_ppp'<`cut3',1,0);
	gen `g_o_5'=cond(``original'_ppp'<`cut3',1,0);
	gen `g_o_6'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'<`cut4',1,0);
	gen `g_o_7'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'<`cut5',1,0);
	gen `g_o_8'=cond(``original'_ppp'>=`cut5' & ``original'_ppp'!=.,1,0);
	gen `g_o_9'=cond(``original'_ppp'>=`cut4' & ``original'_ppp'!=.,1,0);
	gen `g_o_10'=cond(``original'_ppp'>=`cut3' & ``original'_ppp'!=.,1,0);
	gen `g_o_11'=1;
	
	*Results for individuals;
	*Population;

	matrix f24_p=J(6,11,.);
	matrix colnames f24_p=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
	matrix rownames f24_p=national indig white african other nonresp;
	
			
	tempvar tot;
	gen `tot'=1;
	
	forvalues y=1/11{;//Sociodemographic group;
	summ `tot' [w=`w'] if `g_o_`y''==1;
	matrix f24_p[1,`y']=r(sum);
	
	local c=1;
	forvalues x=1/5{;//Race;
		summ `tot' [w=`w'] if `g_o_`y''==1 & `race`x''==1;
		local c=`c'+1;
		matrix f24_p[`c',`y']=r(sum);
		};
	};
	
	*National;
	putexcel D21=matrix(f24_p) using `using',keepcellformat modify sheet("`sheet'") ;
	

	*Results for Households;
	*Households;
	preserve;
	keep if `hhe'==1;//Keep only the household head;
	matrix f24_h=J(6,11,.);
	matrix colnames f24_h=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
	matrix rownames f24_h=national indig white african other nonresp;
				
	tempvar tot;
	gen `tot'=1;
	forvalues y=1/11{;//Sociodemographic group;
	summ `tot' [w=`w'] if `g_o_`y''==1;
	matrix f24_h[1,`y']=r(sum);
	
	local c=1;
	forvalues x=1/5{;//Race;
		summ `tot' [w=`w'] if `g_o_`y''==1 & `race`x''==1;
		local c=`c'+1;
		matrix f24_h[`c',`y']=r(sum);
	};
	};
	*National;
	putexcel D27=matrix(f24_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	restore;
	
	
	foreach z in `vlist'{;
	local nz=`nz'+1;
		if "`z'"==""{;
			tempvar "``z''";
			gen ``z''=.;
		};
		
		*Weighted households: Beneficiaries;
		tempvar d_b_`z';
		gen `d_b_`z''=cond(`z'==1,1,0);
		replace `d_b_`z''=. if `z'==.;
		*Households;
		tempvar hh_b_`z';
		gen `hh_b_`z''=`d_b_`z'';
		replace `hh_b_`z''=. if `hhe'!=1;
		
		
	*****Beneficiaries Matrices;
		*Weighted households;
		matrix f24_`z'_w=J(6,11,.);
		matrix colnames f24_`z'_w=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f24_`z'_w=national indig white african other nonresp;
		
		*Households;
		matrix f24_`z'_h=J(6,11,.);
		matrix colnames f24_`z'_h=yL125 yM125L250 yL250 yM250L400 yL400 yM400L1000 yM1000L5000 yM5000 YM1000 YM4000 YT;
		matrix rownames f24_`z'_h=national indig white african other nonresp;
	
	
	
	
	 forvalues x=1/11{;//groups of income;
		*Households;
		summ `hh_b_`z'' [w=`w'] if `g_o_`x''==1 & `hhe'==1;
		matrix f24_`z'_h[1,`x']=r(sum);
		*Weighted households;
		summ `d_b_`z'' [w=`w'] if `g_o_`x''==1;
		matrix f24_`z'_w[1,`x']=r(sum);
		
		local c=1;
		forvalues y=1/5{;//Ethnic groups;	
			local c=`c'+1;
			*Households;
			summ `hh_b_`z'' [w=`w'] if `g_o_`x''==1 & `race`y''==1  & `hhe'==1;
			matrix f24_`z'_h[`c',`x']=r(sum);
			*Weighted households;			
			summ `d_b_`z'' [w=`w'] if `g_o_`x''==1 & `race`y''==1;
			matrix f24_`z'_w[`c',`x']=r(sum);
	};
	};	
	noisily di "Total Beneficiaries Households: `z'";
	noisily matrix list f24_`z'_h;
	noisily di "Total Beneficiaries Weighted Households: `z'";
	noisily matrix list f24_`z'_w;
	if `nz'==1	putexcel D39=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==2	putexcel D73=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==3	putexcel D107=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==4	putexcel D141=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==5	putexcel D175=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==6	putexcel D209=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==7	putexcel D243=matrix(f24_`z'_h) using `using',keepcellformat modify sheet("`sheet'") ;
	
	if `nz'==1	putexcel D45=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==2	putexcel D79=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==3	putexcel D113=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==4	putexcel D147=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==5	putexcel D181=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==6	putexcel D215=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	if `nz'==7	putexcel D249=matrix(f24_`z'_w) using `using',keepcellformat modify sheet("`sheet'") ;
	
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
		};
	
	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};

end;

*******TABLE F25: Theil Decomposition**************************************************************************;

program define f25_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname)  
		   gender(varname)
		   URban(varname)
           edpar(varname)
		  ];
di "F25. Theil Decomposition";
local sheet="F25. Theil Decomposition";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
cap ssc install ineqdeco;

   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
};

if "`edpar'"==""{;
tempvar edpar;
gen `edpar'=1;
};

*Race involves every group that has no ethnicity;
tempvar race;
gen `race'=.;
replace `race'=0 if `race1'==1;
replace `race'=1 if `race2'==1 | `race3'==1 | `race4'==1;

if "`market'"=="" {;
display as error "Must specify Market(varname) option";
exit;
};


	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' `final';

foreach x in `incomes'{;
matrix f25_`x'=J(5,1,.);
matrix colnames f25_`x'="Portion of Theil";
matrix rownames f25_`x'=total race gender urban edpar;
};
local vlist `race' `gender' `urban' `edpar';

foreach x in `incomes'{;
ineqdeco `x' [w=`w'];
matrix f25_`x'[1,1]=r(ge1);
local c=1;
foreach y in `vlist'{;
local c=`c'+1;
ineqdeco `x' [w=`w'],by(`y');
matrix f25_`x'[`c',1]=r(between_ge1);
};
};

local L`market'="C";
local L`mpluspensions'="E";
local L`netmarket'="G";
local L`gross'="I";
local L`taxable'="K";
local L`disposable'="M";
local L`consumable'="O";
local L`final'="Q";

foreach x in `incomes'{;

noisily di "Theil `x'";
noisily matrix list f25_`x';


putexcel `L`x''8=matrix(f25_`x') using `using',keepcellformat modify sheet("`sheet'") ;
};
putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

	********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;

*******TABLE F26: Inequality of Opportunity**************************************************************************;

program define f26_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname)  
		   gender(varname)
		   URban(varname)
           edpar(varname)
		  ];
di "IneqOfOpportunity `'";
local sheet="F26. IneqOfOpportunity";
local version 2.4;
local command ceqrace;
local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

qui{;
cap ssc install ceq;

   *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		forvalues x=1/5{;
if "`race`x''"==""{;
local cc=`cc'+1;
tempvar race`x';
gen `race`x''=.;
};
};
*Race involves every group that has no ethnicity;
tempvar race;
gen `race'=.;
replace `race'=0 if `race2'==1;
replace `race'=1 if `race1'==1 | `race3'==1 | `race4'==1;
local vlist0 `gender' `urban' `race';

foreach x in `vlist0'{;
if "`x'"==""{;
tempvar `x';
gen ``x''=.;
};
};

tempvar rural;
gen `rural'=cond(`urban'==1,0,1);
tempvar gender_rural;
gen `gender_rural'=`gender' + `rural';

local vlist `gender' `rural' `race' `gender_rural';
if "`market'"=="" {;
display as error "Must specify Market(varname) option";
exit;
};


local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' `final';

oppincidence `incomes' [w=`w'],groupby(`gender');
matrix f26_1_1=r(levels);
matrix f26_2_1=r(ratios);
oppincidence `incomes' [w=`w'],groupby(`rural');
matrix f26_1_2=r(levels);
matrix f26_2_2=r(ratios);
oppincidence `incomes' [w=`w'],groupby(`race');
matrix f26_1_3=r(levels);
matrix f26_2_3=r(ratios);
oppincidence `incomes' [w=`w'],groupby(`gender_rural');
matrix f26_1_4=r(levels);
matrix f26_2_4=r(ratios);
oppincidence `incomes' [w=`w'],groupby(`vlist');
matrix f26_1_5=r(levels);
matrix f26_2_5=r(ratios);

*noisily di "Levels"; 
*noisily matrix list f26_1;
*noisily di "Ratios";
*noisily matrix list f26_2;


putexcel C9=matrix(f26_1_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel C21=matrix(f26_2_1) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D9=matrix(f26_1_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel D21=matrix(f26_2_2) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel E9=matrix(f26_1_3) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel E21=matrix(f26_2_3) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel F9=matrix(f26_1_4) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel F21=matrix(f26_2_4) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel G9=matrix(f26_1_5) using `using',keepcellformat modify sheet("`sheet'") ;
putexcel G21=matrix(f26_2_5) using `using',keepcellformat modify sheet("`sheet'") ;

putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;

********
	* OPEN *
	********;
#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
};
end;

*******TABLE F27: Significance**************************************************************************;


program define f27_race;
syntax  [if] [in] [pweight/] [using/] [,table(string) Market(varname) race1(varname) race2(varname) race3(varname) race4(varname) race5(varname) OPEN 
		   Netmarket(varname) 
		   MPLUSPensions(varname)
		   Gross(varname)
		   TAXABle(varname)
		   Disposable(varname) 
		   Postfiscal(varname) 
		   FStar(varname)
		   Consumable(varname)
		   Final(varname)  
		   psu(varname)   
		   strata(varname) 
		   PL250(string)
		   PL400(string)
		   PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
		  ];
	di "F27. Significance";
	local sheet="F27. Significance";
		local version 2.4;
	local command ceqrace;
	local versionprint ("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");

	qui{;
	 *if `"`weight'"' != "" {;
   *             local wght `"[`weight'`exp']"';
    *    };
	#delimit cr
	cap svydes
	scalar no_svydes = _rc
	tempvar ones
	gen `ones'=1
	*if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen `weightvar' = `w'
			local w `weightvar'
		}
		else local w "`ones'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}		
	
	#delimit;
		
***Svy options;
	cap svydes;
	scalar no_svydes = (c(rc)!=0);
	qui svyset;
	if "`r(wvar)'"=="" & "`exp'"=="" {;
		di as text "WARNING: weights not specified in svydes or the ceqrace command";
		di as text "Hence, equal weights (simple random sample) assumed";
	};
	else if "`r(su1)'"=="" & "`psu'"=="" {;
		di as text "WARNING: primary sampling unit not specified in svydes or the ceqrace command's psu() option";
		di as text "P-values will be incorrect if sample was stratified";
	};
	if "`psu'"=="" & "`r(su1)'"!="" {;
		local psu `r(su1)';
	};
	if "`strata'"=="" & "`r(strata1)'"!="" {;
		local strata `r(strata1)';
	};
	if "`exp'"=="" & "`r(wvar)'"!="" {;
		local weight "pw";
		local exp "= `r(wvar)'";
	};
	if "`strata'"!="" {;
		local opt strata(`strata');
	};
	* now set it:;
	if "`exp'"!="" qui svyset `psu' [w=`w'], `opt';
	else           qui svyset `psu', `opt'		;
		
	#delimit cr 	
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group  not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	* group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
		* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
		}
	}
#delimit;	

	forvalues x=1/5{;
		if "`race`x''"==""{;
			local cc=`cc'+1;
			tempvar race`x';
			gen `race`x''=0;
			local id`x'=1;
		};
		else{;
			local id`x'=0;
		};
	};
	tempvar race6;
	gen `race6'=1;
	local id6=0;
	
	if "`market'"=="" {;
		display as error "Must specify Market(varname) option";
		exit;
	};


	local incomes `market' `mpluspensions' `netmarket' `gross' `taxable' `disposable' `consumable' `final';
	di `incomes';
		
	local races `race1' `race2' `race3' `race4' `race5' `race6';
	foreach x in `incomes'{;
	matrix f27_`x'_p250=J(6,6,.);
	matrix colnames f27_`x'_p250=indig white african other nonresp national ;
	matrix rownames f27_`x'_p250=indig white african other nonresp national ;
	matrix f27_`x'_p400=J(6,6,.);
	matrix colnames f27_`x'_p400=indig white african other nonresp national ;
	matrix rownames f27_`x'_p400=indig white african other nonresp national ;
	matrix f27_`x'_g=J(6,6,.);
	matrix colnames f27_`x'_g=indig white african other nonresp national ;
	matrix rownames f27_`x'_g=indig white african other nonresp national ;
	matrix f27_`x'_t=J(6,6,.);
	matrix colnames f27_`x'_t=indig white african other nonresp national ;
	matrix rownames f27_`x'_t=indig white african other nonresp national ;
	tempvar `x'_ppp;
	gen ``x'_ppp' = (`x'/`divideby')*(1/`ppp_calculated');

	forvalues y=1/6{;
	tempvar rr_`x'_`y';
	gen `rr_`x'_`y''=``x'_ppp'*`race'`y';
	qui sum `rr_`x'_`y'';
	local idd`x'`y'=r(N);
		};};
	
	*Indicators;
	foreach x in `incomes'{;
	noisily di "`x'";
	local c=`c'+1;
	forvalues y=1/6{;
	forvalues z=1/6{;
	
	*| `idd`x'`y''!=0 | `idd`x'`z''!=0;
	if (`id`y''!=1 & `id`z''!=1) & `y'!=`z' {;
	qui difgt `rr_`x'_`z'' `rr_`x'_`y'', pline1(2.5) pline2(2.5) test(0);//$2.5ppp;
	matrix dr=e(di);
	local d_m=dr[1,1];
	local d_e=dr[1,2];
	local t=`d_m'/`d_e';
	if `t'>0{;
	local v=normalden(1-`t');
	};
	else{;
	local v=normalden(`t');
	};
	matrix f27_`x'_p250[`z',`y']=`v'; 
	};
	else{;
	matrix f27_`x'_p250[`z',`y']=.; 

	};
	
	if (`id`y''==0 & `id`z''==0) & `y'!=`z' {;
	qui difgt `rr_`x'_`z'' `rr_`x'_`y'', pline1(4) pline2(4) test(0);//$4ppp;
	matrix dr=e(di);
	local d_m=dr[1,1];
	local d_e=dr[1,2];
	local t=`d_m'/`d_e';
	if `t'>0{;
	local v=normalden(1-`t');
	};
	else{;
	local v=normalden(`t');
	};
	matrix f27_`x'_p400[`z',`y']=`v'; 
	};
	else{;
	matrix f27_`x'_p400[`z',`y']=.; 

	};
	
	if (`id`y''==0 & `id`z''==0)  & `y'!=`z' {;
	qui digini `rr_`x'_`z'' `rr_`x'_`y'',  test(0);//GINI;
	matrix dr=e(di);
	local d_m=dr[1,1];
	local d_e=dr[1,2];
	local t=`d_m'/`d_e';
	if `t'>0{;
	local v=normalden(1-`t');
	};
	else{;
	local v=normalden(`t');
	};
	matrix f27_`x'_g[`z',`y']=`v'; 
	};
	else{;
	matrix f27_`x'_g[`z',`y']=.; 

	};
	
	if (`id`y''==0 & `id`z''==0) & `y'!=`z' {;
	qui dientropy `rr_`x'_`z'' `rr_`x'_`y'',  test(0);//Theil;
	matrix dr=e(di);
	local d_m=dr[1,1];
	local d_e=dr[1,2];
	local t=`d_m'/`d_e';
	if `t'>0{;
	local v=normalden(1-`t');
	};
	else{;
	local v=normalden(`t');
	};
	matrix f27_`x'_t[`z',`y']=`v';
	};
	else{;
	matrix f27_`x'_t[`z',`y']=.; 
	};
	};
	};
	if `c'==1 {;
	putexcel C13=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C33=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C53=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C74=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==2 {;
	putexcel K13=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K33=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K53=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K74=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==3 {;
	putexcel S13=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S33=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S53=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S74=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==4 {;
	putexcel AA13=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA33=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA53=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA74=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==5 {;
	putexcel C22=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C42=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C62=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel C83=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==6 {;
	putexcel K22=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K42=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K62=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel K83=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==7 {;
	putexcel S22=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S42=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S62=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel S83=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	if `c'==8 {;
	putexcel AA22=matrix(f27_`x'_p250) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA42=matrix(f27_`x'_p400) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA62=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	putexcel AA83=matrix(f27_`x'_g) using `using',keepcellformat modify sheet("`sheet'") ;
	};
	putexcel A3=`versionprint' using `using', modify sheet("`sheet'") keepcellformat;
		
		};
		
	********
	* OPEN *
	********;

#delimit cr
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
#delimit;
	};
		end;
