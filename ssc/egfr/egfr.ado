* collection of algorithms for calculating eGFR from
* creatinine/cystatin C +/- age, sex, height & weight, urea, albumin etc
* phil clayton, phil@anzdata.org.au

*! -egfr- version 2.01	Phil Clayton	2013-09-09

* version history:
* 2.01	Fixed problem whereby default formula not allowed
* 2.0	Support CKD-EPI CyC equations
* 1.3.3	Tweaked options to allow asis strings
* 1.3.2 Added formulae to help file and added Brion reference
* 1.3.1	Added -version- command
* 1.3	Fixed bugs in which subjects with missing data might get an eGFR due to
*		  missing indicator variables being true
*		Simplified calculation of MDRD formulae
*		Missing sex in adolescents (13-21) now leads to missing
*		  non-standardised Schwartz eGFR
*		Unit conversion local macros now use parentheses to simplify formulae
* 1.2.3	Return -summarize- results for new eGFR values in r()
* 1.2.2	Schwartz formula with non-standardised Cr allows age up to 21 (not 20)
*		Slightly tweaked help file
* 1.2.1 Removed an unnecessary macro definition
* 1.2	Better handling of missing sex/race
* 1.1	Fixed minor error in help file
* 1.0b	Initial version

capture program drop egfr
program define egfr, rclass
	version 12
	syntax [if] [in], ///
			[Formula(string)				/// which formula to use (default 4-variable MDRD)
			CReatinine(varname numeric)		/// serum creatinine
			CYstatinc(varname numeric)		/// serum cystatin C
			FEMale(string asis)				/// expression true when subject is female
			age(varname numeric)			/// age in years
			prem(string asis)				/// expression true when child born prematurely
			Height(varname numeric)			/// height in cm
			Weight(varname numeric)			/// weight in kg
			URea(varname numeric)			/// urea
			ALBumin(varname numeric)		/// albumin
			Black(string asis)				/// expression true when subject is black
			US								/// US units for creatinine, urea & albumin
			Standard						/// creatinine is standardised or traceable to IMDS
			Generate(name)					/// new variable (default is -egfr_formulaname-)
			replace]						//  replace existing variable
	
	* default formula is mdrd 4 variable
	if "`formula'"=="" {
		di "Calculating eGFR using 4-variable MDRD formula"
		local formula="mdrd4"
	}

	* check formula is known
	local frm "mdrd4 mdrd6 ckdepi ckdepi_pk ckdepi_cyc ckdepi_cr_cyc mayo cg nankivell schwartz"
	if strpos("`frm'", "`formula'") == 0 {
		di in re "Unrecognised formula: `formula'"
		error 498
	}
	
/*
	if !inlist("`formula'", "mdrd4", "mdrd6", "ckdepi", ///
		"ckdepi_cyc", "ckdepi_cr_cyc", "mayo", "cg", "nankivell", "schwartz") {
		di in re "Unrecognised formula: `formula'"
		error 498
	}
*/

	* fsex is an indicator variable for female sex
	if "`female'"!="" {
		tempvar fsex
		qui gen byte `fsex'=`female'
	}

	* blk is an indicator variable for black race
	* assume non-black race if no black variable specified
	* only required for mdrd & creatinine-based ckdepi formulae
	if ("`formula'"=="mdrd4" | "`formula'"=="mdrd6" | "`formula'"=="ckdepi" | "`formula'"=="ckdepi_pk") {
		tempvar blk
		if "`black'"=="" {
			di "Assuming non-black race for all subjects"
			gen byte `blk'=0
		}
		else qui gen byte `blk'=`black'
	}
	
	* unit conversions
	if "`us'"=="us" {
		local crumoll="(`creatinine'*88.402)"
		local crmgdl="`creatinine'"
		local bunmgdl="`urea'"
		local urmmoll="(`urea'/2.8)"
		local albgdl="`albumin'"
	}
	else {
		local crumoll="`creatinine'"
		local crmgdl="(`creatinine'*0.0113)"
		local bunmgdl="(`urea'*2.8)"
		local urmmoll="`urea'"
		local albgdl="(`albumin'/10)"
	}

	* we'll create a working variable called egfr
	* then transfer it over to the actual new variable once calculations are complete
	tempvar egfr
	local newvar="`generate'"
	if "`newvar'"=="" local newvar="egfr_`formula'"
	if "`replace'"!="replace" confirm new var `newvar'

	* MDRD (4 variable)
	* refs: Levey et al. J Am Soc Nephrol. 2000;11(11):155A
	*       Levey et al. Ann Intern Med. 2006 Aug 15;145(4):247Ð54
	if "`formula'"=="mdrd4" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "4-variable MDRD formula requires creatinine, age and female options"
			error 498
		}

		if "`standard'"=="standard" {
			qui gen `egfr'=175*(`crmgdl'^-1.154)*(`age'^-0.203) * ///
				cond(`blk', 1.212, 1, .) * cond(`fsex', 0.742, 1, .)
		}
		else {
			di "Assuming creatinines are not standardised. If they are, specify -standard- option"
			qui gen `egfr'=186*(`crmgdl'^-1.154)*(`age'^-0.203) * ///
				cond(`blk', 1.212, 1, .) * cond(`fsex', 0.742, 1, .)
		}
		
		local newvarlab="eGFR (4-variable MDRD formula)"
	}

	* MDRD (6 variable)
	* refs: Levey et al. Ann Intern Med. 1999 Mar. 16;130(6):461-470
	*       Levey et al. Ann Intern Med. 2006 Aug 15;145(4):247Ð54
	if "`formula'"=="mdrd6" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" | "`urea'"=="" | "`albumin'"=="" {
			di in re "6-variable MDRD formula requires creatinine, age, female, urea and albumin options"
			error 498
		}
		
		if "`standard'"=="standard" {
			qui gen `egfr'=161.5*(`crmgdl'^-0.999)*(`age'^-0.176) * ///
			`bunmgdl'^-.170 * `albgdl'^0.318 * ///
			cond(`blk', 1.180, 1, .) * cond(`fsex', 0.762, 1, .)
		}
		else {
			di "Assuming creatinines are not standardised. If they are, specify -standard- option"
			qui gen `egfr'=170*(`crmgdl'^-0.999)*(`age'^-0.176) * ///
			`bunmgdl'^-.170 * `albgdl'^0.318 * ///
			cond(`blk', 1.180, 1, .) * cond(`fsex', 0.762, 1, .)
		}
				
		local newvarlab="eGFR (6-variable MDRD formula)"
	}

	* CKD-EPI creatinine formula
	* ref: Levey et al, Ann Intern Med. 2009 May 5;150(9):604-612
	if "`formula'"=="ckdepi" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "CKD-EPI creatinine formula requires creatinine, age and female options"
			error 498
		}
		
		if "`standard'"=="" {
			di "Assuming creatinines are standardised. If not, CKD-EPI formula is not valid."
		}

		qui gen     `egfr' = (144 + 22*`blk')*(`crmgdl'/0.7)^(-0.329)*0.993^`age' if `fsex'==1 & `crumoll'<=62
		qui replace `egfr' = (144 + 22*`blk')*(`crmgdl'/0.7)^(-1.209)*0.993^`age' if `fsex'==1 & `crumoll'>62
		qui replace `egfr' = (141 + 22*`blk')*(`crmgdl'/0.9)^(-0.411)*0.993^`age' if `fsex'==0 & `crumoll'<=80
		qui replace `egfr' = (141 + 22*`blk')*(`crmgdl'/0.9)^(-1.209)*0.993^`age' if `fsex'==0 & `crumoll'>80
		
		local newvarlab="eGFR (CKD-EPI creatinine formula)"
	}

	* CKD-EPI (Pak) creatinine formula
	* ref: Jessani et al, Am J Kidney Dis. 2014 January ; 63(1): 49–58.
	if "`formula'"=="ckdepi_pk" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "CKD-EPI (Pak) creatinine formula requires creatinine, age and female options"
			error 498
		}
		
		if "`standard'"=="" {
			di "Assuming creatinines are standardised. If not, CKD-EPI (Pak) formula is not valid."
		}

		qui gen     `egfr' = 0.686*(((144 + 22*`blk')*(`crmgdl'/0.7)^(-0.329)*0.993^`age')^1.059) if `fsex'==1 & `crumoll'<=62
		qui replace `egfr' = 0.686*(((144 + 22*`blk')*(`crmgdl'/0.7)^(-1.209)*0.993^`age')^1.059) if `fsex'==1 & `crumoll'>62
		qui replace `egfr' = 0.686*(((141 + 22*`blk')*(`crmgdl'/0.9)^(-0.411)*0.993^`age')^1.059) if `fsex'==0 & `crumoll'<=80
		qui replace `egfr' = 0.686*(((141 + 22*`blk')*(`crmgdl'/0.9)^(-1.209)*0.993^`age')^1.059) if `fsex'==0 & `crumoll'>80
		*qui replace `egfr' = 0.686*((`egfr')^1.059) 
		
		local newvarlab="eGFR (CKD-EPI (Pak) creatinine formula)"
	}	
	* CKD-EPI cystatin C formula
	* ref: Inker et al, N Engl J Med. 2012 Jul 5;367(1):20Ð9
	if "`formula'"=="ckdepi_cyc" {
		if "`cystatinc'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "CKD-EPI cystatin C formula requires cystatinc, age and female options"
			error 498
		}
		
		qui gen `egfr' = 133 * min(`cystatinc'/0.8, 1)^(-0.499) * ///
			max(`cystatinc'/0.8, 1)^(-1.328) * ///
			0.996^`age' * cond(`fsex', 0.932, 1, .)
		
		local newvarlab="eGFR (CKD-EPI cystatin C formula)"
	}

	* CKD-EPI creatinine plus cystatin C formula
	* ref: Inker et al, N Engl J Med. 2012 Jul 5;367(1):20Ð9
	if "`formula'"=="ckdepi_cr_cyc" {
		if "`creatinine'"=="" | "`cystatinc'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "CKD-EPI creatinine-cystatin C formula requires creatinine, cystatinc, age and female options"
			error 498
		}
		
		qui gen `egfr' = 135 * ///
			min(`crmgdl'/cond(`fsex', 0.7, 0.9, .), 1)^cond(`fsex', -0.248, -0.207, .) * ///
			max(`crmgdl'/cond(`fsex', 0.7, 0.9, .), 1)^(-0.601) * ///
			min(`cystatinc'/0.8, 1)^(-0.375) * ///
			max(`cystatinc'/0.8, 1)^(-0.711) * ///
			0.995^`age' * ///
			cond(`fsex', 0.969, 1, .) * cond(`blk', 1.08, 1, .)
		
		local newvarlab="eGFR (CKD-EPI creatinine-cystatin C formula)"
	}

	* Mayo quadratic formula
	* ref: Rule et al. Ann Intern Med. 2004 Dec. 21;141(12):929-937
	if "`formula'"=="mayo" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" {
			di in re "Mayo quadratic formula requires creatinine, age and female options"
			error 498
		}

		qui gen `egfr'=exp(1.911 + 5.249/`crmgdl' - 2.114/`crmgdl'^2 ///
			- 0.00686*`age' - 0.205*`fsex') if `crmgdl'>=0.8
		qui replace `egfr'=exp(1.911 + 5.249/0.8 - 2.114/0.8^2 ///
			- 0.00686*`age' - 0.205*`fsex') if `crmgdl'<0.8

		local newvarlab="eGFR (Mayo quadratic formula)"
	}
	
	* Cockroft-Gault
	* ref: Cockcroft DW, Gault MH. Nephron. 1976;16(1):31-41
	if "`formula'"=="cg" {
		if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" | "`weight'"=="" {
			di in re "Cockroft-Gault formula requires creatinine, age, female and weight options"
			error 498
		}
		
		qui gen `egfr'= ///
			(140-`age') * `weight' * cond(`fsex', 1.04, 1.23, .) / `crumoll'
		
		local newvarlab="eGFR (Cockroft-Gault formula)"
	}
	
	* Nankivell
	* ref: Nankivell et al. Transplantation. 1995 Jun. 27;59(12):1683-1689
	if "`formula'"=="nankivell" {
		if "`creatinine'"=="" | "`female'"=="" | "`weight'"=="" | "`height'"=="" | "`urea'"=="" {
			di in re "Nankivell formula requires creatinine, female, urea, height and weight options"
			error 498
		}
		
		qui gen `egfr'=6.7/(`crumoll'/1000) + 0.25*`weight' - 0.5*`urmmoll' - ///
			100/(`height'/100)^2 + cond(`fsex', 25, 35, .)
		
		local newvarlab="eGFR (Nankivell formula)"
	}

	* Schwartz
	* refs: Schwartz et al. Pediatrics. 1976 Aug.;58(2):259-263
	*       Schwartz et al. J Pediatr. 1984 Jun.;104(6):849-854 
	*       Schwartz et al. Journal of the American Society of Nephrology. 2009 Mar.;20(3):629-637
	if "`formula'"=="schwartz" {
		tempvar k
		if "`standard'"=="standard" {
			if "`creatinine'"=="" | "`height'"=="" {
				di in re "Schwartz formula with standardised creatinines requires creatinine and height options"
				error 498
			}
			qui gen `k'=0.413
		}
		else {
			if "`creatinine'"=="" | "`age'"=="" | "`female'"=="" | "`height'"=="" | "`prem'"=="" {
				di in re "Schwartz formula without standardised creatinines requires creatinine, age, prem, female and height options"
				error 498
			}
			tempvar isprem
			qui gen byte `isprem'=`prem'
			qui gen `k'=0.33 if `age'<1 & `isprem'==1
			qui replace `k'=0.45 if `age'<1 & `isprem'==0
			qui replace `k'=0.55 if `age'>=1 & `age'<13
			qui replace `k'=0.55 if `age'>=13 & `age'<=21 & `fsex'==1
			qui replace `k'=0.70 if `age'>=13 & `age'<=21 & `fsex'==0
		}
		
		qui gen `egfr'=`k'*`height'/`crmgdl'

		local newvarlab="eGFR (Schwartz formula)"
	}
	
	* report statistics about new variable
	summarize `gfr' `if' `in', meanonly
	di
	di "eGFR calculated for `=r(N)' observations. Values range from " %1.0f r(min) " to " %1.0f r(max) " mL/min."
	return add
	
	* create and label new variable
	capture confirm variable `newvar'
	if !_rc & "`replace'"=="replace" {
			replace `newvar'=`egfr' `if' `in'
	}
	else gen `newvar'=`egfr' `if' `in'
	
	label variable `newvar' "`newvarlab'"
end
