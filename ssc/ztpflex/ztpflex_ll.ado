program define ztpflex_ll
args ll xb lnsigma lntheta

quietly {

tempname sigma theta
sca `sigma' = exp(`lnsigma')
sca `theta' = exp(`lntheta')

/* Get points and weights for Gaussian-Hermite quadrature. */
tempvar x w
gen `x'=.
gen `w'=.
_GetQuad, avar(`x') wvar(`w') quad($R)
replace `x' = sqrt(2)*`x'

tempvar li lnpri pri lambda
gen double `lambda'=.
gen double `lnpri'=.
gen double `pri'=.
gen double `li'=0

  forvalues r=1/$R{
   replace `lambda'   = exp(`xb'+`sigma'*  sinh(`theta'*`x'[`r'])/`theta'   )
   replace `lnpri'    = -`lambda' + $ML_y1*ln(`lambda') - ln(1-exp(-`lambda')) - lngamma($ML_y1 + 1)
   replace `pri'      = exp(`lnpri')  
   replace `li'       = `li' + `pri'*`w'[`r']
  }

replace $f=`li'			/*for vuong test*/

replace `ll' = ln((1/sqrt(_pi))*`li') if $ML_samp

}

end 
