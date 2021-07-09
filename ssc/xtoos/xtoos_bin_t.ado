*program drop xtoos_bin_t
qui program xtoos_bin_t, rclass
version 13.0:

	syntax varlist (fv ts) [if/] [in], INDate(string) CDate(string) [Met(string) MPRob(string) /*
	*/fe dum EValopt(varname) auc wint(string) winf(string) ncut(integer 100) ts *]

******************************************************************************************************************************************
if "`dum'"=="dum" & "`fe'"=="fe" {
	di as err "option fe and option dummy variables not allowed"
	exit 250
}
******************************************************************************************************************************************
tokenize `varlist'
loc yvar "`1'"
macro shift 1
loc rhsvars "`*'"

******************************************************************************************************************************************
capture tsset
if _rc>0 {
	di as err "time/panel variables not set, use tsset/xtset ..."
	exit 0003
}
loc panvar=r(panelvar)
loc timevar=r(timevar)
loc tform=r(unit1)
loc tunit=r(unit)

if "`panvar'"=="." {
	loc panvar _id_
	capture qui gen _id_=1
	if "`tunit'"=="0" qui xtset _id_ `timevar'
	else qui xtset _id_ `timevar', `tunit'
}
if "`tform'"=="q" { 
	loc indate=quarterly("`indate'","YQ")
	loc cdate=quarterly("`cdate'","YQ")
}
else if "`tform'"=="m"  {
	loc indate=monthly("`indate'","YM")
	loc cdate=monthly("`cdate'","YM")
}
else {
	loc indate=real("`indate'")
	loc cdate=real("`cdate'")
}

******************************************************************************************************************************************

if "`if'"!="" qui xtlogit `yvar' `rhsvars' if `timevar'<=`indate' & `if'
else qui xtlogit `yvar' `rhsvars' if `timevar'<=`indate'

tempvar sample
qui gen `sample'=e(sample)
qui replace `sample'=l.`sample' if `timevar'>`indate' & `timevar'<=`cdate'

*********************************************************************************************************************

loc ousd = `cdate'-`indate'
matrix R0 = J(`ousd',6,.)
matrix I0 = J(1,`ousd',1)

*********************************************************************************************************************

forvalues k=1/`ousd' {	
	
	loc j=`ousd'-`k'+1
	matrix R`j' = J(`j',6,.)
	
	************************************************************
	tempvar prf samplein

	if "`met'"=="" {
		if "`dum'"=="dum" {
			if "`if'"!="" qui xtlogit `yvar' `rhsvars' i.`panvar' if `if' & `timevar'<`indate'+`k' & `sample'==1, `options'
			else qui xtlogit `yvar' `rhsvars' i.`panvar' if `timevar'<`indate'+`k' & `sample'==1, `options'
		}
		else {
			if "`if'"!="" qui xtlogit `yvar' `rhsvars' if `if' & `timevar'<`indate'+`k' & `sample'==1, `fe' `options'
			else qui xtlogit `yvar' `rhsvars' if `timevar'<`indate'+`k' & `sample'==1, `fe' `options'
		}
	}
	else if "`dum'"=="dum" {
		if "`if'"!="" qui `met' `yvar' `rhsvars' i.`panvar' if `if' & `timevar'<`indate'+`k' & `sample'==1,`options'
		else qui `met' `yvar' `rhsvars' i.`panvar' if `timevar'<`indate'+`k' & `sample'==1, `options'
	}	
	else {
		if "`if'"!="" qui `met' `yvar' `rhsvars' if `if' & `timevar'<`indate'+`k' & `sample'==1, `fe' `options' 
		else qui `met' `yvar' `rhsvars' if `timevar'<`indate'+`k' & `sample'==1, `fe' `options' 
	}	
	
	qui gen `samplein'=e(sample)

	loc allxvars : colfullnames e(b)
	loc xvars : list allxvars-lyvar
	
	fvexpand i.`panvar' if `samplein'==1
	loc dumi=r(varlist)

	if "`mprob'"=="" qui predict `prf', `mprob'
	else qui predict `prf', `mprob'
	
	capture {
		if "`evalopt'"=="" qui roctab `yvar' `prf' if `samplein'==1 & `sample'==1 & `timevar'<`indate'+`k'
		else qui roctab `yvar' `prf' if `samplein'==1 & `sample'==1 & `evalopt'==1 & `timevar'<`indate'+`k'
	}
	if "`auc'"=="auc" {
		if "`evalopt'"=="" qui auc `yvar' `prf' if `samplein'==1 & `sample'==1 & `timevar'<`indate'+`k', ncut(`ncut') wint(`wint') winf(`winf')
		else qui auc `yvar' `prf' if `samplein'==1 & `sample'==1 & `evalopt'==1 & `timevar'<`indate'+`k', ncut(`ncut') wint(`wint') winf(`winf')
	}
	matrix R0[`k',1]=r(area)
	if "`auc'"=="" matrix R0[`k',2]=r(se)
	else matrix R0[`k',2]=.
	matrix R0[`k',5]=r(N)

	capture {
		if "`evalopt'"=="" qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1 & `timevar'>=`indate'+`k'
		else qui roctab `yvar' `prf'  if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'>=`indate'+`k'
	}
	if "`auc'"=="auc" {
		if "`evalopt'"=="" qui auc `yvar' `prf' if `samplein'==0 & `sample'==1 & `timevar'>=`indate'+`k', ncut(`ncut') wint(`wint') winf(`winf')
		else qui auc `yvar' `prf' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'>=`indate'+`k', ncut(`ncut') wint(`wint') winf(`winf')
	}
	matrix R0[`k',3]=r(area)
	matrix R0[`k',6]=r(N)
	if "`auc'"=="" matrix R0[`k',4]=r(se)
	else matrix R0[`k',4]=.
	
	forvalues t=1/`j' {
		capture {
			if "`evalopt'"=="" qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1 & `timevar'==`indate'+`t'+`k'-1
			else qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'==`indate'+`t'+`k'-1
		}
		if "`auc'"=="auc" {
			if "`evalopt'"=="" qui auc `yvar' `prf' if `samplein'==0 & `sample'==1 & `timevar'==`indate'+`t'+`k'-1, ncut(`ncut') wint(`wint') winf(`winf')
			else qui auc `yvar' `prf' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'==`indate'+`t'+`k'-1, ncut(`ncut') wint(`wint') winf(`winf')
		}
		matrix R`j'[`t',3]=r(area)
		matrix R`j'[`t',6]=r(N)
		if "`auc'"=="" matrix R`j'[`t',4]==r(se)
		else matrix R`j'[`t',4]==.
	}	
	

}
*********************************************************************************************************************
matrix RF = J(`ousd',6,1)

forvalues i=1/`ousd' {
	loc k=`ousd'-`i'+1
	matrix RF`i' = J(`k',6,.)
	forvalues h=1/`k' {
		loc j=`ousd'-`h'+1
			forvalues l=1/6 {
				matrix RF`i'[`h',`l']=R`j'[`i',`l']
			}	
	}	
	matrix I`i' = J(1,`k',1)
	matrix n`i'=I`i'*RF`i'[1...,6]
	scalar n`i'=n`i'[1,1]
	matrix RFSo`i' = (1/n`i')*RF`i'[1...,6]'*RF`i'[1...,3..4]
	matrix RFS`i' = J(1,2,.) , RFSo`i' , J(1,1,.) , n`i' 
	forvalues j=1/6 {
		matrix RF[`i',`j'] = RFS`i'[1,`j']
	}
}

matrix ni=I0*R0[1...,5]
matrix no=I0*R0[1...,6]
scalar ni=ni[1,1]
scalar no=no[1,1]
matrix Ri = (1/ni)*R0[1...,5]'*R0[1...,1..2]
matrix Ro = (1/no)*R0[1...,6]'*R0[1...,3..4]
matrix R = Ri , Ro , ni , no 


matrix N = RF[1...,6]
matrix n=I0*N
scalar n=n[1,1]
forvalues i=1/`ousd' {
	foreach j in 1 2 5 {
		matrix RF[`i',`j'] = R0[`i',`j']
	}
}
matrix RFo = RF[1...,3..4]
matrix RFSo = (1/n)*N'*RFo
matrix RFS = Ri , RFSo , ni , n

forvalues i=1/`ousd' {
	loc j=`indate'+`i'-1
	if "`tform'"=="q" loc j = string(year(dofq(`j')))+"q"+string(quarter(dofq(`j')))
	else if "`tform'"=="m" loc j = string(year(dofm(`j')))+"q"+string(month(dofm(`j')))
	loc rowsR0 `rowsR0' `j'
	loc rowsRF `rowsRF' `i'
}

matrix rownames R0 = `rowsR0'
matrix rownames R = Summary

matrix rownames RF = `rowsRF'
matrix rownames RFS = Summary

matrix R = R0\R
matrix RFS = RF\RFS

matrix colnames R = ROC_in ROC_SE_in ROC_os ROC_SE_os N_in N_os
matrix colnames RFS = ROC_in ROC_SE_in ROC_os ROC_SE_os N_in N_os

matlist R, title("Out of sample evaluation according to last last in-sample date") lines(rowt)
matlist RFS, title("Out of sample evaluation according to forecasting horizon") lines(rowt)

return matrix ev_last R
return matrix ev_hor RFS

end

***************************************************************************************************************************
// Subprogram auc //
*qui program drop auc

qui program auc, rclass
version 13.0
	syntax varlist (min=2 max=2 num) [if/] [in] [, Ncut(integer 100) table snr wint(string) winf(string) ]

tokenize `varlist'
loc dvar "`1'"
loc probvar "`2'"

tempvar windowt windowf roc0 roc sn

loc nm=`ncut'+1
capture drop cut TPR FPR
qui gen cut = .
qui replace cut=1 in 1
qui gen TPR = .
qui replace TPR=0 in 1
qui gen FPR = .
qui replace FPR=0 in 1

matrix RTF = J(`nm',3,.)
matrix SNR = J(1,2,.)

if "`wint'"=="" qui gen `windowt'=0
else qui gen `windowt'=`wint'
if "`winf'"=="" qui gen `windowf'=0
else qui gen `windowf'=`winf'

qui gen `roc0' = .
qui gen `sn' = .

forvalues n=2(1)`nm' {
	tempvar pos 
	loc n0=`n'-1
	loc p=(1-(1/`ncut')*`n0')
	gen `pos'=`probvar'!=. & `probvar'>=`p'
	if "`if'"=="" {
		qui sum `pos' if `dvar'==1 & `probvar'!=. & `windowt'==0
		scalar tpr=r(mean)
		scalar t1=r(N)
		qui sum `pos' if `dvar'==0 & `probvar'!=. & `windowf'==0
		scalar fpr =r(mean)
		scalar t0=r(N)
	}
	else {
		qui sum `pos' if `dvar'==1 & `probvar'!=. & `windowt'==0 & `if'
		scalar tpr=r(mean)
		scalar t1=r(N)
		qui sum `pos' if `dvar'==0 & `probvar'!=. & `windowf'==0 & `if'
		scalar fpr =r(mean)
		scalar t0=r(N)
	}
	qui replace cut=`p' in `n'
	qui replace TPR=tpr in `n'
	qui replace FPR=fpr in `n'
	qui replace `roc0'=TPR[`n'-1]*(FPR-FPR[`n'-1])+(TPR-TPR[`n'-1])*(FPR-FPR[`n'-1])/2 in `n'
	if "`snr'"=="snr" {
		qui replace `sn'=TPR-FPR in `n'
	}
}
qui gen `roc'=sum(`roc0')
scalar auc=`roc'[`nm']

mkmat cut TPR FPR in 1/`nm', mat(RTF)
mata : st_matrix("RTF", sort(st_matrix("RTF"), 1))
matrix colnames RTF = cut TPR FPR
matrix rownames RTF = "."

di "AUC: " auc
return scalar area = auc
return scalar N = t1 + t0
if "`table'"=="table" matlist RTF, title("True Positive and False Positive Ratios by Probability Threshold")

if "`snr'"=="snr" {
	mkmat cut `sn' in 1/`nm', mat(SN)
	mata : st_matrix("SN", sort(st_matrix("SN"), -2))
	matrix SNR[1,1] = SN[2,1]
	matrix SNR[1,2] = SN[2,2]
	matrix colnames SNR = PROB* SNR*
	matrix rownames SNR = "."
	matlist SNR, title("Optimal Probability Threshold and Maximum SNR")
}

qui drop cut TPR FPR

end

***************************************************************************************************************************
