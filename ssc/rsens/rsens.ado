/* 
Version 1; 06.12.2012
Author: Sunil Mitra Kumar
stuff.sunil@gmail.com
*/

program define rsens, rclass
version 8.0
syntax varname [, Gamma(numlist >=1 sort) nn(integer -1)  treatment(varname) id(varname)  matchid(namelist) support(varname)]   

tempname ns ncs out1 out2 out3 out4 out5 out6 out7 out8 out9 out10 out11 out12 out13 out14 out15 out16 out17 out18 out19 out20 csaverage saverage cs1 cs2 cs3 cs4 cs5 cs6 cs7 cs8 cs9 cs10 cs11 cs12 cs13 cs14 cs15 cs16 cs17 cs18 cs19 cs20 csi cscheck ds dsbs t csplus

	if "`treatment'"=="" local treatment _treated
	if "`id'"=="" local id _id
	if "`matchid'"=="" local matchid _n
	if "`support'"=="" local support _support	
	if `nn'==-1 {
	di as error "option nn() must be specified"
	exit 198
	}
	

	
tokenize `gamma'
		if `1'~=1 {
			local gamma = "1 `gamma'"
		}
		preserve
		qui keep if `support'
		if "`if'"~="" {
			qui keep if `if'
		}
qui {
gen `ncs'=`nn' 			// number of controls in each matched strata
gen `ns'=`nn'+1			// number of cases in each matched strata
su `ncs'
local ncmax=r(max) 

* Gather outcome values for each control case
	forv i=1/`ncmax' {
	gen `out`i''=.
	}
	levelsof `id' if `treatment', local(levels)
	forv i=1/`ncmax' {
	foreach treated of local levels {
	su `matchid'`i' if `id'==`treated' 
	local match=r(mean)
	su `varlist' if `id'==`match'
	replace `out`i''=r(mean) if  `id'==`treated'
	}
	local outlist `outlist' `out`i''
	}


keep if `treatment'  //have obtained outcomes for matched controls; so have wide data; restrict accordingly.

egen `csaverage'=rowmean(`outlist') 
egen `saverage'=rowmean(`varlist' `outlist') 
forv i=1/`ncmax' {
gen `cs`i''=`out`i''>`saverage' 
local cslist `cslist' `cs`i''
}

gen `csi'=`varlist'>`saverage'

local cslist `cslist' `csi'

egen `ds'=rank(abs(`varlist'-`csaverage'))
gen `dsbs'=`ds'*`csi'
su `dsbs'
gen `t'=r(sum)
egen `csplus'=rowtotal(`cslist')

}  // end of qui


* table header
	di as text "{hline 7}{c TT}{hline 35}{c TT} "
	di as text "       {c |}              Range of             {c |} "
	di as text " Gamma {c |}        significance levels        {c |} "
	di as text "{hline 7}{c +}{hline 35}{c +} "
	
mat rsensvalues=J(1,3,.)

foreach g of numlist `gamma' {
gamval `varlist', gamma(`g') csplus(`csplus') ns(`ns') ds(`ds') t(`t')
}

	local cnames gamma lower_p upper_p
	mat colnames rsensvalues=`cnames'
	mat rsensvalues=rsensvalues[2..., 1...]



restore
return mat rsensresult=rsensvalues

end

capture program drop gamval
program define gamval
syntax varlist , [csplus(varname) ns(varname) ds(varname) t(varname) gamma(real 1) ] 

tempvar  psplus psminus meanplus meanminus varplus varminus 

qui {
gen `psminus'=`csplus'/(`csplus'+(`ns'-`csplus')*`gamma') 
gen `psplus'=`csplus'*`gamma'/(`csplus'*`gamma'+`ns'-`csplus')
}
foreach sign in plus minus {
	 qui {
	 egen `mean`sign''=total(`ds'*`ps`sign'') 
	 egen `var`sign''=total(`ds'*`ds'*`ps`sign''*(1-`ps`sign'')) 
	 local stat`sign'=(`t'-`mean`sign'')/(`var`sign''^0.5)
	 local sig`sign'=1-normal((`t'-`mean`sign'')/(`var`sign''^0.5))
	}	
	}
di as result %5.0g `gamma'  as text "  {c |}    [" as result %012.0g `sigminus' as text "," as result %12.0g `sigplus' as text " ]   {c |} "
mat rsensvalues=rsensvalues\(`gamma',`sigminus',`sigplus')
end

