*** Last modified 11th October 2005

program define intcens_ll
version 8.2

local t0 "$ML_y1"
local t1 "$ML_y2"
local f "$ML_y3"

quietly{
	if "$intcens_maxm"=="lf"{
		if "$intcens_dist"=="logn"{
			args lnf xb logsigma
			tempvar sigma   
			gen double `sigma'=exp(`logsigma') if $ML_samp
			replace `lnf'=log(normden(log(`t0'), `xb', `sigma')) if `f'==1&$ML_samp
			replace `lnf'=log(norm(-(log(`t0')-`xb')/`sigma')) if `f'==2&$ML_samp
			replace `lnf'=log(norm((log(`t1')-`xb')/`sigma')) if `f'==3&$ML_samp
			replace `lnf'=log(norm((log(`t1')-`xb')/`sigma')-norm((log(`t0')-`xb')/`sigma')) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="logl"{
			args lnf xb loggamma
			tempvar gamma lambda
			gen double `gamma'=exp(`loggamma') if $ML_samp
			gen double `lambda'=exp(-`xb'/`gamma') if $ML_samp
			replace `lnf'=-`xb'/`gamma'+(1/`gamma')*log(`t0')-`loggamma'-2*log(1+`lambda'*(`t0')^(1/`gamma')) if `f'==1&$ML_samp
			replace `lnf'=-log(1+`lambda'*(`t0')^(1/`gamma')) if `f'==2&$ML_samp
			replace `lnf'=-log(1+(`lambda')^(-1)*(`t1')^(-1/`gamma')) if `f'==3&$ML_samp
			replace `lnf'=log(1/(1+`lambda'*(`t0')^(1/`gamma'))-1/(1+`lambda'*(`t1')^(1/`gamma'))) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="exp"{
			args lnf xb 
			tempvar lambda
			gen double `lambda'=exp(-`xb') if $ML_samp
			replace `lnf'=-`xb'-`lambda'*`t0'+log(`t0') if `f'==1&$ML_samp
			replace `lnf'=-`lambda'*`t0' if `f'==2&$ML_samp
			replace `lnf'=log(1-exp(-`lambda'*`t1')) if `f'==3&$ML_samp
			replace `lnf'=log(exp(-`lambda'*`t0')-exp(-`lambda'*`t1')) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="weib"{
			args lnf xb logp
			tempvar lambda p
			gen double `p'=exp(`logp') if $ML_samp
			gen double `lambda'=exp(-`xb'*`p') if $ML_samp
			replace `lnf'=-`xb'*`p'+`logp'+`p'*log(`t0')-`lambda'*(`t0')^`p' if `f'==1&$ML_samp
			replace `lnf'=-`lambda'*(`t0')^`p' if `f'==2&$ML_samp
			replace `lnf'=log(1-exp(-`lambda'*(`t1')^`p')) if `f'==3&$ML_samp
			replace `lnf'=log(exp(-`lambda'*(`t0')^`p')-exp(-`lambda'*(`t1')^`p')) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="gam"{
			args lnf xb logalpha
			tempvar lambda alpha
			gen double `alpha'=exp(`logalpha') if $ML_samp
			gen double `lambda'=exp(-`xb') if $ML_samp
			replace `lnf'=-`xb'*`alpha'+`alpha'*log(`t0')-`lambda'*`t0'-lngamma(`alpha') if `f'==1&$ML_samp
			replace `lnf'=log(1-gammap(`alpha', `lambda'*`t0')) if `f'==2&$ML_samp
			replace `lnf'=log(gammap(`alpha', `lambda'*`t1')) if `f'==3&$ML_samp
			replace `lnf'=log(gammap(`alpha', `lambda'*`t1')-gammap(`alpha', `lambda'*`t0')) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="gen"{
			args lnf xb logsigma  kappa1
			tempvar sigma gamma firstml
			tempname kappa
			gen byte `firstml'=0
			replace `firstml'=sum($ML_samp) if `firstml'[_n-1]==0|_n==1
			su `kappa1' if  `firstml'==1, meanonly
			scalar `kappa'=r(min)
			gen double `sigma'=exp(`logsigma') if $ML_samp
			gen double `gamma'=1/(`kappa')^2 if $ML_samp
			if abs(`kappa')<=1E-6{
				local sign=1
			}
			else{
				local sign=sign(`kappa')
			}
			forval i=0/1{
				tempvar z`i' u`i' 
				gen double `z`i''=`sign'*(log(`t`i'')-`xb')/`sigma' if $ML_samp
				gen double `u`i''=`gamma'*exp(abs(`kappa')*`z`i'') if $ML_samp
			}
			if abs(`kappa')>1E-6{
				replace `lnf'=-2*(`gamma'-0.5)*log(abs(`kappa'))+`z0'/abs(`kappa')-`u0'-`logsigma'-lngamma(`gamma') if `f'==1&$ML_samp
				if `kappa'>1E-6{
					replace `lnf'=log(1-gammap(`gamma', `u0')) if `f'==2&$ML_samp
					replace `lnf'=log(gammap(`gamma', `u1')) if `f'==3&$ML_samp
					replace `lnf'=log(gammap(`gamma',`u1')-gammap(`gamma',`u0')) if `f'==4&$ML_samp
				}
				else if `kappa'<-1E-6{
					replace `lnf'=log(gammap(`gamma', `u0')) if `f'==2&$ML_samp
					replace `lnf'=log(1-gammap(`gamma', `u1')) if `f'==3&$ML_samp
					replace `lnf'=log(gammap(`gamma',`u0')-gammap(`gamma',`u1')) if `f'==4&$ML_samp
				}
			}
			else if abs(`kappa')<=1E-6{
				replace `lnf'=log(normden(`z0'))-`logsigma' if `f'==1&$ML_samp
				replace `lnf'=log(norm(-`z0')) if `f'==2&$ML_samp
				replace `lnf'=log(norm(`z1')) if `f'==3&$ML_samp
				replace `lnf'=log(norm(`z1')-norm(`z0')) if `f'==4&$ML_samp
			}
		}
		else if "$intcens_dist"=="gomp"{
			args lnf xb gamma1 
			tempvar lambda firstml
			gen double `lambda'=exp(`xb') if $ML_samp
			tempname gamma
			gen byte `firstml'=0
			replace `firstml'=sum($ML_samp) if `firstml'[_n-1]==0|_n==1
			su `gamma1' if  `firstml'==1, meanonly
			scalar `gamma'=r(min)
			if abs(`gamma')<=1E-6{
				replace `lnf'=`xb'-`lambda'*`t0'+log(`t0') if `f'==1&$ML_samp
				replace `lnf'=-`lambda'*`t0' if `f'==2&$ML_samp
				replace `lnf'=log(1-exp(-`lambda'*`t1')) if `f'==3&$ML_samp
				replace `lnf'=log(exp(-`lambda'*`t0')-exp(-`lambda'*`t1')) if `f'==4&$ML_samp
			}
			else{
				replace `lnf'=`xb'+`gamma'*`t0'-(`lambda'/`gamma')*(exp(`gamma'*`t0')-1)+log(`t0') if `f'==1&$ML_samp
				replace `lnf'=-(`lambda'/`gamma')*(exp(`gamma'*`t0')-1) if `f'==2&$ML_samp
				replace `lnf'=log(1-exp(-(`lambda'/`gamma')*(exp(`gamma'*`t1')-1))) if `f'==3&$ML_samp
				replace `lnf'=log(exp(-(`lambda'/`gamma')*(exp(`gamma'*`t0')-1))-exp(-(`lambda'/`gamma')*(exp(`gamma'*`t1')-1))) if `f'==4&$ML_samp
			}
		}
		
		else if "$intcens_dist"=="invg"{
			args lnf xb logphi
			tempvar eta phi
			gen double `eta'=exp(`xb') if $ML_samp
			gen double `phi'=exp(`logphi') if $ML_samp
			replace `lnf'=-(`logphi'+log(`t0'))/2-(`t0'-`eta')^2/(2*(`eta')^2*`t0'*`phi') if `f'==1&$ML_samp
			replace `lnf'=log(norm(sqrt(1/(`t0'*`phi'))*(1-`t0'/`eta')) /*
			*/ -exp(2/(`eta'*`phi'))*norm(-sqrt(1/(`t0'*`phi'))*(`t0'/`eta'+1))) if `f'==2&$ML_samp
			replace `lnf'=log(1-norm(sqrt(1/(`t1'*`phi'))*(1-`t1'/`eta')) /*
			*/ +exp(2/(`eta'*`phi'))*norm(-sqrt(1/(`t1'*`phi'))*(`t1'/`eta'+1))) if `f'==3&$ML_samp
			replace `lnf'=log(norm(sqrt(1/(`t0'*`phi'))*(1-`t0'/`eta'))- norm(sqrt(1/(`t1'*`phi'))*(1-`t1'/`eta')) /*
			*/ +exp(2/(`eta'*`phi'))*(norm(-sqrt(1/(`t1'*`phi'))*(`t1'/`eta'+1))-norm(-sqrt(1/(`t0'*`phi'))*(`t0'/`eta'+1)))) if `f'==4&$ML_samp
		}
		
		else if "$intcens_dist"=="wien"{
			args lnf xb logc
			tempvar mu c eta phi logphi
			gen double `mu'=exp(`xb') if $ML_samp
			gen double `c'=exp(`logc') if $ML_samp
			gen double `eta'=`c'/`mu' if $ML_samp
			gen double `phi'=1/(`c')^2 if $ML_samp
			gen double `logphi'=-2*`logc' if $ML_samp
			replace `lnf'=-(`logphi'+log(`t0'))/2-(`t0'-`eta')^2/(2*(`eta')^2*`t0'*`phi') if `f'==1&$ML_samp
			replace `lnf'=log(norm(sqrt(1/(`t0'*`phi'))*(1-`t0'/`eta')) /*
			*/ -exp(2/(`eta'*`phi'))*norm(-sqrt(1/(`t0'*`phi'))*(`t0'/`eta'+1))) if `f'==2&$ML_samp
			replace `lnf'=log(1-norm(sqrt(1/(`t1'*`phi'))*(1-`t1'/`eta')) /*
			*/ +exp(2/(`eta'*`phi'))*norm(-sqrt(1/(`t1'*`phi'))*(`t1'/`eta'+1))) if `f'==3&$ML_samp
			replace `lnf'=log(norm(sqrt(1/(`t0'*`phi'))*(1-`t0'/`eta'))- norm(sqrt(1/(`t1'*`phi'))*(1-`t1'/`eta'))+exp(2/(`eta'*`phi'))* /*
			*/ (norm(-sqrt(1/(`t1'*`phi'))*(`t1'/`eta'+1))-norm(-sqrt(1/(`t0'*`phi'))*(`t0'/`eta'+1)))) if `f'==4&$ML_samp
		}
		else if "$intcens_dist"=="wienran"{
			args lnf xb logc logtau
			tempvar mu c tau
			gen double `mu'=exp(`xb') if $ML_samp
			gen double `c'=exp(`logc') if $ML_samp
			gen double `tau'=exp(`logtau') if $ML_samp
			forval i=0/1{
				tempvar u`i'
				gen double `u`i''=(`t`i''*`tau')^2+`t`i'' if $ML_samp
			}
			replace `lnf'=`logc'-0.5*log(`u0')-(`mu'*`t0'-`c')^2/(2*`u0') if `f'==1&$ML_samp
			replace `lnf'=log(norm((`c'-`mu'*`t0')/sqrt(`u0'))-exp(2*`c'*`mu'+2*(`c'*`tau')^2)* /*
			*/ norm(-(`c'+2*`c'*`t0'*(`tau')^2+`mu'*`t0')/sqrt(`u0'))) if `f'==2&$ML_samp
			replace `lnf'=log(norm(-(`c'-`mu'*`t1')/sqrt(`u1'))+exp(2*`c'*`mu'+2*(`c'*`tau')^2)* /*
			*/ norm(-(`c'+2*`c'*`t1'*(`tau')^2+`mu'*`t1')/sqrt(`u1'))) if `f'==3&$ML_samp
			replace `lnf'=log(norm((`c'-`mu'*`t0')/sqrt(`u0'))+exp(2*`c'*`mu'+2*(`c'*`tau')^2)*(norm(-(`c'+2*`c'*`t1'*(`tau')^2+`mu'*`t1')/sqrt(`u1')) /*
			*/ -norm(-(`c'+2*`c'*`t0'*(`tau')^2+`mu'*`t0')/sqrt(`u0')))-norm((`c'-`mu'*`t1')/sqrt(`u1'))) if `f'==4&$ML_samp
		}
		
		exit
	} /* end of lf method */
	
	else{ /* method d2, only written for 2-parameter gamma */
		if "$intcens_dist"=="gam"{
			args todo b lnf g negH g1 g2
			tempvar ll theta1 lambda
			tempname theta2 alpha
			gen double `ll'=. 
			mleval `theta1'=`b', eq(1)
			mleval `theta2'=`b', eq(2) scalar 
			gen double `lambda'=exp(-`theta1') if $ML_samp
			scalar `alpha'=exp(`theta2')
			forval i=0/1{
				tempvar P`i' lt`i'
				gen double `lt`i''=`lambda'*`t`i'' if $ML_samp
				gen double `P`i''=gammap(`alpha', `lt`i'')  if $ML_samp
			}   
			
			replace `ll'=-`theta1'*`alpha'+`alpha'*log(`t0')-`lt0'-lngamma(`alpha') if `f'==1&$ML_samp
			replace `ll'=log(1-`P0') if `f'==2&$ML_samp
			replace `ll'=log(`P1') if `f'==3&$ML_samp
			replace `ll'=log(`P1'-`P0') if `f'==4&$ML_samp
			
			mlsum `lnf'=`ll'
			if (`todo'==0|`lnf'>=.) exit
			
			/************************************************************************
			************************************************************************/
			tempname d1 d2
			tempvar  dlambda dalpha 
			gen double `dlambda'=.  if $ML_samp
			gen double `dalpha'=. if $ML_samp
			
			replace `dlambda'=`alpha'/`lambda'-`t0' if `f'==1&$ML_samp
			replace `dalpha'=-`theta1'+log(`t0')-digamma(`alpha') if `f'==1&$ML_samp
			replace `dlambda'=-`t0'*dgammapdx(`alpha',`lt0')/(1-`P0') if `f'==2&$ML_samp
			replace `dalpha'=-dgammapda(`alpha',`lt0')/(1-`P0') if `f'==2&$ML_samp
			replace `dlambda'=`t1'*dgammapdx(`alpha',`lt1')/`P1' if `f'==3&$ML_samp
			replace `dalpha'=dgammapda(`alpha',`lt1')/`P1' if `f'==3&$ML_samp
			replace `dlambda'=(`t1'*dgammapdx(`alpha',`lt1')-`t0'*dgammapdx(`alpha',`lt0'))/(`P1'-`P0') if `f'==4&$ML_samp
			replace `dalpha'=(dgammapda(`alpha',`lt1')-dgammapda(`alpha',`lt0'))/(`P1'-`P0') if `f'==4&$ML_samp
			replace `g1'=-`lambda'*`dlambda' if $ML_samp
			replace `g2'=`alpha'*`dalpha'  if $ML_samp
			
			mlvecsum `lnf' `d1'=`g1', eq(1)
			mlvecsum `lnf' `d2'=`g2', eq(2)
			matrix `g'=(`d1', `d2')
			
			if (`todo'==1|`lnf'>=.) exit
			
			/************************************************************************
			************************************************************************/
			tempname d11 d12 d22
			tempvar dtheta11 dtheta12 dtheta22 d2lambda dlambdaalpha d2alpha 
			gen double `d2lambda'=.
			gen double `dlambdaalpha'=.
			gen double `d2alpha'=.
			replace `d2lambda'=-`alpha'/(`lambda')^2 if `f'==1&$ML_samp
			replace `dlambdaalpha'=1/`lambda' if `f'==1&$ML_samp
			replace `d2alpha'=-trigamma(`alpha') if `f'==1&$ML_samp
			replace `d2lambda'=-(`t0')^2*dgammapdxdx(`alpha',`lt0')/(1-`P0')-(`dlambda')^2  if `f'==2&$ML_samp
			replace `dlambdaalpha'=-`t0'*dgammapdadx(`alpha',`lt0')/(1-`P0')-`dlambda'*`dalpha'  if `f'==2&$ML_samp
			replace `d2alpha'=-dgammapdada(`alpha',`lt0')/(1-`P0')-(`dalpha')^2  if `f'==2&$ML_samp
			replace `d2lambda'=(`t1')^2*dgammapdxdx(`alpha',`lt1')/`P1'-(`dlambda')^2 if `f'==3&$ML_samp
			replace `dlambdaalpha'=`t1'*dgammapdadx(`alpha',`lt1')/`P1'-`dlambda'*`dalpha' if `f'==3&$ML_samp
			replace `d2alpha'=dgammapdada(`alpha',`lt1')/`P1'-(`dalpha')^2 if `f'==3&$ML_samp
			replace `d2lambda'=((`t1')^2*dgammapdxdx(`alpha',`lt1')-(`t0')^2*dgammapdxdx(`alpha',`lt0'))/(`P1'-`P0')-(`dlambda')^2 if `f'==4&$ML_samp
			replace `dlambdaalpha'=(`t1'*dgammapdadx(`alpha',`lt1')-`t0'*dgammapdadx(`alpha',`lt0'))/(`P1'-`P0')-`dlambda'*`dalpha' if `f'==4&$ML_samp
			replace `d2alpha'=(dgammapdada(`alpha',`lt1')-dgammapdada(`alpha',`lt0'))/(`P1'-`P0')-(`dalpha')^2  if `f'==4&$ML_samp
			 
			gen double `dtheta11'=-`g1'+(`lambda')^2*`d2lambda'  if $ML_samp
			gen double `dtheta12'=-`lambda'*`alpha'*`dlambdaalpha'  if $ML_samp
			gen double `dtheta22'=`g2'+(`alpha')^2*`d2alpha'  if $ML_samp
			
			mlmatsum `lnf' `d11'=-`dtheta11', eq(1)
			mlmatsum `lnf' `d12'=-`dtheta12', eq(1,2)
			mlmatsum `lnf' `d22'=-`dtheta22', eq(2)
			matrix `negH'=(`d11', `d12' \ `d12'', `d22')
		} 
	}

} 

end
