*! skprobit version 1.0.0
*! Performs Lagrange Multiplier Test for Normality after Probit
*! Diallo Ibrahima Amadou
*! All comments are welcome, 2010




capture program drop skprobit
program skprobit, rclass
        version 11
        if "`e(cmd)'" != "probit" {
		                   error 301
	}
        syntax varlist [if] [in]
        marksample touse
        tokenize `varlist'
        local yvar "`1'"
        mac shift
        local xvars "`*'"
        tempname b
        tempvar xb
        matrix define `b' = e(b)
        matrix score `xb' = `b' if `touse'
        return clear
        mata: _mz_prlm("`yvar'", "`touse'", "`xb'")
        tempname lmtt lmtpp rSS
        scalar `lmtt'=r(lmt)
        scalar `lmtpp'=r(lmtp)
        scalar `rSS'=r(N)
        return clear
        display
        display in gr "Lagrange Multiplier Test for Normality after Probit"
        display
        display _skip(4) in gr "Chi2(" as res 2 as txt ")" _skip(1) as txt "=" as res %10.4f `lmtt'
        display in gr "Prob > chi2" _skip(1) "="  as res %10.4f `lmtpp'
        display
        display in gr "Ho: Normality"
        display in gr "Ha: No Normality"
        return scalar chi2 = `lmtt'
        return scalar chi2_p = `lmtpp'
        return scalar N = `rSS'
end




mata:
void _mz_prlm(string scalar yvar, string scalar touse, string scalar xb)
{
     string scalar lvy, lvb
     real colvector y, txb, phixb, psixb, ei, ei2, ei3, ei4, ei21, ei43, i
     real matrix S, LM
     real scalar rS, lmt, lmtp


     lvy = tokens(yvar); lvb = tokens(xb)
     st_view(y,., lvy, touse); st_view(txb,., lvb, touse)
     phixb = normalden(txb)
     psixb = normal(txb)
     ei    = y:*(phixb:/psixb):+(1:-y):*(-phixb:/(1:-psixb))
     ei2   = y:*(1:-(txb):*(phixb:/psixb)):+(1:-y):*(1:+(txb):*(phixb:/(1:-psixb)))
     ei3   = (1 :- y):*((-phixb:/(1 :- psixb)):*(2 :+ (txb):^2)) :+ y:*((phixb:/psixb):*(2 :+ (txb):^2))
     ei4   = (1 :- y):*(3:*(1 :+ (txb):*(phixb:/(1 :- psixb))) :- (-txb):^3:*(phixb:/(1 :- psixb))):+ y:*(3:*(1 :- (txb):*(phixb:/psixb)) :+ (-txb):^3:*(phixb:/psixb))
     ei21  = ei2 :- 1
     ei43  = ei4 :- 3
     S = (ei, ei21, ei3, ei43)
     rS = rows(S)
     i  = J(rS,1,1)
     LM = i'*S*invsym(S'*S)*S'*i
     lmt = LM[1,1]
     lmtp = chi2tail(2,lmt)
     st_numscalar("r(lmt)", lmt)
     st_numscalar("r(lmtp)", lmtp)
     st_numscalar("r(N)", rS)
}

end
