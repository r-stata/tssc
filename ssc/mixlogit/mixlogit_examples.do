* examples.do
version 9

set more off

cd "H:\mixlogit"

sjlog using data, replace
use traindata.dta, clear
list in 1/12, sepby(gid)
sjlog close, replace

sjlog using normal, replace
global randvars "contract local wknown tod seasonal"
mixlogit y price, rand($randvars) group(gid) id(pid) nrep(50)
*Save coefficients for later use
matrix b = e(b)
sjlog close, replace

sjlog using lognormal, replace
gen mprice=-1*price
global lnrandv "contract local wknown tod seasonal mprice"
mixlogit y, rand($lnrandv) group(gid) id(pid) ln(1) nrep(50) 
sjlog close, replace

sjlog using delta, replace
nlcom (mean_price: -1*exp([Mean]_b[mprice]+0.5*[SD]_b[mprice]^2)) ///
	(med_price: -1*exp([Mean]_b[mprice])) ///
	(sd_price: exp([Mean]_b[mprice]+0.5*[SD]_b[mprice]^2) ///
		* sqrt(exp([SD]_b[mprice]^2)-1)) 
sjlog close, replace

sjlog using normal_corr, replace
*Starting values
matrix b = b[1,1..7],0,0,0,0,b[1,8],0,0,0,b[1,9],0,0,b[1,10],0,b[1,11]
mixlogit y price, rand($randvars) group(gid) id(pid) nrep(50) ///
corr from(b, copy) 
sjlog close, replace

sjlog using mixlcov_1, replace 
mixlcov
sjlog close, replace

sjlog using mixlcov_sd_1, replace 
mixlcov, sd
sjlog close, replace

sjlog using haan_data_1, replace 
use jspmix.dta, clear
list scy3 id tby sex in 1/4
sjlog close, replace

sjlog using haan_data_2, replace 
expand 3
bysort id: gen alt = _n
gen mid = (alt == 2)
gen low = (alt == 3)
gen sex_mid = sex*mid
gen sex_low = sex*low
sjlog close, replace

sjlog using haan_data_3, replace 
gen choice = (tby == alt)
sjlog close, replace

sjlog using haan_data_4, replace 
sort scy3 id alt
list scy3 id choice mid low sex_mid sex_low in 1/12, sepby(id)
sjlog close, replace

sjlog using haan_model, replace
mixlogit choice sex_mid sex_low, group(id) id(scy3) rand(mid low) nrep(50)
matrix b = e(b) 
sjlog close, replace

sjlog using haan_model_corr, replace
matrix b = b[1,1..5],0,b[1,6] 
mixlogit choice sex_mid sex_low, group(id) id(scy3) rand(mid low) corr nrep(50) from(b, copy)
sjlog close, replace

sjlog using mixlcov_2, replace 
mixlcov
sjlog close, replace

sjlog using mixlcov_sd_2, replace 
mixlcov, sd
sjlog close, replace

exit
