/***-------------------------------------------------------
 Stata command: GLMDECO
 This program was written by Boris Kaiser, University of Bern
 2015-09-06: 
 - version requirement set to 11.0.
 - bug fix for cases with collinear variables
------------------------------------------------------- ***/

program define glmdeco, rclass
version 11.0
syntax varlist(numeric min=1) [in] [if] [aw pw iw fw /], Group(string) ///
[Link(string) Family(string) NODETail ipw(string) ///
 Boot approx ITERation(integer 100) SUBbs(string) ///
Normcoef cat1(string) cat2(string) cat3(string) cat4(string) cat5(string) ///
cont1(string) cont2(string) cont3(string) cont4(string) cont5(string) ///
vec1(string) vec0(string) fixed ]
 
*-------------------------------------------------------


*return error when iter is set, but boot is not
if "`boot'" != "boot" & (`iteration'!=100 | "`subbs'"!="") {
di as err "you must specify the option ''boot'' when using " /*
*/ "options ''iter'' or ''subbs''  "
exit
}
*check whether package 'distinct' is installed. 
cap confirm file "c:\ado\plus\d\distinct.ado" 
if _rc>0 {
di as text "Note: the package 'distinct' must be installed first. " /*
*/ "If automatic installation fails, type 'net install dm0042'." 
net install "http://www.stata-journal.com/software/sj8-4/dm0042"
}
*return error if group variable is not binary
qui distinct `group'
if r(ndistinct)!=2 {
di as err "`group' is not binary!"
exit
}
*return error if weight is not pw
if "`weight'" != "pweight" &  "`weight'" != "" {
di as err "weights must be pweight"
exit
}
*return error if subbs is not between 1 and 100
if "`subbs'"!="" & (real("`subbs'")>100 | real("`subbs'")<1)  {
di as err "'subbs' must be between 1 and 100."
exit
}

* mark obs to be included by if/in
marksample touse

*unabbreviate lists
foreach kind in cat cont {
	forvalues c=1/5 {
		if "``kind'`c''"!="" {
		qui unab `kind'`c': ``kind'`c''
		loc firstcat: word 1 of ``kind'`c''
		loc remainingcat: list `kind'`c' - firstcat
		_rmcoll `remainingcat' if `touse' & `group'>0, forcedrop
		loc remainingcat "`r(varlist)'"
		_rmcoll `remainingcat' if `touse' & `group'==0, forcedrop
		loc remainingcat "`r(varlist)'"
		loc `kind'`c' "`firstcat' `remainingcat'"
		}
	}
}

*unabbreviate all lists
loc allcont `cont1' `cont2' `cont3' `cont4' `cont5'
loc allcat `cat1' `cat2' `cat3' `cat4' `cat5'

* get dep var and indep var from varlist
gettoken (local) depvar (local) indepvar1 : varlist
if "`indepvar1'"!="" unab indepvar1: `indepvar1'
* flag collinear variables in indepvar	
_rmcoll `indepvar1' 	if `touse' & `group'>0, forcedrop
loc remainingvar "`r(varlist)'"
_rmcoll `remainingvar' 	if `touse' & `group'==0, forcedrop
loc remainingvar "`r(varlist)'"
loc indepvar1 "`remainingvar'"

loc indepvar2_all ="`allcat' `allcont' `indepvar1'" /*including ref. categories*/
loc indepvar2_est ="`allcont' `indepvar1'" /*without ref. categories*/
forvalues c=5(-1)1 {
	if "`cat`c''"!="" {
		loc firstcat: word 1 of `cat`c''
		loc without_firstcat: list cat`c' - firstcat
		loc indepvar2_est =  "`without_firstcat' `indepvar2_est'"
	}
} 
***

*return error if dummies are specified in "cont" or if 
*continuous are specified in "cat"
loc stoprule=0
foreach c of loc allcont {
	loc testvar "`c'"
	qui distinct `testvar'
	if r(ndistinct)<=2 loc stoprule=1
}
foreach c of loc allcat {
	loc testvar "`c'"
	qui distinct `testvar'
	if r(ndistinct)>2 loc stoprule=2
}
if `stoprule'==1 {
di as err "variables in cont[1-5](varlist) must be continuous!"
exit
}
else if `stoprule'==2 {
di as err "variables in cat[1-5](varlist) must be binary!"
exit
}
*error if variable is specified in both "indepvar and cat/cont"
foreach v of local varlist {
	foreach c in `allcont' `allcat' {
		if strmatch("`v'","`c'") loc stoprule=1
	}
}
if `stoprule'==1 {
di as err "variables should not appear in both indepvar AND the cont/cat options"
exit
}
*rename fixed beta matrices
if "`fixed'"=="fixed" {
	mat vec1=`vec1'
	mat vec0=`vec0'
}
*-------------------------------------------------------
*set GLM family
if "`family'"=="" {
loc family "gau"
}
else if inlist(substr("`family'",1,3),"poi","gam","gau","b","nb")==0 {
di as err "family not valid"
exit
}
*set GLM link function
if "`link'"=="" {
loc link "i"
}
else if inlist(substr("`link'",1,3),"i","log","l","p","c","nb")==0 {
di as err "link not valid"
}
*set number of iterations
if "`boot'" =="" {
	loc reps=1
}
else {
	loc reps=`iteration'
}
* generate weight variable
tempvar w
if "`weight'" != "" {
	g double `w'=`exp'
}
else {
	g `w'=1
}
*generate IPW for regression
tempvar ipw2
if "`ipw'" != "" {
	g double `ipw2' = `ipw' * `w'
}
else {
	tempvar ipw
	g double `ipw2' = `w'
}


* empty matrices for placing the results
mata:MY=J(`reps',3,.)
mata:AD=J(`reps',2,.)
mata:Diff=J(`reps',1,.)
if "`normcoef'"=="" 		loc k=wordcount("`indepvar2_est'")+1
if "`normcoef'"=="normcoef" loc k=wordcount("`indepvar2_all'")+1
mata:DDX=J(`reps',`k',.)
mata:DDS=J(`reps',`k',.)
* find numbers of grouped variables that are to be combined
mat ncat=J(5,1,.)
mat ncont=J(5,1,.)
forvalues r=1/5 {
	if wordcount("`cat`r''")>0 {
		mat ncat[`r',1]=wordcount("`cat`r''")-1
	}
	else {
		mat ncat[`r',1]=wordcount("`cat`r''")
	}
	mat ncont[`r',1]=wordcount("`cont`r''")
}
* generate tempvars for marking samples of group=0 and group=1
tempvar group0 group1
qui replace `group'=. if `touse'==0 /*set unused obs to missing */
g `group0' = (`group'==0)
g `group1' = (`group'==1)
qui count if `group0'
sca N0=r(N)
qui count if `group1'
sca N1=r(N)
* determine default subsample bootstrap
if "`subbs'" =="" {
	if N1+N0>=50000 {
	loc subsample=20
	}
	else if N1+N0<50000 & N1+N0>=10000 {
	loc subsample=round(120 - 0.0020*(N1+N0))
	}
	else {
	loc subsample=100
	}
}
else {
	loc subsample=real("`subbs'")
}
*-------------------------------------------------------
* estimation 

forvalues i=1/`reps' { 
if `i'==2 sca t1=clock("$S_TIME", "hms")

	preserve
	*first iteration is for point estimates, subsequent for bootstrap
	if `i'!=1  {
	bsample round(`subsample'/100*(N0+N1))
	}
	*sort data
	sort `group'
	
	qui {
		* run  regressions
		tempvar y1 y0 sqr0 sqr1
		
		glm `depvar' `indepvar2_est'  if `group0' [pw= `ipw2'], ///
		link(`link') fam(`family') iter(200) 
		mat beta0=e(b)
		if "`fixed'"=="fixed" mat beta0=vec0
		matlist e(b)
		predict `y0'
		su `y0' [aw=`w'] if `group0', meanonly
		sca my0=r(mean)
		su `y0' [aw=`w'] if `group1', meanonly
		sca myc=r(mean)
		* BIC
		g double `sqr0'=(`depvar' - `y0')^2
		su `sqr0' if `group0' [aw=`w']
		ret sca bic0=e(N)*ln( r(mean) ) + e(k)*ln(e(N))
		
		glm `depvar' `indepvar2_est' if `group1' [pw= `ipw2'], ///
		link(`link') fam(`family') iter(200) 
		matlist e(b)
		mat beta1=e(b)
		if "`fixed'"=="fixed" mat beta1=vec1
		predict `y1'
		su `y1' [aw=`w'] if `group1', meanonly
		sca my1=r(mean)
		* BIC
		g double `sqr1'=(`depvar' - `y1')^2
		su `sqr1' if `group1' [aw=`w']
		ret sca bic1=e(N)*ln( r(mean) ) + e(k)*ln(e(N))
		
		* squared correlations (R^2)
		if `i'==1 { 
			qui corr `depvar' `y0' if `group0'
			loc r2_m0=r(rho)^2
			ret sca r2_m0=r(rho)^2
			qui corr `depvar' `y1' if `group1'
			loc r2_m1=r(rho)^2
			ret sca r2_m1=r(rho)^2
		}
		*di "raw diff=" my1 - my0 " | ADX=" myc-my0 " | ADS=" my1-myc
	} /*end of quiet*/
	
	if "`nodetail'"=="" {
		*normalize coefficients of categorical variables
		if "`normcoef'"=="normcoef" {
			mata: normcoef("beta0", "beta1", "ncat", "`indepvar2_all'", /*
			*/ "`group0'", "`group1'")
			loc id2 "all"
		}
		else {
			loc id2 "est"
		}
		*run external mata command to perform decomposition
		if "`approx'"=="" {
			mata: compute_bk("`y1'", "`y0'", "`indepvar2_`id2''", "`group1'", /*
			*/ "`group0'", "`w'", "beta0", "beta1")
		}
		else {
			mata: compute_approx("`y1'", "`y0'", "`indepvar2_`id2''", /*
			*/ "`group1'", "`group0'", "`w'", "beta0", "beta1")
		}
		*DD:ship results from i-th iteration to mata
		mata: DDX[`i',.]=st_matrix("DDx")'
		mata: DDS[`i',.]=st_matrix("DDs")'
	} /* end of "`nodetail'"!="" */
	
	*AD:ship results from i-th iteration to mata
	mata: compute_aggregate("`y1'", "`y0'", "`group1'", "`group0'", "`w'")
	mata: AD[`i',.]=st_numscalar("ADx"),st_numscalar("ADs")
	mata: MY[`i',.]=st_numscalar("my0"),st_numscalar("myc"),st_numscalar("my1")
	mata: Diff[`i',.]=st_numscalar("ADx")+st_numscalar("ADs")
	
	* display bootstrap dots
	if (`i'==1 & "`boot'"!="") {
	di as text "bootstrap in progress" 
	di as txt "{hline 4}{c +}{hline 3} 1 "	///
			  "{hline 3}{c +}{hline 3} 2 "	///
			  "{hline 3}{c +}{hline 3} 3 "	///
			  "{hline 3}{c +}{hline 3} 4 "	///
			  "{hline 3}{c +}{hline 3} 5 "		
	}
	loc round=`i'/50
	capture confirm integer number `round'
	if !_rc {
		di in gr ". " `i'
	}
	else {
		di in gr "." _c
	}

	restore
}
*-------------------------------------------------------
* assemble results 
*0) means
mata:e_y0=MY[1,1]
mata:V_y0=sqrt( (`subsample'/100)*variance(MY[.,1]) )
mata:e_yc=MY[1,2]
mata:V_yc=sqrt( (`subsample'/100)*variance(MY[.,2]) )
mata:e_y1=MY[1,3]
mata:V_y1=sqrt( (`subsample'/100)*variance(MY[.,3]) )
*0) observed differrence
mata:e_Diff=Diff[1,1]
mata:V_Diff=sqrt( (`subsample'/100)*variance(Diff) )
*1)aggregate decomposition
mata:e_ADX=AD[1,1]
mata:e_ADS=AD[1,2]
mata:V_ADX=sqrt( (`subsample'/100)*diagonal(variance(AD[.,1])) )
mata:V_ADS=sqrt( (`subsample'/100)*diagonal(variance(AD[.,2])) )
if "`nodetail'"=="" {
*2)detailed decomposition
*ship results matrices to stata
mata: st_matrix("DDX",DDX)
mata: st_matrix("DDS",DDS)

*run external program to consolidate categorical variables
if ncat[1,1]!=0 | ncont[1,1]!=0 {
	*if coefficients are normalized, expand number of categories by 1
	if "`normcoef'"=="normcoef" {
		forvalues i=1/5 {
			if ncat[`i',1]>0 mat ncat[`i',1]=ncat[`i',1]+1
		}
	}
	* run program to aggregate variables in cat/cont
	mata: compute_cat("DDX", "DDS", "ncat", "ncont")
	
}
*ship results back to mata
mata:DDX=st_matrix("DDX")
mata:DDS=st_matrix("DDS")
*compute estimates and st.err of detailed decomposition
mata:V_DDS=sqrt( (`subsample'/100)*diagonal(variance(DDS)) )
mata:V_DDX=sqrt( (`subsample'/100)*diagonal(variance(DDX)) )
mata:e_DDX=DDX[1,.]'
mata:e_DDS=DDS[1,.]'
}

*3) combine results in one matrix and add p-values 
if "`nodetail'"=="" {
mata:R=e_Diff,V_Diff\e_ADX,V_ADX\e_DDX,V_DDX\e_ADS,V_ADS\e_DDS,V_DDS
mata:pc=100 * (1 \ R[2::rows(e_DDX)+2,1]/e_Diff \ R[3+rows(e_DDX)::rows(R),1]/e_Diff)
}
else {
mata:R=e_Diff,V_Diff\e_ADX,V_ADX\e_ADS,V_ADS
mata:pc=100 * (1 \ R[2::3,1]/e_Diff )
}
mata:pval=2*(J(rows(R),1,1)-normal(editmissing(abs(R[.,1]:/R[.,2]),0)))
mata:R=R,pval,pc
mata:st_matrix("R",R)
mata:M=e_y0,V_y0\e_yc,V_yc\e_y1,V_y1
mata:st_matrix("M",M)
mat coln M = est se
mat rown M = mean_0 mean_cf mean_1

*for labeling: generate list of indepvars including constant!
loc xlist "`indepvar1' constant"  
foreach kind in cont cat {
	forvalues c=5(-1)1 {
		loc xlist=regexr(word("``kind'`c''",1),"[0-9]","") + " `xlist'"
	}
}
loc k=wordcount("`xlist'")
tokenize `xlist' 

*label stata matrix with results
if "`nodetail'"=="" loc lab_xlist "`xlist'"
else				loc lab_xlist ""
*matlist R
mat rown R=tot_diff tot_Dx `lab_xlist' tot_Ds `lab_xlist'
mat coln R=est se pval percent
*matlist R
if "`nodetail'"=="" loc show "*"
else				loc show ""


*-------------------------------------------------------
*display results

*timestamp
sca t2=clock("$S_TIME", "hms")
loc fo "%8.0g"
loc pfo "%9.3f"
loc tab1 "_col(25)"
if "`approx'"=="approx" {
loc ddmodel="approximative"
}
else {
loc ddmodel="exact"
}
if `reps'>1 loc timeperit=0.001*(t2-t1)/(`reps'-1)
di as text ""
di as text "{hline 60}" 
di as text "Decomposition method:" `tab1' "`ddmodel'"
di as text "Model estimation:" `tab1' "`family' family, `link'-link"
di as text "Dependent variable:" `tab1' "`depvar'"
di as text "Covariates:" `tab1' trim("`indepvar2_est'")
di as text "Group:" `tab1' "`group'"
if "`weight'" !="" di as text "Weights:" `tab1' "`exp'"
if `reps'>1 di as text "Number of iterations:" `tab1' "`reps' "
if `reps'>1 di as text "Time per iteration:" `tab1' `timeperit' " sec."
di as text "Decomposition of gap in outcome `depvar' " _c
di as text "between `group'==1 and `group'==0"
di as text "{hline 60}" 
di as text " "
di as text _column(26) "estimate   st.err.     p-value"
di as text "{hline 60}" 
di as text "total differential" `tab1' as res `fo' R[1,1] "  " _c
di as res `fo' R[1,2] "  " as res `pfo' R[1,3]
di as text "{hline 60}" 
di as text "characteristics effect" `tab1' as res `fo' R[2,1] "  " _c
di as res `fo' R[2,2] "  " as res `pfo' R[2,3]
loc rowl=3


if "`nodetail'"=="" {
	forvalues v=1/`k' {
	di as text "  ``v''    " `tab1' as res `fo' R[`rowl',1] "  " _c
	di as res `fo' R[`rowl',2]  "  " as res `pfo' R[`rowl',3]
	loc rowl=`rowl'+1
	}
	di as text "{hline 60}" 
}

di as text "coefficient effect" `tab1' as res `fo' R[`rowl',1] "  " _c
di as res `fo' R[`rowl',2] "  " as res `pfo' R[`rowl',3]

if "`nodetail'"=="" {
	loc rowl=`rowl'+1
	forvalues v=1/`k' {
	di as text "  ``v''" `tab1' as res `fo' R[`rowl',1] "  " _c
	di as res `fo' R[`rowl',2] "  " as res `pfo' R[`rowl',3]
	loc rowl=`rowl'+1
	}
}

di as text "{hline 60}" 
di as text "number of obs. in group 0:"  _column(29) as res N0
di as text "number of obs. in group 1:"  _column(29) as res N1
di as text "{hline 60}" 


*-------------------------------------------------------
*save stuff in r()
ret mat R=R, copy
ret mat M=M, copy
ret sca N0=N0
ret sca N1=N1
ret sca ADs=ADs
ret sca ADx=ADx
ret sca Diff=ADx+ADs
ret loc subsample=`subsample' 
ret loc xlist="`xlist'"
end
*-------------------------------------------------------
* Mata functions

* mata function for normalizing the coefficients of categorical variables
mata
void normcoef(string scalar beta0, string scalar beta1, string scalar ncat, /*
*/ string scalar indepvar2, string scalar group0, string scalar group1)
{
	m_ncat=st_matrix(ncat)
	b1=st_matrix(beta1)'
	b0=st_matrix(beta0)'
	k=rows(b1)
	first=1
	cadj0=0
	cadj1=0
	X0=st_data(.,tokens(indepvar2),group0)
	X1=st_data(.,tokens(indepvar2),group1)
	for (i=1; i<=rows(m_ncat); i++)
	{
		// continue if cat-i group is specified
		if (m_ncat[i,1]>0) {
		
			last=first-1+m_ncat[i,1]
			b0sub=0\b0[first..last,1]
			b1sub=0\b1[first..last,1]
			cadj0=cadj0+mean(b0sub)
			cadj1=cadj1+mean(b1sub)
			b0sub=b0sub-(mean(b0sub)*J(rows(b0sub),1,1))
			b1sub=b1sub-(mean(b1sub)*J(rows(b1sub),1,1))

			if (i==1) {
				b0cat=b0sub
				b1cat=b1sub
			}
			else  {
				b0cat=b0cat\b0sub
				b1cat=b1cat\b1sub
			}
			first=last+1
		}
	}
	if (sum(m_ncat)>=k-1) { // for the case where there are only cat-variables
		b0=b0cat \ b0[k,1]+cadj0
		b1=b1cat \ b1[k,1]+cadj1
	}
	else { // for the case with other variables
		b0=b0cat \ b0[sum(m_ncat)+1..k-1,1] \ b0[k,1]+cadj0
		b1=b1cat \ b1[sum(m_ncat)+1..k-1,1] \ b1[k,1]+cadj1
	}
	st_matrix("beta0",b0')
	st_matrix("beta1",b1')
}
end

* mata function for joining sets of variables
mata
void compute_cat(string scalar DDX, string scalar DDS, string scalar ncat, /*
*/ string scalar ncont)
{
	m_DDX=st_matrix(DDX)
	m_DDS=st_matrix(DDS)
	m_ncat=st_matrix(ncat)
	m_ncont=st_matrix(ncont)
	m_ncols=m_ncat\m_ncont
	DDXfix=m_DDX[.,sum(m_ncols)+1::cols(m_DDX)]
	DDSfix=m_DDS[.,sum(m_ncols)+1::cols(m_DDS)]
	first=1
	ipos=1
	for (i=1; i<=rows(m_ncols); i++)
	{
		last=first-1+m_ncols[i,1]
		
		if (m_ncols[i,1]>0) {
		
			if (ipos==1) {
			DDXcat=rowsum(m_DDX[.,first::last])
			DDScat=rowsum(m_DDS[.,first::last])
			}
			else {
			DDXcat=DDXcat,rowsum(m_DDX[.,first::last])
			DDScat=DDScat,rowsum(m_DDS[.,first::last])
			}
			ipos=ipos+1
		}
		
		first=last+1
	}
	m_DDX=DDXcat,DDXfix
	m_DDS=DDScat,DDSfix
	st_matrix("DDX",m_DDX)
	st_matrix("DDS",m_DDS)
}
end

* mata function for our decomposition
mata
void compute_bk(string scalar y1, string scalar y0, string scalar indepvar2, ///
 string scalar group1, string scalar group0, string scalar w,  ///
 string scalar beta0, string scalar beta1)
	{
	// inputs
	b0=st_matrix(beta0)'
	b1=st_matrix(beta1)'
	k=rows(b0)
	X1=st_data(.,tokens(indepvar2),group1)
	X0=st_data(.,tokens(indepvar2),group0)
	w1=st_data(.,w,group1)
	w0=st_data(.,w,group0)
	N1=rows(X1)
	N0=rows(X0)
	X1=X1,J(N1,1,1)
	X0=X0,J(N0,1,1)
	yh1=st_data(.,y1,group1)
	yc =st_data(.,y0,group1)
	yh0=st_data(.,y0,group0)
	
	// aggregate decomposition
	Ds=mean(yh1,w1)-mean(yc,w1)
	Dx=mean(yc,w1) -mean(yh0,w0)
	st_numscalar("ADx",Dx)
	st_numscalar("ADs",Ds)
	
	//composition effect
	DDx=J(N1,k,.)
	for (i=1; i<=N1; i++)
	{
		x=X1[i,.]
		A=yc[i,1]*J(N0,1,1) - yh0
		//A=exp(x*b0)*J(N0,1,1)  - exp(X0*b0)
		C=(x # J(N0,1,1) - X0)*b0
		B=(x # J(N0,1,1) - X0) :* ( b0' # J(N0,1,1))
		DDx[i,.]=mean( editmissing( (J(1,k,1)#A) :* B :/ (J(1,k,1)#C) ,0) ,w0)
	}
	DDx=mean(DDx,w1)'
	//structural effect
	A=yh1 - yc
	//A=exp(X1*b1) - exp(X1*b0)
	B=X1 :* ( J(N1,1,1)#(b1-b0)' )
	C=X1 * (b1-b0)
	DDs=mean( editmissing( (J(1,k,1)#A) :* B :/ (J(1,k,1)#C) ,0) ,w1)'
	st_matrix("DDx",DDx)
	st_matrix("DDs",DDs)
	}
end

* mata function for Yun's decomposition
mata
void compute_approx(string scalar y1, string scalar y0, ///
	string scalar indepvar2, string scalar group1, ///
	string scalar group0, string scalar w, string scalar beta0, string scalar beta1)
	{
	b0=st_matrix(beta0)'
	b1=st_matrix(beta1)'
	k=rows(b0)
	X1=st_data(.,tokens(indepvar2),group1)
	X0=st_data(.,tokens(indepvar2),group0)
	w1=st_data(.,w,group1)
	w0=st_data(.,w,group0)
	yh1=st_data(.,y1,group1)
	yc =st_data(.,y0,group1)
	yh0=st_data(.,y0,group0)
	N1=rows(X1)
	N0=rows(X0)

	X1=X1,J(N1,1,1)
	X0=X0,J(N0,1,1)
	mX1 =mean(X1,w1)
	mX0 =mean(X0,w0)
	// aggregate decomposition
	Ds=mean(yh1,w1)-mean(yc,w1)
	Dx=mean(yc,w1) -mean(yh0,w0)
	st_numscalar("ADx",Dx)
	st_numscalar("ADs",Ds)

	// vectors of detailed decomposition
	DDs=Ds * ( mX1':*(b1-b0)) * (mX1*(b1-b0)):^(-1)
	DDx=Dx * ((mX1-mX0)':*b0) * ((mX1-mX0)*b0):^(-1)
	st_matrix("DDx",DDx)
	st_matrix("DDs",DDs)
	}
end

* mata function: aggregate decomposition
mata
void compute_aggregate(string scalar y1, string scalar y0, ///
	string scalar group1, string scalar group0, string scalar w)
	{
	w1=st_data(.,w,group1)
	w0=st_data(.,w,group0)
	yh1=st_data(.,y1,group1)
	yc =st_data(.,y0,group1)
	yh0=st_data(.,y0,group0)
	// aggregate decomposition
	Ds=mean(yh1,w1)-mean(yc,w1)
	Dx=mean(yc,w1) -mean(yh0,w0)
	st_numscalar("ADx",Dx)
	st_numscalar("ADs",Ds)
	}
end
