
*! nlces v1.0.0  CFBaum 11aug2008
program nlces
   version 10.1
   syntax varlist(numeric min=3 max=3) if, at(name)
   args logoutput K L
   tempname b0 rho delta
   tempvar kterm lterm
   scalar `b0' = `at'[1, 1]
   scalar `rho' = `at'[1, 2]
   scalar `delta' = `at'[1, 3]
   gen double `kterm' = `delta' * `K'^( -(`rho' )) `if'
   gen double `lterm' = (1 - `delta') *`L'^( -(`rho' )) `if'
   replace `logoutput' = `b0' - 1 / `rho' * ln( `kterm' + `lterm' ) `if'
end
