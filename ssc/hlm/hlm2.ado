*! version 2.0, sean f. reardon, 20dec2005

/*----------------------------------------------------
  this program writes an hlm2 command file. 
  it requires stata 8.2 or higher, and hlm v.6
----------------------------------------------------*/

capture program drop hlm2
program define hlm2
version 8.2
	syntax anything(name=model id="model expression") , ///
		CMDfile(string) 		///
		[ 				///
		MDMfile(string) 		///
		OUTfile(string) 		/// 
		RUN 				/// 
		REPLACE 			///
		LINear 			/// 
		BERnouli 			/// 
		POIsson 			/// 
		BINomial 			/// 
		MULtinomial 		/// 
		ORDinal 			/// 
		NCat(integer 0) 		/// 
		EVar(varname) 		///
		FML 				///
		PRompt 			///
		STop 				/// 
		OD 				/// 
		LAPlace 			/// 
		L6 				/// 
		EML5 				///
		LNum(integer 50) 		/// 
		MACIt(integer 100) 	/// 
		MICIt(integer 14) 	/// 
		MACStop(real 0.0001) 	/// 
		MICStop(real 0.000001) 	///
		WGT1(varname) 		/// 
		WGT2(varname) 		/// 
		PWGT(varname) 		/// 
		FSIG(real -1) 		/// 
		TEst(string) 		/// 
		DEViance(numlist min=2 max=2) /// 
		STore(string) 		/// 
		ROBUST 			///
		noEQ 				///
		LOng 				///
		RES1 				/// 
		RV1(varlist) 		/// 
		RES2 				/// 
		RV2(varlist) 		/// 
		TItle(string) 		/// 
		GRaph(string) 		///
		]

*-----------------------------------------
*check for syntax and specification errors
*-----------------------------------------
*-----------------------------------------
*check for syntax and specification errors
*-----------------------------------------
if "$mdmfile" == "" {
	di in re "mdm file not specified: use hlm mdmset command"
	error 601
}

if "`prompt'" ~= "" & "`stop'" ~= "" {
	di in re "cannot specify both prompt and stop iteration options"
	error 197
}
else if "`prompt'`stop'" == "" local itopt ",y"
else if "`prompt'`stop'" == "prompt" local itopt ""
else if "`prompt'`stop'" == "stop" local itopt ",n"

local nlnum: word count `linear' `bernouli' `poisson' `binomial' `multinomial' `ordinal'
if `nlnum' > 1 {
	di in re "only one model type allowed"
	error 197
}
else if `nlnum' == 0 local linear = "linear"
local modeltype "`linear'`bernouli'`poisson'`binomial'`multinomial'`ordinal'"

if "`modeltype'" ~= "`bernouli'" & "`modeltype'" ~= "`poisson'" ///
		& "`laplace'" ~= "" {
	di in re "laplace option invalid with `modeltype' model"
	error 197
}
if "`modeltype'" == "`poisson'" & "`laplace'" ~= "" & "`evar'" ~= "" {
	di in re "laplace option invalid with variable exposure poisson model"
	error 197
}
if "`modeltype'" == "`bernouli'" & "`laplace'"~="" & "`od'"~="" {
	di in re "laplace option invalid with overdispersion"
	error 197
}
if "`modeltype'" ~= "`linear'`binomial'`multinomial'`ordinal'" ///
		& "`l6'"~="" & "`od'"~="" {
	di in re "l6 option invalid with overdispersion"
	error 197
}
if "`modeltype'" == "`linear'`multinomial'`ordinal'" & "`od'" ~= "" {
	di in re "overdispersion option invalid with `modeltype' model"
	error 197
}

if "`linear'" == "linear" local linear "n"
local nonlin "`linear'`bernouli'`poisson'`binomial'`multinomial'`ordinal'"
if "`nonlin'" == "bernouli" local nonlin = "binomial"
if "`l6'" ~= "" local lopt = "y,`lnum'"
if "`l6'" == "" local lopt = "n,0"
if "`laplace'" ~= "" local emlopt = "y,`lnum'"
if "`laplace'" == "" local emlopt = "n,0"
if "`eml5'" ~= "" local eml5opt = "y,`lnum'"
if "`eml5'" == "" local eml5opt = "n,0"
if "`multinomial'`ordinal'" ~= "" & (`ncat' > 9 | `ncat' < 3) {
	di in re "number of categories in `multinomial'`ordinal' model must be between 3 and 9"
	error 197
}
else if "`multinomial'`ordinal'" ~= "" local nlopt = ",`ncat'"
else if "`binomial'" ~= "" local nlopt = ",`evar'"
else if "`poisson'" ~= "" & "`evar'" ~= "" local nlopt = ",`evar'"
else if "`poisson'" ~= "" & "`evar'" == "" local nlopt = ""
else if "`linear'`bernouli'" ~= "" local nlopt = ""

if `fsig' == -1 local fsig ""
if "`fsig'" ~= "" & "`fsig'" ~= "1" & "`nonlin'" ~= "n" {
	di in re "Cannot fix sigma squared in non-linear model w/o overdispersion"
	error 197
}

if "`fml'" == "" local mlopt = "n"
else if "`fml'" ~= "" local mlopt = "y"

if "`wgt1'" == "" local wgt1 "none"
else if "`wgt1'" ~= "" {
	unab wgt1: `wgt1'
	local wgt1 "`wgt1'"
}
if "`wgt2'" == "" local wgt2 "none"
else if "`wgt2'" ~= "" {
	unab wgt2: `wgt2'
	local wgt2 "`wgt2'"
}
if "`pwgt'" == "" local pwgt "none"
else if "`pwgt'" ~= "" {
	unab pwgt: `pwgt'
	local pwgt "`pwgt'"
}	

confirm new var rand
confirm new var random

local filename = "`cmdfile'"
gettoken filename ext: filename, p(".")
if "`ext'" ~= ".hlm" & "`ext'" ~= "" {
	di in re ".cmd file must be an .hlm file: file extension `ext' ignored"
}
if "`outfile'" == "" local outfile "`filename'"
else {
	gettoken outfile ext: outfile, p(".")
	if "`ext'" ~= ".txt" & "`ext'" ~= "" {
		di in re "output file must be a .txt file: file extension `ext' ignored"
	}
}

if "`res1'" ~= "" {
	loc r1var "`rv1'"
	local res1file "`filename'_res1"
	if "`r1var'" ~= "" {
		unab r1var: `r1var'
		local ur1var=upper("`r1var'")
		local r1var `ur1var' 
		local r1var: subinstr local r1var " " ",", all
		local r1var "/`r1var'"
	}
	local res1 "y`r1var'"
}
else local res1 "n"

if "`res2'" ~= "" {
	loc r2var "`rv2'"
	local res2file "`filename'_res2"
	if "`r2var'" ~= "" {
		unab r2var: `r2var'
		local ur2var=upper("`r2var'")
		local r2var `ur2var' 
		local r2var: subinstr local r2var " " ",", all
		local r2var "/`r2var'"
	}
	local res2 "y`r2var'"
}
else local res2 "n"

if "`long'" == "" local long "n"
else local long "y"

if "`graph'" ~= "" {
	gettoken graph ext: graph, p(".")
	if "`ext'" ~= ".geq" & "`ext'" ~= "" {
		di in re "graph file must be a .geq file: file extension `geq' ignored"
	}
	local graph "`graph'.geq"
}

loc pvc "y"

if "`store'" != "" loc store "store(`store')"

if "`deviance'" ~= "" {
	gettoken devstat df: deviance
	local df: subinstr local df " " "", all
	capture confirm integer `df'
	if ~_rc | `df' < 1 {
		di in re "df in deviance test must be positive integer"
		error 197
	}
} 

*---------------------
*parse model equations
*---------------------
preserve
use "$varfile", clear
gettoken out model: model, bind
unab out: `out'
local l1eq = "`out'="
local l1eqcoef = "`out' = "
local l1var = 0
local vn = 1
local model `model'

while "`model'" ~= "" {
	gettoken l1mod`l1var' model: model, bind
	gettoken l1var`l1var' l1mod`l1var': l1mod`l1var', parse("()")

	local l1var`l1var': subinstr local l1var`l1var' " " "", all
	local cent: piece 1 2 of "C`l1var`l1var''"
	if ("`l1var`l1var''"=="#int" | "`l1var`l1var''"=="#rand" ///
		| "`l1var`l1var''"=="%int" | "`l1var`l1var''"=="%rand") {
		di in re "invalid centering: `l1var`l1var''"
		error 197
	}	
	else if "`cent'"=="C#" | "`cent'"=="C%" {
		local cent: subinstr local cent "C" ""
		local l1var`l1var': subinstr local l1var`l1var' "`cent'" ""
	}
	else local cent ""
	local vcent ""
	if "`cent'" == "#" local vcent ",1"
	else if "`cent'" == "%" local vcent ",2"

	if "`l1var`l1var''" == "int" local l1var`l1var' = "intrcpt1"
	else if "`l1var`l1var''" == "rand" local l1var`l1var' = "random"
	else {
		unab l1var`l1var': `l1var`l1var''
		local w=wordcount("`l1var`l1var''")
		if `w'>1 {
			local l1varw = ""
			gettoken l1var`l1var' l1varx: l1var`l1var'
			tokenize `l1varx'
			local w = `w'-1
			foreach X of num 1/`w' {
				local l1varw "`l1varw' `cent'``X''`l1mod`l1var''"
			}
			if "`model'" ~= "" local model "`l1varw' `model'"
			else local model "`l1varw'"
		}
	}
	if `l1var'==0 {
		local l1eq  "`l1eq'`l1var`l1var''`vcent'"
	}
	else {
		local l1eq  "`l1eq'+`l1var`l1var''`vcent'"
	}

*write level 1 equation for display
*----------------------------------
	if `l1var'==0 & "`l1var`l1var''" == "intrcpt1" local l1eqcoef  "`l1eqcoef'B0 "
	else if `l1var'==0 & "`l1var`l1var''"~="intrcpt1" ///
		local l1eqcoef  "`l1eqcoef'B0*(`l1var`l1var'') "
	else if "`l1var`l1var''" == "random" local l1eqcoef  "`l1eqcoef'+ R"
	else local l1eqcoef  "`l1eqcoef'+ B`l1var'*(`l1var`l1var'') "

*parse level 2 equations
*-----------------------
	gettoken l1mod`l1var': l1mod`l1var', parse("()") match(m)
	if "`l1mod`l1var''" == "" & "`l1var`l1var''"~="random" local l1mod`l1var' = "int"
	tokenize `l1mod`l1var''
	local n = 1
	while "``n''" ~= "" {

		local `n': subinstr local `n' " " "", all
		local cent: piece 1 2 of "C``n''"
		if ("`cent'"=="C#" | "``n''"=="%int" | "``n''"=="%rand") {
			di in re "invalid centering: ``n''"
			error 197
		}	
		else if "`cent'"=="C%" {
			local cent "%"
			local `n': subinstr local `n' "%" ""
		}
		else local cent ""
		local vcent ""
		if "`cent'" == "%" local vcent ",2"

		if "``n''" == "int" {
			local `n' = "intrcpt2"
			if "`l1var`l1var''" == "intrcpt1" local var`vn' "int"
			else local var`vn' "`l1var`l1var''"
			local vn = `vn' + 1
		}
		else if "``n''" == "rand" {
			local `n' = "random"
		}
		else {
			unab `n': ``n''
			local l2list "``n''"
			while "`l2list'" ~= "" {
				gettoken var l2list: l2list
				if "`l1var`l1var''" == "intrcpt1" {
					local var`vn' "`var'"
				}
				else {
					local var`vn' "`var'*`l1var`l1var''"
				}
				local vn = `vn' + 1				
			}
			local `n':subinstr local `n' " " "`vcent'+", all
			local `n' "``n''`vcent'"
		}
		local n = `n'+1
	}
	if "`l1var`l1var''" ~= "random" {
		local l2eq`l1var'  "`l1var`l1var''=`1'"
		local n = 2
		while "``n''" ~= "" {
			local l2eq`l1var' "`l2eq`l1var''+``n''"
			local n = `n'+1
		}
		local l2eq`l1var'  "`l2eq`l1var''/"

*write level 2 equations for display
*-----------------------------------
		local l2eqcoef`l1var': subinstr local l2eq`l1var' ",2" "", all
		local l2eqcoef`l1var': subinstr local l2eqcoef`l1var' "+" " ", all
		local l2eqcoef`l1var': subinstr local l2eqcoef`l1var' "=" " ", all
		local l2eqcoef`l1var': subinstr local l2eqcoef`l1var' "/" "", all
		tokenize `l2eqcoef`l1var''
		if "`2'" == "intrcpt2" local l2eqcoef`l1var' "B`l1var' = G`l1var'0 "
		else if "`2'" == "random" local l2eqcoef`l1var'  "B`l1var' = R`l1var'"
		else local l2eqcoef`l1var'  "B`l1var' = G`l1var'0*(`2') "
		local n = 3
		while "``n''" ~= "" {
			local m = `n'-2
			if "``n''" ~= "random" {
				local l2eqcoef`l1var'  "`l2eqcoef`l1var''+ G`l1var'`m'*(``n'') "
			}
			else local l2eqcoef`l1var'  "`l2eqcoef`l1var''+ R`l1var'"
			local n = `n'+1
		}
	}
	local l1var=`l1var'+1
}
restore


*---------------------------
*save variable list in order
*---------------------------
local nterms = `vn'-1
forv z=1/`nterms' {
	local varsinorder "`varsinorder' `var`z''"
}
global varsinorder: subinstr local varsinorder "*" "_X_", all 


*----------------
*parse test syntax
*---------------- 
if "`test'" ~= "" {
	global nterms = `nterms'
	local z=1 
	while "`var`z''" ~= "" {
		global var`z' "`var`z''"
		local z = `z' +1
	}
	hlmtest `test'
	local z=1 
	while `z' <= $nterms {
		macro drop var`z'
		local z = `z' +1
	}
	macro drop nterms
}

*----------------------
*display model equations
*----------------------
if "`eq'" == "" {
	di in ye "2-Level HLM Model Specified:"
	di in ye "----------------------------"
	local len1 : length local l1eqcoef
	if `len1' < 80 di in gr "`l1eqcoef'"
	else {
		local pieceeq1 : piece 1 75 of "`l1eqcoef'"
		di in gr "`pieceeq1'"
		local l1eqcoef : subinstr local l1eqcoef "`pieceeq1'" ""
		local wc : word count `l1eqcoef'
		while `wc' > 0 {
			local pieceeq1 : piece 1 73 of "`l1eqcoef'"
			di in gr "  `pieceeq1'"
			local l1eqcoef : subinstr local l1eqcoef "`pieceeq1'" ""
			local wc : word count  `l1eqcoef'
		}
	}
	di ""
	local l1var=0
	while "`l2eqcoef`l1var''" ~= "" {
		local len2 : length local l2eqcoef`l1var'
		if `len2' < 80 di in gr "`l2eqcoef`l1var''"
		else {
			local pieceeq2 : piece 1 75 of "`l2eqcoef`l1var''"
			di in gr "`pieceeq2'"
			local l2eqcoef`l1var' : subinstr local l2eqcoef`l1var' "`pieceeq2'" ""
			local wc : word count `l2eqcoef`l1var''
			while `wc' > 0 {
				local pieceeq2 : piece 1 73 of "`l2eqcoef`l1var''"
				di in gr "  `pieceeq2'"
				local l2eqcoef`l1var' : subinstr local l2eqcoef`l1var' "`pieceeq2'" ""
				local wc : word count  `l2eqcoef`l1var''
			}
		}
		local l1var=`l1var'+1
	}
}

/*--------------------------------------------
  open text file `filename'.hlm
  unless nocmd option specified; then give
  unique name to cmd file to be deleted later
--------------------------------------------*/

tempname cmd
capture file close `cmd' /*need to close the file if it exists already*/

if "`nocmd'"=="" quietly file open `cmd'  using "`filename'.hlm", write text `replace' 
else {
  	local r = 1
  	capture confirm file `filename'`r'.hlm
  	while _rc == 0 {
	  	local r = `r' + 1
  		capture confirm file `filename'`r'.hlm 
  	}
	quietly file open `cmd'  using "`filename'`r'.hlm", write text `replace'
}

  
/*--------------------------------------------
  write hlm2 command file;
    (for HLM version 6)
--------------------------------------------*/
        
file write `cmd' "#WHLM CMD FILE FOR $mdmfile" _newline 
file write `cmd' "nonlin:`nonlin'`nlopt'" _newline 
if "`nonlin'" == "n" {
	file write `cmd' "numit:`macit'`itopt'" _newline
	file write `cmd' "stopval:0.000001" _newline
}
else {
	file write `cmd' "microit:`micit'" _newline
	file write `cmd' "macroit:`macit'`itopt'" _newline
	file write `cmd' "stopmicro:`micstop'" _newline
	file write `cmd' "stopmacro:`macstop'" _newline
}
file write `cmd' "level1:`l1eq'" _newline

*need lines to write l2eqs
local r = 0
while "`l2eq`r''" ~= "" {
	file write `cmd' "level2:`l2eq`r''" _newline
	local r = `r' + 1
}
if "`od'" == "" & "`nonlin'" ~= "n" file write `cmd' "fixsigma2:1.000000" _newline
if "`fsig'" ~= "" & "`nonlin'" == "n" file write `cmd' "fixsigma2:`fsig'" _newline
file write `cmd' "fixtau:3" _newline
file write `cmd' "lev1ols:10" _newline
file write `cmd' "accel:5" _newline
if "`test'" ~= "" {
	local g=1
	while "${testcmd`g'c1}" ~= "" {
		local c=1
		while "${testcmd`g'c`c'}" ~= "" {
			file write `cmd' "${testcmd`g'c`c'}" _newline
			macro drop testcmd`g'c`c'
			local c = `c' + 1
		}
		local g = `g' + 1
  	}
}
if "`deviance'" ~= "" {
	file write `cmd' "deviance:`devstat'" _newline
	file write `cmd' "df:`df'" _newline
}
file write `cmd' "level1weight:`wgt1'" _newline
file write `cmd' "level2weight:`wgt2'" _newline
file write `cmd' "varianceknown:`pwgt'" _newline
file write `cmd' "level1deletion:none" _newline
file write `cmd' "resfiltype:stata" _newline
file write `cmd' "resfil1:`res1'" _newline
if "`res1'" ~= "n" file write `cmd' "resfil1name:`res1file'.dta" _newline
file write `cmd' "resfil2:`res2'" _newline
if "`res2'" ~= "n" file write `cmd' "resfil2name:`res2file'.dta" _newline
file write `cmd' "hypoth:n" _newline
file write `cmd' "homvar:n" _newline
file write `cmd' "constrain:n" _newline
file write `cmd' "heterol1var:n" _newline
if "`eml5'" ~= "" {
file write `cmd' "emlaplace5:`eml5opt'" _newline
}
if "`l6'" ~= "" {
file write `cmd' "laplace6:`lopt'" _newline
}
if "`laplace'" ~= "" {
	file write `cmd' "laplace:`emlopt'" _newline
}
if "`graph'" ~= "" {
	file write `cmd' "graphgammas:`graph'" _newline
}
file write `cmd' "printvariance-covariance:`pvc'" _newline
file write `cmd' "lvr:n" _newline
file write `cmd' "title:`title'" _newline
file write `cmd' "output:`outfile'.txt" _newline
file write `cmd' "fulloutput:`long'" _newline
file write `cmd' "mlf:`mlopt'" _newline

capture file close `cmd'

*-------------
*fit HLM model
*-------------
if "`run'" ~= "" {
	hlmrun `filename'.hlm, hlm2 mdm($mdmfile) noview `store' `robust'
	view `"`outfile'.txt"'
}

end 
