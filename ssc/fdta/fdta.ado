/*---------------------------
01Feb2010 - version 1.0

Change contents of string variables

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
cap prog drop fdta
prog define fdta
	version 9
	syntax varlist ,From(string) [To(string)]	
	local m="`varlist'"
	qui ds, has(type string)		
	local rvar=r(varlist)
	local n=0
	local nv=0
	local var=" "
	foreach x of local m  {
		if strpos("`rvar'","`x'")!=0 { 
		tempvar id
		qui gen `id'=strpos(`x',"`from'")
		qui replace `id'=1 if `id'>0
		qui sum `id'
		local i=r(sum)
			if `i'>0 {
				qui replace `x'=subinstr(`x',"`from'","`to'",.)
				di as txt _n "string variable " as result "`x' " as txt "changed in " as result "`i' " as txt "places!"
				local n=`n'+1
			}
		}
		else {
			local nv=`nv'+1
			local var="`var'"+"`x' "
		}
	}
	while `n'==0 {
		di as result _n "Note: " as txt "no variable changed!"
		exit
	}
	if `nv'>=1 {
		di as result _n "FDTA "  as txt "only check the string varibles"
		di as txt "The following numeric variable has not been changed: "
		di as result "`var' "
	}
end
