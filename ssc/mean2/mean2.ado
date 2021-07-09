*! mean2 1.0.0 26jan2010 by roywada@hotmail.com
*! Makes a table of estimate means with subpopulation differences

prog def mean2
syntax varlist(min=2) using/, over(str asis) CATegory(str asis) /*
	*/ [svy * vce(str asis) CLuster(str asis)] replace
version 9

qui {

versionSet

tokenize `category'
if "`svy'"=="svy" {
	local svy "svy:"
}

marksample touse `if' `in' [`weight'`exp']

if `version'>=11 {
	`svy' mean `varlist' if `touse' , over(`over') vce(`vce') cl(`cl')
}
else {
	`svy' mean `varlist' if `touse' , over(`over') cl(`cl')
}


qui outreg2 using `using', noaster nonotes noobs replace side ct("coef")
preserve
insheet using `using', noname clear
drop in `=_N'
sxpose, clear
drop _var1 _var3

tempvar order
gen `order'=_n
set obs `=_N+2'
replace `order'=0.5 in `=_N-1'
replace `order'=1.5 in `=_N'
sort `order'
set obs `=_N+1'
drop `order'
replace _var4="(1)" in 1
replace _var5="(1)" in 1
replace _var2="" if _var2==_var2[_n-1]
outsheet using `using', noname replace noquote
restore

if `version'>=11 {
	noi `svy' mean `varlist' `if' `in' [`weight'`exp'] , over(`over') vce(`vce') cl(`cl')
}
else {
	noi `svy' mean `varlist' `if' `in' [`weight'`exp'] , over(`over') cl(`cl')
}

} /* qui */

tempname coef se
foreach var in `varlist' {
	lincom [`var']`1' - [`var']`2'
	mat `coef' = nullmat(`coef') \ `r(estimate)'
	mat `se' = nullmat(`se') \ `r(se)'
}
ret list
qui mkest, replace bmat(`coef') vmat(`se') depvar(Difference) /*
	*/ cmd(correlation) noobs noesample matname(`varlist') df_r(`r(df)')

di
outreg2 using `using', nonotes noobs `options'
end



* mkest 1.0.1 14jan2010 by roywada@hotmail.com
* Convert variables to estimates matrix
program def mkest, eclass
version 8

syntax [if] [in], replace [b(str asis) v(str asis) bmat(str asis) /*
	*/ vmat(str asis) depvar(str asis) cmd(str asis) obs(numlist) /*
	*/ NOESAMPLE NOOBS matname(str asis) df_r(str asis)]

tempname ebmat eVmat
marksample touse

if "`depvar'"=="" {
	local depvar `b'
}
if "`cmd'"=="" {
	local cmd `depvar'
}

if "`bmat'"=="" {
	* get from variables
	mkmat `b' if `touse', matrix(`ebmat') nomiss
	mat `ebmat'=`ebmat''
	
	mkmat `v' if `touse', matrix(`eVmat') nomiss
	mat `eVmat'=`eVmat''
	mat `eVmat'=(`eVmat''*`eVmat')
}
else {
	* get from matrices
	mat `ebmat'=`bmat''
	
	mat `eVmat'=`vmat''
	mat `eVmat'=(`eVmat''*`eVmat')
}

if "`obs'"=="" {
	local obs=colsof(`ebmat')
}
if "`noobs'"~="" {
	local obs .
}
if "`matname'"~="" {
	matname `ebmat' `matname', col(.)
	matname `eVmat' `matname', row(.)
	matname `eVmat' `matname', col(.)
}


tempvar sample
cap gen `sample'=1 if `b'~=. & `touse'
cap gen `sample'=1 if `b'~="" & `touse'
cap qui replace `sample'=0 if `sample'==.

	if "`replace'"=="replace" {
		eret clear
		if "`noesample'"=="" {
			eret post `ebmat' `eVmat', esample(`sample')
		}
		else {
			eret post `ebmat' `eVmat'
		}
		eret local depvar `"`depvar'"'
		eret local cmd "`cmd'"
		eret scalar N = `obs'
		if "`df_r'"~="" {
			eret scalar df_r = `df_r'
		}
	}

end


* 03nov2009 from outreg2.ado
prog define versionSet
        * sends back the version as c_local
        version 7.0
        
        * invisible to Stata 7
        cap local Version7 `c(stata_version)'
        c_local Version7 `Version7'
        
        if "`Version7'"=="" {
                * it is version 7
                c_local version 7
        }
        else if `Version7'>=8.2 {
                version 8.2
                c_local version 8.2
        }
        
        if "`Version7'"=="" {
                c_local bind ""
        }
        else {
                c_local bind "bind"
        }
end
exit


