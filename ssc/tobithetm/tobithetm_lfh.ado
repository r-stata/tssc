program tobithetm_lfh
version 10
args lnf XB ZB Sig
qui replace `lnf' = ln(normal(-`XB'/((`Sig'*exp(`ZB'))))) if $ML_y1 == 0
qui replace `lnf' = -0.5*ln(2*_pi)-0.5*ln(((`Sig'*exp(`ZB')))^2)-0.5*($ML_y1-`XB')^2/((`Sig'*exp(`ZB')))^2 if $ML_y1>0
end

