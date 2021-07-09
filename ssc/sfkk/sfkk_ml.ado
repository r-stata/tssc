*! version 2.0.0  25oct2016
*! version 1.0.4  02jun2016
*! version 1.0.3  25oct2015
*! version 1.0.2  11sep2015
*! version 1.0.1  03jul2015
*! version 1.0.0  01jun2015
/*
-sfkk-
version 1.0.0 
June 1, 2015
Program Author: Dr. Mustafa Ugur Karakaplan
E-mail: mukarakaplan@yahoo.com
Website: www.mukarakaplan.com

Recommended Citations:

The following two citations are recommended for referring to the sfkk program
package and the underlying econometric methodology:

Karakaplan, Mustafa U. (2016) "Estimating Endogenous Stochastic Frontier Models
in Stata." Forthcoming. The Stata Journal.  Also available at www.mukarakaplan.com

Karakaplan, Mustafa U. and Kutlu, Levent (2013) "Handling Endogeneity in 
Stochastic Frontier Analysis." Available at www.mukarakaplan.com
*/

program sfkk_ml

	if($exo==0) {
		args todo b lnf

		// ml evaluations
		tempvar xb lnsigu2 lnsigw2
		
		mleval `xb' = `b', eq(1)
		forvalues j = 1/$p {
			tempvar zd`j' 
			tempname eta`j'
			mleval `zd`j'' = `b', eq(`=`j'*2')
			mleval `eta`j'' =  `b', eq(`=`j'*2+1') scalar
		}
		mleval `lnsigu2' = `b', eq(`=$p*2+2')
		mleval `lnsigw2' = `b', eq(`=$p*2+3')
		forvalues j = 1/`=($p*($p+1))/2' {
			tempname le`j'
			mleval `le`j'' = `b', eq(`=$p*2+3+`j'') scalar
		}	

		// other variables and matrices	
		local epsilons = ""
		tempvar ei sigs2 term1 lnfn
		tempname L OM EPS term2 lnsigw2c  
		scalar `lnsigw2c' = `b'[1,colnumb(`b',"lnsig2w:_cons")]
		quietly gen double `term1' = 0 
		quietly gen double `lnfn' = 0

		forvalues j = 1/$p {
			tempvar epsilon`j'				
			quietly gen double `epsilon`j'' = `=word("$ML_y",`=1+`j'')' - `zd`j'' 
			local epsilons = "`epsilons'"+"`epsilon`j'' "
			quietly replace `term1' = `term1' +  (1/sqrt(exp(`lnsigw2c'))) * scalar(`eta`j'') * `epsilon`j'' 
		}		
		
		mata: $ML_y1 = st_data(.,"$ML_y1")
		mata: `xb' = st_data(.,"`xb'")
		mata: `lnsigw2' = st_data(.,"`lnsigw2'")
		mata: `term1' = st_data(.,"`term1'")
		mata: `lnsigu2' = st_data(.,"`lnsigu2'")
		mata: `ei' = $ML_y1 - `xb' -  sqrt(exp(`lnsigw2')) :* `term1' 
		mata: `sigs2' = exp(`lnsigw2') + exp(`lnsigu2') 			  
		mata: `L' = J($p,$p,0)
		mata: `L'[1,1] = st_numscalar("`le1'")
		capture {
			mata: `L'[2,1] = st_numscalar("`le2'")
			mata: `L'[2,2] = st_numscalar("`le3'")
			mata: `L'[3,1] = st_numscalar("`le4'")
			mata: `L'[3,2] = st_numscalar("`le5'")
			mata: `L'[3,3] = st_numscalar("`le6'")
			mata: `L'[6,3] = st_numscalar("`le6'")
			mata: `L'[3,5] = st_numscalar("`le6'")
		}
		mata: `OM' = `L' * `L''
		mata: `EPS' = st_data(.,"`epsilons'")
		mata: `term2' = invsym(`OM') * `EPS'' * `EPS'
		mata: `lnfn' = 0.5 * (ln(2/pi()) :- ln(`sigs2') :- (`ei':^2:/`sigs2')) ///
				+ ln(normal((-1 * st_numscalar("prod") * (sqrt(exp(`lnsigu2')) :/ sqrt(exp(`lnsigw2'))) :* `ei') ///
				:/ sqrt(`sigs2'))) :+ 0.5 * (-$p * ln(2*pi()) - ln(det(`OM')) - (trace(`term2')/st_nobs()))
		mata: st_store(., "`lnfn'",`lnfn')
		
		// ml function
		if $fastroute == 1 capture replace `lnf' = `lnfn'
		else capture mlsum `lnf' = `lnfn'
	}
	
	
	if($exo==1) {
		args todo b lnf

		// ml evaluations
		tempvar xb lnsigu2 lnsigv2
		
		mleval `xb' = `b', eq(1)
		mleval `lnsigu2' = `b', eq(2)
		mleval `lnsigv2' = `b', eq(3)

		// other variables and matrices	
		tempvar ei sigs2 lnfn
		quietly gen double `lnfn' = 0
		
		mata: $ML_y1 = st_data(.,"$ML_y1")
		mata: `xb' = st_data(.,"`xb'")
		mata: `lnsigv2' = st_data(.,"`lnsigv2'")
		mata: `lnsigu2' = st_data(.,"`lnsigu2'")
		mata: `ei' = $ML_y1 - `xb' -  sqrt(exp(`lnsigv2'))   
		mata: `sigs2' = exp(`lnsigv2') + exp(`lnsigu2') 			  
		mata: `lnfn' = 0.5 * (ln(2/pi()) :- ln(`sigs2') :- (`ei':^2:/`sigs2')) ///
				+ ln(normal((-1 * st_numscalar("prod") * (sqrt(exp(`lnsigu2')) :/ sqrt(exp(`lnsigv2'))) :* `ei') ///
				:/ sqrt(`sigs2'))) 
		mata: st_store(., "`lnfn'",`lnfn')
				
		// ml function
		if $fastroute == 1 capture replace `lnf' = `lnfn'
		else capture mlsum `lnf' = `lnfn'
	}

	
	
end 
