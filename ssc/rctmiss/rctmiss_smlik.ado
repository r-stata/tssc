prog def rctmiss_smlik
version 10
* log-likelihood for estimating missingness model
* was mnar_mml.ado
args lnf lp
qui replace `lnf' = `lp' if $ML_y1==1
qui replace `lnf' = -exp(`lp') if $ML_y1==0
end

