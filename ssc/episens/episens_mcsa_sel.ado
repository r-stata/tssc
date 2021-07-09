*! v.1.0.0 N.Orsini 8aug2007

capture program drop episens_mcsa_sel
program episens_mcsa_sel, rclass
version 9.2
        syntax [anything] [ , obs(integer 5000) spscex(string) spscun(string)  spsnex(string) spsnun(string) ssbfactor(string) ///
			          apprr(string)  studytype(string) seed(string) GRaph DStat ]

        drop _all
        qui set obs `obs'
	  if "`seed'" != "" set seed `seed'

* get the cell counts

	gettoken a 0 : 0, parse(" ,")
	gettoken b 0 : 0, parse(" ,")
	gettoken c 0 : 0, parse(" ,")
	gettoken d 0 : 0, parse(" ,")

* get the observed RR

	tempname arrdx  
  	scalar `arrdx' = `apprr'

if "`spscex'" != "" {

	tempvar rn_spscex pspscex rpspscex

	local wn : word count `spscex' 

    	tokenize "`spscex'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spscex' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spscex' = `max'-(`max'-`min')*uniform()
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spscex' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spscex' = `min' + sqrt((`mod1'-`min')*(2*`rn_spscex'-`min'-`mod1')) if `rn_spscex' < `mod1'
		qui replace `rn_spscex' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spscex'-`mod2')) if `rn_spscex' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspscex' =  `m' + logit(uniform())*`s' 	
		gen double `rn_spscex'  = `bl' + (`bu'-`bl')*invlogit(`pspscex') 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspscex' = `m' + invnorm(uniform())*`s' 	
		gen double `rn_spscex' = `bl' + (`bu'-`bl')*invlogit(`pspscex')	 
	}

	
}

if "`spscun'" != "" {

	tempvar rn_spscun pspscun rpspscun

	local wn : word count `spscun' 

    	tokenize "`spscun'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spscun' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spscun' = `max'-(`max'-`min')*uniform()
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spscun' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spscun' = `min' + sqrt((`mod1'-`min')*(2*`rn_spscun'-`min'-`mod1')) if `rn_spscun' < `mod1'
		qui replace `rn_spscun' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spscun'-`mod2')) if `rn_spscun' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspscun' =  `m' + logit(uniform())*`s' 	
		gen double `rn_spscun'  = `bl' + (`bu'-`bl')*invlogit(`pspscun') 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspscun' = `m' + invnorm(uniform())*`s' 	
		gen double `rn_spscun' = `bl' + (`bu'-`bl')*invlogit(`pspscun')	 
	}

	
} 
 
if "`spsnex'" != "" {

	tempvar rn_spsnex pspsnex rpspsnex

	local wn : word count `spsnex' 

    	tokenize "`spsnex'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spsnex' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spsnex' = `max'-(`max'-`min')*uniform()
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spsnex' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spsnex' = `min' + sqrt((`mod1'-`min')*(2*`rn_spsnex'-`min'-`mod1')) if `rn_spsnex' < `mod1'
		qui replace `rn_spsnex' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spsnex'-`mod2')) if `rn_spsnex' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspsnex' =  `m' + logit(uniform())*`s' 	
		gen double `rn_spsnex'  = `bl' + (`bu'-`bl')*invlogit(`pspsnex') 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspsnex' = `m' + invnorm(uniform())*`s' 	
		gen double `rn_spsnex' = `bl' + (`bu'-`bl')*invlogit(`pspsnex')	 
	}

	
}

if "`spsnun'" != "" {

	tempvar rn_spsnun pspsnun rpspsnun

	local wn : word count `spsnun' 

    	tokenize "`spsnun'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spsnun' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spsnun' = `max'-(`max'-`min')*uniform()
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spsnun' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spsnun' = `min' + sqrt((`mod1'-`min')*(2*`rn_spsnun'-`min'-`mod1')) if `rn_spsnun' < `mod1'
		qui replace `rn_spsnun' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spsnun'-`mod2')) if `rn_spsnun' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspsnun' =  `m' + logit(uniform())*`s' 	
		gen double `rn_spsnun'  = `bl' + (`bu'-`bl')*invlogit(`pspsnun') 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pspsnun' = `m' + invnorm(uniform())*`s' 	
		gen double `rn_spsnun' = `bl' + (`bu'-`bl')*invlogit(`pspsnun')	 
	}

	
}


if "`ssbfactor'" != "" {

	tempvar rn_ssbfactor  

	local wn : word count `ssbfactor' 

    	tokenize "`ssbfactor'"

	local dist = "`1'" 
    
	if "`dist'" == "Constant" qui gen double `rn_ssbfactor' = `2'

 	if "`dist'" == "Uniform"  {
		local bl = `2'
		local bu = `3'
		local min = `2'
		local max = `3'
		qui gen double `rn_ssbfactor' = `max'-(`max'-`min')*uniform()
	}

	if ("`dist'" == "Triangular")  | ("`distssbfactor'" == "Trapezoidal") {

		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
		local bl = `2'
		local bu = `5' 		
		
		qui gen double `rn_ssbfactor' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_ssbfactor' = `min' + sqrt((`mod1'-`min')*(2*`rn_ssbfactor'-`min'-`mod1')) if `rn_ssbfactor' < `mod1'
		qui replace `rn_ssbfactor' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_ssbfactor'-`mod2')) if `rn_ssbfactor' > `mod2'

	}

	if "`dist'" == "Log-Normal"    {
		local m = `2'
		local s = `3'
		gen double `rn_ssbfactor' = exp( `m' + invnorm(uniform())*`s') 
		tempvar log_rn_ssbfactor 
		gen `log_rn_ssbfactor' = log(`rn_ssbfactor')
	}

	if "`dist'" == "Log-Logistic"    {
		local m = `2'
		local s = `3'
		gen double `rn_ssbfactor' = exp( `m' + logit(uniform())*`s') 
		tempvar log_rn_ssbfactor 
		gen `log_rn_ssbfactor' = log(`rn_ssbfactor')
	}


}

if "`graph'" != "" & "`spscex'" != "" qui hist  `rn_spscex'
if "`graph'" != "" & "`spscun'" != ""  qui hist  `rn_spscun'
if "`graph'" != "" & "`spsnex'" != ""  qui hist  `rn_spsnex'
if "`graph'" != "" & "`spsnun'" != ""  qui hist  `rn_spsnun'
if "`graph'" != "" & "`ssbfactor'" != ""  qui hist  `rn_ssbfactor'

* keep a random subset of the bias parameters

	qui sample 1, count

* From whatever prior distribution the bias parameter are coming from put the values into scalars for the final calculations

	tempname pscex  pscun psnex psnun  sbfact sel_bias_factor rrdx percent_bias adj_factor
	
	scalar `pscex' = `rn_spscex'[1]
	scalar `pscun' = `rn_spscun'[1]
	scalar `psnex' = `rn_spsnex'[1]
	scalar `psnun' = `rn_spsnun'[1]
      scalar `sbfact' = `rn_ssbfactor'[1]

di "pscex = " `pscex'
di "pscun = " `pscun'
di "psnex ="  `psnex'
di "psnun ="  `psnun'
di "sbfact =" `sbfact'

* calculate the bias-adjusted RR   
	 
	if "`ssbfactor'" == ""	scalar `sel_bias_factor' = (`pscex'*`psnun')/(`pscun'*`psnex')
	else 	scalar `sel_bias_factor' = `sbfact'

	scalar `rrdx' = `arrdx'/`sel_bias_factor' 
  
	scalar `percent_bias' = (`arrdx'-`rrdx')/(`rrdx')*100  
	scalar `adj_factor' = `arrdx' / `rrdx'
	
	 di "Adj RR = " %3.2f `rrdx'
	 di "percent bias = " %2.0f `percent_bias' 
	 di "sel bias factor = " `sel_bias_factor' 

* return saved results
	  
        return scalar adj_rr_sel     = `rrdx'
        return scalar adj_factor_sel = `adj_factor'
        return scalar perc_bias = `percent_bias'
	  return scalar pscex = `pscex' 
	  return scalar pscun = `pscun'
	  return scalar psnex = `psnex'
	  return scalar psnun = `psnun'
	  return scalar sbf = `sbfact'
end

/*
 set trace off
 set tracedepth 1

episens_mcsa_sel 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         spscex(Logit-Logistic `=logit(.9)' .8  .8 1) spscun(Logit-Logistic `=logit(.7)' .8 .8 1) ///
         spsnex(Logit-Logistic `=logit(.9)' .8  .8 1) spsnun(Logit-Logistic `=logit(.7)' .8 .8 1) ///
	   nograph
 
episens_mcsa_sel 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         spscex(Uniform  .8 1) spscun(Constant  .8) ///
         spsnex(Trapezoidal .6 .7 .8 .9) spsnun(Logit-Logistic `=logit(.7)' .8 .8 1) ///
	   nograph

episens_mcsa_sel 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         spscex(Uniform  .8 1) spscun(Triangular .6 .7 .7 .9) ///
         spsnex(Trapezoidal .6 .7 .8 .9) spsnun(Logit-Logistic `=logit(.7)' .8 .8 1) ///
	   ssbfactor(Log-Normal 0 .207) graph

episens_mcsa_sel 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
	   ssbfactor(Log-Normal 0 .207) gr
*/
