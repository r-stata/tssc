capture program drop next
program define next
version 13
#delimit ;
	syntax varlist(min=2 max=2) [if] [in], 
		[
			Regtype(string)
			Threshold(real 0)
			data_min(integer 5)
			p1(integer 0) 
			p2(integer 5) 
			base(real 1000) 
			mspe_min(integer 5) 
			CONfidence(real 80)
			bin_left(integer 100)
			bin_right(integer 100)
			details
		];
#delimit cr
	local Y: word 1 of `varlist'
	local X: word 2 of `varlist'
	local isreg = "`regtype'" ==""
	local regtype = cond(`isreg',"regress", "`regtype'")
	* Y is the outcome
	* X is the assignment variable, i.e., the score	
	* R is the type of regression ("regress" "logit" or "probit")
	* T is the threshold
		* Note: when X=T, it is assumed that X is on the right hand side of threshold
	* DATA_MIN is the minimum number of data points that must be used to predict the next value, and it should be in the range of 1 to min(number of distinct values of X on left of threshold-1, number of distinct values of X on right of threshold-1).
		* Note that if data_min>1 then random walk specification is skipped.
	* P1 is the minimum order of the polynomial
	* P2 is the maximum order of the polynomial
	* BASE is the base weight for the weighting scheme and should lie in the interval of 1 (uniform weight) to infinity.
	* MSPE_MIN is the minimum number of MSPEs that are allowed to be included in a weighted average of MSPE.  Must be >=2.
	* CONFIDENCE is the confidence interval and can be between 0 and 100
	* BIN_LEFT and BIN_RIGHT is the number of bins used set by the user. 
		* If BIN_LEFT and BIN_RIGHT is set by the user, then BIN_LEFT and BIN_RIGHT on each side of discontinuity is set equal to Min(user set bin size, Min(matsize,maxvar)/(number of specifications used)-2).
		* If BIN_LEFT and BIN_RIGHT is not set by the user, then BIN_LEFT and BIN_RIGHT on each side of discontinuity is set equal to Min(100, number of distinct values on that side of the discontinuity).
	display "OUTCOME = `Y'"
	display "ASSIGNMENT VARIABLE = `X'"
	display "THRESHOLD = `threshold'"
	display "MINIMUM NUMBER OF DATA POINTS INCLUDED TO PREDICT NEXT VALUE SET BY USER (or default) = " `data_min'
	display "MINIMUM ORDER OF THE POLYNOMIAL SET BY USER (or default) = " `p1'
	display "MAXIMUM ORDER OF THE POLYNOMIAL SET BY USER (or default) = " `p2'
	display "BASE WEIGHT SET BY USER (or default) = " `base'
	display "MINIMUM NUMBER OF MSPEs PERMITTED IN WEIGHTED AVERAGE (or default) = " `mspe_min'
	display "CONFIDENCE INTERVAL SET BY USER (or default) = `confidence' %"
	display "NUMBER OF BINS ON LEFT SET BY USER (or default) = " `bin_left'
	display "NUMBER OF BINS ON RIGHT SET BY USER (or default) = " `bin_right'
	* STOP THE ANALYSIS IF THERE ARE ERRORS IN THE DESIGNATED POLYNOMIALS
	if `p2'<`p1' {
		display as error "Error: Maximum order of the polynomial should be >= Minimum order of the polynomial"
		display as error "Change the value(s) before continuing"
	}
	else {

	* STOP THE ANALYSIS IF THE BASE WEIGHT IS INAPPROPRIATE
	if `base'<1 {
		display as error "Base weight must be >= 1"
		display as error "Change the value(s) before continuing"
	}
	else {

	* STOP THE ANALYSIS IF THE MSPE_MIN IS INAPPROPRIATE
	if `mspe_min'<2 {
		display as error "MSPE_MIN must be >= 2"
		display as error "Change the value(s) before continuing"
	}
	else {
	
	* STOP THE ANALYSIS IF THE CONFIDENCE INTERVAL IS INAPPROPRIATE
	if (`confidence'>100 | `confidence' <0) {
		display as error "Confidence interval must be between 0 and 100"
		display as error "Change the value(s) before continuing"
	}
	else {
	
	* STOP THE ANALYSIS IF THE REGRESSION TYPE IS MISPECIFIED
	if "`regtype'"~="regress" & "`regtype'"~="probit" & "`regtype'"~="logit" {
		display as error "Regresion type must be regress, probit or logit" 
		display as error "Change the value(s) before continuing"
	}	
	else {
	quietly query memory
	if "`bin_left'"~="" {
		quietly query memory
		if `bin_left'>min(`r(matsize)',`r(maxvar)')/(`p2'-`p1'+1)-2 {
			display "Bin size on left is forced to be smaller than requested -- if this is not due to having a smaller number of distinct values of `X' on the left side, you might want to increase your matsize and/or maxvar"
		}
		local bin_left=min(`bin_left',min(`r(matsize)',`r(maxvar)')/(`p2'-`p1'+1)-2)
	}
	if "`bin_right'"~="" {
		quietly query memory
		if `bin_right'>min(`r(matsize)',`r(maxvar)')/(`p2'-`p1'+1)-2 {
			display "Bin size on right is forced to be smaller than requested -- if this is not due to having a smaller number of distinct values of `X' on the right side, you might want to increase your matsize and/or maxvar"
		}
		local bin_right=min(`bin_right',min(`r(matsize)',`r(maxvar)')/(`p2'-`p1'+1)-2)
	}
	local LEFT=1
	while `LEFT'>=0 {
		preserve
		quietly keep if `Y'~=. & `X'~=.
		* Collapse data by values of X (the score, or assignment variable)
		* Preserve number of observations with the same value of X so as to allow weighted regressions.
		generate weight=1
		collapse (sum) weight (mean) `Y', by(`X')
		quietly count if `X'<`threshold'
		if "`bin_left'"=="" {
			local bin_left=min(100,`r(N)')
		}
		if `r(N)'>`bin_left' {
			quietly sum `X' if `X'<`threshold'
			quietly gen temp1=int(`bin_left'*(`X'-`r(min)')/(`threshold'-`r(min)')) if `X'<`threshold'
			egen temp2=mean(`X'), by(temp1)
			egen temp3=mean(`Y'), by(temp1)
			quietly replace `X'=temp2 if `X'<`threshold'
			quietly replace `Y'=temp3 if `X'<`threshold'
			collapse (sum) weight (mean) `Y', by(`X')
			if `LEFT'==1 {
				display "NUMBER OF BINS ON THE LEFT SET TO " `bin_left'
			}
		}
		quietly count if `X'>=`threshold'
		if "`bin_right'"=="" {
			local bin_right=min(100,`r(N)')
		}
		if `r(N)'>`bin_right' {
			quietly sum `X' if `X'>=`threshold'
			quietly gen temp1=min(`bin_right', 1+int(`bin_right'*(`X'-`threshold')/(`r(max)'-`threshold'))) if `X'>=`threshold'
			egen temp2=mean(`X'), by(temp1)
			egen temp3=mean(`Y'), by(temp1)
			quietly replace `X'=temp2 if `X'>=`threshold'
			quietly replace `Y'=temp3 if `X'>=`threshold'
			collapse (sum) weight (mean) `Y', by(`X')
			if `LEFT'==1 {
				display "NUMBER OF BINS ON THE RIGHT SET TO " `bin_right'
			}
		}
		if `LEFT'==1 {
			quietly count if `X'<`threshold'
			display "NUMBER OF DISTINCT VALUES OF `X' ON THE LEFT = " `r(N)'
			local DISTINCT_LEFT=`r(N)'
			quietly count if `X'>=`threshold'
			display "NUMBER OF DISTINCT VALUES OF `X' ON THE RIGHT = " `r(N)'
			local DISTINCT_RIGHT=`r(N)'
			quietly keep if `X'<`threshold'
			local T_ALT=`threshold'
		}
		if `data_min'<1 | `data_min'>min(`DISTINCT_LEFT'-1, `DISTINCT_RIGHT'-1) {
			display as error "Error: DATA_MIN should be >=1 and" 
			display as error "<=min(# distinct values of X on left of threshold - 1, # distinct values of X on right of threshold-1)"
			display as error "Change the value of DATA_MIN before continuing"
			local LEFT=-1
			restore
		}
		else {
			if `LEFT'==0 {
				quietly keep if `X'>=`threshold'
				* invert X so that it treats the process as if it were reading from right to left
				quietly sum `X'
				quietly replace `X'=`r(max)'-`X'
				local T_ALT=`r(max)'-`threshold'
			}
			* Sort the data from lowest to highest X
			sort `X'
			quietly count
			local N=`r(N)'
			forvalues Q=`p1'/`p2' {
				local j=`N'-1
				while `j'>0 {
					quietly gen poly_`Q'_prior_`j'=.
					local j=`j'-1
				}
			}
			aorder
			mkmat `X' weight poly*, matrix(A)
			drop poly*
			* Generate the polynomial terms (if relevant)
			if `p2'>0 {
				forvalues Q=1/`p2' {
					gen double `X'`Q'=`X'^`Q'
				}
			}
			* NOTE: `i' will refer to the observation that we are trying to predict based on prior observations.
			* NOTE: `j' will refer to the prior number of observations that we are using to try to predict observation `i'.
   			* NOTE: `MSPE' is the sum of squared error of the prediction of the next Y.
			local i=1
			if `LEFT'==1 {
				display "Done on the left side after `DISTINCT_LEFT' dots are displayed"
			}
			if `LEFT'==0 {
				display "Done on the right side after `DISTINCT_RIGHT' dots are displayed"
			}
			while `i'<=`N' {
				if `i'>=1+`data_min' {
					local j=`data_min'
					while `j'<=`i'-1 {
						if `p1'==0 {
							* Average of prior observation(s)
							quietly sum `Y' if _n>=`i'-`j' & _n<=`i'-1 [fweight=weight]
							local MSPE=(`Y'[`i']-`r(mean)')^2
							matrix A[`i',2+`j']=`MSPE'
						}
						if `p2'>0 & `j'>=2 {
							* Regression based on prior observations
							local RHS
							local MAXVAR=min(`j'-1,`p2')
							forvalues Q=1/`MAXVAR' {
								local RHS `RHS' `X'`Q'
								if "`regtype'"=="regress" {
									quietly regress `Y' `RHS' if _n>=`i'-`j' & _n<=`i'-1 [fweight=weight]
									quietly predict temp
								}
								else {
									quietly sum `Y' if _n>=`i'-`j' & _n<=`i'-1
									if `r(sd)'==0 {
										gen temp=`r(mean)'
									}
									else {
										quietly count if `Y'>0 & `Y'<1 & _n>=`i'-`j' & _n<=`i'-1 
										if `r(N)' > 0 {
											quietly glm `Y' `RHS' if _n>=`i'-`j' & _n<=`i'-1 [fweight=weight], link(`regtype') family(binomial) vce(robust) asis iterate(100) 
										}
										else {
											quietly `regtype' `Y' `RHS' if _n>=`i'-`j' & _n<=`i'-1 [fweight=weight], asis iterate(100)  
										}
										quietly capture predict temp
										capture confirm variable temp
										if _rc {
											quietly gen temp=.									
										}
										quietly count if temp==.
										if `r(N)'>0 {
											if "`regtype'"=="logit" {
												quietly capture predictnl temp_alt = exp(xb())/(1+exp(xb()))
											}
											if "`regtype'"=="probit" {
												quietly capture predictnl temp_alt = normal(xb())
											}
											capture confirm variable temp_alt
											if _rc {
												quietly gen temp_alt=.									
											}
											quietly replace temp=temp_alt if temp==.
										}
									}
								}
								local MSPE=(`Y'[`i']-temp[`i'])^2
								drop temp*
								if `p1'==0 {
									matrix A[`i',2+`j'+`Q'*(`N'-1)]=`MSPE'
								}
								else {
									matrix A[`i',2+`j'+(`Q'-1)*(`N'-1)]=`MSPE'
								}
							}
						}
						local j=`j'+1
					}
				}
				nois _dots `i' 0
				local i=`i'+1
			}
 			display ""
			clear
			quietly svmat A, names(col)
			local BEST_POLY=`p2'
			local BEST_PRIOR=`N'-1
			local MAXPRIOR=`N'-1
			local FIRST=0
			quietly sum `X'
			gen double weight_temp=weight*(`base'^((`X'-`r(min)')/(`r(max)'-`r(min)')))
			forvalues POLY=`p2'(-1)`p1' {
				forvalues PRIOR=`MAXPRIOR'(-1)`data_min' {
					quietly sum poly_`POLY'_prior_`PRIOR' [weight=weight_temp]
					if `r(N)'>0 {
						* compute sum of squared weights -- this is used to estimate the standard error of the weighted average MSPE
						local denominator=0
						if `LEFT'==1 {
							local start=`DISTINCT_LEFT'-`r(N)'+1
							forvalues q=`start'(1)`DISTINCT_LEFT' {
								local denominator=`denominator'+`base'^((`q'-(`POLY'+1))/(`DISTINCT_LEFT'-(`POLY'+1)))
							}
						}
						else {
							local start=`DISTINCT_RIGHT'-`r(N)'+1
							forvalues q=`start'(1)`DISTINCT_RIGHT' {
								local denominator=`denominator'+`base'^((`q'-(`POLY'+1))/(`DISTINCT_RIGHT'-(`POLY'+1)))
							}
						}
						local sumofsqweights=0
						if `LEFT'==1 {
							local start=`DISTINCT_LEFT'-`r(N)'+1
							forvalues q=`start'(1)`DISTINCT_LEFT' {
								local sumofsqweights=`sumofsqweights'+((`base'^((`q'-(`POLY'+1))/(`DISTINCT_LEFT'-(`POLY'+1))))/`denominator')^2
							}
						}
						else {
							local start=`DISTINCT_RIGHT'-`r(N)'+1
							forvalues q=`start'(1)`DISTINCT_RIGHT' {
								local sumofsqweights=`sumofsqweights'+((`base'^((`q'-(`POLY'+1))/(`DISTINCT_RIGHT'-(`POLY'+1))))/`denominator')^2
							}
						}
					}
					if `r(N)'>=`mspe_min' {
						* Compute the upper bound of the confidence interval around the weighted mean MSPE and compare to others.
						local COLUMN_MSPE=`r(mean)'+(invt(`r(N)'-1,1-(1-`confidence'/100)/2))*(`r(Var)'*`sumofsqweights')^0.5
						if `FIRST'==0 {
							local LOWEST_MSPE=`COLUMN_MSPE'
						}
						local FIRST=1
				 		if `COLUMN_MSPE'<=`LOWEST_MSPE' {
							local LOWEST_MSPE=`COLUMN_MSPE'
							local BEST_POLY=`POLY'
							local BEST_PRIOR=`PRIOR'
						}
						if "`details'"~="" {
							display "POLY = `POLY' & PRIOR = `PRIOR' GIVES EST. MSPE (upper bound of confidence interval) = `COLUMN_MSPE'"
							display "BEST SO FAR: POLY = `BEST_POLY' / PRIOR = `BEST_PRIOR'"
						}
					}
					else if `r(N)'>0 {
						* Compute the upper bound of the confidence interval around the weighted mean MSPE, but do not compare to others.
						local COLUMN_MSPE=`r(mean)'+(invt(`r(N)'-1,1-(1-`confidence'/100)/2))*(`r(Var)'*`sumofsqweights')^0.5
						if "`details'"~="" {
							display "POLY = `POLY' & PRIOR = `PRIOR' GIVES EST. MSPE (upper bound of confidence interval) = `COLUMN_MSPE'"
							display "NOT CONSIDERED BY USER REQUEST"
						}
					}
				}
			}
			if `LEFT'==1 {
				local BEST_POLY_LEFT=`BEST_POLY'
				local BEST_PRIOR_LEFT=`BEST_PRIOR'
				* store minimum value of X that is used in generating impact estimate
				restore 
				preserve
				quietly keep if `Y'~=. & `X'~=.
				collapse (mean) `Y', by(`X')
				quietly keep if `X'<`threshold'
				quietly count 
				if "`bin_left'"=="" {
					local bin_left=min(100,`r(N)')
				}
				if `r(N)'>`bin_left' {
					quietly sum `X' 
					quietly gen temp1=int(`bin_left'*(`X'-`r(min)')/(`threshold'-`r(min)')) 
					egen temp2=min(`X'), by(temp1)
					egen temp3=mean(`Y'), by(temp1)
					quietly replace `X'=temp2 
					quietly replace `Y'=temp3 
					collapse (mean) `Y', by(`X')
				}
				sort `X'
				quietly count
				local N=`r(N)'
				quietly sum `X' if _n>=`N'+1-`BEST_PRIOR' & _n<=`N' 
				local MIN_X=`r(min)'
			}
			if `LEFT'==0 {
				* NOW PRODUCE IMPACT ESTIMATE
				* store maximum value of X that is used in generating impact estimate
				restore 
				preserve
				quietly keep if `Y'~=. & `X'~=.
				collapse (mean) `Y', by(`X')
				quietly keep if `X'>=`threshold'
				quietly count 
				if "`bin_right'"=="" {
					local bin_right=min(100,`r(N)')
				}
				if `r(N)'>`bin_right' {
					quietly sum `X' 
					quietly gen temp1=min(`bin_right', 1+int(`bin_right'*(`X'-`threshold')/(`r(max)'-`threshold'))) if `X'>=`threshold'
					egen temp2=max(`X'), by(temp1)
					egen temp3=mean(`Y'), by(temp1)
					quietly replace `X'=temp2 
					quietly replace `Y'=temp3 
					collapse (mean) `Y', by(`X')
				}
				quietly sum `X'
				local MAX_X=`r(max)'
				quietly replace `X'=`r(max)'-`X'
				sort `X'
				quietly count
				local N=`r(N)'
				quietly keep if _n>=`N'+1-`BEST_PRIOR' & _n<=`N' 
				quietly replace `X'=`MAX_X'-`X'
				quietly sum `X' 
				local MAX_X=`r(max)'
				restore
				preserve
				display "**********************************************************************************************************"
				display "THE BEST SPECIFICATION FOR THE LEFT SIDE OF THRESHOLD IS A POLYNOMIAL OF ORDER `BEST_POLY_LEFT' USING THE LAST `BEST_PRIOR_LEFT' OBSERVATIONS (or BINS)"
				display "THE BEST SPECIFICATION FOR THE RIGHT SIDE OF THRESHOLD IS A POLYNOMIAL OF ORDER `BEST_POLY' USING THE LAST `BEST_PRIOR' OBSERVATIONS (or BINS)"
				display "RANGE OF ASSIGNMENT VARIABLE USED IN ESTIMATING LOCAL AVERAGE TREATMENT EFFECT = `MIN_X' TO `MAX_X'"
				display "BELOW IS REGRESSION USING THE OPTIMAL SPECIFICATION AND RANGE OF ASSIGNMENT VARIABLE, WHERE
				display "THE COEFFICIENT ON RIGHT GIVES THE LOCAL AVERAGE TREATMENT EFFECT (i.e. MOVING FROM LEFT TO RIGHT OF THRESHOLD)"
				display "NOTE: ASSIGNMENT VARIABLE HAS BEEN RECODED SO THAT THRESHOLD IS SET AT ZERO (i.e., X reset to X-Threshold)"
				quietly keep if `X'>=`MIN_X' & `X'<=`MAX_X'
				quietly replace `X'=`X'-`threshold'
				quietly gen RIGHT=`X'>=0
				local RHS 
				if `BEST_POLY_LEFT'>=1 {
					forvalues Q=1/`BEST_POLY_LEFT' {
						gen LEFT_POLY`Q'=(1-RIGHT)*(`X'^`Q')
						local RHS `RHS' LEFT_POLY`Q'
					}
				}
				local RHS `RHS' RIGHT
				if `BEST_POLY'>=1 {
					forvalues Q=1/`BEST_POLY' {
						gen RIGHT_POLY`Q'=RIGHT*(`X'^`Q')
						local RHS `RHS' RIGHT_POLY`Q'
					}
				}
				`regtype' `Y' `RHS' 
				if "`regtype'"=="logit" {
					display "COMPUTATION OF MARGINAL EFFECT FOR LOGIT REGRESSION:"
					display "Predicted likelihood that Y=1 just to left of threshold = " exp(_b[_cons])/(1+exp(_b[_cons]))
					display "Predicted likelihood that Y=1 just to right of threshold = " exp(_b[_cons]+_b[RIGHT])/(1+exp(_b[_cons]+_b[RIGHT]))
					display "Local Average Treatment Effect (i.e., Change in predicted likelihood that Y=1 at the theshold) = " (exp(_b[_cons]+_b[RIGHT])/(1+exp(_b[_cons]+_b[RIGHT]))) - (exp(_b[_cons])/(1+exp(_b[_cons])))
					quietly predictnl margeff = (exp(_b[_cons]+_b[RIGHT])/(1+exp(_b[_cons]+_b[RIGHT]))) - (exp(_b[_cons])/(1+exp(_b[_cons]))), se(margeff_se)
					quietly sum margeff_se
					display "Standard error of Local Average Treatment Effect = " `r(mean)'					
				}
				if "`regtype'"=="probit" {
					"COMPUTATION OF MARGINAL EFFECT FOR PROBIT REGRESSION:"
					display "Predicted likelihood that Y=1 just to left of threshold = " normal(_b[_cons])
					display "Predicted likelihood that Y=1 just to right of threshold = " normal(_b[_cons]+_b[RIGHT])
					display "Local Average Treatment Effect (i.e., Change in predicted likelihood that Y=1 at the theshold) = " normal(_b[_cons]+_b[RIGHT]) - normal(_b[_cons])
					quietly predictnl margeff = (normal(_b[_cons]+_b[RIGHT]) - normal(_b[_cons])), se(margeff_se)
					quietly sum margeff_se
					display "Standard error of Local Average Treatment Effect = " `r(mean)'					
				}
			}	
			restore
			local LEFT=`LEFT'-1
		}
	}
	* NOW PRODUCE CORRESPONDING SCATTER/LINE PLOT
	if `data_min'>=1 & `data_min'<=min(`DISTINCT_LEFT'-1, `DISTINCT_RIGHT'-1) {
		preserve
		quietly keep if `Y'~=. & `X'~=.
		generate weight=1
		collapse (sum) weight (mean) `Y', by(`X')
		quietly count if `X'<`threshold'
		if "`bin_left'"=="" {
			local bin_left=min(100,`r(N)')
		}
		if `r(N)'>`bin_left' {
			quietly sum `X' if `X'<`threshold'
			quietly gen temp1=int(`bin_left'*(`X'-`r(min)')/(`threshold'-`r(min)')) if `X'<`threshold'
			egen temp2=mean(`X'), by(temp1)
			egen temp3=mean(`Y'), by(temp1)
			quietly replace `X'=temp2 if `X'<`threshold'
			quietly replace `Y'=temp3 if `X'<`threshold'
			collapse (sum) weight (mean) `Y', by(`X')
		}
		quietly count if `X'>=`threshold'
		if "`bin_right'"=="" {
			local bin_right=min(100,`r(N)')
		}
		if `r(N)'>`bin_right' {
			quietly sum `X' if `X'>=`threshold'
			quietly gen temp1=min(`bin_right', 1+int(`bin_right'*(`X'-`threshold')/(`r(max)'-`threshold'))) if `X'>=`threshold'
			egen temp2=mean(`X'), by(temp1)
			egen temp3=mean(`Y'), by(temp1)
			quietly replace `X'=temp2 if `X'>=`threshold'
			quietly replace `Y'=temp3 if `X'>=`threshold'
			collapse (sum) weight (mean) `Y', by(`X')
		}
		sort `X'
		quietly count
		local N_PLUS=`r(N)'+1000
		quietly count if `X'<`threshold'
		local N=`r(N)'
		if `BEST_POLY_LEFT'==0 {
			quietly sum `Y' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N' [fweight=weight]
			local temp1=`r(mean)'
			quietly set obs `N_PLUS'
			quietly sum `X' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N'
			quietly replace `X'=`r(min)'+(`threshold'-`r(min)')*uniform() if `X'==.
			quietly gen temp1=`temp1' if (_n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N') | `Y'==.
		}
		else {
			quietly set obs `N_PLUS'
			quietly sum `X' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N'
			quietly replace `X'=`r(min)'+(`threshold'-`r(min)')*uniform() if `X'==.
			forvalues Q=1/`BEST_POLY_LEFT' {
				gen double `X'`Q'=`X'^`Q'
			}
			local RHS
			forvalues Q=1/`BEST_POLY_LEFT' {
				local RHS `RHS' `X'`Q'
			}
			if "`regtype'"=="regress" {
				quietly regress `Y' `RHS' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N' [fweight=weight]
				quietly predict temp1 if e(sample) | `Y'==.
			}
			else {
				quietly sum `Y' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N'
				if `r(sd)'==0 {
					gen temp1=`r(mean)' if (_n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N')| `Y'==.
				}
				else {
					quietly count if `Y'>0 & `Y'<1 & _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N'
					if `r(N)' > 0 {
						quietly glm `Y' `RHS' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N' [fweight=weight], link(`regtype') family(binomial) vce(robust) asis iterate(100) 
					}
					else {
						quietly `regtype' `Y' `RHS' if _n>=`N'+1-`BEST_PRIOR_LEFT' & _n<=`N' [fweight=weight], asis iterate(100) 
					}
					quietly predict temp1 if e(sample) | `Y'==.
				}
			}
			forvalues Q=1/`BEST_POLY_LEFT' {
				drop `X'`Q'
			}
		}
		quietly count
		local N_PLUS=`r(N)'+1000
		if `BEST_POLY'==0 {
			quietly sum `Y' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR' [fweight=weight]
			local temp2=`r(mean)'
			quietly set obs `N_PLUS'
			quietly sum `X' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR'
			quietly replace `X'=`threshold'+(`r(max)'-`threshold')*uniform() if `X'==.
			quietly gen temp2=`temp2' if (_n>=`N'+1 & _n<=`N'+`BEST_PRIOR') | (`Y'==. & temp1==.)
		}
		else {
			quietly set obs `N_PLUS'
			quietly sum `X' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR'
			quietly replace `X'=`threshold'+(`r(max)'-`threshold')*uniform() if `X'==.
			forvalues Q=1/`BEST_POLY' {
				gen double `X'`Q'=`X'^`Q'
			}
			local RHS
			forvalues Q=1/`BEST_POLY' {
				local RHS `RHS' `X'`Q'
			}
			if "`regtype'"=="regress" {
				quietly regress `Y' `RHS' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR' [fweight=weight]
				quietly predict temp2 if e(sample) | (`Y'==. & temp1==.)
			}
			else {
				quietly sum `Y' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR'
				if `r(sd)'==0 {
					quietly gen temp2=`r(mean)' if (_n>=`N'+1 & _n<=`N'+`BEST_PRIOR') | (`Y'==. & temp1==.)
				}
				else {
					quietly count if `Y'>0 & `Y'<1 & _n>=`N'+1 & _n<=`N'+`BEST_PRIOR'
					if `r(N)' > 0 {
						quietly glm `Y' `RHS' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR' [fweight=weight], link(`regtype') family(binomial) vce(robust) asis iterate(100) 
					}
					else {
						quietly `regtype' `Y' `RHS' if _n>=`N'+1 & _n<=`N'+`BEST_PRIOR' [fweight=weight], asis iterate(100) 
					}
					quietly predict temp2 if e(sample) | (`Y'==. & temp1==.)
				}
			}
		}
		sort `X'
		twoway (line temp1 `X', lcolor(red) lwidth(thick)) (line temp2 `X', lcolor(blue) lwidth(thick)) (scatter `Y' `X' [fweight=weight], msymbol(oh) mcolor(black) xline(`threshold')), legend(off) xtitle("") scheme(s1color)
		restore
	}
	}
	}
	}
	}
	}
end

