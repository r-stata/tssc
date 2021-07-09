********************************************************************************
*! "cub", v.16, GCerulli, 10apr2020
********************************************************************************
program cub , eclass sortpreserve
	version 14.1
	if replay()  {
		if ("`e(cmd)'" != "cub") {
		error 301
		}
		syntax [, Level(cilevel) ]
	    ml display, level(`level') eform
 	}
	else {
	qui{
        syntax varlist(max=1) [if] [in] [fweight pweight]  [, m(numlist max=1) vce(passthru) Level(cilevel) Eform pi(varlist numeric) xi(varlist numeric) shelter(numlist max=1) * ]  
		// * adds other options    without returning an error
		mlopts mlopts , `options'  // Since the optins included in * are available in the macro `options', this line tells Stata to add into mplots also the options in *
        ************************************************************************	    
		if "`weight'"!=""{
		local wgt "[`weight'`exp']"
		}
        ************************************************************************		
		marksample touse
		************************************************************************
		* Model with sheleter (cub14s) or without shelter (cub14)
		************************************************************************
		if "`shelter'"!=""{
		ereturn local SHELTER=`shelter'
		ml model d0 cub14s (pi_beta: `varlist' = `pi') (xi_gamma: `xi') (lambda:) `wgt' if `touse', `vce' `mlopts' 
		}
		else if "`shelter'"==""{
		ml model d0 cub14 (pi_beta: `varlist' = `pi') (xi_gamma: `xi') `wgt' if `touse', `vce' `mlopts'
		}
		************************************************************************
		if "`m'"!=""{
		ereturn scalar M=`m'
		}
		else if "`m'"==""{
		tempvar y2
		qui tostring `varlist' , gen(`y2')
		qui levelsof `y2',  local(mylevs)
		qui local m : word count `mylevs'
		ereturn scalar M=`m'
		}
		************************************************************************
		ml maximize
	    ereturn local cmdline `"`0'"'
		ereturn local cmd "cub"
		************************************************************************
		}
	    }
	    ml display, level(`level') showeqns  `eform'
		di as text "The number of categories of variable `varlist' is M = " `m'
		di "{hline 78}"
		************************************************************************
        * Estimates of 'pi' and 'xi', and 'delta'
		************************************************************************
		if "`shelter'"!=""{
		di as text ""
		di as text "{hline}"
		di as text "{bf:******************************************************************************}"
		di as text "{bf:************************ Estimate of 'delta' *********************************}"
		di as text "{bf:******************************************************************************}"
		tempname C
		nlcom delta: 1/(1+exp(-_b[lambda:_cons]))
		mat `C'=r(b)
		ereturn matrix delta=`C'
		}
		************************************************************************
		if ("`pi'" == "") & ("`xi'" == ""){
		************************************************************************
		if "`m'"!=""{
		ereturn scalar M=`m'
		}
		else if "`m'"==""{
		tempvar y2
		qui tostring `varlist' , gen(`y2')
		qui levelsof `y2',  local(mylevs)
		qui local m : word count `mylevs'
		ereturn scalar M=`m'
		}
		************************************************************************
		di as text ""
		di as text "{hline}"
		di as text "{bf:******************************************************************************}"
		di as text "{bf:*************** Estimates of 'pi' and 'xi' *********************************}"
		di as text "{bf:******************************************************************************}"
		tempname A B C
		nlcom (pi: 1/(1+exp(-_b[pi_beta:_cons])))
		mat `A'=r(b)
		ereturn matrix pi=`A'
		nlcom (xi: 1/(1+exp(-_b[xi_gamma:_cons])))
		mat `B'=r(b)
		ereturn matrix xi=`B'
		di as text "{bf:******************************************************************************}"
		************************************************************************
		}
end
********************************************************************************
