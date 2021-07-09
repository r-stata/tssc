program define spmstar1_lf
version 10.0
args lnf mu Rho1 Sigma
tempvar A rYW1
gen double `rYW1'=`Rho1'*mstar_YW1
scalar p1 = `Rho1'
matrix p1W1 = p1*mstar_W1
matrix IpW = mstar_I_n - p1W1
qui gen double `A' = ln(det(IpW))/$mstar_nobs if _n == 1
scalar A = `A'
qui replace `lnf'= A + ln(normalden($ML_y1-`rYW1'-`mu', 0, `Sigma'))
end
