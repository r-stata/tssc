cap program drop xtgranger
program xtgranger,eclass
version 12.0

syntax varlist(numeric) [if][in][,lags(integer 1) maxlags(integer 0) het nodfc sum] 
marksample touse
preserve
gettoken depvar indeps: varlist
quietly keep if `touse'

foreach var in `indeps'{
	quietly xtsum `var'
	if(r(sd_w)==0){
		display as error "Some variables are time-invariant."
		exit
	}
}

capture xtset
local t =r(tmax)-r(tmin)+1
local n =(_N)/`t'

if _rc {
	display as error "Panel variable not set; use xtset before running xtgranger."
	exit
}

if (floor(`t'/2)<=1+`lags') {
	display as error "Not enough time series observations. Floor(T/2) must be greater than 1+lags."
	exit
}

if (floor(`t'/2)<=1+`maxlags') {
	display as error "Not enough time series observations. Floor(T/2) must be greater than 1+maxlags."
	exit
}

if (`lags'==0) {
	display as error "Number of lags need to be a positive integer."
	exit
}

if(`maxlags'!=0){
	mata: test0("`depvar'","`indeps'",`t',`n',`maxlags')
	local lags=r(p)
	matrix lag_BIC=r(lag_BIC)
}

mata: test1("`depvar'","`indeps'",`t',`n',`lags',"`het'","`dfc'")

scalar W_HPJ=r(W_HPJ)
local k=r(k)
local df=`k'*`lags'
local BIC=r(BIC)
scalar rejection_HPJ=W_HPJ>invchi2(`df',0.95)
scalar pvalue_HPJ=chi2tail(`df',W_HPJ)
matrix b_HPJ=r(beta)'
matrix Var_HPJ=r(V)

di in gr "Juodis, Karavias and Sarafidis (2021) Granger non-causality test results:" 
di as text _dup(80) "-"

di in gr "Number of units" _col(16) "= " in ye `n' _col(49) in gr "T" _col(60) "= " _col(64) in ye  `t'-`lags'
di in gr "Number of lags" _col(16) "= "  in ye  `lags' _col(49) in gr "BIC" _col(60) "= " _col(64) in  ye `BIC' 

di as text _dup(80) "-"
di in gr "HPJ Wald test" _col(16) ": "  in ye r(W_HPJ) _col(49) in gr "pvalue_HPJ" _col(60) ": " _col(64) in ye %6.4f pvalue_HPJ _n
if (`k'==1){
di in gr "H0:" "`indeps'" " does not Granger-cause " "`depvar'""."
di in gr "H1:" "`indeps'" " does Granger-cause " "`depvar'" " for at least one panelvar."
}
else{
di in gr "H0: Selected covariates do not Granger-cause " "`depvar'""."
di in gr "H1: H0 is violated."
}
di as text _dup(80) "-"

if (`maxlags'!=0){
	di in gr "BIC selection:" 
	forvalues lag1=1/`maxlags'{
		if (`lag1'==`lags'){
		di in gr "    lags = " in ye lag_BIC[`lag1',1] in gr ", BIC = " in ye lag_BIC[`lag1',2] "*"
		}
		else{
		di in gr "    lags = " in ye lag_BIC[`lag1',1] in gr ", BIC = " in ye lag_BIC[`lag1',2]
		}
	}
di as text _dup(80) "-"
}

local name1 `indeps'
local names ""
foreach name of local name1{
	forvalues p1=1/`lags'{
		local names "`names' l`p1'.`name'"
	}
} 
matrix colname b_HPJ=`names'
matrix colname Var_HPJ=`names'
matrix rowname Var_HPJ=`names'

if (`lags'>1) {
matrix b_Sum_HPJ=r(beta_sum)'
matrix Var_Sum_HPJ=r(Svar)
matrix colnames b_Sum_HPJ= `indeps'
matrix colname Var_Sum_HPJ=`indeps'
matrix rowname Var_Sum_HPJ=`indeps'
}

tempname beta v
if ("`sum'"!="") & (`lags'>1) {
	di _col(8) "{bf:Sum of Half-Panel Jackknife coefficients across lags (lags>1)}" 
	mat `beta'=b_Sum_HPJ
	mat `v'=Var_Sum_HPJ
}
else{
	di _col(16) "{bf:Results for the Half-Panel Jackknife estimator}"
	mat `beta'=b_HPJ
	mat `v'=Var_HPJ
}
	
if ("`het'"!="") {
	di _col(8) "Cross-sectional heteroskedasticity-robust variance estimation"
	}
if("`dfc'"!=""){
	di _col(10) "No degrees-of-freedom correction in the variance estimator"
}
 
ereturn post `beta' `v'
ereturn display

ereturn scalar N = `n'
ereturn scalar T = `t'-`lags'
ereturn scalar p=`lags'
if(`maxlags'!=0){
	ereturn scalar BIC=`BIC'
}
ereturn scalar W_HPJ=W_HPJ
ereturn scalar pvalue=pvalue_HPJ
ereturn matrix b_HPJ=b_HPJ
ereturn matrix Var_HPJ=Var_HPJ

if (`lags'>1) {
	ereturn matrix b_Sum_HPJ=b_Sum_HPJ
	ereturn matrix Var_Sum_HPJ=Var_Sum_HPJ
}
ereturn local cmd "xtgranger"



restore
end
	

capture mata mata drop test0() test1()
	
mata:
void test0 (string scalar depvar,string scalar indeps, numeric scalar t, numeric scalar n,numeric scalar l)
{
	z1=st_data(.,depvar,.) //the transfer (t*n)*1 matrix
	z2=st_data(.,indeps,.)
	k=cols(z2)
	y=J(t,n,.)  // set y to be t*n matrix
	x=J(t,n*k,.)
	for(m=1; m<=k; m++) {
		for(j=1; j<=n; j++) {
			for(i=1; i<=t; i++) {
				y[i,j]=z1[(j-1)*t+i]
					x[i,j+(m-1)*n]=z2[(j-1)*t+i,m]
			}
		}
	}
	
	lag_BIC=J(l,2,0)
	//calculata smallest BIC
	if(l!=0){
		for(z=1; z<=l; z++){
			row=t-z
			cols=z*k
			xi=J(row,cols,.)
			zi=J(row,z+1,.)
			yi=J(row,1,.)
			Mi=J(row,row,0)
			RSS=0	
			for(i=1; i<=n; i++) {
				st_subview(yi,y,(z+1)::t,i) 
				for(m=1; m<=row; m++) { 
					for(q=1; q<=z+1; q++) { 	
						if (q==1) {
							zi[m,q]=1
						}
						else {
							zi[m,q]=y[z+m-q+1,i]
						}
					}		
					for(o=1; o<=k; o++) { 		
						for(j=1; j<=z; j++) { 
							xi[m,(o-1)*z+j]=x[z+m-j,i+(o-1)*n]
						}
					}	
				}
				
				Mi=I(row)-zi*luinv(zi'*zi)*zi'
				tempxx=xi'*Mi*xi
				tempxy=xi'*Mi*yi
				tempbeta=cross(cholinv(tempxx),tempxy)
				RSS=RSS+(yi-xi*tempbeta)'*Mi*(yi-xi*tempbeta)
			}
			BIC_p_p=n*(t-1-z-z)*log(RSS/(n*(t-1-z-z)))+z*log(n*(t-1-z-z))
			lag_BIC[z,1]=z
			lag_BIC[z,2]=BIC_p_p
			if (z==1) {
					BIC=BIC_p_p
					p=1
				}
				else{
					if(BIC>BIC_p_p){
						BIC=BIC_p_p
						p=z
					}
				}
		}
	}	
	st_numscalar("r(p)",p)
	st_matrix("r(lag_BIC)",lag_BIC)
}	
end	



mata:
void test1(string scalar depvar,string scalar indeps, numeric scalar t, numeric scalar n,numeric scalar p,string scalar het,string scalar dfc)
{
	z1=st_data(.,depvar,.) //the transfer (t*n)*1 matrix-y
	z2=st_data(.,indeps,.)
	k=cols(z2)
	y=J(t,n,.)  // set y to be t*n matrix
	x=J(t,n*k,.)
	for(m=1; m<=k; m++) {
		for(j=1; j<=n; j++) {
			for(i=1; i<=t; i++) {
				y[i,j]=z1[(j-1)*t+i]
					x[i,j+(m-1)*n]=z2[(j-1)*t+i,m]
			}
		}
	}
	
	row=t-p
	cols=p*k
	xx=xx_f=xx_l=J(cols,cols,0)
	xy=xy_f=xy_l=J(cols,1,0)
	xi=xi_c=J(row,cols,.)
	zi=J(row,p+1,.)
	yi=J(row,1,.)
	Mi=Mi_c=J(row,row,0)
	mid=floor(t/2)
	RSS=0
	
	for(i=1; i<=n; i++) {
		st_subview(yi,y,(p+1)::t,i) // set yi
		
		for(m=1; m<=row; m++) { 
			for(q=1; q<=p+1; q++) { 	// set zi(m,l)
				if (q==1) {
					zi[m,q]=1
				}
				else {
					zi[m,q]=y[p+m-q+1,i]
				}
			}	
				
			for(o=1; o<=k; o++) { 		// set xi(m,k*p)
				for(j=1; j<=p; j++) { 
					xi[m,(o-1)*p+j]=x[p+m-j,i+(o-1)*n]
				}
			}	
		}
		
	
		Mi=I(row)-zi*luinv(zi'*zi)*zi'
		tempxx=xi'*Mi*xi
		tempxy=xi'*Mi*yi
	// calculate bi for i-th regression
		tempbeta=cross(cholinv(tempxx),tempxy)
		RSS=RSS+(yi-xi*tempbeta)'*Mi*(yi-xi*tempbeta)
		
		xx=xx+tempxx     // xx=var(beta hat) 
		xy=xy+tempxy
		
		zi_f=xi_f=yi_f=.		// calculate first T1=[T/2]
		st_subview(zi_f,zi,1::(mid-p),.)
		st_subview(xi_f,xi,1::(mid-p),.)
		st_subview(yi_f,yi,1::(mid-p),.)
		Mi_f=I(mid-p)-zi_f*luinv(zi_f'*zi_f)*zi_f'
		tempxx=xi_f'*Mi_f*xi_f
		xx_f=xx_f+tempxx
		tempxy=xi_f'*Mi_f*yi_f
		xy_f=xy_f+tempxy
		
		zi_l=xi_l=yi_l=.		// calculate T2=T-T1
		st_subview(zi_l,zi,(mid+1)::row,.)	
		st_subview(xi_l,xi,(mid+1)::row,.)
		st_subview(yi_l,yi,(mid+1)::row,.)
		Mi_l=I(row-mid)-zi_l*luinv(zi_l'*zi_l)*zi_l'
		tempxx=xi_l'*Mi_l*xi_l
		xx_l=xx_l+tempxx
		tempxy=xi_l'*Mi_l*yi_l
		xy_l=xy_l+tempxy
		
		if (i==1) {				
			xi_c=xi		// creat a matrix to store xi
			Mi_c=Mi		// creat a matrix to store mi
			}
			else{
			xi_c=(xi_c,xi)
			Mi_c=(Mi_c,Mi)
			}
	}
	
	b=cross(cholinv(xx),xy)
	b_f=cross(cholinv(xx_f),xy_f)
	b_l=cross(cholinv(xx_l),xy_l)
	beta=2*b-(b_f+b_l)/2   //beta 
	BIC=n*(t-1-p-p)*log(RSS/(n*(t-1-p-p)))+p*log(n*(t-1-p-p))
	
	
	sum=0
	sum_het=J(cols,cols,0)
	
	for(i=1; i<=n; i++) {
			
		st_subview(yi,y,(p+1)::t,i) //yi
		
		f=(i-1)*cols+1
		l=i*cols
		st_subview(xi,xi_c,.,f..l) //xi
			
		f=(i-1)*row+1
		l=i*row
		st_subview(Mi,Mi_c,.,f..l) //Mi		
	
	/* variance */	
		if (het=="") {	
			//HPJ
			di=yi-xi*b
			temp=di'*Mi*di
			sum=sum+temp
		}
		else{
			//HPJ
			di=yi-xi*b
			s2_i=di'*Mi*xi
			sum_het=sum_het+s2_i'*s2_i
		}		
	}
	
	if(dfc==""){
		degree=n*t-n*1-n*p-cols
	}
	else{
		degree=n*t
	}
	
	if (het=="") {	
		var=sum/degree*luinv(xx)
		W_HPJ=beta'*luinv(var)*beta
	}	
	else{
		temp=sum_het/degree
		var=luinv(xx)*temp*luinv(xx)*(n*t)
		W_HPJ=beta'*luinv(var)*beta
	}
	
	
	//calculate the sum of beta
	beta_sum=J(k,1,0)
	for(i=1; i<=k; i++){
		for(j=1; j<=p; j++){
			beta_sum[i]=beta_sum[i]+beta[p*(i-1)+j]
		}
	}
	
	Svar=J(k,k,0)
	for(i=1; i<=k; i++){
		for(j=1; j<=k; j++){
			for(m=1; m<=p; m++){
				for(o=1; o<=p; o++){
					Svar[i,j]=Svar[i,j]+var[m*i,j*o]
				}
			}
		}
	}
	

	
	
	st_numscalar("r(W_HPJ)",W_HPJ) 
	st_numscalar("r(k)",k)
	st_numscalar("r(BIC)",BIC)
	st_matrix("r(beta)",beta)
	st_matrix("r(V)",var) 
	st_matrix("r(beta_sum)",beta_sum)
	st_matrix("r(Svar)",Svar)
}
end