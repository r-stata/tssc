program drop _all
*version 1.2


program define gboxplot, eclass
clear mata
graph drop _all



* Box-Plot outliers

			
version 13.0

if replay()& "`e(cmd)'"=="gboxplot" {
	ereturn  display
exit
}


syntax varlist(max=1) [if] [in], [delta(real 0.1) OUTlier(string) Bdp(integer 10) PERCout(real 0.7) NOGraph]
tempvar touse d z y2 id

mark `touse' `if' `in'
markout `touse' `varlist' 

preserve
qui keep if `touse'

qui {

if "`bdp'"!="" {
	if `bdp'<=0|`bdp'>=25 {
	di in r " The break-down point should be in the open interval (0,25)"
	exit 19
	}
}

if "`percout'"!="" {
	if `percout'<=0|`percout'>=25 {
	di in r " The percentage of standard individuals identified as outliers should be in the open interval (0,25)"
	exit 19
	}
}

local nw2: word count `outlier'
	if `nw2'>1 {  
	di in r "define 1 variables in option outlier"
	exit 19
	}
gen `id'=_n if `touse'
gen `d'=`varlist' if `touse'


sum `d', d
loca s0=(r(p75)-r(p25))
local sk=(r(p90)+r(p10)-2*r(p50))/(r(p90)-r(p10))
local kurt=(r(p90)-r(p10))/(r(p75)-r(p25))
local s0=`s0'/(0.6817766+0.0534282*abs(`sk')+0.1794771*`kurt'-0.0059595*`kurt'^2)

local med0=r(p50)
replace `d'=(`d'-`med0')/`s0'

sum `d', d
local min1=r(min)
local ck=`delta'
replace `d'=`d'-`min1'+`ck'
*loca s=(r(p75)-r(p25))
*replace `d'=`d'/`s'
sum `d', d
local minmax=r(min)+r(max)
replace `d'=(`d'/`minmax')
replace `d'=invnormal(`d')
sum `d', d

local med=r(p50)
loca s=(r(p75)-r(p25))/1.3426


gen `z'=(`d'-`med')/`s'

local bdp1=100-`bdp'

centile `z' , centile(`bdp' 50 `bdp1')
local UHS=r(c_3)-r(c_2)
local LHS=r(c_2)-r(c_1)

local g=ln(`UHS'/`LHS')/invnormal(`bdp1'/100)

centile `z', centile(`bdp' 50 `bdp1')
local p1=`g'*((-r(c_1)*r(c_3))/(r(c_1)+r(c_3)))
local h=2*ln(`p1')/(invnormal(`bdp1'/100)^2)

gen `y2'=(`g'^-1)*(exp(`g'*invnormal(_n/(_N+1)))-1)*exp(`h'*invnormal(_n/(_N+1))^2/2)

local k1=(`g'^-1)*(exp(`g'*invnormal(1-`percout'/200))-1)*exp(`h'*invnormal(1-`percout'/200)^2/2)
local k2=(`g'^-1)*(exp(`g'*invnormal(`percout'/200))-1)*exp(`h'*invnormal(`percout'/200)^2/2)

qui sum `y2', d
local kup=min(max(`k1', r(p75)),r(max))
local klow=max(min(`k2',r(p25)),r(min))


local wlow=((normal(`klow'*`s'+`med')*`minmax')+`min1'-`ck')*`s0'+`med0'
local wup=((normal(`kup'*`s'+`med')*`minmax')+`min1'-`ck')*`s0'+`med0'

qui sum `varlist' if `varlist'>=`wlow'
local wlow=r(min)

qui sum `varlist' if `varlist'<=`wup'
local wup=r(max)

if "`nograph'" == "" {
tempvar d0 median upq loq iqr upper lower upper0 lower0 region

gen `upper'=`wup'
gen `lower'=`wlow'


gen `d0'=`varlist'

egen `median' = pctile(`varlist'), p(50)
egen `upq' = pctile(`varlist'), p(75)
egen `loq' = pctile(`varlist'), p(25)
egen `iqr' = iqr(`varlist'),


egen `upper0' = max(min(`varlist', `upper'))
qui sum `varlist' if `varlist'<=`upper0'
local upper0=r(max)

egen `lower0' = min(max(`varlist', `lower'))
qui sum `varlist' if `varlist'>=`lower0'
local lower0=r(min)

replace `upper'=`upper0'
replace `lower'=`lower0 '


gen `region'=1

twoway (rbar `median' `upq' `region', horiz  pstyle(p1) blc(gs15) bfc(gs8) barw(0.35)) ///
(rbar `median' `loq' `region', horiz pstyle(p1)  lcolor(black) blc(gs15) bfc(gs8) barw(0.35)) ///
(rspike `upq' `upper' `region', horiz pstyle(p1) lcolor(black)) ///
(rspike `loq' `lower' `region', horiz pstyle(p1)  lcolor(black)) ///
(rcap `upper' `upper' `region', horiz pstyle(p1)  lcolor(black) msize(*2)) ///
(rcap `lower' `lower' `region', horiz pstyle(p1)  lcolor(black) msize(*2)) ///
(scatter `region' `d0' if !inrange(`varlist', `lower', `upper'), ms(Oh) mcolor(gs12)), legend(off) ytitle("") ylabel(0 2, nolabels tlcolor(none))
}


restore

if "`outlier'"!="" {
gen `outlier'=(`varlist'>`wup'|`varlist'<`wlow') if `touse'
}

ereturn clear
ereturn scalar g=`g'
ereturn scalar h=`h'
ereturn scalar upperW=`wup'
ereturn scalar lowerW=`wlow'

}
end


