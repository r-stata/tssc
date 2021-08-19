********************************************************************************************************************************
** XT-Version: STACKED REGRESSION ANALYSIS for MULTIPLE TESTING ****************************************************************
********************************************************************************************************************************
*! version 1.1 2020-01-27
*! version 1.0 2019-10-19
cap program drop xtstackreg
program xtstackreg, eclass
** CHECK VERSION (For Handling Unicode Variables) **
if `c(stata_version)' < 14 {
    local strlen "strlen"
}
else {
    local strlen "ustrlen"
}
if !replay() {
		quietly {	
    		** STORE COMMANDLINE ENTRY **
    		local cmd "xtstackreg"
    		local cmdline "`cmd' `*'"
    		syntax anything(equalok) [if/] [in] [pweight fweight aweight iweight/], [CLUster(passthru)] [DEPName(passthru)] [noCONStant] [noCOMmon] [FE] [DF(passthru)] [Wald] [SReshape] [FAVORSpace(integer 0)] [Constraints(passthru)] [EDITtozero(passthru)]/*
    		*/ [LEVel(real `c(level)')] [noci] [noPValues] [OMITted] [EMPTYcells] [VSQUISH] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(passthru)] [fvwrapon(passthru)] [CFORMAT(passthru)] [PFORMAT(passthru)] [SFORMAT(passthru)] [nolstretch]             
            stackreg `anything' `if' `in', fe `cluster' `depname' `constant' `common' `df' `wald' `sreshape' `constraints' `edittozero' level(`level') `ci' `pvalues' `omitted' `emptycells' `vsquish' `baselevels' `allbaselevels' `fvlabel' `fvwrap' `fvwrapon' `cformat' `pformat' `sformat' `nolstretch'
            ** MACROS **
            ereturn local cmd `cmd'
            ereturn local cmdline `cmdline'
        }
    }
	** DISPLAY RESULTS **
    if "`e(estimator)'" != "cnsreg" {
        local name "Stacked"
        local name2 "regression"
    }
    else {
        local name "Constrained stacked"
        if "`e(model)'" != "fe" {
            local name2 "regression"
        }
        else {
            local name2 "reg."
        }
    }
    local skip2 = 52
	local skip3 = floor(`e(N)')
	local skip3 = `strlen'("`skip3'")-1
    if "`e(model)'" == "fe" {
        di _newline as text "`name' within-transformed linear `name2'"     _column(`skip2')  "Number of obs    = " _column(`skip3') as result as result %8.0fc `e(N)'  
        di          as text                                                _column(`skip2')  "Number of groups = " _column(`skip3') as result as result %8.0fc `e(N_g)' _newline
    }
    else {
	   di _newline as text "`name' linear `name2'" _column(`skip2')  "Number of obs    = " _column(`skip3') as result as result %8.0fc `e(N)' _newline 
    }
    ** di _skip as text "(Std. Err. adjusted for " as result `e(N_clust)' as text " clusters in `e(clustvar)')"
    if replay() {
        syntax, [LEVel(real `e(level)')] [noci] [noPValues] [OMITted] [EMPTYcells] [VSQUISH] [BASElevels] [ALLBASElevels] [noFVLABel] [fvwrap(passthru)] [fvwrapon(passthru)] [CFORMAT(passthru)] [PFORMAT(passthru)] [SFORMAT(passthru)] [nolstretch]   
    }
    ** HANDLE OPTIONS EMPTYCELLS & OMITTED for DISPLAY **
    if "`emptycells'" == "" {
        local emptycells "noemptycells"
    }
    if "`omitted'" == "" {
        local omitted "noomitted"
    }        
    ereturn display, level(`level') `ci' `pvalues' `omitted' `vsquish' `emptycells' `baselevels' `allbaselevels' `fvlabel' `fvwrap' `fvwrapon' `fvdisp' `cformat' `pformat' `sformat' `lstretch'         
end
