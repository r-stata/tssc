/* eucldist - Euclidean distance function
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define eucldist
version 10.1
syntax varlist(min=2 max=2)
tempname N D Nsq TDist
quietly {
count
local N = r(N)
local Nsq = comb(`N',2)+`N'
matrix dissimilarity `D' = `varlist'
mata: D = st_matrix("`D'")
forvalues i = 1/`N' {
mata: D[`i',`i']=.
}
mata: dist = vech(D)
set obs `Nsq'
gen TotDist = .
order TotDist
mata: st_store(.,1,dist)
drop if TotDist == .
drop `varlist'
sort TotDist
}
end
