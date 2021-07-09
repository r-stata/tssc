program define ztpflex_ada_ll
args ll xb lnsigma lntheta

quietly {

tempvar ipoisnm_tau ipoisnm_mu 
gen double `ipoisnm_tau'=$ml_tau
gen double `ipoisnm_mu'=$ml_mu

tempvar sigma theta
gen double `sigma' = exp(`lnsigma')
gen double `theta' = exp(`lntheta')

/* Get points and weights for Gaussian-Hermite quadrature. */
tempvar x w
gen double `x'=.
gen double `w'=.
_GetQuad, avar(`x') wvar(`w') quad($R)
replace `x' = sqrt(2)*`x'

tempvar li lnpri pri lambda pi
gen double `lambda'=.
gen double `lnpri'=.
gen double `pri'=.
gen double `li'=0
gen double `pi'=. 

  forvalues r=1/$R{
   replace `lambda'   = exp(`xb'+`sigma'*(sinh(`theta'*(`x'[`r']*`ipoisnm_tau'+`ipoisnm_mu'))/`theta'))
   replace `lnpri'    = -`lambda' + $ML_y1*ln(`lambda') - ln(1-exp(-`lambda')) - lngamma($ML_y1 + 1)
   replace `pri'      = exp(`lnpri')  
   replace `pi'       = sqrt(2*_pi)*`ipoisnm_tau'*`w'[`r']* ///
			normalden(`x'[`r']*`ipoisnm_tau'+`ipoisnm_mu')*exp(`x'[`r']^2/2)/sqrt(_pi)
   replace `li'       = `li' + `pri'*`pi'
  }

replace $f=`li'			/*for vuong test*/  
  
replace `ll' = ln(`li')

}

end 
