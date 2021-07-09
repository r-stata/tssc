*! version 1.0.0  //  Ariel Linden 29mar2019 

program define retrodesign, rclass
version 11.0

        syntax anything, Se(numlist max=1) [ alpha(real 0.05) DF(string) SEED(string) Reps(integer 10000)  ]

		numlist "`anything'", min(1)
		tokenize `anything', parse(" ")
		local kn : list sizeof anything
		
		// error checking of std err
		if `se' <0 {
			di as err "standard error cannot be negative"
			exit 411
		}
		
		// Generate the matrix shell that will hold the results
		matrix X = J(`kn',3,0)
		
		// Loop over values of effect sizes
		forvalues i = 1/`kn' { 
			local A : word `i' of `anything'

			*************************************************
			* Gelman and Carlin’s (2014) simulation approach
			*************************************************
			if "`df'" != "" {
				if `df' > 9007199254740990 {
					di as err "df cannot be greater than 9007199254740990"
					exit 198
				}
			
				// set the seed
				if "`seed'" != "" {
					`version' set seed `seed'
				}
				local z = invt(`df',(1-`alpha'/2))
				local p_hi = 1 - t(`df', `z'- `A'/`se')
				local p_lo = t(`df', -`z'- `A'/`se')
				local power = `p_hi' + `p_lo'
				local typeS = cond(`A' >= 0, `p_lo'/`power', 1-(`p_lo'/`power'))

				tempvar sim estimate significant exaggeration
				quietly set obs `reps'
				gen `sim' = rt(`df')
				gen `estimate' = `A' + `se' * `sim'
				gen `significant' = abs(`estimate') > `se'*`z'
				gen `exaggeration' = abs(abs(`estimate')/`A')
				sum `exaggeration' if `significant'==1, meanonly
				local typeM = r(mean)
			} // end if "df"
		
			***********************************************
			* The closed form solution by Lu et al. (2018)
			***********************************************
			else {
				local z = invnorm(1-`alpha'/2)
				local p_hi = 1 - normal(`z'-`A'/`se')
				local p_lo = normal(-`z'-`A'/`se')
				local power = `p_hi' + `p_lo'
				local typeS = cond(`A' >= 0, `p_lo'/`power', 1-(`p_lo'/`power'))
				local lambda = `A'/`se'
				local typeM = (normalden(`lambda' + `z') + normalden(`lambda' - `z') + ///
					`lambda' * (normal(`lambda' + `z') + normal(`lambda' - `z') - 1)) / /// 
						(`lambda' * (1 - normal(`lambda' + `z') + normal(`lambda' - `z')))
			} // end "closed solution"

			// populate matrix with results after each loop of effect sizes
			matrix X[`i',1]= `power'
			matrix X[`i',2]= `typeS'
			matrix X[`i',3]= `typeM'

		} // end forvalues

		// format matrix table
		matrix colnames X = Power S-error M-error
		matrix rownames X = `anything' 
		matlist X, tw(12) lines(eq) border(bottom) showcoleq(comb) format(%9.4f) rowtitle(Effect)

		// table footnote
		di as txt
		di as txt "Note:"	
		di as txt "- Power is the probability that the statistical test correctly rejects the null hypothesis." 
		di as txt "- Type-S (sign) error is the probability of the sign being in the opposite direction of the effect size." 
		di as txt "- Type-M (magnitude) error is the factor by which the magnitude of the effect size might be exaggerated."

		// store results 
		mata : X = st_matrix("X")
		return matrix table = X

end
