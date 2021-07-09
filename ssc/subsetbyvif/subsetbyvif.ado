program define subsetByVIF, rclass
  version 15.0
*
* 4/25/2019 - using function subinstr caused problems when there are
*        variable names that are substrings of other variable names
*        (e.g. top1 and top10).  Changed to using function subinword.
*
  syntax varlist [if] [in] [,VIFList(numlist descending min=1)]
  marksample touse
*
* Place the names of the variables in varlist into
* the local macro covariates.
*
  local covariates `varlist'
*
* Place the viflimit values into the local
* macro viflist.
*
  local viflist `viflist'
  local vifcount=wordcount("`viflist'")
*
* If no viflist is provided, make a list
* of 1 value.  Default is 10.
*
  if `vifcount'==0 {
  	local vifcount=1
  	local viflist="10"
  }
*disp as result "viflist = `viflist'"
*
* Display number of covariates in the input varlist.
*
local input_n=wordcount("`covariates'")
disp as result "Number of covariates in varlist = `input_n'"
*
* Identify and drop variables to be omitted because of collinearity.
* Call the new list covariate_list.
*
qui _rmcoll `covariates', forcedrop
local covariate_list "`r(varlist)'"
*
* Display the number of covariates remaining.
*
local n=wordcount("`covariate_list'")
disp as result "Number of covariates remaining after elimination of multicollinear covariates = `n'"
*
* For each value of viflimit in viflist...
*
local outputcount=0
*
* (re)set tmpcovlist to be the full, post _rmcoll list
* of covariates.
*
local n_vif=0
local totalremoved=0
local tmpcovlist "`covariate_list'"
foreach viflimit of local viflist {
	local n_vif=`n_vif'+1
	disp as result "..."
	disp as result "Maximum VIF permitted in the next subset of covariates = `viflimit'"
	local n=wordcount("`tmpcovlist'")
	*
	* Loop until `regression_maxvif'<=`viflimit'.
	* the maximum vif from a set of regressions
	*
	local i=1
	local nremoved=0
	while (`i') {
		local regression_maxvif=0
		*
		* For each covariate, regress it against all the others.
		* Determine the maximum vif over these regressions. 
		*
		foreach thiscov of local tmpcovlist {
			local othercovs=subinword("`tmpcovlist'","`thiscov'","",1)
			*display ". regress `thiscov' `othercovs'"
			qui regress `thiscov' `othercovs'
			local vif = 1/(1-e(r2))
			if `vif' > `regression_maxvif' {
				local regression_maxvif = max(`regression_maxvif',`vif')
				local name_maxcov "`thiscov'"
				*disp as result "`thiscov' : r2 = `e(r2)'   vif=`vif'  (new maximum)"
			}
			else {
				*disp as result "`thiscov' : r2 = `e(r2)'   vif=`vif'"
			}
		}  //end of inner loop
		*
		* If the maximum vif for these regressions is > viflimit then remove
		* the associated covariates from the list and loop again.
		*
		* If the maximum vif for these regressions is <= viflimit then
		* we are done for this value of viflimit.
		* 
		if `regression_maxvif'<=`viflimit' {
			disp as result "Maximum remaining VIF = " %9.4f real("`regression_maxvif'") " <= " %9.4f real("`viflimit'")
			local i=0
		} 
		else {
			local nremoved=`nremoved'+1
			disp as result "(`nremoved') removing {it:`name_maxcov'} with VIF = " %9.4f real("`regression_maxvif'") ///
				" > " %9.4f real("`viflimit'")	
			local tmpcovlist=subinstr("`tmpcovlist'","`name_maxcov'","",1)
		}

	}  //end of infinite loop

	local outputcount=`outputcount'+1
	local viflimit`outputcount'=`viflimit'
	disp as result "`nremoved' covariates removed for maximum VIF=`viflimit'."
	local covlist`outputcount' "`tmpcovlist'"
	local totalremoved=`totalremoved'+`nremoved'
	disp as result "`totalremoved' covariates removed in total."
	
}

foreach listn of numlist  `outputcount'(1)1    {
	return local covlist`listn' = strtrim("`covlist`listn''")
	return local n`listn' = wordcount("`covlist`listn''")
	return local vifmax`listn' = `viflimit`listn''
	return local n_vif = `n_vif'
}

end
/* START HELP FILE
title[Select a subset of covariates constrained by VIF]

desc[
 {cmd:subsetByVIF} selects subsets of the covariates listed in depvar such that each covariate in a given subset has a VIF that is less than or equal to a specified value given by viflist.
 
 We are frequently faced with analyzing data sets in which the ratio of covariates to patients is high. There are several approaches to analyzing such data including penalized regression methods, k-fold cross-validation techniques, and bagging. A problem with any of these approaches is that, even after the elimination of variables causing multi-collinearity, the variance-covariance matrix of the remaining covariates is often highly ill-conditioned. The subsetByVIF program reduces the number of covariates to the largest subsample such that the maximum VIF for each variable in the subsample is less than some value specified by the user. These variables are selected without regard to the dependent variable of interest, which should mitigate problems due to overfitting. The use of this program should improve the convergence properties of many methods of exploratory data analysis.]
 
opt[list of maximum variance inflation factors (VIFs) used to subset depvar]

example[
 {stata webuse auto}

 {stata subsetByVIF price mpg weight length displacement gear_ratio foreign}

 {stata subsetByVIF price mpg weight length displacement gear_ratio foreign, viflist(15 5)}
]

author[Dale Plummer]
institute[Department of Biostatistics, Vanderbilt University School of Medicine]
author[William D. Dupont]
institute[Department of Biostatistics, Vanderbilt University School of Medicine]
email[william.dupont@vumc.org]
email[dale.plummer@vumc.org]

freetext[]

references[]

seealso[
{help Collin.ado} (installed) A contributed program by Philip B. Ender that calculates the VIF for each variable in a set of covariates. 
Manual:    regression diagnostics
On-line:   help for vif

]

END HELP FILE */




