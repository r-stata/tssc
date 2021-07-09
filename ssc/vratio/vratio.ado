program define vratio, rclass
version 10.0
syntax varlist(numeric)

tempname VR VR2 VRMAX K PMHET
matrix `VR'=J(1,4,0)

foreach var of local varlist {
tempname n`var' k`var' fmodal`var' VR`var' MH`var' PMH`var'
quietly tab `var'
scalar define `n`var''=r(N)
scalar define `k`var''=r(r)
quietly mmodes `var'
scalar define `fmodal`var''=r(N)
scalar define `VR`var''=1-(`fmodal`var''/`n`var'')
scalar define `MH`var''=(1-((`n`var''/`k`var'')/`n`var''))
scalar define `PMH`var''=(1-(`fmodal`var''/`n`var''))/(1-((`n`var''/`k`var'')/`n`var''))

tempname VR_`var'
matrix `VR_`var''=J(1,4,0)

matrix `VR_`var'' = (`VR`var'',`MH`var'',`PMH`var'',`k`var'')
matrix rownames `VR_`var'' = `var'
matrix `VR'=`VR' \ `VR_`var''

}

matrix `VR'= `VR'[2...,1..4]
matrix colnames `VR' = VR VRmax VR/VRmax k
matlist `VR', border(all) lines(none) format(%9.3f) names(all) twidth(12) left(4) title("Variation Ratio and Proportion of Maximum Heterogeneity (Dispersion Measures for Categorical Variables)")

matrix `VR2'= `VR'[1...,1..1]
matrix `VRMAX'= `VR'[1...,2..2]
matrix `PMHET'= `VR'[1...,3..3]
matrix `K'= `VR'[1...,4..4]

return matrix k = `K'
return matrix pmh = `PMHET'
return matrix vrmax = `VRMAX'
return matrix vr = `VR2'

end
