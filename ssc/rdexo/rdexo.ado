program define rdexo, eclass

version 14.0

syntax varlist(numeric) [if] [in] , [CUToff(numlist)] [COVariate(varlist)] [Hwidth(numlist >=0)] [Bootstrap(numlist >0)]

tokenize `varlist'   //without this, the `2' will be "x," instead of "x"
marksample rdtouse // subsample satisfies `if' `in'

local y `1' // outcome variable
local x `2' // forcing variable
local d `3' // treatment indicator
local nmin=5
local flag=0

if "`cutoff'"!="" {
	local c = `cutoff'
	}
else {
	local c = 0
}	

if "`bootstrap'" != "" {
	local B=`bootstrap'
	}
else {
	local B = 1000
}	

tempvar est se bias hwid 
set seed 1

**************************************
* in case option hwidth is provided, 
* check to see if it has 6 entries
if "`hwidth'" != "" {
	if wordcount(" `hwidth' ")<6 {
		di as error "Bandwidths must be entered as a list with 6 numbers. E.g. h(1.5 2 1.7 2.9 1.4 0.9). Enter zero for unused bandwidths."
		exit
	}
}

**************************************
* determine sharp or fuzzy RD
qui sum `d' if `x'<`c' & `rdtouse'
local var1 = r(Var)
qui sum `d' if `x'>`c' & `rdtouse'
local var2 = r(Var)

**************************************
* estimate sharp RD
if (`var1'<10^(-6)&`var2'<10^(-6)){
	if "`hwidth'" != "" {
		mata: st_matrix("hvec", strtoreal(tokens(st_local("hwidth"))))
		local h=hvec[1,1]
		}
	else {
		qui ikbw `y' `x' if `rdtouse', cut(`c')
		local h = e(hwid)
		local flag = `flag'+e(flag)
		}	
	mata: estim_sharp("`varlist'","`rdtouse'",`h',`flag',`c',`B',`nmin')
	matrix est=est
	matrix se=se
	matrix bias=bias
	matrix estbc=estbc
	matrix tstat=tstat
	matrix pval=pval
	matrix hwid=hwid
	local flag=flag
	local errobs=errobs
	
	if `errobs'>0{
		di as error "Not enough observations around the cutoff! Try a larger bandwidth or sample."
		}
	else{
		di "{hline 74}"
		di "{hline 74}"
		di as text "Sharp RD{col 32}Estimate    S.E.  p-value bandwidth" 
		di "{hline 74}"
		di as result "Prob. of compliers "         _col(30) %10.3f 1           _col(15) %8.3f 0    
		di as result "E[Y(0)|X=c]"                 _col(30) %10.3f estbc[8, 1] _col(15) %8.3f se[8, 1] _col(15) %8.3f pval[8, 1]    
		di as result "E[Y(1)|X=c]"                 _col(30) %10.3f estbc[10,1] _col(15) %8.3f se[10,1] _col(15) %8.3f pval[10,1] 
		di as result "E[Y(1)-Y(0)|X=c]"            _col(30) %10.3f estbc[1, 1] _col(15) %8.3f se[1, 1] _col(15) %8.3f pval[1, 1] _col(20) %8.3f hwid[1,1] 
		di "{hline 74}" 
		di as text "number of pseudo inverses used: `flag'"
		di as text "number of bootstrap iterations used: `B'"
	}
	
	ereturn clear
	ereturn matrix est=est
	ereturn matrix estbc=estbc
	ereturn matrix se=se
	ereturn matrix bias=bias
	ereturn matrix hwid=hwid
	ereturn scalar flag=flag
}
**************************************
* estimate fuzzy RD
else{
	if "`hwidth'" != "" {
	mata: st_matrix("h", strtoreal(tokens(st_local("hwidth"))))
	matrix h=h'
	}
	else { 
		qui ikbw `y' `x' if `rdtouse', cut(`c')  
		local bw1=e(hwid)
		local flag = `flag'+e(flag)
		
		//fuzzy on the left (no never-takers)
		if (`var1'>=10^-6) {
			qui ikbw `y' `x' if `d'==1 & `rdtouse', cut(`c')
			local bw4=e(hwid)
			local flag = `flag'+e(flag) 
		}
		
		//fuzzy on the right (no always-takers) 
		if (`var2'>=10^-6) {
			qui ikbw `y' `x' if `d'==0 & `rdtouse', cut(`c')
			local bw3=e(hwid)
			local flag = `flag'+e(flag) 
		}
		
		//fuzzy on both sides
		if ((`var1'>=10^-6)&(`var2'>=10^-6)) {		
			qui ikbw `d' `x' if `rdtouse', cut(`c')
			local bw2=e(hwid)
			local flag = `flag'+e(flag) 
		}
		
		//sharp on the left, fuzzy on the right (no always-takers) 
		if (`var1'<10^(-6)){
			matrix h=(`bw1'\\`bw1'\\`bw3'\\`bw1'\\`bw3'\\`bw1')
		}
		//fuzzy on the left, sharp on the right (no never-takers)
		else if (`var2'<10^(-6)){
			matrix h=(`bw1'\\`bw1'\\`bw1'\\`bw4'\\`bw1'\\`bw4')
		}
		else {
			matrix h=(`bw1'\\`bw2'\\`bw3'\\`bw4'\\`bw3'\\`bw4')
		} 
	}
		
	if "`covariate'" == ""{
		local flag_cov=0
	}
	else{
		local flag_cov=1	
	}	
			
			mata: estim_fuzzy("`varlist' `covariate'","`rdtouse'","h",`flag_cov',`flag',`c',`B',`nmin',`var1',`var2')
			matrix est=est
			matrix se=se
			matrix bias=bias
			matrix estbc=estbc
			matrix tstat=tstat
			matrix pval=pval
			local  Fstat1=Fstat1
			local  Fpval1=Fpval1
			local  Fstat2=Fstat2
			local  Fpval2=Fpval2
			local  flag=flag
			local errobs=errobs
			matrix hwid=hwid
			
			if (`errobs'>0){
				if (`errobs'==1) di as error "E[Y|X=c+] - E[Y|X=c-]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
				if (`errobs'==2) di as error "E[W|X=c+] - E[W|X=c-]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
				if (`errobs'==3) di as error "E[Y|X=c+,W=0] - E[Y|X=c-,W=0]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
				if (`errobs'==4) di as error "E[Y|X=c+,W=1] - E[Y|X=c-,W=1]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
				if (`errobs'==5) di as error "E[Y|X=c+,W=0,V] - E[Y|X=c-,W=0,V]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
				if (`errobs'==6) di as error "E[Y|X=c+,W=1,V] - E[Y|X=c-,W=1,V]: Not enough observations around the cutoff! Try a larger bandwidth or sample."
			}
			else{
				di "{hline 74}"
				di "{hline 74}"
				if (`var1'<10^(-6)) di as text "Sharp for X-c<0, fuzzy for X-c>=0 {col 37}Estimate    S.E.  p-value bandwidth""
				if (`var2'<10^(-6)) di as text "Fuzzy for X-c<0, sharp for X-c>=0 {col 37}Estimate    S.E.  p-value bandwidth""
				if ((`var1'>=10^(-6))&(`var2'>=10^(-6)))   di as text "Fuzzy RD{col 37}Estimate    S.E.  p-value bandwidth" 
				di "{hline 74}"
				di as result "Prob. of compliers "         _col(35) %10.3f estbc[5,1]  _col(15) %8.3f se[5,1]  _col(15) %8.3f pval[5,1]
				if (`var1'>=10^(-6)) di as result "Prob. of alwaystaker"        _col(35) %10.3f estbc[6,1]  _col(15) %8.3f se[6,1]  _col(15) %8.3f pval[6,1]
				if (`var2'>=10^(-6)) di as result "Prob. of nevertaker"     	_col(35) %10.3f estbc[7,1]  _col(15) %8.3f se[7,1]  _col(15) %8.3f pval[7,1]
				di as result "E[Y(0)|X=c,complier]"        _col(35) %10.3f estbc[8,1]  _col(15) %8.3f se[8,1]  _col(15) %8.3f pval[8,1]   
				if (`var2'>=10^(-6)) di as result "E[Y(0)|X=c,nevertaker]"  	_col(35) %10.3f estbc[9,1]  _col(15) %8.3f se[9,1]  _col(15) %8.3f pval[9,1] 
				di as result "E[Y(1)|X=c,complier] "       _col(35) %10.3f estbc[10,1] _col(15) %8.3f se[10,1] _col(15) %8.3f pval[10,1]  
				if (`var1'>=10^(-6)) di as result "E[Y(1)|X=c,alwaystaker]"     _col(35) %10.3f estbc[11,1] _col(15) %8.3f se[11,1] _col(15) %8.3f pval[11,1] 
				if ((`var1'>=10^(-6))&(`var2'>=10^(-6))) di as result "LATE "   _col(35) %10.3f estbc[13,1] _col(15) %8.3f se[13,1] _col(15) %8.3f pval[13,1] 
				di as result "E[Y|X=c+]-E[Y|X=c-]"         _col(35) %10.3f estbc[1,1]  _col(15) %8.3f se[1,1]  _col(15) %8.3f pval[1,1]  _col(20) %8.3f hwid[1,1]
				if ((`var1'>=10^(-6))&(`var2'>=10^(-6))) di as result "E[W|X=c+]-E[W|X=c-]"     _col(35) %10.3f estbc[2,1]  _col(15) %8.3f se[2,1]  _col(15) %8.3f pval[2,1]  _col(20) %8.3f hwid[2,1] 
				if (`var2'>=10^(-6)) di as result "E[Y|X=c+,W=0]-E[Y|X=c-,W=0]" _col(35) %10.3f estbc[3,1]  _col(15) %8.3f se[3,1]  _col(15) %8.3f pval[3,1]  _col(20) %8.3f hwid[3,1] 
				if (`var1'>=10^(-6)) di as result "E[Y|X=c+,W=1]-E[Y|X=c-,W=1]" _col(35) %10.3f estbc[4,1]  _col(15) %8.3f se[4,1]  _col(15) %8.3f pval[4,1]  _col(20) %8.3f hwid[4,1]
				if ((`var1'>=10^(-6))&(`var2'>=10^(-6))) di as result "Joint F-test" _col(35) %10.3f `Fstat1'     _col(15) "        "  _col(15) %8.3f `Fpval1'
				di as text _dup(74) "-"
				if (`flag_cov'==1){
					if (`var2'>=10^(-6)) di as result "(E[Y|X=c+,W=0]-E[Y|X=c-,W=0])-"
					if (`var2'>=10^(-6))  di as result "(E[V|X=c+,W=0]-E[V|X=c-,W=0])'"_char(103)"(0)" _col(35) %10.3f estbc[16,1]  _col(15) %8.3f se[16,1]  _col(15) %8.3f pval[16,1]  _col(20) %8.3f hwid[5,1] 
					if (`var1'>=10^(-6)) di as result "(E[Y|X=c+,W=1]-E[Y|X=c-,W=1])-"
					if (`var1'>=10^(-6)) di as result "(E[V|X=c+,W=1]-E[V|X=c-,W=1])'"_char(103)"(1)" _col(35) %10.3f estbc[17,1]  _col(15) %8.3f se[17,1]  _col(15) %8.3f pval[17,1]  _col(20) %8.3f hwid[6,1]
					if ((`var1'>=10^(-6))&(`var2'>=10^(-6))) di as result "Joint F-test adj for covariate" _col(35) %10.3f `Fstat2'     _col(15) "        "  _col(15) %8.3f `Fpval2'
					di "{hline 74}" 
				}
				di as text "number of pseudo inverses used: `flag'"
				di as text "number of bootstrap iterations used: `B'"
			}
	
	qui{
		ereturn clear
		ereturn matrix est=est   
		ereturn matrix estbc=estbc
		ereturn matrix se=se
		ereturn matrix bias=bias
		ereturn matrix hwid=hwid
		ereturn scalar flag=flag
		ereturn list
	}
}
end


	
capture mata mata drop estim_sharp()
version 14.0
mata:
void estim_sharp(scalar varlist, scalar rdtouse, h, flag, c, B, nmin)
{	
	real matrix M, X, Y, C, ind, est, bias, est_star
	real scalar n,se
	
	st_view(M,.,varlist,rdtouse)
	st_subview(Y,M,.,1)
	st_subview(X,M,.,2)
	st_subview(D,M,.,3)
	
	C=c:*J(rows(Y),1,1)
	H=h:*J(rows(C),1,1)
	ind=((C-H:<X):&(X:<C+H))
	
	Yh=select(Y,ind)
	Xh=select(X-C,ind)
	nh=length(Yh)
	Hh=select(H,ind)
	
	nmin_obs=min((sum(Xh:>J(nh,1,0)),sum(Xh:<=J(nh,1,0))))
	if (nmin_obs<nmin) {
		st_matrix("est",J(15,1,0))
		st_matrix("se",J(15,1,0))
		st_matrix("bias",J(15,1,0))
		st_matrix("estbc",J(15,1,0))
		st_matrix("tstat",J(15,1,0))
		st_matrix("pval",J(15,1,0))
		st_numscalar("errobs",1)
		st_numscalar("hwid",0)
		printf("-->mata-estim-sharp terminated\n")	
		exit(0)
	}
	
	est  =J(15,1,0)
    bias =J(15,1,0)
	
	//X variables
	XX=(J(nh,1,1), Xh, Xh:^2, (Xh:>=J(nh,1,0)), (Xh:>=J(nh,1,0)):*Xh, (Xh:>=J(nh,1,0)):*Xh:^2)
	XXh=XX[.,(1,2,4,5)]   
	
	//weights
	omg=sqrt((abs(Xh:/Hh):<=J(nh,1,1)):*(J(nh,1,1)-abs(Xh:/Hh)))
	
	//weighted matrices
	XXXh=J(1,cols(XXh),omg):*XXh
	YYYh=omg:*Yh
	if (rank(XXXh'*XXXh)<cols(XXh)) {
		Q=pinv(XXXh'*XXXh)
		flag=flag+1
	}
	else {
		Q=I(cols(XXh))*luinv(XXXh'*XXXh)
	}
	
	beta1=Q*XXXh'*YYYh
	est[1]=beta1[3]
	
	//***********************************************
	//estimating bias - difference bt quadratic and
	//linear local weigthed ols

	XXXb=J(1,cols(XX),omg):*XX
	if (rank(XXXb'*XXXb)<cols(XX)) {
		Q=pinv(XXXb'*XXXb)
		flag=flag+1
	}
	else {
		Q=I(cols(XX))*luinv(XXXb'*XXXb)
	}
	
	beta2=Q*XXXb'*YYYh		
    bias[1]=est[1]-beta2[4]
	
	est[8]=beta1[1]
	est[10]=beta1[1]+beta1[3]
	bias[8]=est[8]-beta2[1]
	bias[10]=est[10]-(beta2[1]+beta2[4])
	
	//***************************************************
	//bootstrap estimation of variance (quadratic estimation)
	residY=Yh-XX*beta2
	
	printf("Bootstrapping SE...")
	est_star=J(15,B,0)
	for (b=1; b<=B; b++) {
		wei_star = (J(nh,1,(1-sqrt(5))/2) + J(nh,1,sqrt(5)):*(runiform(nh,1):<J(nh,1,(sqrt(5)-1)/(2*sqrt(5)))))
	
		resid_star=wei_star:*residY;
	
		Y_star=XX*beta2 + resid_star
	
		YYY_star_h=omg:*Y_star
	
		beta2_star=Q*XXXb'*YYY_star_h
	
		//jump estimate
		est_star[1,b]=beta2_star[4]
		est_star[8,b]=beta2_star[1]
		est_star[10,b]=beta2_star[1]+beta2_star[4]
		
		if (mod(b,(B/10))==0) {
			printf(" %2.0f%%", b/(B/100))  //display the bootstrap iterations
			displayflush()
		}
	}
	
	printf(" \n ")

	
	estbc=est-bias
	cov=variance(est_star')
	se=sqrt(diagonal(cov)) 
	tstat=estbc:/se
	pval =2*normal(-abs(tstat))
	
	st_matrix("est",est)
	st_matrix("se",se)
	st_matrix("bias",bias)
	st_matrix("estbc",estbc)
	st_matrix("tstat",tstat)
	st_matrix("pval",pval)
	st_matrix("hwid",h)
	st_numscalar("flag",flag)
	st_numscalar("errobs",0)
	//printf("-->end of mata-estim-sharp \n")	
}
end


capture mata mata drop estim_fuzzy()
version 14.0
mata:
void estim_fuzzy(scalar varlist, scalar rdtouse, hwid, scalar flag_cov, flag, c, B, nmin, var1, var2)
{
	real matrix M, X, Y, V, C, ind, est, bias, est_star
	real scalar n,se
	
	st_view(M,.,varlist,rdtouse)
	st_subview(Y,M,.,1)
	st_subview(X,M,.,2)
	st_subview(D,M,.,3)
	
	if (flag_cov==1) st_subview(V,M,.,4)
	
	
	h=st_matrix(hwid)
	
	C=c:*J(rows(Y),1,1)
	hmax=max(h)
	H=J(rows(C),1,hmax)
	
	
	ind=((C-J(rows(C),1,hmax):<X):&(X:<C+J(rows(C),1,hmax)))
	
	
	Yh=select(Y,ind)
	Xh=select(X-C,ind)
	Dh=select(D,ind)
	if (flag_cov==1) Vh=select(V-J(rows(V),1,mean(V)),ind)
	nh=length(Yh)
	

	
	nmin_obs=J(4+2*flag_cov,1,0)
	nmin_obs[1]=min((sum((-J(nh,1,h[1]):<Xh):&(Xh:<=J(nh,1,0))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[1])))))
	nmin_obs[2]=min((sum((-J(nh,1,h[2]):<Xh):&(Xh:<=J(nh,1,0))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[2])))))
	nmin_obs[3]=min((sum((-J(nh,1,h[3]):<Xh):&(Xh:<=J(nh,1,0)):&(Dh:==J(nh,1,0))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[3])):&(Dh:==J(nh,1,0)))))
	nmin_obs[4]=min((sum((-J(nh,1,h[4]):<Xh):&(Xh:<=J(nh,1,0)):&(Dh:==J(nh,1,1))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[4])):&(Dh:==J(nh,1,1)))))
		

	if (flag_cov==1){
		
		nmin_obs[5]=min((sum((-J(nh,1,h[5]):<Xh):&(Xh:<=J(nh,1,0)):&(Dh:==J(nh,1,0))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[5])):&(Dh:==J(nh,1,0)))))
		nmin_obs[6]=min((sum((-J(nh,1,h[6]):<Xh):&(Xh:<=J(nh,1,0)):&(Dh:==J(nh,1,1))),sum((Xh:>J(nh,1,0)):&(Xh:<=J(nh,1,h[6])):&(Dh:==J(nh,1,1)))))

	}
	

	for (j=1; j<=4+2*flag_cov; j++) {
		if ((var1<10^(-6))&(j==4|j==6)){ 

			continue
			
		}
		else if ((var2<10^(-6))&(j==3|j==5)){	

			continue
		}
		else {

			if (nmin_obs[j]<nmin) {

				st_matrix("est",J(15,1,0))
				st_matrix("se",J(15,1,0))
				st_matrix("bias",J(15,1,0))
				st_matrix("estbc",J(15,1,0))
				st_matrix("tstat",J(15,1,0))
				st_matrix("pval",J(15,1,0))
				st_numscalar("Fstat1",0)
				st_numscalar("Fpval1",0)
				st_numscalar("Fstat2",0)
				st_numscalar("Fpval2",0)
				st_numscalar("flag",0)
				st_numscalar("errobs",j)   
				st_matrix("hwid",J(6,1,0))
				// printf("-->mata-estim-fuzzy terminated\n")
				exit(0)
			}
		}
	}
		
	est  =J(15+2*flag_cov,1,0)
    bias =J(15+2*flag_cov,1,0)
	
	if (flag_cov==1) {
		beta1=J(4+cols(V),6,0)
		beta2=J(6+cols(V),6,0)
	}
	else{
		beta1=J(4,6,0)
		beta2=J(6,6,0)
	}

	resid=J(nh,6,0)
	
	//create matrix pointers
	indh= J(1, 6, NULL)
	XX  = J(1, 6, NULL)
	omg = J(1, 6, NULL)
	Qb  = J(1, 6, NULL)
	XXXb= J(1, 6, NULL)
	
	for (j=1; j<=4+2*flag_cov; j++) {
	
		//Local linear regression, bandwidth h
        //local sample using h
		indh[j]=&((-J(nh,1,h[j]):<Xh):&(Xh:<J(nh,1,h[j])))
		
		//conditioning weights
		condw = (j<=2):*J(nh,1,1)+(j==3|j==5):*(Dh:==J(nh,1,0))+(j==4|j==6):*(Dh:==J(nh,1,1))
		
		//X variables
		if (j<=4){
			XX[j] = &((J(nh,1,1), Xh, Xh:^2, (Xh:>=J(nh,1,0)), (Xh:>=J(nh,1,0)):*Xh, (Xh:>=J(nh,1,0)):*Xh:^2):*J(1,6,condw))
			XXh=(*XX[j])[.,(1,2,4,5)] 
		}
		else{
			XX[j] = &((J(nh,1,1), Xh, Xh:^2, (Xh:>=J(nh,1,0)), (Xh:>=J(nh,1,0)):*Xh, (Xh:>=J(nh,1,0)):*Xh:^2, Vh):*J(1,6+cols(Vh),condw))
			XXh=(*XX[j])[.,(1,2,4,5,7..(6+cols(Vh)))] 
		}
		XXh=select(XXh,*indh[j])
		
		//Y variable
		if (j==2){
			YY=Dh:*condw
		}
		else {
			YY=Yh:*condw
		}
		YYh=select(YY,*indh[j])
		
		//weights
		omg[j]=&(sqrt((abs(XXh[.,2]:/J(rows(XXh),1,h[j])):<=J(rows(XXh),1,1)):*(J(rows(XXh),1,1)-abs(XXh[.,2]:/J(rows(XXh),1,h[j])))))
		
		//weighted matrices
		XXXh=J(1,cols(XXh),*omg[j]):*XXh
		if (rank(XXXh'*XXXh)<cols(XXh)) {
			Qh=pinv(XXXh'*XXXh)
			if ((var1<10^(-6))&(j==3|j==5)) 	 flag=flag+1
			if ((var2<10^(-6))&(j==4|j==6)) 	 flag=flag+1
			if ((var1>=10^(-6))&(var2>=10^(-6))) flag=flag+1
		}
		else {
			Qh=I(cols(XXh))*luinv(XXXh'*XXXh)
		}	
		YYYh=(*omg[j]):*YYh
		beta1[1..4+(j>4)*cols(Vh),j]=Qh*XXXh'*YYYh
		
		//local quadratic regression
		XXb=select(*XX[j],*indh[j])
		XXXb[j]=&(J(1,cols(XXb),*omg[j]):*XXb)
		
		if (rank((*XXXb[j])'*(*XXXb[j]))<cols(*XX[j])) {
			Qb[j]=&(pinv((*XXXb[j])'*(*XXXb[j])))
			if ((var1<10^(-6))&(j==3|j==5)) 	 flag=flag+1
			if ((var2<10^(-6))&(j==4|j==6)) 	 flag=flag+1
			if ((var1>=10^(-6))&(var2>=10^(-6))) flag=flag+1
		}
		else {
			Qb[j]=&(I(cols(*XX[j]))*luinv((*XXXb[j])'*(*XXXb[j])))
		}
		
		beta2[1..6+(j>4)*cols(Vh),j]=(*Qb[j])*(*XXXb[j])'*YYYh	
		
		if (j<=4){
			est[j] =beta1[3,j]
			bias[j]=beta1[3,j]-beta2[4,j]
		}
		else{
			est[15+(j-4)] =beta1[3,j]
			bias[15+(j-4)]=beta1[3,j]-beta2[4,j]
		}
		resid[.,j]=YY-(*XX[j])*beta2[1..6+(j>4)*cols(Vh),j]	
	}
	
	//sharp on the left, fuzzy on the right (no always-takers)
	if (var1<10^(-6)){
		theta=(beta1[1,1]+beta1[3,1])\(beta1[1,2]+beta1[3,2])\(beta1[1,3]+beta1[3,3])\ //
			   (beta1[1,4]+beta1[3,4])\beta1[1,1]\beta1[1,2]\beta1[1,3]\.
			   
		thetabc=(beta2[1,1]+beta2[4,1])\(beta2[1,2]+beta2[4,2])\(beta2[1,3]+beta2[4,3])\ //
				 (beta2[1,4]+beta2[4,4])\beta2[1,1]\beta2[1,2]\beta2[1,3]\.
	}		 
	//fuzzy on the left, sharp on the right (no never-takers)
	else if (var2<10^(-6)){
		theta=(beta1[1,1]+beta1[3,1])\(beta1[1,2]+beta1[3,2])\.\ //
		   (beta1[1,4]+beta1[3,4])\beta1[1,1]\beta1[1,2]\beta1[1,3]\beta1[1,4]
		   
		thetabc=(beta2[1,1]+beta2[4,1])\(beta2[1,2]+beta2[4,2])\.\ //
		     (beta2[1,4]+beta2[4,4])\beta2[1,1]\beta2[1,2]\beta2[1,3]\beta2[1,4]
	}		 
	else {
		theta=(beta1[1,1]+beta1[3,1])\(beta1[1,2]+beta1[3,2])\(beta1[1,3]+beta1[3,3])\ //
		   (beta1[1,4]+beta1[3,4])\beta1[1,1]\beta1[1,2]\beta1[1,3]\beta1[1,4]
		   
		thetabc=(beta2[1,1]+beta2[4,1])\(beta2[1,2]+beta2[4,2])\(beta2[1,3]+beta2[4,3])\ //
		     (beta2[1,4]+beta2[4,4])\beta2[1,1]\beta2[1,2]\beta2[1,3]\beta2[1,4]
	}
	//prob of compliance types - est(5:7)
    pi_c=theta[2]- theta[6]
    pi_a=theta[6]
    pi_n=1-pi_c-pi_a

    pi_c_bc=thetabc[2] - thetabc[6]
    pi_a_bc=thetabc[6]
    pi_n_bc=1-pi_c_bc-pi_a_bc

    est[5]=pi_c
    est[6]=pi_a
    est[7]=pi_n
	
	bias[5]=pi_c-pi_c_bc
    bias[6]=pi_a-pi_a_bc
    bias[7]=pi_n-pi_n_bc
	
	//est(8:11)
    //eta and etabc - (4x1) vectors
    //       E[Y(0)|X=c,complier]
    //       E[Y(0)|X=c,nevertaker]
    //       E[Y(1)|X=c,complier]
    //       E[Y(1)|X=c,alwaystaker]
	
	//sharp on the left, fuzzy on the right (no always-takers)
	if (var1<10^(-6)){
		eta=((theta[7]*(1-theta[6]) - (1-theta[2])*theta[3])/(theta[2]-theta[6]))\theta[3]\theta[4]\. 
		etabc=((thetabc[7]*(1-thetabc[6]) - (1-thetabc[2])*thetabc[3])/(thetabc[2]-thetabc[6]))\thetabc[3]\thetabc[4]\.
	}
	//fuzzy on the left, sharp on the right (no never-takers)
	else if (var2<10^(-6)){
		eta=theta[7]\.\((theta[4]*theta[2]-theta[6]*theta[8])/(theta[2]-theta[6]))\theta[8] 
		etabc=thetabc[7]\.\((thetabc[4]*thetabc[2]-thetabc[6]*thetabc[8])/(thetabc[2]-thetabc[6]))\thetabc[8]
	}
	else {
		eta=((theta[7]*(1-theta[6]) - (1-theta[2])*theta[3])/(theta[2]-theta[6]))\theta[3]\ //
	     ((theta[4]*theta[2]-theta[6]*theta[8])/(theta[2]-theta[6]))\theta[8]
		 
		etabc=((thetabc[7]*(1-thetabc[6]) - (1-thetabc[2])*thetabc[3])/(thetabc[2]-thetabc[6]))\thetabc[3]\ //
	       ((thetabc[4]*thetabc[2]-thetabc[6]*thetabc[8])/(thetabc[2]-thetabc[6]))\thetabc[8]
	}
	
    est[8..11] =eta
    bias[8..11]=eta-etabc
	
	//est(12): OLS
    wei1    = pi_a/(pi_a+pi_c*.5)
    wei1_bc = pi_a_bc/(pi_a_bc+pi_c_bc*.5)

    wei2   = pi_n/(pi_n+pi_c*.5)
    wei2_bc= pi_n_bc/(pi_n_bc+pi_c_bc*.5)

    olsvec   =(-(1-wei2),-wei2,(1-wei1),wei1)'
    olsvec_bc=(-(1-wei2_bc),-wei2_bc,(1-wei1_bc),wei1_bc)'

    tau_ols   =olsvec'*eta
    tau_ols_bc=olsvec_bc'*etabc
    est[12] =tau_ols
    bias[12]=tau_ols-tau_ols_bc
	
	//est(13): LATE
    ivvec     =(-1,0,1,0)'
    tau_iv    =ivvec'*eta
    tau_iv_bc =ivvec'*etabc
    est[13] =tau_iv
    bias[13]=tau_iv-tau_iv_bc
	
	//est(14): Hausman
    hausman_test=tau_iv-tau_ols
    hausman_test_bc=tau_iv_bc-tau_ols_bc
    est[14] =hausman_test
    bias[14]=hausman_test-hausman_test_bc
	
	//est(15): Angrist
    angvec    =(-1,1,1,-1)'
    est[15] = angvec'*eta 
    bias[15]= angvec'*(eta-etabc)
	
	//bootstrap estimation of variance (quadratic estimation)
	printf("Bootstrapping SE...")
    est_star=J(15+2*flag_cov,B,0)
	if (flag_cov==1){
		beta2_star=J(6+cols(Vh),6,0)
	}
	else{
		beta2_star=J(6,6,0)
	}
	
	for (b=1; b<=B; b++) {
		wei_star = (J(nh,1,(1-sqrt(5))/2) + J(nh,1,sqrt(5)):*(runiform(nh,1):<J(nh,1,(sqrt(5)-1)/(2*sqrt(5)))));
	
		for (j=1; j<=4+2*flag_cov; j++) {
			resid_star=wei_star:*resid[.,j];
			//if (j<=4){
			//	XX[j] = &((J(nh,1,1), Xh, Xh:^2, (Xh:>=J(nh,1,0)), (Xh:>=J(nh,1,0)):*Xh, (Xh:>=J(nh,1,0)):*Xh:^2):*J(1,6,condw))
			//}
			//else{
			//	XX[j] = &((J(nh,1,1), Xh, Xh:^2, (Xh:>=J(nh,1,0)), (Xh:>=J(nh,1,0)):*Xh, (Xh:>=J(nh,1,0)):*Xh:^2, Vh):*J(1,6+cols(Vh),condw)) 
			//}
			
			Y_star=(*XX[j])*beta2[1..6+(j>4)*cols(Vh),j] + resid_star
			YYY_star_h=(*omg[j]):*select(Y_star,*indh[j])
			
			beta2_star[1..6+(j>4)*cols(Vh),j]=(*Qb[j])*(*XXXb[j])'*YYY_star_h
			if (j<=4){
				est_star[j,b]=beta2_star[4,j] 
			}
			else{
				est_star[15+(j-4),b]=beta2_star[4,j]
			}
		}
		
		//thetabc_star (8 X 1) vector
        // 1 - E^ [Y | X=c+]
        // 2 - E^ [W | X=c+]
        // 3 - E^ [Y | X=c+,W=0]
        // 4 - E^ [Y | X=c+,W=1]
        // 5 - E^ [Y | X=c-]
        // 6 - E^ [W | X=c-]
        // 7 - E^ [Y | X=c-,W=0]
        // 8 - E^ [Y | X=c-,W=1]
		
		//sharp on the left, fuzzy on the right (no always-takers)
		if (var1<10^(-6)){
			thetabc_star=(beta2_star[1,1]+beta2_star[4,1])\(beta2_star[1,2]+beta2_star[4,2])\(beta2_star[1,3]+beta2_star[4,3])\ //
		     (beta2_star[1,4]+beta2_star[4,4])\beta2_star[1,1]\beta2_star[1,2]\beta2_star[1,3]\0
		}
		//fuzzy on the left, sharp on the right (no never-takers)
		else if (var2<10^(-6)){
			thetabc_star=(beta2_star[1,1]+beta2_star[4,1])\(beta2_star[1,2]+beta2_star[4,2])\0\ //
		     (beta2_star[1,4]+beta2_star[4,4])\beta2_star[1,1]\beta2_star[1,2]\beta2_star[1,3]\beta2_star[1,4]
		}
		else {
			thetabc_star=(beta2_star[1,1]+beta2_star[4,1])\(beta2_star[1,2]+beta2_star[4,2])\(beta2_star[1,3]+beta2_star[4,3])\ //
		     (beta2_star[1,4]+beta2_star[4,4])\beta2_star[1,1]\beta2_star[1,2]\beta2_star[1,3]\beta2_star[1,4]
		}
		
		//est_star(5:7)
        //prob of compliance types
		pi_c_bc_star=thetabc_star[2]- thetabc_star[6]
		pi_a_bc_star=thetabc_star[6]
		pi_n_bc_star=1-pi_c_bc_star-pi_a_bc_star

		est_star[5,b]=pi_c_bc_star
		est_star[6,b]=pi_a_bc_star
		est_star[7,b]=pi_n_bc_star
		
		//est_star(8:11)
		//etabc_star - (4x1) vectors
		//       E[Y(0)|X=c,complier]
		//       E[Y(0)|X=c,nevertaker]
		//       E[Y(1)|X=c,complier]
		//       E[Y(1)|X=c,alwaystaker]
		
		//sharp on the left, fuzzy on the right (no always-takers)
		if (var1<10^(-6)){
			etabc_star=((thetabc_star[7]*(1-thetabc_star[6]) - (1-thetabc_star[2])*thetabc_star[3])/(thetabc_star[2]-thetabc_star[6]))\thetabc_star[3]\thetabc_star[4]\0
		}
		//fuzzy on the left, sharp on the right (no never-takers)
		else if (var2<10^(-6)){
			etabc_star=thetabc_star[7]\0\((thetabc_star[4]*thetabc_star[2]-thetabc_star[6]*thetabc_star[8])/(thetabc_star[2]-thetabc_star[6]))\thetabc_star[8]
		}
		else {
			etabc_star=((thetabc_star[7]*(1-thetabc_star[6]) - (1-thetabc_star[2])*thetabc_star[3])/(thetabc_star[2]-thetabc_star[6]))\ //
				thetabc_star[3]\((thetabc_star[4]*thetabc_star[2]-thetabc_star[6]*thetabc_star[8])/(thetabc_star[2]-thetabc_star[6]))\thetabc_star[8]
		}
	    est_star[8..11,b] =etabc_star
		
		//est_star(12): OLS
		wei1_bc_star = pi_a_bc_star/(pi_a_bc_star+pi_c_bc_star*.5)
		wei2_bc_star = pi_n_bc_star/(pi_n_bc_star+pi_c_bc_star*.5)

		olsvec_bc_star=(-(1-wei2_bc_star),-wei2_bc_star,(1-wei1_bc_star),wei1_bc_star)'

		tau_ols_bc_star=olsvec_bc_star'*etabc_star
		est_star[12,b] =tau_ols_bc_star
	
		//est_star(13): LATE
		tau_iv_bc_star =ivvec'*etabc_star
		est_star[13,b] =tau_iv_bc_star
		
		//est_star(14): Hausman
		hausman_test_bc_star=tau_iv_bc_star-tau_ols_bc_star
		est_star[14,b] =hausman_test_bc_star
		
		//est_star(15): Angrist
		est_star[15,b] = angvec'*etabc_star 
		
		if (mod(b,(B/10))==0) {
			printf(" %2.0f%%", b/(B/100))  //display the bootstrap iterations
			displayflush()
		}
		
	}
	printf(" \n ")
	
	estbc=est-bias
	cov=variance(est_star')
	se=sqrt(diagonal(cov))  
	tstat=estbc:/se
	pval =2*normal(-abs(tstat))
	
	//compute joint F-value
	estw=estbc[3..4,1]
	se_estw=se[3..4,1]
	cov_estw=cov[3..4,3..4]
    Fstat1=(estw')*luinv(cov_estw)*estw 
    Fpval1=1-chi2(2,Fstat1[1,1]) 
	
	//compute joint F-value adjusted for covariance
	if (flag_cov==1){
		estw=estbc[16..17,1]
		se_estw=se[16..17,1]
		cov_estw=cov[16..17,16..17]
		Fstat2=(estw')*luinv(cov_estw)*estw 
		Fpval2=1-chi2(2,Fstat2[1,1]) 
	}
	else{
		Fstat2=0
		Fpval2=0
	}

	st_matrix("est",est)
	st_matrix("se",se)
	st_matrix("bias",bias)
	st_matrix("estbc",estbc)
	st_matrix("tstat",tstat)
	st_matrix("pval",pval)
	st_numscalar("Fstat1",Fstat1)
	st_numscalar("Fpval1",Fpval1)
	st_numscalar("Fstat2",Fstat2)
	st_numscalar("Fpval2",Fpval2)
	st_numscalar("flag",flag)
	st_numscalar("errobs",0)
	st_matrix("hwid",h)
	
	if (flag_cov==1){
		//"-->end of mata-estim-fuzzy-covariate"
		}
	else{
		//"-->end of mata-estim-fuzzy"
	}
}
end







