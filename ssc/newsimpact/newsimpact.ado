*!version 1.0 2008-02-18
*! Sune.Karlsson@oru.se
*
*! News impact curve for ARCH type models
*


program define newsimpact
version 9

syntax [, Sigma2(real -1) Range(real -1)]

if "`e(cmd)'" != "arch" {
  di as err "newsimpact can only be run after {help arch}"
  exit 198
}

if ( "`sigma2'" <= "0" ) {
  // use default, mean of estimated conditional variances
  tempname h
  quietly {
    predict `h' if e(sample), variance
    sum `h', meanonly
  }
  local sigma2 = r(mean)
}
local sdev = sqrt(`sigma2')

local nobs = _N
if ( `nobs' < 101 ) {
  if ( int(`nobs'/2) == `nobs'/2 ) {
    local nobs = `nobs' - 1
  }
}
else {
  local nobs = 101
}
local nobshalf = int(`nobs'/2)

if ( "`range'" <= "0" ) {
  local range = 2
}

local parnames : colfullnames e(b)
local maxlag = 1
// find max lag in parameter list
foreach name of local parnames {
  if regexm( "`name'", ":L([0-9]*)\." ) { 
    local lag = regexs(1)
    if ( "`lag'" == "" ) local lag = 1
    if ( `lag' > `maxlag' ) local maxlag = `lag'
  }
}
local lagplus = `maxlag'+1
local lagplus2 = `maxlag'+2

tempname z ztmp impact itmp
quietly {
  gen `impact' = .
  gen `z' = `range'*(_n-`nobshalf'-1)/`nobshalf' in 1/`nobs'
  gen `ztmp' = `sdev' in 1/`maxlag'
}
quietly: forvalues i = 1/`nobs' {
  replace `ztmp' = `sdev'*`z'[`i'] in `lagplus'
  capture: drop `itmp'
  predict `itmp' in 1/`lagplus2', variance at(`ztmp' `sigma2')
  replace `impact' = `itmp'[`lagplus2'] in `i'
}
label var `z' "News, z(t-1)"
label var `impact' "Response, sigma^2(t)"
//list `impact' `z' in 1/110

disp as text "News impact calculated at sigma^2 = `sigma2'"

twoway (line `impact' `z'), title("News impact curve")

end
