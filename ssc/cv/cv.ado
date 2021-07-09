*!cv version 1.0
*!Written 01Dec2014
*!Written by Mehmet Mehmetoglu

capture program drop cv 
	program cv
	version 13.0

if "`e(cmd)'" != "regress" {
	di in red "works only with -regress-"
	exit
	}
	
//quietly regress
	//quietly ereturn list
	local rmse = e(rmse)
	local depvar = e(depvar)

sum `depvar' if e(sample), meanonly
	//quietly return list
	local minval = r(min)
	local depvarmean = r(mean)

if `minval' < 0 | `depvarmean' ==0 {
	di as smcl as txt  "{c TLC}{hline 73}{c TRC}"	
	di in red  "  CV cannot be used because Y includes negative values/has a mean of zero"
	di as smcl as txt  "{c BLC}{hline 73}{c BRC}"
	exit
	}

local cv = 100*(`rmse'/`depvarmean')
	di as smcl as txt  "{c TLC}{hline 43}{c TRC}"
	display "  Coefficient of Variation is " %-6.1f `cv' "percent"

if `cv' <= 33.333 {
	display in yellow "  an acceptable model fit"
	}
else {
	display in red "  not an acceptable model fit"
	}
    di as smcl as txt  "{c BLC}{hline 43}{c BRC}"
	
end


