program define mstore
version 7.0
*! version 1.1.0 by M Blasnik 4/19/2001 saves matrices in characteristics

* retrieve list of matrices
local mats "`_dta[matnames]'"
local Nmats: word count `mats'

* check for listing query
if "`0'"=="list" {
	if `Nmats'>0 {di in ye "`Nmats' matrices found: `mats'"}
	else {di "No matrices found"}
	exit
}

* main program
gettoken name 0 : 0 , parse(" ,")
if "`name'"=="," {
	di as error "must specify alias name for matrix: matkeep aliasname, options"
	exit 198
}

syntax , [From(str) Make(str) DELete REPlace]

if "`from'"!="" & "`make'"!="" {
	di as error "cannot specify from and make together"
	exit 198
}
if "`delete'"!="" & "`from'`make'"!="" {
	di as error "cannot specify delete with from or make"
	exit 198
}
if "`from'"=="" & "`replace'"!="" {
	di as error "must specify from() option with replace"
	exit 198
}
if "`from'"!="" {
	tempname mat
	matrix `mat'=`from'
}
if "`make'"!="" { /* make sure make is a legal matrix name */
	cap mat `make'=J(1,1,0)
	if _rc {
		di as error "`make' is not a valid matrix name"
		exit 198
	}
	matrix drop `make'
}
* look for matrix name on existing list 
local m=1		 /* stores matrix number */
tokenize `mats'
while "``m''"!="`name'" & "``m''"!=""{
	local m=`m'+1
}
if "``m''"=="" {local m=0}
* if deleting a matrix
if "`delete'"!="" {
	if `m'==0 {
		di as error "matrix `name' not found"
		exit 111
	}
	local i=1
	tokenize `mats'
	while "``i''"!="" {
		if `i'!=`m' {local newlist "`newlist' ``i''"}
		if `i'>=`m' {
			local j=`i'+1
			* shift row & col names
			local rowcnti: word count `_dta[M`i'rnames]'
			char _dta[M`i'rnames] "`_dta[M`j'rnames]'"
			char _dta[M`i'cnames] "`_dta[M`j'cnames]'"
			local rowcntj: word count `_dta[M`j'rnames]'
			* now change contents
			local max=max(`rowcnti',`rowcntj')
			forvalues row=1/`max' {
				char _dta[M`i'R`row'] "`_dta[M`j'R`row']'"
			}
		}
		local i=`i'+1
	}
	char _dta[matnames] "`newlist'"
	di as text "matrix `name' deleted"
	exit
}	


* if saving or replacing a matrix

if "`from'"!="" {
	if `m'>0 & "`replace'"=="" {
		di in red "matrix `name' already defined"
		error 110
	}
	*get rid of replace if doesn't exist on list
	if `m'==0 & "`replace'"!="" {local replace}
	* assign number, update matrix name list
	if "`replace'"=="" {local m=`Nmats'+1}
	* assign characteristics 
	local nrows=rowsof(`mat') 
	local ncols=colsof(`mat')
	local rnames: rowfullnames(`mat')
	local cnames: colfullnames(`mat')
	char _dta[M`m'rnames] "`rnames'"
	char _dta[M`m'cnames] "`cnames'"
	forvalues row=1/`nrows' {
		local rowvals
		forvalues col=1/`ncols' {
			local lval: di %18.0g `mat'[`row',`col']
			local lval=trim("`lval'")
			local rowvals "`rowvals' `lval'"
		}
		char _dta[M`m'R`row'] "`rowvals'"
	}
	if "`replace'"=="" {char _dta[matnames] "`mats' `name'"}
	di "matrix `name' stored"
}

* else you are retrieving a matrix
else {
	if "`make'"=="" {local make="`name'"}
	tempname thisrow newmat
	if `m'==0 {
		di in red "matrix `name' not found"
		error 198
	}
	local nrows :word count `_dta[M`m'rnames]'
	forvalues row=1/`nrows' {
		matrix input `thisrow'=(`_dta[M`m'R`row']')
		matrix `newmat'=nullmat(`newmat')\ `thisrow'
	}
	matrix rownames `newmat' = `_dta[M`m'rnames]'
	matrix colnames `newmat' = `_dta[M`m'cnames]'
	matrix `make' = `newmat'
	di as text "matrix `make' created"
}

end

