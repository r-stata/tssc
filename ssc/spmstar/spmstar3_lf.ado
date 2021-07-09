program define spmstar3_lf
version 10.0
args lnf mu Rho1 Rho2 Rho3 Sigma
tempvar A rYW1 rYW2 rYW3
gen double `rYW1'=`Rho1'*mstar_YW1
gen double `rYW2'=`Rho2'*mstar_YW2
gen double `rYW3'=`Rho3'*mstar_YW3
scalar p1 = `Rho1'
scalar p2 = `Rho2'
scalar p3 = `Rho3'
matrix p1W1 = p1*mstar_W1
matrix p2W2 = p2*mstar_W2
matrix p3W3 = p3*mstar_W3
matrix IpW = mstar_I_n - p1W1 - p2W2- p3W3
qui gen double `A' = ln(det(IpW))/$mstar_nobs if _n == 1
scalar A = `A'
qui replace `lnf'= A + ln(normalden($ML_y1-`rYW1'-`rYW2'-`rYW3'-`mu', 0, `Sigma'))
end
