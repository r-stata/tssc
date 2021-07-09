* Version 1.1 - 8 Feb 2014
* By J.M.C. Santos Silva, Silvana Tenreyro, Frank Windmeijer
* Please email jmcss@essex.ac.uk for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define hpc, rclass
version 11.1
syntax varlist(numeric min=1) [if] [in], a(string) b(string) [ Cluster(string)]
     
marksample touse 
tempname  _rhs _y oldest resh resp pch pcp cl
gettoken _y _rhs: varlist
unab _rhs :  `_rhs'

capture: _est hold `oldest'

qui gen double `resh'=(`_y'-`a')/`a' if `touse'
qui gen double `resp'=(`_y'-`b')/`b' if `touse'
qui gen double `pch'=(`b'-`a')/`a' if `touse'
qui gen double `pcp'=(`a'-`b')/`b' if `touse'

if "`cluster'"=="" qui g `cl'=_n if `touse'
else               qui g `cl'=`cluster' if `touse'

qui reg  `resp' `pcp' `_rhs' [aw=`b'] if `touse', cluster(`cl')
qui local t_b=_b[`pcp']/_se[`pcp']
qui local enneb=e(N)
qui reg  `resh' `pch' `_rhs' [aw=`a'] if `touse', cluster(`cl')
qui local t_a=_b[`pch']/_se[`pch']
qui local ennea=e(N)

capture: _est unhold `oldest' 

di 
di as txt "         HPC test"
di
di as txt "         Ho: Model A is valid"
di as txt "         t  = " _continue
di %6.3f as result `t_a'
di as txt "         Prob > t  = " _continue
di %6.3f as result 1-normal(`t_a')  
di as txt "         Number of obs = " _continue      
di as result `ennea'

di
di as txt "         Ho: Model B is valid"
di as txt "         t  = " _continue
di %6.3f as result `t_b'
di as txt "         Prob > t  = " _continue
di %6.3f as result 1-normal(`t_b')  
di as txt "         Number of obs = " _continue      
di as result `enneb'

qui return scalar t_b=`t_b'
qui return scalar p_b = 1-normal(`t_b') 
qui cor `_y' `b' if `touse'
qui return scalar R2_b = r(rho)^2
qui return scalar N_b = `ennea'

qui return scalar t_a=`t_a'
qui return scalar p_a = 1-normal(`t_a') 
qui cor `_y' `a' if `touse'
qui return scalar R2_a = r(rho)^2
qui return scalar N_a = `enneb'


end
