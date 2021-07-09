/* dbins - Compute the cutoff points for equiprobable bins for a given sample of coordinates using Euclidean distance
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define dbins , rclass
version 10.1
syntax varlist(min=2 max=2) , [bins(integer 20)]
tempname N ld maxDist minDist d breaks
tempvar quant
capture count
local N = r(N)
if `bins' <= 0 {
dis as error "The number of bins must be a positive integer"
error
}
if `bins' > comb(`N',2) {
dis as error "The number of bins cannot exceed the number of distances (N choose 2)"
error
}
local ld = `bins'-1
quietly {
eucldist `varlist'
pctile `quant' = TotDist , nq(`bins') 
mkmat `quant' in 1/`ld' , mat(`breaks')
capture summarize TotDist
matrix `maxDist' = r(max)
matrix `minDist' = r(min)
matrix `d' = J(`bins',1,.)
matrix `d'[1,1] = (`minDist'[1,1]+`breaks'[1,1])/2
matrix `d'[`bins',1] = (`maxDist'[1,1]+`breaks'[`ld',1])/2
forvalues i = 2/`ld' {
local j = `i'-1
matrix `d'[`i',1] = (`breaks'[`j',1]+`breaks'[`i',1])/2
}
}
return matrix d = `d'
end
