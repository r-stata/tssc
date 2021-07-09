*! Bastien Perrot, Jean-Benoit Hardouin, Emmanuelle Anthoine
*************************************************************************************************************
* Stata program : validscale
* Assess validity and reliability of a multidimensional measurement scale using CTT methods

* Required modules :
* delta
* loevh
* kapci
* mi_twoway
* detect
* imputeitems
* lstrfun
* svmat2

* Version 1.1 (September 3, 2018)  /*updated the dialog box for Stata 15, fixed a bug with cfarmsea, cfacfi and cfacovs, fixed a bug with descitems when the first observation contained missing data*/
* Version 1.2 August 13, 2019 /* filessave and dirsave options */
* Version 1.2.1 August 28, 2019 /* cfa is now a wrapper for sem command; that means that most options of sem_estimation_options should work for cfa */
* Version 1.2.2 February 17, 2020 /* check if svmat2 is installed */



*************************************************************************************************************

program define validscale, rclass
version 12.0
syntax varlist [if], PARTition(numlist integer >0) [HTML(string) CATegories(numlist) SCOREName(string) scores(varlist) IMPute(string) NORound COMPScore(string) DESCitems GRAPHs cfa CFAMethod(string) cfasb CFAStand CFACov(string) CFARmsea(real -999) CFACFi(real -999) CFAOR CFANOCOVDim CONVdiv TCONVdiv(real 0.4) CONVDIVBoxplots Alpha(real 0.7) Delta(real 0.9) h(real 0.3) HJmin(real 0.3) REPet(varlist) scores2(varlist) KAPpa ICKAPpa(integer 0) kgv(varlist) KGVBoxplots KGVGroupboxplots conc(varlist) tconc(real 0.4) DIRsave(string) FILESsave *]
preserve


foreach c in delta loevh mi_twoway detect imputeitems lstrfun{
	capture which "`c'"
	if _rc qui ssc install "`c'"
}

capture which kapci
if _rc qui net install st0076, from(http://www.stata-journal.com/software/sj4-4/)

capture which svmat2 
if _rc qui net install dm79, from(http://www.stata.com/stb/stb56)


if "`if'"!="" {
   qui keep `if'
}

global html
global dirsave
global filessave

if "`filessave'" != "" {
	global filessave = "`filessave'"
}

if "`dirsave'" != "" {
	global dirsave = "`dirsave'"
}
else {
	global dirsave "`c(pwd)'"
}

if "`html'" != "" {
   global html = "`html'"
   set scheme sj
   local htmlregion  "graphregion(fcolor(white) ifcolor(white))"
   local xsize=6
   local ysize=4
   di in gr "<!-- SphereCalc start of response -->"
   di "<br />"
   di "<pre>"
}   

if "`categories'" == "" {
	foreach v in `varlist' {
		tempvar min max
		egen `min' = min(`v')
		egen `max' = max(`v')
		local mi = `min' 
		local ma = `max'
		local m `mi' `ma'
		local categories `categories' `m'
	}
}

global categories = "`categories'"
global compscore = "`compscore'"
if "$compscore" == "" global compscore = "mean"

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}

local nbvars : word count `varlist' 

if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit 119
}


if "`repet'" != "" {
	local b:word count `repet'
	if `nbvars' != `b' {
		di in red "The number of items in varlist is different from the number of items in repet"
		exit 119
	}
}

local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

local P:word count `partition'
local S:word count `scorename'

if "`scores'" != "" & "`scorename'" != "" {
	di in red "scorenames() and scores() cannot be used together"
	exit 119
}  

if "`scorename'" != "" {
	if `P'!=`S' {
		di in red "The number of score names given is different from the number of dimensions in the partition option" 
		exit 119
	}
	foreach sco in `scorename' {
		capture confirm variable `sco', exact
		if !_rc {
			di in red "`sco' already defined. You must choose names that do not already exist or use the scores() option if the scores are already defined."
			exit 119
	    }
		tokenize `scorename'
		local g = 0
		forvalues i = 1/`S' {
			if "`sco'" == "``i''" {
				local `++g'
			}
		}
		if `g' > 1 {
			di in red "2 or more dimensions have the same name"
			exit 119
		}
	}
		calcscore `varlist', scorename(`scorename') partition(`partition') compscore(`compscore') categories(`categories')
		global exist = 0
		global scorename = "`scorename'"
}

else if "`scorename'" == "" & "`scores'" == ""{

	local name
	local nname
	
	forvalues i = 1/`P' {
	
		local name "Dim`i'"
		local nname `nname' `name'
	}
	
	local scorename = "`nname'"
	global scorename = "`nname'"
	calcscore `varlist', scorename(`scorename') partition(`partition') compscore(`compscore') categories(`categories')
	global exist = 0
}

else if "`scores'" != "" {
	local P:word count `partition'
	local S2:word count `scores'
	if `P'!=`S2' {
		di in red "The number of score names given is different from the number of dimensions in the partition option" 
		exit 119
	}
	else {
		global scorename = "`scores'"
		local scorename = "`scores'"
		global exist = 1
		
	}
	
}

local nbm : word count $categories
if `nbm' !=2 &`nbm' !=`P'*2 &`nbm' !=`nbvars'*2 { 
	di in red "option categories() misspecified. You must enter either 2 or `=`nbvars'*2' or `=`P'*2' elements"
	exit 119
}

if `nbm' == 2{
	tokenize $categories
	foreach v in `varlist' {
		tempvar min
		tempvar max
		egen `min' = min(`v')
		egen `max' = max(`v')
		if `min' < `1' {
			di in red "error in option categories() : some responses have smaller values than the minimum value in categories()"
			exit 119
		} 
		if `max' > `2' {
			di in red "error in option categories() : some responses have greater values than the maximum value in categories()"
			exit 119
		} 
	}
}

if `nbm' == `nbvars'*2 {
	local i = 1
	foreach v in `varlist' {
		tempvar min max
		egen `min' = min(`v')
		egen `max' = max(`v')
		local mi = `min' 
		local ma = `max'
		tokenize $categories
		if `mi' < ``i'' {
			di in red "error in option categories() : some responses have values less than the minimum value specified for the variable in categories()"
			exit 119
		}
	local `++i'
	tokenize $categories
		if `ma' > ``i'' {
			di in red "error in option categories() : some responses have values greater than the maximum value specified for the variable in categories()"
			exit 119
		}
	local `++i'
	}
} 

if `nbm' == `P'*2 {
	local i = 1
	local y = 1
	
	foreach x in `partition' {
		//local `i++' 
		if `i' == 1 local s = `x'
		else local s = `s' +`x'
		forvalues w = `y'/`s' {
			tokenize $categories
			tempvar min max
			egen `min' = min(`var`w'')
			egen `max' = max(`var`w'')
			local mi = `min' 
			local ma = `max'
			if `mi' < ``i'' {
				di in red "error in option categories() : some responses have values less than the minimum value specified"
				exit 119
			}
			local j = `i'+1
			tokenize $categories
			if `ma' > ``j'' {
				di in red "error in option categories() : some responses have values greater than the maximum value specified"
				exit 119
			}
		}
		local i = `i'+2
		local y = `s'+1
	}
}

if "`cfa'" != "" {
	if "`cfacov'" != "" {
		if !strpos("`cfacov'", "*") { 
			di "error in cfacov() option : you must enter covariances between errors as follows: item3*item5 item7*item8 ...  "
		exit 119
	}
		local v = subinstr("`cfacov'","*"," ",.)
		foreach var in `v' {
			capture confirm variable `var'
			if _rc {
				di in red "error in cfacov() option : `var' is not a variable from the dataset"
				exit 119
			}
		}
	}
	
}

if "`kgv'" !="" {
	foreach k in `kgv' {
		capture confirm variable `k'
		if _rc!=0 {
			di in red "`k' does not exist" 
			exit 119
		}
    }
}

if "`conc'" !="" {
	foreach c in `conc' {
		capture confirm variable `c'
		if _rc!=0 {
			di in red "`c' does not exist" 
			exit 119
		}
    }
}

di as result "Items used to compute the scores"
di

local i = 1
local j = 1
local y = 1
foreach p in `partition' {
	tokenize `scorename'
	di "{bf:``i''} : " _c
	
	if `j' == 1 local s = `p'
	else local s = `s' +`p'
	forvalues z = `y'/`s' {
		di "{text:`var`z'' }" _c
	}
	local `i++' 
	local `j++' 
	local y = `s'+1
	di
}

di
di as result "Number of observations: " _c
di as text _N

qui destring _all, replace
di

if "`descitems'" != "" {
	di as result "{hline 105}"
	di "Description of items"
	di as result "{hline 105}"
	di
	descitems `varlist', partition(`partition')
	di
}


if "`graphs'" != "" {
	graphs `varlist', partition(`partition')
}						


if "`repet'" != "" {
	if "`descitems'" != "" {
		di as result "{hline 105}"
		di "Description of items (time 2)"
		di as result "{hline 105}"
		di
		descitems `repet', partition(`partition')
		di
	}
}

if "`impute'" != "" {
	if "`impute'" != "pms" & "`impute'" !="mi" {
		di in red "option impute() incorrectly specified. You must specify {hi:pms} or {hi:mi}."
		error 100
	}
	if "`impute'" == "pms" {
		pms `varlist', partition(`partition') `noround'
		if "`descitems'" != "" {
			di as result "{hline 105}"
			di "Description of items after missing data handling (PMS imputation)"
			di as result "{hline 105}"
			di
			descitems `varlist', partition(`partition')
			di
		}
		if "`repet'" != "" {
			pms `repet', partition(`partition') `noround'
			if "`descitems'" != "" {
				di as result "{hline 105}"
				di "Description of items after missing data handling (time 2)"
				di as result "{hline 105}"
				di
				descitems `repet', partition(`partition')
				di
			}
		}
	}
	if "`impute'" == "mi" {
		mitw `varlist', partition(`partition') `noround' 
		if "`descitems'" != "" {
			di as result "{hline 105}"
			di "Description of items after missing data handling (mi two-way imputation)"
			di as result "{hline 105}"
			di
			descitems `varlist', partition(`partition')
			di
		}
		if "`repet'" != "" {
			mitw `repet', partition(`partition') `noround'
			if "`descitems'" != "" {
				di as result "{hline 105}"
				di "Description of items after missing data handling (time 2)"
				di as result "{hline 105}"
				di
				descitems `repet', partition(`partition')
				di
			}
		}
	}
}  

rel `varlist', scorename(`scorename') partition(`partition') alpha(`alpha') delta(`delta') h(`h') hjmin(`hjmin') categories(`categories')
di

if "`convdiv'" != "" {
	convdiv `varlist', partition(`partition') tconvdiv(`tconvdiv') `convdivboxplots'
	di
}

if "`cfa'" != "" {
	cfa `varlist', partition(`partition') cfamethod(`cfamethod') `cfasb' `cfastand' cfacov(`cfacov') cfarmsea(`cfarmsea') cfacfi(`cfacfi') `cfaor' `cfanocovdim' `options'
	di
}

if "`repet'" != "" | "`scores2'" != "" {
	global scores2 = "`scores2'"
	repet `varlist', t2(`repet') partition(`partition') `kappa' ickappa(`ickappa')
	di
}

if "`kgv'" != "" {
	kgv `scorename', categ(`kgv') `kgvboxplots' `kgvgroupboxplots'
	di
}

if "`conc'" != "" {
	conc `scorename', comp(`conc') tconc(`tconc')
}


//capture restore, not
end


/* pms */

capture program drop pms
program pms
syntax varlist, PARTition(numlist integer >0) [NORound]

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local nbvars : word count `varlist'
if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit
}

local i = 1
local y = 1

tokenize `varlist'
foreach x in `partition' {
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' ``w'' 
	}
	
	local n : word count `liste' 
	if mod(`n',2)!=0 local max = floor(`n'/2)
	else local max = `n'/2-1
	
	if "`noround'" != "" {
		qui imputeitems `liste', method(pms) max(`max') noround 
		foreach var of varlist `liste' {
			qui replace `var' = imp`var'
			qui drop imp`var'
		}
	}
	else {
		qui imputeitems `liste', method(pms) max(`max')
		foreach var of varlist `liste' {
			qui replace `var' = imp`var'
			qui drop imp`var'
		}
	}
	
	local `i++' 
	local y = `s'+1
}

end


/* mitw */

capture program drop mitw
program mitw
syntax varlist, PARTition(numlist integer >0) [NORound]

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local nbvars : word count `varlist'
if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit
}

local i = 1
local y = 1


foreach x in `partition' {
	tokenize `varlist'
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' ``w'' 
	}
		
	qui mi_twoway `liste', scorename(scoretmp) add(1) style(wide) clear  
		
	foreach var of varlist `liste' {
		qui replace `var' = _1_`var'
		if "`noround'" == "" {
			qui replace `var' = round(`var')
		}
		/*if `var' > `maxm' {
			qui replace `var' = `maxm'
		}
		if `var' < `minm' {
			qui replace `var' = `minm'
		}*/
		qui drop _1_`var'
		capture drop scoretmp
		capture drop _1_scoretmp
	}
		
	local `i++' 
	local y = `s'+1
}

//capture drop _mi_miss
qui mi unset
end


/*  calcscore */

capture program drop calcscore
program calcscore,rclass
syntax varlist, PARTition(numlist integer >0) [categories(numlist) COMPscore(string) SCOrename(string)]

local P:word count `partition'
local S:word count `scorename'
		
local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local nbvars : word count `varlist'
if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit
}

if "`scorename'" != "" {
	if `P'!=`S' {
		di in red "The number of score names given is different from the number of dimensions in the partition option" 
		exit 119
	}
}

local i = 1
local y = 1
foreach x in `partition' {
	tokenize `varlist'
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' ``w'' 
	}
	
	tempvar nonmiss
	qui egen `nonmiss' = rownonmiss(`liste')
		
	tokenize `scorename'
	local sc = "``i''"

	if "`compscore'" == "" local compscore = "mean"

	if "`compscore'" != "mean" & "`compscore'" != "sum" & "`compscore'" != "stand" {
		di in red "option compscore incorrectly specified (choose among mean, sum and stand)"
		error 198
	}
	
	if "`compscore'" == "sum" {
		qui egen `sc' = rowmean(`liste') if `nonmiss' >= `x'/2
		qui replace `sc' = `sc'*`x'
		
	}
	
	else if "`compscore'" == "stand" {
	
		local nbm:word count `categories'
		
		local nbl:word count `liste'
		tokenize `categories'
	
		if `nbm' == 2 {
			local min = `1'*`nbl'
			local max = `2'*`nbl'
		}
	
		else if `nbm' == `P'*2 {
			local min = ``b''*`nbl'
			local max = ``=`b'+1''*`nbl'
			
		}
	
		else if `nbm' == `nbvars'*2 {
			if `y'==1 local yy = 1
			else local yy = `y'*2-1
			local bb = `yy'
			local min = 0
			local max = 0
		
			forvalues bb = `yy'(2)`=`s'*2' {
				local tpmin = ``bb''
				local tpmax = ``=`bb'+1''
				local min = `min'+`tpmin'
				local max = `max'+`tpmax'
			}
		}
			
		else {
			di in red "option categories() misspecified. You must enter either 2 or `=`nbvars'*2' or `=`P'*2' elements"
			exit 119
		}
				
		qui egen `sc' = rowmean(`liste') if `nonmiss' >= `x'/2
		qui replace `sc' = `sc'*`nonmiss'
		qui replace `sc' = (`sc'-`min')/(`max'-`min')*100
	}
	
	else {
		qui egen `sc' = rowmean(`liste') if `nonmiss' >= `x'/2
	}

local `i++' 
local y = `s'+1
}

end



/* rel */

capture program drop rel
program rel,rclass
syntax varlist, PARTition(numlist integer >0) [CATegories(numlist) SCOrename(string) Alpha(real 0.7) Delta(real 0.9) h(real 0.3) HJmin(real 0.3)]

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local nbvars : word count `varlist'

if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit
}

local P:word count `partition'
if "`scorename'" !="" {
	local S:word count `scorename'
	if `P'!=`S' {
		di in red "The number of score names given is different from the number of dimensions in the partition option" 
		exit
	}
}
di as result "{hline 105}"
di "{bf:Reliability}" 
di as result "{hline 105}"
di

local y = 1
local nbitems = 0
matrix aa = J(`P',4,.)

foreach z in `partition' {
	local nbitems = `nbitems' + `z'
}

local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

matrix d = J(`nbitems',2,.)

local i = 1
local b = 1
foreach x in `partition' {
	
	tokenize `scorename'
	
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' `var`w'' 
	}
	
	capture alpha `liste', asi item std
	local al`i' = r(alpha)
			
	capture qui loevh `liste', pairwise 
	local h`i' = r(loevH)
	matrix c = r(loevHj)	
	matrix ct = c'
		
	
	local lister = ""
	forvalues w = `y'/`s' {
		tempvar z
		qui gen `z' = round(`var`w'')
		local lister `lister' `z' 
	}
	
	tempvar nbmiss
	local nbl : word count `lister'
	egen `nbmiss' = rowmiss(`lister')
	qui count if `nbmiss'<`nbl'
	local n`i' = r(N)
	
	
	// delta
	
	if ${exist} == 0 & "$compscore" == "sum" {
	
		local nbm:word count `categories'
		tokenize `categories'
		
		if `nbm' == 2 {
			local min = `1'*`nbl'
			local max = `2'*`nbl'
		}
		
		else if `nbm' == `P'*2 {
			local min = ``b''*`nbl'
			local max = ``=`b'+1''*`nbl'
		}
		
		
		else if `nbm' == `nbvars'*2 {
			if `y'==1 local yy = 1
			else local yy = `y'*2-1
			local bb = `yy'
			local min = 0
			local max = 0
			
			forvalues bb = `yy'(2)`=`s'*2' {
				local tpmin = ``bb''
				local tpmax = ``=`bb'+1''
				local min = `min'+`tpmin'
				local max = `max'+`tpmax'
				
			}
		}
		
		else {
			di in red "option categories() misspecified. You must enter either 2 or `=`nbvars'*2' or `=`P'*2' elements"
			exit 119
		}
		
		capture delta `lister', min(`min') max(`max')
		local delt`i' = r(delta)
	
	}
	
	else local delt`i' = .
		
	local k = 0
	forvalues j = `y'/`s' {
		local k = `k'+1
		matrix d[`j',1] = ct[`k',1]
		matrix d[`j',2] = `i'
	}
	
	matrix aa [`i',1] = `al`i''
	matrix aa [`i',2] = `delt`i''
	matrix aa [`i',3] = `h`i''
	
	local `i++' 
	local y = `s'+1
	
	local b = `b'+2
}

matrix rownames d = `varlist'
local i = 1
local y = 1

foreach x in `partition' {
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	matrix C = d[`y'..`s',1.]
	local min`i' = C[1,1]
	local n : rownames C
	tokenize `n'
	local t`i' = "`1'"
	forvalues j = 1/`x' {
		local t = "``j''"
		if C[`j',1] <= `min`i'' {
			local min`i' = C[`j',1] 
			local t`i' = "``j''"
			local itmin`i' = "``j''"
		}
	}
	matrix aa [`i',4] = `min`i''
	local `i++' 
	local y = `s'+1
}

matrix colnames aa = "alpha" "delta" "H" "Hj_min"

if "`scorename'"=="" {
	local i = 1
	local y = 1
	local name
	local nname
	forvalues i = 1/`P' {
		local name "Dim`i'"
		local nname `nname' `name'
	}
local scorename = "`nname'"
}	

local maxlen = 0
foreach sco in `scorename' {
	local w = length("`sco'")
	if `w' > `maxlen' local maxlen = `w'
}

local i = 1
local j = 1
local y = 1
local col = `maxlen'+8

di _col(`col') "{bf:n}" _c
local col = `col'+6
di _col(`col') "{bf:alpha}" _c
local col = `col'+10
di _col(`col') "{bf:delta}" _c
local col = `col'+14
di _col(`col') "{bf:H}" _c
local col = `col'+5
di _col(`col') "{bf:Hj_min}"

foreach s in `scorename' {
	di in blue "{bf:`s'}" _c
	local col = `maxlen'+3
	
	local n : di %6.0f `n`i''
	
	di in blue _col(`col') "{text:`n'}" _c
	local col = `col'+10
	
	local a : di %6.2f `al`i''
	if `a' < `alpha' {
		di _col(`col') "{error:`a'} " _c
	}
	else di _col(`col') "{text:`a'}" _c
	
	local col = `col'+10
	local d : di %6.2f `delt`i''
	if `d' < `delta' {
		di _col(`col') "{error:`d'} " _c
	}
	else di _col(`col') "{text:`d'}" _c
	
	local col = `col'+10
	local ht : di %6.2f `h`i''
	if `ht' < `h' {
		di _col(`col') "{error:`ht'} " _c
	}
	else di _col(`col') "{text:`ht'}" _c
	
	local col = `col'+8
	local m : di %8.2f `min`i''
	if `m' < `hjmin' {
		di _col(`col') "{error:`m'} " _c
		di "{text:(item `itmin`i'')}" _c
	}
	else di _col(`col') "{text:`m'}" _c
	
	di
	local `++i'
}

end

/* descitems */

capture program drop descitems
program descitems
syntax varlist, PARTition(numlist integer >0)
local i = 1

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}

local nbvars : word count `varlist'

if `C' != `nbvars' {
	di in red "The sum of the numbers in the partition option is different from the number of variables precised in varlist"
	exit 119
}


local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

foreach var in `varlist' {
	qui replace `var' = round(`var')
}

local lev = ""
foreach var in `varlist' {
	qui levelsof `var', local(levels)
	foreach l in `levels' {
		if strpos("`lev'","`l'") == 0 {
		local lev `lev' `l'	
		}
	}
}

_qsort_index `lev'
local lev = r(slist1)

local i = 1
matrix d = J(`nbvars',4,.)

foreach var in `varlist'{
	qui count if missing(`var')
	local ct=r(N)
	
	local tx`i'=`ct'/_N
	matrix d[`i',1] = `tx`i''
	local `i++'
}

matrix rownames d = `varlist'
matrix colnames d = "missing" "alpha" "Hj" 

local i = 1
local y = 1
foreach x in `partition' {
	
	if `i' == 1 local s = `x'
	else local s = `s' +`x'

	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' `var`w'' 
	}
	
	qui capture alpha `liste', asi item std
	
	mat a = r(Alpha)
	mat at = a'
	
	qui capture loevh `liste', pairwise pair
	matrix e = r(loevHj)	
	matrix et = e'
	
	//matrix ns = r(nbHjkNS)	
	//matrix nst = ns'
	
	
	matrix pval = r(pvalHjk)
	forvalues c = 1/`x' {
		forvalues r = 1/`x' {
			if pval[`r',`c']>0.05 {
				local ns`r' = `ns`r''+1
			}
			else local ns`r' = `ns`r''+0
		}
	}
	
	
	foreach z in `partition' {
		local nbitems = `nbitems' + `z'
	}
	matrix nst = J(`nbitems',1,0)
	local r = 1
	forvalues j = `y'/`s'{
		matrix nst[`j',1]=`ns`r''
		local `r++'
	}
		
	
	local k = 0
	forvalues j = `y'/`s' {
		local k = `k'+1
		matrix d[`j',2] = at[`k',1]
		matrix d[`j',3] = et[`k',1]
		matrix d[`j',4] = `ns`k''
		
	}
	local `i++' 
	local y = `s'+1	
	
	forvalues j = 1/21{
		local ns`j' = 0
	}
}



local i = 1
foreach v in `varlist' {
	local var`i' = abbrev("`v'",8)
	local `++i'
}

local dec = 10
local col = `dec'


local minm = 999
local maxm = -999
foreach mod in $categories {
	if `mod' < `minm' local minm = `mod'
	if `mod' > `maxm' local maxm = `mod'
}

local b = `maxm'-`minm'+1

local i = 1
local j = 1
local y = 1

di in blue _col(`dec') "{bf:Missing}" _c
local col = `col'+11
di in blue _col(`=`col'+2') "{bf:N}" _c

local col = `col'+9
di _col(`col') "{bf:Response categories}" _c
local col = `dec'+18+8*`b'
di _col(`col') "{bf:Alpha}" _c
local col = `col'+9
di _col(`col') "{bf:Loevinger}" _c  
local col = `col'+12
di _col(`col') "{bf:Number of}" 

local col = `dec'-1
di _col(`col') "{bf:data rate}" _c
local col = `dec'+18

forvalues m = `minm'/`maxm' {
	di _col(`=`col'+2') "`m'" _c
	local col = `col'+8
}

di as result _col(`col') "- item" _c
local col = `col'+10
di as result _col(`col') "Hj coeff" _c 
local col = `col'+12
di as result _col(`col') "NS Hjk"  

local ch = `dec'+18+8*`b'+29
di "{hline `ch'}"

local i = 1 
foreach x in `varlist' {
	local varo`i' = "`x'"
	local `++i'
}

local y = 1
foreach p in `partition' {
	
	if `j' == 1 local s = `p'
	else local s = `s' +`p'
	
	forvalues z = `y'/`s' { 
		local col = `dec'
		di "{bf:`var`z''}" _c
		local t = d[`z',1]
		local t : di %8.2f `t'*100 
		di _col(`col') "{text:`t'%}" _c
		qui count if missing(`varo`z'')
		local m = r(N)
		local N = _N-`m'
		local N : di %4.0f `N'
		local col = `col'+10
		di _col(`col') "{text:`N'}" _c
		
		local col = `col'+8
		forvalues m = `minm'/`maxm' {
			qui count if round(`varo`z'') == `m'
			local n = r(N)
			if `m' == `maxm' & round(`varo`z'')>`maxm' & `varo`z''!=.{
				local n = `n' + 1
			}
			if `m' == `minm' & round(`varo`z'')<`minm' & `varo`z''!=.{
				local n = `n' + 1
			}
			qui count if `varo`z'' != . 
			local d = r(N)
			local e = `n'/`d'
			local e : di %4.2f `e'*100
			if `e' != 0 di _col(`=`col'-1')"{text:`e'%}" _c
			else di _col(`=`col'-1')"{text:   -}" _c
			local col = `col'+8
		}
		local a = d[`z',2]
		local a : di %4.2f `a'
		di _col(`=`col'+1') "{text:`a'}" _c
		local h = d[`z',3]
		local h : di %5.2f `h'
		local col = `col'+10
		di _col(`=`col'+3') "{text:`h'}" _c
		local ns = d[`z',4]
		local ns : di %2.0f `ns'
		local col = `col'+11
		di _col(`=`col'+7') "{text:`ns'}" 
			
	}
	local `i++' 
	local `j++' 
	local y = `s'+1
	di "{dup `ch':-}" 
}
end


capture program drop graphs
program graphs
syntax varlist, PARTition(numlist integer >0)

local P:word count `partition'
local html = "${html}"

local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

if "$compscore" == "stand" local w = 10
if "$compscore" == "sum" local b = 10
if "$compscore" == "mean" local w = 0.5




if "`html'"!="" {
	//set graphics off
	foreach s in $scorename {
		qui local saving "saving(`c(tmpdir)'/`html'_`s',replace) nodraw"
		qui hist `s', name(`s',replace) percent fcolor(emidblue) lcolor(none) width(`w') bin(`b') `saving'
		qui graph use `c(tmpdir)'/`html'_`s'.gph
		qui graph export `c(tmpdir)'/`html'_`s'.png, replace
		//di "<img src=" _char(34) "/data/`html'_`s'.png" _char(34) 
		//di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "hist score" _char(34) " title= " _char(34) "hist score - click to enlarge" _char(34) " width=" _char(34) "300" _char(34) " height=" _char(34) "200" _char(34) ">"

	}
	//set graphics on

	
	
	qui local saving "saving(`c(tmpdir)'/`html'_group,replace) nodraw"
	qui gr combine $scorename, name(group,replace) title("Distribution of scores") `saving'  
	qui graph use `c(tmpdir)'/`html'_group.gph
	qui graph export `c(tmpdir)'/`html'_group.png, replace
	//di "<img src=" _char(34) "/data/`html'_group.png" _char(34) 
	//di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "group" _char(34) " title= " _char(34) "Distributions of scores - click to enlarge" _char(34) " width=" _char(34) "300" _char(34) " height=" _char(34) "200" _char(34) ">"

	
	qui local saving "saving(`c(tmpdir)'/`html'_scores,replace) nodraw"
	qui biplot $scorename, name("Biplot_scores",replace) norow std title("Correlations between scores") xtitle("") ytitle("") `saving'
	qui graph use `c(tmpdir)'/`html'_scores.gph
	qui graph export `c(tmpdir)'/`html'_scores.png, replace
	//di "<img src=" _char(34) "/data/`html'_scores.png" _char(34) 
	//di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "Correlations scores" _char(34) " title= " _char(34) "Correlations between scores - click to enlarge" _char(34) " width=" _char(34) "300" _char(34) " height=" _char(34) "200" _char(34) ">"
}

else {
	set graphics off
	foreach s in $scorename {
		qui hist `s', name("`s'",replace) percent fcolor(emidblue) lcolor(none) width(`w') bin(`b')
	}
	set graphics on

	gr combine $scorename, name("Histograms_scores",replace)
	if ("$filessave"!="") qui graph export ${dirsave}/Histograms_scores.png, replace

	capture biplot $scorename, name("Biplot_scores",replace) norow std title("") xtitle("") ytitle("")
	if ("$filessave"!="") qui graph export ${dirsave}/Biplot_scores.png, replace

}



capture biplot `varlist', name("temp",replace) norow std nograph

mat a = r(V)

tempvar a1 a2
mat colnames a = `a1' `a2'
svmat a, names(col)

tempvar mina1 mina2 maxa1 maxa2
egen `mina1' = min(`a1')
egen `mina2' = min(`a2')
egen `maxa1' = max(`a1')
egen `maxa2' = max(`a2')
local mina1 = `mina1'
local mina2 = `mina2'
local maxa1 = `maxa1'+1.4
local maxa1x = `maxa1'+0.3
local maxa2 = `maxa2'

local colors = "red blue black green ebblue mint erose orange maroon magenta mint gray teal navy olive sienna"
local i = 1
foreach c in `colors' {
	local col`i' = "`c'"
	local `++i'
}

local i = 1
local y = 1
local c = 1
local bas = `maxa2'+0.2
local droite = max(`maxa1',0.2)

foreach x in `partition' {
	tokenize $scorename
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	forvalues j=`y'/`s' {
		local a = `a1'[`j']
		local b = `a2'[`j']	
		local call `call' || pcarrowi 0 0 `b' `a' "`var`j''", mlabcolor(`col`i'') color(`col`i'') head   
	}
	local bas = `bas'-0.2
	local call `call' text(`bas' `droite' "``i''", size(3) color(`col`i'')) /*`bas' `droite' "``i''", mlabcolor("`r' `g' `b'")*/
	local `++i' 
	local y = `s'+1	
	local `++c' 
}


if "`html'" != "" {
	qui local saving "saving(`c(tmpdir)'/`html'_items,replace) nodraw"
	qui twoway `call' name("items",replace) legend(off) xscale(range(`mina1' `maxa1x')) yscale(range(`mina2' `maxa2')) title("Correlations between items") xtitle("") ytitle("") xsize(`xsize') ysize(`ysize') `saving'
	qui graph use `c(tmpdir)'/`html'_items.gph
	qui graph export `c(tmpdir)'/`html'_items.png, replace
	//di "<img src=" _char(34) "/data/`html'_items.png" _char(34) 
	//di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "Correlations items" _char(34) " title= " _char(34) "Correlations between items - click to enlarge" _char(34) " width=" _char(34) "300" _char(34) " height=" _char(34) "200" _char(34) ">"
}
else {
	qui twoway `call' name("Biplot_items",replace) legend(off) xscale(range(`mina1' `maxa1x')) yscale(range(`mina2' `maxa2')) xtitle("") ytitle("")
	if ("$filessave"!="") qui graph export ${dirsave}/Biplot_items.png, replace

}


							
end

/* convdiv */

capture program drop convdiv
program convdiv
syntax varlist, PARTition(numlist integer >0) [TCONVdiv(real 0.4) convdivboxplots]
preserve

//qui set autotabgraphs on




local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local nbvars : word count `varlist'
local P:word count `partition'
local cptdiv = 0
local cptconv = 0

if ${exist} != 1 {

	qui detect `varlist', partition(`partition') 

	matrix A = r(Corrrestscores)
	matrix B = r(Corrscores)

	local i = 1
	local y = 1

	foreach x in `partition' {
		if `i' == 1 local s = `x'
		else local s = `s' +`x'
		
		forvalues z = `y'/`s' {
			matrix B[`z',`i'] = A[`z',`i']
		}
		local `i++' 
		local y = `s'+1
	} 

	matrix colnames B = $scorename

    local i = 1
	foreach v in `varlist' {
		local var`i' = abbrev("`v'",10)
		local `++i'
	}

	local i = 1
	foreach s in $scorename {
		local s`i' = abbrev("`s'",7)
		local sc `sc' `s`i''
		local `++i'
	}

	di as result "{hline 105}"
	di "{bf:Correlation matrix}"
	di "{hline 105}"
	di

	local dec = 10
	local col = `dec'

	local decit = 14
	local colit = `decit'


	local col1 = `decit'
	forvalues i=1/`P' {
		di _col(`col1') "{bf:`s`i''}" _c
		local col1 = `col1' + `dec'
	}

	di 
	local h = (`P'-1)*`dec'+`decit'+4
	di "{hline `h'}"

	local i = 1
	local j = 1
	local y = 1

	foreach p in `partition' {
		if `j' == 1 local s = `p'
		else local s = `s' +`p'
		
		forvalues z = `y'/`s' { 
			di as text "{bf:`var`z''}" _c
			local col = `decit'-1	
			
			local dd = `z' // [count cptdiv (one per item)] 
			
			forvalues k = 1/`P' { 
					
				local t = B[`z',`k']
				local t : di %6.3f `t'
				if `k' == `i' {
					if `t' < `tconvdiv' {
						/*if "${html}" != "" {
							di "<p style=" _char(34) "color:red" _char(34)">"
							di _col(`col') "{bf:`t'}" _c
							di "</p>"
						}*/
						//else {
							di in red _col(`col') "{bf:`t'}" _c
						//}
						
						local cptconv = `cptconv'+1
						local col = `col' + `dec'
					}
					else {
						/*if "${html}" != "" {
							di "<p style=" _char(34) "color:blue"_char(34)">"
							di as text _col(`col') "{bf:`t'}" _c
							di "</p>"
						}*/
						//else {
							di as text _col(`col') "{bf:`t'}" _c
						//}
						local col = `col' + `dec'
					}
				}
				else {
					
					if B[`z',`k'] > B[`z',`i'] {
						/*if "${html}" != "" {
							di "<span style=" _char(34) "color:red"_char(34)">"
							di in red _col(`col') "`t'" _c
							di "</span>"
						}*/
						//else {
							di in red _col(`col') "`t'" _c
						//}
						
						if `dd' == `z' local cptdiv = `cptdiv'+1 // [one per item]
						local dd = 0
						local col = `col' + `dec'
					}
					else {
						/*if "${html}" != "" {
							di "<p>"
							di as text _col(`col') "{text:`t'}"_c
							di "</p>"
						}*/
						//else {
							di as text _col(`col') "{text:`t'}"_c
						//}
						
						local col = `col' + `dec'
					}
				}
			}
		di 
		}
		di as text "{dup `h':-}"
		local `i++' 
		local `j++' 
		local y = `s'+1
	}

	local y = 1
	local h = 1
	local np : word count `partition'

	foreach p in `partition' {
		if `h' == 1 local s = `p'
		else local s = `s' +`p'
		
		forvalues j = 1/`np' {
			mat C_`h'_`j' = B[`y'..`s',`j']
			
			tempvar tp_`h'_`j'
			mat colnames C_`h'_`j' = `tp_`h'_`j''
			
			svmat C_`h'_`j', names(col)
		}
		
		local `++h' 
		local y = `s'+1
	}

}

else if ${exist} == 1 {

	di as result "{hline 105}"
	di "{bf:Correlation matrix (without rest-scores)}"
	di "{hline 105}"
	di
	
		
	local i = 1
	foreach v in `varlist' {
		local var`i' = abbrev("`v'",10)
		local `++i'
	}

	local i = 1
	foreach s in $scorename {
		local s`i' = abbrev("`s'",7)
		local sc `sc' `s`i''
		local `++i'
	}
	
	local dec = 10
	local col = `dec'

	local decit = 14
	local colit = `decit'

	local col1 = `decit'
	forvalues i=1/`P' {
		di _col(`col1') "{bf:`s`i''}" _c
		local col1 = `col1' + `dec'
	}

	di 
	local h = (`P'-1)*`dec'+`decit'+4
	di "{hline `h'}"
	
	qui corr $scorename `varlist' 
	matrix c = r(C)
	matrix B = c[`=`P'+1'..`nbvars'+`P',1..`P']
		
	local i = 1
	local j = 1
	local y = 1
	
	foreach p in `partition' {
		if `j' == 1 local s = `p'
		else local s = `s' +`p'
		
		forvalues z = `y'/`s' { 
			di as text "{bf:`var`z''}" _c
			local col = `decit'-1	
			
			local dd = `z' // [count cptdiv (one per item)] 
			
			forvalues k = 1/`P' { 
					
				local t = B[`z',`k']
				local t : di %6.3f `t'
				if `k' == `i' {
					if `t' < `tconvdiv' {
						di in red _col(`col') "{bf:`t'}" _c
						local cptconv = `cptconv'+1
						local col = `col' + `dec'
					}
					else {
						di _col(`col') "{bf:`t'}" _c
						local col = `col' + `dec'
					}
				}
				else {
					
					if B[`z',`k'] > B[`z',`i'] {
						di in red _col(`col') "`t'" _c
						
						if `dd' == `z' local cptdiv = `cptdiv'+1 // [one per item]
						local dd = 0
						local col = `col' + `dec'
					}
					else {
						di as text _col(`col') "{text:`t'}"_c
						local col = `col' + `dec'
					}
				}
			}
		di 
		}
		di "{dup `h':-}"
		local `i++' 
		local `j++' 
		local y = `s'+1
	}

	local y = 1
	local h = 1
	local np : word count `partition'

	foreach p in `partition' {
		if `h' == 1 local s = `p'
		else local s = `s' +`p'
		
		forvalues j = 1/`np' {
			mat C_`h'_`j' = B[`y'..`s',`j']
			
			tempvar tp_`h'_`j'
			mat colnames C_`h'_`j' = `tp_`h'_`j''
			
			svmat C_`h'_`j', names(col)
		}
		
		local `++h' 
		local y = `s'+1
	}
}

if "`convdivboxplots'" != "" {

	if "${html}" != "" {
		local html = "${html}"
		di "</pre>"
		di "<div style=" _char(34) "width:750px;" _char(34) ">"
		
		
		local colors = "red blue green orange maroon magenta ebblue mint erose gray teal navy olive sienna"
		local i = 1
		foreach c in `colors' {
			local col`i' = "`c'"
			local `++i'
		}
		
		forvalues h = 1/`np' {
			tokenize $scorename
			local call = ""
			local callbox = ""
			local callleg = ""
			
			forvalues j = 1/`np' {
				local call `call' `tp_`h'_`j''
				local callbox `callbox' box(`j',fcolor(`col`j'') lcolor(`col`j'')) marker(`j', mcolor(`col`j'')) 
				local lab = "``j''"
				local lab = `"`lab'"'
				local callleg `callleg' `j' "`lab'"
			}
			
			qui local saving "saving(`c(tmpdir)'/`html'_Conv_div_``h'',replace) nodraw"
			qui graph box `call', name("Conv_div_``h''",replace) `callbox' legend(order(`"`callleg'"') stack rows(1) size(small)) title(Correlations between items of ``h'' and scores) yline(`tconvdiv', lpattern(dot) lcolor(black)) `saving'  
			qui graph use `c(tmpdir)'/`html'_Conv_div_``h''.gph
			qui graph export `c(tmpdir)'/`html'_Conv_div_``h''.png, replace
			
			di "<img src=" _char(34) "/data/`html'_Conv_div_``h''.png" _char(34) 
			di "style="_char(34) "margin-bottom:10px;margin-right:22px" _char(34)" class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "convdiv boxplots" _char(34) " title= " _char(34) "Correlations between items of ``h'' and scores - click to enlarge" _char(34) " width=" _char(34) "225" _char(34) " height=" _char(34) "150" _char(34) ">"
					
			
			
			//qui set autotabgraphs on
		}
		di "</div>"
		di "<pre>"
	}
	
	else {
		forvalues h = 1/`np' {
		tokenize $scorename
		local call = ""
		local callbox = ""
		local callleg = ""
		
		forvalues j = 1/`np' {
			local call `call' `tp_`h'_`j''
			local callbox `callbox' box(`j',fcolor(`color') lcolor(`color')) marker(`j', mcolor(`color')) 
			local lab = "``j''"
			local lab = `"`lab'"'
			local callleg `callleg' `j' "`lab'"
		}
		di "ok1"
		graph box `call', name("Conv_div_``h''",replace) `callbox' legend(order(`"`callleg'"') stack rows(1) size(small)) title(Correlations between items of ``h'' and scores) yline(`tconvdiv', lpattern(dot) lcolor(black))
		di "ok2"
		if ("$filessave"!="") qui graph export ${dirsave}/Conv_div_``h''.png, replace
		qui set autotabgraphs on
		}
	}
}


local t : di %5.3f `tconvdiv'
local p1 = (`nbvars'-`cptconv')/`nbvars'*100
local p1 : di %4.1f `p1'
local p2 = (`nbvars'-`cptdiv')/`nbvars'*100
local p2 : di %4.1f `p2'

di
di as result "Convergent validity:" _c
di as text " `=`nbvars'-`cptconv''/`nbvars' items (`p1'%) have a correlation coefficient with the score of "
di _col(22) "their own dimension greater than `t'"
di
di as result "Divergent validity:" _c
di as text "  `=`nbvars'-`cptdiv''/`nbvars' items (`p2'%) have a correlation coefficient with the score"
di _col(22) "of their own dimension greater than those computed with other scores." 

end

/* cfa */

capture program drop cfa
program cfa,rclass
syntax varlist, PARTition(numlist integer >0) [CFAMethod(string) cfasb CFAStand CFACov(string) CFARmsea(real -999) CFACfi(real -999) CFAOR CFANOCOVDim *] 
preserve

if "`cfasb'"!="" & `cfacfi'!=-999 {
	di in red "You cannot use both cfasb and cfacfi()"
	exit 119
} 

if "`cfasb'"!="" & `cfarmsea'!=-999 {
	di in red "You cannot use both cfasb and cfarmsea()"
	exit 119
}


	
if `cfarmsea' == -999{
	local cfarmsea 
	//di in red "error in cfaautormsea option : you must specify a value"
	//exit 119
}
if `cfacfi' == -999{
	local cfacfi
	//di in red "error in cfaautocfi option : you must specify a value"
	//exit 119
}
	
local nbvars:word count `varlist'	
local P:word count `partition'
	
local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

/*
if "`cfarmsea'" != "" & "`cfacov'" != "" {
	di in red "You cannot use both cfacov() and cfarmsea"
	exit 119
}
if "`cfacfi'" != "" & "`cfacov'" != "" {
	di in red "You cannot use both cfacov() and cfacfi"
	exit 119
}
*/	
if "`cfacov'" != "" {
	
	lstrfun v, subinstr("`cfacov'","*"," ",.)
	foreach var in `v' {
		capture confirm variable `var'
		if _rc {
			di in red "error in cfacov() option : `var' is not a variable from the dataset"
			exit 119
		}
	}
	lstrfun s,  subinstr("`cfacov'","* ","*",.)
	lstrfun s,  subinstr("`s'"," *","*",.)
	lstrfun s,  subinstr("`s'","*","*e.",.)
	lstrfun f,  subinstr("`s'"," "," e.",.)
	local g e.`f'
	lstrfun g , lower("`g'")
    local covs `g'
}

local i = 1 
foreach x in `varlist' {
	local var`i' = lower("`x'")
	qui rename `x' `var`i''
	local `++i'
}

local upscorename = upper("$scorename")

local i = 0
local y = 1
tokenize `upscorename'
foreach x in `partition' {
	local `i++' 
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	local liste = ""
	forvalues w = `y'/`s' {
		local liste `liste' `var`w'' 
	}
	
	local a =  "(``i'' -> `liste')"
	local zz `zz' `a'
		
	local y = `s'+1
}

if "`cfamethod'" == "" local cfamethod = "ml"

if "`cfamethod'" != "ml" & "`cfamethod'" != "mlmv" & "`cfamethod'" != "adf" {
	di "`cfamethod'"
	di in red "option cfamethod incorrectly specified (choose among ml, mlmv and adf)."
	error 198
}

if "`cfastand'" != "" local cfastand = "stand"

if "`cfasb'" != "" {
	local cfasb = "vce(sbentler)"
	local sb = "_sb"
}

di as result "{hline 105}"
di "{bf:Confirmatory factor analysis}"
di as result "{hline 105}"

local exitloop = 0
foreach v in `varlist' {
		local low = lower("`v'")
		qui su `low'
		local range = r(max)-r(min)+1
		if `range' < 5 & "`cfamethod'"=="ml"{
			local message "Warning: some items have less than 5 response categories. If multivariate normality assumption does not hold, maximum likelihood estimation might not be appropriate. Consider using cfamethod(adf)."
			continue, break
		}
		else if `range' >= 5 & `range' < 7  & "`cfamethod'"=="ml" & "`cfasb'" == "" {
			local message "Warning: some items have less than 7 response categories. If multivariate normality assumption does not hold, maximum likelihood estimation might not be appropriate. Consider using cfasb in order to apply Satorra-Bentler adjustment or using cfamethod(adf)."
			continue
		}
}

di in red "`message'"

local ii = 1
local s
local stop = 0 

while (`ii' == 1 | "`covsi'" != "") & `stop'!=1 {
	if `ii' == 1 & ("`cfarmsea'"!="" | "`cfacfi'"!="") {
		di
		di as text "step 1 (model without covariances between errors)" 
	}
	if "`covs'" != "" & ("`cfarmsea'"!="" | "`cfacfi'"!="") di _n "{bf:step `ii':} {text:`covsi'}"
	local covsi
	
	
	if "`cfanocovdim'" == "" {
		qui sem `zz', method(`cfamethod') `cfastand' cov(`covs') `cfasb' `options'
	}
	else {
		qui sem `zz', method(`cfamethod') `cfastand' cov(`covs') covstruct(_lexogenous, diagonal) `cfasb' `options'
	}
	local vce = e(vce)
	
	/* factor loadings */

	matrix r = r(table)
	matrix r = r[1,1...]
	matrix r = r'
	local n = `nbvars'*2 

	matrix a = r[1,1]
	forvalues i=3(2)`n' {
		matrix b = r[`i',1]
		matrix a = a\b
	}

	/* standard error factor loadings*/

	matrix r = r(table)
	matrix r = r[2,1...]
	matrix r = r'
	local n = `nbvars'*2 

	matrix sef = r[1,1]
	forvalues i=3(2)`n' {
		matrix b = r[`i',1]
		matrix sef = sef\b
	}

	
	/* intercepts */

	matrix r = r(table)
	matrix r = r[1,1...]
	matrix r = r'
	local n = `nbvars'*2 

	matrix a2 = r[2,1]
	forvalues i=4(2)`n' {
		matrix b = r[`i',1]
		matrix a2 = a2\b
	}
	
	
	/* standard error intercepts*/

	matrix r = r(table)
	matrix r = r[2,2...]
	matrix r = r'
	local n = `nbvars'*2 

	matrix sei = r[1,1]
	forvalues i=3(2)`n' {
		matrix b = r[`i',1]
		matrix sei = sei\b
	}
	
	//mat li sei
	/* error variances */

	local m = `n'+1
	matrix r = r(table)
	matrix r = r[1,`m'...]
	matrix r = r'

	matrix a3 = r[1,1]
	forvalues i=2/`nbvars' {
		matrix b = r[`i',1]
		matrix a3 = a3\b
	}

	/* variance of dimensions*/

	matrix r = r(table)
	local n = `nbvars'*3+1
	matrix r = r[1,`n'...]
	matrix r = r'

	matrix var = r[1,1]
	forvalues i=2/`P' {
		matrix b = r[`i',1]
		matrix var = var\b
	}
	
	//mat li var
	
	/* Covariances between dimensions */
	
	matrix r = r(table)
	local P:word count `partition'
	if `P' > 1 {
		local one = 1
	}
	else{
		local one = 0
	}
	local n = `nbvars'*3+`one'+`P'
	
	
	if "`cfanocovdim'" == "" {
		//mat li r
		matrix r = r[1,`n'...]
		//mat li r
		matrix c = J(`P',`P',.)
		
		local nbcov:word count `cfacov'
		local `++nbcov'
		
		local k = `nbcov'
		forvalues c = 1/`P' { 
			forvalues r = 2/`P' {
				if `r'>`c' {
					matrix c[`r',`c']=r[1,`k']
					local `++k'
				}
			}
		}
		
		local k = 1
		forvalues c = 1/`P' { 
			matrix c[`c',`c']=var[`k',1]
			local `++k'
		}
			
		matrix rownames c = $scorename
		matrix colnames c = $scorename
	}
	
	if ("`cfarmsea'"!="" | "`cfacfi'"!="") {
		local stoprmsea = 0
		 local stopcfi = 0
		if "`cfarmsea'"!="" {
			qui estat gof
			di "rmsea =" round(r(rmsea),0.001)
			if r(rmsea)<=`cfarmsea' {
				local stoprmsea = 1
			}
			//else local stoprmsea = 0
		}
		else local stoprmsea = 1
		if "`cfacfi'"!="" {
			qui estat gof
			di "cfi =" round(r(cfi),0.001)
			if r(cfi)>=`cfacfi' {
				local stopcfi = 1
			}
			//else local stopcfi = 0
		}
		else local stopcfi = 1
		
	
		
		/* OR */ 
		if "`cfaor'"!="" {
			if `stoprmsea'==1 | `stopcfi'==1 {
				local stop = 1
			}
		}
		/* AND */ 
		if "`cfaor'"=="" {
			if `stoprmsea'==1 & `stopcfi'==1 {
				local stop = 1
			}
		}
	}
	
	
	if ("`cfarmsea'"!="" | "`cfacfi'"!="") & `stop'!=1 {
		qui estat mindices, showpclass(mcons merrvar)
		tempname mm nomcol
		mat `mm' = r(mindices)
				
		svmat2 `mm' , r(`nomcol') full
		gsort - `mm'1
		
		local nrows = rowsof(`mm')
		
		local y = 1
		local i = 0
		foreach x in `partition' {
			local `i++' 
			if `i' == 1 local s = `x'
			else local s = `s' +`x'
			
			forvalues w = `y'/`s' {
				local class_`var`w'' = `i'
			}
			local y = `s'+1
		}
		
		
		forvalues i = 1/`nrows' {
			local tmp3=`nomcol'[`i']
			lstrfun e, subinstr("`tmp3'","cov(","",.)
			lstrfun e, subinstr("`e'",")","",.)
			lstrfun e, subinstr("`e'",":_cons","",.)
			lstrfun e, subinstr("`e'",",","*",.)
			
			lstrfun d, subinstr("`e'",","," ",.)
			lstrfun d, subinstr("`d'","e.","",.)
			lstrfun d, subinstr("`d'","*"," ",.)
			
			qui replace `nomcol' = "`d'" in `i'
			
			local d = `nomcol'[`i']
			
			tokenize "`d'"
			if "`class_`1''" != "`class_`2''" {
				qui replace `nomcol' = "" in `i'
			}
			
			local tmp3=`nomcol'[`i']
			
			if "`tmp3'" != "" {
				continue, break
			}
			else {
				local e
			}
			
			
		}
		
		
		
				
		local covsi `e'
		local covs `covs' `e'
		drop `mm'1-`nomcol'

	}
	
	if e(converged) == 0 di in red "Warning : model did not converge after `e(ic)' iterations"
	local `++ii'
	
}

local i = 1
foreach v in `varlist' {
	local var`i' = abbrev("`v'",10)
	local `++i'
}

local i = 1
foreach s in $scorename {
	local s`i' = abbrev("`s'",10)
	local sc `sc' `s`i''
	local `++i'

}

local max = 10
local dec = `max'+5

local max2 = 10

local dec2 = `dec'+`max2'+5

local a = e(N)
di
if e(converged) == 0 di in red "Warning : model did not converge after `e(ic)' iterations"
di as result ""
if "`covs'" != "" {
	di as result "{bf:Covariances between errors added:} {text:`covs'}"
	di
}
di "{bf:Number of used individuals: } {text:`a'}"
di
//di _col(`=`dec2'+17+4') "{bf:Estimation:}"


di as result "{bf:Item}" _c
di _col(`dec') "{bf:Dimension}" _c 
di _col(`dec2') "{bf:Factor}" _c 
di _col(`=`dec2'+14') "{bf:Standard}" _c 
di _col(`=`dec2'+28') "{bf:Intercept}" _c  
di _col(`=`dec2'+43') "{bf:Standard}" _c  

if "`cfastand'" == "" {
	di _col(`=`dec2'+57') "{bf:Error}" _c 
	di _col(`=`dec2'+66') "{bf:Variance of}"
	di _col(`dec2') "{bf:loading}" _c 
	di _col(`=`dec2'+14') "{bf:error}" _c
	di _col(`=`dec2'+43') "{bf:error}" _c
	di _col(`=`dec2'+55') "{bf:variance}" _c
	di _col(`=`dec2'+67') "{bf:dimension}"
	local h = `dec2'+76
}
else {
	di _col(`=`dec2'+57') "{bf:Error}" 
	di _col(`dec2') "{bf:loading}" _c 
	di _col(`=`dec2'+14') "{bf:error}" _c
	di _col(`=`dec2'+44') "{bf:error}" _c
	di _col(`=`dec2'+57') "{bf:variance}" 
	local h = `dec2'+62
} 

di "{hline `h'}"

local i = 1
local y = 1
foreach x in `partition' {
	if `i' == 1 local s = `x'
	else local s = `s' +`x'
	
	forvalues z = `y'/`s' {
		tokenize `sc'
		di "{bf:`var`z''}"_c
		di _col(`dec') "{bf:``i''}" _c
		local t = a[`z',1]
		local t : di %7.2f `t'
		di _col(`dec2') "{text:`t'}" _c
		
		local t = sef[`z',1]
		local t : di %8.2f `t'
		di _col(`=`dec2'+14') "{text:`t'}" _c
			
		local t = a2[`z',1]
		local t : di %9.2f `t'
		di _col(`=`dec2'+28') "{text:`t'}" _c
		
		local t = sei[`z',1]
		local t : di %9.2f `t'
		di _col(`=`dec2'+42') "{text:`t'}" _c
		
		local t = a3[`z',1]
		local t : di %11.2f `t'
				
		if "`cfastand'" == "" & `z' == `y'{
			di _col(`=`dec2'+52') "{text:`t'}" _c
			local t = var[`i',1]
			local t : di %11.2f `t'
			di _col(`=`dec2'+66') "{text:`t'}"
		}
		else di _col(`=`dec2'+52') "{text:`t'}" 
	}
	di
	local `i++' 
	local y = `s'+1	
}

qui estat gof, stats(all)


if "`cfasb'" != "" | "`vce'"=="sbentler"{
	local chi2 = r(chi2sb_ms)
	local p = r(psb_ms)
	local ddl = r(df_ms)
	local ratio = `chi2'/`ddl'
	local rmsea = r(rmsea_sb)
	*local lb = r(lb90_rmsea)
	*local ub = r(ub90_rmsea)
	local nfi = 1-(r(chi2sb_ms)/r(chi2sb_bs))
	local rni = 1-(r(chi2sb_ms)-r(df_ms))/(r(chi2sb_bs)-r(df_bs))
	local cfi = r(cfi_sb)
	local ifi = (r(chi2sb_bs)-r(chi2sb_ms))/(r(chi2sb_bs)-r(df_ms))
	local mci = exp(-0.5*((r(chi2sb_ms)-r(df_ms))/(e(N)-1)))
	local srmr = r(srmr)
}

else {
	local chi2 = r(chi2_ms)
	local p = r(p_ms)
	local ddl = r(df_ms)
	local ratio = `chi2'/`ddl'
	local rmsea = r(rmsea)
	local lb = r(lb90_rmsea)
	local ub = r(ub90_rmsea)
	local nfi = 1-(r(chi2_ms)/r(chi2_bs))
	local rni = 1-(r(chi2_ms)-r(df_ms))/(r(chi2_bs)-r(df_bs))
	local cfi = r(cfi)
	local ifi = (r(chi2_bs)-r(chi2_ms))/(r(chi2_bs)-r(df_ms))
	local mci = exp(-0.5*((r(chi2_ms)-r(df_ms))/(e(N)-1)))
	local srmr = r(srmr)
}

if "`cfanocovdim'" == "" {
	di 
	di "Covariances between dimensions:"
	mat li c, nodotz noheader format(%4.2f)
}

di
if "`cfasb'" != "" | "`vce'"=="sbentler" {
	di "{bf:Goodness of fit (with Satorra-Bentler correction):}"
}
else {
	di "{bf:Goodness of fit:}"
}
di



if "${html}" != "" {

di as result _col(4) "chi2" _c
di as result _col(20) "df" _c
di as result _col(28) "chi2/df" _c
di as result _col(42) "RMSEA [90% CI]" _c
di as result _col(64) "SRMR" _c
di as result _col(74) "NFI" _c
di as result _col(84) "RNI" 


local t : di %7.2f `chi2'
di "{text:`t'}" _c
local t : di %3.0f `ddl'
di _col(20) "{text:`t'}" _c
local t : di %7.1f `ratio'
di _col(29) "{text:`t'}" _c
local t : di %5.3f `rmsea'
local l : di %5.3f `lb'
local u : di %5.3f `ub'
di _col(40) "{text:`t' [`l' ; `u']}" _c
local t : di %5.3f `srmr'
di _col(63) "{text:`t'}" _c
local t : di %5.3f `nfi'
di _col(72) "{text:`t'}" _c
local t : di %5.3f `rni'
di _col(82) "{text:`t'}" 

local p : di %5.3f `p'
di "{text:(p-value = `p')}"
di as result
di as result _col(4) "CFI" _c 
di as result _col(15) "IFI" _c
di as result _col(26) "MCI"
local t : di %5.3f `cfi'
di _col(4) "{text:`t'}" _c
local t : di %5.3f `ifi'
di _col(15) "{text:`t'}" _c
local t : di %5.3f `mci'
di _col(26) "{text:`t'}" 
di as result
}
else {
di as result _col(4) "chi2" _c
di as result _col(20) "df" _c
di as result _col(28) "chi2/df" _c
di as result _col(42) "RMSEA [90% CI]" _c
di as result _col(64) "SRMR" _c
di as result _col(74) "NFI" _c
di as result _col(84) "RNI" _c
di as result _col(94) "CFI" _c 
di as result _col(104) "IFI" _c
di as result _col(114) "MCI"

local t : di %7.2f `chi2'
di "{text:`t'}" _c
local t : di %3.0f `ddl'
di _col(20) "{text:`t'}" _c
local t : di %7.1f `ratio'
di _col(29) "{text:`t'}" _c
local t : di %5.3f `rmsea'
local l : di %5.3f `lb'
local u : di %5.3f `ub'
di _col(40) "{text:`t' [`l' ; `u']}" _c
local t : di %5.3f `srmr'
di _col(63) "{text:`t'}" _c
local t : di %5.3f `nfi'
di _col(72) "{text:`t'}" _c
local t : di %5.3f `rni'
di _col(82) "{text:`t'}" _c
local t : di %5.3f `cfi'
di _col(92) "{text:`t'}" _c
local t : di %5.3f `ifi'
di _col(102) "{text:`t'}" _c
local t : di %5.3f `mci'
di _col(112) "{text:`t'}" 
local p : di %5.3f `p'
di "{text:(p-value = `p')}"
di as result

}
end


/* repet */

capture program drop repet
program repet,rclass
syntax varlist, PARTition(numlist integer >0) [t2(varlist) KAPpa ICKAPpa(integer 0)]
preserve

local nbvars : word count `varlist'

if `ickappa' <= 0 {
	local ickappa = ""
}

local C = 0
foreach z in `partition' {
	local C = `C' + `z'
}
	
local P:word count `partition'

if "$scores2" != "" {
	local t:word count $scores2' 
	if `P' != `t' {
		di in red "The number of score names given in scores2() is different from the number of scores defined"
		exit 119
	}
}

if "`t2'" != "" { 

	local i = 1
	foreach s in $scorename {
		local s`i' = abbrev("`s'",10)
		local sc `sc' `s`i''
		local `++i'
	}

	local i = 1
	foreach v in `varlist' {
		local var`i' = abbrev("`v'",10)
		local `++i'
	}

	local maxit = 1
	forvalues i=1/`nbvars' {
		local len = length("`var`i''")
		if `len' > `maxit' local maxit = `len'
	}

	local decit = `maxit' + 4
	local colit = `decit'

	di as result "{hline 105}"
	di as result "{bf:Reproducibility}"
	di as result "{hline 105}"
	di

	if "$scores2" == "" {
		foreach sco in $scorename {
				*local t = "`sco'bis"
				tempname s
				local scorename2 `scorename2' `s'
		}
		
		qui calcscore `t2', scorename(`scorename2') partition(`partition') compscore(${compscore}) categories($categories)
		
	}
	
	else {
		foreach sco in $scores2 {
			local scorename2 `scorename2' `sco'
		}
	}
	
	local i = 1
	foreach var in `varlist' {
		tokenize `t2'
		qui kap `var' ``i''
		local k`i' = r(kappa)
		if "`ickappa'" != "" {
			qui kapci `var' ``i'', reps(`ickappa')
			local lbk`i' = r(lb_bc)
			local ubk`i' = r(ub_bc)
		}
		local `++i'
	}

	local i = 1
	foreach s in $scorename {
		tokenize `scorename2'
		tempname score id temps
		qui gen `id' = _n
		qui gen `score'_1 = `s'
		qui gen `score'_2 = ``i'' if ``i''!=.
		qui reshape long `score'_, i(`id') j(`temps')
		qui icc `score'_ `id'
		local n`i' = r(N_target)
		local icc`i' = r(icc_i)
		local lb`i' = r(icc_i_lb)
		local ub`i' = r(icc_i_ub)
		qui sort `id'
		qui duplicates drop `id', force
		local `++i'
	}

	tokenize `sc'
	local max = length("dimension")

	forvalues j=1/`P' {
		local len`j' = length("`s`j''")
		if `len`j'' > `max' local max = `len`j''
	}

	local dec = `max' + 5

	local i = 1
	local j = 1
	local y = 1
	di "{bf:Dimension}" _c
	di _col(`=`dec'+2') "{bf:n}" _c
	local col = `dec'+6
	di _col(`col') "{bf:Item}" _c
	local col = `col'+`decit'

	if "`kappa'" != "" {
		di _col(`col') "{bf:Kappa}" _c
		local col = `col'+10
		if "`ickappa'" != "" {
			di _col(`col') "{bf:95% CI for Kappa}" _c
			local col = `col'+20	
		}
		
	}

	di _col(`=`col'+2') "{bf:ICC}" _c
	local col = `col'+9
	di _col(`col') "{bf:95% CI for ICC}"

	local zz = 0
	foreach var in `varlist' {
		qui levelsof `var', local(levels)
		local z : word count `levels'
		if `z' > 2 local zz = 1
	}

	if "`kappa'" != "" & "`ickappa'" != "" & `zz' == 1 {
		local col = `dec'+`decit'+16
		di _col(`col') "{bf:(bootstrapped)}"
	}


	if "`ickappa'" != "" local h = `dec'+6+`decit'+10+8+21+12+1
	else if "`kappa'" != "" local h = `dec'+6+`decit'+10+8+21+12-20
	else local h = `dec'+6+`decit'+10+8+21+12-29
	di "{hline `h'}"

	local i = 1
	foreach p in `partition' {
		tokenize `sc'
		di "{bf:``i''}" _c
		di _col(`dec') "{text:`n`i''}" _c
		if `j' == 1 local s = `p'
		else local s = `s' +`p'
		local col = `dec'+6
		di _col(`col') "{text:`var`y''}" _c 
		
		if "`kappa'" != "" {
			local k : di %5.2f `k`y''
			local col = `col'+`decit'
			di _col(`col') "{text:`k'}" _c
			if "`ickappa'" != "" {
				local lbk : di %5.2f `lbk`i''
				local ubk : di %5.2f `ubk`i''
				local col = `col'+11
				di _col(`col') "{text:[`lbk' ; `ubk']}" _c
				local col = `decit'+50
			}
			
		else local col = `decit'+30	
		}
		else local col = `decit'+20
			
		local icc : di %5.2f `icc`i''
		di _col(`col') "{text:`icc'}" _c
		local lb : di %5.2f `lb`i''
		local ub : di %5.2f `ub`i''
		local col = `col'+8
		di _col(`col')"{text:[`lb' ; `ub']}"
		local w = `y'+1
		
		forvalues z = `w'/`s' {
			local col = `dec'+6
			di _col(`col') "{text:`var`z''}" _c
			if "`kappa'" != "" {
				local k : di %5.2f `k`z''
				local col = `col'+`decit'
				di _col(`col') "{text:`k'}" _c
				if "`ickappa'" != "" {
					local lbk : di %5.2f `lbk`z''
					local ubk : di %5.2f `ubk`z''
					local col = `col'+11
					di _col(`col')"{text:[`lbk' ; `ubk']}"
				}
				else di
				
			}
			else di
		}
		local `i++' 
		local `j++' 
		local y = `s'+1
		di
	}
}

else {
	local i = 1
	foreach s in $scorename {
		tokenize $scores2
		tempname score id temps
		qui gen `id' = _n
		qui gen `score'_1 = `s'
		qui gen `score'_2 = ``i'' if ``i''!=.
		qui reshape long `score'_, i(`id') j(`temps')
		qui icc `score'_ `id'
		local n`i' = r(N_target)
		local icc`i' = r(icc_i)
		local lb`i' = r(icc_i_lb)
		local ub`i' = r(icc_i_ub)
		qui sort `id'
		qui duplicates drop `id', force
		local `++i'
	}

	tokenize $scorename
	local max = length("dimension")

	local h = 1
	foreach s in $scorename {
		local s`h' = abbrev("`s'",10)
		local sc `sc' `s`h''
		local `++h'
	}
	
	forvalues j=1/`P' {
		local len`j' = length("`s`j''")
		if `len`j'' > `max' local max = `len`j''
	}

	local dec = `max' + 5

	local i = 1
	local j = 1
	local y = 1
	
	di as result "{hline 105}"
	di as result "{bf:Reproducibility}"
	di as result "{hline 105}"
	di
	
	di "{bf:Dimension}" _c
	local col = `dec'
	di _col(`col') "{bf:n}" _c
	

	di _col(`=`col'+6') "{bf:ICC}" _c
	local col = `col'+14
	di _col(`col') "{bf:95% CI for ICC}"

	di "{hline 50}"
	
	local i = 1
	foreach p in `partition' {
		tokenize $scorename
		di "{bf:``i''}" _c
		local n : di % 4.0f `n`i''
		di _col(`=`dec'-3') "{text:`n'}" _c
		if `j' == 1 local s = `p'
		else local s = `s' +`p'
		local col = `dec'+4
		
		local icc : di %5.2f `icc`i''
		di _col(`col') "{text:`icc'}" _c
		local lb : di %5.2f `lb`i''
		local ub : di %5.2f `ub`i''
		local col = `col'+9
		di _col(`col')"{text:[`lb' ; `ub']}"
		local w = `y'+1
		
		local `i++' 
	}
}

end


/* kgv */

capture program drop kgv
program kgv,rclass
syntax varlist, categ(varlist) [KGVBoxplots KGVGroupboxplots]
	
foreach c in `categ' {
	tempname j
	capture encode `c', generate(`j')
	capture confirm variable `j'
	if _rc local j = "`c'"
	local categ2 `categ2' `j' 
}	

local i = 1
local j = 1	
local k = 0
local max = 0
local a : word count `categ'
local nb:word count `varlist'

di as result "{hline 105}"
di "{bf:Known-groups validity}"
di as result "{hline 105}"
di
	
foreach sco in `varlist' {
	foreach cat in `categ2' {
		local nblev = 0
		local maxlen`j' = 0
		
		qui anova `sco' `cat'
		local p`i'_`j' = Ftail(e(df_m), e(df_r), e(F))
		qui kwallis `sco', by(`cat')
		local p2`i'_`j' = chi2tail(r(df), r(chi2))
		
		
		/*local inf30 = 0
		qui tab `cat' if `sco'!=., matcell(x)
		local r = r(r)
		forvalues n = 1/`r' {
			if x[`n',1]<48 {
				local `++inf30'
			}
		}
		if `inf30' > 0 {
			//di in red "kw"
			kwallis `sco', by(`cat')
			local p2`i'_`j' = chi2tail(r(df), r(chi2))
			anova `sco' `cat'
			local p`i'_`j' = Ftail(e(df_m), e(df_r), e(F))
			
		}
		else {
			//di in red "aov"
			anova `sco' `cat'
			local p`i'_`j' = Ftail(e(df_m), e(df_r), e(F))
		}*/
		
				
		qui levelsof `cat', local(levels) 
		local lbe : value label `cat'
			
		foreach l of local levels {
			qui count if `sco' !=. & `cat' == `l'
			local `++k'
			local eff`i'_`j'_`k' = r(N)
			
			if "`lbe'" != "" {
				local ll`j'_`k' : label `lbe' `l'
				local len = length("`ll`j'_`k''")
				if `len' > 10 {
					local c = substr("`ll`j'_`k''",1,9)
					local d = substr("`ll`j'_`k''",-1,1)
					local ll`j'_`k' "`c'" "~" "`d'" 
				}
				local w = length("`ll`j'_`k''")
				if `w' > `maxlen`j'' local maxlen`j' = `w'
			}
			else {
				local ll`j'_`k' = `l'
				local len = length("`ll`j'_`k''")
				if `len' > 10 {
					local c = substr("`ll`j'_`k''",1,9)
					local d = substr("`ll`j'_`k''",-1,1)
					local ll`j'_`k' "`c'" "~" "`d'" 
				}
				local w = length("`ll`j'_`k''")
				if `w' > `maxlen`j'' local maxlen`j' = `w'
			}
			qui su `sco' if `cat' == `l'
			local m`i'_`j'_`k' = r(mean)
			local s`i'_`j'_`k' = r(sd)
			local nblev = `nblev' + 1
		}
		if `nblev' > `max' local max = `nblev'
		local `++j'
		local k = 0
	}
	local `++i'
	local j = 1
}

local i = 1
foreach s in `varlist' {
	local s`i' = abbrev("`s'",7)
	local sc `sc' `s`i''
	local `++i'
}

local maxs = 0
forvalues j=1/`nb' {
	local len`j' = length("`s`j''")
	if `len`j'' > `maxs' local maxs = `len`j''
}

local i = 1
local k = 0
local j = 2

foreach cat in `categ'{
	local `++k'
	tokenize `categ'
	local c`k' = "``i'' ``j''"
	local i = `i' + 2 
	local j = `j' + 2 
}


local d = 1
local f = 2
forvalues h = 1/`a' {
	if `f' > `a' local f = `f'-1
	local j = 1
	local col =  `maxs'+6
	foreach cat in `c`h'' {
		di _col(`col') "{bf:`cat'}" _c
		local col = `col' + `maxlen`j'' + 5 + 40
		local `++j'
	}
	di

	local j = `d'
	local col = `maxs'+6
	foreach cat in `c`h'' {
		di _col(`=`col'+`maxlen`j''+5') "{bf:       mean    }" _c
		di "{bf:     sd    }" _c
		di "{bf:p-value}" _c
		//di "{bf:p-value (Kruskal-Wallis)}" _c
		    
		local col = `col' + `maxlen`j'' + 5 + 40
		local `++j'
	}
	
	local j = `d'
	local col = `maxs'+6

	di
	di
	local i = 1
	local col = `maxs'+6

	forvalues g = 1/`nb' {
		
		di "{bf:`s`g''}" _c
		forvalues k = 1/`max' {
			forvalues j = `d'/`f' {
			
				di _col(`col') "{bf:`ll`j'_`k''} " _c
				if "`eff`i'_`j'_`k''" != "" di as text "(n=`eff`i'_`j'_`k'')" _c
				local m : di %6.2f `m`i'_`j'_`k''
				di _col(`=`col'+`maxlen`j''+10') "{text:`m'}  " _c
					
				local s : di %8.2f `s`i'_`j'_`k''
				di "{text: `s'}  " _c
					
				if `k' == 1 {
					local p : di %8.3f `p`i'_`j''
					local p2 : di %4.3f `p2`i'_`j''
					di _col(`=`col'+31') "{text:`p'}  " _c
					di _col(`=`col'+35') "{text:(KW: `p2')}  " _c
				}
				local col = `col' + `maxlen`j'' + 5 + 40
			}
			di
			local col = `maxs'+6
		
		}
		di 
		
	local `++i'
	
	}
	local d = `d'+2
	local f = `f'+2
	if `d' > `a' continue, break
	di
}

if "`kgvboxplots'" != "" {
	local html = "${html}"
	if "`html'" != "" {
		di "</pre>"
		di "<div style=" _char(34) "width:750px;" _char(34) ">"
		if "`kgvgroupboxplots'" != "" {
			local cc = 1
			foreach c in `categ' {
				local k = 1
				foreach s in `varlist' {
					local pp = round(`p`k'_`cc'',0.001)
					//graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c'") nodraw
						
						
					qui local saving "saving(`c(tmpdir)'/`html'_kgv`s',replace) nodraw"
					qui graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c' (p=`pp')") `saving'  
					qui graph use `c(tmpdir)'/`html'_kgv`s'.gph
					qui graph export `c(tmpdir)'/`html'_kgv`s'.png, replace
						
						
					local g `g' `s'_`c'
					local k = `k'+1
				}
				local cc = `cc'+1
			}
				
			qui local saving "saving(`c(tmpdir)'/`html'_kgv,replace) nodraw"
			qui gr combine `g', name(kgv,replace) `saving'
			qui graph use `c(tmpdir)'/`html'_kgv.gph
			qui graph export `c(tmpdir)'/`html'_kgv.png, replace
			//di "<img src=" _char(34) "/data/`html'_kgv.png" _char(34) 
			//di "style="_char(34) "margin-bottom:10px;margin-right:22px" _char(34)" class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "kgv" _char(34) " title= " _char(34) "kgv - click to enlarge" _char(34) " width=" _char(34) "225" _char(34) " height=" _char(34) "150" _char(34) ">"
							
		}
		else {
			local cc = 1
			foreach c in `categ' {
				local k = 1
				foreach s in `varlist' {
					local pp = round(`p`k'_`cc'',0.001)
					//graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c'")
					
					qui local saving "saving(`c(tmpdir)'/`html'_kgv`s',replace) nodraw"
					qui graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c' (p=`pp')") `saving'  
					qui graph use `c(tmpdir)'/`html'_kgv`s'.gph
					qui graph export `c(tmpdir)'/`html'_kgv`s'.png, replace
					//di "<img src=" _char(34) "/data/`html'_kgv`s'.png" _char(34) 
					//di "style="_char(34) "margin-bottom:10px;margin-right:22px" _char(34)" class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "kgv" _char(34) " title= " _char(34) "kgv - click to enlarge" _char(34) " width=" _char(34) "225" _char(34) " height=" _char(34) "150" _char(34) ">"
									
					local g `g' `s'_`c' 
					local k = `k'+1
				}
				local cc = `cc'+1
			}
		}	
		di "</div>"
		di "<pre>"
	
	}
	else {
		if "`kgvgroupboxplots'" != "" {
			local cc = 1
			foreach c in `categ' {
				local k = 1
				foreach s in `varlist' {
					local pp = round(`p`k'_`cc'',0.001)
					graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c' (p=`pp')") nodraw
					local g `g' `s'_`c' 
					local k = `k'+1
				}
				local cc = `cc'+1
			}
			gr combine `g', name(Known_groups_validity,replace)
			if ("$filessave"!="") qui graph export ${dirsave}/Known_groups_validity.png, replace

		}
		else {
			local cc = 1
			foreach c in `categ' {
				local k = 1
				foreach s in `varlist' {
					local pp = round(`p`k'_`cc'',0.001)
					graph box `s', over(`c') name("`s'_`c'",replace) b1title("`c' (p=`pp')")
					if ("$filessave"!="") qui graph export ${dirsave}/Known_groups_validity_`c'_`s'.png, replace
					local g `g' `s'_`c' 
					local k = `k'+1
				}
				local cc = `cc'+1
			}
		}
	}
}

end


/* conc */

capture program drop conc
program conc,rclass
syntax varlist, comp(varlist) [tconc(real 0.4)]

di as result "{hline 105}"
di "{bf:Concurrent validity}"
di as result "{hline 105}"
di

local n : word count `varlist'
local p : word count `comp'

matrix m = J(`n',`p',.)
matrix rownames m = `varlist'
matrix colnames m = `comp'
local r = 1

foreach i in `varlist' {
	local c = 1
	foreach j in `comp' {
		qui corr `i' `j'
		mat e = r(C)
		local f = e[2,1]
		mat m[`r',`c'] = `f' 
		local `++c'
	}
	local `++r'
}

tokenize `varlist'
local maxv = length("`1'")
forvalues i=1/`n' {
	local lenv = length("``i''")
	if `lenv' > `maxv' local maxv = `lenv'
}

local decv = `maxv'+6

tokenize `comp'
local maxc = length("`1'")
forvalues i=1/`p' {
	local lenc = length("``i''")
	if `lenc' > `maxc' local maxc = `lenc'
}

local decc = `maxc'+4

local col = `decv'
foreach c in `comp' {
	di as result _col(`col') "`c'" _c
	local col = `col'+`decc'
}
di

local i = 1 
foreach x in `varlist' {
	local var`i' = "`x'"
	local `++i'
}

forvalues i=1/`n' {
	di as result "`var`i''" _c
	local col = `decv'
	forvalues j=1/`p' {
		local t = m[`i',`j']
		if `t' > `tconc' | `t' < -`tconc' {
			di as result _col(`=`col'-1') %5.2f `t' _c
		}
		else di as text _col(`=`col'-1') %5.2f `t' _c
		local col = `col'+`decc'
	}
	di
}

capture restore, not
end

