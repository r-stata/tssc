capture program drop adjtest
program define adjtest

local lhs $lhs
local rhs $rhs
local group $group
local adjust $adjust
local filename $filename
local group $group
local incgrp $incgrp
local group1 $group1
local method $method
local reps $reps
local reduced $reduced
*local constraint $constraint
local grponlysel $grponlysel

forval i = 1/99 {

	local q = `i'/100 /* quantile to be estimated */
		if `"`grponlysel'"'!="" {
		if `"`adjust'"'!=""&`"`2'"'=="f" {
				capture drop `lhs'_adj
				if `"`2'"'=="p"{
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2, quantile(`q') nolog  
				}
				if `"`2'"'=="i"{
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 `group', quantile(`q') nolog 
				}
				if `"`2'"'=="g"{
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==1, quantile(`q') nolog 
				} 
				if `"`2'"'=="f"{
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==0, quantile(`q') nolog 
				}
				if `"`2'"'=="m"{
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==1, quantile(`q') nolog 
				}
				matrix E=e(b)
			
				scalar cons=_b[_cons]
				scalar beta1=_b[`adjust']
				scalar ps1=abs(_b[`adjust']/_se[`adjust'])
				scalar beta2=_b[`adjust'2]
				scalar ps2=abs(_b[`adjust'2]/_se[`adjust'2])
				
				cext `1' `2' 2
				
				if `method'==2&ps1>1.96&ps2>1.96{
					ge `lhs'_adj=`lhs'-((cons-beta0)+beta1*`adjust'+beta2*`adjust'2)
					if `"`2'"'=="p"{
						quietly: qreg `lhs'_adj `rhs', quantile(`q') nolog
					}
					if `"`2'"'=="i"{
						quietly: qreg `lhs'_adj `rhs' `group', quantile(`q') nolog 
					}
					if `"`2'"'=="g"{
						quietly: qreg `lhs'_adj `rhs' if `group'==1, quantile(`q') nolog 
					}
					if `"`2'"'=="f"{
						quietly: qreg `lhs'_adj `rhs' if `group'==0, quantile(`q') nolog 
					}
					if `"`2'"'=="m"{
						quietly: qreg `lhs'_adj `rhs' if `group'==1, quantile(`q') nolog 
					}
				}
				if ps1<1.96|ps2<1.96 {
						capture drop `lhs'_adj
						if `"`2'"'=="p"{
							quietly: qreg `lhs' `rhs', quantile(`q') nolog  
						}
						if `"`2'"'=="i"{
							quietly: qreg `lhs' `rhs' `group', quantile(`q') nolog 
						}
						if `"`2'"'=="g"{
							quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
						} 
						if `"`2'"'=="f"{
							quietly: qreg `lhs' `rhs' if `group'==0, quantile(`q') nolog 
						}
						if `"`2'"'=="m"{
							quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
						}
						if `method'==2{
							if `"`1'"'=="m"{
								predict x`1'b`2' if `group'==1
							}
							else{
								predict x`1'b`2' if `group'==0
							}
						}	
						scalar sel=0
					}
					else {
						if `method'==2&ps1>1.96&ps2>1.96{
							if `"`1'"'=="m"{
								predict x`1'b`2' if `group'==1
							}
							else{
								predict x`1'b`2' if `group'==0
							}
						}
						scalar sel=1
					}
						if `method'==1{
				matrix E=e(b)
				quietly {
					ge x`1'b`2'=0
					scalar betas = colsof(E)-sel-1
					matrix EB = E[1,1..betas]
					foreach var of local rhs {
						preserve
						drop *
						svmat EB, names(col)
						su `var'
						scalar beta`var' = r(mean)
						restore
						if `"`1'"'=="m"{
							ge b`var' = beta`var'*`var' if `group'==1
							replace x`1'b`2'=b`var'+x`1'b`2' if `group'==1
						}
						else{
							ge b`var' = beta`var'*`var' if `group'==0
							replace x`1'b`2'=b`var'+x`1'b`2' if `group'==0
						}
					}
					qreg `lhs' `reduced' if $constraint, quantile(`q') nolog
					scalar beta0=_b[_cons]
					if `"`1'"'=="m" {
						replace x`1'b`2'=beta0+x`1'b`2' if `group'==1
					}
					else {
						replace x`1'b`2'=beta0+x`1'b`2' if `group'==0
					}
				}
			}
	
		else {
			if `"`2'"'=="p"{
				quietly: qreg `lhs' `rhs', quantile(`q') nolog  
				if `"`1'"'=="m"{
					predict x`1'b`2' if `group'==1
				}
				else{
					predict x`1'b`2' if `group'==0
				}
			}
			if `"`2'"'=="i"{
				quietly: qreg `lhs' `rhs' `group', quantile(`q') nolog  
				if `"`1'"'=="m"{
					predict x`1'b`2' if `group'==1
				}
				else{
					predict x`1'b`2' if `group'==0
				}
			}
			if `"`2'"'=="g"{
				quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
				if `"`1'"'=="m"{
					predict x`1'b`2' if `group'==1
				}
				else{
					predict x`1'b`2' if `group'==0
				}
			}
						
			if `"`2'"'=="f"{
				quietly: qreg `lhs' `rhs' if `group'==0, quantile(`q') nolog 
				if `"`1'"'=="m"{
					predict x`1'b`2' if `group'==1
				}
				else{
					predict x`1'b`2' if `group'==0
				}
			}
			
			if `"`2'"'=="m"{
				quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
				if `"`1'"'=="m"{
					predict x`1'b`2' if `group'==1
				}
				else{
					predict x`1'b`2' if `group'==0
				}
			}
		}
	}

		}
		else {
			if `"`adjust'"'!="" {
				capture drop `lhs'_adj
				if `"`2'"'=="p" {
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2, quantile(`q') nolog  
				}
				if `"`2'"'=="i" {
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 `group', quantile(`q') nolog 
				}
				if `"`2'"'=="g" {
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==1, quantile(`q') nolog 
				} 
				if `"`2'"'=="f" {
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==0, quantile(`q') nolog 
				}
				if `"`2'"'=="m" {
					quietly: qreg `lhs' `rhs' `adjust' `adjust'2 if `group'==1, quantile(`q') nolog 
				}
				matrix E=e(b)
			
				scalar cons=_b[_cons]
				scalar beta1=_b[`adjust']
				scalar ps1=abs(_b[`adjust']/_se[`adjust'])
				scalar beta2=_b[`adjust'2]
				scalar ps2=abs(_b[`adjust'2]/_se[`adjust'2])
				
				cext `1' `2' 2
				
				if `method'==2&ps1>1.96&ps2>1.96{
					ge `lhs'_adj=`lhs'-((cons-beta0)+beta1*`adjust'+beta2*`adjust'2)
					if `"`2'"'=="p"{
						quietly: qreg `lhs'_adj `rhs', quantile(`q') nolog
					}
					if `"`2'"'=="i"{
						quietly: qreg `lhs'_adj `rhs' `group', quantile(`q') nolog 
					}
					if `"`2'"'=="g"{
						quietly: qreg `lhs'_adj `rhs' if `group'==1, quantile(`q') nolog 
					}
					if `"`2'"'=="f"{
						quietly: qreg `lhs'_adj `rhs' if `group'==0, quantile(`q') nolog 
					}
					if `"`2'"'=="m"{
						quietly: qreg `lhs'_adj `rhs' if `group'==1, quantile(`q') nolog 
					}
				}
				if ps1<1.96|ps2<1.96 {
						capture drop `lhs'_adj
						if `"`2'"'=="p" {
							quietly: qreg `lhs' `rhs', quantile(`q') nolog  
						}
						if `"`2'"'=="i" {
							quietly: qreg `lhs' `rhs' `group', quantile(`q') nolog 
						}
						if `"`2'"'=="g" {
							quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
						} 
						if `"`2'"'=="f" {
							quietly: qreg `lhs' `rhs' if `group'==0, quantile(`q') nolog 
						}
						if `"`2'"'=="m" {
							quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
						}
						if `method'==2{
							if `"`1'"'=="m"{
								quietly: predict x`1'b`2' if `group'==1
							}
							else{
								quietly: predict x`1'b`2' if `group'==0
							}
						}	
						scalar sel=0
					}
					else {
						if `method'==2&ps1>1.96&ps2>1.96{
							if `"`1'"'=="m"{
								quietly: predict x`1'b`2' if `group'==1
							}
							else{
								quietly: predict x`1'b`2' if `group'==0
							}
						}
						scalar sel=2
					}
			if `method'==1{
				matrix E=e(b)
				quietly {
					ge x`1'b`2'=0
					scalar betas = colsof(E)-sel-1
					matrix EB = E[1,1..betas]
					foreach var of local rhs {
						preserve
						drop *
						svmat EB, names(col)
						su `var'
						scalar beta`var' = r(mean)
						restore
						if `"`1'"'=="m"{
							ge b`var' = beta`var'*`var' if `group'==1
							replace x`1'b`2'=b`var'+x`1'b`2' if `group'==1
						}
						else{
							ge b`var' = beta`var'*`var' if `group'==0
							replace x`1'b`2'=b`var'+x`1'b`2' if `group'==0
						}
					}
					qreg `lhs' `reduced' if $constraint, quantile(`q') nolog
					scalar beta0=_b[_cons]
					if `"`1'"'=="m" {
						replace x`1'b`2'=beta0+x`1'b`2' if `group'==1
					}
					else {
						replace x`1'b`2'=beta0+x`1'b`2' if `group'==0
					}
				}
			}
		}
	
		else {
			if `"`2'"'=="p"{
				quietly: qreg `lhs' `rhs', quantile(`q') nolog  
				if `"`1'"'=="m"{
					quietly: predict x`1'b`2' if `group'==1
				}
				else{
					quietly: predict x`1'b`2' if `group'==0
				}
			}
			if `"`2'"'=="i"{
				quietly: qreg `lhs' `rhs' `group', quantile(`q') nolog  
				if `"`1'"'=="m"{
					quietly: predict x`1'b`2' if `group'==1
				}
				else{
					quietly: predict x`1'b`2' if `group'==0
				}
			}
			if `"`2'"'=="g"{
				quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
				if `"`1'"'=="m"{
					quietly: predict x`1'b`2' if `group'==1
				}
				else{
					quietly: predict x`1'b`2' if `group'==0
				}
			}
						
			if `"`2'"'=="f"{
				quietly: qreg `lhs' `rhs' if `group'==0, quantile(`q') nolog 
				if `"`1'"'=="m"{
					quietly: predict x`1'b`2' if `group'==1
				}
				else{
					quietly: predict x`1'b`2' if `group'==0
				}
			}
			
			if `"`2'"'=="m"{
				quietly: qreg `lhs' `rhs' if `group'==1, quantile(`q') nolog 
				if `"`1'"'=="m"{
					quietly: predict x`1'b`2' if `group'==1
				}
				else{
					quietly: predict x`1'b`2' if `group'==0
				}
			}
		}
	}

		preserve
		quietly {
		keep if x`1'b`2'~=. /* keep valid predictions */
		keep pid x`1'b`2' /* throw away other vars */
		save tmp/x`1'b`2'`i', replace
		}
		di "`i'% of x`1'b`2' created"
		restore
	
		if `"`adjust'"'!="" {
			if `method'==2{
				drop x`1'b`2'/* b* */
			}
			if `method'==1{
				drop x`1'b`2' b*
			}
		}
		else {
			drop x`1'b`2'
		}
	}
end
