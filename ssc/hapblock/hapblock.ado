*! Date    : 1 Jun 2005
*! Version : 1.04
*! Author  : Adrian Mander
*! Email   : junk.ade@ntlworld.com

/* DATA is all in allsnp
qui insheet using original.csv,clear comma 
qui _genp
qui compress
qui save allsnp,replace
*/

prog def hapblock
version 8.0
syntax [varlist] [using/] [, MV MVDEL HLEN(numlist) Start(integer 1) SModel(integer 1) Block(string) REPLACE]
preserve

global hapmod1 ""
global hapdf1 ""
global hapllhd1 ""
global hapmod0 ""
global hapdf0 ""
global hapllhd0 ""

if "`mvdel'"=="" & "`mv'"=="" local mvdel "mvdel"
if "`mvdel'"~="" & "`mv'"~="" local mvdel ""
if "`hlen'"=="" local hlen "2" 
if "`using'"=="" local using "results"
if "`block'"=="" local block "block"

di as text in smcl "{hline}"
di in text "Missing data will be specified in hapipf using the " in res "`mv'`mvdel'" in text " option"
di in text "The window length will be " in res "`hlen'"
di in text "All the results will be stored to file " in res "`using'"
di in text "All the test statistics will be stored to file " in res "`block'"
di in text in smcl "{hline}"

qui drop _all
qui set obs 0
qui gen model=""
qui gen df=.
qui gen double llhd=.
qui gen str80 vlist=""
qui gen str5 miss=""
qui gen sloc = .
qui gen plusi = .
qui gen haplen = .
qui g pctmiss =.
cap qui save "`using'",`replace'
if _rc~=0 {
  if _rc==602 di as error "`using'.dta already exists use -replace- option"
  exit(602)
}
restore

local wc:word count `varlist'
local mxnloc = `wc'/2


foreach haplen of numlist `hlen' { /*loop for the length of haplotype of interest */
  local step 1
  local lastloc = `mxnloc'-`haplen'+1
  forvalues loci=`start'(`step')`lastloc' {
    di as res _continue "`loci',"

    /*Create the varlist*/
    local vlist ""
    local sloc = 2*`loci'-1
    local lloc = 2*(`loci'+`haplen'-1)
    forv var = `sloc'/`lloc' {
       local temp: word `var' of `varlist'
       local vlist "`vlist' `temp'"
    }

    /* Loop through the models more at start and end*/
    
    local midloc=int(`haplen'/2+1)
    local endloc=`midloc'
    local startloc 1
    if `loci'==1 local modstep 1
    if `loci'~=1 local modstep=`midloc'-1
    if `loci'==`lastloc' {
       local modstep 1
       local endloc = `haplen'+1
       local startloc=`midloc'
    }
    /* Start at a particular model */
    if `smodel'~=1 {
      local startloc `smodel'
      local smodel 1
    }

    foreach i of numlist `startloc'(`modstep')`endloc' {
      local ipf "l1"
      local midloc = `haplen'/2+1
      forvalues loc = 2/`haplen' {
        if `i'==1 local ipf "`ipf'*l`loc'"
        if `i'~=1 & `loc'==`i'  local ipf "`ipf'+l`loc'" 
        if `i'~=1 & `loc'~=`i'  local ipf "`ipf'*l`loc'" 
      }

      preserve
      qui hapipf `vlist', ipf(`ipf') nolog quiet `mv' `mvdel'  model(1) acc(0.005) ipfacc(0.001) 

      qui use "`using'",replace     
      local nobs=_N+1
      qui set obs `nobs'
      qui replace sloc = `loci' in `nobs'
      qui replace plusi = `i' in `nobs'
      qui replace haplen = `haplen' in `nobs'
      qui replace model= "$hapmod1" in `nobs'
      qui replace df= $hapdf1 in `nobs'
      qui replace llhd = $hapllhd1 in `nobs'
      qui replace vlist = "`vlist'" in `nobs'
      qui replace miss = "`mv'`mvdel'" in `nobs'
      qui replace pctmiss = `r(nmiss)'/`r(N)' in `nobs' 
      qui save "`using'",replace
      restore

    }

  }
}


prores using results, b("`block'") `replace'

end

/* Process the output to find out where the blocks are */

prog def prores
syntax using/ [,Log Block(string) REPLACE]
preserve
qui use "`using'",replace

if _N==0 {
  di as error "No models have been fitted..!"
  di as error "Perhaps adjust the smodel() or start() choice?"
  exit(198)
}

/* Generate the test statistics */
qui compress
sort miss haplen sloc df
qui by miss haplen sloc: gen double chi = 2*(llhd[1]-llhd)
qui by miss haplen sloc: gen ddf = df-df[1]
qui by miss haplen sloc: gen double pv= chi2(chi,ddf)
qui gen position = sloc+plusi-1.5
qui gen mlen = cond(miss=="mv", "Window width "+string(haplen)+", MAR", "Window width "+string(haplen)+", MCAR")
qui gen double lpv = log(1-pv)
qui replace lpv = -40 if lpv==.

/* Calculate the blocks */

qui drop if df==0
qui gen sig=pv<0.05 
sort miss haplen sloc position

by miss haplen: gen blocks=cond(sig==1,"1", "") if _n==1

qui by miss haplen: gen blocke= string(position+0.5) if _n==_N
qui by miss haplen: replace blocks=cond(sig==1,                        /*
*/     cond( blocks[_n-1]=="", string(position-0.5), blocks[_n-1])  ,  /*
*/     ""   /*
*/ ) 
qui by miss haplen: replace blocke=cond(sig[_n+1]==0,     /*
*/     string(position+0.5)   ,                           /*
*/     ""   /*
*/ ) if _n~=_N
qui gen block = blocks+"-"+blocke if blocks~="" & blocke~=""
qui gen blocksize = real(blocke)-real(blocks)+1
qui compress

/*
tab blocksize mlen
tab block mlen
*/

lab var pv "p-value"
lab var lpv "log(1-pvalue)"
lab var position "Model Position of the + Sign"

cap qui save "`block'",`replace'
if _rc~=0 di as error "NOTE: `block'.dta already exists use the -replace- option"

if "`log'"=="" {
  local y "pv"
  local ylab "ylab(0 0.05 0.5 1.0)"
}
else {
  local y "lpv" 
  local ylab "yline(-.05129329)"
}

scatter `y' position `if', by(mlen) `ylab' yline(0.05) 

restore
end

