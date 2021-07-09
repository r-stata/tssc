program mequate, rclass
        version 11.0
        args citemsx_a citemsx_b citemsx_c citemsy_a citemsy_b citemsy_c


*------------------------------------------------------------- calculate summary statistics

quietly summ `citemsx_a' if `citemsy_a'!=. 
local mxa=`r(mean)'
local sxa sqrt((`r(N)'-1) / `r(N)' * `r(Var)')


quietly summ `citemsx_b' if `citemsy_b'!=.
local mxb=`r(mean)'
local sxb sqrt((`r(N)'-1) / `r(N)' * `r(Var)')

quietly summ `citemsy_a' if `citemsx_a'!=.
local mya=`r(mean)'
local sya sqrt((`r(N)'-1) / `r(N)' * `r(Var)')

quietly summ `citemsy_b' if `citemsx_b'!=.
local myb=`r(mean)'
local nc=`r(N)'
local syb sqrt((`r(N)'-1) / `r(N)' * `r(Var)')


*------------------------------------------------------------- calculate M/S and M/M constants

local msA=`syb'/`sxb'
local msB= `myb'-`msA'*`mxb'
local mmA=`mxa'/`mya'
local mmB=`myb' -`mmA'*`mxb'

*------------------------------------------------------------- display results
di as text "Summary of Mean/Sigma and Mean/Mean Equating" 
di as text "Number of common items " `nc'
di as text " " 
di as text "Mean/Sigma constant A= " as result `msA'
di as text "Mean/Sigma constant B= " as result `msB'
di as text "Mean/Mean constant A= " as result `mmA'
di as text "Mean/Mean constant A= " as result `mmB'
*------------------------------------------------------------- return results


	return scalar msa =`msA'
	return scalar msb =`msB'
	return scalar mma=`mmA'
	return scalar mmb=`mmB'	

end


