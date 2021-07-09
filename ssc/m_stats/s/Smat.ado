/* Smat - returns the estimated covariance matrix S 
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */


program define Smat , rclass
version 10.1
syntax , x(varname) y(varname) g(varname) [bins(integer 20)]
tempname d ld D N N1 N2 S
_diff , x(`x') y(`y') g(`g') bins(`bins')
matrix `d' = r(d)
local N = r(N)
local N1 = r(N1)
local N2 = r(N2)
local ld = rowsof(`d')
matrix dissimilarity `D' = `x' `y'
forvalues k = 1/`ld' {       
mata: Ind_`k' = J(`N',`N',.) 
forvalues i = 1/`N' {
forvalues j = 1/`N' {
if `D'[`i',`j']<=`d'[`k',1] {
mata: Ind_`k'[`i',`j'] = 1
}
else {
mata: Ind_`k'[`i',`j'] = 0
}
}
}
forvalues i = 1/`N' {
mata: Ind_`k'[`i',`i']=0
}
}
mata: S = J(`ld',`ld',.)
forvalues s = 1/`ld' { // product matrices for each of the entries of S                  
forvalues k = 1/`ld' {
mata: Prod`s'_`k' = Ind_`s'*Ind_`k'    
mata: prob`s'_`k' = (J(1,`N',1)*Prod`s'_`k'*J(`N',1,1))/(2*comb(`N',2)+(`N'*(`N'-1)*(`N'-2)))
mata: S[`s',`k'] = 4*(`N'/`N1'*prob`s'_`k'+`N'/`N2'*prob`s'_`k')/`N' 
mata: mata drop Prod`s'_`k'
mata: mata drop prob`s'_`k'
}
}
forvalues k = 1/`ld' { // clear matrices
mata: mata drop Ind_`k'
}
mata: st_matrix("`S'",S)
return matrix S = `S'
end
