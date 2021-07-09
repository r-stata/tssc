log using TestSNPs.log, replace
pause on
* 
*
* Define the cancer file.
*
*
use TestSNPs.dta, clear
ds case_hpc, not
local snplist `r(varlist)'
sentinel case_hpc `snplist', delta(.05) version list showprogress
sentinel case_hpc snp8_128104117 rs6983267_T snp8_128191672, version list showprogress

log close
