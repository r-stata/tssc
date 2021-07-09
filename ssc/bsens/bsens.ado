program bsens
version 12.1
args a b c d e 

qui local gammainc = `4'
qui local gamma = `5'
qui local ctrl = `2'
qui local trt = `1'
qui local strt = `3'

di "Gamma 	Lower Bound  Upper Bound"
forvalues  n = 1(`gammainc')`gamma' {
qui local mx = `ctrl' + `trt'
qui local sumc = 0.0
qui local sump = 0.0
qui local pplus = `n'/(1+`n') 
qui local pminus = 1/(1+`n')
  
forvalues i = `ctrl'(1)`mx'{
qui local bi = binomialp(`mx',`i',`pplus')
qui  local sump = `sump' + `bi'
qui  local di = binomialp(`mx',`i',`pminus')
qui  local sumc = `sumc' +  `di'
	  }
scalar rbin = round(`n',0.0001)
scalar rsumc = round(`sumc',0.0001)
scalar rsump = round(`sump',0.0001)
   	  di   rbin "        " rsumc "      " rsump
}
end
