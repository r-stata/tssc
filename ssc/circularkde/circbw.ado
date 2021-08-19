*! IHSU v1.0.1 04 January 2013 
* circbw v1.0 IHSU 02jul2012
program circbw, rclass
version 9
syntax varlist(max=1 numeric) [if] [in] , [Kercode(int 4)]
local kc `kercode'
tokenize `varlist'
args xvar
marksample touse
quietly count if `touse'
if r(N) == 0 {
        error 2000
}
quietly {
lv `xvar' if `touse'
sort `touse'
local psigma = (r(u_F) - r(l_F))/1.349
*sum `xvar' if `touse'
*noi l `xvar'
*noi di `psigma' " " r(mean)
tempvar cosa sina sumcosa sumsina
local nuobs = r(N)
*noi di "nuobs = " `nuobs'
gen `cosa' = cos(_pi/180*`xvar') if `touse'
gen `sina' = sin(_pi/180*`xvar') if `touse'
gen `sumcosa'=sum(`cosa') if `touse'
*noi l `sumcosa'
gen `sumsina'=sum(`sina') if `touse'
if `sumcosa'[_N]== 0 {
   noi di as error "Data are half repeated; must use data half"
   exit
   }
*noi di `sumcosa'[_N]
local R = (`sumcosa'[_N]^2+`sumsina'[_N]^2)^.5
*noi di "R = " `R'
local Rbar = `R'/`nuobs'
*noi di "Rbar = " `Rbar'
     if `Rbar' < 0.54 {
          local kappa = 2*`Rbar' + `Rbar'^3 + 5*`Rbar'^5/6
		  }
     else if (`Rbar' <= 0.53 | `Rbar'< 0.85) {
	      local kappa = -1*.4 + 1.39*`Rbar' + 0.43/(1 - `Rbar')
	      }
	 else if `Rbar'>= 0.85 {
	      local kappa = 1/(`Rbar'^3 - 4*`Rbar'^2 + 3*`Rbar')
		  }
*noi di "kappa = " `kappa'
if `nuobs'<= 15 {
     if `kappa' < 2 {
	    local kappa = max(`kappa'-2*(`nuobs'*`kappa')^-1,0)
	 }
	 else if `kappa' >=2 {
	    local kappa = (`nuobs'-1)^3*`kappa'/(`nuobs'^3+`nuobs')
		}
}
*noi di "kappa = " %8.4f `kappa'
i0kappa `kappa'
local i0kappa = r(i0kappa)
*noi di `i0kappa'
*i0kappa 2*`kappa'
*local i02k = r(i0kappa)
local 2kappa = 2*`kappa'
i1kappa `2kappa'
local i12k = r(i1kappa)
i2kappa `2kappa'
local i22k = r(i2kappa)
*noi di `i22k'
local nunum = 3*`nuobs'*`kappa'^2*`i22k'
local nuden = 4*_pi^(1/2)* `i0kappa'^2
local nurt = (`nunum'/`nuden')^(2/5)
*noi di `nurt'
local zeta = 1/`kappa'^(1/2)
*noi di "zeta = " `zeta'
local h0f = 7^(1/2)*`zeta'/`nuobs'^(1/5)
   if `kc' != 4 {
           if `kc'==1 {
		          local h0f=`h0f'*0.663
		   }
		   else if `kc'==2 {
		          local h0f = `h0f'*0.927
		   }
		   else if `kc' ==3 {
		          local h0f = `h0f'*0.844
		   }
		   else if `kc' ==5 {
		          local h0f = `h0f'*1.136
		   }
		   else if `kc' ==6 {
		          local h0f = `h0f'*0.381
		   }
		   else if `kc' == 7 {
		          local h0f = `h0f'*0.872
		   }
  }
*noi di "h_0 de Fisher = " `h0f'
*noi di "Rbar = " `Rbar'
local csigma = (180/_pi)*((2*(1-`Rbar'))^.5)
*noi di "csigma = "`csigma'
local hsv= 0.9*min(`csigma',`psigma')*`nuobs'^(-1/5)
local hh= 1.06*min(`csigma',`psigma')*`nuobs'^(-1/5)
local osh=1.144*`csigma'*`nuobs'^(-1/5)
	if `kc' != 6 {
           if `kc'==1 {
                   local hsv= `hsv'*1.74
                   local hh = `hh' *1.74
                   local osh= `osh'*1.74
           }
           else if `kc'==2 {
                   local hsv= `hsv'*2.432
                   local hh = `hh' *2.432
                   local osh= `osh'*2.432
           }
           else if `kc'==3 {
                   local hsv= `hsv'*2.214
                   local hh = `hh' *2.214
                   local osh= `osh'*2.214
           }
           else if `kc'==4 {
                   local hsv= `hsv'*2.623
                   local hh = `hh' *2.623
                   local osh= `osh'*2.623
           }
           else if `kc'==5 {
                   local hsv= `hsv'*2.978
                   local hh = `hh' *2.978
                   local osh= `osh'*2.978
           }
           else if `kc'==7 {
                   local hsv= `hsv'*2.288
                   local hh = `hh' *2.288
                   local osh= `osh'*2.288
           }
  }
  }
  display as txt _dup(60) "_"
  display "Some practical bandwidth rules for"
  display "circular data density estimation "
  display as txt _dup(60) "="
  display as txt _newline "von Mises rule of thumb bandwidth = " _col(50) as res %8.4f `nurt'
  display as txt _dup(60) "="
   if `kc' == 1 {
           local kerfun=`"Uniform kernel (1)"'
           display as res _newline `"`kerfun'"'
           }
   else if `kc'==2 {
           local kerfun=`"Triangular kernel (2)"'
           display as res _newline `"`kerfun'"'
           }
   else if `kc'==3 {
           local kerfun=`"Epanechnikov kernel (3)"'
           display as res _newline `"`kerfun'"'
           }
   else if `kc'==4 {
           local kerfun=`"Quartic kernel (4)"'
           display as res _newline `"`kerfun'"'
           }
  else if `kc'==5 {
          local kerfun=`"Triweight kernel (5)"'
          display as res _newline `"`kerfun'"'
          }
  else if `kc'==6 {
          local kerfun=`"Gaussian kernel (6)"'
          display as res _newline `"`kerfun'"'
          }
  else if `kc'==7 {
          local kerfun=`"Cosine kernel (7)"'
          display as res _newline `"`kerfun'"'
          }
  display as txt _dup(60) "="
  local h0f = `h0f'*180/_pi
  display as txt _newline "Fisher's kappa (" as res %8.4f `kappa' as txt ") bandwidth = " _col(50) as res %8.4f `h0f'
  display as txt _dup(60) "="
  
  display as txt _newline "Using Batschelet's angular deviation (" as res %8.4f `csigma' as txt ")" 
  display _dup(60) "_"
  display as txt "Silverman's optimal bandwidth = " _col(50)as res %8.4f `hsv'
  display as txt "Haerdle's 'better' optimal bandwidth = " _col(50) as res %8.4f `hh'
  display as txt "Scott's oversmoothed bandwidth = " _col(50) as res %8.4f `osh'
  
  display as txt _dup(60) "_"
  ret scalar kappa = `kappa'
  ret scalar bandw_oF = `h0f'
  ret scalar bandw_oS = `hsv'
  ret scalar bandw_oH = `hh'
  ret scalar bandw_os = `osh'
end

