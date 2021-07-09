*! version 1.0.2 08dec2010 Daniel Klein

program gdsum ,rclass byable(recall)
	/*set version*/
	if _caller() <11.1 {
		local vers =_caller()
		di "{txt}this is version {res}`vers' {txt}of Stata; " ///
		"{cmd:gdsum}{txt} is a version 11.1 program " ///
		"and may not work properly"
	}
	else version 11.1
	/*snytax
	weights are not documented. I am not yet sure 
	if weights are appropriate this way*/
	syntax varlist(numeric) [if] [in] [fw aw iw] ///
	[,REMove(string asis) MEDian MIN(real 0) MAX(real 1) ///
	COMma noVARLabel Format(string) MATrix(name)]
	/*set options*/
	if `"`remove'"' !="" local remove `"- `remove'"'
	else local remove -
	if "`median'" !="" local p50 p50
	else local p50
	local dpis =c(dp)
	if "`comma'" =="" local comma =c(dp)
	if `"`format'"' !="" {
		cap confirm form `format'
		if _rc {
			di "{err}option format() incorrectly specified"
			exit 198
		}
	}
	/*matrices description
	lv 			: vector of unique values in variables
	frq 		: vector of frequencies
	xbar 		: vector of means of classes
	m 			: matrix/scalar mean
	sd 			: matrix/scalar standard deviation
	M 			: output matrix*/
	tempname lv frq xbar m sd M tmp
	/*set ouput matrix*/
	local nvars : word count `varlist'
	if "`median'" !="" local ncols 4
	else local ncols 3
	mat `M' =J(`nvars',`ncols',.)	
	/*loop over vars*/
	local varcount 0
	local txtw 12
	foreach var of local varlist {
		if `"`varlabel'"' =="" {
			local nam : var lab `var'
			if `"`nam'"' =="" local nam `var'
			else local nam =subinstr("`nam'",".","",.)
		}
		else local nam `var'
		local ttxtw : length local nam
		if `ttxtw' >32 {
			di `"{res}`var'{txt}:{res} "`nam'" "' ///
				`"{txt}abbreviated to 32 characters"'
			local nam =abbrev("`nam'" ,32)
			local ttxtw 32
		}
		if `ttxtw' > `txtw' local txtw `ttxtw'
		local listofnames `"`listofnames'"`nam'" "'
		/*mark sample for each var*/
		qui cap drop `touse'
		marksample touse ,novarlist
		qui replace `touse' =0 if `var' >=.
		qui count if `touse'
		if r(N) ==0 {
			di "{res}`var'{txt}: no observations"
			continue
		}
		/*check value label exists*/
		local vallab : val lab `var'
		if `"`vallab'"' =="" {
			di "{res}`var'{txt}: no value label"
			continue
		}
		/*set matrices lv and frq*/
		qui ta `var' if `touse' [`weight'`exp'] ///
			,matrow(`lv') matcell(`frq')
		local n =r(N)
		local nrows =rowsof(`lv')
		/*set empty matrix*/
		mat `xbar' =J(`nrows',1,.)
		/*get median class*/
		if "`median'" !="" {
			qui su `var' [`weight'`exp'] if `touse' ,d
			local med_cl =floor(r(p50))
		}
		forval j =1/`nrows' {
			/*get upper and lower bounds*/
			local lvl =`lv'[`j',1]
			local lbl : label `vallab' `lvl' ,strict
			/*deal with commas*/
			if "`comma'" !="comma" local comma_rmv ""
			else local commarmv "."
			local lbl =subinstr("`lbl'",",","`commarmv'",.)
			foreach chr of local remove {
				local lbl =subinstr("`lbl'","`chr'"," ",.)
			}
			if "`lbl'" =="" {
				di "{res}`var'{txt}=={res}`lvl'{txt} not labeled"
				continue
			}
			tokenize `lbl'
			/*correct first and last bounds*/
			if `j' == 1 & "`2'" =="" {
				cap confirm number `1'
				if _rc {
					di "{err}`var': invalid lower boundary '`1''"
					exit 198
				}
				local 2 =`1'
				local 1 `min'
				di "{res}`var'{txt}: lower boundary set to {res}`min'"
			}
			if `j' ==`nrows' & "`2'" =="" {
				if "`max'" =="1" local max ``max'' 
				cap confirm number `1'
				if _rc {
					di "{err}`var': invalid '`1''"
					exit 198
				}				
				local 2 =`max'				
				di "{res}`var'{txt}: upper boundary set to {res}`max'"
			}
			/*1 contains lower 2 upper bound*/
			cap mat `xbar'[`j',1] =(`1' + `2') / 2
			/*calculate median additionally*/
			if "`median'" !="" {
				if `lvl' ==`med_cl' {
					qui ta `var' if `var' <`med_cl' & `touse' [`weight'`exp']
					local f_pre =r(N)
					local f_med =`frq'[`j',1]
					local med ///
						=`1' + ((`n'/2 - `f_pre') / `f_med') * (`2' - `1')
					ret scal p50_`var' =`med'
				}
			}
		}
		/*calculate mean and sd*/
		mat `m' =(`xbar'' * `frq') / `n'		//mean
		/*sd*/
		mat `tmp' =J(`nrows',1,`m'[1,1])		//constant vextor mean
		mat `sd' =vecdiag((`xbar' - `tmp') * (`xbar' -`tmp')')'
		mat `sd' =1/(`n'-1) * (`sd'' * `frq')
		mat `sd' =sqrt(`sd'[1,1])
		/*add to output matrix*/
		mat `M'[`++varcount',1] =`m'
		mat `M'[`varcount',2] =`sd'
		if "`median'" !="" {
			mat `M'[`varcount',3] =`med'
			mat `M'[`varcount',4] =`n'
		}
		else mat `M'[`varcount',3] =`n'
		/*return results in scalars*/
		ret scal N_`var' =`n'
		ret scal sd_`var' =`sd'[1,1]
		ret scal mean_`var' =`m'[1,1]
	}
	/*output*/
	mat coln `M' =Mean SD `p50' Obs
	cap mat rown `M' =`listofnames'
	if "`dpis'" != "`comma'" set dp `comma'
	matlist `M' ,format(`format') tw(`txtw') 
	if c(dp) !="`dpis'" set dp `dpis'
	/*opt ret matrix*/
	if `"`matrix'"' !="" ret mat `matrix' =`M'
end
