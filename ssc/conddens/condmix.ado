cap program drop condmix
program define condmix
version 10
args $mixargs
*set up mass point
if "$mixmp"=="none" {
	local mixmp1=0
	local mixmp2 "\$mixlik" 
}
else {
	local mixmp1 "\$mixmp"
	local mixmp2 "\$mixmp"
}

quietly replace `lnf'=ln(1-`mixmp1')+ln($mixlik) if $mixobs!=$ML_y1 & $mixobs!=.
quietly replace `lnf'=ln(`mixmp2') if $mixobs==$ML_y1 & $mixobs!=.
quietly replace `lnf'=ln($nrlik) if $mixobs==.
end

