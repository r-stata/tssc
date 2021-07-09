program define rc_spline
version 7
*
*  rc_spline creates variables that can be used for regression models
*  in which the linear predictor f(xvar) is assumed to equal a restricted cubic 
*  spline function of an independent variable xvar.  In these regressions, the user
*  explicitly or implicitly specifies k knots located at xvar = t1, t2, ..., tk.
*  f(xvar) is defined to be a continuous smooth function that is linear before t1,
*  is a piecewise cubic polynomial between adjacent knots, and is linear after
*  tk.  See Harrell (2001) for additional details.
*  
*  Restricted cubic splines are also called natural splines.
*  
*  Input:
*
*   xvar is a continuous covariate that is to be entered into a model using RCPs.
*
*  Options:
*
*   nknots specifies the number of knots.  
*
*   knots specifies the exact location of the knots.  The values of these knots must 
*	  be given in increasing order.
*
*   If both of these options are given they must both specify the same number on knots.
*   When knots is omitted the default knot values are chosen according to Table 2.3 of 
*   Harrell (2001) with the additional restriction that the smallest knot may not be 
*   less than the 5th smallest value of xvar and the largest knot may not be greater than 
*   the 5th largest value of xvar.  The values of the all knots are displayed.  When
*   knots is omitted the number of knots specified by nknots must be between 3 and 7.
*   The default number of knots when neither nknots nor knots is given is 5.
*     
*   Frequency weights are allowed.
*
*  Output:
*
*   rc_spline creates variables called _Sxvar1, _Sxvar2, ..., _Sxvar(k-1), where 
*   "xvar" is the input variable name.  There are always one fewer variables created
*   than there are knots. If the model has k parameters beta0, beta1, ... , beta(k-1)
*   then
*     
*      f(xvar) =beta0 + beta1*_Sxvar1 + beta2*_Sxvar2 + ... + beta(k-1)*_Sxvar(k-1).
*     
*   An important aspect of restricted cubic splines is that the variables _Sxvar1,
*   ... , _Sxvar(k-1) are functions of xvar and the knots only and are not affected by
*   the response variable.  This means that we can use rc_spline to define the 
*   _Sxvar* variables before specifying the response variable or the type of regression
*   model.  
*
*----------------------------------------------------------------
	
	syntax varlist(max=1) [if] [in] [fw] [,NKnots(numlist max=1) KNots(numlist)]
*
*  Preserve the data set.  If this program bombs then we
*  want to restore the data set.  Otherwise we want to keep
*  the data set as modified.
*
   preserve
*
*  Default number of knots (nknots) is 5.
*
	if "`nknots'"!="" {
		local nk `nknots'
	} 
	else {
		local nk=5
	}
*
*  If knots is specified then count the number of
*  knots in the list.
*
  if "`knots'"!="" {
		local nc 0
		tokenize "`knots'"
		while "`1'" != "" {
			local nc = `nc' + 1
			local t`nc' "`1'"
			mac shift
		}
	}
*
*  If nknots or knots is specified but not both then
*  set nc and nk to the same value.
*
	if "`nknots'"!="" & "`knots'"=="" {
	  local nc `nk'
	}
	
	if "`nknots'"=="" & "`knots'"!="" {
	  local nk `nc'
	}
	disp as text " number of knots = " as result "`nk'"
*
*  touse=1 if the record is included in this run.  touse=0
*  otherwise.
*
	 tempvar touse	
	 mark `touse' `if' `in'
*
*  If nknots and knots are both specified then the number
*  of knots must be the same as nknots.
*
  if "`nknots'"!="" & "`knots'"!="" {
		if `nc' != `nk' {
			display as error "nknots count must be the same as the number of knots specified"
			err_handler
			exit
		}
  }
*
*  Set a variable so we can return data set to original
*  sort order when we are done.
*
	gen _Order = _n
*
*  If frequency weights are specified then expand the
*  data set as appropriate.
*
	if "`weight'" != "" {
		qui expand `exp'
	}
	
	sort `varlist'
	
	if "`knots'"!="" {
*
*  Execute this clause if the user specified their own knots.
*
		if `nc' < 2 {
			display as error "Restricted cubic splines must have at least 2 knots"
			err_handler
			exit
    }
*
*  Check order of t(i).
*
		local prevt=`t1'
		local j=2
		while `j'<=`nk' {
			if `t`j'' <= `prevt' {
					disp as error "knots must be in increasing order"
					err_handler
					exit
					}
			local prevt=`t`j''
			local j=`j'+1
			}
	}
	else {
*
*  Execute this clause if user is taking the knots as specified
*  in Harrell (2001).
*
		if `nk' == 3 {
			qui centile `varlist' if `touse', centile(10 50 90)
		}
		else if `nk'== 4 {
			qui centile `varlist' if `touse', centile(5 35 65 95)
		}
		else if `nk'== 5 {
			qui centile `varlist' if `touse', centile(5 27.5 50 72.5 95)
		}
		else if `nk'== 6 {
			qui centile `varlist' if `touse', centile(5 23 41 59 77 95)
		}
		else if `nk'== 7 {
			qui centile `varlist' if `touse', centile(2.5 18.33 34.17 50 65.83 81.67 97.5)
		}
		else 	{
			display as error "Restricted cubic splines with `nk' knots not implimented"
			display as error "Number of knots must be between 3 and 7"
			err_handler
			exit
		}
		forvalues i=1 / `nk' {local t`i' = r(c_`i')}
  	if `t1' < `varlist'[5] {	local t1 = `varlist'[5] } 
  	if `t`nk'' > `varlist'[r(N)-4] 	{ local t`nk' = `varlist'[r(N)-4] } 
	}
*
*  Set _Sx1=x.
*
	gen _S`varlist'1=`varlist'
	
*	if `t1' < `varlist'[5] 	local t1 = `varlist'[5] 
*	if `t`nk'' > `varlist'[r(N)-4] 	local t`nk' = `varlist'[r(N)-4] 
	
	local j = 1
	while `j' <= `nk' {
		display as text" value of knot `j' = " as result `t`j'' 
		local j = `j'+1
		}
	
	local km1 = `nk' - 1
	if `t1' >= `t2' | `t`nk'' <= `t`km1''  {
		display as error "Sample size too small for this many knots"
		err_handler
		exit
		}

	local j = 1
	while `j' <= `nk' {
		gen _Xm`j' = `varlist' - `t`j''
		uplus _Xm`j'  _Xm`j'p
		local j = `j'+1
		}

	local j = 1
	while `j' <= `nk' -2 {
		local jp1 = `j' + 1
		gen _S`varlist'`jp1' = (_Xm`j'p^3 - (_Xm`km1'p^3)*(`t`nk''   - `t`j'')/(`t`nk'' - `t`km1'') + (_Xm`nk'p^3  )*(`t`km1'' - `t`j'')/(`t`nk'' - `t`km1'')) / (`t`nk'' - `t1')^2
		local j = `j' + 1
		}
*
*  Return data set to original sort order.
*
	sort _Order
*
*  If frequency weights caused data set to be expanded then
*  this statement will return data set to original number 
*  of records.
*
	qby _Order: keep if _n==1
	
*	list `varlist'  _S`varlist'*
	drop _Order _Xm* _Xm*p
*
*  This is the normal, successful exit so we don't
*  want to restore the data set (we've added variables).
*
  restore, not
	
	
end
program define uplus 
version 7
*
*  This program has a single input variable u and an output variable 
*  uplus as defined below.
*
	args u uplus
	gen `uplus' = `u'
	quietly replace `uplus' = 0 if `u' <= 0
end 
program define err_handler
version 7
*
*  Clean up after an error before returning.
*
  capture restore
	error 498
end 
exit
