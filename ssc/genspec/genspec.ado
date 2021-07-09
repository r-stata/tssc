*! genspec: General to specific algorithm for model selection
*! Version 1.2.2 diciembre 15, 2013 @ 04:35:56
*! Author: Damian C. Clarke
*! Department of Economics
*! The University of Oxford
*! damian.clarke@economics.ox.ac.uk

cap program drop genspec
program genspec, eclass
	vers 11.0
	#delimit ;
	syntax varlist(min=2 fv ts) [if] [in] [pweight fweight aweight iweight]
	[,
	vce(namelist min=1 max=2) 
	xt(name) 
	ts
	NODIAGnostic
	tlimit(real 1.96)
	verbose
	NUMSearch(integer 5)
	NOPARTition
	noserial
	]
	;
	#delimit cr	

	if "`if'"!=""|"`in'"!="" {
		preserve
		qui keep `if' `in'
	}
	
	****************************************************************************
	*** (0) Setup base definitions
	****************************************************************************
	tempvar resid chow group outofsample
	global Fbase
	global modelvars

	if "`xt'"!="" {
		local regtype xtreg
		local unabtype fvunab
	}
	else if "`ts'"!="" {
		local regtype reg
		local unabtype fvunab
	}
	else {
		local regtype reg	
		local unabtype fvunab
	}
	
	if "`xt'"!=""&"`ts'"!="" {
		dis "Cannot specify both time-series and panel model. Select only one."
		exit 111
	}

	local DH "Doornik-Hansen test rejects normality of errors in the GUM."
	local BP "Breusch-Pagan test rejects homoscedasticity of errors in the GUM."
	local RESET "The RESET test rejects linearity of covariates."
	local CHOW "The in-sample Chow test rejects equality of coefficients"
	local CHOWOUT "The out-of-sample Chow test rejects equality of coefficients"
	local ARCH "The test for ARCH components is not rejected."
	local SERIAL "The test for no autocorrelation in panel data is rejected"
	local RE "The LM test for Random Effects is rejected"

	local m2 "Breusch-Pagan test for homoscedasticity of errors not rejected."
	local m3 " Doornik-Hansen test for normality of errors not rejected."
	local m4 " yRESET test for misspecification not rejected."
	local m5 " In-sample Chow test for equality of coefficients not rejected."
	local m6 " Continuing analysis."
	local m7 " The presence of (1 and 2 order) ARCH components is rejected."
	local m8 " There does not appear to be autocorrelation in panel data."
	local m9 " The LM test for Random Effects is not rejected."
	local m10 " Out-of-sample Chow test for equality of coefficients not rejected."

	local mspec "Respecify using nodiagnostic if you wish to continue without"
	local ms2 "specification tests. This option should be used with caution"

	local runnumber=0

	fvexpand `varlist'
	local varlist `r(varlist)'
	tokenize `varlist'
	local y `1'
	macro shift
	local x `*'
	local numxvars : list sizeof local(x)


	if (regexm("`varlist'", "([0-9]+)b[.]([a-zA-Z0-9_]+)")) {
		dis as error "This command does not allow the i. operator."
		dis as error "Please re-specify using dummy variables (try tab , gen())"
		error 175
		exit
	}
			
	
	fvunab numx: `x'
	local Nx `: word count `numx''
	qui count
	if `Nx'>round(r(N)/10) & `"`nopartition'"'=="" {
		dis "# of observations is > 10% of sample size. Will not run out-of-sample tests."
		local nopartition yes
	}


	qui count
	local tenpercent=r(N)-round(r(N)/10)
	local observs=r(N)
	if `"`nopartition'"'=="" {
		qui gen `outofsample'=1 in `tenpercent'/`observs'
		qui replace `outofsample'=0 if `outofsample'!=1
	}
	else if `"`nopartition'"'!="" qui gen `outofsample'=0


	****************************************************************************
	*** (1) Test unrestricted model for misspecification
	****************************************************************************
	if "`nodiagnostic'"=="" {
		**************************************************************************
		*** (1a) Cross sectional model
		**************************************************************************
		if "`xt'"==""&"`ts'"=="" {
			local p=0
			local q=0

			qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
			qui predict `resid' if `outofsample'==0, residuals
			qui mvtest normality `resid'
			drop `resid'
			local ++q
		
			if r(p_dh)<0.05 {
				display as error "`DH'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p_dh)>=0.05 {
				local testDH yes
				local pass `m3'
				local ++p
			}

			qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
			qui estat ovtest
			local ++q

			if r(p)<0.05 {
				display as error "`RESET'"
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p)>=0.05 {
				local testRESET yes
				local pass `pass' `m4'
				local ++p
			}

			if "`vce'"=="" {
				qui estat hettest
				local ++q

				if r(p)<0.05 {
					display as error "`BP'" 
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p)>=0.05 {
					local testBP yes
					local pass `pass' `m2'
					local ++p
				}
			}

			qui gen `chow'=rnormal()
			sort `chow'
			qui count	if `outofsample'==0
			local halfsample=round(r(N)/2)
			qui gen `group'=1 in 1/`halfsample'
			qui replace `group'=2 if `group'!=1&`outofsample'==0
			cap qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
			if _rc!=0 {
				dis as error "In sample Chow test failed"
				dis as error "Make sure to specify ts or xt if not cross-sectional data"
				exit 5
			}
			local rss_pooled=e(rss)
			qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
			local rss_1=e(rss)
			local n_1=e(N)
			qui `regtype' `y' `x' if `group'==2  [`weight' `exp'], vce(`vce')
			local rss_2=e(rss)
			local n_2=e(N)
			local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
			local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
			local chowstat=`num_chowstat'/`den_chowstat'
			local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
			local ++q
			if `FChow'<0.05 {
				display as error "`CHOW'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p)>=0.05 {
				local testCHOW yes
				local pass `pass' `m5'
				local ++p
			}

			if `"`nopartition'"'=="" {
				cap qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
				if _rc!=0 {
					dis as error "Out-of-sample Chow test failed"
					dis as error "Make sure to specify ts or xt if not cross-sectional data"
					exit 5
				}
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				local ++q
				if `FChow'<0.05 {
					display as error "`CHOWOUT'" 
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p)>=0.05 {
					local testCHOWOUT yes
					local pass `pass' `m10'
					local ++p
				}
			}

			local fails=`q'-`p'
			local m1 "The GUM fails `fails' of `q' misspecification tests. "
			display in green "{p} `m1' `pass'"
			if `fails'>= 2 {
				dis "This GUM performs poorly. Care should be taken in interpretation."
			}
			display ""
		}

		**************************************************************************
		*** (1b) panel model
		**************************************************************************
		if "`xt'"!="" {
			local p=0
			local q=0
			qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
			qui predict `resid' if `outofsample'==0, e
			qui mvtest normality `resid'
			drop `resid'
			local ++q
		
			if r(p_dh)<0.05 {
				display as error "`DH'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p_dh)>=0.05 {
				local testDH yes
				local pass `m3'
				local ++p
			}

			if "`noserial'"=="" {
				cap which xtserial
				if _rc!=0 {
					local e1 "Use of panel data and diagnostic tests requires the"
					local e2 "user-written package xtserial.  Please install by typing:"
					dis "`e1' `e2'"
					dis "net sj 3-2 st0039"
					dis "net install st0039"
					dis "or respecify with the nodiagnostic option."
					exit 111
				}

				cap xtserial `y' `x' if `outofsample'==0
				if _rc!=0&_rc==101 {
					local e1 "serial correlation tests with panel data do not allow factor"
					local e2 "factor variables and time-series operators.  Either respecify"
					local e3 "without these options, or use the noserial option"
					dis 
				}
				else if _rc!=0&_rc!=101 {
					qui xtserial `y' `x' if `outofsample'==0
				}
				else if _rc==0{
					local ++q
					if r(p)<0.05 {
						display as error "`SERIAL'" 
						display as error "{p} `mspec' `ms2'."
						display as error ""
					}
					else if r(p_dh)>=0.05 {
						local testSERIAL yes
						local pass `m8'
						local ++p
					}
				}
			}		

			if "`xt'"=="re" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				qui xttest0
				local ++q
				if r(p)<0.05 {
					display as error "`RE'" 
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p_dh)>=0.05 {
					local testRE yes
					local pass `m9'
					local ++p
				}
			}

			qui count	if `outofsample'==0
			local halfsample=round(r(N)/2)
			qui gen `group'=1 in 1/`halfsample'
			qui replace `group'=2 if `group'!=1&`outofsample'==0
			qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
			local rss_pooled=e(rss)
			qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce') `xt'
			local rss_1=e(rss)
			local n_1=e(N)
			qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce') `xt'
			local rss_2=e(rss)
			local n_2=e(N)
			local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
			local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
			local chowstat=`num_chowstat'/`den_chowstat'
			local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
			local ++q
			if `FChow'<0.05 {
				display as error "`CHOW'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p)>=0.05 {
				local testCHOW yes
				local pass `pass' `m5'
				local ++p
			}

			if `"`nopartition'"'=="" {
				qui `regtype' `y' `x' [`weight' `exp'], vce(`vce') `xt'
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce') `xt'
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				local ++q
				if `FChow'<0.05 {
					display as error "`CHOWOUT'"
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p)>=0.05 {
					local testCHOWOUT yes
					local pass `pass' `m10'
					local ++p
				}
			}

			local fails=`q'-`p'
			local m1 "The GUM fails `fails' of `q' misspecification tests. "
			display in green "{p} `m1' `pass'"
			if `fails'>= 2 {
				dis "This GUM performs poorly. Care should be taken in interpretation."
			}
			display ""
		}

		**************************************************************************
		*** (1c) time-series model
		**************************************************************************
		if "`ts'"!="" {	
			local p=0
			local q=0

			qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
			qui predict `resid' if `outofsample'==0, residuals
			qui mvtest normality `resid'
			local ++q
		
			if r(p_dh)<0.05 {
				display as error "`DH'" 
				display as error "{p}`mspec' `ms2'."
				display as error ""
			}
			else if r(p_dh)>=0.05 {
				local testDH yes
				local pass `m3'
				local ++p
			}

			tempvar resid_sq
			qui gen `resid_sq'=`resid'^2 if `outofsample'==0
			qui reg `resid_sq' l.`resid_sq' l2.`resid_sq'
			qui test l.`resid_sq' l2.`resid_sq'
			drop `resid' `resid_sq'
			local ++q

			if r(p)<0.05 {
				display as error "`ARCH'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p)>=0.05 {
				local testARCH yes
				local pass `pass' `m7'
				local ++p
			}


			if "`vce'"=="" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				qui estat hettest
				local ++q

				if r(p)<0.05 {
					display as error "`BP'" 
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p)>=0.05 {
					local testBP yes
					local pass `pass' `m2'
					local ++p
				}
			}

			qui count	if `outofsample'==0
			local halfsample=round(r(N)/2)
			qui gen `group'=1 in 1/`halfsample'
			qui replace `group'=2 if `group'!=1&`outofsample'==0
			cap qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
			local rss_pooled=e(rss)
			qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
			local rss_1=e(rss)
			local n_1=e(N)
			qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce')
			local rss_2=e(rss)
			local n_2=e(N)
			local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
			local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
			local chowstat=`num_chowstat'/`den_chowstat'
			local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
			local ++q
			if `FChow'<0.05 {
				display as error "`CHOW'" 
				display as error "{p} `mspec' `ms2'."
				display as error ""
			}
			else if r(p)>=0.05 {
				local testCHOW yes
				local pass `pass' `m5'
				local ++p
			}

			if `"`nopartition'"'=="" {
				cap qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				local ++q
				if `FChow'<0.05 {
					display as error "`CHOWOUT'" 
					display as error "{p} `mspec' `ms2'."
					display as error ""
				}
				else if r(p)>=0.05 {
					local testCHOWOUT yes
					local pass `pass' `m10'
					local ++p
				}
			}

			local fails=`q'-`p'
			local m1 "The GUM fails `fails' of `q' misspecification tests. "
			display in green "{p} `m1' `pass'"
			if `q'-`p'>= 2 {
				dis "This GUM performs poorly. Care should be taken in interpretation."
			}
			display ""
		}
	}

	****************************************************************************
	*** (2) Run regression for underlying model
	****************************************************************************		
	foreach searchpath of numlist 1(1)`numsearch' {
		qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
		global Fbase=e(F)
		qui dis "the base F is" $Fbase
		local next= `searchpath'+1
		
		**************************************************************************
		*** (3) Sort by t-stat, remove least explanatory variable from varlist
		**************************************************************************
		cap mata: tsort(st_matrix("e(b)"), st_matrix("e(V)"), `searchpath')
		if _rc==3202|_rc==3201 {
			dis as error "Not enough variables to run `numsearch' independent searches"
			dis as error "Respecify with fewer search paths or an alternative GUM."
			exit 3201
		}
		local num e(var)
		local t = e(t)
		if `"`verbose'"'!="" {
			dis in green "eliminating ```num''' with t-stat of `t'"
		}

		tokenize `varlist'  // find lowest t-value variable
		macro shift
		local remove ```num'''
		
		tokenize `varlist'  // remove lowest t-value variable
		macro shift

		cap `unabtype' varlist : `varlist'
		if _rc!=0 {
			dis as error "factor variables and time-series operators not allowed"
			dis as error "Make sure to specify ts or xt if not cross-sectional data"
			exit 101
		}
		fvexpand `varlist'
		local varlist `r(varlist)'		
		`unabtype' exclude : `remove' `y'
		fvexpand `exclude'
		local exclude `r(varlist)'
		qui local newvarlist : list varlist - exclude
		fvexpand `newvarlist'
		local newvarlist `r(varlist)'
		
		**************************************************************************
		*** (3a) Tests
		**************************************************************************
		local results=0		
		qui `regtype' `y' `newvarlist' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
		if e(F)>$Fbase {
			qui dis "New F improves on GUM.  Keep going"
		}
		else if e(F)<$Fbase {
			qui dis as error "This model does not improve the F-statistic"
			local ++results
		}

		**************************************************************************
		*** (3ai) Cross section
		**************************************************************************
		if "`xt'"==""&"`ts'"=="" {
			if `"`testBP'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				qui estat hettest
				local BPresult=r(p)
				if `BPresult'<0.05 local ++results
			}
			if `"`testRESET'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				qui estat ovtest
				local RESETresult=r(p)
				if `RESETresult'<0.05 local ++results
			}
			if `"`testDH'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				tempvar resid
				qui predict `resid' if `outofsample'==0, residuals
				qui mvtest normality `resid'
				drop `resid'
				local DHresult=r(p_dh)
				if `DHresult'<0.05 local ++results
			}
			if `"`testCHOW'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
			if `"`testCHOWOUT'"'=="yes" {
				qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
		}
		
		**************************************************************************
		*** (3aii) Panel
		**************************************************************************
		if "`xt'"!="" {
			if `"`testDH'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				tempvar resid
				qui predict `resid' if `outofsample'==0, e
				qui mvtest normality `resid'
				drop `resid'
				local DHresult=r(p_dh)
				if `DHresult'<0.05 local ++results
			}
			if `"`testCHOW'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce') `xt'
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce') `xt'
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
			if `"`testCHOWOUT'"'=="yes" {
				qui `regtype' `y' `x' [`weight' `exp'], vce(`vce') `xt'
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce') `xt'
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
			if `"`testSERIAL'"'=="yes" {
				qui xtserial `y' `x' if `outofsample'==0
				local SERIALresult=r(p)
				if `SERIALresult'<0.05 local ++results
			}
			if `"`testRE'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
				qui xttest0
				local REresult=r(p)
				if `REresult'<0.05 local ++results
			}
		}
		
		**************************************************************************
		*** (3aiii) Time series
		**************************************************************************
		if "`ts'"!="" {
			if `"`testBP'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				qui estat hettest
				local BPresult=r(p)
				if `BPresult'<0.05 local ++results
			}
			if `"`testRESET'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				qui estat ovtest
				local RESETresult=r(p)
				if `RESETresult'<0.05 local ++results
			}
			if `"`testDH'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				tempvar resid
				qui predict `resid' if `outofsample'==0, residuals
				qui mvtest normality `resid'
				drop `resid'
				local DHresult=r(p_dh)
				if `DHresult'<0.05 local ++results
			}
			if `"`testARCH'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				tempvar resid resid_sq
				qui predict `resid' if `outofsample'==0, residuals
				qui gen `resid_sq'=`resid'^2
				qui reg `resid_sq' l.`resid_sq' l2.`resid_sq'
				qui test l.`resid_sq' l2.`resid_sq'
				drop `resid' `resid_sq'
				local ARCHresult=r(p)
				if `ARCHresult'<0.05 local ++results
			}

			if `"`testCHOW'"'=="yes" {
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
			if `"`testCHOWOUT'"'=="yes" {
				qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
				local rss_pooled=e(rss)
				qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
				local rss_1=e(rss)
				local n_1=e(N)
				qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
				local rss_2=e(rss)
				local n_2=e(N)
				local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
				local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
				local chowstat=`num_chowstat'/`den_chowstat'
				local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
				if `FChow'<0.05 local ++results
			}
		}

		**************************************************************************
		*** (3b) Assess whether passing tests
		**************************************************************************
		if `results'>0 {
			display in green "This path does not pass misspecification tests. Moving on"
			continue, break
		}

		****************************************************************************
		*** (4) Loop until all variables are significant
		****************************************************************************
		qui `regtype' `y' `newvarlist' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
		cap mata: tsort(st_matrix("e(b)"), st_matrix("e(V)"), 1)
		if _rc==3202|_rc==3201 {
			dis as error "Not enough variables to run `numsearch' independent searches"
			dis as error "Respecify with fewer search paths or an alternative GUM."
			exit 3201
		}

		local num e(var)
		local t = e(t)
		if `"`verbose'"'!="" {
			dis in green "eliminating ```num''' with t-stat of `t'"
		}

		qui dis "`newvarlist'"

		local trial 1
		while `t'<`tlimit' {
			tokenize `newvarlist'
			local remove_try ```num''' `remove'
			`unabtype' varlist : `varlist'
			fvexpand `varlist'
			local varlist `r(varlist)'
			`unabtype' exclude : `remove_try' `y'
			fvexpand `exclude'
			local exclude `r(varlist)'
			local newvarlist_try : list varlist - exclude			
			fvexpand `newvarlist_try'
			local newvarlist_try `r(varlist)'

			qui `regtype' `y' `newvarlist_try' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
			
			**************************************************************************
			*** (4a) Tests
			**************************************************************************
			local results = 0

			if e(F)<$Fbase {
				qui dis as error "This model does not improve the F-statistic, reverting"
				local ++results
			}
			**************************************************************************
			*** (4ai) Cross section
			**************************************************************************
			if "`xt'"==""&"`ts'"=="" {
				if `"`testBP'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					qui estat hettest
					local BPresult=r(p)
					if `BPresult'<0.05 local ++results
					if `BPresult'<0.05&"`verbose'"!="" dis "fail BP"
				}
				if `"`testRESET'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					qui estat ovtest
					local RESETresult=r(p)
					if `RESETresult'<0.05 local ++results
					if `RESETresult'<0.05&"`verbose'"!="" dis "fail RESET"					
				}
				if `"`testDH'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					tempvar resid
					qui predict `resid' if `outofsample'==0, residuals
					qui mvtest normality `resid'
					drop `resid'
					local DHresult=r(p_dh)
					if `DHresult'<0.05 local ++results
					if `DHresult'<0.05&"`verbose'"!="" dis "fail DH"					
				}
				if `"`testCHOW'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce')
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local CHOWresult Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `CHOWresult'<0.05 local ++results
					if `CHOWresult'<0.05&"`verbose'"!="" dis "fail DH"					
				}
				if `"`testCHOWOUT'"'=="yes" {
					qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `FChow'<0.05 local ++results
				}
			}

			**************************************************************************
			*** (4aii) Panel
			**************************************************************************
			if "`xt'"!="" {
				if `"`testDH'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
					tempvar resid
					qui predict `resid' if `outofsample'==0, e
					qui mvtest normality `resid'
					drop `resid'
					local DHresult=r(p_dh)
					if `DHresult'<0.05 local ++results
				}
				if `"`testCHOW'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce') `xt'
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce') `xt'
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `FChow'<0.05 local ++results
				}
				if `"`testCHOWOUT'"'=="yes" {
					qui `regtype' `y' `x' [`weight' `exp'], vce(`vce') `xt'
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce') `xt'
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `FChow'<0.05 local ++results
				}
				if `"`testSERIAL'"'=="yes" {
					qui xtserial `y' `x' if `outofsample'==0
					local SERIALresult=r(p)
					if `SERIALresult'<0.05 local ++results
				}
				if `"`testRE'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
					qui xttest0
					local REresult=r(p)
					if `REresult'<0.05 local ++results
				}
			}

			**************************************************************************
			*** (4aiii) Time series
			**************************************************************************
			if "`ts'"!="" {
				if `"`testBP'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					qui estat hettest
					local BPresult=r(p)
					if `BPresult'<0.05 local ++results
				}
				if `"`testRESET'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					qui estat ovtest
					local RESETresult=r(p)
					if `RESETresult'<0.05 local ++results
				}
				if `"`testDH'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					tempvar resid
					qui predict `resid' if `outofsample'==0, residuals
					qui mvtest normality `resid'
					drop `resid'
					local DHresult=r(p_dh)
					if `DHresult'<0.05 local ++results
				}
				if `"`testARCH'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					tempvar resid resid_sq
					qui predict `resid' if `outofsample'==0, residuals
					qui gen `resid_sq'=`resid'^2
					qui reg `resid_sq' l.`resid_sq' l2.`resid_sq'
					qui test l.`resid_sq' l2.`resid_sq'
					drop `resid' `resid_sq'
					local ARCHresult=r(p)
					if `ARCHresult'<0.05 local ++results
				}

				if `"`testCHOW'"'=="yes" {
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `group'==1 [`weight' `exp'], vce(`vce')
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `group'==2 [`weight' `exp'], vce(`vce')
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `FChow'<0.05 local ++results
				}
				if `"`testCHOWOUT'"'=="yes" {
					qui `regtype' `y' `x' [`weight' `exp'], vce(`vce')
					local rss_pooled=e(rss)
					qui `regtype' `y' `x' if `outofsample'==0 [`weight' `exp'], vce(`vce')
					local rss_1=e(rss)
					local n_1=e(N)
					qui `regtype' `y' `x' if `outofsample'==1 [`weight' `exp'], vce(`vce')
					local rss_2=e(rss)
					local n_2=e(N)
					local num_chowstat=((`rss_pooled'-(`rss_1'+`rss_2'))/(`numxvars'+1))
					local den_chowstat=(`rss_1'+`rss_2')/(`n_1'+`n_2'+2*(`numxvars'+1))
					local chowstat=`num_chowstat'/`den_chowstat'
					local FChow Ftail((`numxvars'+1),(`n_1'+`n_2'+2*(`numxvars'+1)),`chowstat')
					if `FChow'<0.05 local ++results
				}
			}
	
			**************************************************************************
			*** (4b) Assess tests
			**************************************************************************
			if `results'==0 {
				local trial 1
				local remove `remove_try'
				local newvarlist `newvarlist_try'
				tokenize `newvarlist'
			}
			if `results'>0 {
				local ++trial
				if "`verbose'"!="" dis in green `trial'
			}

			**************************************************************************
			*** (4c) Move on, either eliminating variable, or reverting and retrying
			**************************************************************************
			qui `regtype' `y' `newvarlist' if `outofsample'==0 [`weight' `exp'], vce(`vce') `xt'
			cap mata: tsort(st_matrix("e(b)"), st_matrix("e(V)"), `trial')
			if _rc==3202|_rc==3201 {
				dis as error "No variables are found to be significant at given level"
				dis as error "Respecify using a lower t-stat or an alternative GUM."
				exit 3202
			}
			local num e(var)
			local t = e(t)
			if `"`verbose'"'!="" {
				dis in green "eliminating ```num''' with t-stat of `t'"
			}
		}
		

		if "`verbose'"!="" {
			dis in green "Results for search path `searchpath':"
			dis in yellow "remaining variables are: " in green "`newvarlist'"
		}

		****************************************************************************
		*** (5) Determine if potential terminal model is terminal (full sample)
		****************************************************************************
		qui `regtype' `y' `newvarlist' [`weight' `exp'], vce(`vce') `xt'
		local F1=e(F)
		if `"`nopartition'"'=="" {
			local potentialvarlist
			foreach var of local newvarlist {
				if abs(_b[`var']/_se[`var'])>`tlimit' {
					local potentialvarlist `potentialvarlist' `var'
				}
			}
		
			qui `regtype' `y' `potentialvarlist' [`weight' `exp'], vce(`vce') `xt'
			local F2=e(F)
			if `F2'>`F1' local newvarlist `potentialvarlist'
		}

		****************************************************************************
		*** (6) Determine model fit
		****************************************************************************
		if "`xt'"!="" {
			local ++runnumber
			if `runnumber'==1 {
				local runningvars `newvarlist'
			}
			if `runnumber'!=1 {
				foreach item1 of local newvarlist {
					local count=0
					foreach item2 of local runningvars {
						if `item1'==`item2' local ++count
					}
					if `count'==0 local runningvars `runningvars' `item1'
				}
			}
			global modelvars `runningvars'
		}
		else {
			local ++runnumber
			if `runnumber'==1 {
				global BICbest=.
				global BICbname Model
			}
			qui estat ic
			matrix BIC=r(S)
			local BIC=BIC[1,6]
			if `BIC'<$BICbest {
				global BICbest=`BIC'
				global BICbname Model`searchpath'
				global modelvars `newvarlist'
			}
		}
	}
	****************************************************************************
	*** (6) Output
	****************************************************************************
	if "`verbose'"!=""&"`xt'"=="" { 
		dis in green "Bayesian Information Criteria of best model ($BICbname) is $BICbest"
	}
	dis "Specific Model:"
	`regtype' `y' $modelvars [`weight' `exp'], vce(`vce') `xt'
	if "`xt'"=="" qui ereturn scalar fit=$BICbest 
	qui ereturn local genspec $modelvars
	if "`if'"!=""|"`in'"!="" restore
end


********************************************************************************
*** (X) Mata code for selecting irrelevant variables
********************************************************************************
cap mata: mata drop tsort()
mata:
void tsort(real matrix B, real matrix V, real scalar num) {
	real vector se
	real vector t
	real vector tsort
	real vector tnum	
	real matrix X
	real scalar dimn
	real vector a
	
	se = diagonal(V)
	se = sqrt(se)
	t=abs(B':/se)
	dimn = length(t)
	if (dimn==1) {
		_error(3202)
	}
	
	t=t[|1\ dimn-1|]
	a = 1::dimn-1
	X = (t, a)
	tsort = sort(X, 1)
	tnum = tsort[num,1]
	tvar = tsort[num,2]
	st_numscalar("e(t)", tnum)
	st_numscalar("e(var)", tvar)
}
end
