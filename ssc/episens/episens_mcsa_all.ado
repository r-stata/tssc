*! v.1.0.0 N.Orsini 9aug2007

capture program drop episens_mcsa_all
program episens_mcsa_all, rclass
version 9.2
        syntax [anything] [ , obs(integer 5000) apprr(string) applb(string) appub(string) studytype(string) seed(string) GRaph DStat ///
					sseca(string) sspca(string) ssenc(string) sspnc(string) scorrsens(string) scorrspec(string) ///
	     			      spscex(string) spscun(string)  spsnex(string) spsnun(string) ssbfactor(string) ///
					spexp(string) spunexp(string) srrcd(string) sorce(string) scorrprev(string) ///
	  			  ]

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

if ("`sseca'"!="") & ("`sspca'"!="") & ("`ssenc'"!="") & ("`sspnc'"!="") {
 
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

} // end misclassification parameters 

* di as err "`spscex'      `spscun'	 `spsnex'  		`spsnun' 		`ssbfactor' " 

if ( ("`spscex'" != "") &  ("`spscun'" != "") & ("`spsnex'" != "") &  ("`spsnun'" != "") ) ///
   | ("`ssbfactor'" != "")   {	

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

} // end selection bias parameters

if ("`spunexp'"!="") & ( ("`spexp'"!= "") | ("`sorce'"!="") ) & ("`srrcd'"!= "") {

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


	if ("`distsorce'" == "Log-Normal")   {
		local m = `2'
		local s = `3'
		gen double `rn_sorce' = exp( `m' + invnormal(uniform())*`s' ) 
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

} // end unmeasured confounding

* keep a random subset of the bias parameters

	qui sample 1, count
 
tempname rrstep rrdx

scalar `rrstep' = `apprr'

if ("`sseca'"!="") & ("`sspca'"!="") & ("`ssenc'"!="") & ("`sspnc'"!="") {

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

* calculate the bias-adjusted RR   
	 
	tempname b0 b1 a1 a0 percent_bias adj_factor  

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

* Discard draws that produce counts <=0 
	
	if (`seeo' < `c'/`m0') | (`speo' < `d'/`m0') | (`seec' < `a'/`m1')  | (`spec' < `b'/`m1') {
 
	scalar `rrdx' = .

	scalar `a1' = . 
      scalar `a0' = .
	scalar `b1' = . 
      scalar `b0' = .
	}
	
scalar `rrstep' = `rrdx'

di "Adj RR step 1 = " %3.2f `rrstep'

	  return scalar pseca = `seec' 
	  return scalar psenc = `seeo'
	  return scalar pspca = `spec'
	  return scalar pspnc = `speo'
	  return scalar rhose = `rhose'
	  return scalar rhosp = `rhosp'

} // end misclassification

if [ ("`spscex'" != "") &  ("`spscun'" != "") & ("`spsnex'" != "") &  ("`spsnun'" != "") ] ///
   | ("`ssbfactor'" != "")   {	
 
* From whatever prior distribution the bias parameter are coming from put the values into scalars for the final calculations


	tempname pscex  pscun psnex psnun  sbfact sel_bias_factor percent_bias adj_factor
	
	scalar `pscex' = `rn_spscex'[1]
	scalar `pscun' = `rn_spscun'[1]
	scalar `psnex' = `rn_spsnex'[1]
	scalar `psnun' = `rn_spsnun'[1]
      scalar `sbfact' = `rn_ssbfactor'[1]
	
	/*
	di "pscex = " `pscex'
	di "pscun = " `pscun'
	di "psnex ="  `psnex'
	di "psnun ="  `psnun'
	di "sbfact =" `sbfact'
	*/

	* calculate the bias-adjusted RR   
	 
	if "`ssbfactor'" == ""	scalar `sel_bias_factor' = (`pscex'*`psnun')/(`pscun'*`psnex')
	else 	scalar `sel_bias_factor' = `sbfact'

	scalar `rrdx' = `rrstep'/`sel_bias_factor' 
 
	scalar `percent_bias' = (`apprr'-`rrdx')/(`rrdx')*100  

	scalar `rrstep' = `rrdx'
	di "Adj RR step 2 = " %3.2f `rrstep'

	if ("`ssbfactor'" == "") {
	  return scalar pscex = `pscex' 
	  return scalar pscun = `pscun'
	  return scalar psnex = `psnex'
	  return scalar psnun = `psnun'
	  return scalar sbf   = 1
	}
	else {
	  return scalar pscex = 1
	  return scalar pscun = 1
	  return scalar psnex = 1
	  return scalar psnun = 1
	  return scalar sbf   = `sbfact'
	}

} // end selection bias
	
if ("`spunexp'"!="") & ( ("`spexp'"!= "") | ("`sorce'"!="") ) & ("`srrcd'"!= "") {

* From whatever prior distribution the bias parameter are coming from put the values into scalars for the final calculations

	tempname  prz1 prz0 rrdz orze rrdx rrxz  percent_bias adj_factor  

	scalar `prz1' = `rn_spexp'[1]
	scalar `prz0' = `rn_spunexp'[1]
	scalar `rrdz' = `rn_srrcd'[1]
	scalar `orze' = `rn_sorce'[1]

if ("`sorce'" == "") {	
	 scalar `rrdx' =  `rrstep' / [ (`prz1'*(`rrdz'-1)+1 )/(`prz0'*(`rrdz'-1)+1 ) ]  
}  

if ("`sorce'" != "") {	
  	 scalar `rrdx' = `rrstep'/[ (`rrdz'*`orze'*`prz0'+1-`prz0') / ( (`rrdz'*`prz0'+1-`prz0')*( `orze'*`prz0'+1-`prz0') ) ]
}

	scalar `percent_bias' = (`arrdx'-`rrdx')/(`rrdx')*100  

	scalar `rrstep' = `rrdx'

	di "Adj RR step 3 = " %3.2f `rrstep'

if ("`sorce'" != "") 	  return scalar orce = `orze'
if ("`sorce'" == "") 	  return scalar orce = [(`prz1')*(1-`prz0')]/[(1-`prz1')*(`prz0')] 

 	  return scalar pc0 =  `prz0'
 	  return scalar rrcd = `rrdz'
 	  return scalar pc1 =  `prz1'  
 	  return scalar rhoprev =  `rhoprev'  

} // end unmeasured confounding

// Saved result

return scalar adj_rr_all   = `rrstep'
return scalar perc_bias = (`apprr'-`rrstep')/`rrstep'*100
end
 
/*
set trace off
set tracedepth 1

episens_mcsa_all 45 94 257 945,  obs(5000) ///
	   sseca(Uniform .6 .8) sspca(Triangular .6 .8 .8 .9) ///
         ssenc(Trapezoidal .5 .6 .8 .9) sspnc(Logit-Normal 0 1 0.7 1) ///
         spscex(Uniform .8 1) spscun(Uniform .8 1) ///
         spsnex(Constant  .8) spsnun(Uniform .9 1) ///
	   spexp(Uniform .4 .7) spunexp(Uniform .4 .7) ///
         srrcd(Log-Normal 2.159 .280) ///
         apprr(1.76) applb(1.17) appub(2.61) studytype(cc)


episens_mcsa_all 45 94 257 945,  obs(5000) ///
	   sseca(Uniform .6 .8) sspca(Triangular .6 .8 .8 .9) ssenc(Trapezoidal .5 .6 .8 .9) sspnc(Logit-Normal 0 1 0.7 1) ///
		ssbfactor(Log-Normal 0 .207) ///
	   spexp(Uniform .4 .7) spunexp(Uniform .4 .7) srrcd(Log-Normal 2.159 .280) apprr(1.76) applb(1.17) appub(2.61) studytype(cc)
 
*/
