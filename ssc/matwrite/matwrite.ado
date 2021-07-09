*! matwrite version 0.90, 15/12/04, (c) Andrew Shephard

cap program define _matwrite, plugin using("matwrite.plugin")

program define matwrite

	version 8.2

	syntax [anything] using/ [if] [in] [,MATrix(namelist)] [,replace]

	local matrix   : list retokenize matrix
	local matrix   : list uniq matrix
	local anything : list retokenize anything
	
	if ("`matrix'"=="")   local matrix : all matrices
	
	qui de

	if (`r(k)'>0) {
		if ("`anything'"=="") unab anything: *
		}

	/* add file extension if needed */

	if substr("`using'",length("`using'")-3,4)~=".mat" {
		local using = "`using'" + ".mat"
		}

	local anything : subinstr local anything "[" " [ ", all
	local anything : subinstr local anything "]" " ] ", all

	local nVarList : list sizeof anything
	local ++nVarList

	local isMatrix = 0

	/* create lists to be passed to plugin */

	forval n = 1/`nVarList' {

		tokenize `anything'

		if ("`1'"=="[") {

			if (`isMatrix'==1) error 198

			if (index("`matNameList' `newVarList' ","`lastVar' ")>0) {
				di as error "a matrix has already been defined with name `lastVar'"
				exit 110
				}

			local startSize : list sizeof matVarList
			local matNameListOld `matNameList'
			local matNameList `"`matNameList' `lastVar'"'
			local isMatrix = 1
			local thisMatrix `lastVar'
			local lastVar ""

			}

		else if ("`1'"=="]") {

			if "`lastVar'"~="" {
				unab lastVar : `lastVar'
				if (index(" `matNameList' "," `lastVar' ")>0) & (`isMatrix'==0) {
					di as error "a matrix has already been defined with name `lastVar'"
					exit 110
					}
				
				foreach var of varlist `lastVar' {
					local tempType : type `var'
					if (substr("`tempType'",1,3)=="str") {
						di as text "warning: ignoring string variable `var'"
						local lastVar : subinstr local lastVar "`var'" ""
						}
					}

				local matVarList `"`matVarList' `lastVar'"'
				local lastVar ""

				}

			local endSize : list sizeof matVarList
			local size = `endSize' - `startSize'
			local matNameList `"`matNameList' `size'"'


			if (`startSize'==`endSize') {
				local matNameList `matNameListOld'
				local matIndexList `matIndexListOld'
				di as text "warning: ignoring matrix `thisMatrix' with zero dimension"
				}

			local isMatrix = 0
			
			}

		else {

			if ("`lastVar'"~="") {
				unab lastVar : `lastVar'
				if (index(" `matNameList' "," `lastVar' ")>0) & (`isMatrix'==0) {
					di as error "a matrix has already been defined with name `lastVar'"
					exit 110
					}
				
				foreach var of varlist `lastVar' {
					local tempType : type `var'
					if (substr("`tempType'",1,3)=="str") {
						di as text "warning: ignoring string variable `var'"
						local lastVar : subinstr local lastVar "`var'" ""
						}
					}
				
				if (`isMatrix'==0) local newVarList `"`newVarList' `lastVar'"'
				if (`isMatrix'==1) local matVarList `"`matVarList' `lastVar'"'
				}

			local lastVar `1'

			}

		mac shift
		local anything `*'

		}

	local newVarList  : list uniq newVarList
	
	local matSize : list sizeof matNameList
	local matSize = 0.5*`matSize'

	foreach stataMat in `matrix' {
		if (index(" `matNameList' `newVarList' "," `stataMat' ")>0) {
			di as text "warning: ignoring Stata matrix `stataMat'. A matrix has been defined with this name"
			local matrix : subinstr local matrix "`stataMat'" ""
			}
		}

	local version = 1 //0 for file append

	/* variable names to be read from local macro */

	local allNames `"`matNameList' `newVarList' `matrix'"'
	
	foreach varName in `allNames' {

		if (length("`varName'")>19) {

			di as error "the variable name `varName' is too long"
			di as error "variable and matrix names can not exceed 19 characters"
			exit 198
			}
		}

	local allNamesLen : length local allNames

	plugin call _matwrite `matVarList' `newVarList' `if' `in', "`using'" `version' `replace' `matSize' `allNamesLen'

	di as text "file `using' saved"

end
