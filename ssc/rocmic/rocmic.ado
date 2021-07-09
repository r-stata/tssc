*! rocmic.ado v2.0.0 modified in February 2014 by R.Froud and G.Abel
/* from rocmic v1.0.0 by R.Froud (Robert Froud, 2009."ROCMIC: Stata module to estimate minimally important change (MIC) thresholds for continuous clinical outcome measures using ROC curves," Statistical Software Components S457052, Boston College Department of Economics.) in accordance with the Repec copyright statement (http://repec.org/docs/RePEcDataUse.html)

NB Please first do 'ado uninstall rocmic' if you have v1.0.0 of rocmic installed

This program reports minimally important change (MIC) thresholds using three methods 
1) 45 degree tangent line intersection 
2) the smallest residual sum of sensitivity and specificity, and 
3) the sum of squares method described by Froud and Abel

*/

capture program drop rocmic 

version 10.1

program define rocmic, rclass
                syntax varlist(min=2 max=2 numeric), scale(real) [fast] 
                return local varname `varlist'
			local ref: word 1 of `varlist'
			local dv: word 2 of `varlist'
                quietly {
				tempvar se1 sp1 gap thresh emg py original_order
				gen `original_order'=_n
				logistic `ref' `dv'
				lsens, gensens(`se1') genspec(`sp1') nograph
				gen `gap'=abs(`se1'-`sp1')
				gen  `thresh'= `dv' + `scale'
				sort `gap'
                        return scalar mic = `thresh' in 1/1
				gen `emg' = abs((1-`se1')+(1-`sp1')) 
				sort `emg'
			return scalar emgo = `thresh' in 1/1
				gen `py' = abs(((1-`se1')^2)+((1-`sp1')^2)) 
				sort `py'
			return scalar py = `thresh' in 1/1	
				sort `original_order'
                }
			if "`fast'"=="" {
				lroc
			}
			display in smcl as text "--"
		 display in smcl as text "The MIC estimated using a 45 degree tangent line intersection is " as result %05.3f return(mic)
		 display in smcl as text "The MIC estimated using the smallest sum of 1-sensitivity and 1-specificity is " as result %05.3f return(emgo) 
		 display in smcl as text "The MIC estimated using the smallest sum of squares of 1-sensitivity and 1-specificity is " as result %05.3f return(py)
		 display in smcl as text "NB Please use bootstrap if confidence intervals are required for MIC estimates."
	roctab `ref' `dv'
        end







