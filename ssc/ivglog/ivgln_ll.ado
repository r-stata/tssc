* LL program to accompany lnivgs.ado: 2-parameter log-inverse gaussian
program define ivgln_ll
version 6
args lnf theta1 lnphi
tempvar T C M D phi

quietly {
  gen double `phi' = exp(`lnphi')
  gen double `T' = 1/`phi'
  gen double `M' = exp(`theta1')
  gen double `C' = ln(2*_pi*`phi' * ($ML_y1)^3)
  gen double `D' = 1/(`phi'*$ML_y1)

  replace `lnf' = `T' * (-$ML_y1/(2*`M'^2) + 1/`M') /* 
  */  - 0.5*( `C' + `D')
end

