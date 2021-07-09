*! version 1.0.0  //  Ariel Linden 19feb2019 


program define bmii, rclass
version 11.0

	syntax anything(id="argument numlist") [, Metric Category ]

		numlist "`anything'", min(2) max(2)
		tokenize `anything', parse(" ")

		local ht `1'
		local wt `2'

		confirm number `ht'
		confirm number `wt'
	
		// Convert pounds to kilograms and inches to meters
		if "`metric'" == "" {
			local wtm = `wt' * 0.45359237
			local htm2 = (`ht' * 0.0254)^2
			local bmi = `wtm' / `htm2'
		}
		else local bmi = `wt' / `ht'^2
		di as txt "   BMI: " as result %5.3f `bmi'

		if "`category'" != "" {
		
			if `bmi' <16.001 {
				di as txt "   BMI category: Severe thinness"
			}
			else if `bmi' >= 16.001 & `bmi' <= 16.999 {
				di as txt "   BMI category: Moderate thinness"
			}
			else if `bmi' >= 17.000 & `bmi' <= 18.499 {
				di as txt "   BMI category: Mild thinness"
			}
			else if `bmi' >= 18.500 & `bmi' <= 24.999 {
				di as txt "   BMI category: Normal range"
			}
			else if `bmi' >= 25.000 & `bmi' <= 29.999 {
				di as txt "   BMI category: Pre-obese"
			}
			else if `bmi' >= 30.000 & `bmi' <= 34.999 {
				di as txt "   BMI category: Obese class I"
			}
			else if `bmi' >= 35.000 & `bmi' <= 39.999 {
				di as txt "   BMI category: Obese class II"
			}
			else if `bmi' >= 40.000 {
				di as txt "   BMI category: Obese class III"
			}
		}
	
		// return result
		return scalar bmi = `bmi'
end
