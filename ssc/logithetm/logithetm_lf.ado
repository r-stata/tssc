program define logithetm_lf
version 7.0
args todo b lnf g H g1 g2
tempvar XB ZB
 mleval `XB' = `b', eq(1)
 mleval `ZB' = `b', eq(2) 
tempvar eta yv
qui gen byte    `yv' = 2*($ML_y1 ~= 0) - 1 if $ML_samp == 1
qui gen double `eta' = `XB'/exp(`ZB')      if $ML_samp == 1
 mlsum `lnf' = ln(invlogit(`yv'*`eta')) 
if `todo' == 0 { exit }
/* create scores */
 tempvar denom
#delimit ;
qui replace `g1' = `yv'*invlogit(`eta')*(1-invlogit(`eta'))/(exp(`ZB')*invlogit(`yv'*`eta')) if $ML_samp == 1;
#delimit cr
qui replace `g2' = - `XB'*`g1' if $ML_samp == 1
$ML_ec	tempvar d1 d2 
$ML_ec	mlvecsum `lnf' `d1' = `g1', eq(1)
$ML_ec	mlvecsum `lnf' `d2' = `g2', eq(2)
$ML_ec	mat `g' = (`d1',`d2') 
 if `todo' == 1 { exit }
 tempvar d11 ratio d12 d22
 mlmatsum `lnf' `d11' = `g1'*(`eta'/exp(`ZB')+`g1'), eq(1)
qui gen double `ratio' = invlogit(`eta')*(1-invlogit(`eta'))/invlogit(`yv'*`eta')
 mlmatsum `lnf' `d12' = `g1'+`eta'/exp(`ZB')*(`g2'-`ratio'^2),eq(1,2)
 mlmatsum `lnf' `d22' = `g2'*(1 - `eta'^2 + `g2'), eq(2)
 mat `H' = (`d11',`d12' \ `d12'', `d22')
end
