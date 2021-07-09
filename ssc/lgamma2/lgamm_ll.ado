** LL program to accompany lgamma.ado: 2-parameter log-gamma
program define lgamm_ll
version 6
args lnf theta1 lnphi
tempvar T E C phi

quietly  {
  gen double `phi' = exp(`lnphi')
  gen double `T'   = 1/`phi'
  gen double `E'   = exp(`theta1')
  gen double `C'   = `T'*ln($ML_y1/`phi') /*
                  */ -ln($ML_y1)-lngamma(1/`phi')

  replace `lnf'    = `T'*($ML_y1*(-1/`E')-`theta1')+`C'
}
end
