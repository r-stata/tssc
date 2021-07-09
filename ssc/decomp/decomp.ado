program define decomp
* program to conduct a Blinder-Oaxaca decomposition of earnings.
* Requires regression for subgroup of high wage persons to be
* run first, followed by himod [,ds heck]. Then the regression for the
* low wage persons, followed by lomod [,ds heck]. Then decomp is run.
*! ver 1.7 8nov2010 - fixed bug regards estimation sample (was using means
*! from full sample, now use wage equation sample means). 
*! Thanks to Anne Busch for drawing my attention to this.
* ver 1.6 25jan05 - added Tobit correction & removed Heck option (now built-in)
* ver 1.5 30sept04 - added Heckman option
* ver 1.4 26nov02 - added weighting
* ver 1.3 25july02 - fixed typo in himod and lomod
* ver 1.2  4feb02 - changed output presentation
* ver 1.1 14apr00 - original program developed


version 8.2 
syntax [,r]
local varnms : rownames(locoef)

local k=rowsof(locoef)
local hiconstant=hicoef[`k',1]
local loconstant=locoef[`k',1]
local constantdiff=`hiconstant'-`loconstant'
 
mat endowdiff=himean-lomean
mat coefdiff=hicoef-locoef

mat endow=J(`k',1,1)
mat coeff=J(`k',1,1)

local totalendow=0
local totalcoeff=0


if "`r'" ~="" {
   foreach c of numlist 1/`k'{
      if `c'<`k'{
        mat endow[`c',1]= endowdiff[`c',1]*locoef[`c',1]
        local totalendow=`totalendow'+endow[`c',1]
        mat coeff[`c',1]= coefdiff[`c',1]*himean[`c',1]
        local totalcoeff=`totalcoeff'+coeff[`c',1]
      }
   }
}
   else {
   foreach c of numlist 1/`k'{
      if `c'<`k'{
         mat endow[`c',1]= endowdiff[`c',1]*hicoef[`c',1]
         local totalendow=`totalendow'+endow[`c',1]
         mat coeff[`c',1]= coefdiff[`c',1]*lomean[`c',1]
         local totalcoeff=`totalcoeff'+coeff[`c',1]
      }
   }
}

if "`r'" ~="" {
di
di
di as text "DECOMPOSITION IS USING THE REVERSE METHOD"

}

mat attrib= endow+coeff
mat results=attrib,endow,coeff
mat colnames results=Attrib Endow Coeff


di
di as text "{title:Decomposition results for variables (as %s)}"
di
di as text "{hline 13}{c TT}{hline 40}"
di as text "{ralign 12: Variable} {c |} {ralign 13: Attrib}" /*
     */ "{ralign 12: Endow} {ralign 13: Coeff}"
di as text "{hline 13}{c +}{hline 40}"
local j=`k'-1
foreach r of numlist 1/`j'{
    local varnm: word `r' of `varnms'
    local varnm=abbrev("`varnm'",15)
    di as text "{ralign 12:`varnm'} {c |} {col 20}" /*
       */ as result %9.1f results[`r',1] *100 "{col 32}" /*
       */ as result %9.1f results[`r',2] *100 "{col 46}" /*
       */ as result %9.1f results[`r',3] * 100 
}
di as text "{hline 13}{c +}{hline 40}"
di as text "{ralign 12:Subtotal} {c |} {col 20}" /*
       */ as result %9.1f (`totalendow'+`totalcoeff')*100 "{col 32}" /*
       */ as result %9.1f `totalendow'*100 "{col 46}" /*
       */ as result %9.1f `totalcoeff'*100 

di as text "{hline 13}{c BT}{hline 40}"

di
di
di
di as text "{title:Summary of decomposition results (as %)}"
di 
di as text "{hline 33}{c TT}{hline 9}"
di as text "{lalign 32:Amount attributable:} {c |}" /*
     */ as result %9.1f (`totalendow'+`totalcoeff')*100
di as text "{lalign 32:- due to endowments (E):} {c |}" /*
     */ as result %9.1f `totalendow'*100
di as text "{lalign 32:- due to coefficients (C):} {c |}" /*
     */ as result %9.1f `totalcoeff'*100
di as text "{lalign 32:Shift coefficient (U):} {c |}" /*
     */ as result %9.1f `constantdiff'*100
di as text "{lalign 32:Raw differential (R) {E+C+U}:} {c |}" /*
     */ as result %9.1f (`totalendow'+`totalcoeff'+`constantdiff')*100
di as text "{lalign 32:Adjusted differential (D) {C+U}:} {c |}" /*
     */ as result %9.1f (`totalcoeff'+`constantdiff')*100
di as text "{hline 33}{c +}{hline 9}"
di as text "{lalign 32:Endowments as % total (E/R):} {c |}" /*
     */ as result %9.1f (`totalendow'/(`totalendow'+`totalcoeff'+`constantdiff'))*100
di as text "{lalign 32:Discrimination as % total (D/R):} {c |}" /*
     */ as result %9.1f ((`totalcoeff'+`constantdiff')/(`totalendow'+`totalcoeff'+`constantdiff'))*100
di as text "{hline 33}{c BT}{hline 9}"

di
di as text "  U = unexplained portion of differential"
di as text "      (difference between model constants)"
di as text "  D = portion due to discrimination (C+U)"

di
di as text "  positive number indicates advantage to high group"
di as text "  negative number indicates advantage to low group"


end
