*! version 1.0.1  09jan2018
*! version 1.0.0  01jan2018
/*
-xtsfkk-
version 1.0.0 
January 1, 2018
Program Author: Dr. Mustafa Ugur Karakaplan
E-mail: mukarakaplan@yahoo.com
Website: www.mukarakaplan.com

Recommended Citations:

The following citations are recommended for referring to the xtsfkk
program package, underlying econometric methodology, and examples:

+ Karakaplan, Mustafa U. (2018) "xtsfkk: Stata Module for Endogenous 
Panel Stochastic Frontier Models." Available at Boston College, 
Department of Economics, Statistical Software Components (SSC) S458445.

+ Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Endogeneity in Panel
Stochastic Frontier Models." Applied Economics


More Recommended Citations:

Karakaplan, Mustafa U. (2017) "Fitting Endogenous Stochastic Frontier
Models in Stata." The Stata Journal

Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Handling Endogeneity in
Stochastic Frontier Analysis." Economics Bulletin

Karakaplan, Mustafa U. and Kutlu, Levent (2018) "School District
Consolidation Policies: Endogenous Cost Inefficiency and Saving
Reversals." Empirical Economics

Kutlu, Levent (2010) "Battese–Coelli Estimator with Endogenous 
Regressors." Economics Letters 
*/

program xtsfkk_ml

	if($exo==0) {
		args todo b lnf
		tempname lnfold
		
		// ml evaluations
		tempvar xb lnsigu2 lnsigw2
		
		mleval `xb' = `b', eq(1)
		forvalues j = 1/$p { //$p number of endogenous variables
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
		
		//matrix EST$i = `b'
		//global i = $i + 1
		//display _N
		
		if ("$savedmatrix" != "") {
			if (substr("$savedmatrix",-4,1) == ".") {
				capture copy "$savedmatrix" "$savedmatrix.old", replace
				capture matout4 `b' using "$savedmatrix", replace
			}
			else {
				capture copy "$savedmatrix.est" "$savedmatrix.est.old", replace
				capture matout4 `b' using "$savedmatrix.est", replace
			}
		}
		
		// other variables and matrices	
		local epsilons = ""
		tempvar eit muistar sigistar2 term1 Ti eit2 eidot2 hit2 hidot2 exh eidothidot lnfn //mu2
		tempname L OM OMNOM EPS term2 mu2 lnsigu2c lnsigw2c PV TV
		quietly gen double `term1' = 0 
		quietly gen double `lnfn' = 0

		scalar `mu2' = 0
		scalar `lnsigu2c' = `b'[1,colnumb(`b',"lnsig2u:_cons")]
		scalar `lnsigw2c' = `b'[1,colnumb(`b',"lnsig2w:_cons")]
		
		forvalues j = 1/$p {
			tempvar epsilon`j'				
			quietly gen double `epsilon`j'' = `=word("$ML_y",`=1+`j'')' - `zd`j'' 
			local epsilons = "`epsilons'"+"`epsilon`j'' "
			quietly replace `term1' = `term1' +  scalar(`eta`j'') * `epsilon`j'' 
		}
		
		mata: $ML_y1 = st_data(.,"$ML_y1")
		mata: `xb' = st_data(.,"`xb'")
		mata: `lnsigw2' = st_data(.,"`lnsigw2'")
		mata: `term1' = st_data(.,"`term1'")
		mata: `lnsigu2' = st_data(.,"`lnsigu2'")
		mata: `lnsigu2c' = st_numscalar("`lnsigu2c'")
		mata: `lnsigw2c' = st_numscalar("`lnsigw2c'")
		mata: `mu2' = st_numscalar("`mu2'")

		mata: `eit' = $ML_y1 - `xb' - `term1'
		mata: `eit2' = `eit':^2
		mata: `hit2' = exp(`lnsigu2') / exp(`lnsigu2c') 
		mata: `exh' = `eit' :* sqrt(`hit2')
		
		quietly xtset
		quietly sort `r(panelvar)' `r(timevar)'
		quietly by `r(panelvar)': egen double `Ti' = count(`r(timevar)')
		
		mata: `Ti' = st_data(.,"`Ti'")
				
		mata: stata("xtset",1)
		mata: `PV' = st_data(.,"`r(panelvar)'")
		mata: `TV' = st_data(.,"`r(timevar)'")
		
		mata: stata("sort `r(panelvar)'",1)
		mata: `eidot2' = 0
		mata: `hidot2' = 0
		mata: `eidothidot' = 0
		mata: totalby(`PV', `eit2', `eidot2', `hit2', `hidot2', `exh', `eidothidot')
		
		mata: `muistar' = ((exp(`lnsigw2c'):*sqrt(`mu2') :- (st_numscalar("prod") :* exp(`lnsigu2c'):*`eidothidot')):/(exp(`lnsigu2c'):*`hidot2':+exp(`lnsigw2c')))
		mata: `sigistar2' = (exp(`lnsigu2c'):*exp(`lnsigw2c')):/(exp(`lnsigu2c'):*`hidot2':+exp(`lnsigw2c'))
		
		mata: `L' = J($p,$p,0)
		mata: `L'[1,1] = st_numscalar("`le1'")		
		capture {
			capture mata: `L'[2,1] = st_numscalar("`le2'")
			capture mata: `L'[2,2] = st_numscalar("`le3'")
			capture mata: `L'[3,1] = st_numscalar("`le4'")
			capture mata: `L'[3,2] = st_numscalar("`le5'")
			capture mata: `L'[3,3] = st_numscalar("`le6'")
			capture mata: `L'[6,3] = st_numscalar("`le6'")
			capture mata: `L'[3,5] = st_numscalar("`le6'")
		}
		
		mata: `OM' = `L' * `L''
		mata: `OMNOM' = 2 * pi() * `OM'
		mata: `EPS' = st_data(.,"`epsilons'")
		mata: `term2' = invsym(`OM') * `EPS'' * `EPS'
		
		mata: `lnfn' = (-0.5:/`Ti') :* (`Ti' :* ln(2*pi()*exp(`lnsigw2c')) ///
				+ (`eidot2' :/ exp(`lnsigw2c')) + (`mu2'/exp(`lnsigu2c') :- (`muistar':^2):/`sigistar2')) ///
				+ (ln((sqrt(`sigistar2') :* normal(`muistar':/sqrt(`sigistar2'))) ///
				:/ (sqrt(exp(`lnsigu2c')) * normal(sqrt(`mu2') / sqrt(exp(`lnsigu2c'))))):/`Ti' ) ///
				:- 0.5 * (ln(det(`OMNOM')) + (trace(`term2')/st_nobs()))
		mata: st_store(., "`lnfn'",`lnfn')
		
		// ml function
		if $fastroute == 1 capture replace `lnf' = `lnfn'
		else capture mlsum `lnf' = `lnfn'
		
	
	}
	
	
	
	
	if ($exo==1) {
		args todo b lnf

		// ml evaluations
		tempvar xb lnsigu2 lnsigv2
		
		mleval `xb' = `b', eq(1)
		/*
		forvalues j = 1/$p { //$p number of endogenous variables
			tempvar zd`j' 
			tempname eta`j'
			mleval `zd`j'' = `b', eq(`=`j'*2')
			mleval `eta`j'' =  `b', eq(`=`j'*2+1') scalar
		}*/		
		mleval `lnsigu2' = `b', eq(2)
		mleval `lnsigv2' = `b', eq(3)
		/*
		forvalues j = 1/`=($p*($p+1))/2' {
			tempname le`j'
			mleval `le`j'' = `b', eq(`=$p*2+3+`j'') scalar
		}*/
	
		// other variables and matrices	
		//local epsilons = ""
		tempvar eit muistar sigistar2 term1 Ti eit2 eidot2 hit2 hidot2 exh eidothidot lnfn //mu2
		tempname L OM OMNOM EPS term2 mu2 lnsigu2c lnsigv2c PV TV
		//quietly gen double `term1' = 0 
		quietly gen double `lnfn' = 0

		scalar `mu2' = 0
		scalar `lnsigu2c' = `b'[1,colnumb(`b',"lnsig2u:_cons")]
		scalar `lnsigv2c' = `b'[1,colnumb(`b',"lnsig2v:_cons")]
		
		/*
		forvalues j = 1/$p {
			tempvar epsilon`j'				
			quietly gen double `epsilon`j'' = `=word("$ML_y",`=1+`j'')' - `zd`j'' 
			local epsilons = "`epsilons'"+"`epsilon`j'' "
			quietly replace `term1' = `term1' +  scalar(`eta`j'') * `epsilon`j'' 
		}*/
		
		mata: $ML_y1 = st_data(.,"$ML_y1")
		mata: `xb' = st_data(.,"`xb'")
		mata: `lnsigv2' = st_data(.,"`lnsigv2'")
		//mata: `term1' = st_data(.,"`term1'")
		mata: `lnsigu2' = st_data(.,"`lnsigu2'")
		mata: `lnsigu2c' = st_numscalar("`lnsigu2c'")
		mata: `lnsigv2c' = st_numscalar("`lnsigv2c'")
		mata: `mu2' = st_numscalar("`mu2'")

		mata: `eit' = $ML_y1 - `xb' //- sqrt(exp(`lnsigv2')) //- `term1'
		mata: `eit2' = `eit':^2
		mata: `hit2' = exp(`lnsigu2') / exp(`lnsigu2c') 
		mata: `exh' = `eit' :* sqrt(`hit2')
		
		quietly xtset
		quietly sort `r(panelvar)' `r(timevar)'
		quietly by `r(panelvar)': egen double `Ti' = count(`r(timevar)')
		
		mata: `Ti' = st_data(.,"`Ti'")
				
		mata: stata("xtset",1)
		mata: `PV' = st_data(.,"`r(panelvar)'")
		mata: `TV' = st_data(.,"`r(timevar)'")
		
		mata: stata("sort `r(panelvar)'",1)
		mata: `eidot2' = 0
		mata: `hidot2' = 0
		mata: `eidothidot' = 0
		mata: totalby(`PV', `eit2', `eidot2', `hit2', `hidot2', `exh', `eidothidot')
		
		mata: `muistar' = ((exp(`lnsigv2c'):*sqrt(`mu2') :- (st_numscalar("prod") :* exp(`lnsigu2c'):*`eidothidot')):/(exp(`lnsigu2c'):*`hidot2':+exp(`lnsigv2c')))
		mata: `sigistar2' = (exp(`lnsigu2c'):*exp(`lnsigv2c')):/(exp(`lnsigu2c'):*`hidot2':+exp(`lnsigv2c'))
		
		/*
		mata: `L' = J($p,$p,0)
		mata: `L'[1,1] = st_numscalar("`le1'")		
		capture {
			capture mata: `L'[2,1] = st_numscalar("`le2'")
			capture mata: `L'[2,2] = st_numscalar("`le3'")
			capture mata: `L'[3,1] = st_numscalar("`le4'")
			capture mata: `L'[3,2] = st_numscalar("`le5'")
			capture mata: `L'[3,3] = st_numscalar("`le6'")
			capture mata: `L'[6,3] = st_numscalar("`le6'")
			capture mata: `L'[3,5] = st_numscalar("`le6'")
		}
		
		mata: `OM' = `L' * `L''
		mata: `OMNOM' = 2 * pi() * `OM'
		mata: `EPS' = st_data(.,"`epsilons'")
		mata: `term2' = invsym(`OM') * `EPS'' * `EPS'
		*/
		
		mata: `lnfn' = (-0.5:/`Ti') :* (`Ti' :* ln(2*pi()*exp(`lnsigv2c')) ///
				+ (`eidot2' :/ exp(`lnsigv2c')) + (`mu2'/exp(`lnsigu2c') :- (`muistar':^2):/`sigistar2')) ///
				+ (ln((sqrt(`sigistar2') :* normal(`muistar':/sqrt(`sigistar2'))) ///
				:/ (sqrt(exp(`lnsigu2c')) * normal(sqrt(`mu2') / sqrt(exp(`lnsigu2c'))))):/`Ti' ) 
				
				///
				
				//:- 0.5 * (ln(det(`OMNOM')) + (trace(`term2')/st_nobs()))
		mata: st_store(., "`lnfn'",`lnfn')

		// ml function
		if $fastroute == 1 capture replace `lnf' = `lnfn'
		else capture mlsum `lnf' = `lnfn'
		
	}
	
	
end 


mata:
	void totalby(vector id, vector in1, vector out1, vector in2, vector out2, vector in3, vector out3) {
	V = panelsetup(id, 1)
	out1 = J(rows(id),cols(id),.)
	out2 = J(rows(id),cols(id),.)
	out3 = J(rows(id),cols(id),.)
	for (i=1; i<=rows(V); i++) {
		X1 = panelsubmatrix(in1, i, V)
		out1[V[i,1]::V[i,2],.]=J(rows(X1),1,colsum(X1))
		X2 = panelsubmatrix(in2, i, V)
		out2[V[i,1]::V[i,2],.]=J(rows(X2),1,colsum(X2))
		X3 = panelsubmatrix(in3, i, V)
		out3[V[i,1]::V[i,2],.]=J(rows(X3),1,colsum(X3))
		}
	}
end




