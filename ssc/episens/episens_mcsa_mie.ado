*! v.1.0.0 N.Orsini 13sep2007

capture program drop episens_mcsa_mie
program episens_mcsa_mie, rclass
version 9.2
        syntax anything [ , obs(integer 5000) sseca(string) sspca(string) ssenc(string) sspnc(string) scorrsens(string) scorrspec(string) ///
			          apprr(string)  studytype(string) seed(string) GRaph DStat ]

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

	tempname arrdx  
  	scalar `arrdx' = `apprr'

* Generate a pairs of 0,1 random variables with user-specified correlation

tempvar v1 v2 v3  v4 v5 v6 se1 se0 sp1 sp0
tempname rsens rspec

forv i = 1/6 {
gen `v`i'' = logit(uniform()) 
}			

if "`scorrsens'" != "" 	scalar `rsens' = `scorrsens'
	else scalar `rsens' = 1

if "`scorrspec'" != "" 	scalar `rspec' = `scorrspec'
	else scalar `rspec' = 1

gen `se1' = invlogit( sqrt(`rsens')*`v1'+ sqrt(1-`rsens')*`v2')  
gen `se0' = invlogit( sqrt(`rsens')*`v1'+ sqrt(1-`rsens')*`v3')  

gen `sp1' = invlogit( sqrt(`rspec')*`v4'+ sqrt(1-`rspec')*`v5')  
gen `sp0' = invlogit( sqrt(`rspec')*`v4'+ sqrt(1-`rspec')*`v6')  

if "`sseca'" != "" {

	tempvar rn_sseca psseca rpsseca

	local wn : word count `sseca' 

    	tokenize "`sseca'"
	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_sseca' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_sseca' = `max'-(`max'-`min')*`se1'
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_sseca' =  (`se1'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_sseca' = `min' + sqrt((`mod1'-`min')*(2*`rn_sseca'-`min'-`mod1')) if `rn_sseca' < `mod1'
		qui replace `rn_sseca' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_sseca'-`mod2')) if `rn_sseca' > `mod2'
	}

	if "`dist'" == "Logit-Logistic" {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psseca' =  `m' + logit(`se1')*`s' 	
		gen double `rn_sseca'  = `bl' + (`bu'-`bl')*invlogit(`psseca') 	
	}

	if "`dist'" == "Logit-Normal"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psseca' = `m' + invnorm(`se1')*`s' 	
		gen double `rn_sseca' = `bl' + (`bu'-`bl')*invlogit(`psseca')	 
	}

	
}

if "`sspca'" != "" {

	tempvar rn_sspca psspca rpsspca

	local wn : word count `sspca' 

    	tokenize "`sspca'"

	local dist = "`1'" 

	if "`dist'" == "Constant" qui gen double `rn_sspca' = `2'

 	if "`dist'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_sspca' = `max'-(`max'-`min')*`sp1'
	}

	if ("`dist'" == "Triangular")  | ("`dist'" == "Trapezoidal") {
		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
 		qui gen double `rn_sspca' =  (`sp1'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_sspca' = `min' + sqrt((`mod1'-`min')*(2*`rn_sspca'-`min'-`mod1')) if `rn_sspca' < `mod1'
		qui replace `rn_sspca' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_sspca'-`mod2')) if `rn_sspca' > `mod2'
	}

	if "`dist'" == "Logit-Logistic"  {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psspca' = `m' + logit(`sp1')*`s' 	
		gen double `rn_sspca' = `bl' + (`bu'-`bl')*invlogit(`psspca')
	}

	if "`dist'" == "Logit-Normal"   {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psspca' = `m' + invnorm(`sp1')*`s' 	
		gen double `rn_sspca' = `bl' + (`bu'-`bl')*invlogit(`psspca')	 
	}


}

if "`ssenc'" != "" {

	tempvar rn_ssenc pssenc rpssenc

	local wn : word count `ssenc' 

    	tokenize "`ssenc'"

	local distssenc = "`1'" 
    
	if "`distssenc'" == "Constant" qui gen double `rn_ssenc' = `2'

 	if "`distssenc'" == "Uniform"  {
		local min = `2'
		local max = `3'
		qui gen double `rn_ssenc' = `max'-(`max'-`min')*`se0'
	}

	if ("`distssenc'" == "Triangular")  | ("`distssenc'" == "Trapezoidal") {

		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
		
		qui gen double `rn_ssenc' =  (`se0'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_ssenc' = `min' + sqrt((`mod1'-`min')*(2*`rn_ssenc'-`min'-`mod1')) if `rn_ssenc' < `mod1'
		qui replace `rn_ssenc' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_ssenc'-`mod2')) if `rn_ssenc' > `mod2'

	}

	if "`distssenc'" == "Logit-Logistic"   {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pssenc' = `m' + logit(`se0')*`s' 	
		gen double `rn_ssenc' = `bl' + (`bu'-`bl')*invlogit(`pssenc')	 

	}

	if "`distssenc'" == "Logit-Normal"    {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `pssenc' = `m' + invnorm(`se0')*`s'	
		gen double `rn_ssenc' = `bl' + (`bu'-`bl')*invlogit(`pssenc') 
	}

}

if "`sspnc'" != "" {

	tempvar rn_sspnc psspnc rpsspnc

	local wn : word count `sspnc' 

    	tokenize "`sspnc'"

	local distsspnc = "`1'" 
    
	if "`distsspnc'" == "Constant" qui gen double `rn_sspnc' = `2'

 	if "`distsspnc'" == "Uniform"  {
		local min = `2'
		local max = `3'
 		qui gen double  `rn_sspnc' = `max'-(`max'-`min')*`sp0'
	}

	if ("`distsspnc'" == "Triangular")  | ("`distsspnc'" == "Trapezoidal") {

		local min  = `2'
		local mod1 = `3'
		local mod2 = `4'
		local max  = `5'
		qui gen double `rn_sspnc' =  (`sp0'*(`max'+`mod2'-`min'-`mod1') + (`min' + `mod1') )/2
		qui replace `rn_sspnc' = `min' + sqrt((`mod1'-`min')*(2*`rn_sspnc'-`min'-`mod1')) if `rn_sspnc' < `mod1'
		qui replace `rn_sspnc' = `max' - sqrt( 2*(`max'-`mod2')*(`rn_sspnc'-`mod2')) if `rn_sspnc' > `mod2'
	}

	if "`distsspnc'" == "Logit-Logistic"    {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psspnc' = `m' + logit(`sp0')*`s'	
		gen double `rn_sspnc' = `bl' + (`bu'-`bl')*invlogit(`psspnc')	 

	}

	if "`distsspnc'" == "Logit-Normal"    {
		local m = `2'
		local s = `3'
		local bl = `4'
		local bu = `5'
		gen double `psspnc' = `m' + invnorm(`sp0')*`s'	
		gen double `rn_sspnc' = `bl' + (`bu'-`bl')*invlogit(`psspnc') 
	}

}

 
		tempname rhose rhosp
		qui corr `rn_sseca' `rn_ssenc' 
		scalar `rhose' = r(rho)
		qui corr `rn_sspca' `rn_sspnc' 
		scalar `rhosp' = r(rho)
	
	if "`dstat'" != "" {
		qui corr `rn_sseca' `rn_ssenc' 
		di as text "Correlation sensitivities : " %3.2f r(rho)
		char `rn_sseca'[varname] "Se|Cases"
		char `rn_ssenc'[varname] "Se|No-Cases"
		tabstat `rn_sseca' `rn_ssenc' , stat(min median max ) format(%3.2f)
	}

	if "`dstat'" != "" {
		qui corr `rn_sspca' `rn_sspnc' 
		di as text "Correlation specificities : " %3.2f r(rho)
		char `rn_sspca'[varname] "Sp|Cases"
		char `rn_sspnc'[varname] "Sp|No-Cases"
		tabstat `rn_sspca' `rn_sspnc' , stat(min median max ) format(%3.2f)
	}
 
 
if "`graph'" != "" qui hist  `rn_sseca'
if "`graph'" != "" qui hist  `rn_sspca'
if "`graph'" != "" qui hist  `rn_ssenc'
if "`graph'" != "" qui hist  `rn_sspnc'

/* 
tempvar seec spec seeo speo fnec fpec fneo fpeo a1 a0 b1 b0 rrdx

	gen `seec' = `rn_sseca' 
	gen `spec' = `rn_sspca' 
	gen `seeo' = `rn_ssenc' 
	gen `speo' = `rn_sspnc' 

	gen `fnec' = 1-`seec'
	gen `fpec' = 1-`spec'
	gen `fneo' = 1-`seeo'
	gen `fpeo' = 1-`speo'

	gen `b1' = (`speo'*`c'-`fpeo'*`d')/(`seeo'*`speo'-`fneo'*`fpeo')
	gen `b0' = (`c'+`d'-`b1')
	gen `a1' = (`spec'*`a'-`fpec'*`b')/(`seec'*`spec'-`fnec'*`fpec')
	gen `a0' = (`a'+`b')-`a1'

	if "`studytype'" == "cc"  gen `rrdx' = (`a1'*`b0')/(`b1'*`a0')  
	if "`studytype'" == "ir"  gen `rrdx' = (`a1'/`b1')/(`a0'/`b0')  
	if "`studytype'" == "cs"  gen `rrdx' = (`a1'/(`a1'+`b1'))/(`a0'/(`a0'+`b0'))


	_pctile `rrdx' , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic error " as res _col(30) %3.2f r(r1)   _col(40) %3.2f   r(r2)    _col(50) %3.2f   r(r3) 

if "`graph'" != "" hist `rrdx'
 
*/

* keep a random subset of the bias parameters

	qui sample 1, count

* From whatever prior distribution the bias parameter are coming from put the values into scalars for the final calculations

	tempname seec spec seeo speo
	
	scalar `seec' = `rn_sseca'[1]
	scalar `spec' = `rn_sspca'[1]
	scalar `seeo' = `rn_ssenc'[1]
	scalar `speo' = `rn_sspnc'[1]

	tempname fnec fpec fneo fpeo

	scalar `fnec' = 1-`seec'
	scalar `fpec' = 1-`spec'
	scalar `fneo' = 1-`seeo'
	scalar `fpeo' = 1-`speo'

   di `seec' "   " `spec'  "   "  `seeo' "  "  `speo'

* calculate the bias-adjusted RR   
	 
	tempname b0 b1 a1 a0 rrdx percent_bias adj_factor

	scalar `b1' = (`speo'*`c'-`fpeo'*`d')/(`seeo'*`speo'-`fneo'*`fpeo')
	scalar `b0' = (`c'+`d')-`b1'
	scalar `a1' = (`spec'*`a'-`fpec'*`b')/(`seec'*`spec'-`fnec'*`fpec')
	scalar `a0' = (`a'+`b')-`a1'

	if "`studytype'" == "cc"  scalar `rrdx' = (`a1'*`b0')/(`b1'*`a0')  

	if "`studytype'" == "ir"  scalar `rrdx' = (`a1'/`b1')/(`a0'/`b0')  
	if "`studytype'" == "cs"  scalar `rrdx' = (`a1'/(`a1'+`b1'))/(`a0'/(`a0'+`b0'))

* Treatment of Negative Adjustment
* Discard draws that produce negative cell counts 

* 	di as y  `a1' " "   `a0' " "  `b1' " "  `b0' 


 
* Discard draws that produce counts < 1 

if (round(`a1')<1) | (round(`a0')<1) | (round(`b1')<1) | (round(`b0')<1)  {

	scalar `rrdx' = .

	scalar `a1' = . 
      scalar `a0' = .
	scalar `b1' = . 
      scalar `b0' = .
	}

	if (`seeo' < `c'/`m0') | (`speo' < `d'/`m0') | (`seec' < `a'/`m1')  | (`spec' < `b'/`m1') {
 
	scalar `rrdx' = .

	scalar `a1' = . 
      scalar `a0' = .
	scalar `b1' = . 
      scalar `b0' = .
	}

  
	scalar `percent_bias' = (`arrdx'-`rrdx')/(`rrdx')*100  
	scalar `adj_factor' = `arrdx' / `rrdx'
	
	 di "Adj RR = " %3.2f `rrdx'
	* di "percent bias = " %2.0f `percent_bias' 

* return saved results

        return scalar adj_rr_mie     = `rrdx'
        return scalar adj_factor_mie = `adj_factor'
        return scalar perc_bias = `percent_bias'
	  return scalar pseca = `seec' 
	  return scalar psenc = `seeo'
	  return scalar pspca = `spec'
	  return scalar pspnc = `speo'
	  return scalar a1 = `a1'
        return scalar a0 = `a0'
	  return scalar b1 = `b1'
	  return scalar b0 = `b0'
	  return scalar rhose = `rhose'
	  return scalar rhosp = `rhosp'
end
 
/*
episens_mcsa_mie 45 94 257 945,  obs(5000) sseca(Uniform .6 .8) sspca(Triangular .6 .8 .8 .9) ssenc(Trapezoidal .5 .6 .8 .9) sspnc(Logit-Normal 0 1 0.7 1) apprr(1.76) studytype(cc)

*  episens_mcsa_mie 45 94 257 945,  obs(5000) sseca(Constant .8) sspca(Constant .9) ssenc(Constant .8) sspnc(Constant .9) apprr(1.76) studytype(cc) dstat


cd "C:\Nicola\SJ\sensitivity\command" // work

*  episensi 45 94 257 945, st(cc) mie(0.8 0.9 0.8 0.9) 
*  episens_mcsa_mie 45 94 257 945,  obs(5000) sseca(Uniform .6 .8) sspca(Constant .9) ssenc(Constant .8) sspnc(Constant .9) apprr(1.76) studytype(cc)

 set trace off
 set tracedepth 1

 
* episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Logit-Logistic `=logit(.9)' .8  .8 1) sspca(Logit-Logistic `=logit(.7)' .8 .8 1) ///
         ssenc(Logit-Logistic `=logit(.9)' .8  .8 1) sspnc(Logit-Logistic `=logit(.7)' .8 .8 1) ///
	   scorrsens(.8) scorrspec(.8) nograph

* The correlation option works when the input are logit-normal or logit-logistic but not when trapezoidal/triangular

 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Trapezoidal .6 .7 .8 .9) sspca(Trapezoidal .6 .7 .8 .9) ///
         ssenc(Trapezoidal .6 .7 .8 .9) sspnc(Trapezoidal .6 .7 .8 .9) ///
	   scorrsens(.7) scorrspec(.4)  nograph

  episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Triangular .5 .7 .7 .9) sspca(Triangular .5 .8 .8 .9) ///
         ssenc(Triangular .5 .7 .7 .9) sspnc(Triangular .5 .8 .8 .9) ///
	   scorrsens(.7) scorrspec(.4)  nograph
ret list

  episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Constant 18) sspca(Constant .8) ///
         ssenc(Triangular .5 .7 .7 .9) sspnc(Uniform .8 1) ///
	   scorrsens(.6) scorrspec(.9)  nograph


episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Constant .9) sspca(Constant .8) ///
         ssenc(Constant .9) sspnc(Constant .8)

 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Constant .9)  sspca(Constant .84906613) ///
         ssenc(Constant .9) sspnc(Constant .86820865)  
 
 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Uniform .9 .9)  sspca(Uniform .8 .8) ///
         ssenc(Uniform .9 .9)  sspnc(Uniform .8 .8)  

 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Constant .9)  sspca(Uniform .8 .8) ///
         ssenc(Constant .9)  sspnc(Uniform .8 .8)  

 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Constant .9)  sspca(Constant .8) ///
         ssenc(Constant .9)  sspnc(Constant .8)  

episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Trapezoidal .75  .85 .95  1) sspca(Trapezoidal .75  .85 .95  1) ///
         ssenc(Trapezoidal .75  .85 .95  1) sspnc(Trapezoidal .75  .85 .95  1)  

set trace off
set tracedepth 2
episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Trapezoidal .75  .85 .95  1) sspca(Trapezoidal .75  .85 .95  1) ///
         ssenc(Trapezoidal .75  .85 .95  1) sspnc(Trapezoidal .75  .85 .95  1)  scorrsens(.8) scorrspec(.8)  dstat

 episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Uniform .7 .9)  sspca(Uniform .6 .8) ///
         ssenc(Uniform .8 .9)  sspnc(Uniform .8 1)  dstat scorrsens(.8) scorrspec(.5)

  episens_mcsa_mie 45 94 257 945,  obs(20000) apprr(1.76) studytype(cc) ///
         sseca(Logit-Logistic `=logit(.9)' .8  .8 1) sspca(Logit-Logistic `=logit(.7)' .8 .8 1) ///
         ssenc(Logit-Logistic `=logit(.9)' .8  .8 1) sspnc(Logit-Logistic `=logit(.7)' .8 .8 1) ///
	   scorrsens(.8) scorrspec(.6) dstat
*/
