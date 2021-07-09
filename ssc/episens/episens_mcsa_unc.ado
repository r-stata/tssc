*! v.1.0.0 N.Orsini 7aug2007

capture program drop episens_mcsa_unc
program episens_mcsa_unc, rclass
version 9.2

        syntax anything [ , obs(integer 5000) spexp(string) spunexp(string) srrcd(string) sorce(string) scorrprev(string)  ///
			          apprr(string) applb(string) appub(string) studytype(string) seed(string) GRaph DStat ]

        drop _all
        qui set obs `obs'
	  if "`seed'" != "" set seed `seed'

* get the cell counts

	gettoken a 0 : 0, parse(" ,")
	gettoken b 0 : 0, parse(" ,")
	gettoken c 0 : 0, parse(" ,")
	gettoken d 0 : 0, parse(" ,")

* di "`a'   `b'  `c'   `d'"

	local m1 = `a' + `b'
	local m0 = `c' + `d'

* get the observed RR

	tempname arrdx  albdx aubdx
  	scalar `arrdx' = `apprr'
	scalar `albdx' = `applb'
	scalar `aubdx' = `appub'

* Generate a pairs of 0,1 random variables with user-specified correlation

tempvar h1 h2 h3 p1 p0  
tempname rprev

forv i = 1/3 {
gen `h`i'' = logit(uniform()) 
}		

if "`scorrprev'" != "" 	scalar `rprev' = `scorrprev'
	else scalar `rprev' = 0

gen `p1' = invlogit( sqrt(`rprev')*`h1'+ sqrt(1-`rprev')*`h2')  
gen `p0' = invlogit( sqrt(`rprev')*`h1'+ sqrt(1-`rprev')*`h3') 

if "`spexp'" != "" {

	tempvar rn_spexp 

	local wn : word count `sseca' 

    	tokenize "`spexp'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spexp' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spexp' = `max'-(`max'-`min')*`p1'
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spexp' =  (`p1'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spexp' = `min' + sqrt((`mod1'-`min')*(2*`rn_spexp'-`min'-`mod1')) if `rn_spexp' < `mod1'
		qui replace `rn_spexp' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spexp'-`mod2')) if `rn_spexp' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `rn_spexp'  = `bl' + (`bu'-`bl')*invlogit(`m' + logit(`p1')*`s' ) 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `rn_spexp' = `bl' + (`bu'-`bl')*invlogit(`m' + invnorm(`p1')*`s' )	 
	}

}

if "`spunexp'" != "" {

	tempvar rn_spunexp 

	local wn : word count `spunexp' 

    	tokenize "`spunexp'"

	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_spunexp' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_spunexp' = `max'-(`max'-`min')*`p0'
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_spunexp' =  (`p0'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_spunexp' = `min' + sqrt((`mod1'-`min')*(2*`rn_spunexp'-`min'-`mod1')) if `rn_spunexp' < `mod1'
		qui replace `rn_spunexp' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_spunexp'-`mod2')) if `rn_spunexp' > `mod2'
	}

	if "`dist'" == "Logit-Logistic"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `rn_spunexp' = `bl' + (`bu'-`bl')*invlogit(`m' + invnorm(`p0')*`s' )
	}

	if "`dist'" == "Logit-Normal"   {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `rn_spunexp' = `bl' + (`bu'-`bl')*invlogit(`m' + invnorm(`p0')*`s' )	 
	}


}

if "`srrcd'" != "" {

	tempvar rn_srrcd  

	local wn : word count `srrcd' 

    	tokenize "`srrcd'"

	local distsrrcd = "`1'" 
    
	if "`distsrrcd'" == "Constant" qui gen double `rn_srrcd' = `2'

 	if "`distsrrcd'" == "Uniform"  {
		local blsrrcd = `2'
		local busrrcd = `3'
		local min = `2'
		local max = `3'
		qui gen double `rn_srrcd' = `max'-(`max'-`min')*uniform()
	}

	if ("`distsrrcd'" == "Triangular")  | ("`distsrrcd'" == "Trapezoidal") {

		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
		local blsrrcd = `2'
		local busrrcd = `5' 		
		
		qui gen double `rn_srrcd' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_srrcd' = `min' + sqrt((`mod1'-`min')*(2*`rn_srrcd'-`min'-`mod1')) if `rn_srrcd' < `mod1'
		qui replace `rn_srrcd' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_srrcd'-`mod2')) if `rn_srrcd' > `mod2'

	}

	if "`distsrrcd'" == "Log-Normal"    {
		local m = `2'
		local s = `3'
		gen double `rn_srrcd' = exp( `m' + invnorm(uniform())*`s') 
		tempvar log_rn_srrcd 
		gen `log_rn_srrcd' = log(`rn_srrcd')
	}

	if "`distsrrcd'" == "Log-Logistic"    {
		local m = `2'
		local s = `3'
		gen double `rn_srrcd' = exp( `m' + logit(uniform())*`s') 
		tempvar log_rn_srrcd 
		gen `log_rn_srrcd' = log(`rn_srrcd')
	}

}

if "`sorce'" != "" {

	tempvar rn_sorce u

	gen `u' = uniform()

	local wn : word count `sorce' 

    	tokenize "`sorce'"

	local distsorce = "`1'" 
    
	if "`distsorce'" == "Constant" qui gen double `rn_sorce' = `2'

 	if "`distsorce'" == "Uniform"  {
		local blsorce = `2'
		local busorce = `3'
		local min = `2'
		local max = `3'
		qui gen double `rn_sorce' = `max'-(`max'-`min')*uniform()
	}

	if ("`distsorce'" == "Triangular")  | ("`distsorce'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
		local blsorce = `2'
		local busorce = `5' 		
		
		qui gen double `rn_sorce' =  (uniform()*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_sorce' = `min' + sqrt((`mod1'-`min')*(2*`rn_sorce'-`min'-`mod1')) if `rn_sorce' < `mod1'
		qui replace `rn_sorce' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_sorce'-`mod2')) if `rn_sorce' > `mod2'
	}


	if ("`distsorce'" == "Log-Normal")    {
		local m = `2'
		local s = `3'
		gen double `rn_sorce' = exp( `m' + invnorm(uniform())*`s' ) 
		tempvar log_rn_sorce 
		gen `log_rn_sorce' = log(`rn_sorce')
	}

	if ("`distsorce'" == "Log-Logistic")    {
		local m = `2'
		local s = `3'
		gen double `rn_sorce' = exp( `m' + logit(uniform())*`s' ) 
		tempvar log_rn_sorce 
		gen `log_rn_sorce' = log(`rn_sorce')
	}

}

di "`spexp'"
di "`spunexp'"
di "`srrcd'"
di in y "`sorce'"

 
		tempname rhoprev
		qui corr `rn_spexp' `rn_spunexp' 
		scalar `rhoprev' = r(rho)
	
	if "`dstat'" != "" {
		qui corr `rn_spexp' `rn_spunexp' 
		di as text "Correlation prevalences : " %3.2f r(rho)
		tabstat `rn_spexp' `rn_spunexp'  , stat(min median max ) format(%3.2f)
	}
 
if "`graph'" != "" qui hist   `rn_spexp'
if "`graph'" != "" qui hist   `rn_spunexp'
if "`graph'" != "" qui hist  `log_rn_srrcd'
if "`graph'" != "" & "`sorce'" != "" qui hist  `log_rn_sorce'

* keep a random subset of the bias parameters

	qui sample 1, count

* From whatever prior distribution the bias parameter are coming from put the values into scalars for the final calculations

	tempname  prz1 prz0 rrdz orze rrdx rrxz  percent_bias adj_factor  b11 b01 a11 a01  

	scalar `prz1' = `rn_spexp'[1]
	scalar `prz0' = `rn_spunexp'[1]
	scalar `rrdz' = `rn_srrcd'[1]
	scalar `orze' = `rn_sorce'[1]
  
if "`sorce'" != "" {	

  	 scalar `rrdx' = `arrdx'/[ (`rrdz'*`orze'*`prz0'+1-`prz0') / ( (`rrdz'*`prz0'+1-`prz0')*( `orze'*`prz0'+1-`prz0') ) ]

}

/*
	 // To be able to re-calculate the cell counts we need to back-calculate the prevalence of the confounder among the exposed - prz1
	 // I use a simple iterative method  

	 tempname oz1 oz0  
	 scalar `oz0' = [`prz0'/(1-`prz0')]	
       local prz1 = .

	 forv i = 0(.01)1 {
		   scalar `oz1' = [`i'/(1-`i')]
		  * di "prz1 = " `i'  "    Diff =  " abs(`oz1' - (`orze'*`oz0') )
		   if abs(`oz1' - (`orze'*`oz0') ) < 1e-2  {
				 local prz1 = `i'
				 continue, break
		   }
	 }

	 if `prz1' == . {
		di as err "Not able to back-calculate the Pr(c=1|e=1)"
		exit 198
	}	

}	
*/

/*
	 di in g  "prz1 = " `prz1'  
	 di "prz0 = " `prz0'
	 di "rrcd = " `rrdz'
	 di "orze = " `orze'
*/

 if "`spexp'" != "" & "`sorce'" == "" {	

  	 scalar `rrxz' = [(`prz1')*(1-`prz0')]/[(1-`prz1')*(`prz0')] 
 	 scalar `b11' = `prz1' * `c'  
	 scalar `b01' = `prz0' * `d'  
	 scalar `a11' = (`rrdz'*`a'*`b11')/(`rrdz'*`b11' +`c'-`b11')  
	 scalar `a01' = (`rrdz'*`b'*`b01')/(`rrdz'*`b01'+`d'-`b01') 

	if "`studytype'" == "cc"  scalar `rrdx' = (`a11'*`b01')/(`b11'*`a01')  
	if "`studytype'" == "ir"  scalar `rrdx' = (`a11'/`b11')/(`a01'/`b01')  
	if "`studytype'" == "cs"  scalar `rrdx' = (`a11'/(`a11'+`b11'))/(`a01'/(`a01'+`b01'))
 }

/*
di `a11'
di `a01'
di `b11'
di `b01'
di (`a11'*`b01')/(`b11'*`a01')  
*/

 
	scalar `percent_bias' = (`arrdx'-`rrdx')/(`rrdx')*100  
	scalar `adj_factor' = `arrdx' / `rrdx'

	 di "Adj RR = " %3.2f `rrdx'
	 di "percent bias = " %2.0f `percent_bias' 
	tempname adjrrte 
	scalar `adjrrte' = exp( log(`rrdx') - invnorm(uniform())*[ (log(`aubdx')-log(`albdx'))/(invnorm(.975)*2) ] )

 // Saved results

        return scalar adj_rr_unc = `rrdx'
	  return scalar adj_rr_unc_te = `adjrrte'
        return scalar adj_factor_unc = `adj_factor'
        return scalar perc_bias = `percent_bias'
	  return scalar orce = `orze'
 	  return scalar pc0 =  `prz0'
 	  return scalar rrcd = `rrdz'
	
 if "`spexp'" != "" & "`sorce'" == "" {	
 	  return scalar a1 = `a11'
	  return scalar a0 = `a01'
	  return scalar b1 = `b11'
	  return scalar b0 = `b01'
 	  return scalar pc1 =  `prz1'  
 	  return scalar orce = `rrxz'
	  return scalar rhoprev = `rhoprev'
}

end
 
/*

episens_mcsa_unc 45 94 257 945,  obs(5000) spexp(Constant .7) spunexp(Constant .5) srrcd(Constant 5)  apprr(1.76) studytype(cc)  
 
episens_mcsa_unc 45 94 257 945,  obs(5000) spexp(Uniform .6 .8) spunexp(Constant .5) srrcd(Constant 5)  apprr(1.76) studytype(cc)  
episens_mcsa_unc 45 94 257 945,  obs(5000) spexp(Uniform .6 .8) spunexp(Triangular .4 .5 .5 .6) srrcd(Log-Normal `=log(5)' 1)  apprr(1.76) studytype(cc)  

episens_mcsa_unc 45 94 257 945,  obs(5000) spexp(Uniform .4 .7) spunexp(Uniform .4 .7) srrcd(Log-Normal 2.159 .280) ///
                                           apprr(1.76) studytype(cc)  
set trace off
set tracedepth 2
episens_mcsa_unc 45 94 257 945,  obs(5000) spexp(Uniform .4 .7) spunexp(Uniform .4 .7) srrcd(Log-Normal 2.159 .280) ///
                                    sorce(Log-Normal 0 .639 )         apprr(1.76) studytype(cc)  graph

*/
