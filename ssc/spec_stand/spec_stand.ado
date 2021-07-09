* ! version 1.0  26jan2006
* ! version 1.1  09feb2006 added unadj as independent option from standonly and speconly
* rosa gini 
program define spec_stand, rclass
	version 8.2 , missing
	syntax varlist(min=3) [if] [in], BY(varlist)  /*
		*/  USing(string) NAMEPOPstd(string) [STANDonly SPEConly UNADJusted /*
		*/ noREstore SAVing(string) Format(string) Level(integer 95)/*
		*/ CONstant(integer 100) RATEname(string) LBname(string) UBname(string)/*
		*/ DENtot(string) NUMtot(string)]
	tempvar touse
	mark `touse' `if' `in'

	tokenize `varlist'
	local num `1'
	local den `2'
	mac shift 2
	local Ga `*'
	
	/* defaults */
	if `"`format'"'=="" {
		local format "%5.1f"
	}
	if `"`ratename'"'=="" {
		local ratename "_rate"
	}
	if `"`lbname'"'=="" {
		local lbname "_lb"
	}
	if `"`ubname'"'=="" {
		local ubname "_ub"
	}
	if `"`numtot'"'=="" {
		local numtot "_`num'_tot"
	}
	if `"`dentot'"'=="" {
		local dentot "_`den'_tot"
	}
	
	/* one of options saving and norestore must be set*/
	if (`"`saving'"'=="")&("`restore'"!="norestore") {
		disp as error "You must specify at least one of the two options:"             _n 
		disp as error " saving() and norestore."                                                    _n 
		disp as error "If you specify saving(), then the new data set is output to a disk file."    _n 
		disp as error "If you specify norestore then the new data set is created in the memory,"    _n 
		disp as error "and any existing data set in the memory is destroyed."                       _n 
		disp as error "For more details, see {help spec_stand:on-line help for spec_stand}."
		error 498
		}
	/* standonly and speconly are mutually exclusive*/
	if (`"`standonly'"'!="")&("`speconly'"!="") {
		disp as error "You cannot specify both speconly and standonly options."
		error 498
		}
	/* speconly and unadjusted are mutually exclusive*/
	if (`"`unadjusted'"'!="")&("`speconly'"!="") {
		disp as error "You cannot specify both speconly and unadjusted options."
		error 498
		}
	
	/* defines standard population*/
	preserve
	use `using',clear
	local j 1
	tokenize `"`Ga'"'
	while "``j''"!="" {
		qui capture drop if ``j''>=.
		qui capture drop if ``j''==""
		local j = `j' + 1
	}
	collapse (sum) `den'=`namepopstd',by(`Ga')
	tempfile standard
	save `standard'
	restore
	
	/* stratum-specific */
	if "`standonly'"==""{
		preserve
		collapse (sum) `num' `den' if `touse', by(`by' `Ga' `touse')
		drop `touse'
		qui gen `ratename'_spec=""
		qui gen `lbname'_spec=""
		qui gen `ubname'_spec=""
		local quanti=_N
		forvalues s=1/`quanti'{
			qui cii  `den'[`s'] `num'[`s'],ex level(`level')
			capture confirm number `r(lb)'
			if _rc==0{
				qui replace `ratename'_spec=string(r(mean)*`constant',"`format'") if   _n==`s'
				qui replace `lbname'_spec=string(r(lb)*`constant',"`format'") if   _n==`s'
				qui replace `ubname'_spec=string(r(ub)*`constant',"`format'") if   _n==`s'
			}
		}
		sort `by' `Ga'
		tempfile specific
		save `specific'
		restore
		}
	
	/* standardised*/
	
	if "`speconly'"==""{
		preserve
		collapse (sum) `num' `den' if `touse', by(`by' `Ga' `touse')
		drop `touse'
		qui gen `ratename'_stand=""
		qui gen `lbname'_stand=""
		qui gen `ubname'_stand=""
		sort `by' 
		tempvar group
		egen `group'=group(`by')
		qui sum `group'
		local quanti=r(max)
		// set matsize `quanti'
		qui dstdize `num' `den' `Ga' ,by(`group') using(`standard') level(`level')
		matrix T=r(adj)
		matrix L=r(lb)
		matrix R=r(ub)
		local col=colsof(T)
		forvalues j=1/`col'{
		local g`j'=`r(c`j')'
		}
		forvalues j=1/`col'{
		local l=L[1,`j']
		capture confirm number `l'
		if _rc==0{
			qui replace `ratename'_stand=string(T[1,`j']*`constant',"`format'") if string(`group')=="`g`j''"
			qui replace `lbname'_stand=string(L[1,`j']*`constant',"`format'") if string(`group')=="`g`j''"
			qui replace `ubname'_stand=string(R[1,`j']*`constant',"`format'") if string(`group')=="`g`j''"
			}
		}
		if "`check'"!=""{
			di "`check'"
			bysort `by' :egen _check=max(`den'<`check')
			}
		tempvar tag
		egen `tag'=tag(`by')
		keep if `tag'
		drop `group' `tag' `Ga'
		keep `by' `ratename'_stand `lbname'_stand `ubname'_stand
		sort `by'
		tempfile standardized
		save `standardized'
		restore
		}
	
	/*unadjusted*/
	if "`unadjusted'"!=""{
		preserve
		collapse (sum) `num' `den' if `touse', by(`by' `touse')
		drop `touse'
		qui gen `ratename'_unadj=""
		qui gen `lbname'_unadj=""
		qui gen `ubname'_unadj=""
		local quanti=_N
		forvalues s=1/`quanti'{
			qui cii  `den'[`s'] `num'[`s'] ,ex level(`level')
			capture confirm number `r(lb)'
			if _rc==0{
				qui replace `ratename'_unadj=string(r(mean)*`constant',"`format'") if   _n==`s'
				qui replace `lbname'_unadj=string(r(lb)*`constant',"`format'") if   _n==`s'
				qui replace `ubname'_unadj=string(r(ub)*`constant',"`format'") if   _n==`s'
			}
		}
		drop `num' `den'
		sort `by' 
		tempfile unadj_file
		save `unadj_file'
		restore
		}
	
	/* merging computed files, saving and/or leaving in memory*/
	preserve
	collapse (sum) `num' `den' if `touse', by(`by' `touse')
	drop `touse'
	rename `num' `numtot'
	rename `den' `dentot'
	if "`speconly'"==""{
		sort `by'
		merge `by' using `standardized'
		drop _merge
		}
	order `by'
	sort `by'
	if "`standonly'"==""{
		merge `by' using `specific'
		drop _merge `touse'
		order `by' `Ga' `num' `den'
		sort `by' `Ga'
		}
	sort `by'
	if "`unadjusted'"!=""{
		merge `by' using `unadj_file'
		drop _merge
		sort `by'
		}
	if(`"`saving'"'!=""){
		capture noisily save `saving'
		if(_rc!=0){
			disp in red `"saving(`saving') invalid"'
			exit 498
			}
		}
	if "`restore'"=="norestore" {
		restore, not
		}
	
	end
