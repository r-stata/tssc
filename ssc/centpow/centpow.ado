program centpow
version 11
//Revised 15oct2012
syntax anything [, NORMalize beta(real 0) saveas(str)]
quietly {
preserve
local smallnumber = .000000000000001	//Added to isolates' degree to avoid divide-by-zero error when 

//Check that beta is positive
if `beta' < 0 {
	noisily: display "{bf:ERROR -} The {it:beta} parameter must be positive."
	noisily: display " "
	}
error (`beta' < 0)

//Import data & check that matrix is symmetric
clear
insheet using `anything'
mata: network = st_data(.,.)
mata: symmetric = issymmetric(network)
mata: st_numscalar("r(symmetric)", symmetric)
if r(symmetric) == 0 {
	noisily: display "{bf:ERROR -} The matrix must be symmetric."
	noisily: display " "
	}
error (r(symmetric) == 0)

//Compute auxiliary matrices & values
mata: y = I(rows(network))
mata: z = J(rows(network),1,1)
mata: eigenvalue = symeigenvalues(network)
mata: dimension = eigenvalue[1,1]/eigenvalue[1,2]
mata: maxbeta = 1 / eigenvalue[1,1]

//Compute indices
mata: degree = network*z
mata: altercent = network*((network*z):+`smallnumber')
mata: alterpow = network*(1 :/ ((network*z):+`smallnumber'))
if `beta' == 0 mata: beta = Re(maxbeta * .995)		//Set beta to max allowable as default
		else mata: beta = `beta'
mata: betacent = (luinv(y - (beta * network)))*network*z
mata: betapow = (luinv(y - (-beta * network)))*network*z

//Flag violations of beta centrality/power assumptions
mata: st_numscalar("r(beta)", beta)
mata: st_numscalar("r(maxbeta)", Re(maxbeta))
mata: st_numscalar("r(dimension)", Re(dimension))

//Flag networks with multiple components, r(minpath) = 0
mata: x = network
mata: y = network
mata: z = network
local path = 1
while `path' < _N {
	mata: y = y * x
	mata: z = z + y
	local path = `path' + 1
	}
mata: st_numscalar("r(minpath)", min(z))

if r(beta) > r(maxbeta) {
	noisily: display"{bf:WARNING -} Beta centrality and power can not be interpreted"
	noisily: display "because the selected value of {it:beta} (" r(beta) ") exceeds"
	noisily: display "the maximum allowable value of " round(r(maxbeta), .001) "."
	noisily: display " "
	}
if r(dimension) < 2 {
	noisily: display "{bf:WARNING -} Beta centrality and power should be interpreted with"
	noisily: display "caution because the network's largest eigenvalue is only " round(r(dimension), .01) " times"
	noisily: display "the size of the 2nd largest eigenvalue."
	noisily: display " "
	}
if r(minpath) == 0 {
	noisily: display "{bf:WARNING -} Beta centrality and power should be interpreted with"
	noisily: display "caution because the network contains multiple components."
	noisily: display " "
	}

//Post results to Stata
clear
mata: results = (degree, altercent, alterpow, betacent, betapow)
mata: st_matrix("results", results)
svmat results
rename results1 degree
rename results2 altercent
rename results3 alterpow
rename results4 betacent
rename results5 betapow

//Compute normalizations, if requested
if "`normalize'" ~= "" {
gen degree2 = degree^2
sum degree2
gen ndegree = degree * (sqrt(_N/r(sum)))
gen altercent2 = altercent^2
sum altercent2
gen naltercent = altercent * (sqrt(_N/r(sum)))
gen alterpow2 = alterpow^2
sum alterpow2
gen nalterpow = alterpow * (sqrt(_N/r(sum)))
gen betacent2 = betacent^2
sum betacent2
gen nbetacent = betacent * (sqrt(_N/r(sum)))
gen betapow2 = betapow^2
sum betapow2
gen nbetapow = betapow * (sqrt(_N/r(sum)))
drop degree degree2 altercent altercent2 alterpow alterpow2 betacent betacent2 betapow betapow2
}

//Save and end
if "`saveas'" ~= "" save "`saveas'", replace
else save centpow, replace
restore
}
end
