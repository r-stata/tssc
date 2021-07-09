*! version 1.0.4 21may2011 Daniel Klein
*	1.0.1 	reference may now be specified
*	1.0.2	assert mi set wide manually
*			u_mi_assert wide not fixed yet
*	1.0.3	u_mi_assert fixed and used
*			tempname for matrix checking dummy-coding
*	1.0.4	assert double precision

prog mi_cmd_mvncat
	version 11.1
	
	u_mi_assert_set wide
	if `_dta[_mi_M]' < 1 srerr noms
	
	syntax anything(id = "dset [(reference)]") [,noUPdate *]
	
	/*parse anything
	-----------------*/
	loc i 1
	gettoken dset`i' anything : anything ,p("\/")
	if inlist("`dset`i''", "\","/") srerr novars
	gettoken dset`i' refc`i' : dset`i' ,p("(") //check reference specified
	gettoken dump anything : anything ,p("\/")
	while !inlist(`"`dset`i''"', "", "\", "/") {
		gettoken dset`++i' anything : anything ,p("\/")
		/*check for explicit reference category*/
		gettoken dset`i' refc`i' : dset`i' ,p("(")
		gettoken dump anything : anything ,p("\/")
	}
	loc ndset = `i' - 1
	
	/*call subroutine fvcat in loop
	--------------------------------*/
	forval j = 1/`ndset' {
		loc user_ref = cond("`refc`j''" == "", "", "user_ref`refc`j''")
		srfvcat `dset`j'' ,`user_ref' `options'
	}

	/*mi update
	------------*/
	u_mi_certify_data, acceptable  
	if "`update'" == "" u_mi_certify_data ,proper	
end

prog srfvcat
	syntax varlist(numeric) [,REPort user_ref(name)]
	
	u_mi_no_sys_vars "`varlist'"
	u_mi_no_wide_vars "`varlist'"
	
	/*edit varlist
	---------------*/
	if "`user_ref'" != "" loc varlist : list varlist - user_ref
	loc varlist : list uniq varlist
	
	/*check dummies and determine reference category
	-------------------------------------------------*/
	tempname zo
	loc M `_dta[_mi_M]'
	loc ivlist `_dta[_mi_ivars]'
	loc nniv = ("`user_ref'" != "")
	foreach d of loc varlist {
		qui ta `d' ,matrow(`zo')
		if (`= rowsof(`zo')' != 2) | (`zo'[1,1] != 0) ///
			| (`zo'[2,1] != 1) srerr nodummy `d'
		if !`: list posof "`d'" in ivlist' {
			if `nniv' srerr notiv `varlist' `user_ref'
			loc nniv 1
			continue
		}
		forval m = 1/`M' {
			conf v _`m'_`d'
			if "`user_ref'" != "" {
				cap conf v _`m'_`user_ref'
				if !_rc loc refcat`m' _`m'_`user_ref'
			}
			else {
				cap ass _`m'_`d' != .
				if _rc {
					if "`refcat`m''" != "" srerr msoftmiss `varlist' ///
					,r1(`refcat`m'') r2(_`m'_`d')
					loc refcat`m' _`m'_`d'
					continue
				}
			}
			loc dlist`m' `dlist`m'' _`m'_`d'
		}
	}
	
	/*calculate values for reference category and assign final values
	------------------------------------------------------------------*/
	tempvar tmp_ref tmp_max tmp_chksum
	forval m = 1/`M' {
		loc vartype : t `: word 1 of `dlist`m'''
		loc doub = cond("`vartype'" == "double", "double", "")
		loc fp = cond("`vartype'" == "double", "", "float")
		qui g `double' `tmp_ref' = 1 - `: word 1 of `dlist`m''' ///
		if !inlist(`: word 1 of `dlist`m''', 0 ,1)
			/*create tmp_ref = . if no imputatios made
			!mi(`tmp_ref') can then be used to identify*/
		forval j = 2/`: word count `dlist`m''' {
			qui replace `tmp_ref' = `tmp_ref' - `: word `j' of `dlist`m'''
		}
		loc tmp_list `dlist`m'' `tmp_ref'
		qui egen `double' `tmp_max' = rowmax(`tmp_list') if !mi(`tmp_ref')
		qui g `tmp_chksum' = 0 if !mi(`tmp_ref')
	
		/*assign final values
		----------------------*/
		forval j = 1/`: word count `tmp_list'' {
			qui replace `: word `j' of `tmp_list'' ///
				= `fp'(`: word `j' of `tmp_list'') == `fp'(`tmp_max') ///
					if !mi(`tmp_ref')
			qui replace `tmp_chksum' = ///
				`tmp_chksum' + `: word `j' of `tmp_list'' 
				/*chksum has . where tmp_ref has .*/
		}				
		
		/*check only one dummy set to one
		----------------------------------*/
		cap as `tmp_chksum' == 1 if !mi(`tmp_ref')
		if _rc srerr notaddone `m'
		if "`refcat`m''" != "" qui replace `refcat`m'' = `tmp_ref' ///
			if `refcat`m'' == .
	
		/*report
		---------*/
		if "`report'" != "" {
			di _n
			loc norc = cond("`refcat`m''" == "", "no ", "")
			di "{txt}assigning final values to ... "
			di "{res}`dlist`m''"
			di "{txt}`norc'reference category {res}`refcat`m''"
		}
		
		/*clear locals and drop tempvars
		---------------------------------*/
		loc dlist`m'
		loc refcat`m'
		drop `tmp_ref' `tmp_max' `tmp_chksum'
	}
end

prog srerr
	gettoken werr 0 : 0
	if "`werr'" == "noms" {
		di "{err}no imputed values"
		exit 459
	}
	if "`werr'" == "novars" {
		di "{err}syntax is {bf:dset1 [ \ dset2 ... \ dsetk]}"
		exit 198
	}
	if "`werr'" == "nodummy" {
		di "{err}`0': not a dummy; only values 0 and 1 are allowed"
		exit 459
	}
	if "`werr'" == "notiv" {
		syntax varlist
		di "{err}`varlist': more than one dummy not registered as imputed"
		exit 459
	}
	if "`werr'" == "msoftmiss" {
		syntax varlist ,r1(varlist) r2(varlist)
		di "{err}`varlist': cannot determine reference category;"
		di "`r1' and `r2' both contain soft missings"
		exit 459
	}
	if "`werr'" == "notaddone" {
		di "{err}unexpected error in dataset {it:m} = `2';"
		di "{err}final values do not add up to 1"
		exit 498
	}
end
