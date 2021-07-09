capture program drop cext
program define cext

quietly {

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
local constraint $constraint

ge cx`1'b`2'=0

				if `3'==3 {
					if `"`2'"'=="i"{
						scalar betas = colsof(E)-5
					}
					else {
						scalar betas = colsof(E)-4
					}
				}
				if `3'==2 {
					if `"`2'"'=="i"{
						scalar betas = colsof(E)-4
					}
					else {
						scalar betas = colsof(E)-3
					}
				}
				if `3'==1 {
					if `"`2'"'=="i"{
						scalar betas = colsof(E)-3
					}
					else {
						scalar betas = colsof(E)-2
					}
				}
		
		
				matrix EB = E[1,1..betas]
				foreach var of local rhs {
					preserve
					drop *
					svmat EB, names(col)
					su `var'
					scalar cbeta`var' = r(mean)
					restore
					if `"`1'"'=="m" {
						ge cb`var' = cbeta`var'*`var' if `constraint'&`group'==1
						replace cx`1'b`2'=cb`var'+cx`1'b`2' if `constraint'&`group'==1
					}
					else {
						ge cb`var' = cbeta`var'*`var' if `constraint'&`group'==0
						replace cx`1'b`2'=cb`var'+cx`1'b`2' if `constraint'&`group'==0
					}
				}
				if `"`1'"'=="m" {
					replace cx`1'b`2'=cx`1'b`2'+cons if `constraint'&`group'==1
				}
				else {
					replace cx`1'b`2'=cx`1'b`2'+cons if `constraint'&`group'==0
				}
				ge resid=`lhs'-cx`1'b`2'
				su resid

			scalar beta0=r(mean)
			drop cx`1'b`2' cb* resid

}			
end
