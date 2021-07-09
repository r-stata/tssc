*! version 1.05, Ben Jann, 27apr2005
program define mrgraph
	version 8.2

//Syntax parsing
	gettoken graphtype 0 : 0
	local graphlist "bar dot hbar tab"
	if !`: list graphtype in graphlist' {
		di as error `"`graphtype' is not a valid graphtype"'
		exit 198
	}
	syntax varlist [if] [in] [fweight aweight] [ , /*
	                 */ ADDval ADDval2(string) Width(numlist >1 int max=1)/*
	 mrtab_options   */ Response(passthru) CONDition(passthru) Poly INclude INCLUDEMissing CASEwise /*
	                 */ COUNTall sort SORT2(numlist int max=1 >0) DEScending by(string) /*
	 _mrsvmat_options*/ Stat(passthru) RTotal CTotal noPercent noLabel /*
	 tabplot_options */ height(real 0.8) HORizontal BARWidth(real 0.5) /*
	 bar/dot_options */ bysep(string) OVERSubopts(string) /*
	 remainder       */ YSCale(passthru) XSCale(passthru) * ]

//Parse by option
	if `"`by'"'!="" {
		ParseBy `by'
	}

//Check options consistency
	if "`graphtype'"=="tab"&"`by'"=="" {
		di as error "graphtype tabplot not allowed unless by() is specified"
		exit 198
	}
	if `"`addval2'"'!="" {
		local addval addval
	}
	else local addval2 " "
	if "`label'"!=""&"`addval'"!="" {
		di as error "nolabel and addval not allowed both"
		exit 198
	}
	if "`rtotal'"!=""&"`by'"=="" {
		di as error "rtotal not allowed unless by() is specified"
		exit 198
	}

//Retrieve frequencies
	mrtab `varlist' `if' `in' [`weight'`exp'] , `response' `condition' `poly' /*
	 */ `include' `includemissing' `casewise' `countall' `by' nofreq
	preserve
	_mrsvmat, `stat' rtotal ctotal `percent' `label' clear returnstat

//Graph label
	if "`stat'"=="freq" local what "frequency"
	else if "`stat'"=="column" local what "column percent (base: cases)"
	else if "`stat'"=="row" local what "row percent"
	else if "`stat'"=="cell" local what "percent (base: cases)"
	else if "`stat'"=="rcolumn" local what "column percent (base: responses)"
	else if "`stat'"=="rcell" local what "percent (base: responses)"

//Sorting
	if "`sort'"!=""|"`sort2'"!="" {
		unab vlist: C* T
		local nov: word count `vlist'
		if "`sort2'"=="" local sort2 `nov'
		if `sort2'<=`nov' {
			sort `: word `sort2' of `vlist'' in 1/`=_N-1'
			if "`descending'"!="" {
				qui gen id=-_n
				sort id in 1/`=_N-1'
				drop id
			}
		}
	}
	qui gen id=_n

//Assemble over-variable
	capture confirm new variable L
	if _rc!=0&"`label'"=="" {
		if "`addval'"!="" {
			qui replace R=R+`"`addval2'"'+L if _n<_N
			qui replace R=L in l
		}
		else qui replace R=L
	}
	capture drop L

//Drop totals
	if "`rtotal'"=="" drop T
	else local T T
	if "`ctotal'"=="" qui drop in l

//Split labels
	if "`width'"!="" {
		forv i=1/`=_N' {
			local lab=R[`i']
			SplitLabel `"`lab'"' `width' nobreak
			qui replace R=`"`lab'"' in `i'
		}
	}

//Graph: univariate/inboard
	if "`by'"=="" | ( "`bysep'"=="inboard" & "`graphtype'"!="tab" ) {
		graph `graphtype' (asis) C* `T', over(R, sort(id) `oversubopts') ///
		 yti(`what') `yscale' `xscale' `options'
		exit
	}

//Prepare data for other graphs
//Rename totals variable (=> reshape)
	if "`T'"=="T" {
		unab vlist: C*
		local nov: word count `vlist'
		rename T C`++nov'
	}
//Get labels of by-groups
	unab vlist: C*
	local nov: word count `vlist'
	forv i=1/`nov' {
		local C: word `i' of `vlist'
		local vallab `"`vallab'`i' `"`: var l `C''"' "'
	}
//Reshape
	tokenize `by', parse("()")
	qui reshape long C, i(id) j(`3')
	tempname `3'
	lab def ``3'' `vallab'
	lab val `3' ``3''

//Graph: outboard
	if "`graphtype'"!="tab" {
		if "`bysep'"=="outboard" {
			graph `graphtype' (asis) C ,  over(R,sort(id) `oversubopts') ///
			 yti(`what') over(`3'`byopts') ///
			 `yscale' `xscale' `options'
		}

//Graph: separate
		else if "`bysep'"=="separate" {
			if "`sort'"!=""|("`sort'"==""&"`sort2'"=="") {
				local sort2 id
				local descending
			}
			graph `graphtype' (asis) C, over(R, sort(`sort2') `descending' `oversubopts') ///
			 yti(`what') by(`3'`byopts') ///
			 `yscale' `xscale' `options'
		}
		exit
	}

//Tabplot
//Levels and labels
	qui count if `3'==1
	local nor `r(N)'
	sort `3' id
	forv i=1/`nor' {
		local lab=R[`i']
		local ylabels `"`ylabels'`i++' `"`lab'"' "'
	}
//Direction
	if index("`stat'","column") local horizontal vertical
	else if "`stat'"=="row" local horizontal horizontal
	if "`horizontal'"!="horizontal" {
		local ygrid grid
		local xgrid nogrid
		local lhs id
		local rhs `3'
		if index(`"`yscale'"',"norev") {
			local sign "+"
		}
		else local sign "-"
	}
	else {
		local ygrid nogrid
		local xgrid grid
		local lhs `3'
		local rhs id
		if index(`"`xscale'"',"rev")&!index(`"`xscale'"',"norev") {
			local sign "-"
		}
		else local sign "+"
	}
//Compute margins
	sum C, meanonly
	qui gen M = `lhs' `sign' `height' * C / `r(max)'
	local max = trim("`: di %6.0g r(max)'")
//Graph
	twoway scatter id `3', ms(none)  yla(`ylabels', `ygrid' ang(h)) yscale(reverse) ///
	 || rbar M `lhs' `rhs', barw(`barwidth') xla(1(1)`nov', `xgrid' val) ///
	 subtitle(`what', place(w) size(medsmall)) legend(off) yti("") xti("") ///
	 note("maximum: `max'") `yscale' `xscale'  `options' `horizontal'
end

program ParseBy
	syntax varname [ , INboard OUTboard SEParate * ]
	local bysep `inboard'`outboard'`separate'
	if length("`bysep'")>8 {
		di as error "by_subopts inboard, outboard, separate are mutually exclusive"
		exit 198
	}
	else if "`bysep'"=="" local bysep inboard
	c_local bysep `bysep'
	c_local by "by(`varlist')"
	if `"`options'"'!="" c_local byopts `", `options'"'
end

program SplitLabel
	args lab width nobreak
	local j 1
	local temp : piece `j' `width' of `"`lab'"', `nobreak'
	local newlab `"`"`temp'"'"'
	local j 2
	local temp : piece `j' `width' of `"`lab'"', `nobreak'
	if `"`temp'"'=="" local newlab `"`newlab' """'
	while `"`temp'"'!="" {
		local newlab `"`newlab' `"`temp'"'"'
		local j=`j'+1
		local temp : piece `j' `width' of `"`lab'"', `nobreak'
	}
	c_local lab `"`newlab'"'
end
