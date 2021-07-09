*! mtefe_gendata v1.82 28may2018
* Author: Martin Eckhoff Andresen
* This program is part of the mtefe package.

cap program drop mtefe_gendata
{
	program define mtefe_gendata, rclass
		version 13.0
		syntax , [parameters(namelist min=4 max=5) fixedeffects(namelist min=3 max=3)  /*
			*/ obs(integer 5000) POLynomial(integer 0) link(string) districts(integer 0)]
		
		qui {
			clear
			
			//Check input
			if "`link'"!="" {
				if !inlist("`link'","lpm","probit") {
					noi di in red "Link() must be probit or lpm."
					exit 301
					}
				}
			else loc link probit
			
			tempname U0 U1 V index gamma beta0 beta1 pi pi0 pi1
			if "`parameters'"!="" {
				gettoken gammaname rest: parameters
				confirm matrix `gammaname'
				mat `gamma'=`gammaname'
				gettoken beta0name rest: rest
				confirm matrix `beta0name'
				mat `beta0'=`beta0name'
				gettoken beta1name rest: rest
				confirm matrix `beta1name'
				mat `beta1'=`beta1name'
				
				if colsof(`gamma')!=colsof(`beta1')+1|colsof(`beta1')!=colsof(`beta0')|colsof(`beta1')<`=`numX'+1' {
					noi di in red "Matrix beta0, beta1 or gamma of wrong dimensions - should be 1 x K for betas and 1 x K+1 for gamma."
					exit 301
					}
				local numpi: word count `rest'
				if `numpi'==1&`polynomial'!=0|`numpi'==2&`polynomial'<=0 {
					noi di in red "Specify either variance-covariance matrix for joint normal errors or two matrices for the pi-parameters if using the polynomial model."
					exit 301
					}
				
				if `polynomial'==0 {
					confirm matrix `rest'
					mat `pi'=`rest'
					if colsof(`pi')!=3|rowsof(`pi')!=3 {
						noi di in red "When using joint normal errors, matrix pi must be 3 x 3."
						exit 301
						}
					}
				if `polynomial'!=0 {
					tempname pi0name pi1name
					gettoken pi0name pi1name: rest
					confirm matrix `pi0name' `pi1name'
					mat `pi0'=`pi0name'
					mat `pi1'=`pi1name'
					if colsof(`pi1')!=`polynomial'|colsof(`pi0')!=`polynomial' {
						noi di in red "Columns of pi1 and pi0 must match degree of polynomial."
						exit 301
						}
						
					}
				}
			else {
				if !inlist(`polynomial',0,2) {
					noi di in red "When using default parameters, use polynomial of degree 0 (normal) or 2."
					exit 301
					}
				if "`link'"=="lpm" mat `gamma'=[ 0.015 , -0.01 , 0.00025 , `=0.5-0.015*40+0.01*15-0.00025*305']
				else mat `gamma'=[ -0.125 , -0.08 , 0.002 , `=0.125*40+0.08*15-0.002*305']
				mat `beta0'=[ 0.025 , -0.0004 , 3.2]
				mat `beta1'=[ 0.01 , 0 , 3.6 ]
				mat `pi'= [ 0.5 , 0.3 , -0.1 \ 0.3 , 0.5, -0.5 \ -0.1 , -0.5 , 1 ]
				mat `pi1'= [ 0.5 , -0.1 ]
				mat `pi0'= [ 2 , -1 ]
				}
				
			if "`fixedeffects'"!="" {
				tempname fix0 fix1 avgDist
				gettoken fix0name rest: fixedeffects
				confirm matrix `fix0name'
				mat `fix0'=`fix0name'
				loc districts=colsof(`fix0')
				
				gettoken fix1name rest: rest
				confirm matrix `fix1name'
				mat `fix1'=`fix1name'
				if colsof(`fix1')!=`districts' {
					noi di in red "Fixed effects matrices must be same dimensions - 1 x G."
					exit 301
					}
				confirm matrix `rest'
				mat `avgDist'=`rest'
				if colsof(`avgDist')!=`districts' {
					noi di in red "Fixed effects matrices must be same dimensions - 1 x G."
					exit 301
					}
				}
			else if `districts'>0 {
				set obs `districts'
				tempname fix0 fix1 avgDist cov means
				mat `cov'= [ 0.1 , 0.05 , -0.05 \ 0.05 , 0.1 , -0.1 \ -0.05 , -0.1 , 10 ]
				drawnorm `fix0' `fix1' `avgDist', cov(`cov')
				foreach state in fix0 fix1 avgDist {
					replace ``state''=0 in 1
					mkmat ``state'', matrix(``state'')
					mat ``state''=``state'''
					}
				}
		
			//Generate X, Z
			clear
			set obs `obs'
			if `districts'>0 {
				tempname fix
				gen district=ceil(`districts'*runiform())
				fvexpand i.district
				loc districtlist `r(varlist)'
				foreach state in fix0 fix1 avgDist {
					mat colnames ``state''=`districtlist'
					}
				mat score `avgDist'=`avgDist'
				gen distCol=`avgDist'+rnormal(40,10)
				}
			else gen distCol=rnormal(0,10)+40
			gen exp=floor(31*runiform())
			gen exp2=exp^2
			
			//Combine coefs, include fixed effects
			if `districts'>0 {
				foreach state in 0 1 {
					mat `beta`state''=`beta`state''[1,1..colsof(`beta`state'')-1],`fix`state'',`beta`state''[1,colsof(`beta`state'')]
					}
				}
			mat colnames `gamma'=distCol exp exp2 _cons
			mat colnames `beta0'=exp exp2 `districtlist' _cons
			mat colnames `beta1'=exp exp2 `districtlist' _cons
			
			//Create errors
			tempname U0 U1 V Ud
			if `polynomial'==0 {
				drawnorm `U0' `U1' `V', cov(`pi')
				gen `Ud'=normal(`V')
				}
			if `polynomial'>0 {
				gen `V'=rnormal()
				gen `Ud'=normal(`V')
				loc cons1=0
				loc cons0=0
				forvalues p=1/`polynomial' {
					tempname p`p'
					loc names `names' `p`p''
					loc cons1=`cons1'-`pi1'[1,`p']*(1/(`p'+1))
					loc cons0=`cons0'-`pi0'[1,`p']*(1/(`p'+1))
					gen `p`p''=`Ud'^`p'
					}
				mat `pi1'=`pi1',`cons1'
				mat `pi0'=`pi0',`cons0'
				mat colnames `pi1'=`names' _cons
				mat colnames `pi0'=`names' _cons
				mat score `U1'=`pi1'
				mat score `U0'=`pi0'
				replace `U1'=`U1'+rnormal(0,0.2)
				replace `U0'=`U0'+rnormal(0,0.2)
				}
			
			//determine first stage
			tempname index
			mat score `index'=`gamma'
			if "`link'"=="probit" gen col=`index'>`V'
			if "`link'"=="lpm"  gen col=`index'>`Ud'
				
			//Determine outomes
			tempname lwage0 lwage1
			mat score `lwage0'=`beta0'
			mat score `lwage1'=`beta1'
			replace `lwage0'=`lwage0'+`U0'
			replace `lwage1'=`lwage1'+`U1'
			gen lwage=col*`lwage1'+(1-col)*`lwage0'
			
			//generate MTE
			tempname support temp mtexs beta10pi mte
			forvalues i=1/99 {
				mat `support'=[nullmat(`support'),`=round(`i'/100,0.01)' ]
				loc mtenames `mtenames' u`i'
				}
			mat `mtexs'=[ 15 \ 305 ]
			if `districts'>0 {
					forvalues i=1/`districts' {
						mat `mtexs'=[nullmat(`mtexs') \ `=1/`districts'' ]
					}
				}
			mat `mtexs'=[nullmat(`mtexs') \ 1]
			if `polynomial'==0 {
				mat `beta10pi'=`beta1'-`beta0',`pi'[3,2]-`pi'[3,1]
				mata: mtefecalc_small(st_matrix("`beta10pi'"),invnormal(st_matrix("`support'")),st_matrix("`mtexs'"),"`mte'")
				}
			else {
				tempname S tempsup
				forvalues k=1/`polynomial' {
					if `k'==1 mat `tempsup'=`support'
					else mat `tempsup'=hadamard(`tempsup',`support')
					mat `S'=[nullmat(`S') \ `tempsup']
					}
				mat `beta10pi'=`beta1'[1,1..`=colsof(`beta1')-1']-`beta0'[1,1..`=colsof(`beta0')-1'],`beta1'[1,`=colsof(`beta1')']-`beta0'[1,`=colsof(`beta0')']+`pi1'[1,`=`polynomial'+1']-`pi0'[1,`=`polynomial'+1'],`pi1'[1,1..`polynomial']-`pi0'[1,1..`polynomial']
				mata: mtefecalc_small(st_matrix("`beta10pi'"),st_matrix("`S'"),st_matrix("`mtexs'"),"`mte'")
				}
			mat colnames `mte'=`mtenames'
				
			//post parameters
			return matrix gamma=`gamma'
			return matrix beta1=`beta1'
			return matrix beta0=`beta0'
			return matrix mte=`mte'
			if `polynomial'>0 {
				forvalues state=0/1 {
					tempname retpi`state'
					mat `retpi`state''=`pi`state''[1,1..`polynomial']
					return matrix pi`state'=`retpi`state''
					}
				}
			else return matrix pi=`pi'
			/*gen lwage0=`lwage0'
			gen lwage1=`lwage1'
			gen U1=`U1'
			gen U0=`U0'
			gen Ud=`Ud'
			*/
		}

end
}

mata:
mata clear

void mtefecalc_small(real matrix beta10pi, real matrix S, real matrix mtexs, ///
	string scalar mtename)
{
	real matrix fullS
	real scalar i
	real vector mte
	
	fullS=J(rows(mtexs),cols(S),.)
	for (i=1;i<=cols(S);i++) fullS[.,i]=mtexs
	fullS=fullS \ S
	mte=beta10pi*fullS
	st_matrix(mtename,mte)
}


end
