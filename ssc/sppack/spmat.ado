*! version 1.0.5  26nov2018
program define spmat, rclass

	version 11.1
	
	gettoken sub 0 : 0 , parse(" ,")
	
 	local len = length(`"`sub'"')
        if `len'==0 {
               di as err "No subcommand specified"
               exit 198
        }
        
	// some spmat subcommands create tempnames used by Mata
	// make sure to drop the tempnames after a subcommand is terminated
	
	if `"`sub'"'==substr("idistance",1,max(5,`len')) {
		SPMAT_idistance `0'
	}
	else if `"`sub'"'==substr("contiguity",1,max(3,`len')) {
		cap noi SPMAT_contiguity `0'
		SPMAT_drop_tempnames `matanames'
	}
	else if `"`sub'"'==substr("use",1,max(3,`len')) {
		SPMAT_read `0'
	}
	else if `"`sub'"'==substr("import",1,max(2,`len')) {
                SPMAT_import `0'
        }
	else if `"`sub'"'==substr("export",1,max(2,`len')) {
                SPMAT_export `0'
        }
	else if `"`sub'"'==substr("save",1,max(2,`len')) {
                SPMAT_save `0'
        }
	else if `"`sub'"'=="drop" {
                SPMAT_drop `0'
        }
	else if `"`sub'"'==substr("graph",1,max(2,`len')) {
                SPMAT_graph `0'
        }
	else if `"`sub'"'==substr("putmatrix",1,max(3,`len')) {
		syntax [ namelist(max=3)] [, * ]
		
		local w : word count `namelist'
		if `w'==0 {
			di "{err}name of spmat object required"
			exit 498
		}
		local objname : word 1 of `namelist'
		if `w'>2 local old _old
		cap noi SPMAT_putmatrix`old' `0'
		local rc = _rc
		if `rc' {
                	capture SPMAT_drop_tempnames `matanames'
			capture mata: SPMAT_fcheck(`objname')
			if _rc capture mata mata drop `objname'
		}
		exit `rc'
        }
	else if `"`sub'"'==substr("getmatrix",1,max(3,`len')) {
		syntax namelist(min=1 max=3) [, * ]
		local w : word count `namelist'
		if `w'>2 local old _old
                SPMAT_getmatrix`old' `0'
        }
        else if `"`sub'"'==substr("permute",1,max(3,`len')) {
                SPMAT_permute `0'
        }
        else if `"`sub'"'==substr("dta",1,max(3,`len')) {
                cap noi SPMAT_dta `0'
                SPMAT_drop_tempnames `matanames'
        }
	else if `"`sub'"'==substr("summarize",1,max(2,`len')) {
		SPMAT_summarize `0'
		return add
	}
        else if `"`sub'"'==substr("note",1,max(4,`len')) {
                cap noi SPMAT_note `0'
                SPMAT_drop_tempnames `matanames'
        }
        else if `"`sub'"'==substr("tobanded",1,max(3,`len')) {
                SPMAT_tobanded `0'
        }
        else if `"`sub'"'==substr("copy",1,max(4,`len')) {
                SPMAT_copy `0'
        }
        else if `"`sub'"'==substr("lag",1,max(3,`len')) {
                SPMAT_lag `0'
        }
        else if `"`sub'"'==substr("eigenvalues",1,max(3,`len')) {
                SPMAT_eigenvalues `0'
        }
        else if `"`sub'"'==substr("idmatch",1,max(2,`len')) {
                SPMAT_idmatch `0'	// not documented
        }
 	else {
                di as error `"`sub' unknown subcommand"'
                exit 198
        }
        
end

program define SPMAT_drop_tempnames
	
	syntax [anything]
	
	local rc = c(rc)
	
        foreach m of local 0 {
		capture mata: mata drop `m'
	}
	if `rc' exit `rc'
	
end

program define SPMAT_contiguity, sortpreserve

	syntax name [if] [in] using/, 		///
		id(varname numeric) 		///
		[				///
		rook				///
		NORMalize(string)		///
		TOLerance(real .0000001) 	///
		BANDed				///
		replace				///
		saving(string asis)	 	///
		noMATrix			///
		]
	
	if "`matrix'"=="nomatrix" & `"`saving'"'=="" {
		di "{err}saving() required with option nomatrix"
		exit 498
	}
	
	SPMAT_normparse,  `normalize'
	local normalize `r(normalize)'
	
	marksample touse
	
	qui preserve
	
	tempvar index index2 gr N
	tempname map
	tempfile mapping gr1 gr2 n2 n3 jb
	
	c_local matanames `map'
	
	qui keep if `touse'
	
	qui count
	local size = `r(N)'
	
	// ++++++++++++ mapping between `id' and 1...n
	keep `id'
	qui gen double `index' = _n
	qui save `mapping'
	mata : `map'=st_data(.,"`id' `index'")
	
	sort `id'
	capture by `id': assert _N==1
	if _rc {
		di as err "`id' values must be unique"
		exit 498
	}
		
	if ("`normalize'"=="spectral" & "`banded'"=="banded") {
		di "{err}spectral normalization not allowed with " 	///
			"option banded"
		exit 498
	}
	
	local tolerance = `tolerance'
	
	if "`rook'"=="" {		// ++++++++++++++++++ vertex contiguity
		
		capture rename `id' _ID
		qui merge 1:n _ID using `"`using'"'
		qui count if _merge == 1
		if r(N) > 0 {
			di as err "Some observations in master dataset "    ///
				"are not in coordinates dataset"
			exit 498
		}
		qui keep if _merge==3
		keep `index' _X _Y
		order `index' _X _Y
		
		qui drop if _X==.

		qui replace _X = round(_X,`tolerance')
		qui replace _Y = round(_Y,`tolerance')
		
		sort _X _Y
		qui by _X _Y: gen double `gr'=_n==1
		qui replace `gr'=sum(`gr')
		
		drop _X _Y
		
		sort `gr' 		// there will still be multiple 
					// obs per `gr' `index'
					// but mata will process them faster 

		qui by `gr': gen `N'=_N
		qui drop if `N'==1
		
		qui count
		if `r(N)'==0 {
			di
			di "{res}No neighbors found"
			di
			exit 0
		}
		
		qui replace `N' = `N'==2		
	}
	else {				// ++++++++++++++++++++ edge contiguity
				
		tempvar orderu _X2 _Y2 slope intercept vline v edge
		tempvar minX maxX minY maxY
		
		// +++++++++++ shp2dta does not create an order var, create one
		qui use _ID _X _Y using `"`using'"', clear
		capture rename _ID `id'
		qui gen double `orderu' = _n
		sort `id'
		qui merge n:1 `id' using `mapping'
		qui count if _merge == 2
		if r(N) > 0 {
			di as err "Some observations in master dataset "    ///
				"are not in coordinates dataset"
			exit 498
		}
		qui keep if _merge==3
		drop _merge
		qui assert `index'!=.
		keep `index' `orderu' _X _Y
		sort `index' `orderu'
		drop `orderu'
		
		qui gen double `_X2' = _X[_n-1]
		qui gen double `_Y2' = _Y[_n-1]
		qui drop if _X==. | `_X2'==.
		
		qui gen double `slope' = (_Y-`_Y2') / (_X-`_X2')
		qui gen double `intercept' = _Y-`slope'*_X
		qui gen double `vline' = _X if `slope'==.
		
		qui replace `slope' = round(`slope',`tolerance')
		qui replace `intercept' = round(`intercept',`tolerance')
		qui replace `vline' = round(`vline',`tolerance')
		
		sort `intercept' `slope' `vline'
		qui by `intercept' `slope' `vline': gen double `gr' = _n==1
		qui replace `gr'=sum(`gr')
		
		drop `slope' `intercept'
		qui gen byte `v' = `vline'==.
		drop `vline'
	
		sort `gr'
		qui by `gr': gen `N'=_N
		qui drop if `N'==1
		
		qui count
		if `r(N)'==0 {
			di
			di "{res}No neighbors found"
			di
			exit 0
		}
		
		qui keep `index' _X _Y `gr' `_X2' `_Y2' `v' `N'
		
		qui gen double `minX' = min(_X,`_X2')
		qui gen double `maxX' = max(_X,`_X2')
		qui gen double `minY' = min(_Y,`_Y2')
		qui gen double `maxY' = max(_Y,`_Y2')
		
		drop _X `_X2' _Y `_Y2'
		sort `gr'
		
		qui replace `N' = `N'==2
		
		keep `index' `gr' `N' `v' `minX' `maxX' `minY' `maxY'
		
		order `index' `gr' `N' `v' `minX' `maxX' `minY' `maxY'
	}
	
	if "`replace'"=="replace" capture spmat drop `namelist'
	
	if `"`saving'"'!="" {
		gettoken file replace : saving, parse(" ,")
		if "`replace'"!="" {
			local replace = trim(subinstr("`replace'",",","",.))
		}
	}
	
	mata : SPMAT_contiguity("`namelist'",`map',"`normalize'",  ///
		`size',"`rook'","`matrix'","`banded'","`file'","`replace'")
	
	mata : mata drop `map'
	
	restore
	
end

program define SPMAT_idistance, sortpreserve
	
	syntax anything [if] [in] , 				///
		id(varname numeric) 				///
		[						///
		DFunction(string)				///
		NORMalize(string)				///
		BTRuncate(numlist >0 min=2 max=2)		///
		DTRuncate(numlist >=0 integer min=1 max=2)	///
		VTRuncate(string)				///
		BANDed						///
		replace						///
		knn(string)					/// undocumented
		]
	
	marksample touse, novarlist
	
	gettoken objname coordinates : anything
	
	if "`coordinates'"=="" {
		di "{err}at least one coordinate variable required"
		exit 498
	}
	capture confirm numeric variable `coordinates'
	if _rc {
		di "{err}coordinate variables must be numeric"
		exit 498
	}
	foreach c of local coordinates {
		capture assert !missing(`c') if `touse'
		if _rc {
		       di "{err}coordinate variable {bf:`c'} has missing values"
			exit 198
		}
	}
	
	tempvar order
	qui gen double `order' = _n
	sort `coordinates'
	capture by `coordinates': assert _N==1
	if _rc {
		di "{err}Two or more observations have the same coordinates"
		exit 498
	}
	sort `order'
	
	local ncoor : word count `coordinates'
	
	// parse knn option
	
	if "`knn'"!="" {
		gettoken knn rest : knn, parse(",")
		local rest : subinstr local rest "," " "
		local 0 ", knn(`knn') `rest'"
		syntax , knn(numlist max=1 >0) [ TIES(string) ]
		if "`ties'"!="" {
			if "`ties'"!="keep" & "`ties'"!="drop" {
				di "{err}invalid {cmd:ties()} option"
				exit 498
			}
		}
	}
	
	local btr = ("`btruncate'"!="")
	local dtr = ("`dtruncate'"!="")
	local vtr = ("`vtruncate'"!="")
	local ktr = ("`knn'"!="")
	local trs = `btr'+`dtr'+`vtr'
	if `trs'>1 {
		di "{err}only one of btruncate(), dtruncate(), or " _c
			di "vtruncate() is allowed"
		exit 498
	}
	
	SPMAT_normparse,  `normalize'
	local normalize `r(normalize)'
	
	if ("`banded'"=="banded" & `trs'==0 & `ktr'==0) {
		di "{err}one of truncate() required"
		exit 498
	}
	
	if ("`banded'"=="banded" & "`normalize'"=="spectral") {
		di "{err}spectral normalization not allowed with " 	///
			"option {cmd:banded}"
		exit 498
	}
	
	// +++++++++++++++++++++++++++++++++++++++++++ process dfunction option
	
	// for either haversine the number of coordinates must =2
	// miles can be specified only with haversine
	
	local 0 "_`dfunction'"
	capture syntax [ namelist(name=dfunction) ] [, MIles ]
	if _rc {
		di "{err}option {cmd:dfunction()} incorrectly specified"
		exit 498
	}
	local dfunction : subinstr local dfunction "_" "" 
	if "`dfunction'"=="" local dfunction "euclidean"
	
	local 0 ",`dfunction'"
	
	local 0 ",`dfunction'"
	syntax [, EUClidean DHAVersine RHAVersine * ]  // Minkowski passed in *
	
	local minkowski `options'
	
	if "`minkowski'" != "" {
		capture confirm integer number `minkowski'
		if _rc {
			di "{err}option {cmd:dfunction()} incorrectly specified"
			exit 498
		}
		else {
			if `options'<1 {
				di "{err}Minkowski distance must be > 0"
				exit 498
			}
			local power `minkowski'
		}
	}
	
	if "`power'"=="" local power 2
	
	opts_exclusive "`euclidean' `dhaversine' `rhaversine' `minkowski'"
	
	if ("`dhaversine'`rhaversine'"!="" & `ncoor'!=2) {
		di "{err}{cmd:`dhaversine'`rhaversine'} requires "  ///
					"two coordinate variables"
		exit 498
	}
	
	if ("`dhaversine'`rhaversine'"=="" & "`miles'"!="") {
		di "{err}{cmd:miles} not allowed with option "	///
					"{cmd:`euclidean'`minkowski'}"
		exit 498
	}
	
	if "`miles'"=="" {
		local dscale = "km"
	}
	else local dscale = "miles"
	
	if "`euclidean'`minkowski'"!="" {
		local type "reals"
	}
	else if "`dhaversine'"!="" {
		local type "degrees"
	}
	else local type
	
	tempvar prob
	
	markout `touse' `coordinates'
	
	preserve
	quietly keep if `touse'
	
	qui count
	local maxn = r(N)-1
	
	if ("`knn'"!="") {
		capture confirm integer number `knn'
		if _rc {
			di "{err}knn() must be an integer"
			exit 498
		}
		
		if (`knn'>`maxn') {
			di "{err}knn() must be <= `maxn'"
			exit 498
		}
	}
	else local knn=0
	
	local trtype = ("`btruncate'"!="")*1 + ("`dtruncate'"!="")*2 + ///
		("`vtruncate'"!="")*3
	
	local num1 = 0
	local num2 = 0
	
	if "`btruncate'"!="" {
		local num1 : word 1 of `btruncate'
		local num2 : word 2 of `btruncate'
		if `num2' <= `num1' {
			di "{err}number of bins must be greater than the " _c
				di "bin you are truncating at"
			exit 498
		}
	}
	
	if "`dtruncate'"!="" {
		local num1 : word 1 of `dtruncate'
		local num2 : word 2 of `dtruncate'
		if "`num2'"=="" local num2 = `num1'
		qui count
		local limit = floor(`r(N)'/4)
		if (`num1' > `limit' | `num2' > `limit') {
			di "{err}dtruncate() arg must be <= `limit'"
			exit 498
		}
	}
	
	if "`vtruncate'"!="" {
		local nval : word count `vtruncate'
		if `nval'>1 {
			di "{err}{cmd:vtruncate()} accepts only one number"
			exit 498
		}
		capture local num1 = `vtruncate'
		if _rc {
			di "{err}{cmd:`vtruncate'} is not a valid number"
			exit 498
		}
		capture confirm number `num1'
		if _rc {
			di "{err}{cmd:`vtruncate'} did not evaluate to a number"
			exit 498
		}
		local num2 = 0
	}
	
	if "`replace'"=="replace" {
		capture spmat drop `objname'
	}
	
	mata : SPMAT_idistance`banded'("`objname'" ,"`id'" , 		///
		"`coordinates'", "`normalize'", `trtype', `num1', 	///
		`num2', "`type'",`power',"`dscale'")
	
	restore
	
end

program define SPMAT_putmatrix, rclass
	
	syntax namelist(max=2) [ ,					///
		IDISTance 						///
		NORMalize(string)					///
		Bands(numlist integer >=0 min=1 max=2) 			///
		id(string)						///
		eig(string)						///
		replace							///
		force							///
		]
	
	local objname : word 1 of `namelist'
	local matname : word 2 of `namelist'
	
	if "`matname'`id'`eig'"=="" {
		di "{err}at least one of matname, id, eig required"
		exit 498
	}
	
	if "`replace'"=="" {
		capture mata : SPMAT_assert_object("`objname'")
		if !_rc {
			di "{err}spmat object {cmd:`objname'} already exists"
			exit 498
		}
		if "`matname'"=="" {
			di "{err}matname required for a new spmat object"
			exit 498
		}
		local replace 0
	}
	else {
		capture mata : SPMAT_assert_object("`objname'")
		if _rc local replace 0
		else local replace 1
	}
	
	if "`matname'"=="" {
		if "`idistance'"!="" {
			di "{err}idistance can only be specified with matname"
			exit 498
		}
		if "`normalize'"!="" {
			di "{err}normalize can only be specified with matname"
			exit 498
		}
		if "`bands'"!="" {
			di "{err}bands can only be specified with matname"
			exit 498
		}
	}
	else {
		capture mata mata describe `matname'
		if _rc {
			di "{err}matrix `matname' not found"
			exit 498
		}
	}
	
	if "`id'" != "" {
		
		tempname vecname
		c_local matanames `vecname'
		
		local w : word count `id'
		if `w'>1 {
			di "{err}only one argument allowed in id()"
			exit 498
		}
		
		capture confirm variable `id'
		local sid = _rc
		capture mata mata describe `id'
		local mid = _rc
		if (!`sid' & !`mid') {
			di "{err}ambiguous id({cmd:`id'}): {cmd:`id'} "	///
				"exists in both Stata and Mata"
			exit 498
		}
		
		if !`sid' {
			capture confirm numeric variable `id'
			if _rc {
				di "{err}`id' must be a numeric variable"
				exit 498
			}
			capture assert `id' != .
			if _rc {
				di "{err}`id' contains missing values"
				exit 498
			}		
			mata :`vecname'=st_data(.,"`id'")
		}
		else {
			capture mata: `vecname' = `id'
			if _rc {
				di "{err}`id' not found"
				exit 498
			}
		}
	}
	
	if "`matname'"== "" {
		local matname .
		local hasm 0
	}
	else local hasm 1
	
	if "`id'"== "" {
		local hasid 0
		local vecname .
	}
	else local hasid 1
	
	if "`eig'"== "" {
		local hase 0
		local eig .
	}
	else {
		capture mata: SPREG_eigen_check(`eig')
		if _rc {
			di "{err}`eig' must be a numeric rowvector"
			exit 498
		}
		local hase 1
	}
	
	SPMAT_normparse,  `normalize'
	local normalize `r(normalize)'
	
	gettoken lb ub : bands
	if "`lb'"=="" local lb=-1
	if "`ub'"=="" local ub=`lb'
	
	if ("`normalize'"=="spectral" & "`bands'"!="") {
		di "{err}spectral normalization not allowed "		///
			"with banded matrices"
		exit 498
	}
	
	if "`objname'"=="`matname'" {
		di "{err}matname must be different from objname"
		exit 498
	}
	
	cap noi mata : SPMAT_putmatrix("`objname'",`hasm',`hasid',	///
		`hase',"`idistance'","`normalize'",`lb',`ub',`matname',	///
		`vecname',`eig')
	exit _rc
		
end

program define SPMAT_putmatrix_old
	
	syntax namelist [ , 						///
		IDISTance 						///
		NORMalize(string)					///
		Bands(numlist integer >=0 min=1 max=2) 			///
		id(string)						///
		replace							///
		force							///
		]
	
	local words : word count `namelist'
	if (`words'<2 | `words'>3) {
		di "{err}incorrect number of arguments"
		exit 498
	}
	
	local objname : word 1 of `namelist'
	local matname : word 2 of `namelist'
	local vecname : word 3 of `namelist'
	
	if "`vecname'"!="" {
		gettoken bef aft : 0, parse(",")
		local bef : subinstr local bef  "`vecname'" ""
		if ("`aft'"!="") local aft `aft' id(`vecname')
		else local aft `aft' , id(`vecname')
		
		local 0 `bef' `aft'
	}
	
	SPMAT_putmatrix `0'
end

program define SPMAT_getmatrix
	
	syntax namelist(min=1 max=2) [, id(string) eig(string) ]
	
	local objname : word 1 of `namelist'
	local matname : word 2 of `namelist'
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc SPMAT_error `objname'
	
	if ("`objname'"=="`matname'") {
		di "{err}matname must be different from objname"
		exit 498
	}
	if ("`objname'"=="`id'") {
		di "{err}id must be different from objname"
		exit 498
	}
	if ("`objname'"=="`eig'") {
		di "{err}eig must be different from objname"
		exit 498
	}
	
	if "`matname'"!="" {
		if ("`matname'"=="`id'") {
			di "{err}id must be different from matname"
			exit 498
		}
		if ("`matname'"=="`eig'") {
			di "{err}eig must be different from matname"
			exit 498
		}
	}
	
	if "`id'"!="" {
		if ("`id'"=="`eig'") {
			di "{err}eig must be different from id"
			exit 498
		}
	}
	
	if "`matname'"!="" mata : `matname' = SPMAT_getsel("`objname'",2)
	if "`id'"!="" mata : `id' = SPMAT_getsel("`objname'",1)
	if "`eig'"!="" mata : `eig' = SPMAT_getsel("`objname'",12)
	
end

program define SPMAT_getmatrix_old
	
	syntax namelist [, * ]
	
	local objname : word 1 of `namelist'
	local matname : word 2 of `namelist'
	local vecname : word 3 of `namelist'
	
	local args : word count `namelist'
	
	if `args'>3 {
		di "{err}too many arguments"
		exit 498
	}
	
	if "`vecname'"!="" {
		gettoken bef aft : 0, parse(",")
		local bef : subinstr local bef  "`vecname'" ""
		if ("`aft'"!="") local aft `aft' id(`vecname')
		else local aft `aft' , id(`vecname')
		local 0 `bef' `aft'
	}
	
	SPMAT_getmatrix `0'
end

program define SPMAT_summarize, rclass
	
	syntax name(name=objname)				///
		[ ,						///
		LInks						///
		DETail						///
		DTRuncate(numlist >=0 integer min=1 max=2)	///
		VTRuncate(string)				///
		BTRuncate(numlist >0 min=2 max=2)		///
		BANDed						///
		]
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc SPMAT_error `objname'
	
	local btr = ("`btruncate'"!="")
	local dtr = ("`dtruncate'"!="")
	local vtr = ("`vtruncate'"!="")
	local con = ("`banded'"!="")
	local trs = `btr'+`dtr'+`vtr'+`con'
	
	if `trs'>1 {
		di "{err}only one of btruncate(), dtruncate(), "	///
				"vtruncate(), or banded is allowed"
		exit 498
	}
	
	if `trs'>0 & "`detail'"!="" {
		if (`btr') local opt "btruncate()"
		if (`dtr') local opt "dtruncate()"
		if (`vtr') local opt "vtruncate()"
		if (`con') local opt "banded"
		di "{err}option detail not allowed with {inp}`opt'"
		exit 498
	}
	
	if "`detail'"!="" & "`links'"=="" {
		di "{err}option links required with detail"
		exit 498
	}
	
	if "`btruncate'"!="" {
		local atbin : word 1 of `btruncate'
		local nbins : word 2 of `btruncate'
		if `nbins' < 2 {
			di "{err}number of bins must be greater than 1"
			exit 498
		}
		if `nbins' <= `atbin' {
			di "{err}number of bins must be greater than the " _c
				di "bin you are truncating at"
			exit 498
		}
		mata : SPMAT_summarize("`objname'",		///
			"`links'","`detail'",1,`atbin',`nbins')
		if _rc SPMAT_error `objname'
	}
	else if "`dtruncate'"!="" {
		local below : word 1 of `dtruncate'
		local above : word 2 of `dtruncate'
		if "`above'"=="" local above = `below'
		mata : SPMAT_summarize("`objname'",		///
			"`links'","`detail'",2,`below',`above')
		if _rc SPMAT_error `objname'
	}
	else if "`vtruncate'"!="" {
		local nval : word count `vtruncate'
		if `nval'>1 {
			di "{err}{cmd:vtruncate()} accepts only one number"
			exit 498
		}
		capture local num1 = `vtruncate'
		if _rc {
			di "{err}{cmd:`vtruncate'} is not a valid number"
			exit 498
		}
		capture confirm number `num1'
		if _rc {
			di "{err}{cmd:`vtruncate'} did not evaluate to a number"
			exit 498
		}
		mata : SPMAT_summarize("`objname'",		///
			"`links'","`detail'",3,`num1')
		if _rc SPMAT_error `objname'
	}
	else if "`banded'"!="" {
		mata : SPMAT_summarize("`objname'",		///
			"`links'","`detail'",4)
		if _rc SPMAT_error `objname'
	}
	else {	// plain summary
		mata : SPMAT_summarize("`objname'",		///
			"`links'","`detail'",0)
		if _rc SPMAT_error `objname'
	}
	
	return scalar eig = r(eigen)
	
	if "`links'"=="links" {
		return scalar ltotal = r(total)
		return scalar lmax = r(max)
		return scalar lmean = r(mean)
		return scalar lmin = r(min)
	}
	else {
		return scalar max = r(max)
		return scalar mean = r(mean)
		return scalar min0 = r(min0)
		return scalar min = r(min)
	}
	
	local n = r(n)
	local b = r(b)
	
	if (`n'!=`b' | `trs'>0) {
		return scalar canband = r(canband)
		return scalar uband = r(uband)
		return scalar lband = r(lband)
	}
	
	return scalar n = r(n)
	return scalar b = r(b)
	
end

program define SPMAT_note
	
	syntax anything [ , replace ]
		
	gettoken obj rest : 0, parse(": ")
	gettoken colon rest : rest, parse(": ")
	
	if "`colon'"=="drop" { // ++++++++++++++++++++++++++++++++++++ drop note
		capture mata : SPMAT_note("`obj'",`"`note'"',"drop")
		if _rc SPMAT_error `obj'
		exit 0
	}
	
	if !("`colon'"=="" | "`colon'"==":") {
		di "{err}invalid syntax"
		exit 498
	}
	
	if "`colon'"=="" { // ++++++++++++++++++++++++++++++++++++ display note
		tempname note
		c_local matanames `note'
		capture mata : `note' = SPMAT_getsel("`obj'",7)
		if _rc SPMAT_error `obj'
		mata : `note'
		exit 0
	}
	else if "`colon'"==":" {
		gettoken note suffix : rest, parse(",")
		if "`suffix'"!= "" {
			gettoken comma suffix : suffix, parse(", ")
			
			local suffix = trim(`"`suffix'"')
			
			if "`suffix'"=="replace" {
				// +++++++++++++++++++++++++++++++ replace note	
				capture mata : SPMAT_note("`obj'",	///
					`"`note'"',"replace")
				if _rc SPMAT_error `obj'
			}
			else { // +++++++++++++++++++++++++++++++++ append note
				capture mata : SPMAT_note("`obj'",`"`note'"',"")
				if _rc SPMAT_error `objname'
			}
		}
		else { // +++++++++++++++++++++++++++++++++++++++++ append note
			capture mata : SPMAT_note("`obj'",`"`note'"',"")
			if _rc SPMAT_error `obj'
		}
	}
	else {
		di "{err}invalid syntax"
		exit 498
	}
	
end

program define SPMAT_tobanded
	
	syntax anything 					///
		[ ,						///
		BTRuncate(numlist >=0 min=2 max=2)		///
		DTRuncate(numlist >=0 integer min=1 max=2)	///
		VTRuncate(string)				///
		replace 					///
		]
	
	local btr = ("`btruncate'"!="")
	local dtr = ("`dtruncate'"!="")
	local vtr = ("`vtruncate'"!="")
	local trs = `btr'+`dtr'+`vtr'
	
	if `trs'>1 {
		di "{err}only one of btruncate, dtruncate, "		///
			"or vtruncate is allowed"
		exit 498
	}
	
	local nwords : word count `anything'
	if `nwords' > 2 { // +++++++++++++++++++++++++++++++++++ invalid syntax
		di "{err}invalid syntax"
		exit 498
	}
	
	local oldobj : word 1 of `anything'
	local newobj : word 2 of `anything'
	
	if `nwords'==1 { // +++++++++++++++++++++++++++++ objname, replace
		if "`replace'"=="" {
			capture mata : SPMAT_assert_object("`oldobj'")
			if !_rc {
				di "{err}spmat object {cmd:`oldobj'} "	///
					"already exists"
				exit 498
			}
		}
	}
	
	if `nwords'==2 {
		capture mata : SPMAT_assert_object("`oldobj'")
		if _rc {
			di "{err}spmat object {cmd:`oldobj'} not found"
			exit 498
		}
		
		if "`replace'"=="" {
			capture mata : SPMAT_assert_object("`newobj'")
			if !_rc {
				di "{err}object {cmd:`newobj'} already exists"
				exit 498
			}
		}
	}
	
	if "`btruncate'"!="" {
		local atbin : word 1 of `btruncate'
		local nbins : word 2 of `btruncate'
		
		if `nbins' < 2 {
			di "{err}number of bins must be greater than 1"
			exit 498
		}
		
		if `nbins' <= `atbin' {
			di "{err}number of bins must be greater "	///
				"than the bin you are truncating at"
			exit 498
		}
		mata : SPMAT_truncate_object("`oldobj'",	///
			"`newobj'",1,`atbin',`nbins',"`replace'",0)
	}
	else if "`dtruncate'"!="" {
		local below : word 1 of `dtruncate'
		local above : word 2 of `dtruncate'
		if "`above'"=="" local above = `below'
		mata : SPMAT_truncate_object("`oldobj'",	///
			"`newobj'",2,`below',`above',"`replace'",0)
	}
	else if "`vtruncate'"!="" {
		local nval : word count `vtruncate'
		if `nval'>1 {
			di "{err}{cmd:vtruncate()} accepts only one number"
			exit 498
		}
		capture local num1 = `vtruncate'
		if _rc {
			di "{err}{cmd:`vtruncate'} is not a valid number"
			exit 498
		}
		capture confirm number `num1'
		if _rc {
			di "{err}{cmd:`vtruncate'} did not evaluate to a number"
			exit 498
		}
		mata : SPMAT_truncate_object("`oldobj'",	///
			"`newobj'",3,`num1',0,"`replace'",0)
	}
	else {
		mata : SPMAT_truncate_object("`oldobj'",	///
			"`newobj'",4,0,0,"`replace'",0)
	}
	
end

program define SPMAT_dta
	
	syntax anything [if] [in] ,			///
		[ 					///
		id(varname numeric) 			///
		rcv					///
	      	IDISTance 				///
		NORMalize(string)			///
		replace 				///
		force					///
	    	]
	
	if "`rcv'" != "" & "`id'" != "" {
		opts_exclusive "id() rcv"
	}
	
	gettoken objname vars : anything
	unab varlist : `vars'
	
	confirm variable `varlist'
	
	SPMAT_normparse,  `normalize'
	local normalize `r(normalize)'
	
	marksample touse
		
	if ("`replace'" != "") capture spmat drop `objname'
	
	if "`rcv'" != "" {
		mata: SPMAT_putdta_rcv("`objname'","`varlist'","`touse'", ///
			"`idistance'","`normalize'")
		exit
	}
	
	tempname mat vec
	c_local matanames `mat' `vec'
	mata : `mat' = st_data(.,"`varlist'","`touse'")
	if ("`id'" != "") {
		mata: `vec' = st_data(.,"`id'","`touse'")
	}
	else mata: `vec' = J(0,1,0)
	
	mata : SPMAT_putdta("`objname'",`mat',"`idistance'","`normalize'",`vec')
	
end

program define SPMAT_permute
	
	syntax anything
	
	local nwords : word count `anything'
	if `nwords' != 2 {
		di "{err}spmat permute requires two arguments"
		exit 498
	}
	
	gettoken objname sortvar : anything
	local sortvar = trim("`sortvar'")
	
	// check objname
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc SPMAT_error `objname'
	
	// check sortvar
	
	capture confirm numeric variable `sortvar'
	if _rc {
		di "{err}`sortvar' must be a numeric variable"
		exit 498
	}
	capture assert `sortvar' != .
	if _rc {
		di "{err}`sortvar' contains missing values"
		exit 498
	}
	
	capture mata : SPMAT_permute("`objname'", "`sortvar'")
	if _rc SPMAT_error `objname'
	
end

program define SPMAT_read

	syntax name using/ [, replace ]
	
	if "`replace'" != "" {
		capture spmat drop `namelist'
	}
	
	mata : SPMAT_read_u("`namelist'",`"`using'"') 

end

program define SPMAT_import

	syntax name using/, [ 			///
		noID 				///
		nlist 				///
		geoda 				///
		NORMalize(string)		///
		IDISTance 			///
		replace 			///
		force				///
		]
	
	if ("`nlist'"=="nlist" & "`idistance'"=="idistance") {
	      di "{err}idistance not allowed with nlist"
	      exit(498)
	}
	
	if ("`id'"!="" & "`nlist'"=="nlist") {
		di "{err}option {cmd:noid} not allowed with nlist"
		exit 498
	}
	
	if ("`id'"!="" & "`geoda'"!="") {
		di "{err}option {cmd:noid} not allowed with geoda"
		exit 498
	}
	
	SPMAT_normparse,  `normalize'
	local normalize `r(normalize)'
	
	if "`replace'" != "" {
		capture spmat drop `namelist'
	}
	
	mata : SPMAT_import_u("`namelist'", `"`using'"', "`id'",	 ///
		"`nlist'", "`geoda'", "`idistance'","`normalize'")
	
end

program define SPMAT_export

	syntax name using/, [ noID nlist replace DELIMiter(string) ] 

	if "`replace'" != "" {
		local rpl 1
	}
	else local rpl 0
	
	if ("`id'"!="" & "`nlist'"!="") {
		di "{err}noid not allowed with nlist"
		exit 498
	}
	
	capture mata : SPMAT_assert_object("`namelist'")
	if _rc SPMAT_error `namelist'
	
	mata : SPMAT_export_u("`namelist'",`"`using'"',"`id'",`rpl', "`nlist'")
	
end

program define SPMAT_save

	syntax name using/ [, replace ]

	if "`replace'" == "" {
		local replace 0
	}
	else local replace 1
	
	capture mata : SPMAT_assert_object("`namelist'")
	if _rc SPMAT_error `namelist'
	
	mata : SPMAT_save_u("`namelist'",`"`using'"',`replace')
	if _rc SPMAT_error `namelist'

end

program define SPMAT_drop

	capture syntax name
	
	capture mata : SPMAT_assert_object("`namelist'")
	local rc = _rc
	
	capture mata : mata drop `namelist'
	
	if (`rc') di "{txt}(note: spmat object {cmd:`namelist'} not found)"
	
end

program define SPMAT_normparse, rclass

	capture syntax , [row SPEctral MINmax]

	if _rc {
		local 0 : subinstr local 0 "," ""
		local 0  = trim("`0'")
		di as err `"invalid {cmd:normalize(`0')}"'
		exit 498
	}

	if "`row'" != "" {
		return local normalize "row"
		exit
	}	
	else if "`spectral'" != "" {
		return local normalize "spectral"
		exit
	}	
	else if "`minmax'" != "" {
		return local normalize "minmax"
		exit
	}	
	else {
		return local normalize 
	}
end

program define SPMAT_graph

	syntax name(name=spmat) 	///
		[ , 			///
		BLocks(string)		///
		XTItle(passthru)	///
		YTItle(passthru)	///
		XLABel(passthru)	///
		YLABel(passthru)	///
		XSCale(passthru)	///
		YSCale(passthru)	///
		ASPECTratio(passthru)	///
		LEGend(passthru)	///
		by(passthru)		///
		plain			///  UNDOCUMENTED
		*			///
		]
	
	if `"`by'"' != "" {
		di "{err}option by() not allowed"
		exit 191
	}
	
	capture mata : SPMAT_assert_object("`spmat'")
	if _rc SPMAT_error `spmat'
	
	preserve
	
	qui drop _all
	
	tempvar row column yy xx color id
	
	if "`blocks'" != "" {
		gettoken b1 b2 : blocks, parse("() ") match(parens)
		if "`b2'"=="" {
			local blocks `b1'
			local stat = "max"	/* default statistic */
		}
		else {
			local blocks `b2'
			local stat `b1'
		}
	
		confirm integer number `blocks'
		
		if `blocks' < 1 {
			di "{err}number of blocks must be >0"
			exit 498
		}
	}
	else {
		local blocks 1
		local stat = "max"	// default statistic
	}
	
	qui gen double `color' = .
	
	mata : SPMAT_make("`spmat'","`color'",`blocks',"`stat'")
	
	qui gen `column' = int((_n-1)/`dim') + 1  // dim created in SPMAT_make
	sort `column' 
	qui by `column': gen `row' = _n
	qui expand 5
	
	sort `row' `column'
	qui by `row' `column': gen `id' = _n
	qui gen `xx' = cond(`id'<3, `column'-1, 	///
				cond(`id'<5, `column', .))
	qui gen `yy' = cond(`id'==2 | `id'==3, -`row',	///
			cond(`id'==1 | `id'==4, -`row'+1, .))
	qui replace `yy' = abs(`yy')
	qui levels `color', local(shades)
	
	// invert shades list
	mata : SPMAT_invert_shades("`shades'")
	local shades = r(shadelist)
	
	local area = ""
	foreach i of local shades {
		local area `area' (area `yy' `xx' if `color'==`i', ///
		    cmiss(n) bfintensity(100) blw(vvvthin) bc(gs`i') nodropb)
	}
	
	if "`plain'"=="plain" {
		twoway `area' ,						///
			aspectratio(1) legend(off)			///
			xlabel(minmax,nolabels nogrid tstyle(none)) 	///
			ylabel(minmax,nolabels nogrid tstyle(none))	///
			xscale(off) yscale(off reverse) 		///
			`options'
	}
	else {
		
		if (`dim'<=12) {
			local ticks = "1(1)`dim'"
		}
		else {
			qui summ `xx'
			local max = `r(max)'
			
			_natscale 1 `max' 5
			local natmax = `r(max)'
			local delta = round(`r(delta)',1)
			if (`delta'<1) local delta = 1
			
			local ticks 1
			local curr 0
			local cond = `max'-`delta'
			
			while (`curr'<=`cond') {
				local curr = `curr' + `delta'
				if (`max'-`curr' >= .5*`delta') {
					local ticks "`ticks' `curr'"
				}
			}
			
			local ticks "`ticks' `max'"
		}
		
		qui replace `xx' = `xx' + .5
		qui replace `yy' = `yy' + .5
		
		if `"`aspectratio'"'=="" local aspectratio "aspectratio(1)"
		if `"`legend'"'=="" local legend "legend(off)"
		if `"`xtitle'"'=="" local xtitle "xtitle(Columns)"
		if `"`ytitle'"'=="" local ytitle "ytitle(Rows)"
		if `"`xlabel'"'=="" local xlabel "xlabel(`ticks', nogrid)"
		if `"`ylabel'"'=="" {
			local ylabel "ylabel(`ticks', nogrid angle(0))"
		}
		if `"`xscale'"'=="" local xscale = "xscale(alt)"
		if `"`yscale'"'=="" local yscale = "yscale(reverse)"
		
		
		twoway `area' , 					///
			`aspectratio' `legend' `xtitle' `ytitle'	///
			`xlabel' `ylabel' `xscale' `yscale' `options'
	}
	
	restore
	
end

program define SPMAT_lag, sortpreserve

	syntax anything [, id(varname numeric) ]
	
	local n : word count `anything'
		
	if (`n'<3 | `n'>4) {
		di "{err}invalid syntax"
		error 498
	}
	
	local type : word 1 of `anything'
	
	if (`n'==4 & "`type'"!="double" & "`type'"!="float") {
		di "{err}invalid type"
		exit 498
	}
	
	if `n'==4 {
		gettoken type anything : anything
	}
	else {
		local type = "float"
	}
	
	gettoken newvar anything : anything
	gettoken objname oldvar : anything
	local oldvar = trim("`oldvar'")
	confirm new variable `newvar'
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc SPMAT_error `objname'
	
	if "`id'"!="" {
		spmat idmatch `objname' , id("`id'")
	}
	
	mata : SPMAT_lag("`type'","`newvar'","`objname'","`oldvar'")
	
end

program define SPMAT_eigenvalues
	
	syntax anything [, EIGenvalues(string) replace drop]
	
	local n : word count `anything'
		
	if `n'>1 {
		di "{err}invalid syntax"
		error 498
	}
	
	local objname : word 1 of `anything'
	
	if "`drop'"=="drop" local replace = "drop"
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc SPMAT_error `objname'
	
	mata : SPMAT_eigenvalues("`objname'","`replace'",`eigenvalues')
	
end

program define SPMAT_idmatch
	
	syntax anything , id(varname numeric)
	
	/* sorts the dataset in memory on id variable such that the 
		id variable matches the ids contained in spmat object */
	
	local n : word count `anything'
		
	if `n'>1 {
		di "{err}invalid syntax"
		error 498
	}
	
	local objname : word 1 of `anything'
	
	capture mata : SPMAT_assert_object("`objname'")
	if _rc {
		di "{err}object `objname' not found"
		exit 498
	}
	
	capture assert `id' != .
	if _rc {
		di "{err}`id' contains missing values"
		exit 498
	}
	
	capture mata : SPMAT_idmatch("`objname'","`id'")
	if _rc {
		di "{err}ids in spmat object {bf:`objname'} do not match " ///
			"ids in variable {bf:`id'}"
		exit 498
	}
end

program define SPMAT_error
	args objname
	di "{err}spmat object {cmd:`objname'} not found"
	exit 498
end

exit

Version history

1.0.5

spmat dta - now supports (row, column, value) format with option -rcv-

1.0.4

spmat contiguity - option -tolerance()- is now applied and works with queen
	contiguity
	
1.0.3

spmat idistance - added check in Stata for duplicate coordinates
spmat idistance - added check in Stata for missing values in coordiate variables
spmat dta - errored out when option id() was omitted, this has been fixed

1.0.2

spmat idistance - option knn(#) is now knn(# [, ties(drop|keep)] )
spmat export - capture in front of Mata call was masking error messages
	coming from Mata code, this has been fixed
spmat getmatrix - revised syntax
spmat putmatrix - revised syntax; added error messages to make sure objname,
	matname, and vecname are different
spmat tobanded - capture in front of Mata call was masking error messages
	coming from Mata code, this has been fixed

