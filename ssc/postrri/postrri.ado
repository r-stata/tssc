*! v 1.0.0 N.Orsini  7july2006

capture program drop postrri
program postrri, rclass
version 8.2
syntax , Prior(string) Data(string)  [ Level(int $S_level) LPrior(int $S_level) LData(int $S_level) Format(string) * ]

if `level' <10 | `level'>99 { 
di in red "level() invalid"
exit 198
}   

if `lprior' <10 | `lprior'>99 { 
di in red "lprior() invalid"
exit 198
}   

if `ldata' <10 | `ldata'>99 { 
di in red "ldata() invalid"
exit 198
}   

if "`format'" == "" {
local format = "%3.2f"
}   
else {
local format = "`format'"
} 

tempname rr_p lb_p ub_p rr_d lb_d ub_d rr_post se_post lb_post ub_post levelci levelci_p levelci_d  se_p se_d w_se_p w_se_d

scalar `levelci' = `level' * 0.005 + 0.50
scalar `levelci_p' = `lprior' * 0.005 + 0.50
scalar `levelci_d' = `ldata' * 0.005 + 0.50

if "`prior'" == "" {
	di in red "specify prior LB and UB"
	exit 198
}   
else {
	tokenize "`prior'"
	confirm number `1'
	confirm number `2'
	scalar `lb_p' = `1'
	scalar `ub_p' = `2'
	scalar `rr_p' =  exp([log(`lb_p')+log(`ub_p')]/2)
}

if "`data'" == "" {
	di in red "specify data RR, LB and UB"
	exit 198
}   
else {
	tokenize "`data'"
	confirm number `1'
	confirm number `2'
	confirm number `3'

	scalar `rr_d' = `1'
	scalar `lb_d' = `2'
	scalar `ub_d' = `3'
}

// check values 

if  inrange(`rr_p', 0, .) != 1 {
		di in red "prior RR has to be >= 0"	
		exit 198
	}   

if  `rr_d' < 0 |  `rr_d' == . {
		di in red "data RR has to be >= 0"	
		exit 198
	}     

// calculate variances we assume by default 95% CI for both prior and data

scalar `se_p' =  ( log(`lb_p') - log(`ub_p') )/(2*invnorm(`levelci_p'))
scalar `se_d' =  ( log(`lb_d') - log(`ub_d') )/(2*invnorm(`levelci_d'))

// calculate weights

scalar `w_se_p' =  1/`se_p'^2
scalar `w_se_d' =  1/`se_d'^2

// Approximate-bayesian method

// Calculate posterior relative risk and 95% CI

scalar `rr_post' = exp( (log(`rr_p')*`w_se_p' + log(`rr_d')*`w_se_d')/(`w_se_p' +`w_se_d') )
scalar `se_post' = 1/ [1/`se_p'^2 + 1/`se_d'^2]

scalar `lb_post' = exp( log(`rr_post') - invnorm(`levelci') * sqrt(`se_post') )
scalar `ub_post' = exp( log(`rr_post') + invnorm(`levelci') * sqrt(`se_post') )
 
// display results

di _n as text "Posterior median for RR = " in y `format' `rr_post' 
di in g "`level'% posterior limits for RR (" `format' in y `lb_post' in g ", " in y `format' `ub_post' in g ")"

// saved results

return local cmd = "postrri"

return scalar rr_post = `rr_post'
return scalar lb_post = `lb_post'
return scalar ub_post = `ub_post'
return scalar logrr_post = log(`rr_post')
return scalar var_logrr_post =  `se_post' 
return scalar var_logrr_prior = `se_p'^2 
return scalar var_logrr_data =  `se_d'^2 
end

