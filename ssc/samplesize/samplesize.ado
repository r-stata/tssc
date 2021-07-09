*! Date        : 21 January 2008
*! Version     : 1.12
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*!
*! Loop samplesize calculations and produce graphs.
*! Only sampsi, sampsi_mcc, sampsi_rho and sampsi_reg are supported at the moment

/*
  2/6/06 v1.07 - added depv labels in the plot  by the mlabel option 
11/10/06 v1.08 - added sampsi_rho to this command
25/10/06 v1.09 - Fix bug about whether SD is specified in sampsi i.e. two means or two proportions
25/10/06 v1.1  - Fix the bug again about whether SD is specified in sampsi i.e. two means or two proportions
4 /12/07 v1.11 - Add a norestore option to 
21/ 1/08 v1.12 - Fix a bug about transferring errors from the individual samplesize calculations
*/

prog def samplesize
version 9.0
syntax [,NORESTORE NULL(numlist) ALT(numlist) N1(numlist) N2(numlist) SD1(numlist) SD2(numlist) RHO(numlist) Alpha(numlist) Power(numlist) ////
Solve(string) Ratio(numlist) XVAR(string) ONESAMple ONESIDED MEthod(string) NOCONTinuity PRE(numlist) POST(numlist) ////
R0(numlist) R1(numlist) R01(numlist) COMmand(string) YXCORR(numlist) SY(numlist) SX(numlist) VARmethod(string) NOI ////
M(numlist) P0(numlist) PHI(numlist) NY(numlist) NX(numlist) NC(numlist) NOISE MLABEL *]

local goptions "`options'"

if "`norestore'"=="" preserve
/* Pick a default samplesize calcuation */
if "`solve'"=="" local solve "n"
if "`command'"=="" local command "sampsi"
if "`varmethod'"=="" local varmethod "res"

if "`command'"=="sampsi" & "`sd1'"=="" & "`sd2'"==""  local nosd 1

/* Quick check on whether the command exists */
cap which `command'
if _rc~=0 {
  di as error "Command `command' not found"
  di as text "Try and find the command from the Web (click below)"
  di as smcl "{stata findit `command'}"
  exit
}

if "`method'"~="" local ssoptions "method(`method')"
local ssoptions "`ssoptions' `nocontinuity' `onesided'"

/* stop Excess looping later... */
if "`solve'"=="n" {
  local n1 10
  local n2 10
}
if "`solve'"=="power" local power 0.9


/* Need to set initial values just in case and print them to the screen */

di as text in smcl "{hline}"
di in smcl "{bf:The Default values used are below} (not all these parameters are used in every samplesize command) "
di as text in smcl "{hline}"
local col 57
if "`power'"=="" {
  di in smcl as text "Power {col `col'}{c |}" as res " 90%"
  local power 0.9
}
if "`alpha'"=="" {
  di in smcl as text "Significance Level {col `col'}{c |}" as res "  5%"
  local alpha 0.05
}
if "`null'"=="" {
  di as text "The null value{col `col'}{c |}" as res "  1"
  local null 1
}
if "`alt'"=="" {
  local alt "1 1.2 1.4 1.6 1.8 2"
  di as text "The alternative values {col `col'}{c |}" as res "  `alt'"
}
if "`n1'"=="" {
  local n1 10
  di as text "Size of sample 1 (n1) {col `col'}{c |}" as res " 10"
}
if "`n2'"=="" {
  local n2 `n1'
  di as text "Size of sample 2 (n2) {col `col'}{c |}" as res " `n2'" 
}
if "`sd1'"=="" {
  local sd1 1
  di as text "Standard deviation of sample 1 (sd1) {col `col'}{c |}" as res "  `sd1'"
}
if "`sd2'"=="" {
  local sd2 `sd1'
  di as text "Standard deviation of sample 2 (sd2) {col `col'}{c |}" as res "  `sd2'"
}
if "`ratio'"=="" {
  di as text "Allocation ratio {col `col'}{c |}" as res "  1"
  local ratio 1
}
if "`rho'"=="" {
  di as text "Correlation " as error "(disabled)" as text" (rho) {col `col'}{c |}" as res "  0"
  local rho 0
} 
if "`pre'"=="" {
  di as text "# of baseline measurements (pre) {col `col'}{c |}" as res "  0"
  local pre 0
}
if "`post'"=="" {
  local post 1
  di as text "# of follow-up measurements (post) {col `col'}{c |}" as res "  1"
}
if "`r0'"=="" {
  di as text "Correlation between baseline measurements (r0) {col `col'}{c |}" as res "  0"
  local r0 0
}
if "`r1'"=="" {
  di as text "Correlation between follow-up measurements (r1) {col `col'}{c |}" as res "  0"
  local r1 0
}
if "`r01'"=="" {
  di as text "Corr. between baseline and follow-up measurements (r01) {col `col'}{c |}" as res "  0"
  local r01 0
}
if "`yxcorr'"=="" {
  di as text "Correlation between Y's and X's (yxcorr) {col `col'}{c |}" as res "  0.5"
  local yxcorr 0.5
}
if "`sx'"=="" {
  di as text "Standard deviation of the X's (sx) {col `col'}{c |}" as res "  1"
  local sx 1
}
if "`sy'"=="" {
  di as text "Standard deviation of the Y's (sy) {col `col'}{c |}" as res "  1"
  local sy 1
}
if "`m'"=="" {
  di as text "Number of matched controls per case (m) {col `col'}{c |}" as res "  1"
  local m 1
}
if "`phi'"=="" {
  di as text "Correlation of exposure between pairs of subjects (phi) {col `col'}{c |}" as res "  0.2"
  local phi 0.2
}
if "`p0'"=="" {
  di as text "Probability of exposure in the controls (p0) {col `col'}{c |}" as res "  0.05"
  local p0 0.5
}
if "`ny'"=="" {
  di as text "ny" as error "(disabled)" as text "{col `col'}{c |}"  as res "  1"
  local ny 1
}
if "`nx'"=="" {
  di as text "nx"  as error "(disabled)" as text "{col `col'}{c |}" as res "  2"
  local nx 2
}
if "`nc'"=="" {
  di as text "nc"  as error "(disabled)" as text "{col `col'}{c |}" as res "  0"
  local nc 0
}
di as text "{hline}"

qui drop _all

/* Calculate the number of calculations and what are the by-variables */

local ssoptlist "power alpha null alt sd1 sd2 rho n1  n2  ratio pre post r0 r1 r01 yxcorr sx sy m p0 phi ny nx nc"
local ssoptabv  "p     a     h0   ha  s1  s2  r   ss1 ss2 rat   pre post r0 r1 r01 yxcorr sx sy m p0 phi ny nx nc"

local xvar ""
local npts 1
local maxchoices 1
local maxvar "power"

/* 
  Go through the variables and calculate how many levels and generate dataset 
  Check if the individual lists have more than one value.
  put this in local numb`var' and check it is more than maxchoices

*/

local no:list sizeof ssoptlist
forv i=1/`no' {
  local var:word `i' of `ssoptlist'
  local abv:word `i' of `ssoptabv'
  qui gen `var'=.
  local numb`var':list sizeof `var'
 
  if `numb`var''>`maxchoices' {
    local maxchoices "`numb`var''"
    local maxvar "`var'"
  }
  local npts = `npts'*`numb`var''
  if `numb`var''>1 local graphby "`graphby' `var'"
}

if "`xvar'"=="" local xvar "`maxvar'"

/*di `" local ngraphs = `npts'/`numb`xvar''  `xvar' "'*/
local ngraphs = `npts'/`numb`xvar''
local graphby:list graphby - xvar


if `ngraphs' > 12 {
  di as error "WARNING: You  are about to plot more than 12 plots on one graph"
  di as error "Try reducing the number of possible values"
}
if "`graphby'"~="" {
  local graphby:list uniq graphby
  local gopt "by(`graphby')"
}

local line 1
foreach h0 of numlist `null' {
foreach p of numlist `power' {
foreach a of numlist `alpha' {
foreach ha of numlist `alt' {
foreach s1 of numlist `sd1' {
foreach s2 of numlist `sd2' {
foreach r of numlist `rho' {
foreach ss1 of numlist `n1' {
foreach ss2 of numlist `n2' {
foreach rat of numlist `ratio' {
foreach ppre of numlist `pre' {
foreach ppost of numlist `post' {
foreach rr0 of numlist `r0' {
foreach rr1 of numlist `r1' {
foreach rr01 of numlist `r01' {
foreach myxc of numlist `yxcorr' {
foreach msx of numlist `sx' {
foreach msy of numlist `sy' {
foreach mm of numlist `m' {
foreach mp0 of numlist `p0' {
foreach mphi of numlist `phi' {
foreach mny of numlist `ny' {
foreach mnx of numlist `nx' {
foreach mnc of numlist `nc' {

  qui set obs `line'

/*
  The main bulk of the program deals with the various calculations of sample size *
  New sample size calculations will be added correspondingly

       sampsi two/one sample means/proportions

*NEW*  sampsi_reg  linear regression
       sampsi_mcc  matched case/control
       sampsi_rho  correlation

*/

if "`noise'"~="" local qui ""
else local qui "qui"

  if "`solve'"=="n" {
    /* Assume that the globals N_1 and N_2 contain the right information */
    local nomore 1 
    if "`onesample'"~="" local onesamp "`onesample'"
    else {
      if "`nosd'"~="1" local onesamp "sd2(`s2') ratio(`rat')"
      else local onesamp "ratio(`rat')"
    }
    if "`command'"=="sampsi" {
      if "`nosd'"=="1" local ss ""
      else local ss "sd1(`s1')"
      cap `qui' sampsi `h0' `ha', `ss' alpha(`a') power(`p') pre(`ppre') post(`ppost') r0(`rr0') ////
               r1(`rr1') r01(`rr01') `onesamp' `ssoptions'
      if _rc~=0 sampsi `h0' `ha', `ss' alpha(`a') power(`p') pre(`ppre') post(`ppost') r0(`rr0') ////
               r1(`rr1') r01(`rr01') `onesamp' `ssoptions'

    }
    else if "`command'"=="sampsi_reg" {
      cap `qui' sampsi_reg ,alt(`ha') null(`h0') sd1(`s1') alpha(`a') power(`p') ////
                `ssoptions' varmethod(`varmethod') sy(`msy') sx(`msx') yxcorr(`myxc')
      if _rc~=0 & "`qui'"~="" sampsi_reg ,alt(`ha') null(`h0') sd1(`s1') alpha(`a') power(`p') ////
                `ssoptions' varmethod(`varmethod') sy(`msy') sx(`msx') yxcorr(`myxc')
    }
    else if "`command'"=="sampsi_mcc" {
      cap `qui' sampsi_mcc ,alt(`ha') m(`mm') alpha(`a') power(`p') s(n) ////
                `ssoptions' phi(`mphi') p0(`mp0')
      if _rc~=0 & "`qui'"~="" sampsi_mcc ,alt(`ha') m(`mm') alpha(`a') power(`p') s(n) ////
                `ssoptions' phi(`mphi') p0(`mp0')
    }
    else if "`command'"=="sampsi_rho" {
      cap `qui' sampsi_rho ,alt(`ha') alpha(`a') power(`p')  ////
                `ssoptions'
      if _rc~=0 & "`qui'"~="" sampsi_rho ,alt(`ha') alpha(`a') power(`p')  ////
                `ssoptions'
    }
    else if "`command'"=="mvsampsi" {
      cap `qui' mvsampsi `ha', ny(`mny') nx(`mnx') nc(`mnc') alpha(`a') power(`p')
      if _rc~=0 & "`qui'"~="" mvsampsi `ha', ny(`mny') nx(`mnx') nc(`mnc') alpha(`a') power(`p')
      qui replace n1 = $S_1 in `line'
      qui replace n2 = $S_1 in `line'
      local nomore 0
    }

    if `nomore' {
      qui replace n1=`r(N_1)' in `line'
      qui replace n2=`r(N_2)' in `line'
    }
    qui replace power = `p' in `line'
    local depv "n1"
  }
  else if "`solve'"=="power" {
    local nomore 1 /*Assume r(power) contains power */
    if "`onesample'"~="" local onesamp "`onesample'"
    else {
      if "`nosd'"~="1" local onesamp "sd2(`s2') n2(`ss2') ratio(`rat')"
      else local onesamp " n2(`ss2') ratio(`rat')"
    }
    if "`command'"=="sampsi" {
      if "`nosd'"=="1" local ss ""
      else local ss "sd1(`s1')"
      cap `qui' sampsi `h0' `ha', `ss' alpha(`a') n1(`ss1') pre(`ppre') post(`ppost') r0(`rr0') ////
                      r1(`rr1') r01(`rr01') `onesamp'  `ssoptions'
      if _rc~=0 & "`qui'"~="" sampsi `h0' `ha', `ss' alpha(`a') n1(`ss1') pre(`ppre') post(`ppost') r0(`rr0') ////
                      r1(`rr1') r01(`rr01') `onesamp'  `ssoptions'
    }
    else if "`command'"=="sampsi_reg" {
      cap `qui' sampsi_reg ,alt(`ha') null(`h0') sd1(`s1') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' varmethod(`varmethod') sy(`msy') sx(`msx') yxcorr(`myxc')
      if _rc~=0 & "`qui'"~="" sampsi_reg ,alt(`ha') null(`h0') sd1(`s1') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' varmethod(`varmethod') sy(`msy') sx(`msx') yxcorr(`myxc')
    }
    else if "`command'"=="sampsi_mcc" {
      cap `qui' sampsi_mcc ,alt(`ha') m(`mm') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' phi(`mphi') p0(`mp0')
      if _rc~=0 & "`qui'"~="" sampsi_mcc ,alt(`ha') m(`mm') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' phi(`mphi') p0(`mp0')
    }
    else if "`command'"=="sampsi_rho" {
      cap `qui' sampsi_rho ,alt(`ha') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' 
      if _rc~=0 & "`qui'"~="" sampsi_rho ,alt(`ha') alpha(`a') n1(`ss1') s(power) ////
                `ssoptions' 
    }
    else if "`command'"=="mvsampsi" {
      cap `qui' mvsampsi `ha', n(`ss1') ny(`mny') nx(`mnx') nc(`mnc') alpha(`a')
      if _rc~=0 & "`qui'"~="" mvsampsi `ha', n(`ss1') ny(`mny') nx(`mnx') nc(`mnc') alpha(`a')
      qui replace power = $S_3 in `line'
      local nomore 0
    }
    if `nomore' qui replace power = `r(power)' in `line'
    qui replace n1=`ss1' in `line'
    qui replace n2=`ss2' in `line'
    local depv "power"
  }

  qui replace alt = `ha' in `line'
  qui replace null = `h0' in `line'
  qui replace sd1 = `s1' in `line'
  qui replace sd2 = `s2' in `line'
  qui replace alpha = `a' in `line'
  qui replace rho=`r' in `line'
  qui replace ratio=`rat' in `line'
  qui replace pre=`ppre' in `line'
  qui replace post=`ppost' in `line'
  qui replace r0 = `rr0' in `line'
  qui replace r1 = `rr1' in `line'
  qui replace r01 = `rr01' in `line'
  qui replace yxcorr = `myxc' in `line'
  qui replace sy = `msy' in `line'
  qui replace sx = `msx' in `line'
  qui replace m = `mm' in `line'
  qui replace p0 = `mp0' in `line'
  qui replace phi = `mphi' in `line'
  qui replace ny = `ny' in `line'
  qui replace nx = `nx' in `line'
  qui replace nc = `nc' in `line'

/* FUTURE release on clustered data 
 qui sampclus_new, obsclus(2) rho(`r')
 qui replace adjn = `r(n1)' in `line'
*/

  di as text _continue "."
  local `line++'
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
} /* myxc */
} /* msy  */
} /* msx  */
} /* m */
} /*p0*/
} /*phi*/
} /* ny */
} /* nx */
} /* nc */

lab var n1 "Sample Size for Group 1"
lab var n2 "Sample Size for Group 2"
lab var power "Power"
lab var alt "Alternative Value"
lab var null "Null Value"
lab var sd1 "Standard Deviation for Group 1"
lab var sd2 "Standard Deviation for Group 2"
lab var alpha "Significance Level"
lab var post "Number of Follow-up Measurements"
lab var pre "Number of Baseline Measurements"
lab var r0 "Correlation of Baseline Measurements"
lab var r1 "Correlation of Follow-up Measurements"
lab var r01 "Correlation of Follow-up and Baseline Measurements"
lab var yxcorr "Correlation of Y's and X's"
lab var sy "Standard Deviation for Y's"
lab var sx "Standard Deviation for X's"
if "`command'"=="sampsi_reg" {
  lab var n1 "Sample Size"
  lab var alt "Alternative Slope"
  lab var sd1 "Residual Standard Deviation"
}
if "`command'"=="sampsi_mcc" {
  lab var n1 "Number of Cases"
  lab var alt "Alternative Odds Ratio"
  lab var m "Number of matched controls"
  lab var phi "Correlation of exposure between pairs in matched set"
  lab var p0 "Probability of Exposure for Controls"
}

if `npts'~=1 {
  if "`mlabel'"~=""  twoway scatter `depv' `xvar', mlabel(`depv')  `gopt' `goptions' 
  else twoway line `depv' `xvar' , `gopt' `goptions' 

/* FUTURE force my v9 overlay command instead
  overlay9 line `depv' `xvar' , `gopt' `goptions'
*/

}
else {
  di as error "WARNING: only one calculation performed and this can be done by sampsi"
  exit(198)
}

if "`norestore'"=="" restore
end


