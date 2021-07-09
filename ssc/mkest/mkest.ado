*! mkest 1.0.0 13jan2010 by roywada@hotmail.com
*! Convert variables to estimates matrix

program def mkest, eclass
version 8

syntax [if] [in], replace b(str asis) v(str asis) /*
	*/ [depvar(str asis) cmd(str asis) obs(numlist)]

tempname ebmat eVmat
marksample touse

if "`depvar'"=="" {
	local depvar `b'
}
if "`cmd'"=="" {
	local cmd `depvar'
}

mkmat `b' if `touse', matrix(`ebmat') nomiss
mat `ebmat'=`ebmat''

mkmat `v' if `touse', matrix(`eVmat') nomiss
mat `eVmat'=`eVmat''
mat `eVmat'=(`eVmat''*`eVmat')

if "`obs'"=="" {
	local obs=colsof(`ebmat')
}

tempvar sample temp
cap gen `sample'=1 if `b'~=. & `touse'
cap gen `sample'=1 if `b'~="" & `touse'
qui replace `sample'=0 if `sample'==.

	if "`replace'"=="replace" {
		eret clear
		mat b=`ebmat'
		mat V=`eVmat'
		eret post b V, esample(`sample')
		eret local depvar `"`depvar'"'
		eret local cmd "`cmd'"
		eret scalar N = `obs'
	}

end
exit

