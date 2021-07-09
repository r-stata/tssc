*! version 2.0 11th July 2008
*! Author : Rajesh Tharyan

capture program drop historaj
program define historaj, rclass
version 9
syntax varlist(numeric)[if] [in]
marksample touse
foreach var of varlist `varlist' { 
capture confirm numeric variable `var'
if _rc==0 {
di " Please enter the following if required or press esc key and then enter to leave blank"
di "-----------------------------------------------------------------------------------------"
di ""
di in yellow "Please enter a title   : " _request(_title)
di in yellow "Please enter a note    : " _request(_note)
di in yellow "Y axis as Density, Frequency,  Fraction or Percentage ? (must type dens, freq, frac or percent)  : " _request(_type)
di ""
di ""

* display the stats of the whole sample in the results window

qui sum `var', detail

local 1sd=`r(mean)' - 3*(`r(sd)')
local 2sd=`r(mean)' - 2*(`r(sd)')
local 3sd=`r(mean)' - 1*(`r(sd)')
local 4sd=`r(mean)' + 1*(`r(sd)')
local 5sd=`r(mean)' + 2*(`r(sd)')
local 6sd=`r(mean)' + 3*(`r(sd)')

di "stats from the whole sample"
di "-------------------------------"
di in green "obs     : " `r(N)'
di in green "mean    : " `r(mean)'
di in green "median  : " `r(p50)'
di in green "stdev   : " `r(sd)'
di in green "skew    : " `r(skewness)'
di in green "kurtos  : " `r(kurtosis)'
di in green "p1      : " `r(p1)'
di in green "p99     : " `r(p99)'
di in green "p5      : " `r(p5)'
di in green "p95     : " `r(p95)'
di in green "p10     : " `r(p10)'
di in green "p90     : " `r(p90)'
di in green "p25     : " `r(p25)'
di in green "p75     : " `r(p75)'
di ""
di in white"-3 s.d. : " `1sd'
di in white"-2 s.d. : " `2sd'
di in white"-1 s.d. : " `3sd'
di in white"+3 s.d. : " `4sd'
di in white"+2 s.d. : " `5sd'
di in white"+3 s.d. : " `6sd'
di "-------------------------------"
di ""
di in red "Note: The stats of the whole sample shown above. The histogram displays the stats from the sample by if or in (if specified)"

* display the stats of the selected sample ( by if or in) in the histogram

qui sum `var' if `touse', detail

local 1sd=`r(mean)' - 3*(`r(sd)')
local 2sd=`r(mean)' - 2*(`r(sd)')
local 3sd=`r(mean)' - 1*(`r(sd)')
local 4sd=`r(mean)' + 1*(`r(sd)')
local 5sd=`r(mean)' + 2*(`r(sd)')
local 6sd=`r(mean)' + 3*(`r(sd)')
di ""
di ""

qui histogram `varlist', `type' normal xaxis(1 2 3) xlabel( `r(mean)' "mean" `1sd' "-3 s.d." `2sd'  "-2 s.d." `3sd'  "-1 s.d." `4sd'  "+1 s.d." `5sd'  "+2 s.d." `6sd'  "+3 s.d." ,  labsize(vsmall) format(%10.4g) labgap(minuscule) axis(2) grid gmax) xlabel (  `r(mean)' `1sd' `2sd' `3sd'  `4sd'  `5sd'  `6sd' ,labsize(vsmall) format(%10.4g) axis(1) labgap(minuscule)) xlabel (minmax,labsize(small) format(%10.4g) axis(3) labgap(minuscule)) xmtick (##10, labels labsize(vsmall) ticks axis(3)) xtitle( "", axis (3)) title (`title', box bexpand) note(`note',size(vsmall)) ylabel(,labsize(vsmall) format(%10.4g)) ytitle(, size(small)) caption( `"no.obs  :`:di %9.0f `r(N)''"' `"median :`:di %9.3f `r(p50)''"'  `"skew    :`:di %9.3f `r(skewness)''"'  `"kurtos  :`:di %9.3f `r(kurtosis)''"'  `"p1        :`:di %9.3f  `r(p1)''"'  `"p99      :`:di %9.3f   `r(p99)''"' `"p5        :`:di %9.3f   `r(p5)''"'  `"p95      :`:di %9.3f   `r(p95)''"'  `"p10      :`:di %9.3f   `r(p10)''"'  `"p90      :`:di %9.3f   `r(p90)''"'  `"p25      :`:di %9.3f   `r(p25)''"'  `"p75      :`:di %9.3f    `r(p75)''"', size(vsmall) position(1) ring(0) orientation(horizontal) lwidth(vthin) linegap(1) justification(left))
}
else {
di as input "`var'" as text " is not a numeric variable histogram cannot be created"
}
}
end
