* do ~/Inc_preval/Report/Dec99/Altern_publ/Simulations/Exefiles/fwtdgen.do

pr de fwtdgen
qui {
syntax varlist(min = 2 max = 2), /*
*/ param(string) startd(string) endd(string) [prevd(string) atsamp addfu(integer 0) lnphi noshar]
tokenize `varlist'
local events `1'
local cens `2'

tempvar tmpcens censZ frailty g1var aHvar aIvar
*  g2var aLvar aIvar
gen `tmpcens' = .

tempname prev lat g1 g2 aH aL aI gparm
scalar `prev' = el(`param', 1, 1)
scalar `g1' = el(`param', 1, 2)
scalar `aH' = el(`param', 1, 3)
scalar `aI' = el(`param', 1, 4)
local gam1 = el(`param', 1, 5)
local gam2 = el(`param', 1, 6)

if `gam1' ~= . & `gam2' ~= . {
  local datsize = _N
  rndgam `datsize' `gam1' `gam2'
  rename xg `frailty'
  noi di "here"
  if "`noshar'" ~= "" {
    tempname frailty2
    rndgam `datsize' `gam1' `gam2'
    rename xg `frailty2'
  }
}
else {
  gen `frailty' = 1
}
if "`lnphi'" ~= "" {
  tempname P11 P01 P10 P00 H D0 phi
  /* note that addfu is ignored here!!! */
  scalar `phi' = exp(el(`param', 1, 9))
  scalar `H' = exp(- `g1')
  scalar `D0' = exp(- `aH')
  scalar `P11' = `phi' * (1 - `H') * (1 - `D0')
  scalar `P10' = (1 - `H') * (1 - (1 - `D0') * `phi')
  scalar `P01' = (1 - `D0') * (1 - (1 - `H') * `phi')
  scalar `P00' = 1 - `P11' - `P01' - `P10'

  gen prevalstat = uniform() < `prev'
  gen healthstat = prevalstat == 0
  tempvar Pind Pindtmp

  gen `Pindtmp' = uniform() if healthstat == 1
  gen `Pind' = 1 if `Pindtmp' < `P11'
  replace `Pind' = 2 if `Pindtmp' >= `P11' & `Pindtmp' < 1 - `H'
  replace `Pind' = 3 if `Pindtmp' >= 1 - `H' & `Pindtmp' < 1 - `P00'
  replace `Pind' = 4 if `Pindtmp' >= 1 - `P00'
  replace `Pind' = . if healthstat == 0

  gen T1 = - log(1 - uniform() * (1 - exp(- `g1'))) / `g1' if `Pind' <= 2
  gen ZH = - log(1 - uniform() * (1 - exp(- `aH'))) / `aH' if `Pind' == 1 | `Pind' == 3
  gen ZI = -log(uniform()) / `aI' if prevalstat == 1
}
else {
  gen `g1var' = `frailty' * `g1'
  if "`noshar'" == "" {
    gen `aHvar' = `frailty' * `aH'
  }
  else {
    gen `aHvar' = `frailty2' * `aH'
  }
  gen `aIvar' = `frailty' * `aI'

  gen prevalstat = uniform() < `prev'
  gen healthstat = prevalstat == 0

  gen T1 = -log(uniform()) / `g1var' if healthstat == 1
  gen ZH = -log(uniform()) / `aHvar' if healthstat == 1
  gen ZI = -log(uniform()) / `aIvar' if prevalstat == 1
}

local nparm = colsof(`param')
mat `gparm' = `param'[1, 7..`nparm']

if "`prevd'" == "" {
    ifrsampa `events' `tmpcens' if prevalstat == 1, density("if_norm") densmat("`gparm'") kval(4) compint("yes")
  }
if "`prevd'" == "wei" {
  tempname ialpha beta
  scalar `ialpha' = 1 / exp(el(`gparm', 1, 1))
  scalar `beta' = exp(el(`gparm', 1, 2))
  replace `events' = invgammap(`ialpha', uniform())^`ialpha' / `beta' if prevalstat == 1

}

replace `events' = T1 if healthstat == 1
egen `censZ' = rmin(ZH ZI)
replace `cens' = `censZ'
replace `events' = . if `events' > `cens'

for var `events' `cens': replace X = d(`startd') + X * (d(`endd') - d(`startd'))
for var `events' `cens': replace X = round(X, 1)
for var `events' `cens': replace X = . if X > d(`endd') + `addfu'

}

end


