/*
Program creates column or row percentages of a two-way tabulation and saves results in a specified matrix with appropriate labels.

Version 1.0
July 2016
Loris Fagioli
lfagioli@ivc.edu
*/
program rcolp2mat
version 10
syntax varlist(max=2) [if/] [in] [fweight aweight], matrix(string) [row] [col] [detail] [total] [missing]

if "`row'"=="" & "`col'"=="" {
			di as err "row or col option required"
			exit 198
			}
if "`row'"=="row" & "`col'"=="col" {
			di as err "only one option (row or col) allowed"
			exit 198
			}
if "`detail'"=="detail" & "`total'"=="total" {
			di as err "only one option (detail or total) allowed"
			exit 198
			}

qui {

if "`if'"!="" local iff "if `if'"
if "`if'"!="" local iff2 "& `if'"
local varname1: word 1 of `varlist'
local varname2: word 2 of `varlist'

tab `varlist' `iff' `in' [`weight' `exp'], matcell(`matrix') `missing'
if "`row'"=="row"  mata: st_matrix("`matrix'", (st_matrix("`matrix'")  :/ rowsum(st_matrix("`matrix'"))))
if "`col'"=="col"  mata: st_matrix("`matrix'", (st_matrix("`matrix'")  :/ colsum(st_matrix("`matrix'"))))


*Add labels
levelsof `varname1' if missing(`varname2')==0 `iff2' `in', local(a) `missing'
levelsof `varname2' if missing(`varname1')==0 `iff2' `in', local(b) `missing'


local i=1
foreach r of local a {
capture local rr: label (`varname1') `r'
if _rc!=0 local rr `r'
local rr=ustrregexra("`rr'"," ","_") //if label has spaces
local rr=ustrregexra("`rr'","/","_") //if label has slashes
matrcrename `matrix' row `i' "`rr'"
local ++i
}

local i=1
foreach c of local b {
capture local cc: label (`varname2') `c'
if _rc!=0 local cc `c'
local cc=ustrregexra("`cc'"," ","_") //if label has spaces
local cc=ustrregexra("`cc'","/","_") //if label has slashes
matrcrename `matrix' col `i' "`cc'"
local ++i
}

*Add detail
if "`detail'"!="" {


		tab `varname1' if missing(`varname2')==0 `iff2' `in' [`weight' `exp'], matcell(r) 
		matrix colnames r="Total N"
		matrix `matrix'=`matrix',r
		tab `varname2' if missing(`varname1')==0 `iff2' `in' [`weight' `exp'], matcell(c) 
		matrix a=r(N)
		matrix c=c'
		matrix c=c,a
		matrix rownames c="Total N"
		matrix `matrix'=`matrix'\c

		matrix drop a c r
		
}


if "`total'"!="" {

if "`row'"=="row" {
		tab `varname2' if missing(`varname1')==0 `iff2' `in' [`weight' `exp'], matcell(c) `missing'
		matrix c=c'
		mata: st_matrix("c", (st_matrix("c")  :/ rowsum(st_matrix("c"))))
		matrix rownames c="Total %"
		matrix `matrix'=`matrix'\c
		matrix drop c 

}


if "`col'"=="col" {
		tab `varname1' if missing(`varname2')==0 `iff2' `in' [`weight' `exp'], matcell(c) `missing'
		mata: st_matrix("c", (st_matrix("c")  :/ colsum(st_matrix("c"))))
		matrix colnames c="Total %"
		matrix `matrix'=`matrix',c
		matrix drop c 
}
}

}

matrix li `matrix'
end 	

*-------------------------------------------------------------------------
*Subroutine by Nick Cox from STATA listserv: http://www.stata.com/statalist/archive/2006-11/msg00537.html
*-------------------------------------------------------------------------

program matrcrename 
	version 8 
	// syntax matrixname row_or_col which_row_or_col new_name 

	// matrix name 
	gettoken matrix 0 : 0 
	confirm matrix `matrix' 

	// row or column 
	gettoken which 0 : 0 
	local length = length("`which'") 
	if lower("`which'") == substr("row",1,`length') { 
		local which row 
	}
	else if lower("`which'") == substr("column",1,`length') { 
		local which col
	}
	else { 
		di as err "second argument should specify row or column" 
		exit 198 
	} 

	// which row or column 
	gettoken where newname : 0 
	if "`which'" == "row" { 
		capture local found = inrange(`where', 1, rowsof(`matrix'))
		if _rc { 
			di as err "inappropriate row number?"
			exit 498 
		} 
		if !`found' { 
			di as err "row out of range" 
			exit 498 
		}	
	}	
	else { 
		capture local found = inrange(`where', 1, colsof(`matrix')) 
		if _rc { 
			di as err "inappropriate column number?"
			exit 498 
		} 
		if !`found' { 
			di as err "column out of range" 
			exit 498 
		}	
	} 

	// test newname 
	tempname moo 
	matrix `moo' = J(1,1,1) 
	capture matrix rownames `moo' = `newname' 
	if _rc { 
		local what = cond("`which'" == "col", "column", "row") 
		di as err "inappropriate `what' name?" 
		exit 498
	} 

	// in business! 
	local names : `which'names `matrix' 
	tokenize `names'
	local `where' `newname'
	local newnames "`*'" 
	matrix `which'names `matrix' = `newnames' 
end 
