*! v.1.0 -- prediction commands for confa suite; 16 Oct 2008
program define confa_p
 version 10

* set trace on

* di as inp "`0'"

 syntax anything [if] [in], [EBayes EMPiricalbayes REGression MLE BARTlett SCores]

* fork to equation scores or factor scores

 if "`scores'"!="" EqScores `0'
 else if "`ebayes'`empiricalbayes'`regression'`mle'`bartlett'" != "" FScores `0'
 else {
    di as err "cannot figure those options out"
    exit 198
 }

end

program define EqScores

 * implicitly used by _robust and svy
 * typical request: predict stub*, scores
 * stub* is not parsed well by newvarlist, have to use anything
 syntax anything [if] [in], scores
 marksample touse, novarlist
 ml score `anything' if `touse'
end

program define FScores

 * user requested factor predictions

 syntax newvarlist [if] [in], [EBayes EMPiricalbayes REGression MLE BARTlett]

 marksample touse, novarlist

 if "`ebayes'`empiricalbayes'`regression'`mle'`bartlett'" == "" | ///
    ( ("`ebayes'`empiricalbayes'`regression'"~="" ) & ("`mle'`bartlett'"~="" ) ) {

     di as err "One and only one factor scoring option must be specified"
     exit 198
 }
 else {

    local nfactors = rowsof( e(Phi) )

    if "`: word count `varlist''" ~= "`nfactors'" {
       di as err "Must specify as many new variables as there were factors in confa model"
       exit 198
    }

    * generate new variables
    forvalues k=1/`nfactors' {
      tempname f`k'
      qui gen double `f`k'' = .
      local flist `flist' `f`k''
    }

    if "`ebayes'`empiricalbayes'`regression`" ~= "" {
       * Empirical Bayes:
       mata : CONFA_P_EB("`flist'", "`e(observed)'", "`touse'")
    }

    if "`mle'`bartlett'" ~= "" {
       * MLE/Bartlett scoring:
       mata : CONFA_P_MLE("`flist'", "`e(observed)'", "`touse'")
    }

    nobreak {
      forvalues k=1/`nfactors' {
        local type : word `k' of `typlist'
        local name : word `k' of `varlist'
        qui gen `type' `name' = `f`k'' if `touse'
        label var `name' `"`e(factor`k')', `ebayes'`empiricalbayes'`regression'`mle'`bartlett' method"'
      }
    }

 }


end

exit

History:
v.1.0 -- June 12, 2008: Empirical Bayes and MLE scoring
