

*! version 1.0.4 20sept2019
		
		program define rho_xtregar, rclass
		version 10
		tempvar K Ki prem NbrindvN ni lemaxni num yhat utilde tempdnum0 /*
			*/ tempdnum1 dnum tempddenom1 ddnom WIndiv1 WIndiv2
        tempname tdelta final Windiv1 Windiv2
		
        syntax varlist(fv ts) [if] [using/] [, approx approx_balanced approx_unbalanced option_nodisplay]
		
				
		if "`weight'" != "" {
                local weights "weights"
                        di as error "no option for weights so far"
                        exit 198
        }
        else {
                local weights ""
        }
	
		
		//The preserve is not done for the if condition in itself
		quietly: preserve		
		if "`using'"!="" {
			quietly: use `using', clear
		}	
		if "`if'"!="" {
			quietly: keep `if'
		}
				
		 _xt, trequired
        local id "`r(ivar)'"
        local t  "`r(tvar)'"
        scalar `tdelta' = r(tdelta)
		
		gettoken depvar xvars : varlist

		
		quietly {
		
		
		*****************************
		//definition of the Ki
			bysort `id': gen K = (`t'[_n-1]==`t'[_n]-`tdelta') if  _n!=1
			bysort `id': egen Ki=total(K)
			bysort `id': gen prem = (_n==1) //premier means first in French
		}
		
		if "`option_nodisplay'"=="" {
			quietly {
			egen WIndiv1 = total(prem)
			local Windiv1 = WIndiv1[1]
			egen WIndiv2 = total(prem*(Ki>0 & Ki!=.))
			local Windiv2 = WIndiv2[1]
			}
		dis "There are `Windiv1' units, over which `Windiv2' have at least two successive observations"
		}
		//
		
		quietly {
		*****************************
		//erasing those that never have two successive observations		
		drop if Ki==0 
		
		
		//Total Number of individuals
			egen double NbrindvN= total(prem)
			local the_NbrindvN = NbrindvN[1]
		//sometimes useful: ni and maxni 
		bysort `id': gen ni = _N
		egen double lemaxni = max(ni)
			local the_maxni = lemaxni[1]
		//and to get vecN2:=(n_1^2, (...), n_N^2):
			gsort -prem +`id'
			order ni
			mata: vecN1 = st_data((1,`the_NbrindvN'), 1) 
			mata: vecN2=power(2,vecN1)  
			sort `id' `t'
		
		*****************************
		*term at the numerator (save 1-rho)
		egen double num = total(prem * Ki /(1+Ki))
		replace num =  num / `the_NbrindvN'
		local the_num = num[1]
		
		*****************************
		*estimate of r_d		
		//THESE TWO LINES SHOULD BE SPEED UP
		xtreg `depvar' `xvars', fe	
		predict yhat, xbu 
		gen utilde = `depvar' - yhat	
		//the numerateur	
			gen double tempdnum0 = 0
			bysort `id': replace tempdnum0 = ((utilde[_n]-utilde[_n-1])^2) ///
						if _n!=1 & (`t'[_n-1]==`t'[_n]-`tdelta')
			bysort `id': egen tempdnum1 = total(tempdnum0)
			bysort `id': replace tempdnum1 = tempdnum1 * prem / (1+Ki)
			egen double dnum = total(tempdnum1)
			local the_dnum = dnum[1]
		//the denominateor
			gen double tempddenom0 = utilde*utilde	
				bysort `id': egen tempddenom1 = total(tempddenom0)
				bysort `id': replace tempddenom1 = tempddenom1 * prem / ni
			egen double ddnom = total(tempddenom1)
			local the_ddnom = ddnom[1]
		// final: r_d = 1-d/2
		local the_rhod= 	1-0.5*`the_dnum' / `the_ddnom'
				
		//the general case
			if ("`approx'"=="") & ("`approx_unbalanced'"=="") & ("`approx_balanced'"=="") {
				
				***********
				//estimate of A, mata matrix of size(`the_NbrindvN',`the_maxni'*`the_maxni')
				//whith the exponents for the rho	
				keep `id' `t' ni lemaxni
				forvalues i = 1/`the_maxni' {
					forvalues j = 1/`the_maxni' {
					quietly{
						gen double coeff_`i'_`j' = .
							bysort `id': replace coeff_`i'_`j' = abs(`t'[`i']-`t'[`j'])/`tdelta' if max(`i',`j')<=ni
					}
					//
					}
					//
				}
				//
				bysort `id': keep if _n==1
				drop `id' `t' ni lemaxni
				mata: A = st_data(., .)	
				**********
				//almost done:
				//definition of MATA function pourE below the main program
			
				**********
				//preparing the optimisation
					mata: myrhoD = `the_rhod'
					mata: mynum = `the_num'
					mata: myNbrindvN  = `the_NbrindvN'	
				//definition of MATA function funcfinal below the main program
				//the optimisation
				mata: mm_root(r=.,&funcfinal(), -1.1, 1.1, 0, 1000,myrhoD,mynum,myNbrindvN,A,vecN2) 
				mata: r
				mata: st_numscalar("final",r)
				restore
			}
			//
		
		
		//with option approx 
			if ("`approx'"!="") | ("`approx_unbalanced'"!="") | ("`approx_balanced'"!="") {			
				restore 
				preserve		
				
					if "`using'"!="" {
						quietly: use `using', clear
					}	
					if "`if'"!="" {
						quietly: keep `if'
					}
				
				xtset 
				local balancing = r(balanced)
				local tmax=r(tmaxs)
				local tmin=r(tmins)
				local thegrandT = `tmax'-`tmin'
			
				//balanced case
				if inlist("`balancing'","weakly balanced","strongly balanced") | "`approx_balanced'"!="" {
					scalar final = `the_rhod'/(1-2/`thegrandT')
				}
				//	
			
				//unbalanced case
				if inlist("`balancing'","unbalanced") | "`approx_unbalanced'"!="" {	
						scalar final = (`the_rhod'-1+`the_num')/`the_num'			
				}
				//
			restore
			}
			//
		
		}
		//end of the quietly
			
		dis "*******   rho_BFN  =  " final
		
		return scalar rho_BFN = final 
		end
	

		
		//MATA functions used in the program
		mata: function power(a,r) return (exp(ln(r)*a))		
		mata: function pourE(A,r,vecN2,N) return (sum(power(A,r):/vecN2)/N)
		mata: function funcfinal(r,rhoD,lenum,leNbrindvN,A,vecN2) ///
			return (rhoD-1+((1-r)*lenum)/(1-pourE(A,r,vecN2,leNbrindvN)))
		
		
	
		