*program drop xtoos_bin_i
qui program xtoos_bin_i, rclass
version 13.0:

	syntax varlist (fv ts) [if/] [in], Ous(integer) Ksmpl(integer) [Rsmpl(integer 1) MPRob(string) EValopt(varname) /*
	*/Met(string) fe dum lags(numlist integer) auc wint(string) winf(string) ncut(integer 100) *]

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

capture tsset
if _rc>0 {
	di as err "time/panel variables not set, use tsset/xtset ..."
	exit 0003
}
loc panvar=r(panelvar)
loc timevar=r(timevar)
	
******************************************************************************************************************************************

if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' if `if'
else qui xtlogit `yvar' `lyvar' `rhsvars'

fvexpand i.`panvar' if e(sample)
loc idum=r(varlist) 

tempvar sample
qui gen `sample'=e(sample)
qui replace `sample'=. if `sample'==0

*********************************************************************************************************************

loc numid = wordcount("`idum'")

foreach x of loc idum {
	loc k=regexr("`x'",".`panvar'","")
	loc k=regexr("`k'","b","")
	loc k=regexr("`k'","o","")
	loc idumn `idumn' `k'
	}

*********************************************************************************************************************
loc kn =round(`numid'/`ous')
matrix R0 = J(`kn',6,.)
matrix I1 = J(1,`kn',1)


*********************************************************************************************************************
if `rsmpl'>=1 {
	matrix RS = J(`rsmpl',6,.)
	matrix I2 = J(1,`rsmpl',1)
	
	forvalues r=1/`rsmpl' {
		loc idumn2 "`idumn'"
		loc rndid ""
		loc rndidk ""

		forvalues k=1/`kn' {	
			if `k'<`kn' {
				foreach i of loc rndid {
					loc rndidk `rndidk' ``i''
				}
				loc idumn2 : list idumn2-rndidk
				loc numid2 = wordcount("`idumn2'") 
				tokenize `idumn2'
				loc rndid ""
				loc rndidk ""
				matrix A = `numid2'*matuniform(1,`ous')
					
				forvalues i=1/`ous' {
					loc x= A[1,`i']
					loc j=round(`x')
					loc rndid `rndid' `j'
					}
						
				loc zero 0
				loc rndid : list uniq rndid 
				loc rndid : list rndid-zero 
				loc nrndid = wordcount("`rndid'")
					
				while `nrndid'<`ous' {
					loc dif=`ous'-`nrndid'
					matrix A = `numid2'*matuniform(1,`dif')
					forvalues i=1/`dif' {
						loc x= A[1,`i']
						loc j=round(`x')
						loc rndid `rndid' `j'
					}
						
					loc rndid : list uniq rndid 
					loc rndid : list rndid-zero 
					loc nrndid = wordcount("`rndid'")
				} 
				************************************************************
				tempvar samplein
				qui gen `samplein'=`sample'
				
				foreach i of loc rndid {
					qui replace `samplein'=0 if `panvar'==``i''
				}
			}
			************************************************************
			else if `k'==`kn' {
				foreach i of loc rndid {
					loc rndidk `rndidk' ``i''
				}
				loc idumn2 : list idumn2-rndidk
				loc numid2 = wordcount("`idumn2'") 

			************************************************************
				tempvar samplein
				qui gen `samplein'=`sample'
				
				foreach i of loc idumn2 {
					qui replace `samplein'=0 if `panvar'==`i'
				}
			}
			**********************************************************
			************************************************************
			tempvar prf i_c

			if "`met'"=="" {
				if "`dum'"=="dum" {
					if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
					else qui xtlogit `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
				}
				else {
					if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
					else qui xtlogit `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
				}
			}
			else if "`dum'"=="dum" {
				if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
				else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
			}
			else {
				if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
				else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
			}
						
			if "`mprob'"=="" qui predict `prf', pr
			else qui predict `prf', `mprob'
					
			if "`dum'"=="dum" {
				loc allxvars : colfullnames e(b)
				loc dumi : list allxvars-rhsvars
				
				qui gen `i_c'=-_b[_cons]
				foreach i of loc dumi {
					qui replace `i_c'=`i_c'+_b[`i']*`i'
				}
				qui sum `i_c' if `samplein'==1
				qui replace `prf'=`prf'+r(mean) if `samplein'==0
			}
	
			capture qui roctab `yvar' `prf' if `samplein'==1 & `sample'==1
			if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==1 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
			matrix R0[`k',1]=r(area)
			if "`auc'"=="" matrix R0[`k',2]=r(se)
			else matrix R0[`k',2]=.
			matrix R0[`k',5]=r(N)
		
			capture qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1
			if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==0 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
			matrix R0[`k',3]=r(area)
			if "`auc'"=="" matrix R0[`k',4]=r(se)
			else matrix R0[`k',4]=.
			matrix R0[`k',6]=r(N)
			}
		*********************************************************************************************************************
		matrix N = R0[1...,6]
		matrix n0=I1*N
		scalar n=n0[1,1]
		matrix R`r' = (1/n)*N'*R0
		
		forvalues s=1/6 {
			matrix RS[`r',`s']=R`r'[1...,`s']
		}
		*********************************************************************************************************************

	}
	matrix ni=I2*RS[1...,5]
	matrix no=I2*RS[1...,6]
	scalar ni=ni[1,1]
	scalar no=no[1,1]
	matrix Ri = (1/ni)*RS[1...,5]'*RS[1...,1..2]
	matrix Ro = (1/no)*RS[1...,6]'*RS[1...,3..4]
	matrix R = Ri , Ro , ni , no 

	matrix colnames R = ROC_in ROC_SE_os ROC_os ROC_SE_os N_in N_os
	matrix rownames R = Summary
	matlist R, title("Out of sample evaluation: Random sampling") lines(rowt)
	return matrix random R
}
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
tokenize `idumn'
loc kn =round(`numid'/`ksmpl')
loc ln = `kn'*`ksmpl'

if `ksmpl'>=1 {
	matrix R0 = J(`kn',6,.)
	matrix I1 = J(1,`kn',1)

	forvalues k=`ksmpl'(`ksmpl')`ln' {	
	
		loc j=`k'-`ksmpl'
		loc ki=`k'/`ksmpl'
 
		tempvar samplein
		qui gen `samplein'=`sample'

		if `k'==`ksmpl' {
			loc j=1
			qui replace `samplein'=0 if `panvar'>=``j'' & `panvar'<=``k''
			}
		else if `k'==`ln' {
			qui replace `samplein'=0 if `panvar'>``j'' & `panvar'<=``numid''
			}
		else {	
			qui replace `samplein'=0 if `panvar'>``j'' & `panvar'<=``k''
			}
		
		************************************************************
		tempvar prf i_c

		if "`met'"=="" {
			if "`dum'"=="dum" {
				if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
				else qui xtlogit `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
			}
			else {
				if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
				else qui xtlogit `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
			}
		}
		else if "`dum'"=="dum" {
			if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
			else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
		}
		else {
			if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
			else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
		}
	
		if "`mprob'"=="" qui predict `prf', pr
		else qui predict `prf', `mprob'
					
		if "`dum'"=="dum" {
			loc allxvars : colfullnames e(b)
			loc dumi : list allxvars-rhsvars
				
			qui gen `i_c'=-_b[_cons]
			foreach i of loc dumi {
				qui replace `i_c'=`i_c'+_b[`i']*`i'
			}
			qui sum `i_c' if `samplein'==1
			qui replace `prf'=`prf'+r(mean) if `samplein'==0
		}
			
		capture qui roctab `yvar' `prf' if `samplein'==1 & `sample'==1
		if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==1 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
		matrix R0[`ki',1]=r(area)
		if "`auc'"=="" matrix R0[`ki',2]=r(se)
		else matrix R0[`ki',2]=.
		matrix R0[`ki',5]=r(N)
				
		capture qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1
		if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==0 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
		matrix R0[`ki',3]=r(area)
		if "`auc'"=="" matrix R0[`ki',4]=r(se)
		else matrix R0[`ki',4]=.
		matrix R0[`ki',6]=r(N)
	}

	*********************************************************************************************************************

	matrix ni=I1*R0[1...,5]
	matrix no=I1*R0[1...,6]
	scalar ni=ni[1,1]
	scalar no=no[1,1]
	matrix Ri = (1/ni)*R0[1...,5]'*R0[1...,1..2]
	matrix Ro = (1/no)*R0[1...,6]'*R0[1...,3..4]
	matrix R = Ri , Ro , ni , no 
	
	matrix colnames R = ROC_in ROC_SE_os ROC_os ROC_SE_os N_in N_os
	matrix rownames R = Summary
	matlist R, title("Out of sample evaluation: Ordered partition") lines(rowt)
	return matrix ordered R

}

*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************

if "`evalopt'"!="" {
	matrix R0 = J(1,6,.)

	tempvar samplein
	qui gen `samplein'=`sample'
	qui replace `samplein'=0 if `evalopt'==1
		
	************************************************************
	tempvar prf res res2 y ym_in ym_ous ydev2_in ydev2_ous y_ar1 i_c

	if "`met'"=="" {
		if "`dum'"=="dum" {
			if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
			else qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
		}
		else {
			if "`if'"!="" qui xtlogit `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
			else qui xtlogit `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
		}
	}
	else if "`dum'"=="dum" {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
		else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
	}
	else {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
		else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
	}
			
	if "`mprob'"=="" qui predict `prf', pr
	else qui predict `prf', `mprob'
					
	if "`dum'"=="dum" {
		loc allxvars : colfullnames e(b)
		loc dumi : list allxvars-rhsvars
				
		qui gen `i_c'=-_b[_cons]
		foreach i of loc dumi {
			qui replace `i_c'=`i_c'+_b[`i']*`i'
		}
		qui sum `i_c' if `samplein'==1
		qui replace `prf'=`prf'+r(mean) if `samplein'==0
	}
			
	capture qui roctab `yvar' `prf' if `samplein'==1 & `sample'==1
	if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==1 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
	matrix R0[1,1]=r(area)
	if "`auc'"=="auc" matrix R0[1,2]=r(se)
	else matrix R0[1,2]=.
	matrix R0[1,5]=r(N)
				
	capture qui roctab `yvar' `prf' if `samplein'==0 & `sample'==1
	if "`auc'"=="auc" qui auc `yvar' `prf' if `samplein'==0 & `sample'==1, ncut(`ncut') wint(`wint') winf(`winf')
	matrix R0[1,3]=r(area)
	if "`auc'"=="auc" matrix R0[1,4]=r(se)
	else matrix R0[1,4]=.
	matrix R0[1,6]=r(N)

	matrix colnames R0 = ROC_in ROC_SE_os ROC_ous ROC_SE_os N_in N_os
	matrix rownames R0 = Summary
	matlist R0, title("Out of sample evaluation: Specific individuals: `evalopt'") lines(rowt)
	return matrix specific R0
}

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
